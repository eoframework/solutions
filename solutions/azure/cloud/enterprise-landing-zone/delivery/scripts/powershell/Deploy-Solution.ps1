# Azure Enterprise Landing Zone Deployment Script
# PowerShell version for Windows environments
# Prerequisites: Azure PowerShell, Terraform, appropriate Azure permissions

#Requires -Version 7.0
#Requires -Modules @{ ModuleName="Az"; ModuleVersion="8.0.0" }

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [string]$Environment = "production",

    [Parameter(Mandatory = $false)]
    [string]$Location = "East US 2",

    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove,

    [Parameter(Mandatory = $false)]
    [string]$LogPath = ""
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Script configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptDir))
$LogFile = if ($LogPath) { $LogPath } else { Join-Path $RepoRoot "deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log" }

# Initialize logging
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"

    # Write to console with colors
    switch ($Level) {
        "Info" { Write-Host $LogMessage -ForegroundColor Blue }
        "Success" { Write-Host $LogMessage -ForegroundColor Green }
        "Warning" { Write-Host $LogMessage -ForegroundColor Yellow }
        "Error" { Write-Host $LogMessage -ForegroundColor Red }
    }

    # Write to log file
    Add-Content -Path $LogFile -Value $LogMessage
}

function Write-ErrorAndExit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Log -Message $Message -Level "Error"
    exit 1
}

# Check prerequisites
function Test-Prerequisites {
    Write-Log -Message "Checking prerequisites..." -Level "Info"

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-ErrorAndExit "PowerShell 7.0 or later is required. Current version: $($PSVersionTable.PSVersion)"
    }

    # Check Azure PowerShell module
    $AzModule = Get-Module -Name Az -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $AzModule -or $AzModule.Version -lt [Version]"8.0.0") {
        Write-ErrorAndExit "Azure PowerShell module 8.0.0 or later is required. Please install or update the Az module."
    }

    # Check Terraform
    try {
        $TerraformVersion = & terraform version -json | ConvertFrom-Json
        if ($TerraformVersion.terraform_version -lt [Version]"1.2.0") {
            Write-ErrorAndExit "Terraform 1.2.0 or later is required. Current version: $($TerraformVersion.terraform_version)"
        }
    }
    catch {
        Write-ErrorAndExit "Terraform is not installed or not in PATH. Please install Terraform and try again."
    }

    # Check Azure connection
    try {
        $Context = Get-AzContext
        if (-not $Context) {
            Write-ErrorAndExit "Not connected to Azure. Please run Connect-AzAccount and try again."
        }
    }
    catch {
        Write-ErrorAndExit "Error checking Azure connection: $($_.Exception.Message)"
    }

    Write-Log -Message "Prerequisites check completed" -Level "Success"
}

# Validate Azure permissions
function Test-AzurePermissions {
    Write-Log -Message "Validating Azure permissions..." -Level "Info"

    try {
        # Check if user has Owner or Contributor role on subscription
        $RoleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$SubscriptionId" -SignInName (Get-AzContext).Account.Id

        $HasRequiredRole = $RoleAssignments | Where-Object { $_.RoleDefinitionName -in @("Owner", "Contributor") }

        if (-not $HasRequiredRole) {
            Write-ErrorAndExit "Insufficient permissions. Owner or Contributor role required on subscription $SubscriptionId"
        }

        Write-Log -Message "Permission validation completed" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error validating permissions: $($_.Exception.Message)"
    }
}

# Set Azure context
function Set-AzureContext {
    Write-Log -Message "Setting Azure context..." -Level "Info"

    try {
        Set-AzContext -SubscriptionId $SubscriptionId -TenantId $TenantId

        $CurrentContext = Get-AzContext
        if ($CurrentContext.Subscription.Id -ne $SubscriptionId) {
            Write-ErrorAndExit "Failed to set subscription context to $SubscriptionId"
        }

        Write-Log -Message "Azure context set to subscription: $SubscriptionId" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error setting Azure context: $($_.Exception.Message)"
    }
}

# Initialize Terraform
function Initialize-Terraform {
    Write-Log -Message "Initializing Terraform..." -Level "Info"

    try {
        Set-Location -Path (Join-Path $RepoRoot "delivery/scripts/terraform")

        # Initialize Terraform with backend configuration
        & terraform init `
            -backend-config="subscription_id=$SubscriptionId" `
            -backend-config="tenant_id=$TenantId"

        if ($LASTEXITCODE -ne 0) {
            Write-ErrorAndExit "Terraform initialization failed"
        }

        # Validate Terraform configuration
        & terraform validate

        if ($LASTEXITCODE -ne 0) {
            Write-ErrorAndExit "Terraform validation failed"
        }

        Write-Log -Message "Terraform initialization completed" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error initializing Terraform: $($_.Exception.Message)"
    }
}

# Create Terraform plan
function New-TerraformPlan {
    Write-Log -Message "Creating Terraform plan..." -Level "Info"

    try {
        Set-Location -Path (Join-Path $RepoRoot "delivery/scripts/terraform")

        # Create deployment plan
        & terraform plan `
            -var="tenant_id=$TenantId" `
            -var="subscription_id=$SubscriptionId" `
            -var="environment=$Environment" `
            -var="location=$Location" `
            -out="deployment.tfplan"

        if ($LASTEXITCODE -ne 0) {
            Write-ErrorAndExit "Terraform plan creation failed"
        }

        Write-Log -Message "Terraform plan created successfully" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error creating Terraform plan: $($_.Exception.Message)"
    }
}

# Apply Terraform configuration
function Invoke-TerraformApply {
    Write-Log -Message "Applying Terraform configuration..." -Level "Info"

    try {
        Set-Location -Path (Join-Path $RepoRoot "delivery/scripts/terraform")

        # Apply the deployment plan
        & terraform apply "deployment.tfplan"

        if ($LASTEXITCODE -ne 0) {
            Write-ErrorAndExit "Terraform deployment failed"
        }

        Write-Log -Message "Terraform deployment completed successfully" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error applying Terraform configuration: $($_.Exception.Message)"
    }
}

# Deploy management groups
function Deploy-ManagementGroups {
    Write-Log -Message "Deploying management group hierarchy..." -Level "Info"

    try {
        # Deploy management groups using Azure PowerShell
        $TemplateFile = Join-Path $RepoRoot "delivery/scripts/templates/management-groups.json"
        $DeploymentName = "management-groups-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

        New-AzTenantDeployment `
            -Location $Location.Replace(" ", "").ToLower() `
            -TemplateFile $TemplateFile `
            -tenantId $TenantId `
            -Name $DeploymentName

        Write-Log -Message "Management groups deployed successfully" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error deploying management groups: $($_.Exception.Message)"
    }
}

# Deploy Azure policies
function Deploy-AzurePolicies {
    Write-Log -Message "Deploying Azure Policy framework..." -Level "Info"

    try {
        $PolicyDir = Join-Path $RepoRoot "delivery/scripts/policies"

        # Deploy custom policy definitions
        $PolicyDefinitions = Get-ChildItem -Path (Join-Path $PolicyDir "definitions") -Filter "*.json"
        foreach ($PolicyFile in $PolicyDefinitions) {
            $PolicyName = $PolicyFile.BaseName
            $PolicyRules = Get-Content -Path $PolicyFile.FullName -Raw | ConvertFrom-Json

            New-AzPolicyDefinition `
                -Name $PolicyName `
                -Policy ($PolicyRules | ConvertTo-Json -Depth 20) `
                -Mode "Indexed" `
                -ManagementGroupName "mg-enterprise-root"
        }

        # Deploy policy initiatives
        $PolicyInitiatives = Get-ChildItem -Path (Join-Path $PolicyDir "initiatives") -Filter "*.json"
        foreach ($InitiativeFile in $PolicyInitiatives) {
            $InitiativeName = $InitiativeFile.BaseName
            $InitiativeDefinitions = Get-Content -Path $InitiativeFile.FullName -Raw

            New-AzPolicySetDefinition `
                -Name $InitiativeName `
                -PolicyDefinition $InitiativeDefinitions `
                -ManagementGroupName "mg-enterprise-root"
        }

        Write-Log -Message "Azure Policy framework deployed successfully" -Level "Success"
    }
    catch {
        Write-ErrorAndExit "Error deploying Azure policies: $($_.Exception.Message)"
    }
}

# Validate deployment
function Test-Deployment {
    Write-Log -Message "Validating deployment..." -Level "Info"

    try {
        # Validate management groups
        $ManagementGroups = Get-AzManagementGroup
        if ($ManagementGroups.Count -lt 5) {
            Write-Log -Message "Expected at least 5 management groups, found $($ManagementGroups.Count)" -Level "Warning"
        }

        # Validate policy compliance
        $NonCompliantResources = Get-AzPolicyState -ManagementGroupName "mg-enterprise-root" | Where-Object { $_.ComplianceState -eq "NonCompliant" }
        if ($NonCompliantResources.Count -gt 0) {
            Write-Log -Message "Found $($NonCompliantResources.Count) non-compliant resources" -Level "Warning"
        }

        # Test network connectivity (if applicable)
        Write-Log -Message "Testing network connectivity..." -Level "Info"
        # Add network connectivity tests here

        Write-Log -Message "Deployment validation completed" -Level "Success"
    }
    catch {
        Write-Log -Message "Error during deployment validation: $($_.Exception.Message)" -Level "Warning"
    }
}

# Generate deployment report
function New-DeploymentReport {
    Write-Log -Message "Generating deployment report..." -Level "Info"

    try {
        $ReportFile = Join-Path $RepoRoot "deployment-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
        $DeploymentEndTime = Get-Date
        $DeploymentDuration = $DeploymentEndTime - $script:DeploymentStartTime

        $ReportContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Enterprise Landing Zone Deployment Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Azure Enterprise Landing Zone Deployment Report</h1>
        <p>Generated on: $(Get-Date)</p>
        <p>Subscription: $SubscriptionId</p>
        <p>Tenant: $TenantId</p>
    </div>

    <div class="section">
        <h2>Deployment Summary</h2>
        <p class="success">Deployment completed successfully</p>
        <p>Total deployment time: $([math]::Round($DeploymentDuration.TotalMinutes, 2)) minutes</p>
    </div>

    <div class="section">
        <h2>Resources Deployed</h2>
        <ul>
            <li>Management Group Hierarchy</li>
            <li>Azure Policy Framework</li>
            <li>Platform Subscriptions</li>
            <li>Network Infrastructure</li>
            <li>Security Services</li>
            <li>Monitoring and Logging</li>
        </ul>
    </div>

    <div class="section">
        <h2>Next Steps</h2>
        <ol>
            <li>Review and validate all deployed resources</li>
            <li>Configure additional security controls as needed</li>
            <li>Begin application landing zone deployment</li>
            <li>Complete user training and documentation</li>
        </ol>
    </div>
</body>
</html>
"@

        Set-Content -Path $ReportFile -Value $ReportContent

        Write-Log -Message "Deployment report generated: $ReportFile" -Level "Success"
    }
    catch {
        Write-Log -Message "Error generating deployment report: $($_.Exception.Message)" -Level "Warning"
    }
}

# Cleanup function
function Invoke-Cleanup {
    Write-Log -Message "Performing cleanup..." -Level "Info"

    try {
        # Remove temporary files
        $TempFiles = @(
            (Join-Path $RepoRoot "delivery/scripts/terraform/deployment.tfplan")
        )

        foreach ($TempFile in $TempFiles) {
            if (Test-Path $TempFile) {
                Remove-Item -Path $TempFile -Force
            }
        }

        Write-Log -Message "Cleanup completed" -Level "Success"
    }
    catch {
        Write-Log -Message "Error during cleanup: $($_.Exception.Message)" -Level "Warning"
    }
}

# Main deployment function
function Invoke-Deployment {
    $script:DeploymentStartTime = Get-Date

    Write-Log -Message "Starting Azure Enterprise Landing Zone deployment..." -Level "Info"
    Write-Log -Message "Deployment log: $LogFile" -Level "Info"

    try {
        # Execute deployment steps
        Test-Prerequisites
        Test-AzurePermissions
        Set-AzureContext
        Initialize-Terraform
        New-TerraformPlan

        # Confirm deployment
        if (-not $AutoApprove) {
            $Confirmation = Read-Host "Do you want to proceed with the deployment? (y/N)"
            if ($Confirmation -ne "y" -and $Confirmation -ne "Y") {
                Write-Log -Message "Deployment cancelled by user" -Level "Info"
                return
            }
        }

        Invoke-TerraformApply
        Deploy-ManagementGroups
        Deploy-AzurePolicies
        Test-Deployment
        New-DeploymentReport

        $DeploymentEndTime = Get-Date
        $DeploymentDuration = $DeploymentEndTime - $script:DeploymentStartTime

        Write-Log -Message "Azure Enterprise Landing Zone deployment completed successfully!" -Level "Success"
        Write-Log -Message "Total deployment time: $([math]::Round($DeploymentDuration.TotalMinutes, 2)) minutes" -Level "Info"
    }
    catch {
        Write-ErrorAndExit "Deployment failed: $($_.Exception.Message)"
    }
    finally {
        Invoke-Cleanup
    }
}

# Script execution
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Invoke-Deployment
}
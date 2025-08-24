# Google Cloud Landing Zone Deployment Script
# PowerShell script for deploying Google Cloud Landing Zone infrastructure

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,
    
    [Parameter(Mandatory = $true)]
    [string]$OrganizationId,
    
    [Parameter(Mandatory = $true)]
    [string]$BillingAccountId,
    
    [Parameter(Mandatory = $false)]
    [string]$Region = "us-central1",
    
    [Parameter(Mandatory = $false)]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "terraform.tfvars",
    
    [Parameter(Mandatory = $false)]
    [switch]$PlanOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove,
    
    [Parameter(Mandatory = $false)]
    [switch]$Destroy
)

# Script configuration
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Global variables
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TerraformPath = Join-Path $ScriptPath "..\terraform"
$LogFile = Join-Path $ScriptPath "deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Logging function
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { Write-Host $logMessage -ForegroundColor White }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
    }
    
    Add-Content -Path $LogFile -Value $logMessage
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..." "INFO"
    
    # Check if gcloud CLI is installed
    try {
        $gcloudVersion = gcloud version --format="value(Google Cloud SDK)"
        Write-Log "Google Cloud SDK version: $gcloudVersion" "INFO"
    }
    catch {
        Write-Log "Google Cloud SDK not found. Please install gcloud CLI." "ERROR"
        throw "Prerequisites check failed"
    }
    
    # Check if Terraform is installed
    try {
        $terraformVersion = terraform version -json | ConvertFrom-Json
        Write-Log "Terraform version: $($terraformVersion.terraform_version)" "INFO"
    }
    catch {
        Write-Log "Terraform not found. Please install Terraform." "ERROR"
        throw "Prerequisites check failed"
    }
    
    # Check authentication
    try {
        $currentAccount = gcloud config get-value account
        if ([string]::IsNullOrEmpty($currentAccount)) {
            throw "Not authenticated"
        }
        Write-Log "Authenticated as: $currentAccount" "INFO"
    }
    catch {
        Write-Log "Not authenticated with Google Cloud. Run 'gcloud auth login'" "ERROR"
        throw "Prerequisites check failed"
    }
    
    # Check if configuration file exists
    $configPath = Join-Path $TerraformPath $ConfigFile
    if (-not (Test-Path $configPath)) {
        Write-Log "Configuration file not found: $configPath" "ERROR"
        throw "Prerequisites check failed"
    }
    
    Write-Log "Prerequisites check completed successfully" "SUCCESS"
}

# Function to validate configuration
function Test-Configuration {
    param(
        [string]$ConfigPath
    )
    
    Write-Log "Validating configuration..." "INFO"
    
    # Read and validate configuration file
    $config = Get-Content $ConfigPath -Raw
    
    # Check required variables
    $requiredVars = @("project_id", "organization_id", "billing_account_id", "region")
    foreach ($var in $requiredVars) {
        if ($config -notmatch "$var\s*=") {
            Write-Log "Required variable '$var' not found in configuration" "ERROR"
            throw "Configuration validation failed"
        }
    }
    
    # Validate project ID format
    if ($config -match 'project_id\s*=\s*"([^"]+)"') {
        $projectIdFromConfig = $matches[1]
        if ($projectIdFromConfig -notmatch '^[a-z][-a-z0-9]{5,29}$') {
            Write-Log "Invalid project ID format: $projectIdFromConfig" "ERROR"
            throw "Configuration validation failed"
        }
    }
    
    Write-Log "Configuration validation completed successfully" "SUCCESS"
}

# Function to setup Google Cloud project
function Initialize-GoogleCloudProject {
    Write-Log "Setting up Google Cloud project..." "INFO"
    
    try {
        # Set project
        gcloud config set project $ProjectId
        Write-Log "Set active project to: $ProjectId" "INFO"
        
        # Check if project exists, create if not
        $projectExists = gcloud projects describe $ProjectId --format="value(projectId)" 2>$null
        if ([string]::IsNullOrEmpty($projectExists)) {
            Write-Log "Creating project: $ProjectId" "INFO"
            gcloud projects create $ProjectId --organization=$OrganizationId
            
            # Link billing account
            Write-Log "Linking billing account: $BillingAccountId" "INFO"
            gcloud billing projects link $ProjectId --billing-account=$BillingAccountId
        } else {
            Write-Log "Project already exists: $ProjectId" "INFO"
        }
        
        # Enable required APIs
        Write-Log "Enabling required APIs..." "INFO"
        $requiredApis = @(
            "cloudresourcemanager.googleapis.com",
            "compute.googleapis.com",
            "iam.googleapis.com",
            "logging.googleapis.com",
            "monitoring.googleapis.com",
            "storage.googleapis.com",
            "cloudkms.googleapis.com",
            "dns.googleapis.com"
        )
        
        foreach ($api in $requiredApis) {
            Write-Log "Enabling API: $api" "INFO"
            gcloud services enable $api --project=$ProjectId
        }
        
        Write-Log "Google Cloud project setup completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to setup Google Cloud project: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to setup Terraform backend
function Initialize-TerraformBackend {
    Write-Log "Setting up Terraform backend..." "INFO"
    
    try {
        $stateBucket = "$ProjectId-terraform-state"
        
        # Check if bucket exists, create if not
        $bucketExists = gsutil ls -b gs://$stateBucket 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Creating Terraform state bucket: $stateBucket" "INFO"
            gsutil mb gs://$stateBucket
            
            # Enable versioning
            gsutil versioning set on gs://$stateBucket
            Write-Log "Enabled versioning on state bucket" "INFO"
            
            # Set lifecycle policy
            $lifecycleConfig = @"
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 365,
          "isLive": false
        }
      }
    ]
  }
}
"@
            $lifecycleConfig | Out-File -FilePath "lifecycle.json" -Encoding UTF8
            gsutil lifecycle set lifecycle.json gs://$stateBucket
            Remove-Item "lifecycle.json"
            Write-Log "Applied lifecycle policy to state bucket" "INFO"
        } else {
            Write-Log "Terraform state bucket already exists: $stateBucket" "INFO"
        }
        
        Write-Log "Terraform backend setup completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to setup Terraform backend: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to initialize Terraform
function Initialize-Terraform {
    Write-Log "Initializing Terraform..." "INFO"
    
    try {
        Push-Location $TerraformPath
        
        # Initialize Terraform
        terraform init
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform init failed"
        }
        
        # Select or create workspace
        $workspaceName = "$Environment-$Region"
        $workspaceExists = terraform workspace list | Select-String $workspaceName
        if (-not $workspaceExists) {
            Write-Log "Creating Terraform workspace: $workspaceName" "INFO"
            terraform workspace new $workspaceName
        } else {
            Write-Log "Selecting Terraform workspace: $workspaceName" "INFO"
            terraform workspace select $workspaceName
        }
        
        # Validate configuration
        terraform validate
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform validation failed"
        }
        
        Write-Log "Terraform initialization completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to initialize Terraform: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

# Function to plan Terraform deployment
function Invoke-TerraformPlan {
    Write-Log "Running Terraform plan..." "INFO"
    
    try {
        Push-Location $TerraformPath
        
        $planFile = "tfplan-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        
        # Run terraform plan
        terraform plan -var-file=$ConfigFile -out=$planFile
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform plan failed"
        }
        
        # Show plan summary
        Write-Log "Terraform plan completed successfully" "SUCCESS"
        Write-Log "Plan file created: $planFile" "INFO"
        
        return $planFile
    }
    catch {
        Write-Log "Failed to run Terraform plan: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

# Function to apply Terraform deployment
function Invoke-TerraformApply {
    param(
        [string]$PlanFile
    )
    
    Write-Log "Applying Terraform deployment..." "INFO"
    
    try {
        Push-Location $TerraformPath
        
        if ($AutoApprove) {
            terraform apply -auto-approve $PlanFile
        } else {
            # Interactive approval
            Write-Host "`nReview the plan above. Do you want to continue with the deployment? (y/N): " -NoNewline -ForegroundColor Yellow
            $response = Read-Host
            if ($response -match '^[Yy]') {
                terraform apply $PlanFile
            } else {
                Write-Log "Deployment cancelled by user" "WARN"
                return
            }
        }
        
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform apply failed"
        }
        
        # Show outputs
        Write-Log "Deployment outputs:" "INFO"
        terraform output
        
        Write-Log "Terraform deployment completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Failed to apply Terraform deployment: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

# Function to destroy Terraform resources
function Invoke-TerraformDestroy {
    Write-Log "Destroying Terraform resources..." "WARN"
    
    try {
        Push-Location $TerraformPath
        
        # Warning message
        Write-Host "`nWARNING: This will destroy all resources managed by Terraform!" -ForegroundColor Red
        Write-Host "This action cannot be undone!" -ForegroundColor Red
        Write-Host "`nAre you sure you want to continue? (type 'yes' to confirm): " -NoNewline -ForegroundColor Red
        $confirmation = Read-Host
        
        if ($confirmation -eq "yes") {
            if ($AutoApprove) {
                terraform destroy -var-file=$ConfigFile -auto-approve
            } else {
                terraform destroy -var-file=$ConfigFile
            }
            
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform destroy failed"
            }
            
            Write-Log "Resources destroyed successfully" "SUCCESS"
        } else {
            Write-Log "Destroy operation cancelled" "INFO"
        }
    }
    catch {
        Write-Log "Failed to destroy resources: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Pop-Location
    }
}

# Function to perform post-deployment validation
function Test-Deployment {
    Write-Log "Performing post-deployment validation..." "INFO"
    
    try {
        # Check VPC networks
        Write-Log "Validating VPC networks..." "INFO"
        $networks = gcloud compute networks list --format="value(name)" --filter="name:*vpc"
        if ($networks) {
            Write-Log "Found VPC networks: $($networks -join ', ')" "INFO"
        } else {
            Write-Log "No VPC networks found" "WARN"
        }
        
        # Check firewall rules
        Write-Log "Validating firewall rules..." "INFO"
        $firewallRules = gcloud compute firewall-rules list --format="value(name)" | Measure-Object
        Write-Log "Found $($firewallRules.Count) firewall rules" "INFO"
        
        # Check IAM policies
        Write-Log "Validating IAM policies..." "INFO"
        $iamPolicies = gcloud projects get-iam-policy $ProjectId --format="value(bindings.members[])" | Measure-Object
        Write-Log "Found $($iamPolicies.Count) IAM bindings" "INFO"
        
        Write-Log "Post-deployment validation completed" "SUCCESS"
    }
    catch {
        Write-Log "Post-deployment validation failed: $($_.Exception.Message)" "WARN"
    }
}

# Function to generate deployment report
function New-DeploymentReport {
    Write-Log "Generating deployment report..." "INFO"
    
    try {
        Push-Location $TerraformPath
        
        $reportFile = Join-Path $ScriptPath "deployment-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        
        # Get Terraform state
        $state = terraform show -json | ConvertFrom-Json
        
        # Create deployment report
        $report = @{
            timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
            project_id = $ProjectId
            organization_id = $OrganizationId
            region = $Region
            environment = $Environment
            terraform_version = terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version
            resources_created = $state.values.root_module.resources.Count
            deployment_log = $LogFile
        }
        
        # Add resource summary
        $resourceTypes = $state.values.root_module.resources | Group-Object type
        $report.resource_summary = @{}
        foreach ($type in $resourceTypes) {
            $report.resource_summary[$type.Name] = $type.Count
        }
        
        # Save report
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
        Write-Log "Deployment report saved to: $reportFile" "SUCCESS"
    }
    catch {
        Write-Log "Failed to generate deployment report: $($_.Exception.Message)" "WARN"
    }
    finally {
        Pop-Location
    }
}

# Main execution
function Main {
    try {
        Write-Log "Starting Google Cloud Landing Zone deployment" "INFO"
        Write-Log "Project ID: $ProjectId" "INFO"
        Write-Log "Organization ID: $OrganizationId" "INFO"
        Write-Log "Region: $Region" "INFO"
        Write-Log "Environment: $Environment" "INFO"
        Write-Log "Log file: $LogFile" "INFO"
        
        # Check prerequisites
        Test-Prerequisites
        
        # Validate configuration
        $configPath = Join-Path $TerraformPath $ConfigFile
        Test-Configuration -ConfigPath $configPath
        
        if ($Destroy) {
            # Destroy resources
            Initialize-Terraform
            Invoke-TerraformDestroy
        } else {
            # Deploy resources
            Initialize-GoogleCloudProject
            Initialize-TerraformBackend
            Initialize-Terraform
            
            $planFile = Invoke-TerraformPlan
            
            if (-not $PlanOnly) {
                Invoke-TerraformApply -PlanFile $planFile
                Test-Deployment
                New-DeploymentReport
            } else {
                Write-Log "Plan-only mode: Skipping apply phase" "INFO"
            }
        }
        
        Write-Log "Script execution completed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Script execution failed: $($_.Exception.Message)" "ERROR"
        Write-Log "Check the log file for details: $LogFile" "ERROR"
        exit 1
    }
}

# Execute main function
Main
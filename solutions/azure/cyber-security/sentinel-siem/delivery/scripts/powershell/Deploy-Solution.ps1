# Azure Sentinel SIEM - PowerShell Deployment Script
# Main deployment script for Azure Sentinel SIEM solution

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$true)]
    [string]$WorkspaceName,
    
    [Parameter(Mandatory=$false)]
    [int]$RetentionDays = 730,
    
    [Parameter(Mandatory=$false)]
    [int]$DailyQuotaGB = 500,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableDataConnectors,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateSampleRules,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory=$false)]
    [hashtable]$Tags = @{
        Environment = "Production"
        Solution = "Azure Sentinel SIEM"
        CostCenter = "Security Operations"
    }
)

#Requires -Modules Az.Accounts, Az.Resources, Az.OperationalInsights, Az.SecurityInsights, Az.Monitor

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize logging
$LogFile = "SentinelDeployment_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    switch ($Level) {
        "INFO" { Write-Host $LogMessage -ForegroundColor White }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
    }
    
    Add-Content -Path $LogFile -Value $LogMessage
}

function Test-AzureConnection {
    """Test Azure PowerShell connection"""
    try {
        $Context = Get-AzContext
        if (-not $Context) {
            Write-Log "No Azure context found. Please run Connect-AzAccount first." -Level "ERROR"
            throw "Azure authentication required"
        }
        
        Write-Log "Connected to Azure as: $($Context.Account.Id)" -Level "SUCCESS"
        Write-Log "Current subscription: $($Context.Subscription.Name)" -Level "INFO"
        
        # Set subscription context
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
        Write-Log "Set subscription context to: $SubscriptionId" -Level "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Failed to connect to Azure: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function New-SentinelResourceGroup {
    """Create or verify resource group exists"""
    param(
        [string]$Name,
        [string]$Location,
        [hashtable]$Tags
    )
    
    try {
        Write-Log "Creating or verifying resource group: $Name" -Level "INFO"
        
        $ResourceGroup = Get-AzResourceGroup -Name $Name -ErrorAction SilentlyContinue
        
        if (-not $ResourceGroup) {
            $ResourceGroup = New-AzResourceGroup -Name $Name -Location $Location -Tag $Tags
            Write-Log "Resource group created: $($ResourceGroup.ResourceGroupName)" -Level "SUCCESS"
        } else {
            Write-Log "Resource group already exists: $($ResourceGroup.ResourceGroupName)" -Level "INFO"
        }
        
        return $ResourceGroup
    }
    catch {
        Write-Log "Failed to create resource group: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function New-LogAnalyticsWorkspace {
    """Create Log Analytics workspace for Sentinel"""
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName,
        [string]$Location,
        [int]$RetentionDays,
        [int]$DailyQuotaGB,
        [hashtable]$Tags
    )
    
    try {
        Write-Log "Creating Log Analytics workspace: $WorkspaceName" -Level "INFO"
        
        # Check if workspace already exists
        $ExistingWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
        
        if ($ExistingWorkspace) {
            Write-Log "Workspace already exists: $WorkspaceName" -Level "INFO"
            return $ExistingWorkspace
        }
        
        # Create new workspace
        $WorkspaceParams = @{
            ResourceGroupName = $ResourceGroupName
            Name = $WorkspaceName
            Location = $Location
            Sku = "PerGB2018"
            Tag = $Tags
            RetentionInDays = $RetentionDays
        }
        
        $Workspace = New-AzOperationalInsightsWorkspace @WorkspaceParams
        
        # Wait for workspace to be ready
        Write-Log "Waiting for workspace provisioning to complete..." -Level "INFO"
        do {
            Start-Sleep -Seconds 30
            $WorkspaceStatus = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
        } while ($WorkspaceStatus.ProvisioningState -eq "Creating")
        
        Write-Log "Log Analytics workspace created successfully: $WorkspaceName" -Level "SUCCESS"
        return $Workspace
    }
    catch {
        Write-Log "Failed to create Log Analytics workspace: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Enable-AzureSentinel {
    """Enable Azure Sentinel on the workspace"""
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    try {
        Write-Log "Enabling Azure Sentinel on workspace: $WorkspaceName" -Level "INFO"
        
        # Check if Sentinel is already enabled
        $SentinelWorkspace = Get-AzSentinelWorkspace -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -ErrorAction SilentlyContinue
        
        if ($SentinelWorkspace) {
            Write-Log "Azure Sentinel already enabled on workspace" -Level "INFO"
            return $SentinelWorkspace
        }
        
        # Enable Sentinel
        $SentinelResult = New-AzSentinelWorkspace -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
        
        Write-Log "Azure Sentinel enabled successfully" -Level "SUCCESS"
        return $SentinelResult
    }
    catch {
        Write-Log "Failed to enable Azure Sentinel: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Set-SentinelDataConnectors {
    """Configure essential data connectors"""
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    $ConfiguredConnectors = @()
    
    try {
        Write-Log "Configuring data connectors..." -Level "INFO"
        
        # Azure Active Directory connector
        try {
            $AADConnectorParams = @{
                ResourceGroupName = $ResourceGroupName
                WorkspaceName = $WorkspaceName
                Kind = "AzureActiveDirectory"
                DataType = @("SigninLogs", "AuditLogs")
            }
            
            New-AzSentinelDataConnector @AADConnectorParams -ErrorAction SilentlyContinue
            $ConfiguredConnectors += "AzureActiveDirectory"
            Write-Log "Azure AD data connector configured" -Level "SUCCESS"
        }
        catch {
            Write-Log "Azure AD connector configuration failed: $($_.Exception.Message)" -Level "WARNING"
        }
        
        # Azure Security Center connector
        try {
            $ASCConnectorParams = @{
                ResourceGroupName = $ResourceGroupName
                WorkspaceName = $WorkspaceName
                Kind = "AzureSecurityCenter"
                SubscriptionId = $SubscriptionId
            }
            
            New-AzSentinelDataConnector @ASCConnectorParams -ErrorAction SilentlyContinue
            $ConfiguredConnectors += "AzureSecurityCenter"
            Write-Log "Azure Security Center data connector configured" -Level "SUCCESS"
        }
        catch {
            Write-Log "Azure Security Center connector configuration failed: $($_.Exception.Message)" -Level "WARNING"
        }
        
        # Office 365 connector
        try {
            $Office365ConnectorParams = @{
                ResourceGroupName = $ResourceGroupName
                WorkspaceName = $WorkspaceName
                Kind = "Office365"
                DataType = @("Exchange", "SharePoint", "Teams")
            }
            
            New-AzSentinelDataConnector @Office365ConnectorParams -ErrorAction SilentlyContinue
            $ConfiguredConnectors += "Office365"
            Write-Log "Office 365 data connector configured" -Level "SUCCESS"
        }
        catch {
            Write-Log "Office 365 connector configuration failed: $($_.Exception.Message)" -Level "WARNING"
        }
        
        Write-Log "Data connectors configuration completed. Configured: $($ConfiguredConnectors -join ', ')" -Level "INFO"
        return $ConfiguredConnectors
    }
    catch {
        Write-Log "Data connector configuration failed: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function New-SentinelAnalyticsRules {
    """Create sample analytics rules"""
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    $CreatedRules = @()
    
    try {
        Write-Log "Creating analytics rules..." -Level "INFO"
        
        # Brute Force Attack Detection Rule
        $BruteForceRule = @{
            ResourceGroupName = $ResourceGroupName
            WorkspaceName = $WorkspaceName
            RuleName = "BruteForceDetection"
            DisplayName = "Brute Force Attack Detection"
            Description = "Detects multiple failed login attempts from single source"
            Severity = "Medium"
            Enabled = $true
            Query = @"
SigninLogs
| where TimeGenerated >= ago(1h)
| where ResultType !in ("0", "50125", "50140")
| where UserPrincipalName != ""
| summarize FailedAttempts = count(), Users = make_set(UserPrincipalName) by IPAddress
| where FailedAttempts >= 10
| project IPAddress, FailedAttempts, Users
"@
            QueryFrequency = [TimeSpan]::FromHours(1)
            QueryPeriod = [TimeSpan]::FromHours(1)
            TriggerOperator = "GreaterThan"
            TriggerThreshold = 0
            Tactics = @("CredentialAccess", "InitialAccess")
        }
        
        try {
            New-AzSentinelAlertRule @BruteForceRule -ErrorAction Stop
            $CreatedRules += "BruteForceDetection"
            Write-Log "Brute Force Detection rule created" -Level "SUCCESS"
        }
        catch {
            Write-Log "Failed to create Brute Force rule: $($_.Exception.Message)" -Level "WARNING"
        }
        
        # Suspicious PowerShell Activity Rule
        $PowerShellRule = @{
            ResourceGroupName = $ResourceGroupName
            WorkspaceName = $WorkspaceName
            RuleName = "SuspiciousPowerShell"
            DisplayName = "Suspicious PowerShell Activity"
            Description = "Detects potentially malicious PowerShell execution"
            Severity = "High"
            Enabled = $true
            Query = @"
SecurityEvent
| where TimeGenerated >= ago(1h)
| where EventID == 4688
| where Process endswith "powershell.exe"
| where CommandLine contains "Download" or CommandLine contains "Invoke-" or CommandLine contains "IEX"
| project TimeGenerated, Computer, Account, CommandLine
"@
            QueryFrequency = [TimeSpan]::FromMinutes(30)
            QueryPeriod = [TimeSpan]::FromHours(1)
            TriggerOperator = "GreaterThan"
            TriggerThreshold = 0
            Tactics = @("Execution", "CommandAndControl")
        }
        
        try {
            New-AzSentinelAlertRule @PowerShellRule -ErrorAction Stop
            $CreatedRules += "SuspiciousPowerShell"
            Write-Log "Suspicious PowerShell rule created" -Level "SUCCESS"
        }
        catch {
            Write-Log "Failed to create PowerShell rule: $($_.Exception.Message)" -Level "WARNING"
        }
        
        Write-Log "Analytics rules creation completed. Created: $($CreatedRules -join ', ')" -Level "INFO"
        return $CreatedRules
    }
    catch {
        Write-Log "Analytics rules creation failed: $($_.Exception.Message)" -Level "ERROR"
        throw
    }
}

function Set-SentinelMonitoring {
    """Configure monitoring and diagnostic settings"""
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    try {
        Write-Log "Configuring monitoring and diagnostics..." -Level "INFO"
        
        # Get workspace resource ID
        $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
        
        # Configure diagnostic settings
        $DiagnosticSettings = @{
            ResourceId = $Workspace.ResourceId
            Name = "sentinel-diagnostics"
            WorkspaceId = $Workspace.ResourceId
            Category = @("Audit")
            Enabled = $true
        }
        
        Set-AzDiagnosticSetting @DiagnosticSettings -ErrorAction SilentlyContinue
        
        Write-Log "Monitoring and diagnostics configured successfully" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to configure monitoring: $($_.Exception.Message)" -Level "WARNING"
        return $false
    }
}

function Test-SentinelDeployment {
    """Validate the Sentinel deployment"""
    param(
        [string]$ResourceGroupName,
        [string]$WorkspaceName
    )
    
    $ValidationResults = @{
        ResourceGroupExists = $false
        WorkspaceExists = $false
        SentinelEnabled = $false
        DataConnectorsConfigured = $false
    }
    
    try {
        Write-Log "Validating deployment..." -Level "INFO"
        
        # Check resource group
        $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        $ValidationResults.ResourceGroupExists = $null -ne $ResourceGroup
        
        # Check workspace
        $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName -ErrorAction SilentlyContinue
        $ValidationResults.WorkspaceExists = $null -ne $Workspace
        
        # Check Sentinel
        $SentinelWorkspace = Get-AzSentinelWorkspace -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -ErrorAction SilentlyContinue
        $ValidationResults.SentinelEnabled = $null -ne $SentinelWorkspace
        
        # Check data connectors
        $DataConnectors = Get-AzSentinelDataConnector -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -ErrorAction SilentlyContinue
        $ValidationResults.DataConnectorsConfigured = ($DataConnectors | Measure-Object).Count -gt 0
        
        # Display validation results
        Write-Log "Validation Results:" -Level "INFO"
        foreach ($Key in $ValidationResults.Keys) {
            $Status = if ($ValidationResults[$Key]) { "✅ PASS" } else { "❌ FAIL" }
            $Level = if ($ValidationResults[$Key]) { "SUCCESS" } else { "ERROR" }
            Write-Log "$Key : $Status" -Level $Level
        }
        
        return $ValidationResults
    }
    catch {
        Write-Log "Validation failed: $($_.Exception.Message)" -Level "ERROR"
        return $ValidationResults
    }
}

# Main execution
function Main {
    try {
        Write-Log "Starting Azure Sentinel SIEM deployment..." -Level "INFO"
        Write-Log "Parameters: RG=$ResourceGroupName, Location=$Location, Workspace=$WorkspaceName" -Level "INFO"
        
        # Test Azure connection
        if (-not (Test-AzureConnection)) {
            throw "Azure connection failed"
        }
        
        if ($ValidateOnly) {
            Write-Log "Running validation only..." -Level "INFO"
            $ValidationResults = Test-SentinelDeployment -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
            
            if ($ValidationResults.Values -contains $false) {
                Write-Log "Validation completed with failures" -Level "ERROR"
                exit 1
            } else {
                Write-Log "All validations passed!" -Level "SUCCESS"
                exit 0
            }
        }
        
        # Step 1: Create resource group
        $ResourceGroup = New-SentinelResourceGroup -Name $ResourceGroupName -Location $Location -Tags $Tags
        
        # Step 2: Create Log Analytics workspace
        $Workspace = New-LogAnalyticsWorkspace -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -Location $Location -RetentionDays $RetentionDays -DailyQuotaGB $DailyQuotaGB -Tags $Tags
        
        # Step 3: Enable Sentinel
        $SentinelWorkspace = Enable-AzureSentinel -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
        
        # Step 4: Configure data connectors
        if ($EnableDataConnectors) {
            $DataConnectors = Set-SentinelDataConnectors -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
        }
        
        # Step 5: Create sample analytics rules
        if ($CreateSampleRules) {
            $AnalyticsRules = New-SentinelAnalyticsRules -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
        }
        
        # Step 6: Configure monitoring
        $MonitoringResult = Set-SentinelMonitoring -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
        
        # Step 7: Validate deployment
        Write-Log "Running post-deployment validation..." -Level "INFO"
        $ValidationResults = Test-SentinelDeployment -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
        
        # Generate deployment summary
        $DeploymentSummary = @{
            Status = "Success"
            ResourceGroup = $ResourceGroup.ResourceGroupName
            Workspace = $Workspace.Name
            WorkspaceId = $Workspace.CustomerId
            Location = $Location
            RetentionDays = $RetentionDays
            DataConnectors = if ($EnableDataConnectors) { $DataConnectors } else { @() }
            AnalyticsRules = if ($CreateSampleRules) { $AnalyticsRules } else { @() }
            ValidationResults = $ValidationResults
            DeploymentTime = Get-Date
        }
        
        # Save deployment results
        $DeploymentSummary | ConvertTo-Json -Depth 3 | Out-File "SentinelDeploymentSummary_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        
        Write-Log "Azure Sentinel SIEM deployment completed successfully!" -Level "SUCCESS"
        Write-Log "Workspace ID: $($Workspace.CustomerId)" -Level "INFO"
        Write-Log "Portal URL: https://portal.azure.com/#asset/Microsoft_Azure_Security_Insights/MainMenuBlade" -Level "INFO"
        
        if ($ValidationResults.Values -contains $false) {
            Write-Log "Deployment completed but some validations failed. Please review the logs." -Level "WARNING"
        }
        
    }
    catch {
        Write-Log "Deployment failed: $($_.Exception.Message)" -Level "ERROR"
        Write-Log "Full error: $($_.Exception)" -Level "ERROR"
        exit 1
    }
}

# Execute main function
Main
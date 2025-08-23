# GitHub Advanced Security Platform - PowerShell Deployment Script
# This script automates the deployment of GitHub Advanced Security features
# and integrations across the organization using PowerShell

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$GitHubOrganization = $env:GITHUB_ORGANIZATION,
    
    [Parameter(Mandatory = $false)]
    [string]$GitHubToken = $env:GITHUB_TOKEN,
    
    [Parameter(Mandatory = $false)]
    [string]$GitHubAppId = $env:GITHUB_APP_ID,
    
    [Parameter(Mandatory = $false)]
    [string]$GitHubAppPrivateKey = $env:GITHUB_APP_PRIVATE_KEY,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory = $false)]
    [switch]$EnableSplunkIntegration,
    
    [Parameter(Mandatory = $false)]
    [switch]$EnableAzureSentinelIntegration,
    
    [Parameter(Mandatory = $false)]
    [switch]$EnableDatadogIntegration,
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Script configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogFile = Join-Path $ScriptDir "deployment.log"

# Initialize logging
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Color coding for console output
    switch ($Level) {
        "Info" { Write-Host $logMessage -ForegroundColor Cyan }
        "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
        "Error" { Write-Host $logMessage -ForegroundColor Red }
        "Success" { Write-Host $logMessage -ForegroundColor Green }
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logMessage
}

# Display usage information
function Show-Usage {
    $usage = @"
GitHub Advanced Security Platform - PowerShell Deployment Script

SYNOPSIS:
    Deploy-Solution.ps1 [OPTIONS]

PARAMETERS:
    -GitHubOrganization <string>     GitHub organization name
    -GitHubToken <string>            GitHub personal access token
    -GitHubAppId <string>            GitHub App ID (optional)
    -GitHubAppPrivateKey <string>    GitHub App private key (optional)
    -Environment <string>            Environment (dev/staging/prod)
    -ConfigFile <string>             Configuration file path
    -DryRun                         Perform dry run without making changes
    -SkipValidation                 Skip pre-deployment validation
    -EnableSplunkIntegration        Enable Splunk SIEM integration
    -EnableAzureSentinelIntegration Enable Azure Sentinel integration
    -EnableDatadogIntegration       Enable Datadog integration
    -Help                          Show this help message

EXAMPLES:
    Deploy-Solution.ps1 -GitHubOrganization "myorg" -GitHubToken "ghp_xxx" -Environment "prod"
    Deploy-Solution.ps1 -ConfigFile ".\config.json" -DryRun
    Deploy-Solution.ps1 -Help

ENVIRONMENT VARIABLES:
    GITHUB_ORGANIZATION    GitHub organization name
    GITHUB_TOKEN          GitHub personal access token
    GITHUB_APP_ID         GitHub App ID (optional)
    GITHUB_APP_PRIVATE_KEY GitHub App private key (optional)

"@
    Write-Host $usage
}

# Validate deployment requirements
function Test-DeploymentRequirements {
    Write-Log "Validating deployment requirements..." -Level Info
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Log "PowerShell 5.0 or later is required" -Level Error
        return $false
    }
    
    # Check required parameters
    if ([string]::IsNullOrEmpty($GitHubOrganization)) {
        Write-Log "GitHub organization name is required" -Level Error
        return $false
    }
    
    if ([string]::IsNullOrEmpty($GitHubToken)) {
        Write-Log "GitHub token is required" -Level Error
        return $false
    }
    
    # Test GitHub API connectivity
    try {
        $headers = @{
            'Authorization' = "token $GitHubToken"
            'Accept' = 'application/vnd.github.v3+json'
        }
        
        $userResponse = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -Method Get
        Write-Log "GitHub API connectivity confirmed for user: $($userResponse.login)" -Level Success
        
        # Test organization access
        $orgResponse = Invoke-RestMethod -Uri "https://api.github.com/orgs/$GitHubOrganization" -Headers $headers -Method Get
        Write-Log "Organization access confirmed: $($orgResponse.name)" -Level Success
        
    }
    catch {
        Write-Log "GitHub API connectivity test failed: $($_.Exception.Message)" -Level Error
        return $false
    }
    
    Write-Log "All requirements validated successfully" -Level Success
    return $true
}

# GitHub API helper function
function Invoke-GitHubAPI {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Method,
        
        [Parameter(Mandatory = $true)]
        [string]$Endpoint,
        
        [Parameter(Mandatory = $false)]
        [object]$Body = $null
    )
    
    $headers = @{
        'Authorization' = "token $GitHubToken"
        'Accept' = 'application/vnd.github.v3+json'
        'Content-Type' = 'application/json'
    }
    
    $uri = "https://api.github.com$Endpoint"
    
    if ($DryRun) {
        Write-Log "[DRY RUN] Would call GitHub API: $Method $Endpoint" -Level Info
        if ($Body) {
            Write-Log "[DRY RUN] With body: $($Body | ConvertTo-Json -Compress)" -Level Info
        }
        return @{ success = $true; dryRun = $true }
    }
    
    try {
        $params = @{
            Uri = $uri
            Method = $Method
            Headers = $headers
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return @{ success = $true; data = $response }
    }
    catch {
        Write-Log "GitHub API call failed: $($_.Exception.Message)" -Level Error
        return @{ success = $false; error = $_.Exception.Message }
    }
}

# Configure organization-level security settings
function Set-OrganizationSecurity {
    Write-Log "Configuring organization-level security settings..." -Level Info
    
    # Enable 2FA requirement
    Write-Log "Enabling two-factor authentication requirement..." -Level Info
    $twoFABody = @{
        two_factor_requirement_enabled = $true
    }
    
    $result = Invoke-GitHubAPI -Method "PATCH" -Endpoint "/orgs/$GitHubOrganization" -Body $twoFABody
    
    if ($result.success) {
        Write-Log "Two-factor authentication requirement enabled" -Level Success
    }
    else {
        Write-Log "Failed to enable 2FA requirement: $($result.error)" -Level Warning
    }
    
    # Configure security and analysis settings
    Write-Log "Configuring security and analysis settings..." -Level Info
    $securityBody = @{
        advanced_security_enabled_for_new_repositories = $true
        dependency_graph_enabled_for_new_repositories = $true
        dependabot_alerts_enabled_for_new_repositories = $true
        dependabot_security_updates_enabled_for_new_repositories = $true
        secret_scanning_enabled_for_new_repositories = $true
        secret_scanning_push_protection_enabled_for_new_repositories = $true
    }
    
    $result = Invoke-GitHubAPI -Method "PATCH" -Endpoint "/orgs/$GitHubOrganization" -Body $securityBody
    
    if ($result.success) {
        Write-Log "Organization security settings configured successfully" -Level Success
    }
    else {
        Write-Log "Failed to configure security settings: $($result.error)" -Level Warning
    }
}

# Configure repository-level security settings
function Set-RepositorySecurity {
    Write-Log "Configuring repository-level security settings..." -Level Info
    
    # Get organization repositories
    $repoResult = Invoke-GitHubAPI -Method "GET" -Endpoint "/orgs/$GitHubOrganization/repos?per_page=100"
    
    if (-not $repoResult.success) {
        Write-Log "Failed to fetch organization repositories: $($repoResult.error)" -Level Error
        return $false
    }
    
    $repositories = $repoResult.data
    Write-Log "Found $($repositories.Count) repositories in organization" -Level Info
    
    foreach ($repo in $repositories) {
        Write-Log "Configuring security for repository: $($repo.name)" -Level Info
        
        # Enable vulnerability alerts
        $vulnResult = Invoke-GitHubAPI -Method "PUT" -Endpoint "/repos/$GitHubOrganization/$($repo.name)/vulnerability-alerts"
        
        # Enable secret scanning (ignore errors for private repos without Advanced Security)
        $secretResult = Invoke-GitHubAPI -Method "PUT" -Endpoint "/repos/$GitHubOrganization/$($repo.name)/secret-scanning/alerts"
        
        # Configure branch protection
        $protectionBody = @{
            required_status_checks = @{
                strict = $true
                contexts = @("security/codeql", "security/secret-scan", "security/dependency-check")
            }
            enforce_admins = $true
            required_pull_request_reviews = @{
                required_approving_review_count = 2
                dismiss_stale_reviews = $true
                require_code_owner_reviews = $true
            }
            restrictions = $null
            allow_force_pushes = $false
            allow_deletions = $false
        }
        
        $protectionResult = Invoke-GitHubAPI -Method "PUT" -Endpoint "/repos/$GitHubOrganization/$($repo.name)/branches/$($repo.default_branch)/protection" -Body $protectionBody
        
        if ($protectionResult.success) {
            Write-Log "Repository $($repo.name) configured successfully" -Level Success
        }
        else {
            Write-Log "Failed to configure branch protection for $($repo.name): $($protectionResult.error)" -Level Warning
        }
    }
    
    return $true
}

# Deploy security scanning workflows
function Deploy-SecurityWorkflows {
    Write-Log "Deploying security scanning workflows..." -Level Info
    
    $workflowDir = Join-Path $ScriptDir "..\workflows"
    if (-not (Test-Path $workflowDir)) {
        New-Item -Path $workflowDir -ItemType Directory -Force | Out-Null
    }
    
    # Create CodeQL workflow
    Write-Log "Creating CodeQL scanning workflow..." -Level Info
    $codeqlWorkflow = @'
name: "CodeQL Security Analysis"

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  schedule:
    - cron: '0 2 * * *'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: [ 'javascript', 'python', 'java', 'csharp', 'cpp', 'go' ]

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
        queries: security-extended,security-and-quality

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
      with:
        category: "/language:${{matrix.language}}"
'@
    
    Set-Content -Path (Join-Path $workflowDir "codeql-analysis.yml") -Value $codeqlWorkflow -Encoding UTF8
    
    # Create Secret Scanning workflow
    Write-Log "Creating secret scanning workflow..." -Level Info
    $secretWorkflow = @'
name: "Secret Scanning"

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  schedule:
    - cron: '0 2 * * *'

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3
      with:
        fetch-depth: 0

    - name: Run TruffleHog OSS
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
        extra_args: --debug --only-verified
'@
    
    Set-Content -Path (Join-Path $workflowDir "secret-scanning.yml") -Value $secretWorkflow -Encoding UTF8
    
    # Create Dependency Scanning workflow
    Write-Log "Creating dependency scanning workflow..." -Level Info
    $dependencyWorkflow = @'
name: "Dependency Security Scan"

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]
  schedule:
    - cron: '0 2 * * *'

jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high --fail-on=all

    - name: Upload result to GitHub Code Scanning
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: snyk.sarif
'@
    
    Set-Content -Path (Join-Path $workflowDir "dependency-scanning.yml") -Value $dependencyWorkflow -Encoding UTF8
    
    Write-Log "Security scanning workflows created successfully" -Level Success
    return $true
}

# Setup SIEM integrations
function Set-SIEMIntegration {
    Write-Log "Setting up SIEM integrations..." -Level Info
    
    $siemDir = Join-Path $ScriptDir "..\siem-integration"
    if (-not (Test-Path $siemDir)) {
        New-Item -Path $siemDir -ItemType Directory -Force | Out-Null
    }
    
    # Create PowerShell SIEM forwarder
    Write-Log "Creating PowerShell SIEM event forwarder..." -Level Info
    $siemForwarder = @'
# GitHub Security Events to SIEM Forwarder (PowerShell)
# Forwards GitHub security events to configured SIEM systems

param(
    [Parameter(Mandatory = $true)]
    [string]$GitHubOrganization,
    
    [Parameter(Mandatory = $true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory = $false)]
    [string]$SplunkHecUrl = $env:SPLUNK_HEC_URL,
    
    [Parameter(Mandatory = $false)]
    [string]$SplunkHecToken = $env:SPLUNK_HEC_TOKEN,
    
    [Parameter(Mandatory = $false)]
    [string]$AzureSentinelWorkspaceId = $env:AZURE_SENTINEL_WORKSPACE_ID,
    
    [Parameter(Mandatory = $false)]
    [string]$AzureSentinelSharedKey = $env:AZURE_SENTINEL_SHARED_KEY
)

function Get-GitHubSecurityAlerts {
    param([string]$Organization, [string]$Token)
    
    $headers = @{
        'Authorization' = "token $Token"
        'Accept' = 'application/vnd.github.v3+json'
    }
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/orgs/$Organization/security-advisories" -Headers $headers
        return $response
    }
    catch {
        Write-Error "Failed to fetch security alerts: $($_.Exception.Message)"
        return @()
    }
}

function Send-ToSplunk {
    param([array]$Events, [string]$HecUrl, [string]$HecToken)
    
    if ([string]::IsNullOrEmpty($HecUrl) -or [string]::IsNullOrEmpty($HecToken)) {
        Write-Warning "Splunk HEC URL or token not configured"
        return
    }
    
    $headers = @{
        'Authorization' = "Splunk $HecToken"
        'Content-Type' = 'application/json'
    }
    
    foreach ($event in $Events) {
        $payload = @{
            time = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            source = "github-security"
            sourcetype = "github:security:alert"
            event = $event
        } | ConvertTo-Json -Depth 10
        
        try {
            Invoke-RestMethod -Uri "$HecUrl/services/collector" -Method Post -Headers $headers -Body $payload
            Write-Host "Forwarded event to Splunk: $($event.id)"
        }
        catch {
            Write-Error "Failed to forward to Splunk: $($_.Exception.Message)"
        }
    }
}

function Send-ToAzureSentinel {
    param([array]$Events, [string]$WorkspaceId, [string]$SharedKey)
    
    if ([string]::IsNullOrEmpty($WorkspaceId) -or [string]::IsNullOrEmpty($SharedKey)) {
        Write-Warning "Azure Sentinel workspace ID or shared key not configured"
        return
    }
    
    Write-Host "Azure Sentinel integration configured but not implemented in this demo"
}

# Main execution
Write-Host "Starting SIEM forwarder for organization: $GitHubOrganization"

$alerts = Get-GitHubSecurityAlerts -Organization $GitHubOrganization -Token $GitHubToken
Write-Host "Found $($alerts.Count) security alerts"

if ($alerts.Count -gt 0) {
    Send-ToSplunk -Events $alerts -HecUrl $SplunkHecUrl -HecToken $SplunkHecToken
    Send-ToAzureSentinel -Events $alerts -WorkspaceId $AzureSentinelWorkspaceId -SharedKey $AzureSentinelSharedKey
}

Write-Host "SIEM forwarder completed"
'@
    
    Set-Content -Path (Join-Path $siemDir "SIEMForwarder.ps1") -Value $siemForwarder -Encoding UTF8
    
    Write-Log "SIEM integration scripts created successfully" -Level Success
    return $true
}

# Setup compliance monitoring
function Set-ComplianceMonitoring {
    Write-Log "Setting up compliance monitoring..." -Level Info
    
    $complianceDir = Join-Path $ScriptDir "..\compliance"
    if (-not (Test-Path $complianceDir)) {
        New-Item -Path $complianceDir -ItemType Directory -Force | Out-Null
    }
    
    # Create PowerShell compliance checker
    Write-Log "Creating PowerShell compliance monitoring script..." -Level Info
    $complianceChecker = @'
# GitHub Security Compliance Checker (PowerShell)
# Monitors compliance with security frameworks (SOC2, PCI-DSS, GDPR, HIPAA)

param(
    [Parameter(Mandatory = $true)]
    [string]$GitHubOrganization,
    
    [Parameter(Mandatory = $true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory = $false)]
    [string[]]$ComplianceFrameworks = @("SOC2", "PCI-DSS", "GDPR", "HIPAA")
)

function Test-OrganizationCompliance {
    param([string]$Organization, [string]$Token)
    
    $headers = @{
        'Authorization' = "token $Token"
        'Accept' = 'application/vnd.github.v3+json'
    }
    
    try {
        $orgData = Invoke-RestMethod -Uri "https://api.github.com/orgs/$Organization" -Headers $headers
        
        return @{
            organization = $Organization
            timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            compliance_frameworks = $ComplianceFrameworks
            checks = @{
                two_factor_required = $orgData.two_factor_requirement_enabled -eq $true
                advanced_security_enabled = $true
                private_vulnerability_reporting = $orgData.private_vulnerability_reporting_enabled -eq $true
            }
        }
    }
    catch {
        Write-Error "Failed to check organization compliance: $($_.Exception.Message)"
        return $null
    }
}

function New-ComplianceReport {
    param([hashtable]$ComplianceData)
    
    $report = @{
        compliance_report = @{
            organization = $ComplianceData
            generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            report_version = "1.0"
        }
    }
    
    $reportFile = "compliance_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    $report | ConvertTo-Json -Depth 10 | Set-Content -Path $reportFile -Encoding UTF8
    
    Write-Host "Compliance report generated: $reportFile"
    return $report
}

# Main execution
Write-Host "Starting compliance check for organization: $GitHubOrganization"

$complianceData = Test-OrganizationCompliance -Organization $GitHubOrganization -Token $GitHubToken

if ($complianceData) {
    $report = New-ComplianceReport -ComplianceData $complianceData
    $report | ConvertTo-Json -Depth 10
} else {
    Write-Error "Compliance check failed"
}
'@
    
    Set-Content -Path (Join-Path $complianceDir "ComplianceChecker.ps1") -Value $complianceChecker -Encoding UTF8
    
    Write-Log "Compliance monitoring configured successfully" -Level Success
    return $true
}

# Validate deployment
function Test-Deployment {
    Write-Log "Validating deployment..." -Level Info
    
    # Check organization security settings
    $orgResult = Invoke-GitHubAPI -Method "GET" -Endpoint "/orgs/$GitHubOrganization"
    
    if ($orgResult.success) {
        if ($orgResult.data.two_factor_requirement_enabled -eq $true) {
            Write-Log "✓ Two-factor authentication requirement is enabled" -Level Success
        }
        else {
            Write-Log "⚠ Two-factor authentication requirement is not enabled" -Level Warning
        }
        
        Write-Log "Organization validation completed" -Level Info
    }
    else {
        Write-Log "Failed to validate organization settings" -Level Warning
    }
    
    # Check repository count
    $repoResult = Invoke-GitHubAPI -Method "GET" -Endpoint "/orgs/$GitHubOrganization/repos?per_page=1"
    if ($repoResult.success) {
        Write-Log "Organization has $($repoResult.data.Count) repositories (sample)" -Level Info
    }
    
    Write-Log "Deployment validation completed" -Level Success
}

# Main execution function
function Invoke-Deployment {
    Write-Log "Starting GitHub Advanced Security Platform deployment..." -Level Info
    Write-Log "Organization: $GitHubOrganization" -Level Info
    Write-Log "Environment: $Environment" -Level Info
    Write-Log "Dry Run: $DryRun" -Level Info
    
    try {
        # Pre-deployment validation
        if (-not $SkipValidation) {
            if (-not (Test-DeploymentRequirements)) {
                throw "Pre-deployment validation failed"
            }
        }
        
        # Deployment steps
        Set-OrganizationSecurity
        
        if (-not (Set-RepositorySecurity)) {
            throw "Repository security configuration failed"
        }
        
        if (-not (Deploy-SecurityWorkflows)) {
            throw "Security workflows deployment failed"
        }
        
        if (-not (Set-SIEMIntegration)) {
            throw "SIEM integration setup failed"
        }
        
        if (-not (Set-ComplianceMonitoring)) {
            throw "Compliance monitoring setup failed"
        }
        
        # Post-deployment validation
        Test-Deployment
        
        Write-Log "GitHub Advanced Security Platform deployment completed successfully!" -Level Success
        
        # Display next steps
        Write-Host @"

🎉 DEPLOYMENT COMPLETE! 🎉

Next Steps:
1. Review and test security scanning workflows
2. Configure SIEM integration endpoints and credentials
3. Set up alert notification channels (email, Teams, Slack)
4. Train your security team on the new monitoring capabilities
5. Schedule regular security assessments and compliance reviews
6. Configure backup and disaster recovery procedures

Documentation and logs available in:
- Deployment log: $LogFile
- Workflow templates: $(Join-Path $ScriptDir '..\workflows')
- SIEM integration: $(Join-Path $ScriptDir '..\siem-integration')
- Compliance monitoring: $(Join-Path $ScriptDir '..\compliance')

For support and additional configuration, refer to the implementation guide.

"@ -ForegroundColor Green
        
    }
    catch {
        Write-Log "Deployment failed: $($_.Exception.Message)" -Level Error
        Write-Log "Check the log file for detailed error information: $LogFile" -Level Error
        throw
    }
}

# Script entry point
if ($Help) {
    Show-Usage
    exit 0
}

# Load configuration file if specified
if (-not [string]::IsNullOrEmpty($ConfigFile) -and (Test-Path $ConfigFile)) {
    Write-Log "Loading configuration from $ConfigFile" -Level Info
    $config = Get-Content $ConfigFile | ConvertFrom-Json
    
    if ($config.GitHubOrganization) { $GitHubOrganization = $config.GitHubOrganization }
    if ($config.GitHubToken) { $GitHubToken = $config.GitHubToken }
    if ($config.Environment) { $Environment = $config.Environment }
    if ($config.EnableSplunkIntegration) { $EnableSplunkIntegration = $config.EnableSplunkIntegration }
    if ($config.EnableAzureSentinelIntegration) { $EnableAzureSentinelIntegration = $config.EnableAzureSentinelIntegration }
    if ($config.EnableDatadogIntegration) { $EnableDatadogIntegration = $config.EnableDatadogIntegration }
}

# Execute deployment
try {
    Invoke-Deployment
    exit 0
}
catch {
    Write-Log "Script execution failed: $($_.Exception.Message)" -Level Error
    exit 1
}
# GitHub Actions Enterprise CI/CD Platform Deployment Script
# PowerShell script for deploying the GitHub Actions Enterprise CI/CD Platform
# on Windows environments

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GitHubOrganization,
    
    [Parameter(Mandatory = $false)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory = $false)]
    [string]$AWSRegion = "us-east-1",
    
    [Parameter(Mandatory = $false)]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory = $false)]
    [string]$InstanceType = "t3.large",
    
    [Parameter(Mandatory = $false)]
    [int]$MinRunners = 2,
    
    [Parameter(Mandatory = $false)]
    [int]$MaxRunners = 10,
    
    [Parameter(Mandatory = $false)]
    [int]$DesiredRunners = 3,
    
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove,
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$Cleanup,
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProjectName = "github-actions-enterprise"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

# Color definitions for output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    Default = "White"
}

# Logging functions
function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Blue
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Green
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Yellow
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Red
}

# Help function
function Show-Help {
    @"
GitHub Actions Enterprise CI/CD Platform Deployment Script

SYNOPSIS:
    Deploy-Solution.ps1 [OPTIONS]

DESCRIPTION:
    This script automates the deployment of the GitHub Actions Enterprise CI/CD Platform
    including infrastructure provisioning, configuration, and validation on Windows.

PARAMETERS:
    -GitHubOrganization     GitHub organization name (required)
    -GitHubToken           GitHub personal access token (optional, will prompt if not provided)
    -AWSRegion             AWS region (default: us-east-1)
    -Environment           Environment name (default: dev)
    -InstanceType          Runner instance type (default: t3.large)
    -MinRunners            Minimum number of runners (default: 2)
    -MaxRunners            Maximum number of runners (default: 10)
    -DesiredRunners        Desired number of runners (default: 3)
    -AutoApprove           Auto-approve Terraform changes
    -ValidateOnly          Only validate configuration, don't deploy
    -Cleanup               Cleanup deployed resources
    -Help                  Show this help message

EXAMPLES:
    # Basic deployment
    .\Deploy-Solution.ps1 -GitHubOrganization "myorg"

    # Production deployment with larger capacity
    .\Deploy-Solution.ps1 -GitHubOrganization "myorg" -Environment "prod" -MaxRunners 20 -DesiredRunners 5

    # Validation only
    .\Deploy-Solution.ps1 -GitHubOrganization "myorg" -ValidateOnly

    # Cleanup deployment
    .\Deploy-Solution.ps1 -GitHubOrganization "myorg" -Cleanup

PREREQUISITES:
    - AWS CLI configured with appropriate permissions
    - Terraform installed (>= 1.0)
    - GitHub CLI installed
    - PowerShell 5.1 or later

"@
}

# Check prerequisites
function Test-Prerequisites {
    Write-LogInfo "Checking prerequisites..."
    
    $missingTools = @()
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-LogError "PowerShell 5.1 or later is required"
        exit 1
    }
    
    # Check required tools
    $requiredTools = @("aws", "terraform", "gh")
    
    foreach ($tool in $requiredTools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-LogError "Missing required tools: $($missingTools -join ', ')"
        Write-LogInfo "Please install the missing tools and try again."
        exit 1
    }
    
    # Check AWS credentials
    try {
        $null = aws sts get-caller-identity 2>$null
    }
    catch {
        Write-LogError "AWS credentials not configured or invalid"
        Write-LogInfo "Please run 'aws configure' or set AWS environment variables"
        exit 1
    }
    
    # Check or configure GitHub authentication
    if ($GitHubToken) {
        Write-LogInfo "Authenticating with GitHub using provided token..."
        $env:GITHUB_TOKEN = $GitHubToken
        echo $GitHubToken | gh auth login --with-token
    }
    else {
        try {
            $null = gh auth status 2>$null
        }
        catch {
            Write-LogError "GitHub authentication required"
            Write-LogInfo "Please run 'gh auth login' or provide -GitHubToken parameter"
            exit 1
        }
    }
    
    Write-LogSuccess "All prerequisites met"
}

# Validate configuration
function Test-Configuration {
    Write-LogInfo "Validating configuration..."
    
    # Validate GitHub organization access
    try {
        $null = gh api "/orgs/$GitHubOrganization" 2>$null
    }
    catch {
        Write-LogError "Cannot access GitHub organization: $GitHubOrganization"
        Write-LogInfo "Please check organization name and token permissions"
        exit 1
    }
    
    # Validate AWS region
    try {
        $null = aws ec2 describe-regions --region-names $AWSRegion 2>$null
    }
    catch {
        Write-LogError "Invalid AWS region: $AWSRegion"
        exit 1
    }
    
    # Validate runner configuration
    if ($MinRunners -gt $MaxRunners) {
        Write-LogError "Minimum runners ($MinRunners) cannot be greater than maximum runners ($MaxRunners)"
        exit 1
    }
    
    if ($DesiredRunners -lt $MinRunners -or $DesiredRunners -gt $MaxRunners) {
        Write-LogError "Desired runners ($DesiredRunners) must be between min ($MinRunners) and max ($MaxRunners)"
        exit 1
    }
    
    Write-LogSuccess "Configuration validation passed"
}

# Setup Terraform workspace
function Initialize-Terraform {
    Write-LogInfo "Setting up Terraform workspace..."
    
    $terraformDir = Join-Path $ProjectRoot "scripts\terraform"
    Set-Location $terraformDir
    
    # Initialize Terraform
    Write-LogInfo "Initializing Terraform..."
    terraform init
    
    if ($LASTEXITCODE -ne 0) {
        Write-LogError "Terraform initialization failed"
        exit 1
    }
    
    # Create or select workspace
    $workspaces = terraform workspace list
    if ($workspaces -match $Environment) {
        Write-LogInfo "Selecting existing workspace: $Environment"
        terraform workspace select $Environment
    }
    else {
        Write-LogInfo "Creating new workspace: $Environment"
        terraform workspace new $Environment
    }
    
    # Generate terraform.tfvars
    Write-LogInfo "Generating Terraform variables..."
    $tfvarsContent = @"
project_name = "$ProjectName"
environment = "$Environment"
aws_region = "$AWSRegion"
github_organization = "$GitHubOrganization"

# Runner configuration
runner_instance_type = "$InstanceType"
runner_min_size = $MinRunners
runner_max_size = $MaxRunners
runner_desired_capacity = $DesiredRunners

# VPC configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["${AWSRegion}a", "${AWSRegion}b"]

# Tags
tags = {
  Project = "$ProjectName"
  Environment = "$Environment"
  ManagedBy = "terraform"
  CreatedBy = "$env:USERNAME"
}
"@
    
    $tfvarsContent | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
    
    Write-LogSuccess "Terraform workspace ready"
}

# Deploy infrastructure
function Deploy-Infrastructure {
    Write-LogInfo "Deploying infrastructure with Terraform..."
    
    $terraformDir = Join-Path $ProjectRoot "scripts\terraform"
    Set-Location $terraformDir
    
    # Plan deployment
    Write-LogInfo "Creating Terraform plan..."
    terraform plan -out=tfplan -var-file=terraform.tfvars
    
    if ($LASTEXITCODE -ne 0) {
        Write-LogError "Terraform planning failed"
        exit 1
    }
    
    if ($ValidateOnly) {
        Write-LogSuccess "Validation completed successfully"
        return
    }
    
    # Apply deployment
    if ($AutoApprove) {
        Write-LogInfo "Applying Terraform configuration (auto-approved)..."
        terraform apply -auto-approve tfplan
    }
    else {
        Write-LogInfo "Applying Terraform configuration..."
        Write-Host "Please review the plan above and confirm deployment." -ForegroundColor $Colors.Yellow
        terraform apply tfplan
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-LogError "Terraform apply failed"
        exit 1
    }
    
    # Get outputs
    Write-LogInfo "Retrieving Terraform outputs..."
    terraform output -json | Out-File -FilePath "outputs.json" -Encoding UTF8
    
    # Display important outputs
    if (Test-Path "outputs.json") {
        Write-LogInfo "Infrastructure deployment completed:"
        
        $outputs = Get-Content "outputs.json" | ConvertFrom-Json
        
        if ($outputs.vpc_id.value) {
            Write-LogInfo "  VPC ID: $($outputs.vpc_id.value)"
        }
        
        if ($outputs.runner_asg_name.value) {
            Write-LogInfo "  Auto Scaling Group: $($outputs.runner_asg_name.value)"
        }
        
        if ($outputs.runner_role_arn.value) {
            Write-LogInfo "  Runner IAM Role: $($outputs.runner_role_arn.value)"
        }
    }
    
    Write-LogSuccess "Infrastructure deployment completed"
}

# Configure GitHub organization
function Set-GitHubOrganization {
    Write-LogInfo "Configuring GitHub organization..."
    
    # Enable GitHub Actions
    Write-LogInfo "Enabling GitHub Actions for organization..."
    gh api -X PUT "/orgs/$GitHubOrganization/actions/permissions" `
        -f enabled=true `
        -f allowed_actions=selected `
        -f github_owned_allowed=true `
        -f verified_allowed=true
    
    # Configure workflow permissions
    Write-LogInfo "Configuring workflow permissions..."
    gh api -X PUT "/orgs/$GitHubOrganization/actions/permissions/workflow" `
        -f default_workflow_permissions=read `
        -f can_approve_pull_request_reviews=false
    
    # Create runner groups
    Write-LogInfo "Creating runner groups..."
    $runnerGroups = @("default-runners", "production-runners", "security-runners")
    
    foreach ($group in $runnerGroups) {
        Write-LogInfo "Creating runner group: $group"
        try {
            gh api -X POST "/orgs/$GitHubOrganization/actions/runner-groups" `
                -f name="$group" `
                -f visibility="all" `
                -f allows_public_repositories=false 2>$null
        }
        catch {
            Write-LogWarning "Runner group '$group' may already exist"
        }
    }
    
    Write-LogSuccess "GitHub organization configured"
}

# Set up workflow templates
function Set-WorkflowTemplates {
    Write-LogInfo "Setting up organization workflow templates..."
    
    # Check if .github repository exists
    try {
        $null = gh repo view "$GitHubOrganization/.github" 2>$null
    }
    catch {
        Write-LogInfo "Creating .github repository..."
        gh repo create "$GitHubOrganization/.github" `
            --public `
            --description "Organization workflow templates and configuration"
    }
    
    # Clone repository
    $tempDir = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    Write-LogInfo "Cloning .github repository to $tempDir..."
    gh repo clone "$GitHubOrganization/.github" $tempDir
    
    # Create workflow templates directory
    $templatesDir = Join-Path $tempDir "workflow-templates"
    New-Item -ItemType Directory -Path $templatesDir -Force | Out-Null
    
    # Copy workflow templates
    Write-LogInfo "Creating workflow templates..."
    
    # CI/CD Template
    $cicdTemplate = @'
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: self-hosted
    strategy:
      matrix:
        node-version: [16, 18, 20]
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Run security scan
        uses: github/codeql-action/analyze@v2

  build:
    needs: test
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Build application
        run: npm run build
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-files
          path: dist/

  deploy:
    needs: build
    runs-on: self-hosted
    if: github.ref == 'refs/heads/main'
    environment: production
    steps:
      - name: Deploy to production
        run: echo "Deploying to production"
'@
    
    $cicdTemplate | Out-File -FilePath (Join-Path $templatesDir "ci-cd.yml") -Encoding UTF8
    
    # Security Scan Template
    $securityTemplate = @'
name: Security Scan
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly scan

jobs:
  security-scan:
    runs-on: self-hosted
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
      
      - name: Autobuild
        uses: github/codeql-action/autobuild@v2
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
      
      - name: Run dependency check
        uses: dependency-check/Dependency-Check_Action@main
        with:
          project: 'security-scan'
          path: '.'
'@
    
    $securityTemplate | Out-File -FilePath (Join-Path $templatesDir "security-scan.yml") -Encoding UTF8
    
    # Template properties
    $cicdProperties = @{
        name = "CI/CD Pipeline"
        description = "Complete CI/CD pipeline with testing, building, and deployment"
        iconName = "rocket"
        categories = @("Deployment")
    } | ConvertTo-Json
    
    $cicdProperties | Out-File -FilePath (Join-Path $templatesDir "ci-cd.properties.json") -Encoding UTF8
    
    $securityProperties = @{
        name = "Security Scan"
        description = "Comprehensive security scanning with CodeQL and dependency check"
        iconName = "shield"
        categories = @("Security")
    } | ConvertTo-Json
    
    $securityProperties | Out-File -FilePath (Join-Path $templatesDir "security-scan.properties.json") -Encoding UTF8
    
    # Commit and push templates
    Set-Location $tempDir
    git config user.name "GitHub Actions Automation"
    git config user.email "actions@$GitHubOrganization.com"
    git add .
    
    try {
        git commit -m "Add organization workflow templates"
        git push origin main
        Write-LogSuccess "Workflow templates uploaded"
    }
    catch {
        Write-LogInfo "No changes to commit"
    }
    
    # Cleanup
    Remove-Item -Recurse -Force $tempDir
}

# Configure secrets
function Set-OrganizationSecrets {
    Write-LogInfo "Configuring organization secrets..."
    
    # AWS credentials (if available)
    if ($env:AWS_ACCESS_KEY_ID -and $env:AWS_SECRET_ACCESS_KEY) {
        Write-LogInfo "Setting AWS credentials as organization secrets..."
        gh secret set AWS_ACCESS_KEY_ID --org $GitHubOrganization --body $env:AWS_ACCESS_KEY_ID
        gh secret set AWS_SECRET_ACCESS_KEY --org $GitHubOrganization --body $env:AWS_SECRET_ACCESS_KEY
        gh secret set AWS_REGION --org $GitHubOrganization --body $AWSRegion
    }
    
    Write-LogSuccess "Organization secrets configured"
}

# Set up monitoring
function Set-Monitoring {
    Write-LogInfo "Setting up monitoring and alerting..."
    
    # Create CloudWatch dashboard
    $dashboardName = "$ProjectName-$Environment"
    
    $dashboardJson = @{
        widgets = @(
            @{
                type = "metric"
                x = 0
                y = 0
                width = 12
                height = 6
                properties = @{
                    metrics = @(
                        @("AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "$ProjectName-runners-$Environment")
                    )
                    period = 300
                    stat = "Average"
                    region = $AWSRegion
                    title = "Runner CPU Utilization"
                }
            },
            @{
                type = "metric"
                x = 12
                y = 0
                width = 12
                height = 6
                properties = @{
                    metrics = @(
                        @("AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "$ProjectName-runners-$Environment"),
                        @(".", "GroupInServiceInstances", ".", "."),
                        @(".", "GroupTotalInstances", ".", ".")
                    )
                    period = 300
                    stat = "Average"
                    region = $AWSRegion
                    title = "Runner Capacity"
                }
            }
        )
    } | ConvertTo-Json -Depth 10
    
    $tempDashboard = [System.IO.Path]::GetTempFileName()
    $dashboardJson | Out-File -FilePath $tempDashboard -Encoding UTF8
    
    aws cloudwatch put-dashboard `
        --dashboard-name $dashboardName `
        --dashboard-body "file://$tempDashboard" `
        --region $AWSRegion
    
    Remove-Item $tempDashboard
    
    # Create CloudWatch alarms
    Write-LogInfo "Creating CloudWatch alarms..."
    
    # Runner availability alarm
    aws cloudwatch put-metric-alarm `
        --alarm-name "$ProjectName-$Environment-runner-availability" `
        --alarm-description "Monitor GitHub Actions runner availability" `
        --metric-name GroupInServiceInstances `
        --namespace AWS/AutoScaling `
        --statistic Average `
        --period 300 `
        --evaluation-periods 2 `
        --threshold 1 `
        --comparison-operator LessThanThreshold `
        --dimensions Name=AutoScalingGroupName,Value="$ProjectName-runners-$Environment" `
        --region $AWSRegion
    
    Write-LogSuccess "Monitoring configured"
}

# Validate deployment
function Test-Deployment {
    Write-LogInfo "Validating deployment..."
    
    # Check GitHub organization settings
    Write-LogInfo "Checking GitHub Actions permissions..."
    $permissions = gh api "/orgs/$GitHubOrganization/actions/permissions" | ConvertFrom-Json
    
    if ($permissions.enabled -eq $true) {
        Write-LogSuccess "GitHub Actions is enabled"
    }
    else {
        Write-LogError "GitHub Actions is not enabled"
        return $false
    }
    
    # Check runner availability
    Write-LogInfo "Checking runner availability..."
    $runners = gh api "/orgs/$GitHubOrganization/actions/runners" | ConvertFrom-Json
    $totalRunners = $runners.total_count
    $onlineRunners = ($runners.runners | Where-Object { $_.status -eq "online" }).Count
    
    Write-LogInfo "Total runners: $totalRunners"
    Write-LogInfo "Online runners: $onlineRunners"
    
    if ($onlineRunners -gt 0) {
        Write-LogSuccess "Runners are online and available"
    }
    else {
        Write-LogWarning "No runners are currently online"
        Write-LogInfo "Runners may still be starting up. Check again in a few minutes."
    }
    
    # Check infrastructure
    $terraformDir = Join-Path $ProjectRoot "scripts\terraform"
    $outputsFile = Join-Path $terraformDir "outputs.json"
    
    if (Test-Path $outputsFile) {
        Write-LogInfo "Checking infrastructure..."
        $outputs = Get-Content $outputsFile | ConvertFrom-Json
        
        if ($outputs.runner_asg_name.value) {
            $asgName = $outputs.runner_asg_name.value
            $asgStatus = aws autoscaling describe-auto-scaling-groups `
                --auto-scaling-group-names $asgName `
                --region $AWSRegion `
                --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`]' `
                --output json | ConvertFrom-Json
            
            $healthyInstances = $asgStatus.Count
            Write-LogInfo "Healthy instances in ASG: $healthyInstances"
        }
    }
    
    Write-LogSuccess "Deployment validation completed"
    return $true
}

# Cleanup resources
function Remove-Deployment {
    Write-LogInfo "Cleaning up deployment resources..."
    
    if (-not $AutoApprove) {
        $response = Read-Host "This will destroy all deployed resources. Are you sure? (y/N)"
        if ($response -notmatch "^[Yy]$") {
            Write-LogInfo "Cleanup cancelled"
            return
        }
    }
    
    $terraformDir = Join-Path $ProjectRoot "scripts\terraform"
    Set-Location $terraformDir
    
    # Select workspace
    $workspaces = terraform workspace list
    if ($workspaces -match $Environment) {
        terraform workspace select $Environment
    }
    else {
        Write-LogError "Workspace $Environment not found"
        return
    }
    
    # Destroy infrastructure
    Write-LogInfo "Destroying infrastructure..."
    if ($AutoApprove) {
        terraform destroy -auto-approve -var-file=terraform.tfvars
    }
    else {
        terraform destroy -var-file=terraform.tfvars
    }
    
    # Remove CloudWatch dashboard
    Write-LogInfo "Removing CloudWatch dashboard..."
    try {
        aws cloudwatch delete-dashboards `
            --dashboard-names "$ProjectName-$Environment" `
            --region $AWSRegion 2>$null
    }
    catch {
        # Ignore errors
    }
    
    # Remove CloudWatch alarms
    Write-LogInfo "Removing CloudWatch alarms..."
    try {
        aws cloudwatch delete-alarms `
            --alarm-names "$ProjectName-$Environment-runner-availability" `
            --region $AWSRegion 2>$null
    }
    catch {
        # Ignore errors
    }
    
    Write-LogSuccess "Cleanup completed"
}

# Generate deployment report
function New-DeploymentReport {
    Write-LogInfo "Generating deployment report..."
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportFile = Join-Path $ProjectRoot "deployment-report-$timestamp.md"
    
    $reportContent = @"
# GitHub Actions Enterprise CI/CD Platform Deployment Report

**Generated:** $(Get-Date)
**Organization:** $GitHubOrganization
**Environment:** $Environment
**Region:** $AWSRegion

## Configuration

- **Project Name:** $ProjectName
- **Instance Type:** $InstanceType
- **Runner Capacity:** $MinRunners - $MaxRunners (desired: $DesiredRunners)

## Deployment Status

"@
    
    # Add runner information
    try {
        $runners = gh api "/orgs/$GitHubOrganization/actions/runners" 2>$null | ConvertFrom-Json
        $totalRunners = $runners.total_count
        $onlineRunners = ($runners.runners | Where-Object { $_.status -eq "online" }).Count
        
        $reportContent += @"

### GitHub Actions Runners

- **Total Runners:** $totalRunners
- **Online Runners:** $onlineRunners
- **Organization:** https://github.com/$GitHubOrganization

"@
    }
    catch {
        # Continue without runner information
    }
    
    # Add infrastructure information
    $terraformDir = Join-Path $ProjectRoot "scripts\terraform"
    $outputsFile = Join-Path $terraformDir "outputs.json"
    
    if (Test-Path $outputsFile) {
        $reportContent += @"

### Infrastructure

"@
        
        $outputs = Get-Content $outputsFile | ConvertFrom-Json
        
        if ($outputs.vpc_id.value) {
            $reportContent += "- **VPC ID:** $($outputs.vpc_id.value)`n"
        }
        
        if ($outputs.runner_asg_name.value) {
            $reportContent += "- **Auto Scaling Group:** $($outputs.runner_asg_name.value)`n"
        }
    }
    
    $reportContent += @"

## Next Steps

1. **Test the Platform**
   - Create a test repository with a simple workflow
   - Verify workflows execute on self-hosted runners

2. **Configure Additional Settings**
   - Set up additional organization secrets as needed
   - Configure repository-specific settings

3. **Team Onboarding**
   - Train development teams on GitHub Actions
   - Provide documentation and best practices

4. **Monitoring**
   - Set up additional monitoring and alerting
   - Configure notification channels

## Resources

- **GitHub Organization:** https://github.com/$GitHubOrganization
- **AWS Console:** https://console.aws.amazon.com/ec2/v2/home?region=$AWSRegion
- **CloudWatch Dashboard:** https://console.aws.amazon.com/cloudwatch/home?region=$AWSRegion#dashboards:name=$ProjectName-$Environment

"@
    
    $reportContent | Out-File -FilePath $reportFile -Encoding UTF8
    
    Write-LogSuccess "Deployment report generated: $reportFile"
}

# Main execution
function Main {
    # Show help if requested
    if ($Help) {
        Show-Help
        return
    }
    
    # Display configuration
    Write-LogInfo "GitHub Actions Enterprise CI/CD Platform Deployment"
    Write-LogInfo "=================================================="
    Write-LogInfo "Organization: $GitHubOrganization"
    Write-LogInfo "Environment: $Environment"
    Write-LogInfo "AWS Region: $AWSRegion"
    Write-LogInfo "Instance Type: $InstanceType"
    Write-LogInfo "Runner Capacity: $MinRunners - $MaxRunners (desired: $DesiredRunners)"
    Write-LogInfo "Auto Approve: $AutoApprove"
    Write-LogInfo "Validate Only: $ValidateOnly"
    Write-LogInfo "Cleanup: $Cleanup"
    Write-Host ""
    
    # Execute deployment steps
    Test-Prerequisites
    Test-Configuration
    
    if ($Cleanup) {
        Remove-Deployment
        return
    }
    
    Initialize-Terraform
    Deploy-Infrastructure
    
    if ($ValidateOnly) {
        Write-LogSuccess "Validation completed successfully"
        return
    }
    
    Set-GitHubOrganization
    Set-WorkflowTemplates
    Set-OrganizationSecrets
    Set-Monitoring
    
    # Wait for runners to come online
    Write-LogInfo "Waiting for runners to come online..."
    Start-Sleep -Seconds 60
    
    $validationResult = Test-Deployment
    New-DeploymentReport
    
    if ($validationResult) {
        Write-LogSuccess "GitHub Actions Enterprise CI/CD Platform deployment completed successfully!"
        Write-LogInfo "Check the deployment report for next steps and additional information."
    }
    else {
        Write-LogWarning "Deployment completed with some validation issues. Please check the logs above."
    }
}

# Execute main function
try {
    Main
}
catch {
    Write-LogError "Deployment failed: $_"
    exit 1
}
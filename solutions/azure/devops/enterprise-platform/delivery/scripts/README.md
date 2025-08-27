# Azure DevOps Enterprise Platform - Automation Scripts

This directory contains automation scripts and utilities for deploying, configuring, and managing the Azure DevOps enterprise platform.

## Overview

The automation scripts are organized by function and provide comprehensive tooling for:
- Platform deployment and configuration
- User and permission management
- Pipeline templates and management
- Monitoring and maintenance
- Backup and recovery operations
- Security and compliance automation

## Directory Structure

```
scripts/
├── deployment/
│   ├── deploy-organization.ps1      # Deploy and configure Azure DevOps organization
│   ├── setup-projects.ps1           # Create and configure projects
│   ├── configure-security.ps1       # Set up security groups and permissions
│   └── install-extensions.ps1       # Install required extensions
├── management/
│   ├── user-management.ps1          # Bulk user operations
│   ├── project-management.ps1       # Project maintenance tasks
│   ├── pipeline-management.ps1      # Pipeline operations and templates
│   └── repository-management.ps1    # Repository maintenance
├── monitoring/
│   ├── health-check.ps1             # System health verification
│   ├── performance-monitor.ps1      # Performance metrics collection
│   ├── usage-analytics.ps1          # Usage reporting and analytics
│   └── alert-management.ps1         # Alert configuration and testing
├── maintenance/
│   ├── backup-repositories.ps1      # Repository backup automation
│   ├── cleanup-old-data.ps1         # Data retention and cleanup
│   ├── update-agents.ps1            # Agent pool maintenance
│   └── security-rotation.ps1        # Secret and certificate rotation
├── utilities/
│   ├── config-validator.ps1         # Configuration validation
│   ├── migration-tools.ps1          # Data migration utilities
│   ├── bulk-operations.ps1          # Bulk administrative operations
│   └── reporting-tools.ps1          # Custom reporting utilities
└── templates/
    ├── pipeline-templates/          # YAML pipeline templates
    ├── work-item-templates/         # Work item templates
    ├── repository-templates/        # Repository structure templates
    └── configuration-templates/     # Configuration file templates
```

## Prerequisites

### Required Tools
- **PowerShell 7.0+** - Main scripting environment
- **Azure CLI 2.50+** - Azure resource management
- **Azure DevOps CLI Extension** - DevOps operations
- **Git 2.30+** - Repository operations
- **Terraform 1.5+** - Infrastructure management (optional)

### Authentication Setup
```powershell
# Install required modules
Install-Module -Name Az -Force -AllowClobber
Install-Module -Name VSTeam -Force

# Configure Azure CLI
az login
az extension add --name azure-devops

# Set up Azure DevOps PAT
$env:AZURE_DEVOPS_EXT_PAT = "your-personal-access-token"

# Configure default organization
az devops configure --defaults organization=https://dev.azure.com/contoso-enterprise-devops
```

### Permissions Required
- **Azure Subscription**: Contributor or Owner
- **Azure DevOps Organization**: Project Collection Administrator
- **Azure Active Directory**: User Administrator (for user management scripts)

## Script Categories

### Deployment Scripts

#### deploy-organization.ps1
Automates the complete setup of an Azure DevOps organization including initial configuration, security policies, and integration setup.

```powershell
# Example usage
.\deploy-organization.ps1 -OrganizationName "contoso-enterprise-devops" -Region "Central US" -ConfigFile "organization-config.json"
```

**Features:**
- Organization creation and configuration
- Initial security policy setup
- Service connection configuration
- Extension installation
- License assignment

#### setup-projects.ps1
Creates and configures multiple projects based on templates and organizational standards.

```powershell
# Example usage
.\setup-projects.ps1 -ProjectsConfigFile "projects.json" -ProcessTemplate "Enterprise Agile"
```

**Features:**
- Bulk project creation
- Repository initialization
- Team configuration
- Area and iteration setup
- Permission inheritance

### Management Scripts

#### user-management.ps1
Comprehensive user lifecycle management including onboarding, role changes, and offboarding.

```powershell
# Example usage
.\user-management.ps1 -Action "BulkAdd" -UserListFile "new-users.csv" -DefaultLicense "Basic"
```

**Features:**
- Bulk user addition and removal
- License management
- Group membership updates
- Access level modifications
- Audit reporting

#### pipeline-management.ps1
Manages pipeline templates, configurations, and bulk operations across multiple projects.

```powershell
# Example usage
.\pipeline-management.ps1 -Action "DeployTemplate" -Template "enterprise-ci-template.yml" -Projects "Project1,Project2"
```

**Features:**
- Pipeline template deployment
- Bulk pipeline updates
- Variable group management
- Service connection validation
- Pipeline health checks

### Monitoring Scripts

#### health-check.ps1
Performs comprehensive health checks across the Azure DevOps platform and generates detailed reports.

```powershell
# Example usage
.\health-check.ps1 -ReportFormat "JSON" -OutputPath "health-report.json" -CheckLevel "Detailed"
```

**Features:**
- Service availability checks
- Performance metrics collection
- Security policy validation
- Integration testing
- Compliance verification

#### performance-monitor.ps1
Collects and analyzes performance metrics for optimization and capacity planning.

```powershell
# Example usage
.\performance-monitor.ps1 -MetricsInterval "15min" -RetentionDays 30 -ExportFormat "CSV"
```

**Features:**
- Pipeline execution metrics
- Agent utilization tracking
- Repository size monitoring
- API response time analysis
- Trend analysis and reporting

### Maintenance Scripts

#### backup-repositories.ps1
Automated backup solution for repositories, configurations, and metadata.

```powershell
# Example usage
.\backup-repositories.ps1 -BackupPath "\\backup-server\devops" -IncludeMetadata -CompressionLevel "Optimal"
```

**Features:**
- Complete repository backup
- Metadata preservation
- Incremental backup support
- Compression and encryption
- Restore verification

#### cleanup-old-data.ps1
Manages data retention policies and cleans up old artifacts, builds, and logs.

```powershell
# Example usage
.\cleanup-old-data.ps1 -RetentionDays 90 -ArtifactSizeLimit "10GB" -DryRun
```

**Features:**
- Build artifact cleanup
- Log file management
- Work item attachment cleanup
- Test result pruning
- Storage optimization

## Configuration Files

### Global Configuration
```json
{
  "organization": {
    "name": "contoso-enterprise-devops",
    "region": "Central US",
    "billing": {
      "subscription_id": "12345678-1234-1234-1234-123456789012",
      "resource_group": "rg-devops-billing"
    }
  },
  "security": {
    "require_2fa": true,
    "allow_public_projects": false,
    "disable_anonymous_access": true,
    "audit_retention_days": 365
  },
  "policies": {
    "branch_protection": {
      "require_pr": true,
      "min_reviewers": 2,
      "dismiss_stale_reviews": true
    },
    "build_policies": {
      "require_successful_build": true,
      "timeout_minutes": 60
    }
  }
}
```

### Project Template Configuration
```json
{
  "projects": [
    {
      "name": "Enterprise-Platform",
      "description": "Main enterprise platform project",
      "template": "enterprise-template",
      "repositories": [
        {
          "name": "frontend-application",
          "template": "react-typescript"
        },
        {
          "name": "backend-services",
          "template": "dotnet-webapi"
        },
        {
          "name": "infrastructure",
          "template": "terraform"
        }
      ],
      "teams": [
        {
          "name": "Development Team",
          "members": ["dev-team@contoso.com"],
          "permissions": "Contributor"
        },
        {
          "name": "Architecture Team",
          "members": ["architects@contoso.com"],
          "permissions": "Project Administrator"
        }
      ]
    }
  ]
}
```

## Pipeline Templates

### Enterprise CI Template
```yaml
# templates/pipeline-templates/enterprise-ci-template.yml
parameters:
  - name: solution
    type: string
  - name: buildConfiguration
    type: string
    default: 'Release'
  - name: runSonarAnalysis
    type: boolean
    default: true
  - name: publishArtifacts
    type: boolean
    default: true

stages:
- stage: Build
  displayName: 'Build Stage'
  jobs:
  - job: Build
    displayName: 'Build Job'
    pool:
      vmImage: 'ubuntu-latest'
    
    steps:
    - checkout: self
      clean: true
      
    - task: UseDotNet@2
      displayName: 'Use .NET Core SDK'
      inputs:
        version: '6.0.x'
        
    - task: NuGetAuthenticate@1
      displayName: 'NuGet Authenticate'
      
    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '${{ parameters.solution }}'
        feedsToUse: 'select'
        vstsFeed: 'Enterprise-Packages'
        
    - ${{ if eq(parameters.runSonarAnalysis, true) }}:
      - task: SonarCloudPrepare@1
        displayName: 'Prepare SonarCloud analysis'
        inputs:
          SonarCloud: 'SonarCloud-Connection'
          organization: 'contoso-enterprise'
          scannerMode: 'MSBuild'
          
    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '${{ parameters.solution }}'
        arguments: '--configuration ${{ parameters.buildConfiguration }} --no-restore'
        
    - task: DotNetCoreCLI@2
      displayName: 'Run unit tests'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration ${{ parameters.buildConfiguration }} --no-build --collect "Code coverage" --logger trx'
        publishTestResults: true
        
    - ${{ if eq(parameters.runSonarAnalysis, true) }}:
      - task: SonarCloudAnalyze@1
        displayName: 'Run SonarCloud analysis'
        
      - task: SonarCloudPublish@1
        displayName: 'Publish SonarCloud results'
        
    - ${{ if eq(parameters.publishArtifacts, true) }}:
      - task: DotNetCoreCLI@2
        displayName: 'Publish application'
        inputs:
          command: 'publish'
          publishWebProjects: true
          arguments: '--configuration ${{ parameters.buildConfiguration }} --output $(Build.ArtifactStagingDirectory)'
          zipAfterPublish: true
          
      - task: PublishPipelineArtifact@1
        displayName: 'Publish artifacts'
        inputs:
          targetPath: '$(Build.ArtifactStagingDirectory)'
          artifactName: 'drop'
```

### Infrastructure Deployment Template
```yaml
# templates/pipeline-templates/infrastructure-deployment-template.yml
parameters:
  - name: environment
    type: string
  - name: azureSubscription
    type: string
  - name: terraformVersion
    type: string
    default: '1.5.7'

stages:
- stage: Infrastructure_${{ parameters.environment }}
  displayName: 'Infrastructure - ${{ parameters.environment }}'
  
  jobs:
  - job: Terraform
    displayName: 'Terraform Deployment'
    pool:
      vmImage: 'ubuntu-latest'
      
    steps:
    - checkout: self
    
    - task: TerraformInstaller@0
      displayName: 'Install Terraform'
      inputs:
        terraformVersion: '${{ parameters.terraformVersion }}'
        
    - task: TerraformTaskV3@3
      displayName: 'Terraform Init'
      inputs:
        provider: 'azurerm'
        command: 'init'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure'
        backendServiceArm: '${{ parameters.azureSubscription }}'
        backendAzureRmResourceGroupName: 'rg-terraform-state'
        backendAzureRmStorageAccountName: 'terraformstatesa'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: '${{ parameters.environment }}.tfstate'
        
    - task: TerraformTaskV3@3
      displayName: 'Terraform Plan'
      inputs:
        provider: 'azurerm'
        command: 'plan'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure'
        environmentServiceNameAzureRM: '${{ parameters.azureSubscription }}'
        commandOptions: '-var="environment=${{ parameters.environment }}" -out=tfplan'
        
    - task: TerraformTaskV3@3
      displayName: 'Terraform Apply'
      inputs:
        provider: 'azurerm'
        command: 'apply'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure'
        environmentServiceNameAzureRM: '${{ parameters.azureSubscription }}'
        commandOptions: 'tfplan'
```

## Usage Examples

### Deploying a New Organization
```powershell
# Set configuration
$config = @{
    OrganizationName = "contoso-enterprise-devops"
    Region = "Central US"
    ConfigFile = "organization-config.json"
    AdminUsers = @("admin1@contoso.com", "admin2@contoso.com")
}

# Deploy organization
.\deployment\deploy-organization.ps1 @config

# Set up initial projects
.\deployment\setup-projects.ps1 -ProjectsConfigFile "initial-projects.json"

# Configure security
.\deployment\configure-security.ps1 -SecurityConfigFile "security-policies.json"
```

### Daily Operations
```powershell
# Morning health check
.\monitoring\health-check.ps1 -ReportFormat "Email" -Recipients "ops-team@contoso.com"

# Monitor performance
.\monitoring\performance-monitor.ps1 -RealTime

# Check for maintenance needs
.\maintenance\cleanup-old-data.ps1 -DryRun -ReportOnly
```

### Monthly Maintenance
```powershell
# Backup repositories
.\maintenance\backup-repositories.ps1 -FullBackup

# Update agents
.\maintenance\update-agents.ps1 -Schedule "MaintenanceWindow"

# Generate usage reports
.\utilities\reporting-tools.ps1 -ReportType "Usage" -Period "Monthly"

# Rotate secrets
.\maintenance\security-rotation.ps1 -DryRun
```

## Security Considerations

### Script Execution Policy
- All scripts should be signed with valid certificates
- Execution policy should be set to RemoteSigned or Restricted
- Use PowerShell Constrained Language Mode for production

### Credential Management
```powershell
# Use Azure Key Vault for sensitive information
$keyVault = "kv-devops-automation"
$pat = Get-AzKeyVaultSecret -VaultName $keyVault -Name "DevOps-PAT" -AsPlainText
$env:AZURE_DEVOPS_EXT_PAT = $pat
```

### Audit Logging
All scripts include comprehensive audit logging:
```powershell
# Logging configuration
$logPath = "C:\Logs\DevOpsAutomation"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Start-Transcript -Path "$logPath\script-execution-$timestamp.log"
```

## Error Handling and Recovery

### Retry Logic
```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 5
    )
    
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            return & $ScriptBlock
        }
        catch {
            if ($attempt -eq $MaxAttempts) {
                throw
            }
            Write-Warning "Attempt $attempt failed: $($_.Exception.Message)"
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}
```

### Recovery Procedures
Each script includes specific recovery procedures for common failure scenarios and rollback capabilities where appropriate.

## Contributing

### Script Development Guidelines
1. Follow PowerShell best practices and style guides
2. Include comprehensive error handling
3. Implement proper logging and audit trails
4. Add parameter validation and help documentation
5. Include unit tests where applicable

### Testing Requirements
- Test scripts in development environment first
- Validate against multiple project configurations
- Include both positive and negative test cases
- Document test results and edge cases

### Code Review Process
All scripts must undergo code review before deployment to production environments.

---

*This automation script collection provides comprehensive tooling for Azure DevOps enterprise platform management. Regular updates ensure scripts remain compatible with platform changes and organizational needs.*
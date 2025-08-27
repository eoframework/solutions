# Azure DevOps Configuration Templates

This document provides comprehensive configuration templates for Azure DevOps enterprise platform implementations, covering organizations, projects, repositories, pipelines, and security configurations.

## Table of Contents

- [Organization Configuration](#organization-configuration)
- [Project Templates](#project-templates)
- [Repository Configuration](#repository-configuration)
- [Pipeline Templates](#pipeline-templates)
- [Security & Permissions](#security--permissions)
- [Service Connections](#service-connections)
- [Variable Groups](#variable-groups)
- [Environments](#environments)

## Organization Configuration

### Organization Settings Template

```yaml
# organization-settings.yml
organization:
  name: "contoso-enterprise-devops"
  region: "Central US"
  
  policies:
    # Security policies
    require_2fa: true
    allow_public_projects: false
    disable_anonymous_access: true
    
    # Pipeline policies
    enforce_pipeline_approval: true
    limit_variables_in_pipeline: true
    
    # Repository policies
    enforce_branch_policies: true
    require_pull_request_reviews: 2
    
  extensions:
    required:
      - "SonarCloud"
      - "WhiteSource Bolt"
      - "Azure Artifacts"
      - "Test Plans"
    
  billing:
    license_model: "Basic + Test Plans"
    parallel_jobs: 10
    self_hosted_agents: 20
```

### Process Template Configuration

```yaml
# agile-process-template.yml
process_template:
  name: "Enterprise Agile"
  base: "Agile"
  
  work_item_types:
    epic:
      fields:
        - business_value: required
        - acceptance_criteria: required
    
    feature:
      fields:
        - feature_owner: required
        - acceptance_criteria: required
    
    user_story:
      fields:
        - acceptance_criteria: required
        - definition_of_done: required
    
    bug:
      fields:
        - severity: required
        - reproduction_steps: required
  
  workflows:
    epic: ["New", "Active", "Resolved", "Closed"]
    feature: ["New", "Active", "Resolved", "Closed"]
    user_story: ["New", "Active", "Resolved", "Closed"]
    bug: ["New", "Active", "Resolved", "Closed"]
```

## Project Templates

### Standard Enterprise Project

```yaml
# enterprise-project-template.yml
project:
  name: "{PROJECT_NAME}"
  description: "Enterprise application development project"
  visibility: "private"
  version_control: "Git"
  work_item_process: "Enterprise Agile"
  
  areas:
    - "Frontend"
    - "Backend" 
    - "Infrastructure"
    - "Testing"
    - "Security"
  
  iterations:
    - "Sprint 1"
    - "Sprint 2" 
    - "Sprint 3"
    - "Sprint 4"
    
  repositories:
    - name: "{PROJECT_NAME}-frontend"
      template: "frontend-template"
    - name: "{PROJECT_NAME}-backend"
      template: "backend-template"
    - name: "{PROJECT_NAME}-infrastructure"
      template: "infrastructure-template"
  
  teams:
    - name: "Development Team"
      members: ["dev-team@contoso.com"]
      permissions: "Contributor"
    - name: "Architecture Team"
      members: ["architects@contoso.com"] 
      permissions: "Project Administrator"
    - name: "QA Team"
      members: ["qa-team@contoso.com"]
      permissions: "Contributor"
```

### Microservices Project Template

```yaml
# microservices-project-template.yml
project:
  name: "{PROJECT_NAME}-microservices"
  description: "Microservices architecture project"
  
  repositories:
    - name: "api-gateway"
      template: "dotnet-core-api"
    - name: "user-service"
      template: "dotnet-core-api"
    - name: "order-service"
      template: "dotnet-core-api"
    - name: "payment-service"
      template: "dotnet-core-api"
    - name: "notification-service"
      template: "dotnet-core-api"
    - name: "infrastructure"
      template: "terraform-template"
    - name: "shared-libraries"
      template: "dotnet-library"
  
  pipelines:
    - name: "CI/CD-Gateway"
      repository: "api-gateway"
      template: "microservice-cicd.yml"
    - name: "Infrastructure-Deploy"
      repository: "infrastructure" 
      template: "infrastructure-deploy.yml"
```

## Repository Configuration

### Branch Policies Template

```json
{
  "branchPolicies": {
    "main": {
      "minimumApproverCount": 2,
      "resetOnSourcePush": true,
      "requireCommenterResolution": true,
      "blockLastPusherVote": true,
      "requiredReviewerPolicies": [
        {
          "displayName": "Security Team Review",
          "requiredReviewers": ["security-team@contoso.com"],
          "pathFilters": ["*/security/*", "*/auth/*"]
        }
      ],
      "buildValidationPolicies": [
        {
          "displayName": "CI Build",
          "buildDefinitionId": "{BUILD_ID}",
          "queueOnSourceUpdateOnly": false,
          "validDuration": 12
        }
      ],
      "statusCheckPolicies": [
        {
          "name": "Security Scan",
          "genre": "security",
          "applicability": "conditional"
        }
      ]
    },
    "develop": {
      "minimumApproverCount": 1,
      "resetOnSourcePush": true,
      "requireCommenterResolution": false
    }
  }
}
```

### Repository Structure Template

```
# Standard Repository Structure
repository-root/
├── .azuredevops/
│   ├── pull_request_template.md
│   └── pipelines/
│       ├── ci.yml
│       ├── cd.yml
│       └── templates/
├── src/
│   ├── {APP_NAME}/
│   ├── {APP_NAME}.Tests/
│   └── {APP_NAME}.IntegrationTests/
├── infrastructure/
│   ├── terraform/
│   ├── arm-templates/
│   └── scripts/
├── docs/
│   ├── architecture.md
│   ├── api-documentation.md
│   └── deployment-guide.md
├── .gitignore
├── README.md
├── Dockerfile
└── docker-compose.yml
```

## Pipeline Templates

### CI Pipeline Template

```yaml
# templates/ci-template.yml
parameters:
  - name: solution
    type: string
  - name: buildConfiguration
    type: string
    default: 'Release'
  - name: runTests
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
        
    - task: DotNetCoreCLI@2
      displayName: 'Restore packages'
      inputs:
        command: 'restore'
        projects: '${{ parameters.solution }}'
        
    - task: DotNetCoreCLI@2
      displayName: 'Build solution'
      inputs:
        command: 'build'
        projects: '${{ parameters.solution }}'
        arguments: '--configuration ${{ parameters.buildConfiguration }} --no-restore'
        
    - ${{ if eq(parameters.runTests, true) }}:
      - task: DotNetCoreCLI@2
        displayName: 'Run unit tests'
        inputs:
          command: 'test'
          projects: '**/*Tests.csproj'
          arguments: '--configuration ${{ parameters.buildConfiguration }} --no-build --collect "Code coverage"'
          
    - task: SonarCloudAnalyze@1
      displayName: 'Run SonarCloud analysis'
      
    - ${{ if eq(parameters.publishArtifacts, true) }}:
      - task: DotNetCoreCLI@2
        displayName: 'Publish application'
        inputs:
          command: 'publish'
          publishWebProjects: true
          arguments: '--configuration ${{ parameters.buildConfiguration }} --output $(Build.ArtifactStagingDirectory)'
          
      - task: PublishPipelineArtifact@1
        displayName: 'Publish artifacts'
        inputs:
          targetPath: '$(Build.ArtifactStagingDirectory)'
          artifactName: 'drop'
```

### CD Pipeline Template

```yaml
# templates/cd-template.yml
parameters:
  - name: environment
    type: string
  - name: azureSubscription
    type: string
  - name: resourceGroupName
    type: string
  - name: appServiceName
    type: string

stages:
- stage: Deploy_${{ parameters.environment }}
  displayName: 'Deploy to ${{ parameters.environment }}'
  condition: succeeded()
  
  jobs:
  - deployment: Deploy
    displayName: 'Deploy to ${{ parameters.environment }}'
    environment: '${{ parameters.environment }}'
    pool:
      vmImage: 'ubuntu-latest'
      
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: drop
            
          - task: AzureRmWebAppDeployment@4
            displayName: 'Deploy to App Service'
            inputs:
              ConnectionType: 'AzureRM'
              azureSubscription: '${{ parameters.azureSubscription }}'
              appType: 'webApp'
              WebAppName: '${{ parameters.appServiceName }}'
              packageForLinux: '$(Pipeline.Workspace)/drop/**/*.zip'
              
          - task: AzureAppServiceManage@0
            displayName: 'Restart App Service'
            inputs:
              azureSubscription: '${{ parameters.azureSubscription }}'
              Action: 'Restart Azure App Service'
              WebAppName: '${{ parameters.appServiceName }}'
```

### Infrastructure Pipeline Template

```yaml
# templates/infrastructure-template.yml
parameters:
  - name: environment
    type: string
  - name: azureSubscription
    type: string
  - name: terraformVersion
    type: string
    default: 'latest'

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
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure/terraform'
        backendServiceArm: '${{ parameters.azureSubscription }}'
        backendAzureRmResourceGroupName: 'terraform-state-rg'
        backendAzureRmStorageAccountName: 'terraformstatesa'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: '${{ parameters.environment }}.tfstate'
        
    - task: TerraformTaskV3@3
      displayName: 'Terraform Plan'
      inputs:
        provider: 'azurerm'
        command: 'plan'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure/terraform'
        environmentServiceNameAzureRM: '${{ parameters.azureSubscription }}'
        commandOptions: '-var="environment=${{ parameters.environment }}" -out=tfplan'
        
    - task: TerraformTaskV3@3
      displayName: 'Terraform Apply'
      inputs:
        provider: 'azurerm'
        command: 'apply'
        workingDirectory: '$(System.DefaultWorkingDirectory)/infrastructure/terraform'
        environmentServiceNameAzureRM: '${{ parameters.azureSubscription }}'
        commandOptions: 'tfplan'
```

## Security & Permissions

### Security Groups Template

```yaml
# security-groups.yml
security_groups:
  project_administrators:
    name: "Project Administrators"
    permissions:
      - "Administer build permissions"
      - "Administer release permissions"
      - "Edit project-level information"
      - "Manage project properties"
    members:
      - "project-leads@contoso.com"
      - "architects@contoso.com"
  
  developers:
    name: "Developers"
    permissions:
      - "Contribute"
      - "Create branch"
      - "Contribute to pull requests"
      - "Queue builds"
    members:
      - "dev-team@contoso.com"
  
  qa_engineers:
    name: "QA Engineers"
    permissions:
      - "View project-level information"
      - "View builds"
      - "View releases"
      - "Manage test plans"
    members:
      - "qa-team@contoso.com"
  
  security_team:
    name: "Security Team"
    permissions:
      - "View project-level information"
      - "View builds"
      - "View releases"
      - "Administer build permissions"
    members:
      - "security@contoso.com"
```

### Pipeline Permissions Template

```json
{
  "pipelinePermissions": {
    "build": {
      "administrators": ["Project Administrators", "Build Administrators"],
      "editors": ["Developers", "Build Editors"],
      "viewers": ["Everyone"],
      "queuers": ["Developers", "Build Administrators"]
    },
    "release": {
      "administrators": ["Project Administrators", "Release Administrators"],
      "editors": ["Developers", "Release Editors"],
      "viewers": ["Everyone", "QA Engineers"],
      "approvers": ["Project Administrators", "Release Approvers"]
    },
    "environments": {
      "development": {
        "administrators": ["Developers", "Project Administrators"],
        "deployers": ["Developers"],
        "viewers": ["Everyone"]
      },
      "staging": {
        "administrators": ["Project Administrators"],
        "deployers": ["Release Administrators"],
        "viewers": ["Everyone"],
        "approvers": ["QA Engineers"]
      },
      "production": {
        "administrators": ["Project Administrators"],
        "deployers": ["Release Administrators"],
        "viewers": ["Everyone"],
        "approvers": ["Project Administrators", "Security Team"]
      }
    }
  }
}
```

## Service Connections

### Azure Service Connection Template

```yaml
# service-connections.yml
service_connections:
  azure_dev:
    name: "Azure-Development"
    type: "AzureRM"
    subscription_id: "{DEV_SUBSCRIPTION_ID}"
    subscription_name: "Development Subscription"
    service_principal:
      tenant_id: "{TENANT_ID}"
      client_id: "{DEV_CLIENT_ID}"
      client_secret: "{DEV_CLIENT_SECRET}"
    permissions:
      - project: "All projects"
        users: ["Developers", "Project Administrators"]
  
  azure_prod:
    name: "Azure-Production"
    type: "AzureRM"
    subscription_id: "{PROD_SUBSCRIPTION_ID}"
    subscription_name: "Production Subscription"
    service_principal:
      tenant_id: "{TENANT_ID}"
      client_id: "{PROD_CLIENT_ID}"
      client_secret: "{PROD_CLIENT_SECRET}"
    permissions:
      - project: "Specific projects only"
        users: ["Project Administrators", "Release Administrators"]
  
  sonarcloud:
    name: "SonarCloud"
    type: "SonarCloud"
    organization: "contoso-org"
    token: "{SONAR_TOKEN}"
```

## Variable Groups

### Environment Variable Groups

```yaml
# variable-groups.yml
variable_groups:
  development_variables:
    name: "Development-Variables"
    description: "Variables for development environment"
    variables:
      Environment: "Development"
      DatabaseConnectionString: 
        value: "{DEV_DB_CONNECTION}"
        secret: true
      ApiBaseUrl: "https://dev-api.contoso.com"
      LogLevel: "Debug"
    permissions:
      - "Developers"
      - "Project Administrators"
  
  staging_variables:
    name: "Staging-Variables"
    description: "Variables for staging environment"
    variables:
      Environment: "Staging"
      DatabaseConnectionString:
        value: "{STAGING_DB_CONNECTION}"
        secret: true
      ApiBaseUrl: "https://staging-api.contoso.com"
      LogLevel: "Information"
    permissions:
      - "QA Engineers"
      - "Project Administrators"
  
  production_variables:
    name: "Production-Variables"
    description: "Variables for production environment"
    variables:
      Environment: "Production"
      DatabaseConnectionString:
        value: "{PROD_DB_CONNECTION}"
        secret: true
      ApiBaseUrl: "https://api.contoso.com"
      LogLevel: "Warning"
    permissions:
      - "Project Administrators"
      - "Release Administrators"
```

## Environments

### Environment Configuration Template

```yaml
# environments.yml
environments:
  development:
    name: "Development"
    description: "Development environment for testing"
    approvals: []
    checks: []
    resources:
      - type: "kubernetes"
        namespace: "development"
      - type: "virtualMachine"
        tags: "env:dev"
  
  staging:
    name: "Staging"
    description: "Staging environment for pre-production testing"
    approvals:
      - type: "manual"
        approvers: ["qa-team@contoso.com"]
        minRequiredApprovers: 1
        instructions: "Please verify all tests pass before approving"
    checks:
      - type: "businessHours"
        settings:
          timeZone: "UTC"
          startTime: "09:00"
          endTime: "17:00"
    resources:
      - type: "kubernetes"
        namespace: "staging"
  
  production:
    name: "Production"
    description: "Production environment"
    approvals:
      - type: "manual"
        approvers: ["project-leads@contoso.com", "security@contoso.com"]
        minRequiredApprovers: 2
        instructions: "Requires security team approval for production deployment"
    checks:
      - type: "businessHours"
        settings:
          timeZone: "UTC"
          startTime: "08:00"
          endTime: "18:00"
          daysOfWeek: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
      - type: "evaluateArtifact"
        settings:
          definitionRef: "Security-Scan-Pipeline"
    resources:
      - type: "kubernetes"
        namespace: "production"
      - type: "virtualMachine"
        tags: "env:prod"
```

## Usage Instructions

1. **Organization Setup**: Use the organization configuration template to establish baseline settings and policies
2. **Project Creation**: Select appropriate project template based on application architecture
3. **Repository Configuration**: Apply branch policies and repository structure templates
4. **Pipeline Implementation**: Use CI/CD templates as starting points, customize as needed
5. **Security Configuration**: Implement security groups and permissions templates
6. **Environment Management**: Configure environments with appropriate approvals and checks

## Customization Guidelines

- Replace all `{PLACEHOLDER}` values with actual configuration values
- Modify templates based on specific enterprise requirements
- Ensure all secret values are stored in Azure Key Vault
- Review and adjust permissions based on organizational security policies
- Test configurations in development environments before production deployment

---

*These templates provide a foundation for Azure DevOps enterprise implementations. Customize based on specific organizational requirements and security policies.*
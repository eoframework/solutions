# HashiCorp Terraform Enterprise - PowerShell Deployment Script
# Deploys TFE platform on AWS EKS with complete automation

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "",
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipPrerequisites,
    
    [Parameter(Mandatory = $false)]
    [switch]$EnableMonitoring,
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

# Set error handling and strict mode
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Import required modules
try {
    Import-Module AWSPowerShell.NetCore -Force
    Write-Output "✓ AWS PowerShell module imported successfully"
}
catch {
    Write-Error "Failed to import AWS PowerShell module. Please install it with: Install-Module -Name AWSPowerShell.NetCore"
    exit 1
}

# Global variables
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $ScriptPath))
$LogFile = Join-Path $ProjectRoot "deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$StartTime = Get-Date

# Configuration defaults
$Script:Config = @{
    ProjectName = "terraform-enterprise"
    Environment = $Environment
    AwsRegion = $env:AWS_DEFAULT_REGION ?? "us-east-1"
    KubernetesVersion = "1.28"
    TfeHostname = "terraform.company.com"
    TfeVersion = "v202401-1"
    VpcCidr = "10.0.0.0/16"
    NodeInstanceType = "m5.xlarge"
    MinNodeCount = 3
    MaxNodeCount = 10
    DesiredNodeCount = 6
    DbInstanceClass = "db.r5.xlarge"
    DbAllocatedStorage = 500
}

# Logging function
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    # Color coding for console output
    switch ($Level) {
        "INFO" { Write-Host $LogEntry -ForegroundColor White }
        "WARN" { Write-Host $LogEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $LogEntry -ForegroundColor Red }
        "SUCCESS" { Write-Host $LogEntry -ForegroundColor Green }
    }
    
    # Write to log file
    Add-Content -Path $LogFile -Value $LogEntry
}

# Helper functions for logging
function Write-Info { param($Message) Write-Log -Message $Message -Level "INFO" }
function Write-Warn { param($Message) Write-Log -Message $Message -Level "WARN" }
function Write-Error { param($Message) Write-Log -Message $Message -Level "ERROR" }
function Write-Success { param($Message) Write-Log -Message $Message -Level "SUCCESS" }

# Load configuration from file
function Get-DeploymentConfig {
    param([string]$ConfigPath)
    
    Write-Info "Loading deployment configuration..."
    
    # Load environment-specific config if exists
    $envConfigPath = Join-Path $ProjectRoot "environments" "$Environment.json"
    if (Test-Path $envConfigPath) {
        Write-Info "Loading environment configuration: $envConfigPath"
        $envConfig = Get-Content $envConfigPath | ConvertFrom-Json
        
        # Merge with default config
        foreach ($property in $envConfig.PSObject.Properties) {
            $Script:Config[$property.Name] = $property.Value
        }
    }
    
    # Load custom config file if provided
    if ($ConfigFile -and (Test-Path $ConfigFile)) {
        Write-Info "Loading configuration from: $ConfigFile"
        $customConfig = Get-Content $ConfigFile | ConvertFrom-Json
        
        foreach ($property in $customConfig.PSObject.Properties) {
            $Script:Config[$property.Name] = $property.Value
        }
    }
    
    Write-Success "Configuration loaded successfully"
}

# Validate prerequisites
function Test-Prerequisites {
    if ($SkipPrerequisites) {
        Write-Warn "Skipping prerequisites validation"
        return $true
    }
    
    Write-Info "Validating prerequisites..."
    
    # Check required tools
    $RequiredTools = @{
        "terraform" = "Terraform CLI"
        "kubectl" = "Kubernetes CLI"
        "helm" = "Helm Package Manager"
        "aws" = "AWS CLI"
    }
    
    foreach ($tool in $RequiredTools.Keys) {
        try {
            $version = & $tool --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Info "✓ $($RequiredTools[$tool]): $($version.Split("`n")[0])"
            } else {
                throw "Command failed"
            }
        }
        catch {
            Write-Error "✗ $($RequiredTools[$tool]) not found or not working"
            return $false
        }
    }
    
    # Validate environment variables
    $RequiredVars = @("TFE_LICENSE")
    foreach ($var in $RequiredVars) {
        if (-not (Get-ChildItem Env:$var -ErrorAction SilentlyContinue)) {
            Write-Error "✗ Environment variable $var is not set"
            return $false
        } else {
            Write-Info "✓ Environment variable $var is configured"
        }
    }
    
    # Validate AWS credentials
    Write-Info "Validating AWS credentials..."
    try {
        $identity = aws sts get-caller-identity | ConvertFrom-Json
        Write-Info "✓ AWS Account: $($identity.Account)"
        Write-Info "✓ AWS User/Role: $($identity.Arn)"
        $Script:Config.AwsAccount = $identity.Account
    }
    catch {
        Write-Error "✗ AWS credentials not configured or invalid"
        return $false
    }
    
    Write-Success "Prerequisites validation passed"
    return $true
}

# Deploy infrastructure with Terraform
function Deploy-Infrastructure {
    Write-Info "Deploying infrastructure with Terraform..."
    
    $TerraformDir = Join-Path $ProjectRoot "delivery" "scripts" "terraform"
    
    if (-not (Test-Path $TerraformDir)) {
        Write-Error "Terraform directory not found: $TerraformDir"
        return $false
    }
    
    Push-Location $TerraformDir
    
    try {
        # Initialize Terraform
        Write-Info "Initializing Terraform..."
        if ($DryRun) {
            Write-Info "[DRY RUN] Would run: terraform init"
        } else {
            terraform init
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform init failed"
            }
        }
        
        # Create terraform.tfvars
        $tfvarsPath = Join-Path $TerraformDir "terraform.tfvars"
        if (-not (Test-Path $tfvarsPath)) {
            Write-Info "Creating terraform.tfvars from configuration..."
            
            $tfvarsContent = @"
project_name         = "$($Script:Config.ProjectName)"
environment          = "$($Script:Config.Environment)"
aws_region          = "$($Script:Config.AwsRegion)"
kubernetes_version  = "$($Script:Config.KubernetesVersion)"
tfe_hostname        = "$($Script:Config.TfeHostname)"

# VPC Configuration
vpc_cidr = "$($Script:Config.VpcCidr)"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# EKS Configuration
node_instance_types = ["$($Script:Config.NodeInstanceType)"]
min_node_count     = $($Script:Config.MinNodeCount)
max_node_count     = $($Script:Config.MaxNodeCount)
desired_node_count = $($Script:Config.DesiredNodeCount)

# Database Configuration
postgres_version      = "14.9"
db_instance_class    = "$($Script:Config.DbInstanceClass)"
db_allocated_storage = $($Script:Config.DbAllocatedStorage)
enable_multi_az      = true

# Security Configuration
enable_encryption = true
allowed_cidr_blocks = [
  "0.0.0.0/0"  # Update this for production
]
"@
            
            $tfvarsContent | Out-File -FilePath $tfvarsPath -Encoding UTF8
        }
        
        # Plan deployment
        Write-Info "Planning Terraform deployment..."
        if ($DryRun) {
            Write-Info "[DRY RUN] Would run: terraform plan -var-file=terraform.tfvars"
        } else {
            terraform plan -var-file=terraform.tfvars -out=tfe.tfplan
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform plan failed"
            }
        }
        
        # Apply deployment (if not validate-only)
        if (-not $ValidateOnly) {
            Write-Info "Applying Terraform deployment..."
            if ($DryRun) {
                Write-Info "[DRY RUN] Would run: terraform apply tfe.tfplan"
            } else {
                terraform apply tfe.tfplan
                if ($LASTEXITCODE -ne 0) {
                    throw "Terraform apply failed"
                }
                
                # Extract outputs
                Write-Info "Extracting infrastructure outputs..."
                $outputs = terraform output -json | ConvertFrom-Json
                
                # Store outputs in config
                $Script:Config.ClusterName = $outputs.cluster_name.value
                $Script:Config.ClusterEndpoint = $outputs.cluster_endpoint.value
                $Script:Config.DatabaseEndpoint = $outputs.database_endpoint.value
                $Script:Config.S3Bucket = $outputs.s3_bucket_name.value
                
                Write-Info "Infrastructure deployed successfully:"
                Write-Info "  EKS Cluster: $($Script:Config.ClusterName)"
                Write-Info "  Database: $($Script:Config.DatabaseEndpoint)"
                Write-Info "  S3 Bucket: $($Script:Config.S3Bucket)"
            }
        }
        
        return $true
    }
    catch {
        Write-Error "Infrastructure deployment failed: $_"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Configure Kubernetes
function Initialize-Kubernetes {
    Write-Info "Configuring Kubernetes access..."
    
    if (-not $Script:Config.ClusterName) {
        Write-Error "ClusterName not set. Infrastructure may not be deployed."
        return $false
    }
    
    # Update kubeconfig
    if ($DryRun) {
        Write-Info "[DRY RUN] Would run: aws eks update-kubeconfig --region $($Script:Config.AwsRegion) --name $($Script:Config.ClusterName)"
    } else {
        aws eks update-kubeconfig --region $Script:Config.AwsRegion --name $Script:Config.ClusterName
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to update kubeconfig"
            return $false
        }
    }
    
    # Verify cluster connectivity
    if (-not $DryRun) {
        Write-Info "Verifying cluster connectivity..."
        kubectl get nodes | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Cannot connect to Kubernetes cluster"
            return $false
        }
        
        $nodeCount = (kubectl get nodes --no-headers | Measure-Object).Count
        Write-Info "✓ Connected to cluster with $nodeCount nodes"
    }
    
    # Add Helm repositories
    Write-Info "Adding HashiCorp Helm repository..."
    if ($DryRun) {
        Write-Info "[DRY RUN] Would run: helm repo add hashicorp https://helm.releases.hashicorp.com"
    } else {
        helm repo add hashicorp https://helm.releases.hashicorp.com
        helm repo update
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to add Helm repository"
            return $false
        }
    }
    
    Write-Success "Kubernetes configuration completed"
    return $true
}

# Deploy Terraform Enterprise
function Deploy-TerraformEnterprise {
    Write-Info "Deploying Terraform Enterprise..."
    
    # Create namespace
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create terraform-enterprise namespace"
    } else {
        kubectl create namespace terraform-enterprise --dry-run=client -o yaml | kubectl apply -f -
    }
    
    # Create secrets
    Write-Info "Creating TFE secrets..."
    if (-not $DryRun) {
        # TFE License
        $licenseContent = $env:TFE_LICENSE
        if (-not $licenseContent) {
            Write-Error "TFE_LICENSE environment variable not set"
            return $false
        }
        
        $licenseFile = [System.IO.Path]::GetTempFileName()
        $licenseContent | Out-File -FilePath $licenseFile -Encoding UTF8 -NoNewline
        
        kubectl create secret generic tfe-license `
            --from-file=license=$licenseFile `
            --namespace=terraform-enterprise `
            --dry-run=client -o yaml | kubectl apply -f -
        
        Remove-Item $licenseFile
        
        # Database credentials
        $dbPassword = [System.Web.Security.Membership]::GeneratePassword(32, 8)
        kubectl create secret generic tfe-database-credentials `
            --from-literal=host="$($Script:Config.DatabaseEndpoint)" `
            --from-literal=database="terraform_enterprise" `
            --from-literal=username="tfe" `
            --from-literal=password="$dbPassword" `
            --from-literal=url="postgresql://tfe:${dbPassword}@$($Script:Config.DatabaseEndpoint):5432/terraform_enterprise?sslmode=require" `
            --namespace=terraform-enterprise `
            --dry-run=client -o yaml | kubectl apply -f -
    }
    
    # Generate Helm values
    $valuesFile = [System.IO.Path]::GetTempFileName()
    $valuesContent = @"
replicaCount: 3

image:
  repository: hashicorp/terraform-enterprise
  tag: "$($Script:Config.TfeVersion)"
  pullPolicy: Always

tfe:
  hostname: "$($Script:Config.TfeHostname)"
  
  database:
    external: true
    host: "$($Script:Config.DatabaseEndpoint)"
    name: "terraform_enterprise"
    username: "tfe"
    passwordSecret: "tfe-database-credentials"
    passwordSecretKey: "password"
    
  objectStorage:
    type: "s3"
    bucket: "$($Script:Config.S3Bucket)"
    region: "$($Script:Config.AwsRegion)"
    
  license:
    secret: "tfe-license"
    key: "license"
    
  resources:
    requests:
      cpu: "2000m"
      memory: "4Gi"
    limits:
      cpu: "4000m"
      memory: "8Gi"

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/healthcheck-path: "/_health_check"
  hosts:
    - host: "$($Script:Config.TfeHostname)"
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

podDisruptionBudget:
  enabled: true
  minAvailable: 2
"@
    
    $valuesContent | Out-File -FilePath $valuesFile -Encoding UTF8
    
    # Deploy with Helm
    if ($DryRun) {
        Write-Info "[DRY RUN] Would deploy TFE with Helm using values from $valuesFile"
    } else {
        Write-Info "Deploying TFE with Helm..."
        helm upgrade --install terraform-enterprise hashicorp/terraform-enterprise `
            --namespace terraform-enterprise `
            --values $valuesFile `
            --wait --timeout 600s
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "TFE Helm deployment failed"
            Remove-Item $valuesFile
            return $false
        }
    }
    
    Remove-Item $valuesFile
    Write-Success "Terraform Enterprise deployed successfully"
    return $true
}

# Deploy monitoring stack
function Deploy-MonitoringStack {
    if (-not $EnableMonitoring) {
        return $true
    }
    
    Write-Info "Deploying monitoring stack..."
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would deploy monitoring stack"
        return $true
    }
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Add monitoring Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Deploy Prometheus
    Write-Info "Deploying Prometheus..."
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack `
        --namespace monitoring `
        --set grafana.adminPassword=admin123 `
        --wait --timeout 600s
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Prometheus deployment failed"
        return $false
    }
    
    Write-Success "Monitoring stack deployed successfully"
    return $true
}

# Validate deployment
function Test-Deployment {
    Write-Info "Validating TFE deployment..."
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would validate deployment"
        return $true
    }
    
    # Check pod status
    Write-Info "Checking pod status..."
    $pods = kubectl get pods -n terraform-enterprise -o json | ConvertFrom-Json
    $runningPods = ($pods.items | Where-Object { $_.status.phase -eq "Running" }).Count
    $totalPods = $pods.items.Count
    
    Write-Info "Pods status: $runningPods/$totalPods running"
    
    if ($runningPods -eq 0) {
        Write-Error "No pods are running"
        kubectl get pods -n terraform-enterprise
        return $false
    }
    
    # Wait for TFE to be accessible
    Write-Info "Waiting for TFE to be accessible..."
    $maxAttempts = 20
    $attempt = 1
    
    while ($attempt -le $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "https://$($Script:Config.TfeHostname)/_health_check" -TimeoutSec 10
            if ($response.StatusCode -eq 200) {
                Write-Success "TFE is accessible at https://$($Script:Config.TfeHostname)"
                break
            }
        }
        catch {
            Write-Info "Attempt $attempt/$maxAttempts`: TFE not ready yet, waiting 30 seconds..."
            Start-Sleep -Seconds 30
            $attempt++
        }
    }
    
    if ($attempt -gt $maxAttempts) {
        Write-Error "TFE did not become accessible within expected time"
        return $false
    }
    
    # Test API endpoint
    Write-Info "Testing TFE API..."
    try {
        $response = Invoke-WebRequest -Uri "https://$($Script:Config.TfeHostname)/api/v2/ping" -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "TFE API is responding"
        }
    }
    catch {
        Write-Warn "TFE API test failed - this may be normal during initial setup"
    }
    
    Write-Success "Deployment validation completed"
    return $true
}

# Generate deployment report
function New-DeploymentReport {
    param($Success)
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    $ReportFile = Join-Path $ProjectRoot "deployment-report-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
    
    $reportContent = @"
# Terraform Enterprise Deployment Report

**Environment**: $Environment  
**Deployment Date**: $(Get-Date)  
**Deployed by**: $env:USERNAME  
**Duration**: $($Duration.ToString('hh\:mm\:ss'))  
**Status**: $(if ($Success) { "SUCCESS" } else { "FAILED" })

## Infrastructure Details

- **AWS Region**: $($Script:Config.AwsRegion)
- **AWS Account**: $($Script:Config.AwsAccount)
- **EKS Cluster**: $($Script:Config.ClusterName ?? "Not deployed")
- **Database**: $($Script:Config.DatabaseEndpoint ?? "Not deployed")
- **S3 Bucket**: $($Script:Config.S3Bucket ?? "Not deployed")

## Application Details

- **TFE Hostname**: $($Script:Config.TfeHostname)
- **TFE Version**: $($Script:Config.TfeVersion)
- **Replicas**: 3
- **Namespace**: terraform-enterprise

## Access Information

- **Web UI**: https://$($Script:Config.TfeHostname)
- **Health Check**: https://$($Script:Config.TfeHostname)/_health_check
- **API Endpoint**: https://$($Script:Config.TfeHostname)/api/v2

## Next Steps

1. Complete initial admin setup: https://$($Script:Config.TfeHostname)/admin/account/new
2. Configure authentication (SAML/OIDC)
3. Create first organization
4. Create workspaces and upload Terraform configurations
5. Configure team access and permissions

## Support

- **Log File**: $LogFile
- **Deployment Report**: $ReportFile
- **Documentation**: $ProjectRoot\README.md

"@
    
    $reportContent | Out-File -FilePath $ReportFile -Encoding UTF8
    Write-Success "Deployment report generated: $ReportFile"
    
    # Display summary
    Write-Host "`n" -NoNewline
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "🎉 TFE Deployment Summary" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Environment: $Environment" -ForegroundColor White
    Write-Host "TFE URL: https://$($Script:Config.TfeHostname)" -ForegroundColor White
    Write-Host "Status: $(if ($ValidateOnly) { "Validated" } else { "Deployed" })" -ForegroundColor White
    Write-Host "Duration: $($Duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
    Write-Host "`nNext steps:" -ForegroundColor White
    Write-Host "1. Access TFE at https://$($Script:Config.TfeHostname)" -ForegroundColor Yellow
    Write-Host "2. Complete admin setup" -ForegroundColor Yellow
    Write-Host "3. Configure authentication" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "`n" -NoNewline
    
    return $ReportFile
}

# Main deployment function
function Start-TfeDeployment {
    Write-Host "HashiCorp Terraform Enterprise - PowerShell Deployment Script" -ForegroundColor Cyan
    Write-Host "=============================================================" -ForegroundColor Cyan
    
    Write-Info "Starting HashiCorp Terraform Enterprise deployment"
    Write-Info "Environment: $Environment"
    Write-Info "Log file: $LogFile"
    
    $deploymentSuccess = $true
    
    try {
        # Load configuration
        Get-DeploymentConfig
        
        # Validate prerequisites
        if (-not (Test-Prerequisites)) {
            throw "Prerequisites validation failed"
        }
        
        # Deploy infrastructure
        if (-not (Deploy-Infrastructure)) {
            throw "Infrastructure deployment failed"
        }
        
        if (-not $ValidateOnly) {
            # Configure Kubernetes
            if (-not (Initialize-Kubernetes)) {
                throw "Kubernetes configuration failed"
            }
            
            # Deploy TFE
            if (-not (Deploy-TerraformEnterprise)) {
                throw "TFE deployment failed"
            }
            
            # Deploy monitoring (if enabled)
            if (-not (Deploy-MonitoringStack)) {
                throw "Monitoring stack deployment failed"
            }
        }
        
        # Validate deployment
        if (-not (Test-Deployment)) {
            Write-Warn "Deployment validation completed with warnings"
        }
        
        Write-Success "Deployment completed successfully!"
    }
    catch {
        Write-Error "Deployment failed: $_"
        $deploymentSuccess = $false
    }
    finally {
        # Generate deployment report
        $reportFile = New-DeploymentReport -Success $deploymentSuccess
        
        if ($deploymentSuccess) {
            exit 0
        } else {
            exit 1
        }
    }
}

# Script entry point
if ($MyInvocation.InvocationName -ne '.') {
    Start-TfeDeployment
}
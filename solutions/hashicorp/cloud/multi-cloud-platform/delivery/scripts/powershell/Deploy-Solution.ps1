# HashiCorp Multi-Cloud Platform - PowerShell Deployment Script
# This script deploys the HashiCorp Multi-Cloud Infrastructure Management Platform
# across AWS, Azure, and Google Cloud Platform

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("aws", "azure", "gcp", "all")]
    [string]$CloudProvider,
    
    [Parameter(Mandatory = $false)]
    [string]$Environment = "prod",
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipPrerequisites,
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = "deployment-config.json"
)

# Set error handling and strict mode
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Import required modules
Import-Module Az -Force
Import-Module AWSPowerShell.NetCore -Force

# Global variables
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = "$ScriptPath\deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$StartTime = Get-Date

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

# Configuration validation
function Test-Prerequisites {
    Write-Log "Validating deployment prerequisites..." "INFO"
    
    $Prerequisites = @{
        "terraform" = "Terraform CLI"
        "kubectl" = "Kubernetes CLI"
        "helm" = "Helm Package Manager"
        "aws" = "AWS CLI"
        "az" = "Azure CLI"
        "gcloud" = "Google Cloud CLI"
    }
    
    foreach ($Tool in $Prerequisites.Keys) {
        try {
            $Version = & $Tool --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✓ $($Prerequisites[$Tool]) found: $($Version.Split("`n")[0])" "SUCCESS"
            } else {
                throw "Command failed"
            }
        }
        catch {
            Write-Log "✗ $($Prerequisites[$Tool]) not found or not working" "ERROR"
            return $false
        }
    }
    
    # Validate environment variables
    $RequiredVars = @(
        "TERRAFORM_TOKEN",
        "CONSUL_ENCRYPTION_KEY", 
        "VAULT_ROOT_TOKEN",
        "AWS_ACCESS_KEY_ID",
        "AWS_SECRET_ACCESS_KEY",
        "AZURE_CLIENT_ID",
        "AZURE_CLIENT_SECRET",
        "AZURE_TENANT_ID",
        "GOOGLE_CREDENTIALS"
    )
    
    foreach ($Var in $RequiredVars) {
        if (-not (Get-ChildItem Env:$Var -ErrorAction SilentlyContinue)) {
            Write-Log "✗ Environment variable $Var is not set" "ERROR"
            return $false
        } else {
            Write-Log "✓ Environment variable $Var is configured" "SUCCESS"
        }
    }
    
    Write-Log "All prerequisites validated successfully" "SUCCESS"
    return $true
}

# Load deployment configuration
function Get-DeploymentConfig {
    param([string]$ConfigPath)
    
    if (-not (Test-Path $ConfigPath)) {
        Write-Log "Configuration file not found: $ConfigPath" "ERROR"
        exit 1
    }
    
    try {
        $Config = Get-Content $ConfigPath | ConvertFrom-Json
        Write-Log "Configuration loaded successfully from $ConfigPath" "SUCCESS"
        return $Config
    }
    catch {
        Write-Log "Failed to parse configuration file: $_" "ERROR"
        exit 1
    }
}

# Cloud provider authentication
function Initialize-CloudProviders {
    param($Providers)
    
    Write-Log "Authenticating with cloud providers..." "INFO"
    
    if ($Providers -contains "aws" -or $Providers -contains "all") {
        try {
            $AwsIdentity = aws sts get-caller-identity | ConvertFrom-Json
            Write-Log "✓ AWS authentication successful - Account: $($AwsIdentity.Account)" "SUCCESS"
        }
        catch {
            Write-Log "✗ AWS authentication failed: $_" "ERROR"
            return $false
        }
    }
    
    if ($Providers -contains "azure" -or $Providers -contains "all") {
        try {
            az account show | Out-Null
            $AzureAccount = az account show | ConvertFrom-Json
            Write-Log "✓ Azure authentication successful - Subscription: $($AzureAccount.name)" "SUCCESS"
        }
        catch {
            Write-Log "✗ Azure authentication failed: $_" "ERROR"
            return $false
        }
    }
    
    if ($Providers -contains "gcp" -or $Providers -contains "all") {
        try {
            $GcpProject = gcloud config get-value project 2>$null
            Write-Log "✓ GCP authentication successful - Project: $GcpProject" "SUCCESS"
        }
        catch {
            Write-Log "✗ GCP authentication failed: $_" "ERROR"
            return $false
        }
    }
    
    return $true
}

# Terraform deployment function
function Deploy-TerraformInfrastructure {
    param(
        [string]$Provider,
        [object]$Config
    )
    
    Write-Log "Deploying Terraform infrastructure for $Provider..." "INFO"
    
    $TerraformDir = "$ScriptPath\terraform\$Provider"
    
    if (-not (Test-Path $TerraformDir)) {
        Write-Log "Terraform directory not found: $TerraformDir" "ERROR"
        return $false
    }
    
    Push-Location $TerraformDir
    
    try {
        # Initialize Terraform
        Write-Log "Initializing Terraform for $Provider..." "INFO"
        terraform init -backend-config="token=$env:TERRAFORM_TOKEN"
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform init failed"
        }
        
        # Create terraform.tfvars
        $TfVars = @"
# Generated terraform.tfvars for $Provider
project_name = "$($Config.project_name)"
environment = "$Environment"
region = "$($Config.cloud_providers.$Provider.region)"
availability_zones = $($Config.cloud_providers.$Provider.availability_zones | ConvertTo-Json -Compress)
vpc_cidr = "$($Config.cloud_providers.$Provider.vpc_cidr)"
node_count = $($Config.kubernetes.node_count)
node_instance_type = "$($Config.cloud_providers.$Provider.node_instance_type)"
"@
        
        $TfVars | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
        
        # Plan deployment
        Write-Log "Planning Terraform deployment for $Provider..." "INFO"
        terraform plan -var-file="terraform.tfvars" -out="$Provider.tfplan"
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform plan failed"
        }
        
        if (-not $ValidateOnly) {
            # Apply deployment
            Write-Log "Applying Terraform deployment for $Provider..." "INFO"
            terraform apply "$Provider.tfplan"
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform apply failed"
            }
            
            # Extract outputs
            Write-Log "Extracting Terraform outputs for $Provider..." "INFO"
            $Outputs = terraform output -json | ConvertFrom-Json
            $Outputs | ConvertTo-Json -Depth 10 | Out-File -FilePath "..\outputs\$Provider`_outputs.json" -Encoding UTF8
            
            Write-Log "Infrastructure deployment completed for $Provider" "SUCCESS"
        } else {
            Write-Log "Validation-only mode: Terraform plan completed for $Provider" "SUCCESS"
        }
        
        return $true
    }
    catch {
        Write-Log "Terraform deployment failed for $Provider`: $_" "ERROR"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Kubernetes configuration
function Configure-KubernetesClusters {
    param($Providers, $Config)
    
    Write-Log "Configuring Kubernetes clusters..." "INFO"
    
    foreach ($Provider in $Providers) {
        if ($Provider -eq "all") { continue }
        
        switch ($Provider) {
            "aws" {
                Write-Log "Configuring AWS EKS cluster..." "INFO"
                $ClusterName = "$($Config.project_name)-eks-cluster"
                $Region = $Config.cloud_providers.aws.region
                
                aws eks update-kubeconfig --region $Region --name $ClusterName
                kubectl config rename-context "arn:aws:eks:$($Region):$((aws sts get-caller-identity | ConvertFrom-Json).Account):cluster/$ClusterName" "aws-prod"
            }
            
            "azure" {
                Write-Log "Configuring Azure AKS cluster..." "INFO"
                $ClusterName = "$($Config.project_name)-aks-cluster"
                $ResourceGroup = "$($Config.project_name)-rg"
                
                az aks get-credentials --resource-group $ResourceGroup --name $ClusterName --overwrite-existing
                kubectl config rename-context $ClusterName "azure-prod"
            }
            
            "gcp" {
                Write-Log "Configuring GCP GKE cluster..." "INFO"
                $ClusterName = "$($Config.project_name)-gke-cluster"
                $Region = $Config.cloud_providers.gcp.region
                $Project = gcloud config get-value project
                
                gcloud container clusters get-credentials $ClusterName --region $Region
                kubectl config rename-context "gke_$($Project)_$($Region)_$ClusterName" "gcp-prod"
            }
        }
        
        # Verify cluster connectivity
        Write-Log "Verifying cluster connectivity for $Provider..." "INFO"
        kubectl --context="$Provider-prod" get nodes
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✓ Kubernetes cluster configured successfully for $Provider" "SUCCESS"
        } else {
            Write-Log "✗ Failed to configure Kubernetes cluster for $Provider" "ERROR"
            return $false
        }
    }
    
    return $true
}

# HashiCorp services deployment
function Deploy-HashiCorpServices {
    param($Providers, $Config)
    
    Write-Log "Deploying HashiCorp services..." "INFO"
    
    # Add HashiCorp Helm repository
    helm repo add hashicorp https://helm.releases.hashicorp.com
    helm repo update
    
    foreach ($Provider in $Providers) {
        if ($Provider -eq "all") { continue }
        
        $Context = "$Provider-prod"
        
        # Create namespace
        kubectl --context=$Context create namespace hashicorp-system --dry-run=client -o yaml | kubectl --context=$Context apply -f -
        
        # Deploy Consul
        Write-Log "Deploying Consul Enterprise to $Provider..." "INFO"
        $ConsulValues = @"
global:
  name: consul
  datacenter: $Provider-dc
  image: "hashicorp/consul-enterprise:$($Config.versions.consul)"
  
server:
  replicas: 3
  bootstrapExpect: 3
  enterprise:
    enabled: true
  connect:
    enabled: true
  
ui:
  enabled: true
  service:
    type: LoadBalancer
"@
        
        $ConsulValues | Out-File -FilePath "$env:TEMP\consul-values-$Provider.yaml" -Encoding UTF8
        helm --kube-context=$Context upgrade --install consul hashicorp/consul --namespace hashicorp-system --values "$env:TEMP\consul-values-$Provider.yaml"
        
        # Deploy Vault
        Write-Log "Deploying Vault Enterprise to $Provider..." "INFO"
        $VaultValues = @"
global:
  enabled: true
  
server:
  image:
    repository: hashicorp/vault-enterprise
    tag: "$($Config.versions.vault)"
  
  ha:
    enabled: true
    replicas: 3
    
ui:
  enabled: true
  serviceType: LoadBalancer
"@
        
        $VaultValues | Out-File -FilePath "$env:TEMP\vault-values-$Provider.yaml" -Encoding UTF8
        helm --kube-context=$Context upgrade --install vault hashicorp/vault --namespace hashicorp-system --values "$env:TEMP\vault-values-$Provider.yaml"
        
        # Deploy Terraform Enterprise
        Write-Log "Deploying Terraform Enterprise to $Provider..." "INFO"
        $TfeValues = @"
tfe:
  image:
    tag: "$($Config.versions.terraform_enterprise)"
  
  hostname: "tfe-$Provider.company.com"
  
  resources:
    requests:
      cpu: "2"
      memory: "4Gi"
    limits:
      cpu: "4"
      memory: "8Gi"
      
service:
  type: LoadBalancer
"@
        
        $TfeValues | Out-File -FilePath "$env:TEMP\tfe-values-$Provider.yaml" -Encoding UTF8
        helm --kube-context=$Context upgrade --install terraform-enterprise hashicorp/terraform-enterprise --namespace hashicorp-system --values "$env:TEMP\tfe-values-$Provider.yaml"
        
        Write-Log "HashiCorp services deployed successfully to $Provider" "SUCCESS"
    }
    
    return $true
}

# Post-deployment validation
function Test-Deployment {
    param($Providers)
    
    Write-Log "Performing post-deployment validation..." "INFO"
    
    foreach ($Provider in $Providers) {
        if ($Provider -eq "all") { continue }
        
        $Context = "$Provider-prod"
        
        # Check pod status
        Write-Log "Checking pod status for $Provider..." "INFO"
        $Pods = kubectl --context=$Context get pods -n hashicorp-system -o json | ConvertFrom-Json
        
        $RunningPods = ($Pods.items | Where-Object { $_.status.phase -eq "Running" }).Count
        $TotalPods = $Pods.items.Count
        
        Write-Log "Pod status for $Provider`: $RunningPods/$TotalPods pods running" "INFO"
        
        # Test service endpoints
        Write-Log "Testing service endpoints for $Provider..." "INFO"
        
        try {
            # Test TFE health check
            $TfeUrl = "https://tfe-$Provider.company.com/_health_check"
            $Response = Invoke-WebRequest -Uri $TfeUrl -TimeoutSec 30
            
            if ($Response.StatusCode -eq 200) {
                Write-Log "✓ Terraform Enterprise health check passed for $Provider" "SUCCESS"
            }
        }
        catch {
            Write-Log "✗ Terraform Enterprise health check failed for $Provider`: $_" "WARN"
        }
    }
    
    Write-Log "Deployment validation completed" "SUCCESS"
    return $true
}

# Cleanup function
function Remove-TempFiles {
    Write-Log "Cleaning up temporary files..." "INFO"
    
    Get-ChildItem -Path $env:TEMP -Filter "*-values-*.yaml" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "." -Filter "*.tfplan" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
    
    Write-Log "Temporary files cleaned up" "SUCCESS"
}

# Generate deployment report
function New-DeploymentReport {
    param($Providers, $Config, $Success)
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    $Report = @{
        "deployment_id" = [guid]::NewGuid().ToString()
        "timestamp" = $EndTime.ToString("yyyy-MM-dd HH:mm:ss")
        "duration" = $Duration.ToString()
        "cloud_providers" = $Providers
        "environment" = $Environment
        "success" = $Success
        "components" = @{
            "terraform_enterprise" = @{
                "version" = $Config.versions.terraform_enterprise
                "endpoints" = @()
            }
            "consul" = @{
                "version" = $Config.versions.consul
                "datacenters" = @()
            }
            "vault" = @{
                "version" = $Config.versions.vault
                "clusters" = @()
            }
        }
    }
    
    foreach ($Provider in $Providers) {
        if ($Provider -eq "all") { continue }
        
        $Report.components.terraform_enterprise.endpoints += "https://tfe-$Provider.company.com"
        $Report.components.consul.datacenters += "$Provider-dc"
        $Report.components.vault.clusters += "$Provider-vault"
    }
    
    $ReportPath = "$ScriptPath\deployment-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $Report | ConvertTo-Json -Depth 10 | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-Log "Deployment report generated: $ReportPath" "SUCCESS"
    
    # Display summary
    Write-Host "`n" -NoNewline
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "HashiCorp Multi-Cloud Platform Deployment Summary" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Status: " -NoNewline
    if ($Success) {
        Write-Host "SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "FAILED" -ForegroundColor Red
    }
    Write-Host "Duration: $($Duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
    Write-Host "Cloud Providers: $($Providers -join ', ')" -ForegroundColor White
    Write-Host "Environment: $Environment" -ForegroundColor White
    Write-Host "`nComponents Deployed:" -ForegroundColor White
    foreach ($Provider in $Providers) {
        if ($Provider -eq "all") { continue }
        Write-Host "  $Provider`: https://tfe-$Provider.company.com" -ForegroundColor Yellow
    }
    Write-Host "`nLog File: $LogFile" -ForegroundColor White
    Write-Host "Report File: $ReportPath" -ForegroundColor White
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "`n" -NoNewline
}

# Main deployment function
function Start-Deployment {
    Write-Log "Starting HashiCorp Multi-Cloud Platform deployment..." "INFO"
    Write-Log "Cloud Provider: $CloudProvider" "INFO"
    Write-Log "Environment: $Environment" "INFO"
    Write-Log "Validate Only: $ValidateOnly" "INFO"
    
    try {
        # Load configuration
        $Config = Get-DeploymentConfig $ConfigFile
        
        # Determine providers to deploy
        $Providers = if ($CloudProvider -eq "all") { @("aws", "azure", "gcp") } else { @($CloudProvider) }
        
        # Validate prerequisites
        if (-not $SkipPrerequisites) {
            if (-not (Test-Prerequisites)) {
                throw "Prerequisites validation failed"
            }
        }
        
        # Authenticate with cloud providers
        if (-not (Initialize-CloudProviders $Providers)) {
            throw "Cloud provider authentication failed"
        }
        
        # Deploy infrastructure with Terraform
        foreach ($Provider in $Providers) {
            if (-not (Deploy-TerraformInfrastructure $Provider $Config)) {
                throw "Infrastructure deployment failed for $Provider"
            }
        }
        
        if (-not $ValidateOnly) {
            # Configure Kubernetes clusters
            if (-not (Configure-KubernetesClusters $Providers $Config)) {
                throw "Kubernetes configuration failed"
            }
            
            # Deploy HashiCorp services
            if (-not (Deploy-HashiCorpServices $Providers $Config)) {
                throw "HashiCorp services deployment failed"
            }
            
            # Perform validation
            if (-not (Test-Deployment $Providers)) {
                Write-Log "Post-deployment validation completed with warnings" "WARN"
            }
        }
        
        # Generate deployment report
        New-DeploymentReport $Providers $Config $true
        
        Write-Log "HashiCorp Multi-Cloud Platform deployment completed successfully!" "SUCCESS"
        return $true
        
    }
    catch {
        Write-Log "Deployment failed: $_" "ERROR"
        New-DeploymentReport $Providers $Config $false
        return $false
    }
    finally {
        Remove-TempFiles
    }
}

# Script entry point
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "HashiCorp Multi-Cloud Platform - PowerShell Deployment Script" -ForegroundColor Cyan
    Write-Host "=============================================================" -ForegroundColor Cyan
    
    $Success = Start-Deployment
    
    if ($Success) {
        exit 0
    } else {
        exit 1
    }
}
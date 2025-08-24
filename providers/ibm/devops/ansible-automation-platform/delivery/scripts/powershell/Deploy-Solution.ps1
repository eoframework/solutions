# IBM Ansible Automation Platform - PowerShell Deployment Script
# This script automates the deployment of IBM Ansible Automation Platform on Red Hat OpenShift

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Namespace = "ansible-automation",
    
    [Parameter(Mandatory=$false)]
    [string]$DomainName = "automation.company.com",
    
    [Parameter(Mandatory=$false)]
    [string]$AAPVersion = "2.4",
    
    [Parameter(Mandatory=$false)]
    [switch]$Cleanup,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Global variables
$script:LogFile = "C:\temp\aap-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$script:TempDir = $null

# Ensure log directory exists
if (!(Test-Path "C:\temp")) {
    New-Item -ItemType Directory -Path "C:\temp" -Force | Out-Null
}

# Logging functions
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [ConsoleColor]$Color = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Level - $Message"
    
    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $script:LogFile -Value $logMessage
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log -Message "ERROR: $Message" -Level "ERROR" -Color Red
    throw $Message
}

function Write-Warning-Log {
    param([string]$Message)
    Write-Log -Message "WARNING: $Message" -Level "WARNING" -Color Yellow
}

function Write-Info-Log {
    param([string]$Message)
    Write-Log -Message $Message -Level "INFO" -Color Cyan
}

function Write-Success-Log {
    param([string]$Message)
    Write-Log -Message "SUCCESS: $Message" -Level "SUCCESS" -Color Green
}

# Function to show usage
function Show-Usage {
    Write-Host @"
IBM Ansible Automation Platform - PowerShell Deployment Script

USAGE:
    Deploy-Solution.ps1 [OPTIONS]

OPTIONS:
    -Namespace <string>     OpenShift namespace (default: ansible-automation)
    -DomainName <string>    Base domain name (default: automation.company.com)
    -AAPVersion <string>    AAP version (default: 2.4)
    -Cleanup               Remove existing deployment
    -ValidateOnly          Only validate prerequisites
    -DryRun                Show what would be deployed without making changes
    -Help                  Show this help message

ENVIRONMENT VARIABLES (required):
    AAP_ADMIN_PASSWORD     Admin password for the platform
    OPENSHIFT_TOKEN        OpenShift authentication token
    AAP_LICENSE_MANIFEST   Base64 encoded license manifest zip file

EXAMPLES:
    .\Deploy-Solution.ps1
    .\Deploy-Solution.ps1 -Namespace "my-aap" -DomainName "aap.example.com"
    .\Deploy-Solution.ps1 -Cleanup
    .\Deploy-Solution.ps1 -ValidateOnly

"@ -ForegroundColor Green
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Info-Log "Checking prerequisites..."
    
    # Check required tools
    $requiredTools = @("oc", "ansible-playbook")
    foreach ($tool in $requiredTools) {
        try {
            $null = Get-Command $tool -ErrorAction Stop
            Write-Info-Log "Found required tool: $tool"
        }
        catch {
            Write-Error-Log "$tool is required but not found in PATH"
        }
    }
    
    # Check environment variables
    $requiredEnvVars = @("AAP_ADMIN_PASSWORD", "OPENSHIFT_TOKEN", "AAP_LICENSE_MANIFEST")
    foreach ($envVar in $requiredEnvVars) {
        if (-not [Environment]::GetEnvironmentVariable($envVar)) {
            Write-Error-Log "Environment variable $envVar is required"
        }
    }
    
    # Check OpenShift connectivity
    try {
        $whoami = & oc whoami 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Log "Not logged into OpenShift. Please run 'oc login' first"
        }
        Write-Info-Log "Connected to OpenShift as: $whoami"
    }
    catch {
        Write-Error-Log "Failed to verify OpenShift connectivity: $_"
    }
    
    # Verify cluster permissions
    try {
        $canCreate = & oc auth can-i create namespace 2>&1
        if ($LASTEXITCODE -ne 0 -or $canCreate -ne "yes") {
            Write-Error-Log "Insufficient permissions. Cluster admin access required"
        }
    }
    catch {
        Write-Error-Log "Failed to verify cluster permissions: $_"
    }
    
    Write-Success-Log "All prerequisites validated"
}

# Function to setup environment
function Initialize-Environment {
    Write-Info-Log "Setting up deployment environment..."
    
    # Create temporary directory
    $script:TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "aap-deployment-$(Get-Random)"
    New-Item -ItemType Directory -Path $script:TempDir -Force | Out-Null
    
    # Login to OpenShift with token
    $openshiftToken = [Environment]::GetEnvironmentVariable("OPENSHIFT_TOKEN")
    try {
        & oc login --token="$openshiftToken" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Log "Failed to login to OpenShift with provided token"
        }
    }
    catch {
        Write-Error-Log "Failed to login to OpenShift: $_"
    }
    
    # Display cluster information
    $currentContext = & oc config current-context 2>&1
    $currentUser = & oc whoami 2>&1
    Write-Info-Log "Connected to cluster: $currentContext"
    Write-Info-Log "Current user: $currentUser"
    
    Write-Success-Log "Environment setup complete"
}

# Function to validate resources
function Test-ClusterResources {
    Write-Info-Log "Validating cluster resources..."
    
    # Get cluster resource information
    try {
        $nodes = & oc get nodes --no-headers 2>&1
        $nodeCount = ($nodes | Measure-Object).Count
        Write-Info-Log "Available nodes: $nodeCount"
        
        # Check storage classes
        $storageClasses = & oc get storageclass --no-headers 2>&1
        $storageClassCount = ($storageClasses | Measure-Object).Count
        if ($storageClassCount -eq 0) {
            Write-Error-Log "No storage classes available. Storage classes are required for persistent volumes"
        }
        Write-Info-Log "Available storage classes: $storageClassCount"
        
        # Check if namespace already exists
        $namespaceExists = & oc get namespace $Namespace 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Warning-Log "Namespace $Namespace already exists"
            $response = Read-Host "Continue with existing namespace? (y/N)"
            if ($response -notmatch "^[Yy]$") {
                Write-Error-Log "Deployment cancelled by user"
            }
        }
    }
    catch {
        Write-Error-Log "Failed to validate cluster resources: $_"
    }
    
    Write-Success-Log "Resource validation complete"
}

# Function to install operator
function Install-AAPOperator {
    Write-Info-Log "Installing Ansible Automation Platform Operator..."
    
    try {
        # Create operator namespace
        $operatorNamespace = @"
apiVersion: v1
kind: Namespace
metadata:
  name: ansible-automation-platform-operator
"@
        $operatorNamespace | & oc apply -f - 2>&1 | Out-Null
        
        # Create operator group
        $operatorGroup = @"
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ansible-automation-platform-operator
  namespace: ansible-automation-platform-operator
spec:
  targetNamespaces:
  - ansible-automation-platform-operator
"@
        $operatorGroup | & oc apply -f - 2>&1 | Out-Null
        
        # Create subscription
        $subscription = @"
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ansible-automation-platform-operator
  namespace: ansible-automation-platform-operator
spec:
  channel: stable-2.4-cluster-scoped
  name: ansible-automation-platform-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
"@
        $subscription | & oc apply -f - 2>&1 | Out-Null
        
        # Wait for operator installation
        Write-Info-Log "Waiting for operator installation (this may take a few minutes)..."
        $timeout = 600
        $elapsed = 0
        
        do {
            Start-Sleep -Seconds 10
            $elapsed += 10
            $csv = & oc get csv -n ansible-automation-platform-operator 2>&1 | Select-String "Succeeded"
            Write-Info-Log "Waiting... ($elapsed/$timeout seconds)"
        } while ($csv.Count -eq 0 -and $elapsed -lt $timeout)
        
        if ($elapsed -ge $timeout) {
            Write-Error-Log "Operator installation timed out"
        }
    }
    catch {
        Write-Error-Log "Failed to install operator: $_"
    }
    
    Write-Success-Log "Operator installed successfully"
}

# Function to create namespace and secrets
function New-NamespaceAndSecrets {
    Write-Info-Log "Creating namespace and secrets..."
    
    try {
        # Create namespace
        $namespaceYaml = @"
apiVersion: v1
kind: Namespace
metadata:
  name: $Namespace
"@
        $namespaceYaml | & oc apply -f - 2>&1 | Out-Null
        
        # Create admin password secret
        $adminPassword = [Environment]::GetEnvironmentVariable("AAP_ADMIN_PASSWORD")
        & oc create secret generic automation-controller-admin-password `
            --from-literal=password="$adminPassword" `
            -n $Namespace --dry-run=client -o yaml | & oc apply -f - 2>&1 | Out-Null
        
        # Create license manifest secret
        $licenseManifest = [Environment]::GetEnvironmentVariable("AAP_LICENSE_MANIFEST")
        $manifestPath = Join-Path $script:TempDir "manifest.zip"
        [System.Convert]::FromBase64String($licenseManifest) | Set-Content -Path $manifestPath -Encoding Byte
        
        & oc create secret generic automation-controller-license `
            --from-file=manifest.zip="$manifestPath" `
            -n $Namespace --dry-run=client -o yaml | & oc apply -f - 2>&1 | Out-Null
        
        # Generate and create database password secret
        $dbPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
        & oc create secret generic postgres-admin-password `
            --from-literal=password="$dbPassword" `
            -n $Namespace --dry-run=client -o yaml | & oc apply -f - 2>&1 | Out-Null
    }
    catch {
        Write-Error-Log "Failed to create namespace and secrets: $_"
    }
    
    Write-Success-Log "Namespace and secrets created"
}

# Function to deploy platform components
function Deploy-PlatformComponents {
    Write-Info-Log "Deploying Ansible Automation Platform components..."
    
    try {
        # Find the project root directory (assuming script is in delivery/scripts/powershell)
        $projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $playbookPath = Join-Path $projectRoot "delivery\scripts\ansible\playbook.yml"
        
        if (!(Test-Path $playbookPath)) {
            Write-Error-Log "Ansible playbook not found at: $playbookPath"
        }
        
        # Run the Ansible playbook
        Push-Location $projectRoot
        try {
            & ansible-playbook $playbookPath `
                -e "openshift_namespace=$Namespace" `
                -e "domain_name=$DomainName" `
                -e "aap_version=$AAPVersion" `
                --tags "operator,namespace,secrets,database,controller,hub,eda,monitoring" `
                -v
                
            if ($LASTEXITCODE -ne 0) {
                Write-Error-Log "Ansible playbook execution failed"
            }
        }
        finally {
            Pop-Location
        }
    }
    catch {
        Write-Error-Log "Failed to deploy platform components: $_"
    }
    
    Write-Success-Log "Platform components deployed"
}

# Function to validate deployment
function Test-Deployment {
    Write-Info-Log "Validating deployment..."
    
    try {
        # Check pod status
        $runningPods = & oc get pods -n $Namespace --field-selector=status.phase=Running --no-headers 2>&1
        $podCount = ($runningPods | Measure-Object).Count
        Write-Info-Log "Running pods: $podCount"
        
        # Check routes
        $controllerRoute = & oc get route -n $Namespace -l app.kubernetes.io/name=automation-controller -o jsonpath='{.items[0].spec.host}' 2>&1
        
        if ($controllerRoute -and $LASTEXITCODE -eq 0) {
            Write-Info-Log "Controller URL: https://$controllerRoute"
            
            # Test connectivity
            try {
                $response = Invoke-RestMethod -Uri "https://$controllerRoute/api/v2/ping/" -Method Get -SkipCertificateCheck -TimeoutSec 10
                if ($response.version) {
                    Write-Success-Log "Controller is accessible and responding"
                }
            }
            catch {
                Write-Warning-Log "Controller may not be fully ready yet"
            }
        }
        else {
            Write-Warning-Log "Controller route not found"
        }
    }
    catch {
        Write-Warning-Log "Some validation checks failed: $_"
    }
    
    Write-Success-Log "Deployment validation complete"
}

# Function to display summary
function Show-DeploymentSummary {
    Write-Info-Log "Deployment Summary"
    Write-Host "======================================================" -ForegroundColor Green
    Write-Host "🎉 IBM Ansible Automation Platform Deployment Complete!" -ForegroundColor Green
    Write-Host ""
    
    try {
        # Get routes
        $controllerRoute = & oc get route -n $Namespace -l app.kubernetes.io/name=automation-controller -o jsonpath='{.items[0].spec.host}' 2>&1
        $hubRoute = & oc get route -n $Namespace -l app.kubernetes.io/name=automation-hub -o jsonpath='{.items[0].spec.host}' 2>&1
        $edaRoute = & oc get route -n $Namespace -l app.kubernetes.io/name=eda -o jsonpath='{.items[0].spec.host}' 2>&1
        
        if ($LASTEXITCODE -ne 0) { $controllerRoute = "Not available" }
        if ($LASTEXITCODE -ne 0) { $hubRoute = "Not available" }
        if ($LASTEXITCODE -ne 0) { $edaRoute = "Not available" }
        
        Write-Host "📊 Controller: https://$controllerRoute" -ForegroundColor Cyan
        Write-Host "🏪 Hub: https://$hubRoute" -ForegroundColor Cyan
        Write-Host "⚡ EDA: https://$edaRoute" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "👤 Admin User: admin" -ForegroundColor Yellow
        Write-Host "🔐 Admin Password: [Set via AAP_ADMIN_PASSWORD]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Namespace: $Namespace" -ForegroundColor White
        Write-Host "🏗️ Platform Version: $AAPVersion" -ForegroundColor White
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Green
        Write-Host "1. Access the Controller UI to complete initial setup" -ForegroundColor White
        Write-Host "2. Configure organizations and teams" -ForegroundColor White
        Write-Host "3. Set up credential types and credentials" -ForegroundColor White
        Write-Host "4. Upload automation content to Private Automation Hub" -ForegroundColor White
        Write-Host "5. Configure event-driven automation rules" -ForegroundColor White
        Write-Host ""
        Write-Host "📝 Deployment log: $script:LogFile" -ForegroundColor Magenta
    }
    catch {
        Write-Warning-Log "Failed to retrieve some deployment information: $_"
    }
    
    Write-Host "======================================================" -ForegroundColor Green
}

# Function to cleanup deployment
function Remove-Deployment {
    Write-Info-Log "Removing IBM Ansible Automation Platform deployment..."
    
    $response = Read-Host "Are you sure you want to remove the deployment? This cannot be undone. (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Info-Log "Cleanup cancelled"
        exit 0
    }
    
    try {
        # Find the project root directory
        $projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        $playbookPath = Join-Path $projectRoot "delivery\scripts\ansible\playbook.yml"
        
        # Run cleanup playbook
        Push-Location $projectRoot
        try {
            & ansible-playbook $playbookPath `
                -e "openshift_namespace=$Namespace" `
                --tags "cleanup" `
                -v
        }
        finally {
            Pop-Location
        }
        
        # Remove operator if no other instances exist
        $otherInstances = & oc get automationcontroller --all-namespaces --no-headers 2>&1
        if ($LASTEXITCODE -ne 0 -or !$otherInstances) {
            Write-Info-Log "Removing operator (no other instances found)..."
            & oc delete subscription ansible-automation-platform-operator -n ansible-automation-platform-operator --ignore-not-found=true 2>&1 | Out-Null
            & oc delete csv -n ansible-automation-platform-operator -l operators.coreos.com/ansible-automation-platform-operator.ansible-automation-platform-operator --ignore-not-found=true 2>&1 | Out-Null
            & oc delete namespace ansible-automation-platform-operator --ignore-not-found=true 2>&1 | Out-Null
        }
    }
    catch {
        Write-Error-Log "Failed to cleanup deployment: $_"
    }
    
    Write-Success-Log "Cleanup complete"
}

# Function to cleanup temporary files
function Remove-TemporaryFiles {
    if ($script:TempDir -and (Test-Path $script:TempDir)) {
        try {
            Remove-Item -Path $script:TempDir -Recurse -Force
        }
        catch {
            Write-Warning-Log "Failed to cleanup temporary directory: $_"
        }
    }
}

# Main function
function Main {
    try {
        if ($Help) {
            Show-Usage
            return
        }
        
        Write-Info-Log "Starting IBM Ansible Automation Platform deployment"
        Write-Info-Log "Log file: $script:LogFile"
        
        # Handle cleanup mode
        if ($Cleanup) {
            Test-Prerequisites
            Initialize-Environment
            Remove-Deployment
            return
        }
        
        # Run deployment steps
        Test-Prerequisites
        
        if ($ValidateOnly) {
            Write-Success-Log "Prerequisites validation complete"
            return
        }
        
        Initialize-Environment
        Test-ClusterResources
        
        if ($DryRun) {
            Write-Info-Log "Dry run complete. Would proceed with deployment using:"
            Write-Info-Log "  Namespace: $Namespace"
            Write-Info-Log "  Domain: $DomainName"
            Write-Info-Log "  Version: $AAPVersion"
            return
        }
        
        Install-AAPOperator
        New-NamespaceAndSecrets
        Deploy-PlatformComponents
        Test-Deployment
        Show-DeploymentSummary
        
        Write-Success-Log "IBM Ansible Automation Platform deployment completed successfully"
    }
    catch {
        Write-Error-Log "Deployment failed: $_"
    }
    finally {
        Remove-TemporaryFiles
    }
}

# Load required assemblies for password generation
Add-Type -AssemblyName System.Web

# Run main function
Main
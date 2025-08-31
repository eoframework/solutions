#!/bin/bash
# Azure Virtual Desktop - Deployment Script
# Comprehensive deployment automation for Azure Virtual Desktop

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.yml"
LOG_FILE="/var/log/azure-avd-deploy.log"

# Logging function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        error_exit "Azure CLI not found. Please install Azure CLI first."
    fi
    
    # Check Azure login
    if ! az account show &> /dev/null; then
        error_exit "Not logged into Azure. Run 'az login' first."
    fi
    
    # Check PowerShell Core
    if ! command -v pwsh &> /dev/null; then
        log "WARN" "PowerShell Core not found. Installing..."
        install_powershell
    fi
    
    # Check required tools
    for tool in jq curl; do
        if ! command -v "$tool" &> /dev/null; then
            error_exit "$tool not found. Please install $tool."
        fi
    done
    
    log "INFO" "Prerequisites check passed"
}

# Install PowerShell Core
install_powershell() {
    log "INFO" "Installing PowerShell Core..."
    
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell_7.3.0-1.deb_amd64.deb -o /tmp/powershell.deb
        sudo dpkg -i /tmp/powershell.deb
        sudo apt-get install -f -y
        rm /tmp/powershell.deb
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS
        curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell-7.3.0-1.rhel.7.x86_64.rpm -o /tmp/powershell.rpm
        sudo yum install -y /tmp/powershell.rpm
        rm /tmp/powershell.rpm
    else
        error_exit "Unsupported Linux distribution for PowerShell installation"
    fi
    
    log "INFO" "PowerShell Core installed successfully"
}

# Set Azure subscription
set_subscription() {
    log "INFO" "Setting Azure subscription..."
    
    local subscription_id="${AZURE_SUBSCRIPTION_ID:-}"
    
    if [[ -z "$subscription_id" ]]; then
        # List available subscriptions
        log "INFO" "Available subscriptions:"
        az account list --output table
        
        read -p "Enter subscription ID: " subscription_id
    fi
    
    # Set subscription
    az account set --subscription "$subscription_id"
    
    export AZURE_SUBSCRIPTION_ID="$subscription_id"
    log "INFO" "Azure subscription set: $subscription_id"
}

# Create resource group
create_resource_group() {
    log "INFO" "Creating resource group..."
    
    local rg_name="${RESOURCE_GROUP_NAME:-${PROJECT_NAME}-avd-rg}"
    local location="${AZURE_LOCATION:-eastus}"
    
    # Create resource group
    az group create \
        --name "$rg_name" \
        --location "$location" \
        --tags Project="${PROJECT_NAME}" Environment="${ENVIRONMENT:-production}"
    
    export RESOURCE_GROUP_NAME="$rg_name"
    export AZURE_LOCATION="$location"
    
    log "INFO" "Resource group created: $rg_name"
}

# Create shared image gallery
create_shared_image_gallery() {
    log "INFO" "Creating Shared Image Gallery..."
    
    local gallery_name="${PROJECT_NAME}Gallery"
    local image_definition="${PROJECT_NAME}ImageDef"
    
    # Create gallery
    az sig create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --gallery-name "$gallery_name" \
        --location "$AZURE_LOCATION"
    
    # Create image definition
    az sig image-definition create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --gallery-name "$gallery_name" \
        --gallery-image-definition "$image_definition" \
        --publisher "Microsoft" \
        --offer "WindowsDesktop" \
        --sku "win11-22h2-avd" \
        --os-type Windows \
        --os-state generalized \
        --hyper-v-generation V2 \
        --minimum-cpu-core 2 \
        --maximum-cpu-core 32 \
        --minimum-memory 4 \
        --maximum-memory 128
    
    export GALLERY_NAME="$gallery_name"
    export IMAGE_DEFINITION="$image_definition"
    
    log "INFO" "Shared Image Gallery created: $gallery_name"
}

# Install AVD PowerShell module
install_avd_module() {
    log "INFO" "Installing AVD PowerShell module..."
    
    # Install required modules using PowerShell
    pwsh -c "
        if (-not (Get-Module -ListAvailable -Name Az.DesktopVirtualization)) {
            Install-Module -Name Az.DesktopVirtualization -Force -AllowClobber
        }
        if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
            Install-Module -Name Az.Resources -Force -AllowClobber
        }
        Import-Module Az.DesktopVirtualization
        Import-Module Az.Resources
    "
    
    log "INFO" "AVD PowerShell module installed successfully"
}

# Create host pool
create_host_pool() {
    log "INFO" "Creating AVD host pool..."
    
    local hostpool_name="${PROJECT_NAME}-hostpool"
    local max_sessions="${MAX_SESSIONS:-10}"
    
    # Create host pool using PowerShell
    pwsh -c "
        Connect-AzAccount -Identity
        Set-AzContext -SubscriptionId '${AZURE_SUBSCRIPTION_ID}'
        
        New-AzWvdHostPool \
            -ResourceGroupName '${RESOURCE_GROUP_NAME}' \
            -Name '${hostpool_name}' \
            -Location '${AZURE_LOCATION}' \
            -HostPoolType 'Pooled' \
            -LoadBalancerType 'BreadthFirst' \
            -MaxSessionLimit ${max_sessions} \
            -PersonalDesktopAssignmentType 'Automatic' \
            -Tag @{Project='${PROJECT_NAME}'; Environment='${ENVIRONMENT:-production}'}
    "
    
    export HOSTPOOL_NAME="$hostpool_name"
    log "INFO" "Host pool created: $hostpool_name"
}

# Create application group
create_application_group() {
    log "INFO" "Creating application group..."
    
    local appgroup_name="${PROJECT_NAME}-appgroup"
    
    # Create application group using PowerShell
    pwsh -c "
        New-AzWvdApplicationGroup \
            -ResourceGroupName '${RESOURCE_GROUP_NAME}' \
            -Name '${appgroup_name}' \
            -Location '${AZURE_LOCATION}' \
            -FriendlyName 'Desktop Application Group' \
            -Description 'Desktop Application Group for AVD' \
            -HostPoolArmPath '/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.DesktopVirtualization/hostpools/${HOSTPOOL_NAME}' \
            -ApplicationGroupType 'Desktop'
    "
    
    export APPGROUP_NAME="$appgroup_name"
    log "INFO" "Application group created: $appgroup_name"
}

# Create workspace
create_workspace() {
    log "INFO" "Creating AVD workspace..."
    
    local workspace_name="${PROJECT_NAME}-workspace"
    
    # Create workspace using PowerShell
    pwsh -c "
        New-AzWvdWorkspace \
            -ResourceGroupName '${RESOURCE_GROUP_NAME}' \
            -Name '${workspace_name}' \
            -Location '${AZURE_LOCATION}' \
            -FriendlyName 'Main Workspace' \
            -Description 'Main AVD Workspace'
    "
    
    # Associate application group with workspace
    pwsh -c "
        Register-AzWvdApplicationGroup \
            -ResourceGroupName '${RESOURCE_GROUP_NAME}' \
            -WorkspaceName '${workspace_name}' \
            -ApplicationGroupPath '/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourcegroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.DesktopVirtualization/applicationgroups/${APPGROUP_NAME}'
    "
    
    export WORKSPACE_NAME="$workspace_name"
    log "INFO" "Workspace created and associated: $workspace_name"
}

# Create session host VMs
create_session_hosts() {
    log "INFO" "Creating session host VMs..."
    
    local host_count="${SESSION_HOST_COUNT:-2}"
    local vm_size="${VM_SIZE:-Standard_D4s_v3}"
    local admin_username="${ADMIN_USERNAME:-avdadmin}"
    local admin_password="${ADMIN_PASSWORD:-$(openssl rand -base64 32)}"
    
    # Get host pool registration token
    local registration_token=$(pwsh -c "
        (New-AzWvdRegistrationInfo \
            -ResourceGroupName '${RESOURCE_GROUP_NAME}' \
            -HostPoolName '${HOSTPOOL_NAME}' \
            -ExpirationTime (Get-Date).AddHours(4)).Token
    ")
    
    # Create VMs using Azure CLI
    for i in $(seq 1 "$host_count"); do
        local vm_name="${PROJECT_NAME}-vm-${i}"
        
        log "INFO" "Creating session host: $vm_name"
        
        # Create VM
        az vm create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$vm_name" \
            --image "MicrosoftWindowsDesktop:Windows-11:win11-22h2-avd:latest" \
            --size "$vm_size" \
            --admin-username "$admin_username" \
            --admin-password "$admin_password" \
            --location "$AZURE_LOCATION" \
            --tags Project="${PROJECT_NAME}" Environment="${ENVIRONMENT:-production}" \
            --no-wait
    done
    
    # Wait for all VMs to be created
    log "INFO" "Waiting for VMs to be created..."
    for i in $(seq 1 "$host_count"); do
        local vm_name="${PROJECT_NAME}-vm-${i}"
        az vm wait --created --resource-group "$RESOURCE_GROUP_NAME" --name "$vm_name"
    done
    
    # Store credentials securely
    echo "ADMIN_USERNAME=${admin_username}" >> "${SCRIPT_DIR}/../.env"
    echo "ADMIN_PASSWORD=${admin_password}" >> "${SCRIPT_DIR}/../.env"
    echo "REGISTRATION_TOKEN=${registration_token}" >> "${SCRIPT_DIR}/../.env"
    
    log "INFO" "Session host VMs created successfully"
}

# Configure monitoring
configure_monitoring() {
    log "INFO" "Configuring monitoring..."
    
    local workspace_name="${PROJECT_NAME}-log-analytics"
    
    # Create Log Analytics workspace
    az monitor log-analytics workspace create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$workspace_name" \
        --location "$AZURE_LOCATION" \
        --tags Project="${PROJECT_NAME}"
    
    # Enable AVD insights
    local workspace_id=$(az monitor log-analytics workspace show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --workspace-name "$workspace_name" \
        --query customerId -o tsv)
    
    export LOG_ANALYTICS_WORKSPACE="$workspace_name"
    export WORKSPACE_ID="$workspace_id"
    
    log "INFO" "Monitoring configured successfully"
}

# Generate deployment summary
generate_summary() {
    log "INFO" "Generating deployment summary..."
    
    # Source environment variables if they exist
    if [[ -f "${SCRIPT_DIR}/../.env" ]]; then
        source "${SCRIPT_DIR}/../.env"
    fi
    
    cat << EOF | tee -a "$LOG_FILE"

================================================================================
AZURE VIRTUAL DESKTOP DEPLOYMENT SUMMARY
================================================================================

Deployment Status: SUCCESSFUL
Deployment Date: $(date)
Azure Region: ${AZURE_LOCATION}
Resource Group: ${RESOURCE_GROUP_NAME}

AVD Resources:
- Host Pool: ${HOSTPOOL_NAME}
- Application Group: ${APPGROUP_NAME}
- Workspace: ${WORKSPACE_NAME}
- Session Hosts: ${SESSION_HOST_COUNT:-2} VMs

Shared Image Gallery:
- Gallery: ${GALLERY_NAME}
- Image Definition: ${IMAGE_DEFINITION}

Monitoring:
- Log Analytics: ${LOG_ANALYTICS_WORKSPACE}
- Workspace ID: ${WORKSPACE_ID}

Admin Credentials:
- Username: ${ADMIN_USERNAME}
- Password: [Stored in .env file]

Next Steps:
1. Join session hosts to the host pool using the registration token
2. Install and configure applications on session hosts
3. Assign users to application groups
4. Test user connections via AVD client
5. Configure backup and disaster recovery

URLs:
- AVD Web Client: https://rdweb.wvd.microsoft.com/arm/webclient
- Azure Portal: https://portal.azure.com

Documentation:
- Environment: ${SCRIPT_DIR}/../.env
- Logs: ${LOG_FILE}

================================================================================
EOF
}

# Main deployment function
main() {
    log "INFO" "Starting Azure Virtual Desktop deployment..."
    
    # Set default values
    export PROJECT_NAME="${PROJECT_NAME:-azure-avd}"
    export ENVIRONMENT="${ENVIRONMENT:-production}"
    export SESSION_HOST_COUNT="${SESSION_HOST_COUNT:-2}"
    
    # Execute deployment steps
    check_prerequisites
    set_subscription
    create_resource_group
    create_shared_image_gallery
    install_avd_module
    create_host_pool
    create_application_group
    create_workspace
    create_session_hosts
    configure_monitoring
    generate_summary
    
    log "INFO" "Azure Virtual Desktop deployment completed successfully!"
}

# Execute main function
main "$@"
#!/bin/bash
#
# Azure Virtual Desktop Deployment Script
# 
# This script automates the deployment of Azure Virtual Desktop infrastructure
# using Azure CLI commands and configuration files.
#

set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/avd_deployment.log"
CONFIG_FILE=""
SUBSCRIPTION_ID=""
DRY_RUN=false
VERBOSE=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[INFO]${NC} ${timestamp} - $1" | tee -a "${LOG_FILE}"
}

log_warn() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARN]${NC} ${timestamp} - $1" | tee -a "${LOG_FILE}"
}

log_error() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR]${NC} ${timestamp} - $1" | tee -a "${LOG_FILE}"
}

log_success() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[SUCCESS]${NC} ${timestamp} - $1" | tee -a "${LOG_FILE}"
}

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Azure Virtual Desktop infrastructure using Azure CLI.

OPTIONS:
    -c, --config FILE       Configuration file path (required)
    -s, --subscription ID   Azure subscription ID (required)
    -d, --dry-run          Validate configuration without deploying
    -v, --verbose          Enable verbose output
    -h, --help             Show this help message

EXAMPLES:
    $0 --config avd-config.json --subscription 12345678-1234-1234-1234-123456789012
    $0 -c config.json -s 12345678-1234-1234-1234-123456789012 --dry-run

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -s|--subscription)
                SUBSCRIPTION_ID="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "${CONFIG_FILE}" ]]; then
        log_error "Configuration file is required. Use -c or --config option."
        usage
        exit 1
    fi

    if [[ -z "${SUBSCRIPTION_ID}" ]]; then
        log_error "Subscription ID is required. Use -s or --subscription option."
        usage
        exit 1
    fi

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log_error "Configuration file not found: ${CONFIG_FILE}"
        exit 1
    fi
}

# Load configuration from JSON file
load_config() {
    log_info "Loading configuration from ${CONFIG_FILE}"
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed. Please install jq to parse JSON configuration."
        exit 1
    fi

    # Validate JSON syntax
    if ! jq empty "${CONFIG_FILE}" 2>/dev/null; then
        log_error "Invalid JSON in configuration file: ${CONFIG_FILE}"
        exit 1
    fi

    # Load configuration variables
    RESOURCE_GROUP=$(jq -r '.resource_group_name' "${CONFIG_FILE}")
    LOCATION=$(jq -r '.location' "${CONFIG_FILE}")
    PREFIX=$(jq -r '.prefix' "${CONFIG_FILE}")
    VNET_NAME=$(jq -r '.vnet_name' "${CONFIG_FILE}")
    SUBNET_NAME=$(jq -r '.subnet_name' "${CONFIG_FILE}")
    STORAGE_ACCOUNT_NAME=$(jq -r '.storage_account_name' "${CONFIG_FILE}")
    HOST_POOL_NAME=$(jq -r '.host_pool_name' "${CONFIG_FILE}")
    WORKSPACE_NAME=$(jq -r '.workspace_name' "${CONFIG_FILE}")
    SESSION_HOST_COUNT=$(jq -r '.session_host_count' "${CONFIG_FILE}")
    VM_SIZE=$(jq -r '.session_host_vm_size // "Standard_D4s_v4"' "${CONFIG_FILE}")

    log_info "Configuration loaded successfully"
    if [[ "${VERBOSE}" == true ]]; then
        log_info "Resource Group: ${RESOURCE_GROUP}"
        log_info "Location: ${LOCATION}"
        log_info "Host Pool: ${HOST_POOL_NAME}"
        log_info "Session Hosts: ${SESSION_HOST_COUNT}"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites"

    # Check Azure CLI installation
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install Azure CLI."
        exit 1
    fi

    # Check Azure CLI login
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure CLI. Please run 'az login' first."
        exit 1
    fi

    # Set subscription
    log_info "Setting Azure subscription: ${SUBSCRIPTION_ID}"
    az account set --subscription "${SUBSCRIPTION_ID}"

    # Check if AVD extension is installed
    if ! az extension list | grep -q "desktopvirtualization"; then
        log_info "Installing Azure CLI desktopvirtualization extension"
        az extension add --name desktopvirtualization
    fi

    log_success "Prerequisites check completed"
}

# Create resource group
create_resource_group() {
    log_info "Creating resource group: ${RESOURCE_GROUP} in ${LOCATION}"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create resource group ${RESOURCE_GROUP}"
        return 0
    fi

    if az group show --name "${RESOURCE_GROUP}" &> /dev/null; then
        log_info "Resource group already exists"
    else
        az group create \
            --name "${RESOURCE_GROUP}" \
            --location "${LOCATION}" \
            --tags "Environment=Production" "Project=AVD" "CreatedBy=Script"
        log_success "Resource group created successfully"
    fi
}

# Create virtual network
create_virtual_network() {
    log_info "Creating virtual network: ${VNET_NAME}"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create virtual network ${VNET_NAME}"
        return 0
    fi

    # Create virtual network
    az network vnet create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${VNET_NAME}" \
        --address-prefix "10.0.0.0/16" \
        --subnet-name "${SUBNET_NAME}" \
        --subnet-prefix "10.0.1.0/24" \
        --tags "Environment=Production" "Project=AVD"

    # Create Network Security Group
    local nsg_name="nsg-${PREFIX}-hosts"
    az network nsg create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${nsg_name}" \
        --tags "Environment=Production" "Project=AVD"

    # Add NSG rules for AVD
    az network nsg rule create \
        --resource-group "${RESOURCE_GROUP}" \
        --nsg-name "${nsg_name}" \
        --name "Allow-AVD-Traffic" \
        --priority 100 \
        --direction Outbound \
        --access Allow \
        --protocol Tcp \
        --source-address-prefixes "VirtualNetwork" \
        --source-port-ranges "*" \
        --destination-address-prefixes "WindowsVirtualDesktop" \
        --destination-port-ranges "443"

    az network nsg rule create \
        --resource-group "${RESOURCE_GROUP}" \
        --nsg-name "${nsg_name}" \
        --name "Allow-Azure-KMS" \
        --priority 110 \
        --direction Outbound \
        --access Allow \
        --protocol Tcp \
        --source-address-prefixes "*" \
        --source-port-ranges "*" \
        --destination-address-prefixes "23.102.135.246" \
        --destination-port-ranges "1688"

    # Associate NSG with subnet
    az network vnet subnet update \
        --resource-group "${RESOURCE_GROUP}" \
        --vnet-name "${VNET_NAME}" \
        --name "${SUBNET_NAME}" \
        --network-security-group "${nsg_name}"

    log_success "Virtual network created successfully"
}

# Create storage account
create_storage_account() {
    log_info "Creating storage account: ${STORAGE_ACCOUNT_NAME}"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create storage account ${STORAGE_ACCOUNT_NAME}"
        return 0
    fi

    # Create storage account
    az storage account create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${STORAGE_ACCOUNT_NAME}" \
        --location "${LOCATION}" \
        --sku "Premium_LRS" \
        --kind "FileStorage" \
        --default-action "Deny" \
        --tags "Environment=Production" "Project=AVD"

    # Create file share for profiles
    local storage_key=$(az storage account keys list \
        --resource-group "${RESOURCE_GROUP}" \
        --account-name "${STORAGE_ACCOUNT_NAME}" \
        --query "[0].value" --output tsv)

    az storage share create \
        --name "profiles" \
        --quota 1024 \
        --account-name "${STORAGE_ACCOUNT_NAME}" \
        --account-key "${storage_key}"

    log_success "Storage account created successfully"
}

# Create AVD host pool
create_host_pool() {
    log_info "Creating AVD host pool: ${HOST_POOL_NAME}"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create host pool ${HOST_POOL_NAME}"
        return 0
    fi

    az desktopvirtualization hostpool create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${HOST_POOL_NAME}" \
        --location "${LOCATION}" \
        --host-pool-type "Pooled" \
        --load-balancer-type "BreadthFirst" \
        --max-session-limit 10 \
        --preferred-app-group-type "Desktop" \
        --tags "Environment=Production" "Project=AVD"

    log_success "Host pool created successfully"
}

# Create workspace and application group
create_workspace_and_app_group() {
    log_info "Creating workspace: ${WORKSPACE_NAME}"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create workspace and application group"
        return 0
    fi

    # Create workspace
    az desktopvirtualization workspace create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${WORKSPACE_NAME}" \
        --location "${LOCATION}" \
        --tags "Environment=Production" "Project=AVD"

    # Create desktop application group
    local app_group_name="${PREFIX}-desktop-appgroup"
    local host_pool_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.DesktopVirtualization/hostPools/${HOST_POOL_NAME}"

    az desktopvirtualization applicationgroup create \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${app_group_name}" \
        --location "${LOCATION}" \
        --application-group-type "Desktop" \
        --host-pool-arm-path "${host_pool_id}" \
        --tags "Environment=Production" "Project=AVD"

    # Associate application group with workspace
    local app_group_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.DesktopVirtualization/applicationGroups/${app_group_name}"

    az desktopvirtualization workspace update \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${WORKSPACE_NAME}" \
        --application-group-references "${app_group_id}"

    log_success "Workspace and application group created successfully"
}

# Create session hosts
create_session_hosts() {
    log_info "Creating ${SESSION_HOST_COUNT} session host VMs"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create ${SESSION_HOST_COUNT} session host VMs"
        return 0
    fi

    # Get host pool registration token
    local token=$(az desktopvirtualization hostpool retrieve-registration-token \
        --resource-group "${RESOURCE_GROUP}" \
        --name "${HOST_POOL_NAME}" \
        --expiration-time "$(date -u -d '+4 hours' '+%Y-%m-%dT%H:%M:%S.000Z')" \
        --query "token" --output tsv)

    # Create session host VMs
    for ((i=1; i<=SESSION_HOST_COUNT; i++)); do
        local vm_name="vm-${PREFIX}-sh-$(printf '%02d' $i)"
        local nic_name="nic-${PREFIX}-sh-$(printf '%02d' $i)"

        log_info "Creating session host: ${vm_name}"

        # Create network interface
        az network nic create \
            --resource-group "${RESOURCE_GROUP}" \
            --name "${nic_name}" \
            --vnet-name "${VNET_NAME}" \
            --subnet "${SUBNET_NAME}" \
            --tags "Environment=Production" "Project=AVD"

        # Create virtual machine
        az vm create \
            --resource-group "${RESOURCE_GROUP}" \
            --name "${vm_name}" \
            --nics "${nic_name}" \
            --image "MicrosoftWindowsDesktop:Windows-11:win11-21h2-ent:latest" \
            --size "${VM_SIZE}" \
            --admin-username "avdadmin" \
            --admin-password "$(generate_password)" \
            --os-disk-name "${vm_name}-osdisk" \
            --storage-sku "Premium_LRS" \
            --tags "Environment=Production" "Project=AVD" &

        # Limit concurrent VM creations
        if ((i % 3 == 0)); then
            wait
        fi
    done

    # Wait for all background processes to complete
    wait

    log_success "Session host VMs created successfully"

    # Install AVD agents
    install_avd_agents "${token}"
}

# Generate secure password for VMs
generate_password() {
    openssl rand -base64 20 | tr -d "=+/" | cut -c1-16
}

# Install AVD agents on session hosts
install_avd_agents() {
    local token="$1"
    
    log_info "Installing AVD agents on session hosts"

    for ((i=1; i<=SESSION_HOST_COUNT; i++)); do
        local vm_name="vm-${PREFIX}-sh-$(printf '%02d' $i)"
        
        log_info "Installing AVD agent on ${vm_name}"

        # Create PowerShell script for agent installation
        local script_content="
            \$ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv' -OutFile 'C:\\AVDAgentBootLoaderInstall.msi'
            Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\\AVDAgentBootLoaderInstall.msi /quiet /qn /norestart /passive' -Wait
            
            Invoke-WebRequest -Uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH' -OutFile 'C:\\AVDAgentInstall.msi'
            Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\\AVDAgentInstall.msi /quiet /qn /norestart /passive REGISTRATIONTOKEN=${token}' -Wait
            
            Restart-Computer -Force
        "

        # Execute script on VM
        az vm run-command invoke \
            --resource-group "${RESOURCE_GROUP}" \
            --name "${vm_name}" \
            --command-id "RunPowerShellScript" \
            --scripts "${script_content}" &
    done

    # Wait for all installations to complete
    wait

    log_success "AVD agents installed successfully"
}

# Create Log Analytics workspace
create_log_analytics() {
    local workspace_name="law-${PREFIX}-prod"
    
    log_info "Creating Log Analytics workspace: ${workspace_name}"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would create Log Analytics workspace ${workspace_name}"
        return 0
    fi

    az monitor log-analytics workspace create \
        --resource-group "${RESOURCE_GROUP}" \
        --workspace-name "${workspace_name}" \
        --location "${LOCATION}" \
        --sku "PerGB2018" \
        --retention-time 30 \
        --tags "Environment=Production" "Project=AVD"

    log_success "Log Analytics workspace created successfully"
}

# Configure monitoring and diagnostics
configure_monitoring() {
    log_info "Configuring monitoring and diagnostics"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would configure monitoring"
        return 0
    fi

    # Enable diagnostic settings for host pool
    local workspace_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.OperationalInsights/workspaces/law-${PREFIX}-prod"
    local host_pool_id="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.DesktopVirtualization/hostPools/${HOST_POOL_NAME}"

    az monitor diagnostic-settings create \
        --name "avd-diagnostics" \
        --resource "${host_pool_id}" \
        --workspace "${workspace_id}" \
        --logs '[
            {"category": "Checkpoint", "enabled": true, "retention-policy": {"enabled": true, "days": 30}},
            {"category": "Error", "enabled": true, "retention-policy": {"enabled": true, "days": 30}},
            {"category": "Management", "enabled": true, "retention-policy": {"enabled": true, "days": 30}}
        ]'

    log_success "Monitoring configured successfully"
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment"

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "DRY RUN: Would verify deployment"
        return 0
    fi

    # Check resource group
    if ! az group show --name "${RESOURCE_GROUP}" &> /dev/null; then
        log_error "Resource group verification failed"
        return 1
    fi

    # Check host pool
    if ! az desktopvirtualization hostpool show --resource-group "${RESOURCE_GROUP}" --name "${HOST_POOL_NAME}" &> /dev/null; then
        log_error "Host pool verification failed"
        return 1
    fi

    # Check session hosts
    local registered_hosts=$(az desktopvirtualization sessionhost list \
        --resource-group "${RESOURCE_GROUP}" \
        --host-pool-name "${HOST_POOL_NAME}" \
        --query "length(@)")

    if [[ "${registered_hosts}" -lt "${SESSION_HOST_COUNT}" ]]; then
        log_warn "Only ${registered_hosts} of ${SESSION_HOST_COUNT} session hosts are registered"
    fi

    log_success "Deployment verification completed"
}

# Print deployment summary
print_summary() {
    log_info "Deployment Summary"
    echo "=================================="
    echo "Resource Group: ${RESOURCE_GROUP}"
    echo "Location: ${LOCATION}"
    echo "Host Pool: ${HOST_POOL_NAME}"
    echo "Workspace: ${WORKSPACE_NAME}"
    echo "Session Hosts: ${SESSION_HOST_COUNT}"
    echo "Storage Account: ${STORAGE_ACCOUNT_NAME}"
    echo "Web Client URL: https://rdweb.wvd.microsoft.com/arm/webclient"
    echo "=================================="
}

# Main deployment function
main() {
    local start_time=$(date +%s)
    
    log_info "Starting Azure Virtual Desktop deployment"

    # Parse arguments and load configuration
    parse_args "$@"
    load_config

    if [[ "${DRY_RUN}" == true ]]; then
        log_warn "Running in DRY RUN mode - no resources will be created"
    fi

    # Execute deployment steps
    check_prerequisites
    create_resource_group
    create_virtual_network
    create_storage_account
    create_host_pool
    create_workspace_and_app_group
    create_session_hosts
    create_log_analytics
    configure_monitoring
    verify_deployment

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log_success "Azure Virtual Desktop deployment completed in ${duration} seconds!"
    print_summary

    if [[ "${DRY_RUN}" == false ]]; then
        log_info "Access your desktop at: https://rdweb.wvd.microsoft.com/arm/webclient"
    fi
}

# Trap errors and cleanup
trap 'log_error "Script failed on line $LINENO"' ERR

# Execute main function with all arguments
main "$@"
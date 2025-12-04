#!/bin/bash
################################################################################
# Microsoft Sentinel SIEM - Bicep Deployment Script
################################################################################
# Description: Deploys Sentinel SIEM solution using Azure Bicep
# Version: 1.0.0
# Usage: ./deploy.sh [environment] [subscription-id]
# Example: ./deploy.sh prod 12345678-1234-1234-1234-123456789012
################################################################################

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

################################################################################
# VARIABLES
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_DIR="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-prod}"
SUBSCRIPTION_ID="${2:-}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DEPLOYMENT_NAME="sentinel-siem-${ENVIRONMENT}-${TIMESTAMP}"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# FUNCTIONS
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_banner() {
    echo "################################################################################"
    echo "#                  Microsoft Sentinel SIEM Deployment                         #"
    echo "################################################################################"
    echo ""
    echo "Environment:     ${ENVIRONMENT}"
    echo "Deployment Name: ${DEPLOYMENT_NAME}"
    echo "Timestamp:       ${TIMESTAMP}"
    echo ""
    echo "################################################################################"
    echo ""
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        log_info "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi

    # Check Azure CLI version
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
    log_info "Azure CLI version: ${AZ_VERSION}"

    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi

    log_success "Prerequisites check passed"
}

validate_environment() {
    log_info "Validating environment parameter..."

    if [[ ! "${ENVIRONMENT}" =~ ^(prod|test|dr)$ ]]; then
        log_error "Invalid environment: ${ENVIRONMENT}"
        log_error "Valid environments are: prod, test, dr"
        exit 1
    fi

    # Check if parameter file exists
    PARAM_FILE="${BICEP_DIR}/parameters/${ENVIRONMENT}.parameters.json"
    if [[ ! -f "${PARAM_FILE}" ]]; then
        log_error "Parameter file not found: ${PARAM_FILE}"
        exit 1
    fi

    log_success "Environment validation passed"
}

set_subscription() {
    log_info "Setting Azure subscription..."

    if [[ -n "${SUBSCRIPTION_ID}" ]]; then
        az account set --subscription "${SUBSCRIPTION_ID}"
        log_success "Subscription set to: ${SUBSCRIPTION_ID}"
    else
        CURRENT_SUB=$(az account show --query id -o tsv)
        log_warning "No subscription specified, using current: ${CURRENT_SUB}"
        SUBSCRIPTION_ID="${CURRENT_SUB}"
    fi
}

validate_bicep() {
    log_info "Validating Bicep template..."

    MAIN_BICEP="${BICEP_DIR}/main.bicep"
    PARAM_FILE="${BICEP_DIR}/parameters/${ENVIRONMENT}.parameters.json"

    if az deployment sub validate \
        --location eastus \
        --template-file "${MAIN_BICEP}" \
        --parameters "${PARAM_FILE}" \
        --output none; then
        log_success "Bicep template validation passed"
    else
        log_error "Bicep template validation failed"
        exit 1
    fi
}

what_if_deployment() {
    log_info "Running what-if analysis..."

    MAIN_BICEP="${BICEP_DIR}/main.bicep"
    PARAM_FILE="${BICEP_DIR}/parameters/${ENVIRONMENT}.parameters.json"

    az deployment sub what-if \
        --location eastus \
        --name "${DEPLOYMENT_NAME}-whatif" \
        --template-file "${MAIN_BICEP}" \
        --parameters "${PARAM_FILE}"

    echo ""
    log_warning "Review the what-if results above before proceeding."
    read -p "Do you want to continue with deployment? (yes/no): " -r REPLY
    echo ""

    if [[ ! "${REPLY}" =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Deployment cancelled by user."
        exit 0
    fi
}

deploy_sentinel() {
    log_info "Starting Sentinel SIEM deployment..."

    MAIN_BICEP="${BICEP_DIR}/main.bicep"
    PARAM_FILE="${BICEP_DIR}/parameters/${ENVIRONMENT}.parameters.json"

    log_info "Deploying to subscription: ${SUBSCRIPTION_ID}"
    log_info "Using parameters from: ${PARAM_FILE}"

    if az deployment sub create \
        --location eastus \
        --name "${DEPLOYMENT_NAME}" \
        --template-file "${MAIN_BICEP}" \
        --parameters "${PARAM_FILE}" \
        --verbose; then

        log_success "Deployment completed successfully!"

        # Get deployment outputs
        log_info "Retrieving deployment outputs..."
        az deployment sub show \
            --name "${DEPLOYMENT_NAME}" \
            --query properties.outputs \
            --output json > "${BICEP_DIR}/outputs-${ENVIRONMENT}-${TIMESTAMP}.json"

        log_success "Deployment outputs saved to: outputs-${ENVIRONMENT}-${TIMESTAMP}.json"

    else
        log_error "Deployment failed!"
        exit 1
    fi
}

post_deployment_checks() {
    log_info "Running post-deployment checks..."

    # Get resource group name from deployment outputs
    RESOURCE_GROUP=$(az deployment sub show \
        --name "${DEPLOYMENT_NAME}" \
        --query properties.outputs.resourceGroupName.value \
        --output tsv)

    if [[ -n "${RESOURCE_GROUP}" ]]; then
        log_info "Checking resources in resource group: ${RESOURCE_GROUP}"

        # List deployed resources
        az resource list --resource-group "${RESOURCE_GROUP}" --output table

        log_success "Post-deployment checks completed"
    else
        log_warning "Could not retrieve resource group name from deployment"
    fi
}

print_summary() {
    echo ""
    echo "################################################################################"
    echo "#                        Deployment Summary                                   #"
    echo "################################################################################"
    echo ""
    echo "Environment:        ${ENVIRONMENT}"
    echo "Subscription ID:    ${SUBSCRIPTION_ID}"
    echo "Deployment Name:    ${DEPLOYMENT_NAME}"
    echo "Status:             ${GREEN}SUCCESSFUL${NC}"
    echo ""
    echo "Next Steps:"
    echo "1. Review deployment outputs in: outputs-${ENVIRONMENT}-${TIMESTAMP}.json"
    echo "2. Configure data connector authentication in Azure Portal"
    echo "3. Customize analytics rules based on organizational needs"
    echo "4. Test automation playbooks with sample incidents"
    echo "5. Configure UEBA data sources and entity mappings"
    echo "6. Review and adjust workbook queries for your environment"
    echo ""
    echo "Azure Portal Links:"
    echo "- Sentinel Workspace: https://portal.azure.com/#blade/Microsoft_Azure_Security_Insights/WorkspaceSelectorBlade"
    echo "- Log Analytics: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.OperationalInsights%2Fworkspaces"
    echo ""
    echo "################################################################################"
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    print_banner
    check_prerequisites
    validate_environment
    set_subscription
    validate_bicep
    what_if_deployment
    deploy_sentinel
    post_deployment_checks
    print_summary
}

# Execute main function
main "$@"

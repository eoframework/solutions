#!/bin/bash

################################################################################
# Azure Enterprise Landing Zone - Deployment Script
################################################################################
# Description: Deploys Azure Landing Zone infrastructure using Bicep templates
# Usage: ./deploy.sh <environment> [--validate-only]
# Environments: prod, test, dr
################################################################################

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_DIR="$(dirname "$SCRIPT_DIR")"
PARAMETERS_DIR="$BICEP_DIR/parameters"
MAIN_TEMPLATE="$BICEP_DIR/main.bicep"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "================================================================================"
    echo "$1"
    echo "================================================================================"
    echo ""
}

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    print_success "Azure CLI is installed"

    # Check Azure CLI version
    local az_version=$(az version --query '"azure-cli"' -o tsv)
    print_info "Azure CLI version: $az_version"

    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    print_success "Logged in to Azure"

    # Display current subscription
    local subscription_name=$(az account show --query name -o tsv)
    local subscription_id=$(az account show --query id -o tsv)
    print_info "Current subscription: $subscription_name ($subscription_id)"
}

validate_environment() {
    local env=$1

    if [[ ! "$env" =~ ^(prod|test|dr)$ ]]; then
        print_error "Invalid environment: $env"
        print_info "Valid environments: prod, test, dr"
        exit 1
    fi

    local param_file="$PARAMETERS_DIR/${env}.parameters.json"
    if [[ ! -f "$param_file" ]]; then
        print_error "Parameter file not found: $param_file"
        exit 1
    fi
}

validate_bicep() {
    print_header "Validating Bicep Template"

    print_info "Building Bicep template..."
    if az bicep build --file "$MAIN_TEMPLATE" --stdout > /dev/null; then
        print_success "Bicep template is valid"
    else
        print_error "Bicep template validation failed"
        exit 1
    fi
}

what_if_deployment() {
    local env=$1
    local param_file="$PARAMETERS_DIR/${env}.parameters.json"
    local mg_id=$(jq -r '.parameters.managementGroupRoot.value' "$param_file")

    print_header "Running What-If Analysis for $env Environment"

    print_info "Analyzing deployment changes..."
    az deployment mg what-if \
        --management-group-id "$mg_id" \
        --location eastus \
        --template-file "$MAIN_TEMPLATE" \
        --parameters "@$param_file" \
        --result-format FullResourcePayloads
}

deploy_infrastructure() {
    local env=$1
    local param_file="$PARAMETERS_DIR/${env}.parameters.json"
    local mg_id=$(jq -r '.parameters.managementGroupRoot.value' "$param_file")
    local deployment_name="alz-deployment-${env}-$(date +%Y%m%d-%H%M%S)"

    print_header "Deploying $env Environment"

    print_info "Deployment name: $deployment_name"
    print_info "Management group: $mg_id"
    print_info "Template: $MAIN_TEMPLATE"
    print_info "Parameters: $param_file"

    # Confirm deployment
    read -p "$(echo -e ${YELLOW}Do you want to proceed with the deployment? [y/N]:${NC} )" -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user"
        exit 0
    fi

    print_info "Starting deployment..."
    local start_time=$(date +%s)

    if az deployment mg create \
        --name "$deployment_name" \
        --management-group-id "$mg_id" \
        --location eastus \
        --template-file "$MAIN_TEMPLATE" \
        --parameters "@$param_file" \
        --verbose; then

        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_success "Deployment completed successfully in $duration seconds"

        # Show deployment outputs
        print_header "Deployment Outputs"
        az deployment mg show \
            --name "$deployment_name" \
            --management-group-id "$mg_id" \
            --query properties.outputs \
            --output table
    else
        print_error "Deployment failed"
        exit 1
    fi
}

show_usage() {
    cat << EOF
Usage: $0 <environment> [OPTIONS]

Deploy Azure Enterprise Landing Zone infrastructure

ENVIRONMENTS:
    prod        Production environment
    test        Test environment
    dr          Disaster Recovery environment

OPTIONS:
    --validate-only     Only validate the template without deploying
    --what-if          Run what-if analysis without deploying
    -h, --help         Show this help message

EXAMPLES:
    $0 prod                    # Deploy to production
    $0 test --validate-only    # Validate test environment
    $0 dr --what-if            # Run what-if for DR environment

PREREQUISITES:
    - Azure CLI installed and configured
    - Logged in to Azure (az login)
    - Appropriate permissions on target management group
    - Parameter files configured in parameters/ directory

EOF
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

main() {
    # Parse arguments
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi

    local environment=$1
    local validate_only=false
    local what_if=false

    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --validate-only)
                validate_only=true
                shift
                ;;
            --what-if)
                what_if=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    print_header "Azure Enterprise Landing Zone Deployment"
    print_info "Environment: $environment"
    print_info "Timestamp: $(date)"

    # Run checks
    check_prerequisites
    validate_environment "$environment"
    validate_bicep

    # Execute based on options
    if [[ "$validate_only" == true ]]; then
        print_success "Validation completed successfully"
        exit 0
    elif [[ "$what_if" == true ]]; then
        what_if_deployment "$environment"
        exit 0
    else
        deploy_infrastructure "$environment"
    fi

    print_header "Deployment Complete"
    print_success "Azure Landing Zone has been deployed successfully!"
}

# Run main function
main "$@"

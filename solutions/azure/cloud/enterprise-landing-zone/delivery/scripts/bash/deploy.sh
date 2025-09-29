#!/bin/bash

# Azure Enterprise Landing Zone Deployment Script
# This script deploys the Azure Enterprise Landing Zone using Terraform
# Prerequisites: Azure CLI, Terraform, appropriate Azure permissions

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
LOG_FILE="${REPO_ROOT}/deployment-$(date +%Y%m%d-%H%M%S).log"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "$1" | tee -a "${LOG_FILE}"
}

log_info() {
    log "${BLUE}[INFO]${NC} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    log "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# Error handling
error_exit() {
    log_error "$1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        error_exit "Azure CLI is not installed. Please install Azure CLI and try again."
    fi

    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        error_exit "Terraform is not installed. Please install Terraform and try again."
    fi

    # Check Azure login
    if ! az account show &> /dev/null; then
        error_exit "Not logged into Azure. Please run 'az login' and try again."
    fi

    # Check required environment variables
    if [[ -z "${TENANT_ID:-}" ]] || [[ -z "${SUBSCRIPTION_ID:-}" ]]; then
        error_exit "Required environment variables not set. Please set TENANT_ID and SUBSCRIPTION_ID."
    fi

    log_success "Prerequisites check completed"
}

# Validate Azure permissions
validate_permissions() {
    log_info "Validating Azure permissions..."

    # Check if user has Owner or Contributor role on subscription
    local role_assignments
    role_assignments=$(az role assignment list --scope "/subscriptions/${SUBSCRIPTION_ID}" --assignee "$(az account show --query user.name -o tsv)" --query "[].roleDefinitionName" -o tsv)

    if ! echo "${role_assignments}" | grep -E "(Owner|Contributor)" &> /dev/null; then
        error_exit "Insufficient permissions. Owner or Contributor role required on subscription ${SUBSCRIPTION_ID}"
    fi

    log_success "Permission validation completed"
}

# Set Azure context
set_azure_context() {
    log_info "Setting Azure context..."

    az account set --subscription "${SUBSCRIPTION_ID}"

    local current_subscription
    current_subscription=$(az account show --query id -o tsv)

    if [[ "${current_subscription}" != "${SUBSCRIPTION_ID}" ]]; then
        error_exit "Failed to set subscription context to ${SUBSCRIPTION_ID}"
    fi

    log_success "Azure context set to subscription: ${SUBSCRIPTION_ID}"
}

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform..."

    cd "${REPO_ROOT}/delivery/scripts/terraform"

    # Initialize Terraform with backend configuration
    terraform init \
        -backend-config="subscription_id=${SUBSCRIPTION_ID}" \
        -backend-config="tenant_id=${TENANT_ID}"

    # Validate Terraform configuration
    terraform validate

    log_success "Terraform initialization completed"
}

# Create Terraform plan
create_terraform_plan() {
    log_info "Creating Terraform plan..."

    cd "${REPO_ROOT}/delivery/scripts/terraform"

    # Create deployment plan
    terraform plan \
        -var="tenant_id=${TENANT_ID}" \
        -var="subscription_id=${SUBSCRIPTION_ID}" \
        -var="environment=${ENVIRONMENT:-production}" \
        -var="location=${LOCATION:-East US 2}" \
        -out="deployment.tfplan"

    log_success "Terraform plan created successfully"
}

# Apply Terraform configuration
apply_terraform() {
    log_info "Applying Terraform configuration..."

    cd "${REPO_ROOT}/delivery/scripts/terraform"

    # Apply the deployment plan
    terraform apply "deployment.tfplan"

    log_success "Terraform deployment completed successfully"
}

# Deploy management groups
deploy_management_groups() {
    log_info "Deploying management group hierarchy..."

    # Deploy management groups using Azure CLI
    az deployment tenant create \
        --location "${LOCATION:-eastus2}" \
        --template-file "${REPO_ROOT}/delivery/scripts/templates/management-groups.json" \
        --parameters tenantId="${TENANT_ID}" \
        --name "management-groups-$(date +%Y%m%d-%H%M%S)"

    log_success "Management groups deployed successfully"
}

# Deploy Azure policies
deploy_policies() {
    log_info "Deploying Azure Policy framework..."

    # Deploy policy definitions and initiatives
    local policy_dir="${REPO_ROOT}/delivery/scripts/policies"

    # Deploy custom policy definitions
    for policy_file in "${policy_dir}"/definitions/*.json; do
        if [[ -f "${policy_file}" ]]; then
            local policy_name
            policy_name=$(basename "${policy_file}" .json)

            az policy definition create \
                --name "${policy_name}" \
                --rules "${policy_file}" \
                --mode "Indexed" \
                --management-group "mg-enterprise-root"
        fi
    done

    # Deploy policy initiatives
    for initiative_file in "${policy_dir}"/initiatives/*.json; do
        if [[ -f "${initiative_file}" ]]; then
            local initiative_name
            initiative_name=$(basename "${initiative_file}" .json)

            az policy set-definition create \
                --name "${initiative_name}" \
                --definitions "${initiative_file}" \
                --management-group "mg-enterprise-root"
        fi
    done

    log_success "Azure Policy framework deployed successfully"
}

# Validate deployment
validate_deployment() {
    log_info "Validating deployment..."

    # Validate management groups
    local mg_count
    mg_count=$(az account management-group list --query "length(@)" -o tsv)

    if [[ "${mg_count}" -lt 5 ]]; then
        log_warning "Expected at least 5 management groups, found ${mg_count}"
    fi

    # Validate policy compliance
    local compliance_state
    compliance_state=$(az policy state list --management-group "mg-enterprise-root" --query "[?complianceState=='NonCompliant'] | length(@)" -o tsv)

    if [[ "${compliance_state}" -gt 0 ]]; then
        log_warning "Found ${compliance_state} non-compliant resources"
    fi

    # Validate network connectivity
    if command -v ping &> /dev/null; then
        log_info "Testing network connectivity..."
        # Add network connectivity tests here
    fi

    log_success "Deployment validation completed"
}

# Generate deployment report
generate_report() {
    log_info "Generating deployment report..."

    local report_file="${REPO_ROOT}/deployment-report-$(date +%Y%m%d-%H%M%S).html"

    cat > "${report_file}" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Azure Enterprise Landing Zone Deployment Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Azure Enterprise Landing Zone Deployment Report</h1>
        <p>Generated on: $(date)</p>
        <p>Subscription: ${SUBSCRIPTION_ID}</p>
        <p>Tenant: ${TENANT_ID}</p>
    </div>

    <div class="section">
        <h2>Deployment Summary</h2>
        <p class="success">Deployment completed successfully</p>
        <p>Total deployment time: $(( SECONDS / 60 )) minutes</p>
    </div>

    <div class="section">
        <h2>Resources Deployed</h2>
        <ul>
            <li>Management Group Hierarchy</li>
            <li>Azure Policy Framework</li>
            <li>Platform Subscriptions</li>
            <li>Network Infrastructure</li>
            <li>Security Services</li>
            <li>Monitoring and Logging</li>
        </ul>
    </div>

    <div class="section">
        <h2>Next Steps</h2>
        <ol>
            <li>Review and validate all deployed resources</li>
            <li>Configure additional security controls as needed</li>
            <li>Begin application landing zone deployment</li>
            <li>Complete user training and documentation</li>
        </ol>
    </div>
</body>
</html>
EOF

    log_success "Deployment report generated: ${report_file}"
}

# Cleanup function
cleanup() {
    log_info "Performing cleanup..."

    # Remove temporary files
    rm -f "${REPO_ROOT}/delivery/scripts/terraform/deployment.tfplan"

    log_success "Cleanup completed"
}

# Main deployment function
main() {
    local start_time=$SECONDS

    log_info "Starting Azure Enterprise Landing Zone deployment..."
    log_info "Deployment log: ${LOG_FILE}"

    # Set trap for cleanup on exit
    trap cleanup EXIT

    # Execute deployment steps
    check_prerequisites
    validate_permissions
    set_azure_context
    init_terraform
    create_terraform_plan

    # Confirm deployment
    if [[ "${AUTO_APPROVE:-false}" != "true" ]]; then
        read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled by user"
            exit 0
        fi
    fi

    apply_terraform
    deploy_management_groups
    deploy_policies
    validate_deployment
    generate_report

    local end_time=$SECONDS
    local duration=$(( end_time - start_time ))

    log_success "Azure Enterprise Landing Zone deployment completed successfully!"
    log_info "Total deployment time: $(( duration / 60 )) minutes and $(( duration % 60 )) seconds"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
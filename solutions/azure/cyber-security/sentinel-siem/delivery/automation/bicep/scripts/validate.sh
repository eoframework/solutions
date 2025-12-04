#!/bin/bash
################################################################################
# Microsoft Sentinel SIEM - Bicep Validation Script
################################################################################
# Description: Validates Bicep templates and parameters
# Version: 1.0.0
# Usage: ./validate.sh [environment]
# Example: ./validate.sh prod
################################################################################

set -e  # Exit on error
set -o pipefail  # Exit on pipe failure

################################################################################
# VARIABLES
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_DIR="$(dirname "$SCRIPT_DIR")"
ENVIRONMENT="${1:-prod}"

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
    echo "#              Microsoft Sentinel SIEM - Bicep Validation                     #"
    echo "################################################################################"
    echo ""
    echo "Environment: ${ENVIRONMENT}"
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

    log_success "Prerequisites check passed"
}

validate_environment() {
    log_info "Validating environment parameter..."

    if [[ ! "${ENVIRONMENT}" =~ ^(prod|test|dr|all)$ ]]; then
        log_error "Invalid environment: ${ENVIRONMENT}"
        log_error "Valid environments are: prod, test, dr, all"
        exit 1
    fi

    log_success "Environment parameter is valid"
}

validate_bicep_syntax() {
    log_info "Validating Bicep syntax..."

    MAIN_BICEP="${BICEP_DIR}/main.bicep"
    MODULES_DIR="${BICEP_DIR}/modules"

    # Validate main bicep file
    log_info "Building main.bicep..."
    if az bicep build --file "${MAIN_BICEP}" --stdout > /dev/null; then
        log_success "main.bicep syntax is valid"
    else
        log_error "main.bicep syntax validation failed"
        return 1
    fi

    # Validate all module files
    log_info "Validating module files..."
    local modules_valid=true

    for module_file in "${MODULES_DIR}"/*.bicep; do
        if [[ -f "${module_file}" ]]; then
            module_name=$(basename "${module_file}")
            log_info "Building ${module_name}..."

            if az bicep build --file "${module_file}" --stdout > /dev/null; then
                log_success "${module_name} syntax is valid"
            else
                log_error "${module_name} syntax validation failed"
                modules_valid=false
            fi
        fi
    done

    if [[ "${modules_valid}" == "true" ]]; then
        log_success "All Bicep module syntax validation passed"
        return 0
    else
        log_error "Some Bicep modules failed syntax validation"
        return 1
    fi
}

validate_parameters() {
    local env=$1
    log_info "Validating parameters for environment: ${env}..."

    PARAM_FILE="${BICEP_DIR}/parameters/${env}.parameters.json"

    if [[ ! -f "${PARAM_FILE}" ]]; then
        log_error "Parameter file not found: ${PARAM_FILE}"
        return 1
    fi

    # Check if parameter file is valid JSON
    if jq empty "${PARAM_FILE}" 2>/dev/null; then
        log_success "Parameter file JSON syntax is valid: ${env}"
    else
        log_error "Parameter file JSON syntax is invalid: ${env}"
        return 1
    fi

    # Validate required parameters exist
    log_info "Checking required parameters..."

    local required_params=(
        "environment"
        "location"
        "logAnalyticsWorkspaceName"
        "alertEmail"
        "socAdGroupId"
        "socAdminGroupId"
    )

    local params_valid=true
    for param in "${required_params[@]}"; do
        if jq -e ".parameters.${param}" "${PARAM_FILE}" > /dev/null 2>&1; then
            log_success "Required parameter found: ${param}"
        else
            log_error "Missing required parameter: ${param}"
            params_valid=false
        fi
    done

    if [[ "${params_valid}" == "true" ]]; then
        log_success "All required parameters are present for: ${env}"
        return 0
    else
        log_error "Some required parameters are missing for: ${env}"
        return 1
    fi
}

validate_deployment() {
    local env=$1
    log_info "Validating deployment template for environment: ${env}..."

    MAIN_BICEP="${BICEP_DIR}/main.bicep"
    PARAM_FILE="${BICEP_DIR}/parameters/${env}.parameters.json"

    # Skip Azure validation if not logged in
    if ! az account show &> /dev/null; then
        log_warning "Not logged in to Azure. Skipping deployment validation."
        log_info "Run 'az login' to enable full deployment validation."
        return 0
    fi

    log_info "Running Azure deployment validation..."
    if az deployment sub validate \
        --location eastus \
        --template-file "${MAIN_BICEP}" \
        --parameters "${PARAM_FILE}" \
        --output json > /dev/null 2>&1; then
        log_success "Deployment validation passed for: ${env}"
        return 0
    else
        log_error "Deployment validation failed for: ${env}"
        log_info "Run deployment validation manually for detailed errors:"
        log_info "az deployment sub validate --location eastus --template-file ${MAIN_BICEP} --parameters ${PARAM_FILE}"
        return 1
    fi
}

validate_single_environment() {
    local env=$1
    local validation_passed=true

    echo ""
    log_info "========================================"
    log_info "Validating Environment: ${env}"
    log_info "========================================"
    echo ""

    if ! validate_parameters "${env}"; then
        validation_passed=false
    fi

    if ! validate_deployment "${env}"; then
        validation_passed=false
    fi

    if [[ "${validation_passed}" == "true" ]]; then
        log_success "All validations passed for environment: ${env}"
        return 0
    else
        log_error "Some validations failed for environment: ${env}"
        return 1
    fi
}

print_summary() {
    local exit_code=$1

    echo ""
    echo "################################################################################"
    echo "#                        Validation Summary                                   #"
    echo "################################################################################"
    echo ""

    if [[ ${exit_code} -eq 0 ]]; then
        echo -e "Status: ${GREEN}ALL VALIDATIONS PASSED${NC}"
        echo ""
        echo "The Bicep templates and parameters are ready for deployment."
        echo ""
        echo "To deploy, run:"
        echo "  ./deploy.sh ${ENVIRONMENT} [subscription-id]"
    else
        echo -e "Status: ${RED}VALIDATION FAILED${NC}"
        echo ""
        echo "Please fix the errors above before attempting deployment."
        echo ""
        echo "Common issues:"
        echo "  - Missing or invalid parameters in parameter files"
        echo "  - Bicep syntax errors in templates or modules"
        echo "  - Invalid resource configurations"
        echo "  - Not logged in to Azure (run 'az login')"
    fi

    echo ""
    echo "################################################################################"
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    local exit_code=0

    print_banner
    check_prerequisites
    validate_environment

    # Validate Bicep syntax first
    if ! validate_bicep_syntax; then
        exit_code=1
        print_summary ${exit_code}
        exit ${exit_code}
    fi

    # Validate environments
    if [[ "${ENVIRONMENT}" == "all" ]]; then
        log_info "Validating all environments..."

        for env in prod test dr; do
            if ! validate_single_environment "${env}"; then
                exit_code=1
            fi
        done
    else
        if ! validate_single_environment "${ENVIRONMENT}"; then
            exit_code=1
        fi
    fi

    print_summary ${exit_code}
    exit ${exit_code}
}

# Execute main function
main "$@"

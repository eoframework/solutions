#!/bin/bash

################################################################################
# Azure Enterprise Landing Zone - Validation Script
################################################################################
# Description: Validates Bicep templates and parameter files for all environments
# Usage: ./validate.sh [environment]
################################################################################

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_DIR="$(dirname "$SCRIPT_DIR")"
PARAMETERS_DIR="$BICEP_DIR/parameters"
MODULES_DIR="$BICEP_DIR/modules"
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

check_bicep_cli() {
    print_header "Checking Bicep CLI"

    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed"
        return 1
    fi

    # Get Bicep version
    local bicep_version=$(az bicep version 2>/dev/null || echo "Not installed")
    if [[ "$bicep_version" == "Not installed" ]]; then
        print_warning "Bicep CLI not found. Installing..."
        az bicep install
        bicep_version=$(az bicep version)
    fi

    print_success "Bicep CLI version: $bicep_version"
}

validate_json_syntax() {
    local file=$1
    print_info "Validating JSON syntax: $(basename "$file")"

    if jq empty "$file" 2>/dev/null; then
        print_success "JSON syntax is valid"
        return 0
    else
        print_error "Invalid JSON syntax in $file"
        return 1
    fi
}

validate_parameter_file() {
    local env=$1
    local param_file="$PARAMETERS_DIR/${env}.parameters.json"

    print_header "Validating Parameter File: $env"

    if [[ ! -f "$param_file" ]]; then
        print_error "Parameter file not found: $param_file"
        return 1
    fi

    # Validate JSON syntax
    if ! validate_json_syntax "$param_file"; then
        return 1
    fi

    # Check required parameters
    local required_params=(
        "environment"
        "subscriptionIdConnectivity"
        "subscriptionIdIdentity"
        "subscriptionIdManagement"
        "managementGroupRoot"
        "primaryRegion"
        "azureAdAdminGroup"
        "alertEmail"
    )

    local missing_params=0
    for param in "${required_params[@]}"; do
        if ! jq -e ".parameters.$param" "$param_file" > /dev/null 2>&1; then
            print_error "Missing required parameter: $param"
            missing_params=$((missing_params + 1))
        fi
    done

    if [[ $missing_params -gt 0 ]]; then
        print_error "Found $missing_params missing parameters"
        return 1
    fi

    # Check for placeholder values
    local placeholder_count=$(grep -o "REPLACE_WITH_" "$param_file" | wc -l)
    if [[ $placeholder_count -gt 0 ]]; then
        print_warning "Found $placeholder_count placeholder values that need to be replaced"
    fi

    print_success "Parameter file validation passed"
    return 0
}

validate_bicep_template() {
    local template=$1
    local template_name=$(basename "$template")

    print_info "Validating Bicep template: $template_name"

    # Build the template
    if az bicep build --file "$template" --stdout > /dev/null 2>&1; then
        print_success "Template build successful: $template_name"
        return 0
    else
        print_error "Template build failed: $template_name"
        az bicep build --file "$template" 2>&1 | tail -20
        return 1
    fi
}

validate_all_modules() {
    print_header "Validating All Module Templates"

    local total_modules=0
    local failed_modules=0

    # Find all .bicep files in modules directory
    while IFS= read -r -d '' template; do
        total_modules=$((total_modules + 1))
        if ! validate_bicep_template "$template"; then
            failed_modules=$((failed_modules + 1))
        fi
    done < <(find "$MODULES_DIR" -name "*.bicep" -type f -print0)

    if [[ $failed_modules -eq 0 ]]; then
        print_success "All $total_modules module templates are valid"
        return 0
    else
        print_error "$failed_modules out of $total_modules module templates failed validation"
        return 1
    fi
}

validate_main_template() {
    print_header "Validating Main Orchestration Template"

    if validate_bicep_template "$MAIN_TEMPLATE"; then
        print_success "Main template validation passed"
        return 0
    else
        print_error "Main template validation failed"
        return 1
    fi
}

lint_bicep_files() {
    print_header "Running Bicep Linter"

    local lint_errors=0

    # Lint main template
    print_info "Linting main.bicep..."
    if az bicep build --file "$MAIN_TEMPLATE" 2>&1 | grep -i "warning\|error"; then
        lint_errors=$((lint_errors + 1))
    fi

    # Lint all modules
    while IFS= read -r -d '' template; do
        local template_name=$(basename "$template")
        print_info "Linting $template_name..."
        if az bicep build --file "$template" 2>&1 | grep -i "warning\|error"; then
            lint_errors=$((lint_errors + 1))
        fi
    done < <(find "$MODULES_DIR" -name "*.bicep" -type f -print0)

    if [[ $lint_errors -eq 0 ]]; then
        print_success "Linting completed with no issues"
        return 0
    else
        print_warning "Linting completed with $lint_errors warnings/errors"
        return 0
    fi
}

check_naming_conventions() {
    print_header "Checking Naming Conventions"

    local naming_issues=0

    # Check resource naming patterns
    print_info "Checking resource naming patterns..."

    # List of expected naming patterns
    local patterns=(
        "rg-.*-.*-.*:Resource Groups"
        "vnet-.*-.*-.*:Virtual Networks"
        "kv-.*-.*-.*:Key Vaults"
        "log-.*-.*-.*:Log Analytics"
        "afw-.*-.*:Azure Firewall"
        "bas-.*-.*:Bastion Hosts"
    )

    for pattern_def in "${patterns[@]}"; do
        IFS=':' read -r pattern desc <<< "$pattern_def"
        print_info "Checking $desc naming..."
    done

    if [[ $naming_issues -eq 0 ]]; then
        print_success "Naming conventions check passed"
    else
        print_warning "Found $naming_issues potential naming issues"
    fi
}

generate_validation_report() {
    print_header "Validation Summary Report"

    echo "Validation Date: $(date)"
    echo "Bicep Directory: $BICEP_DIR"
    echo ""
    echo "Files Validated:"
    echo "  - Main Template: $MAIN_TEMPLATE"
    echo "  - Modules: $(find "$MODULES_DIR" -name "*.bicep" -type f | wc -l) files"
    echo "  - Parameter Files: $(find "$PARAMETERS_DIR" -name "*.json" -type f | wc -l) files"
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [environment]

Validate Azure Enterprise Landing Zone Bicep templates

ARGUMENTS:
    environment     Optional. Validate specific environment (prod, test, dr)
                   If not specified, validates all environments

OPTIONS:
    -h, --help     Show this help message

EXAMPLES:
    $0              # Validate all environments
    $0 prod         # Validate production only
    $0 test         # Validate test only

VALIDATIONS PERFORMED:
    - Bicep template syntax and compilation
    - JSON parameter file syntax
    - Required parameter presence
    - Naming conventions
    - Linting checks

EOF
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

main() {
    local environment="${1:-all}"
    local validation_failed=0

    if [[ "$environment" == "-h" ]] || [[ "$environment" == "--help" ]]; then
        show_usage
        exit 0
    fi

    print_header "Azure Enterprise Landing Zone - Template Validation"
    print_info "Starting validation at $(date)"

    # Check prerequisites
    if ! check_bicep_cli; then
        print_error "Bicep CLI check failed"
        exit 1
    fi

    # Validate main template
    if ! validate_main_template; then
        validation_failed=1
    fi

    # Validate all modules
    if ! validate_all_modules; then
        validation_failed=1
    fi

    # Validate parameter files
    if [[ "$environment" == "all" ]]; then
        for env in prod test dr; do
            if ! validate_parameter_file "$env"; then
                validation_failed=1
            fi
        done
    else
        if ! validate_parameter_file "$environment"; then
            validation_failed=1
        fi
    fi

    # Run linter
    lint_bicep_files

    # Check naming conventions
    check_naming_conventions

    # Generate report
    generate_validation_report

    # Final result
    print_header "Validation Complete"
    if [[ $validation_failed -eq 0 ]]; then
        print_success "All validations passed successfully!"
        exit 0
    else
        print_error "Some validations failed. Please review the errors above."
        exit 1
    fi
}

# Run main function
main "$@"

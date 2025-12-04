#!/bin/bash
#------------------------------------------------------------------------------
# Dell VxRail HCI - Validation Script
# EO Framework - Dell Cloud Solutions
#
# Usage: ./validate.sh <environment>
#        ./validate.sh production
#        ./validate.sh test
#------------------------------------------------------------------------------

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------
log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

log_section() {
    echo -e "${BLUE}[====]${NC} $*"
}

usage() {
    cat << EOF
Usage: $(basename "$0") <environment>

Arguments:
    environment    Target environment (production|test|dr)

Examples:
    $(basename "$0") production    # Validate production environment
    $(basename "$0") test          # Validate test environment
    $(basename "$0") dr            # Validate DR environment

This script runs comprehensive validation checks on the VxRail HCI deployment
including VxRail Manager, ESXi hosts, vCenter, vSAN, and networking.
EOF
    exit 1
}

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check Ansible
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "ansible-playbook not found. Please install Ansible."
        exit 1
    fi

    # Check inventory exists
    if [ ! -d "$ANSIBLE_DIR/inventory/$ENVIRONMENT" ]; then
        log_error "Inventory not found: $ANSIBLE_DIR/inventory/$ENVIRONMENT"
        exit 1
    fi

    # Check validate playbook exists
    if [ ! -f "$ANSIBLE_DIR/playbooks/validate.yml" ]; then
        log_error "Validation playbook not found: $ANSIBLE_DIR/playbooks/validate.yml"
        exit 1
    fi

    log_info "Prerequisites check passed"
}

run_validation() {
    log_info "Starting validation..."
    log_info "Environment: $ENVIRONMENT"

    cd "$ANSIBLE_DIR"

    # Build ansible-playbook command
    CMD="ansible-playbook"
    CMD="$CMD -i inventory/$ENVIRONMENT"
    CMD="$CMD playbooks/validate.yml"
    CMD="$CMD -v"

    log_info "Running: $CMD"
    echo ""

    # Execute
    eval $CMD

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log_info "Validation completed successfully"
        return 0
    else
        log_error "Validation failed with exit code: $exit_code"
        return $exit_code
    fi
}

display_summary() {
    local exit_code=$1

    echo ""
    echo "================================================================"
    if [ $exit_code -eq 0 ]; then
        log_section "Validation Summary: ${GREEN}PASSED${NC}"
        echo ""
        echo "All validation checks completed successfully."
        echo "VxRail HCI environment is healthy and operational."
    else
        log_section "Validation Summary: ${RED}FAILED${NC}"
        echo ""
        echo "One or more validation checks failed."
        echo "Please review the output above for details."
    fi
    echo "================================================================"
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

# Parse arguments
if [ $# -lt 1 ]; then
    usage
fi

ENVIRONMENT="$1"

# Validate environment
case "$ENVIRONMENT" in
    production|test|dr) ;;
    *) log_error "Invalid environment: $ENVIRONMENT"; usage ;;
esac

# Run validation
echo ""
echo "================================================================"
echo "  Dell VxRail HCI Validation"
echo "  Environment: $ENVIRONMENT"
echo "================================================================"
echo ""

check_prerequisites

# Run validation and capture exit code
set +e
run_validation
VALIDATION_EXIT_CODE=$?
set -e

# Display summary
display_summary $VALIDATION_EXIT_CODE

exit $VALIDATION_EXIT_CODE

#!/bin/bash
#------------------------------------------------------------------------------
# Dell PowerSwitch Datacenter - Deployment Script
# EO Framework - Dell Network Solutions
#
# Usage: ./deploy.sh <environment> [playbook] [options]
#        ./deploy.sh production              # Full deployment
#        ./deploy.sh test spine-config.yml   # Deploy spine only in test
#        ./deploy.sh production --check      # Dry run
#------------------------------------------------------------------------------

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

usage() {
    cat << EOF
Usage: $(basename "$0") <environment> [playbook] [ansible-options]

Arguments:
    environment    Target environment (production|test|dr)
    playbook       Optional playbook name (default: site.yml)
    options        Additional ansible-playbook options

Examples:
    $(basename "$0") production                    # Full production deployment
    $(basename "$0") test                          # Full test deployment
    $(basename "$0") production spine-config.yml   # Deploy spine switches only
    $(basename "$0") production --check            # Dry run
    $(basename "$0") production --tags bgp         # Deploy BGP only
    $(basename "$0") production --limit spine-01   # Single switch

Available Playbooks:
    site.yml              Master orchestration (default)
    base-config.yml       Base switch configuration
    spine-config.yml      Spine switch configuration
    leaf-config.yml       Leaf switch configuration
    vlan-config.yml       VLAN configuration
    bgp-config.yml        BGP underlay
    vxlan-config.yml      VXLAN overlay
    monitoring-config.yml Monitoring setup
    validate.yml          Post-deployment validation
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

    # Check ansible-galaxy
    if ! command -v ansible-galaxy &> /dev/null; then
        log_error "ansible-galaxy not found. Please install Ansible."
        exit 1
    fi

    # Check inventory exists
    if [ ! -d "$ANSIBLE_DIR/inventory/$ENVIRONMENT" ]; then
        log_error "Inventory not found: $ANSIBLE_DIR/inventory/$ENVIRONMENT"
        exit 1
    fi

    # Check playbook exists
    if [ ! -f "$ANSIBLE_DIR/playbooks/$PLAYBOOK" ]; then
        log_error "Playbook not found: $ANSIBLE_DIR/playbooks/$PLAYBOOK"
        exit 1
    fi

    log_info "Prerequisites check passed"
}

install_collections() {
    log_info "Installing Ansible collections..."
    cd "$ANSIBLE_DIR"
    ansible-galaxy collection install -r requirements.yml --force
    log_info "Collections installed"
}

run_deployment() {
    log_info "Starting deployment..."
    log_info "Environment: $ENVIRONMENT"
    log_info "Playbook: $PLAYBOOK"

    cd "$ANSIBLE_DIR"

    # Build ansible-playbook command
    CMD="ansible-playbook"
    CMD="$CMD -i inventory/$ENVIRONMENT"
    CMD="$CMD playbooks/$PLAYBOOK"
    CMD="$CMD $EXTRA_ARGS"

    log_info "Running: $CMD"
    echo ""

    # Execute
    eval $CMD

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        log_info "Deployment completed successfully"
    else
        log_error "Deployment failed with exit code: $exit_code"
        exit $exit_code
    fi
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

# Parse arguments
if [ $# -lt 1 ]; then
    usage
fi

ENVIRONMENT="$1"
shift

# Validate environment
case "$ENVIRONMENT" in
    production|test|dr) ;;
    *) log_error "Invalid environment: $ENVIRONMENT"; usage ;;
esac

# Check if second arg is a playbook or ansible option
PLAYBOOK="site.yml"
EXTRA_ARGS=""

if [ $# -gt 0 ]; then
    if [[ "$1" == *.yml ]]; then
        PLAYBOOK="$1"
        shift
    fi
fi

# Remaining args are ansible options
EXTRA_ARGS="$*"

# Run deployment
echo ""
echo "================================================================"
echo "  Dell PowerSwitch Datacenter Deployment"
echo "  Environment: $ENVIRONMENT"
echo "  Playbook: $PLAYBOOK"
echo "================================================================"
echo ""

check_prerequisites
install_collections
run_deployment

echo ""
echo "================================================================"
echo "  Deployment Complete"
echo "================================================================"

#!/bin/bash
#------------------------------------------------------------------------------
# run-playbook.sh - Ansible playbook runner for SRX automation
# Usage: ./run-playbook.sh <environment> [playbook] [options]
#------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}/../../ansible"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat << EOF
Usage: $(basename "$0") <environment> [playbook] [options]

Arguments:
    environment    Target environment (prod|test|dr)
    playbook       Playbook to run (default: site.yml)

Options:
    --check        Dry run mode (no changes)
    --diff         Show differences
    --tags TAGS    Run only specific tags
    --limit HOST   Limit to specific hosts
    --verbose      Verbose output (-vvv)
    --help         Show this help

Examples:
    $(basename "$0") prod
    $(basename "$0") test site.yml --check
    $(basename "$0") prod security-policies.yml --tags security
    $(basename "$0") dr backup.yml --limit srx-dr-node0

EOF
    exit 1
}

check_prerequisites() {
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "ansible-playbook not found. Install with: pip install ansible"
        exit 1
    fi

    if ! command -v ansible-galaxy &> /dev/null; then
        log_error "ansible-galaxy not found"
        exit 1
    fi
}

install_collections() {
    log_info "Checking Ansible collections..."
    cd "${ANSIBLE_DIR}"

    if [ -f requirements.yml ]; then
        ansible-galaxy collection install -r requirements.yml --force-with-deps 2>/dev/null || true
    fi
}

# Parse arguments
ENVIRONMENT=""
PLAYBOOK="site.yml"
EXTRA_ARGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        prod|test|dr)
            ENVIRONMENT="$1"
            shift
            ;;
        *.yml)
            PLAYBOOK="$1"
            shift
            ;;
        --check)
            EXTRA_ARGS="${EXTRA_ARGS} --check"
            shift
            ;;
        --diff)
            EXTRA_ARGS="${EXTRA_ARGS} --diff"
            shift
            ;;
        --tags)
            EXTRA_ARGS="${EXTRA_ARGS} --tags $2"
            shift 2
            ;;
        --limit)
            EXTRA_ARGS="${EXTRA_ARGS} --limit $2"
            shift 2
            ;;
        --verbose)
            EXTRA_ARGS="${EXTRA_ARGS} -vvv"
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            EXTRA_ARGS="${EXTRA_ARGS} $1"
            shift
            ;;
    esac
done

if [ -z "$ENVIRONMENT" ]; then
    log_error "Environment required"
    usage
fi

# Main execution
check_prerequisites
install_collections

INVENTORY="${ANSIBLE_DIR}/inventory/${ENVIRONMENT}"
PLAYBOOK_PATH="${ANSIBLE_DIR}/playbooks/${PLAYBOOK}"

if [ ! -d "$INVENTORY" ]; then
    log_error "Inventory not found: $INVENTORY"
    exit 1
fi

if [ ! -f "$PLAYBOOK_PATH" ]; then
    log_error "Playbook not found: $PLAYBOOK_PATH"
    exit 1
fi

log_info "Running playbook: $PLAYBOOK"
log_info "Environment: $ENVIRONMENT"
log_info "Inventory: $INVENTORY"

cd "${ANSIBLE_DIR}"

# Check for vault password
VAULT_ARGS=""
if [ -f vars/secrets.yml ]; then
    if [ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ]; then
        VAULT_ARGS="--vault-password-file ${ANSIBLE_VAULT_PASSWORD_FILE}"
    else
        VAULT_ARGS="--ask-vault-pass"
    fi
fi

# Run playbook
ansible-playbook \
    -i "${INVENTORY}" \
    "${PLAYBOOK_PATH}" \
    ${VAULT_ARGS} \
    ${EXTRA_ARGS}

log_info "Playbook completed"

#!/bin/bash
#------------------------------------------------------------------------------
# run-playbook.sh - Ansible playbook runner for Mist automation
#------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}/../../ansible"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
    cat << EOF
Usage: $(basename "$0") <environment> [playbook] [options]

Arguments:
    environment    Target environment (prod|test|dr)
    playbook       Playbook to run (default: site.yml)

Options:
    --check        Dry run mode
    --tags TAGS    Run specific tags
    --help         Show help

Examples:
    $(basename "$0") prod
    $(basename "$0") test mist-site-setup.yml --tags wlans
EOF
    exit 1
}

ENVIRONMENT=""
PLAYBOOK="site.yml"
EXTRA_ARGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        prod|test|dr) ENVIRONMENT="$1"; shift ;;
        *.yml) PLAYBOOK="$1"; shift ;;
        --check) EXTRA_ARGS="${EXTRA_ARGS} --check"; shift ;;
        --tags) EXTRA_ARGS="${EXTRA_ARGS} --tags $2"; shift 2 ;;
        --help|-h) usage ;;
        *) EXTRA_ARGS="${EXTRA_ARGS} $1"; shift ;;
    esac
done

[ -z "$ENVIRONMENT" ] && { log_error "Environment required"; usage; }

INVENTORY="${ANSIBLE_DIR}/inventory/${ENVIRONMENT}"
PLAYBOOK_PATH="${ANSIBLE_DIR}/playbooks/${PLAYBOOK}"

[ ! -d "$INVENTORY" ] && { log_error "Inventory not found: $INVENTORY"; exit 1; }
[ ! -f "$PLAYBOOK_PATH" ] && { log_error "Playbook not found: $PLAYBOOK_PATH"; exit 1; }

log_info "Running: $PLAYBOOK for $ENVIRONMENT"

cd "${ANSIBLE_DIR}"

VAULT_ARGS=""
[ -f vars/secrets.yml ] && VAULT_ARGS="--ask-vault-pass"

ansible-playbook -i "${INVENTORY}" "${PLAYBOOK_PATH}" ${VAULT_ARGS} ${EXTRA_ARGS}

log_info "Complete"

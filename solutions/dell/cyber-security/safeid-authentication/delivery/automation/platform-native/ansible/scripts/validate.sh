#!/bin/bash
#------------------------------------------------------------------------------
# Dell SafeID Authentication - Validation Script
# EO Framework - Dell Cyber Security Solutions
#
# Usage: ./validate.sh <environment>
#------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $*" >&2
}

usage() {
    cat << EOF
Usage: $(basename "$0") <environment>

Arguments:
    environment    Target environment (production|test|dr)

Examples:
    $(basename "$0") production
    $(basename "$0") test
EOF
    exit 1
}

# Parse arguments
if [ $# -lt 1 ]; then
    usage
fi

ENVIRONMENT="$1"

case "$ENVIRONMENT" in
    production|test|dr) ;;
    *) log_error "Invalid environment: $ENVIRONMENT"; usage ;;
esac

echo ""
echo "================================================================"
echo "  Dell SafeID Authentication Validation"
echo "  Environment: $ENVIRONMENT"
echo "================================================================"
echo ""

log_info "Running validation playbook..."

cd "$ANSIBLE_DIR"
ansible-playbook \
    -i "inventory/$ENVIRONMENT" \
    playbooks/validate.yml \
    --tags validate

echo ""
log_info "Validation complete. Review output above for any failures."

#!/bin/bash
#------------------------------------------------------------------------------
# health-check.sh - SRX health check script
# Validates connectivity and basic operations
#------------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="${SCRIPT_DIR}/../../ansible"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $*"; }

ENVIRONMENT="${1:-prod}"
INVENTORY="${ANSIBLE_DIR}/inventory/${ENVIRONMENT}"

if [ ! -d "$INVENTORY" ]; then
    log_error "Inventory not found: $INVENTORY"
    exit 1
fi

log_info "Running health checks for ${ENVIRONMENT} environment"
echo "========================================"

# Check 1: Ansible ping
log_info "Check 1: Ansible connectivity"
if ansible -i "${INVENTORY}" srx_firewalls -m ping 2>/dev/null | grep -q "SUCCESS"; then
    log_pass "Ansible ping successful"
else
    log_fail "Ansible ping failed"
fi

# Check 2: Device facts
log_info "Check 2: Device facts retrieval"
if ansible -i "${INVENTORY}" srx_firewalls -m junipernetworks.junos.junos_facts -a "gather_subset=default" 2>/dev/null | grep -q "ansible_net_hostname"; then
    log_pass "Device facts retrieved"
else
    log_fail "Device facts retrieval failed"
fi

# Check 3: NETCONF connectivity
log_info "Check 3: NETCONF connectivity"
if ansible -i "${INVENTORY}" srx_firewalls -m junipernetworks.junos.junos_command -a "commands='show version'" 2>/dev/null | grep -q "JUNOS"; then
    log_pass "NETCONF working"
else
    log_fail "NETCONF connectivity issues"
fi

echo "========================================"
log_info "Health check complete"

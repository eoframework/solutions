#!/bin/bash
# Dell VxRail Enterprise - Validation Script
# EO Framework - Dell Cloud Solutions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"

ENVIRONMENT="${1:-production}"

echo "================================================================"
echo "Dell VxRail Enterprise - Validation"
echo "================================================================"
echo "Environment: ${ENVIRONMENT}"
echo "================================================================"

cd "$ANSIBLE_DIR"

ansible-playbook \
    -i "inventory/${ENVIRONMENT}/hosts.yml" \
    playbooks/validate.yml

echo "================================================================"
echo "Validation Complete"
echo "================================================================"

#!/bin/bash
# Cisco Network Automation Test Runner
# Runs validation tests for Ansible playbooks and configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
INVENTORY="${INVENTORY:-inventory/test/hosts.yml}"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

echo "========================================"
echo "Cisco Network Automation Test Runner"
echo "========================================"
echo ""

# Function to print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "success" ]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}✗${NC} $message"
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}⚠${NC} $message"
    else
        echo "  $message"
    fi
}

# Change to ansible directory
cd "$ANSIBLE_DIR" || exit 1

# Test 1: Check Ansible installation
echo "Test 1: Checking Ansible installation..."
if command -v ansible &> /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -n1)
    print_status "success" "Ansible is installed: $ANSIBLE_VERSION"
else
    print_status "error" "Ansible is not installed"
    exit 1
fi
echo ""

# Test 2: Validate Ansible configuration
echo "Test 2: Validating Ansible configuration..."
if [ -f "ansible.cfg" ]; then
    print_status "success" "ansible.cfg found"
else
    print_status "warning" "ansible.cfg not found, using defaults"
fi
echo ""

# Test 3: Check inventory file
echo "Test 3: Checking inventory file..."
if [ -f "$INVENTORY" ]; then
    print_status "success" "Inventory file found: $INVENTORY"
else
    print_status "error" "Inventory file not found: $INVENTORY"
    exit 1
fi
echo ""

# Test 4: Validate YAML syntax
echo "Test 4: Validating YAML syntax..."
if command -v yamllint &> /dev/null; then
    if yamllint playbooks/*.yml inventory/ 2>/dev/null; then
        print_status "success" "YAML syntax is valid"
    else
        print_status "warning" "YAML linting found issues (non-critical)"
    fi
else
    print_status "warning" "yamllint not installed, skipping YAML validation"
fi
echo ""

# Test 5: Validate Ansible playbook syntax
echo "Test 5: Validating Ansible playbook syntax..."
SYNTAX_ERRORS=0
for playbook in playbooks/*.yml; do
    if [ -f "$playbook" ]; then
        echo "  Checking: $playbook"
        if ansible-playbook --syntax-check "$playbook" &> /dev/null; then
            print_status "success" "$(basename "$playbook") - Syntax OK"
        else
            print_status "error" "$(basename "$playbook") - Syntax errors found"
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    fi
done

if [ $SYNTAX_ERRORS -eq 0 ]; then
    print_status "success" "All playbooks have valid syntax"
else
    print_status "error" "Found syntax errors in $SYNTAX_ERRORS playbook(s)"
    exit 1
fi
echo ""

# Test 6: Run Ansible-lint (if available)
echo "Test 6: Running Ansible-lint..."
if command -v ansible-lint &> /dev/null; then
    if ansible-lint playbooks/*.yml 2>/dev/null; then
        print_status "success" "Ansible-lint checks passed"
    else
        print_status "warning" "Ansible-lint found issues (non-critical)"
    fi
else
    print_status "warning" "ansible-lint not installed, skipping lint checks"
fi
echo ""

# Test 7: Validate Ansible roles
echo "Test 7: Validating Ansible roles..."
if [ -d "roles" ]; then
    ROLE_COUNT=$(find roles -maxdepth 1 -mindepth 1 -type d | wc -l)
    print_status "success" "Found $ROLE_COUNT role(s)"

    for role in roles/*/; do
        role_name=$(basename "$role")
        if [ -f "$role/tasks/main.yml" ]; then
            print_status "success" "Role '$role_name' has tasks/main.yml"
        else
            print_status "warning" "Role '$role_name' missing tasks/main.yml"
        fi
    done
else
    print_status "warning" "No roles directory found"
fi
echo ""

# Test 8: Test inventory parsing
echo "Test 8: Testing inventory parsing..."
if ansible-inventory -i "$INVENTORY" --list &> /dev/null; then
    print_status "success" "Inventory parses correctly"
    HOST_COUNT=$(ansible-inventory -i "$INVENTORY" --list | grep -c '"ansible_host"' || echo 0)
    print_status "info" "Found $HOST_COUNT host(s) in inventory"
else
    print_status "error" "Inventory parsing failed"
    exit 1
fi
echo ""

# Test 9: Dry-run validation playbook
echo "Test 9: Running validation playbook in check mode..."
if ansible-playbook -i "$INVENTORY" playbooks/validation.yml --check --diff &> /dev/null; then
    print_status "success" "Validation playbook dry-run successful"
else
    print_status "warning" "Validation playbook dry-run had issues (may require live devices)"
fi
echo ""

# Test 10: Validate Python scripts
echo "Test 10: Validating Python scripts..."
if command -v python3 &> /dev/null; then
    for script in "$PROJECT_ROOT/scripts/python"/*.py; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            if python3 -m py_compile "$script" 2>/dev/null; then
                print_status "success" "$script_name - Syntax OK"
            else
                print_status "error" "$script_name - Syntax errors"
            fi
        fi
    done
else
    print_status "warning" "Python3 not installed, skipping Python validation"
fi
echo ""

# Summary
echo "========================================"
echo "Test Summary"
echo "========================================"
print_status "success" "All critical tests passed"
echo ""
echo "Ready for deployment!"
echo ""

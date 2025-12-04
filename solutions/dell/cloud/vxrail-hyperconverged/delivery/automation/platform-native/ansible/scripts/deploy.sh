#!/bin/bash
# Dell VxRail Enterprise - Deployment Wrapper Script
# EO Framework - Dell Cloud Solutions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"

# Default values
ENVIRONMENT="${1:-production}"
PLAYBOOK="${2:-site.yml}"
TAGS="${3:-}"
EXTRA_VARS="${4:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}Dell VxRail Enterprise - Deployment${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "Environment: ${YELLOW}${ENVIRONMENT}${NC}"
echo -e "Playbook: ${YELLOW}${PLAYBOOK}${NC}"
echo -e "================================================================"

# Change to ansible directory
cd "$ANSIBLE_DIR"

# Check if inventory exists
if [ ! -d "inventory/${ENVIRONMENT}" ]; then
    echo -e "${RED}ERROR: Inventory for environment '${ENVIRONMENT}' not found${NC}"
    echo "Available environments:"
    ls -1 inventory/
    exit 1
fi

# Check if vault password file exists
if [ ! -f ".vault_password" ]; then
    echo -e "${YELLOW}WARNING: .vault_password file not found. Secrets will not be decrypted.${NC}"
fi

# Install required collections
echo -e "\n${GREEN}Installing Ansible collections...${NC}"
ansible-galaxy collection install -r requirements.yml --force

# Build ansible-playbook command
CMD="ansible-playbook"
CMD="$CMD -i inventory/${ENVIRONMENT}/hosts.yml"
CMD="$CMD playbooks/${PLAYBOOK}"

if [ -n "$TAGS" ]; then
    CMD="$CMD --tags ${TAGS}"
fi

if [ -n "$EXTRA_VARS" ]; then
    CMD="$CMD -e ${EXTRA_VARS}"
fi

# Run the playbook
echo -e "\n${GREEN}Running playbook...${NC}"
echo -e "Command: ${CMD}\n"

$CMD

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}Deployment Complete${NC}"
echo -e "${GREEN}================================================================${NC}"

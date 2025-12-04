#!/bin/bash
#------------------------------------------------------------------------------
# EO Framework Deployment Script - GCP Landing Zone Production
#------------------------------------------------------------------------------
# Wrapper script for Terraform commands with auto-loading of tfvars
#------------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build var-file arguments from config/*.tfvars
VAR_FILES=""
for file in config/*.tfvars; do
    [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file"
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}EO Framework - GCP Landing Zone${NC}"
echo "Environment: prod"
echo "-----------------------------------"

case "${1:-help}" in
    "init")
        echo -e "${YELLOW}Initializing Terraform...${NC}"
        terraform init "${@:2}"
        ;;
    "plan")
        echo -e "${YELLOW}Planning deployment...${NC}"
        terraform plan $VAR_FILES "${@:2}"
        ;;
    "apply")
        echo -e "${YELLOW}Applying deployment...${NC}"
        terraform apply $VAR_FILES "${@:2}"
        ;;
    "destroy")
        echo -e "${RED}Destroying infrastructure...${NC}"
        terraform destroy $VAR_FILES "${@:2}"
        ;;
    "validate")
        echo -e "${YELLOW}Validating configuration...${NC}"
        terraform validate
        ;;
    "output")
        terraform output "${@:2}"
        ;;
    "help"|*)
        echo ""
        echo "Usage: ./eo-deploy.sh <command> [options]"
        echo ""
        echo "Commands:"
        echo "  init      Initialize Terraform (downloads providers)"
        echo "  plan      Preview changes without applying"
        echo "  apply     Apply the infrastructure changes"
        echo "  destroy   Destroy all managed infrastructure"
        echo "  validate  Validate Terraform configuration"
        echo "  output    Show Terraform outputs"
        echo ""
        echo "Examples:"
        echo "  ./eo-deploy.sh init"
        echo "  ./eo-deploy.sh plan"
        echo "  ./eo-deploy.sh apply -auto-approve"
        echo ""
        ;;
esac

#!/bin/bash
#------------------------------------------------------------------------------
# EO Framework Deployment Script - HashiCorp Multi-Cloud Platform
#------------------------------------------------------------------------------
# Auto-discovers and loads all config/*.tfvars files for Terraform operations.
# Usage: ./eo-deploy.sh [init|plan|apply|destroy|validate]
#------------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Build var-file arguments from config/*.tfvars
# Files are loaded alphabetically which determines override order
VAR_FILES=""
for file in config/*.tfvars; do
    [ -f "$file" ] && VAR_FILES="$VAR_FILES -var-file=$file"
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}EO Framework - HashiCorp Multi-Cloud Platform${NC}"
echo -e "${GREEN}Environment: $(basename "$SCRIPT_DIR")${NC}"
echo -e "${GREEN}============================================${NC}"

case $1 in
    "init")
        echo -e "${YELLOW}Initializing Terraform...${NC}"
        if [ -f "backend.tfvars" ]; then
            terraform init -backend-config=backend.tfvars "${@:2}"
        else
            echo -e "${YELLOW}No backend.tfvars found, initializing with local backend${NC}"
            terraform init "${@:2}"
        fi
        ;;
    "plan")
        echo -e "${YELLOW}Planning infrastructure changes...${NC}"
        echo "Using tfvars files: $VAR_FILES"
        terraform plan $VAR_FILES "${@:2}"
        ;;
    "apply")
        echo -e "${YELLOW}Applying infrastructure changes...${NC}"
        echo "Using tfvars files: $VAR_FILES"
        terraform apply $VAR_FILES "${@:2}"
        ;;
    "destroy")
        echo -e "${RED}Destroying infrastructure...${NC}"
        echo "Using tfvars files: $VAR_FILES"
        terraform destroy $VAR_FILES "${@:2}"
        ;;
    "validate")
        echo -e "${YELLOW}Validating Terraform configuration...${NC}"
        terraform validate
        echo -e "${GREEN}Configuration is valid!${NC}"
        ;;
    "fmt")
        echo -e "${YELLOW}Formatting Terraform files...${NC}"
        terraform fmt -recursive
        echo -e "${GREEN}Formatting complete!${NC}"
        ;;
    "output")
        terraform output "${@:2}"
        ;;
    *)
        echo "Usage: $0 {init|plan|apply|destroy|validate|fmt|output}"
        echo ""
        echo "Commands:"
        echo "  init     - Initialize Terraform with backend configuration"
        echo "  plan     - Show planned infrastructure changes"
        echo "  apply    - Apply infrastructure changes"
        echo "  destroy  - Destroy all infrastructure (use with caution)"
        echo "  validate - Validate Terraform configuration syntax"
        echo "  fmt      - Format Terraform files"
        echo "  output   - Show Terraform outputs"
        exit 1
        ;;
esac

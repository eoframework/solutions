#!/bin/bash
#------------------------------------------------------------------------------
# GitHub Advanced Security - EO Framework Deployment Script
#------------------------------------------------------------------------------
# Production Environment
#------------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== GitHub Advanced Security - Production Deployment ===${NC}"
echo ""

# Check for required environment variables
if [ -z "$TF_VAR_auth" ]; then
    echo -e "${YELLOW}Warning: TF_VAR_auth not set. You will need to provide authentication credentials.${NC}"
    echo "Example: export TF_VAR_auth='{\"api_token\":\"ghp_xxx\",\"mfa_enforcement\":\"required\"}'"
fi

# Build tfvars arguments
TFVARS_ARGS=""
for tfvars_file in "${CONFIG_DIR}"/*.tfvars; do
    if [ -f "$tfvars_file" ]; then
        TFVARS_ARGS="${TFVARS_ARGS} -var-file=${tfvars_file}"
    fi
done

# Parse command line arguments
ACTION="${1:-plan}"

case "$ACTION" in
    init)
        echo -e "${GREEN}Initializing Terraform...${NC}"
        terraform init
        ;;
    plan)
        echo -e "${GREEN}Planning deployment...${NC}"
        terraform plan ${TFVARS_ARGS}
        ;;
    apply)
        echo -e "${GREEN}Applying configuration...${NC}"
        terraform apply ${TFVARS_ARGS}
        ;;
    destroy)
        echo -e "${RED}Destroying resources...${NC}"
        terraform destroy ${TFVARS_ARGS}
        ;;
    validate)
        echo -e "${GREEN}Validating configuration...${NC}"
        terraform validate
        ;;
    output)
        echo -e "${GREEN}Showing outputs...${NC}"
        terraform output
        ;;
    *)
        echo "Usage: $0 {init|plan|apply|destroy|validate|output}"
        echo ""
        echo "Commands:"
        echo "  init     - Initialize Terraform providers and modules"
        echo "  plan     - Show planned changes (default)"
        echo "  apply    - Apply configuration changes"
        echo "  destroy  - Destroy all resources"
        echo "  validate - Validate configuration syntax"
        echo "  output   - Show current outputs"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done.${NC}"

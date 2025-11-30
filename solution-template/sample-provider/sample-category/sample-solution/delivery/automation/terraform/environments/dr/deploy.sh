#!/bin/bash

# DR Environment - Terraform Deployment Script
# Uses config/*.tfvars files for configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script info
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT=$(basename "$SCRIPT_DIR")

echo -e "${BLUE}🚀 ${ENVIRONMENT^} Environment - Terraform Wrapper${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"

# Function to build var-file arguments
build_var_files() {
    VAR_FILES=""

    # Load all tfvars files from config/ directory
    # Files are loaded alphabetically which determines override order
    if [ -d "config" ]; then
        for file in config/*.tfvars; do
            if [ -f "$file" ]; then
                VAR_FILES="$VAR_FILES -var-file=$file"
                echo -e "${GREEN}   ✓ $file${NC}"
            fi
        done
    fi

    # Fallback: Load main.tfvars if config/ not present (legacy support)
    if [ ! -d "config" ] && [ -f "main.tfvars" ]; then
        VAR_FILES="-var-file=main.tfvars"
        echo -e "${GREEN}   ✓ main.tfvars (legacy)${NC}"
    fi

    echo ""
}

# Function to show usage
show_usage() {
    echo -e "${CYAN}Usage: $0 <command> [options]${NC}"
    echo ""
    echo -e "${YELLOW}Available Commands:${NC}"
    echo -e "${GREEN}  init${NC}           Initialize Terraform working directory"
    echo -e "${GREEN}  plan${NC}           Create an execution plan"
    echo -e "${GREEN}  apply${NC}          Apply the Terraform plan"
    echo -e "${GREEN}  destroy${NC}        Destroy Terraform-managed infrastructure"
    echo -e "${GREEN}  validate${NC}       Validate the Terraform configuration"
    echo -e "${GREEN}  fmt${NC}            Format Terraform configuration files"
    echo -e "${GREEN}  output${NC}         Show output values"
    echo -e "${GREEN}  show${NC}           Show current state or saved plan"
    echo -e "${GREEN}  state${NC}          Advanced state management"
    echo -e "${GREEN}  refresh${NC}        Update state to match remote systems"
    echo -e "${GREEN}  version${NC}        Show Terraform version"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "${CYAN}  $0 init${NC}"
    echo -e "${CYAN}  $0 plan${NC}"
    echo -e "${CYAN}  $0 apply -auto-approve${NC}"
    echo -e "${CYAN}  $0 destroy${NC}"
    echo ""
}

# Check if command provided
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

COMMAND=$1
shift # Remove first argument to pass rest to terraform

# Handle commands
case $COMMAND in
    "init")
        echo -e "${BLUE}🔧 Initializing Terraform...${NC}"
        terraform init "$@"
        ;;

    "plan")
        echo -e "${BLUE}📊 Creating execution plan...${NC}"
        echo -e "${YELLOW}📋 Loading configuration files:${NC}"
        build_var_files
        terraform plan $VAR_FILES "$@"
        ;;

    "apply")
        echo -e "${BLUE}🚀 Applying Terraform configuration...${NC}"
        echo -e "${YELLOW}📋 Loading configuration files:${NC}"
        build_var_files
        terraform apply $VAR_FILES "$@"
        ;;

    "destroy")
        echo -e "${RED}💥 Destroying infrastructure...${NC}"
        echo -e "${YELLOW}⚠️  This will destroy all resources in $ENVIRONMENT environment!${NC}"
        echo -e "${YELLOW}📋 Loading configuration files:${NC}"
        build_var_files
        terraform destroy $VAR_FILES "$@"
        ;;

    "validate")
        echo -e "${BLUE}✅ Validating Terraform configuration...${NC}"
        terraform validate "$@"
        ;;

    "fmt")
        echo -e "${BLUE}📝 Formatting Terraform files...${NC}"
        terraform fmt "$@"
        ;;

    "output")
        echo -e "${BLUE}📤 Showing output values...${NC}"
        terraform output "$@"
        ;;

    "show")
        echo -e "${BLUE}👁️  Showing current state...${NC}"
        terraform show "$@"
        ;;

    "state")
        echo -e "${BLUE}🗃️  State management...${NC}"
        terraform state "$@"
        ;;

    "refresh")
        echo -e "${BLUE}🔄 Refreshing state...${NC}"
        echo -e "${YELLOW}📋 Loading configuration files:${NC}"
        build_var_files
        terraform refresh $VAR_FILES "$@"
        ;;

    "version")
        echo -e "${BLUE}ℹ️  Terraform version information:${NC}"
        terraform version
        ;;

    "help"|"-h"|"--help")
        show_usage
        ;;

    *)
        echo -e "${RED}❌ Unknown command: $COMMAND${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Command completed successfully!${NC}"

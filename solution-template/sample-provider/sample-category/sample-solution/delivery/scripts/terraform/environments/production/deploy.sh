#!/bin/bash

# Production Environment - Terraform Deployment Script
# Comprehensive Terraform wrapper with auto-loading of config files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script info
SCRIPT_NAME=$(basename "$0")
ENVIRONMENT="production"

echo -e "${BLUE}🚀 ${ENVIRONMENT^} Environment - Terraform Wrapper${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"

# Function to build var-file arguments
build_var_files() {
    VAR_FILES=""
    local count=0

    if [ -d "config" ]; then
        echo -e "${YELLOW}📋 Loading configuration files:${NC}"
        for file in config/*.tfvars; do
            if [ -f "$file" ]; then
                VAR_FILES="$VAR_FILES -var-file=$file"
                echo -e "${GREEN}   ✓ $file${NC}"
                ((count++))
            fi
        done

        if [ $count -eq 0 ]; then
            echo -e "${YELLOW}   ⚠️  No .tfvars files found in config/${NC}"
        else
            echo -e "${CYAN}   📊 Total: $count configuration file(s)${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  config/ directory not found${NC}"
    fi
    echo ""
}

# Function to show usage
show_usage() {
    echo -e "${CYAN}Usage: $SCRIPT_NAME <command> [options]${NC}"
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
    echo -e "${GREEN}  import${NC}         Import existing infrastructure"
    echo -e "${GREEN}  workspace${NC}      Workspace management"
    echo -e "${GREEN}  version${NC}        Show Terraform version"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "${CYAN}  $SCRIPT_NAME init${NC}"
    echo -e "${CYAN}  $SCRIPT_NAME plan${NC}"
    echo -e "${CYAN}  $SCRIPT_NAME apply${NC}"
    echo -e "${CYAN}  $SCRIPT_NAME destroy${NC}"
    echo -e "${CYAN}  $SCRIPT_NAME fmt -recursive${NC}"
    echo -e "${CYAN}  $SCRIPT_NAME output${NC}"
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
        build_var_files
        terraform plan $VAR_FILES "$@"
        ;;

    "apply")
        echo -e "${BLUE}🚀 Applying Terraform configuration...${NC}"
        build_var_files
        terraform apply $VAR_FILES "$@"
        ;;

    "destroy")
        echo -e "${RED}💥 Destroying infrastructure...${NC}"
        echo -e "${YELLOW}⚠️  This will destroy all resources in $ENVIRONMENT environment!${NC}"
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
        build_var_files
        terraform refresh $VAR_FILES "$@"
        ;;

    "import")
        echo -e "${BLUE}📥 Importing existing infrastructure...${NC}"
        build_var_files
        terraform import $VAR_FILES "$@"
        ;;

    "workspace")
        echo -e "${BLUE}🏢 Workspace management...${NC}"
        terraform workspace "$@"
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
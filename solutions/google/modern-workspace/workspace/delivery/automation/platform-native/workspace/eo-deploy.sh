#!/bin/bash
#------------------------------------------------------------------------------
# EO Framework Deployment Script - Google Workspace
#------------------------------------------------------------------------------
# Wrapper script for Python deployment with auto-loading of configuration
#------------------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default environment
ENV="${EO_ENVIRONMENT:-prod}"
CONFIG_FILE="config/${ENV}.yaml"

# Validate config exists
check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
        echo "Available configurations:"
        ls -1 config/*.yaml 2>/dev/null || echo "  (none found)"
        exit 1
    fi
}

# Check Python dependencies
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: python3 is not installed${NC}"
        exit 1
    fi

    if ! python3 -c "import yaml" &> /dev/null; then
        echo -e "${YELLOW}Installing Python dependencies...${NC}"
        pip3 install -r scripts/python/requirements.txt
    fi
}

print_header() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}EO Framework - Google Workspace${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo "Environment: $ENV"
    echo "Config:      $CONFIG_FILE"
    echo "-------------------------------------------"
}

case "${1:-help}" in
    "deploy")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Running full deployment...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" "${@:2}"
        ;;
    "plan"|"dry-run")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Running dry-run (preview mode)...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" --dry-run "${@:2}"
        ;;
    "org-units")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Creating Organizational Units...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" --step org-units "${@:2}"
        ;;
    "groups")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Creating Groups...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" --step groups "${@:2}"
        ;;
    "sso")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Configuring SSO...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" --step sso "${@:2}"
        ;;
    "security")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Configuring Security Policies...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" --step security "${@:2}"
        ;;
    "dlp")
        check_config
        check_dependencies
        print_header
        echo -e "${YELLOW}Configuring DLP...${NC}"
        python3 scripts/python/setup_workspace.py --config "$CONFIG_FILE" --step dlp "${@:2}"
        ;;
    "validate")
        check_config
        print_header
        echo -e "${YELLOW}Validating configuration...${NC}"
        python3 -c "import yaml; yaml.safe_load(open('$CONFIG_FILE'))" && \
            echo -e "${GREEN}Configuration is valid YAML${NC}"
        ;;
    "env")
        echo "Current environment: $ENV"
        echo ""
        echo "To change environment, set EO_ENVIRONMENT:"
        echo "  export EO_ENVIRONMENT=test"
        echo "  export EO_ENVIRONMENT=prod"
        echo "  export EO_ENVIRONMENT=dr"
        echo ""
        echo "Available configurations:"
        ls -1 config/*.yaml 2>/dev/null || echo "  (none found)"
        ;;
    "help"|*)
        echo ""
        echo -e "${BLUE}Usage: ./eo-deploy.sh <command> [options]${NC}"
        echo ""
        echo "Commands:"
        echo "  deploy      Run full deployment (all steps)"
        echo "  plan        Preview changes without applying (dry-run)"
        echo "  org-units   Create organizational units only"
        echo "  groups      Create groups only"
        echo "  sso         Configure SSO only"
        echo "  security    Configure security policies only"
        echo "  dlp         Configure DLP rules only"
        echo "  validate    Validate configuration YAML"
        echo "  env         Show/change environment"
        echo ""
        echo "Environment:"
        echo "  Set EO_ENVIRONMENT to switch environments:"
        echo "    export EO_ENVIRONMENT=test"
        echo ""
        echo "Examples:"
        echo "  ./eo-deploy.sh plan                    # Preview all changes"
        echo "  ./eo-deploy.sh deploy                  # Full deployment"
        echo "  ./eo-deploy.sh org-units --dry-run    # Preview org unit creation"
        echo "  EO_ENVIRONMENT=test ./eo-deploy.sh plan"
        echo ""
        ;;
esac

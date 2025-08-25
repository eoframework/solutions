#!/bin/bash
# Juniper Mist AI Network Deployment Script
# Automates the deployment and configuration of Mist AI Network Platform

set -euo pipefail

# Global Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/mist-deployment"
LOG_FILE="$LOG_DIR/deployment_$(date +%Y%m%d_%H%M%S).log"
CONFIG_FILE="${SCRIPT_DIR}/../config/deployment.conf"

# Default Values
ORG_ID=""
SITE_NAME=""
API_TOKEN=""
DRY_RUN=false
VERBOSE=false

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Juniper Mist AI Network Deployment Script

OPTIONS:
    --org-id ORG_ID         Mist Organization ID
    --site-name SITE_NAME   Site name for deployment
    --api-token TOKEN       Mist API token
    --config FILE           Configuration file path
    --dry-run              Perform dry run without making changes
    --verbose              Enable verbose logging
    --check-prerequisites   Check system prerequisites
    --help                 Display this help message

EXAMPLES:
    $0 --org-id "12345" --site-name "HQ-Campus" --api-token "token123"
    $0 --config /path/to/config.conf --dry-run
    $0 --check-prerequisites

EOF
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    
    if [[ "$VERBOSE" == "true" ]] || [[ "$level" == "ERROR" ]]; then
        echo "[$level] $message" >&2
    fi
}

# Function to check prerequisites
check_prerequisites() {
    log_message "INFO" "Checking deployment prerequisites..."
    
    local prereq_ok=true
    
    # Check required tools
    local required_tools=("curl" "jq" "python3" "pip3")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_message "ERROR" "Required tool not found: $tool"
            prereq_ok=false
        else
            log_message "INFO" "Found required tool: $tool"
        fi
    done
    
    # Check Python packages
    local python_packages=("requests" "pyyaml" "pandas")
    for package in "${python_packages[@]}"; do
        if ! python3 -c "import $package" &> /dev/null; then
            log_message "WARN" "Python package not found: $package (will install)"
        else
            log_message "INFO" "Found Python package: $package"
        fi
    done
    
    # Check network connectivity
    if ! curl -s --connect-timeout 5 https://api.mist.com/api/v1/self &> /dev/null; then
        log_message "ERROR" "Cannot reach Mist API (https://api.mist.com)"
        prereq_ok=false
    else
        log_message "INFO" "Network connectivity to Mist API: OK"
    fi
    
    if [[ "$prereq_ok" == "true" ]]; then
        log_message "INFO" "All prerequisites satisfied"
        return 0
    else
        log_message "ERROR" "Prerequisites check failed"
        return 1
    fi
}

# Function to install Python dependencies
install_dependencies() {
    log_message "INFO" "Installing Python dependencies..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would install Python packages"
        return 0
    fi
    
    pip3 install --user requests pyyaml pandas || {
        log_message "ERROR" "Failed to install Python dependencies"
        return 1
    }
    
    log_message "INFO" "Python dependencies installed successfully"
}

# Function to validate API token
validate_api_token() {
    log_message "INFO" "Validating Mist API token..."
    
    local response
    response=$(curl -s -H "Authorization: Token $API_TOKEN" \
        "https://api.mist.com/api/v1/self" 2>/dev/null) || {
        log_message "ERROR" "Failed to connect to Mist API"
        return 1
    }
    
    if echo "$response" | jq -e '.email' &> /dev/null; then
        local user_email
        user_email=$(echo "$response" | jq -r '.email')
        log_message "INFO" "API token validated for user: $user_email"
        return 0
    else
        log_message "ERROR" "Invalid API token or API error"
        return 1
    fi
}

# Function to create or update site
setup_site() {
    log_message "INFO" "Setting up site: $SITE_NAME"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would create/update site: $SITE_NAME"
        return 0
    fi
    
    # Use Python script for API operations
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action create_site \
        --org-id "$ORG_ID" \
        --site-name "$SITE_NAME" \
        --api-token "$API_TOKEN" || {
        log_message "ERROR" "Failed to setup site"
        return 1
    }
    
    log_message "INFO" "Site setup completed successfully"
}

# Function to configure network policies
configure_network_policies() {
    log_message "INFO" "Configuring network policies..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would configure network policies"
        return 0
    fi
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action configure_policies \
        --org-id "$ORG_ID" \
        --site-name "$SITE_NAME" \
        --api-token "$API_TOKEN" || {
        log_message "ERROR" "Failed to configure network policies"
        return 1
    }
    
    log_message "INFO" "Network policies configured successfully"
}

# Function to deploy access points
deploy_access_points() {
    log_message "INFO" "Deploying access points configuration..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_message "INFO" "[DRY RUN] Would deploy access points"
        return 0
    fi
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action deploy_aps \
        --org-id "$ORG_ID" \
        --site-name "$SITE_NAME" \
        --api-token "$API_TOKEN" || {
        log_message "ERROR" "Failed to deploy access points"
        return 1
    }
    
    log_message "INFO" "Access points deployed successfully"
}

# Function to validate deployment
validate_deployment() {
    log_message "INFO" "Validating deployment..."
    
    python3 "${SCRIPT_DIR}/../python/deploy.py" \
        --action validate \
        --org-id "$ORG_ID" \
        --site-name "$SITE_NAME" \
        --api-token "$API_TOKEN" || {
        log_message "ERROR" "Deployment validation failed"
        return 1
    }
    
    log_message "INFO" "Deployment validation completed successfully"
}

# Function to load configuration file
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_message "INFO" "Loading configuration from: $CONFIG_FILE"
        source "$CONFIG_FILE"
    fi
}

# Main deployment function
main() {
    # Create log directory
    mkdir -p "$LOG_DIR"
    
    log_message "INFO" "Starting Juniper Mist AI Network deployment"
    log_message "INFO" "Log file: $LOG_FILE"
    
    # Load configuration
    load_config
    
    # Check prerequisites
    check_prerequisites || exit 1
    
    # Install dependencies
    install_dependencies || exit 1
    
    # Validate required parameters
    if [[ -z "$ORG_ID" ]] || [[ -z "$SITE_NAME" ]] || [[ -z "$API_TOKEN" ]]; then
        log_message "ERROR" "Missing required parameters: org-id, site-name, and api-token"
        usage
        exit 1
    fi
    
    # Validate API token
    validate_api_token || exit 1
    
    # Execute deployment steps
    setup_site || exit 1
    configure_network_policies || exit 1
    deploy_access_points || exit 1
    validate_deployment || exit 1
    
    log_message "INFO" "Mist AI Network deployment completed successfully"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        echo "Deployment Summary:"
        echo "  Organization ID: $ORG_ID"
        echo "  Site Name: $SITE_NAME"
        echo "  Log File: $LOG_FILE"
        echo ""
        echo "Next Steps:"
        echo "  1. Monitor deployment in Mist Dashboard"
        echo "  2. Install and adopt access points"
        echo "  3. Validate network performance"
        echo "  4. Configure additional policies as needed"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --org-id)
            ORG_ID="$2"
            shift 2
            ;;
        --site-name)
            SITE_NAME="$2"
            shift 2
            ;;
        --api-token)
            API_TOKEN="$2"
            shift 2
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --check-prerequisites)
            mkdir -p "$LOG_DIR"
            check_prerequisites
            exit $?
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            log_message "ERROR" "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Execute main function
main
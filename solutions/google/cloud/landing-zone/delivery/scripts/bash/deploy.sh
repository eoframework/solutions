#!/bin/bash

# Google Cloud Landing Zone Deployment Script
# This script automates the deployment of Google Cloud Landing Zone infrastructure
# using Terraform and Google Cloud CLI tools.

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")/terraform"
LOG_FILE="$SCRIPT_DIR/deployment_$(date +%Y%m%d_%H%M%S).log"

# Default values
DEFAULT_REGION="us-central1"
DEFAULT_ENVIRONMENT="prod"
DEFAULT_CONFIG_FILE="terraform.tfvars"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${BLUE}[${timestamp}] [INFO] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        "WARN")
            echo -e "${YELLOW}[${timestamp}] [WARN] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        "ERROR")
            echo -e "${RED}[${timestamp}] [ERROR] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[${timestamp}] [SUCCESS] ${message}${NC}" | tee -a "$LOG_FILE"
            ;;
        *)
            echo -e "[${timestamp}] ${message}" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Google Cloud Landing Zone infrastructure using Terraform.

OPTIONS:
    -p, --project-id PROJECT_ID          Google Cloud project ID (required)
    -o, --organization-id ORG_ID         Google Cloud organization ID (required)
    -b, --billing-account BILLING_ID     Billing account ID (required)
    -r, --region REGION                  Deployment region (default: $DEFAULT_REGION)
    -e, --environment ENV                Environment name (default: $DEFAULT_ENVIRONMENT)
    -c, --config-file FILE               Terraform config file (default: $DEFAULT_CONFIG_FILE)
    -a, --auto-approve                   Auto-approve Terraform changes
    -P, --plan-only                      Only create deployment plan, do not apply
    -d, --destroy                        Destroy infrastructure instead of creating
    -v, --verbose                        Enable verbose logging
    -h, --help                          Show this help message

EXAMPLES:
    # Basic deployment
    $0 -p my-project -o 123456789012 -b ABCD-1234-EFGH

    # Plan-only mode
    $0 -p my-project -o 123456789012 -b ABCD-1234-EFGH --plan-only

    # Auto-approve deployment
    $0 -p my-project -o 123456789012 -b ABCD-1234-EFGH --auto-approve

    # Destroy infrastructure
    $0 -p my-project -o 123456789012 -b ABCD-1234-EFGH --destroy

EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--project-id)
                PROJECT_ID="$2"
                shift 2
                ;;
            -o|--organization-id)
                ORGANIZATION_ID="$2"
                shift 2
                ;;
            -b|--billing-account)
                BILLING_ACCOUNT_ID="$2"
                shift 2
                ;;
            -r|--region)
                REGION="$2"
                shift 2
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -c|--config-file)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -a|--auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -P|--plan-only)
                PLAN_ONLY=true
                shift
                ;;
            -d|--destroy)
                DESTROY=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done

    # Set defaults
    REGION="${REGION:-$DEFAULT_REGION}"
    ENVIRONMENT="${ENVIRONMENT:-$DEFAULT_ENVIRONMENT}"
    CONFIG_FILE="${CONFIG_FILE:-$DEFAULT_CONFIG_FILE}"
    AUTO_APPROVE="${AUTO_APPROVE:-false}"
    PLAN_ONLY="${PLAN_ONLY:-false}"
    DESTROY="${DESTROY:-false}"
    VERBOSE="${VERBOSE:-false}"

    # Validate required arguments
    if [[ -z "${PROJECT_ID:-}" ]]; then
        error_exit "Project ID is required. Use -p or --project-id"
    fi
    
    if [[ -z "${ORGANIZATION_ID:-}" ]]; then
        error_exit "Organization ID is required. Use -o or --organization-id"
    fi
    
    if [[ -z "${BILLING_ACCOUNT_ID:-}" ]]; then
        error_exit "Billing account ID is required. Use -b or --billing-account"
    fi
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking deployment prerequisites..."

    # Check if gcloud CLI is installed
    if ! command -v gcloud &> /dev/null; then
        error_exit "Google Cloud SDK (gcloud) is not installed or not in PATH"
    fi
    
    local gcloud_version
    gcloud_version=$(gcloud version --format="value(Google Cloud SDK)")
    log "INFO" "Google Cloud SDK version: $gcloud_version"

    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        error_exit "Terraform is not installed or not in PATH"
    fi
    
    local terraform_version
    terraform_version=$(terraform version -json | jq -r '.terraform_version')
    log "INFO" "Terraform version: $terraform_version"

    # Check authentication
    local current_account
    current_account=$(gcloud config get-value account 2>/dev/null || echo "")
    if [[ -z "$current_account" ]]; then
        error_exit "Not authenticated with Google Cloud. Run 'gcloud auth login'"
    fi
    log "INFO" "Authenticated as: $current_account"

    # Check if configuration file exists
    local config_path="$TERRAFORM_DIR/$CONFIG_FILE"
    if [[ ! -f "$config_path" ]]; then
        error_exit "Configuration file not found: $config_path"
    fi
    log "INFO" "Configuration file: $config_path"

    # Check if jq is available (used for JSON parsing)
    if ! command -v jq &> /dev/null; then
        log "WARN" "jq is not installed. Some features may be limited."
    fi

    log "SUCCESS" "Prerequisites check completed successfully"
}

# Validate configuration
validate_configuration() {
    log "INFO" "Validating Terraform configuration..."
    
    local config_path="$TERRAFORM_DIR/$CONFIG_FILE"
    
    # Check required variables in config file
    local required_vars=("project_id" "organization_id" "billing_account_id" "region")
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}[[:space:]]*=" "$config_path"; then
            error_exit "Required variable '$var' not found in configuration file"
        fi
    done
    
    # Validate project ID format
    if [[ ! "$PROJECT_ID" =~ ^[a-z][-a-z0-9]{5,29}$ ]]; then
        error_exit "Invalid project ID format: $PROJECT_ID"
    fi
    
    log "SUCCESS" "Configuration validation completed successfully"
}

# Setup Google Cloud project
setup_google_cloud_project() {
    log "INFO" "Setting up Google Cloud project..."
    
    # Set active project
    gcloud config set project "$PROJECT_ID" || error_exit "Failed to set active project"
    log "INFO" "Set active project to: $PROJECT_ID"
    
    # Check if project exists, create if it doesn't
    if ! gcloud projects describe "$PROJECT_ID" &> /dev/null; then
        log "INFO" "Creating project: $PROJECT_ID"
        gcloud projects create "$PROJECT_ID" --organization="$ORGANIZATION_ID" || \
            error_exit "Failed to create project"
        
        # Link billing account
        log "INFO" "Linking billing account: $BILLING_ACCOUNT_ID"
        gcloud billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID" || \
            log "WARN" "Failed to link billing account"
    else
        log "INFO" "Project already exists: $PROJECT_ID"
    fi
    
    # Enable required APIs
    log "INFO" "Enabling required APIs..."
    local required_apis=(
        "cloudresourcemanager.googleapis.com"
        "compute.googleapis.com"
        "iam.googleapis.com"
        "logging.googleapis.com"
        "monitoring.googleapis.com"
        "storage.googleapis.com"
        "cloudkms.googleapis.com"
        "dns.googleapis.com"
        "servicenetworking.googleapis.com"
        "cloudtrace.googleapis.com"
    )
    
    for api in "${required_apis[@]}"; do
        log "INFO" "Enabling API: $api"
        gcloud services enable "$api" --project="$PROJECT_ID" || \
            log "WARN" "Failed to enable API: $api"
    done
    
    # Wait for API enablement to propagate
    log "INFO" "Waiting for API enablement to propagate..."
    sleep 30
    
    log "SUCCESS" "Google Cloud project setup completed"
}

# Setup Terraform backend
setup_terraform_backend() {
    log "INFO" "Setting up Terraform backend..."
    
    local state_bucket="${PROJECT_ID}-terraform-state"
    
    # Check if bucket exists
    if ! gsutil ls -b "gs://$state_bucket" &> /dev/null; then
        log "INFO" "Creating Terraform state bucket: $state_bucket"
        gsutil mb "gs://$state_bucket" || error_exit "Failed to create state bucket"
        
        # Enable versioning
        gsutil versioning set on "gs://$state_bucket" || \
            log "WARN" "Failed to enable versioning on state bucket"
        log "INFO" "Enabled versioning on state bucket"
        
        # Set lifecycle policy
        local lifecycle_config=$(cat << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 365,
          "isLive": false
        }
      }
    ]
  }
}
EOF
)
        echo "$lifecycle_config" > "$SCRIPT_DIR/lifecycle.json"
        gsutil lifecycle set "$SCRIPT_DIR/lifecycle.json" "gs://$state_bucket" || \
            log "WARN" "Failed to set lifecycle policy"
        rm -f "$SCRIPT_DIR/lifecycle.json"
        log "INFO" "Applied lifecycle policy to state bucket"
    else
        log "INFO" "Terraform state bucket already exists: $state_bucket"
    fi
    
    log "SUCCESS" "Terraform backend setup completed"
}

# Initialize Terraform
initialize_terraform() {
    log "INFO" "Initializing Terraform..."
    
    cd "$TERRAFORM_DIR" || error_exit "Failed to change to Terraform directory"
    
    # Initialize Terraform
    terraform init || error_exit "Terraform init failed"
    log "INFO" "Terraform initialized successfully"
    
    # Create or select workspace
    local workspace_name="${ENVIRONMENT}-${REGION}"
    
    if terraform workspace list | grep -q "$workspace_name"; then
        log "INFO" "Selecting Terraform workspace: $workspace_name"
        terraform workspace select "$workspace_name" || \
            error_exit "Failed to select workspace"
    else
        log "INFO" "Creating Terraform workspace: $workspace_name"
        terraform workspace new "$workspace_name" || \
            error_exit "Failed to create workspace"
    fi
    
    # Validate configuration
    terraform validate || error_exit "Terraform validation failed"
    log "INFO" "Terraform configuration validated successfully"
    
    log "SUCCESS" "Terraform initialization completed"
}

# Plan Terraform deployment
plan_deployment() {
    log "INFO" "Creating Terraform deployment plan..."
    
    cd "$TERRAFORM_DIR" || error_exit "Failed to change to Terraform directory"
    
    local plan_file="tfplan_$(date +%Y%m%d_%H%M%S)"
    
    # Create plan
    if [[ "$VERBOSE" == "true" ]]; then
        terraform plan -var-file="$CONFIG_FILE" -out="$plan_file" || \
            error_exit "Terraform plan failed"
    else
        terraform plan -var-file="$CONFIG_FILE" -out="$plan_file" > /dev/null || \
            error_exit "Terraform plan failed"
    fi
    
    log "SUCCESS" "Terraform plan created successfully: $plan_file"
    
    # Show plan summary
    local plan_summary
    plan_summary=$(terraform show "$plan_file" | grep "Plan:" || echo "Plan summary not available")
    log "INFO" "$plan_summary"
    
    echo "$plan_file"
}

# Apply Terraform deployment
apply_deployment() {
    local plan_file="$1"
    
    log "INFO" "Applying Terraform deployment..."
    
    cd "$TERRAFORM_DIR" || error_exit "Failed to change to Terraform directory"
    
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        terraform apply -auto-approve "$plan_file" || \
            error_exit "Terraform apply failed"
    else
        # Interactive approval
        echo
        echo -e "${YELLOW}Review the plan above. Do you want to continue with the deployment? (y/N): ${NC}"
        read -r response
        case "$response" in
            [Yy][Ee][Ss]|[Yy])
                terraform apply "$plan_file" || error_exit "Terraform apply failed"
                ;;
            *)
                log "WARN" "Deployment cancelled by user"
                return 1
                ;;
        esac
    fi
    
    # Show outputs
    log "INFO" "Deployment outputs:"
    if command -v jq &> /dev/null; then
        terraform output -json | jq -r '. | to_entries[] | "\(.key): \(.value.value)"'
    else
        terraform output
    fi
    
    log "SUCCESS" "Terraform deployment completed successfully"
}

# Destroy Terraform resources
destroy_deployment() {
    log "WARN" "Destroying Terraform resources..."
    
    cd "$TERRAFORM_DIR" || error_exit "Failed to change to Terraform directory"
    
    # Warning message
    echo
    echo -e "${RED}WARNING: This will destroy all resources managed by Terraform!${NC}"
    echo -e "${RED}This action cannot be undone!${NC}"
    echo
    echo -e "${RED}Are you sure you want to continue? (type 'yes' to confirm): ${NC}"
    read -r confirmation
    
    if [[ "$confirmation" == "yes" ]]; then
        if [[ "$AUTO_APPROVE" == "true" ]]; then
            terraform destroy -var-file="$CONFIG_FILE" -auto-approve || \
                error_exit "Terraform destroy failed"
        else
            terraform destroy -var-file="$CONFIG_FILE" || \
                error_exit "Terraform destroy failed"
        fi
        log "SUCCESS" "Resources destroyed successfully"
    else
        log "INFO" "Destroy operation cancelled"
    fi
}

# Validate deployment
validate_deployment() {
    log "INFO" "Performing post-deployment validation..."
    
    # Check VPC networks
    log "INFO" "Validating VPC networks..."
    local networks
    networks=$(gcloud compute networks list --format="value(name)" --filter="name:*vpc" 2>/dev/null || echo "")
    if [[ -n "$networks" ]]; then
        log "INFO" "Found VPC networks: $(echo "$networks" | tr '\n' ', ' | sed 's/,$//')"
    else
        log "WARN" "No VPC networks found"
    fi
    
    # Check firewall rules
    log "INFO" "Validating firewall rules..."
    local firewall_count
    firewall_count=$(gcloud compute firewall-rules list --format="value(name)" 2>/dev/null | wc -l)
    log "INFO" "Found $firewall_count firewall rules"
    
    # Check IAM policies
    log "INFO" "Validating IAM policies..."
    local iam_bindings_count
    if command -v jq &> /dev/null; then
        iam_bindings_count=$(gcloud projects get-iam-policy "$PROJECT_ID" --format=json 2>/dev/null | \
            jq '.bindings | length' || echo "0")
    else
        iam_bindings_count="unknown"
    fi
    log "INFO" "Found $iam_bindings_count IAM policy bindings"
    
    # Check enabled APIs
    log "INFO" "Validating enabled APIs..."
    local enabled_apis_count
    enabled_apis_count=$(gcloud services list --enabled --format="value(name)" 2>/dev/null | wc -l)
    log "INFO" "Found $enabled_apis_count enabled APIs"
    
    log "SUCCESS" "Post-deployment validation completed"
}

# Generate deployment report
generate_deployment_report() {
    log "INFO" "Generating deployment report..."
    
    local report_file="$SCRIPT_DIR/deployment_report_$(date +%Y%m%d_%H%M%S).json"
    local end_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Create deployment report
    cat > "$report_file" << EOF
{
  "deployment_info": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "project_id": "$PROJECT_ID",
    "organization_id": "$ORGANIZATION_ID",
    "region": "$REGION",
    "environment": "$ENVIRONMENT",
    "config_file": "$CONFIG_FILE"
  },
  "execution_info": {
    "script_version": "1.0",
    "log_file": "$LOG_FILE",
    "auto_approve": $AUTO_APPROVE,
    "plan_only": $PLAN_ONLY,
    "destroy": $DESTROY
  }
}
EOF
    
    # Add Terraform outputs if available
    if [[ -d "$TERRAFORM_DIR" ]] && cd "$TERRAFORM_DIR" 2>/dev/null; then
        if terraform output -json &> /dev/null; then
            local terraform_outputs
            terraform_outputs=$(terraform output -json 2>/dev/null || echo "{}")
            
            # Update report with Terraform data
            if command -v jq &> /dev/null; then
                local temp_report=$(mktemp)
                jq --argjson outputs "$terraform_outputs" '.terraform_outputs = $outputs' "$report_file" > "$temp_report"
                mv "$temp_report" "$report_file"
            fi
        fi
    fi
    
    log "SUCCESS" "Deployment report saved to: $report_file"
}

# Cleanup temporary files
cleanup() {
    log "INFO" "Performing cleanup..."
    
    # Remove temporary files
    find "$SCRIPT_DIR" -name "lifecycle.json" -delete 2>/dev/null || true
    find "$TERRAFORM_DIR" -name "tfplan_*" -type f -delete 2>/dev/null || true
    
    log "INFO" "Cleanup completed"
}

# Main deployment function
main_deployment() {
    local deployment_start_time=$(date +%s)
    
    log "INFO" "Starting Google Cloud Landing Zone deployment"
    log "INFO" "Project: $PROJECT_ID"
    log "INFO" "Organization: $ORGANIZATION_ID"
    log "INFO" "Region: $REGION"
    log "INFO" "Environment: $ENVIRONMENT"
    log "INFO" "Log file: $LOG_FILE"
    
    # Execute deployment steps
    check_prerequisites
    validate_configuration
    
    if [[ "$DESTROY" == "true" ]]; then
        initialize_terraform
        destroy_deployment
    else
        setup_google_cloud_project
        setup_terraform_backend
        initialize_terraform
        
        local plan_file
        plan_file=$(plan_deployment)
        
        if [[ "$PLAN_ONLY" == "true" ]]; then
            log "INFO" "Plan-only mode: Skipping apply phase"
        else
            if apply_deployment "$plan_file"; then
                validate_deployment
            else
                log "WARN" "Deployment was cancelled or failed"
                return 1
            fi
        fi
    fi
    
    local deployment_end_time=$(date +%s)
    local deployment_duration=$((deployment_end_time - deployment_start_time))
    log "SUCCESS" "Script execution completed in ${deployment_duration} seconds"
}

# Signal handlers
cleanup_on_exit() {
    cleanup
    generate_deployment_report
}

# Set trap for cleanup
trap cleanup_on_exit EXIT

# Main execution
main() {
    parse_arguments "$@"
    
    # Enable verbose mode if requested
    if [[ "$VERBOSE" == "true" ]]; then
        set -x
    fi
    
    main_deployment
}

# Execute main function with all arguments
main "$@"
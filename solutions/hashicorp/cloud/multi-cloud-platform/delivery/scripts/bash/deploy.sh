#!/bin/bash

# HashiCorp Multi-Cloud Infrastructure Management Platform Deployment Script
# This script automates the deployment of the complete HashiCorp multi-cloud platform

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "${SCRIPT_DIR}")")"
LOG_FILE="/tmp/hashicorp-multicloud-deploy-$(date +%Y%m%d-%H%M%S).log"
TERRAFORM_DIR="${PROJECT_ROOT}/scripts/terraform"
ANSIBLE_DIR="${PROJECT_ROOT}/scripts/ansible"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
ENVIRONMENT="${ENVIRONMENT:-development}"
DRY_RUN="${DRY_RUN:-false}"
SKIP_PREREQS="${SKIP_PREREQS:-false}"
VERBOSE="${VERBOSE:-false}"
AUTO_APPROVE="${AUTO_APPROVE:-false}"

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS] [ENVIRONMENT]

Deploy HashiCorp Multi-Cloud Infrastructure Management Platform

ARGUMENTS:
    ENVIRONMENT         Target environment (development, staging, production) [default: development]

OPTIONS:
    -h, --help          Show this help message
    -d, --dry-run       Perform a dry run without making changes
    -s, --skip-prereqs  Skip prerequisite checks
    -v, --verbose       Enable verbose output
    -a, --auto-approve  Auto-approve Terraform changes (USE WITH CAUTION)
    -l, --log-level     Set log level (DEBUG, INFO, WARN, ERROR) [default: INFO]
    
EXAMPLES:
    $0 development                     # Deploy to development environment
    $0 production --dry-run            # Dry run for production
    $0 staging --verbose --auto-approve # Deploy staging with verbose output

EOF
}

# Logging functions
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
    
    case $level in
        ERROR)
            echo -e "${RED}[ERROR] ${message}${NC}" >&2
            ;;
        WARN)
            echo -e "${YELLOW}[WARN] ${message}${NC}"
            ;;
        INFO)
            echo -e "${GREEN}[INFO] ${message}${NC}"
            ;;
        DEBUG)
            if [[ "$VERBOSE" == "true" ]]; then
                echo -e "${BLUE}[DEBUG] ${message}${NC}"
            fi
            ;;
    esac
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_debug() { log "DEBUG" "$@"; }

# Error handling
error_exit() {
    log_error "$1"
    cleanup_on_error
    exit 1
}

cleanup_on_error() {
    log_warn "Deployment failed. Check logs at: $LOG_FILE"
    log_info "Run './cleanup.sh' if you need to clean up partial deployments"
}

# Trap for cleanup on script exit
trap 'cleanup_on_error' ERR

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--skip-prereqs)
                SKIP_PREREQS=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -a|--auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -l|--log-level)
                LOG_LEVEL="$2"
                shift 2
                ;;
            development|staging|production)
                ENVIRONMENT="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Prerequisite checks
check_prerequisites() {
    if [[ "$SKIP_PREREQS" == "true" ]]; then
        log_info "Skipping prerequisite checks as requested"
        return 0
    fi
    
    log_info "Checking prerequisites..."
    
    # Check required commands
    local required_commands=(
        "terraform"
        "ansible"
        "ansible-playbook"
        "kubectl"
        "aws"
        "az"
        "gcloud"
        "consul"
        "vault"
        "nomad"
        "boundary"
        "curl"
        "jq"
    )
    
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_commands[*]}"
        error_exit "Please install missing prerequisites and try again"
    fi
    
    # Check Terraform version
    local terraform_version
    terraform_version=$(terraform version -json | jq -r '.terraform_version')
    local required_terraform_version="1.5.0"
    
    if ! printf '%s\n' "$required_terraform_version" "$terraform_version" | sort -V -C; then
        error_exit "Terraform version $terraform_version is less than required version $required_terraform_version"
    fi
    
    # Check cloud authentication
    log_info "Verifying cloud provider authentication..."
    
    # AWS authentication
    if ! aws sts get-caller-identity &> /dev/null; then
        error_exit "AWS authentication failed. Please run 'aws configure' or set AWS credentials"
    fi
    
    # Azure authentication
    if ! az account show &> /dev/null; then
        error_exit "Azure authentication failed. Please run 'az login'"
    fi
    
    # GCP authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        error_exit "GCP authentication failed. Please run 'gcloud auth login'"
    fi
    
    log_info "All prerequisites satisfied"
}

# Validate configuration
validate_configuration() {
    log_info "Validating configuration for environment: $ENVIRONMENT"
    
    local tfvars_file="${TERRAFORM_DIR}/terraform.tfvars"
    
    if [[ ! -f "$tfvars_file" ]]; then
        log_warn "terraform.tfvars not found, creating from example"
        if [[ -f "${TERRAFORM_DIR}/terraform.tfvars.example" ]]; then
            cp "${TERRAFORM_DIR}/terraform.tfvars.example" "$tfvars_file"
            log_warn "Please edit $tfvars_file with your specific configuration"
        else
            error_exit "terraform.tfvars.example not found"
        fi
    fi
    
    # Environment-specific validation
    case $ENVIRONMENT in
        development)
            log_info "Development environment - minimal configuration"
            ;;
        staging)
            log_info "Staging environment - testing configuration"
            ;;
        production)
            log_info "Production environment - high availability configuration"
            if [[ "$AUTO_APPROVE" == "true" ]]; then
                log_warn "Auto-approve is enabled for production - this is not recommended"
                read -p "Are you sure you want to continue? (y/N): " -r
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Deployment cancelled by user"
                    exit 0
                fi
            fi
            ;;
        *)
            error_exit "Invalid environment: $ENVIRONMENT. Must be development, staging, or production"
            ;;
    esac
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    log_info "Starting infrastructure deployment with Terraform"
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    if [[ "$VERBOSE" == "true" ]]; then
        terraform init
    else
        terraform init > /dev/null 2>&1
    fi
    
    # Validate configuration
    log_info "Validating Terraform configuration..."
    terraform validate
    
    # Plan deployment
    log_info "Planning infrastructure deployment..."
    local plan_file="/tmp/terraform-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).plan"
    
    terraform plan \
        -var-file="terraform.tfvars" \
        -var="environment=${ENVIRONMENT}" \
        -out="$plan_file"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run mode - stopping after plan"
        rm -f "$plan_file"
        return 0
    fi
    
    # Apply infrastructure
    log_info "Applying infrastructure changes..."
    
    if [[ "$AUTO_APPROVE" == "true" ]]; then
        terraform apply -auto-approve "$plan_file"
    else
        terraform apply "$plan_file"
    fi
    
    # Clean up plan file
    rm -f "$plan_file"
    
    log_info "Infrastructure deployment completed"
}

# Configure services with Ansible
configure_services() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run mode - skipping service configuration"
        return 0
    fi
    
    log_info "Starting service configuration with Ansible"
    
    cd "$ANSIBLE_DIR"
    
    # Check Ansible inventory
    if [[ ! -f "inventory.yml" ]]; then
        log_info "Generating dynamic inventory..."
        python3 scripts/generate_inventory.py > inventory.yml
    fi
    
    # Run Ansible playbook
    local ansible_args=()
    
    if [[ "$VERBOSE" == "true" ]]; then
        ansible_args+=("-vvv")
    fi
    
    ansible_args+=(
        "-i" "inventory.yml"
        "playbook.yml"
        "--extra-vars" "environment=${ENVIRONMENT}"
    )
    
    ansible-playbook "${ansible_args[@]}"
    
    log_info "Service configuration completed"
}

# Health checks
run_health_checks() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run mode - skipping health checks"
        return 0
    fi
    
    log_info "Running health checks..."
    
    # Run health check script
    local health_script="${SCRIPT_DIR}/health-check.sh"
    
    if [[ -f "$health_script" ]]; then
        if [[ "$VERBOSE" == "true" ]]; then
            bash "$health_script" --verbose
        else
            bash "$health_script"
        fi
    else
        log_warn "Health check script not found, running basic checks"
        
        # Basic service checks
        local services=(
            "https://consul.${DOMAIN:-hashicorp.yourdomain.com}:8500/v1/status/leader"
            "https://vault.${DOMAIN:-hashicorp.yourdomain.com}:8200/v1/sys/health"
            "https://nomad.${DOMAIN:-hashicorp.yourdomain.com}:4646/v1/status/leader"
        )
        
        for service in "${services[@]}"; do
            if curl -sf "$service" > /dev/null; then
                log_info "Service check passed: $service"
            else
                log_warn "Service check failed: $service"
            fi
        done
    fi
}

# Generate deployment report
generate_report() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run completed successfully"
        return 0
    fi
    
    log_info "Generating deployment report..."
    
    local report_file="/tmp/deployment-report-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).txt"
    
    cat > "$report_file" << EOF
HashiCorp Multi-Cloud Platform Deployment Report
================================================

Deployment Details:
- Environment: $ENVIRONMENT
- Timestamp: $(date)
- Log File: $LOG_FILE
- Deployed By: $(whoami)

Service Endpoints:
$(cd "$TERRAFORM_DIR" && terraform output -json | jq -r '.quick_start_urls.value | to_entries[] | "- \(.key): \(.value)"' 2>/dev/null || echo "Unable to retrieve endpoints")

Next Steps:
1. Access the HashiCorp product UIs using the endpoints above
2. Configure your applications to use the platform
3. Set up monitoring and alerting
4. Review and customize security policies
5. Plan for regular maintenance and updates

For support, refer to the operations runbook and troubleshooting guides.
EOF
    
    log_info "Deployment report generated: $report_file"
    
    # Display summary
    cat "$report_file"
}

# Main deployment function
main() {
    log_info "Starting HashiCorp Multi-Cloud Platform deployment"
    log_info "Environment: $ENVIRONMENT"
    log_info "Dry Run: $DRY_RUN"
    log_info "Log File: $LOG_FILE"
    
    # Pre-deployment steps
    check_prerequisites
    validate_configuration
    
    # Deployment phases
    deploy_infrastructure
    configure_services
    
    # Post-deployment steps
    run_health_checks
    generate_report
    
    log_info "Deployment completed successfully!"
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        log_info "Production deployment complete. Please review the deployment report and run additional validation tests."
    fi
}

# Cleanup function
cleanup() {
    log_debug "Cleaning up temporary files..."
    # Add any cleanup logic here
}

# Set up trap for cleanup
trap cleanup EXIT

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
    main
fi
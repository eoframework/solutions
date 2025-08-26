#!/bin/bash
# HashiCorp Terraform Enterprise Deployment Script
# Deploys TFE platform on AWS EKS with complete automation

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
readonly LOG_FILE="${PROJECT_ROOT}/deployment-$(date +%Y%m%d-%H%M%S).log"

# Default configuration
ENVIRONMENT="${ENVIRONMENT:-prod}"
CONFIG_FILE="${CONFIG_FILE:-}"
VALIDATE_ONLY="${VALIDATE_ONLY:-false}"
SKIP_PREREQUISITES="${SKIP_PREREQUISITES:-false}"
ENABLE_MONITORING="${ENABLE_MONITORING:-false}"
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$level" in
        "INFO")  echo -e "${BLUE}[INFO]${NC}  ${message}" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC}  ${message}" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} ${message}" >&2 ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} ${message}" ;;
    esac
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

info() { log "INFO" "$@"; }
warn() { log "WARN" "$@"; }
error() { log "ERROR" "$@"; }
success() { log "SUCCESS" "$@"; }

# Error handling
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Deployment failed with exit code $exit_code"
        error "Check the log file: $LOG_FILE"
    fi
    exit $exit_code
}
trap cleanup EXIT

# Usage information
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Deploy HashiCorp Terraform Enterprise on AWS EKS

OPTIONS:
    -e, --environment ENV       Target environment (dev, staging, prod) [default: prod]
    -c, --config-file FILE      Configuration file path
    -v, --validate-only         Perform validation without deployment
    -s, --skip-prerequisites    Skip prerequisite validation
    -m, --enable-monitoring     Deploy monitoring stack
    -n, --dry-run              Show what would be deployed
    --verbose                  Enable verbose logging
    -h, --help                 Show this help message

EXAMPLES:
    $SCRIPT_NAME --environment prod
    $SCRIPT_NAME --config-file config.yaml --validate-only
    $SCRIPT_NAME --environment staging --enable-monitoring
    
ENVIRONMENT VARIABLES:
    TFE_LICENSE                 Terraform Enterprise license (required)
    TFE_TOKEN                   TFE API token (for validation)
    AWS_ACCESS_KEY_ID           AWS access key
    AWS_SECRET_ACCESS_KEY       AWS secret key
    AWS_DEFAULT_REGION          AWS region [default: us-east-1]

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -c|--config-file)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -v|--validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            -s|--skip-prerequisites)
                SKIP_PREREQUISITES=true
                shift
                ;;
            -m|--enable-monitoring)
                ENABLE_MONITORING=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                set -x
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Load configuration
load_config() {
    # Set defaults
    PROJECT_NAME="${PROJECT_NAME:-terraform-enterprise}"
    AWS_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    KUBERNETES_VERSION="${KUBERNETES_VERSION:-1.28}"
    TFE_HOSTNAME="${TFE_HOSTNAME:-terraform.company.com}"
    
    # Load environment-specific config file if provided
    if [[ -n "$CONFIG_FILE" ]]; then
        if [[ -f "$CONFIG_FILE" ]]; then
            info "Loading configuration from $CONFIG_FILE"
            source "$CONFIG_FILE"
        else
            error "Configuration file not found: $CONFIG_FILE"
            exit 1
        fi
    fi
    
    # Load default environment config
    local env_config="${PROJECT_ROOT}/environments/${ENVIRONMENT}.env"
    if [[ -f "$env_config" ]]; then
        info "Loading environment configuration: $env_config"
        source "$env_config"
    fi
}

# Prerequisite validation
validate_prerequisites() {
    if [[ "$SKIP_PREREQUISITES" == "true" ]]; then
        warn "Skipping prerequisite validation"
        return 0
    fi
    
    info "Validating prerequisites..."
    
    # Check required tools
    local required_tools=("terraform" "kubectl" "helm" "aws" "jq")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "Required tool not found: $tool"
            return 1
        else
            local version
            case "$tool" in
                "terraform") version=$(terraform version | head -n1) ;;
                "kubectl") version=$(kubectl version --client --short 2>/dev/null || echo "kubectl client") ;;
                "helm") version=$(helm version --short) ;;
                "aws") version=$(aws --version) ;;
                "jq") version=$(jq --version) ;;
            esac
            info "✓ $tool: $version"
        fi
    done
    
    # Check environment variables
    local required_vars=("TFE_LICENSE")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            error "Required environment variable not set: $var"
            return 1
        else
            info "✓ Environment variable $var is set"
        fi
    done
    
    # Validate AWS credentials
    info "Validating AWS credentials..."
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials not configured or invalid"
        return 1
    else
        local aws_account
        aws_account=$(aws sts get-caller-identity --query Account --output text)
        local aws_user
        aws_user=$(aws sts get-caller-identity --query Arn --output text)
        info "✓ AWS Account: $aws_account"
        info "✓ AWS User/Role: $aws_user"
    fi
    
    success "Prerequisites validation passed"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    info "Deploying infrastructure with Terraform..."
    
    local terraform_dir="${PROJECT_ROOT}/delivery/scripts/terraform"
    
    if [[ ! -d "$terraform_dir" ]]; then
        error "Terraform directory not found: $terraform_dir"
        return 1
    fi
    
    pushd "$terraform_dir" > /dev/null
    
    # Initialize Terraform
    info "Initializing Terraform..."
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would run: terraform init"
    else
        if ! terraform init; then
            error "Terraform initialization failed"
            popd > /dev/null
            return 1
        fi
    fi
    
    # Create terraform.tfvars if it doesn't exist
    if [[ ! -f terraform.tfvars ]]; then
        info "Creating terraform.tfvars from template..."
        cat > terraform.tfvars << EOF
project_name         = "${PROJECT_NAME}"
environment          = "${ENVIRONMENT}"
aws_region          = "${AWS_REGION}"
kubernetes_version  = "${KUBERNETES_VERSION}"
tfe_hostname        = "${TFE_HOSTNAME}"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
private_subnet_cidrs = [
  "10.0.10.0/24",
  "10.0.11.0/24",
  "10.0.12.0/24"
]

# EKS Configuration
node_instance_types = ["m5.xlarge"]
min_node_count     = 3
max_node_count     = 10
desired_node_count = 6

# Database Configuration
postgres_version      = "14.9"
db_instance_class    = "db.r5.xlarge"
db_allocated_storage = 500
enable_multi_az      = true

# Security Configuration
enable_encryption = true
allowed_cidr_blocks = [
  "0.0.0.0/0"  # Update this for production
]
EOF
    fi
    
    # Plan deployment
    info "Planning Terraform deployment..."
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would run: terraform plan -var-file=terraform.tfvars"
    else
        if ! terraform plan -var-file=terraform.tfvars -out=tfe.tfplan; then
            error "Terraform planning failed"
            popd > /dev/null
            return 1
        fi
    fi
    
    # Apply deployment (if not validate-only)
    if [[ "$VALIDATE_ONLY" == "false" ]]; then
        info "Applying Terraform deployment..."
        if [[ "$DRY_RUN" == "true" ]]; then
            info "[DRY RUN] Would run: terraform apply tfe.tfplan"
        else
            if ! terraform apply tfe.tfplan; then
                error "Terraform apply failed"
                popd > /dev/null
                return 1
            fi
            
            # Extract outputs
            info "Extracting infrastructure outputs..."
            terraform output -json > outputs.json
            
            # Set variables from outputs
            export CLUSTER_NAME=$(terraform output -raw cluster_name)
            export CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
            export DATABASE_ENDPOINT=$(terraform output -raw database_endpoint)
            export S3_BUCKET=$(terraform output -raw s3_bucket_name)
            
            info "Infrastructure deployed successfully:"
            info "  EKS Cluster: $CLUSTER_NAME"
            info "  Database: $DATABASE_ENDPOINT"
            info "  S3 Bucket: $S3_BUCKET"
        fi
    fi
    
    popd > /dev/null
    success "Infrastructure deployment completed"
}

# Configure Kubernetes
configure_kubernetes() {
    info "Configuring Kubernetes access..."
    
    if [[ -z "${CLUSTER_NAME:-}" ]]; then
        error "CLUSTER_NAME not set. Infrastructure may not be deployed."
        return 1
    fi
    
    # Update kubeconfig
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would run: aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME"
    else
        if ! aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"; then
            error "Failed to update kubeconfig"
            return 1
        fi
    fi
    
    # Verify cluster connectivity
    if [[ "$DRY_RUN" == "false" ]]; then
        info "Verifying cluster connectivity..."
        if ! kubectl get nodes > /dev/null; then
            error "Cannot connect to Kubernetes cluster"
            return 1
        fi
        
        local node_count
        node_count=$(kubectl get nodes --no-headers | wc -l)
        info "✓ Connected to cluster with $node_count nodes"
    fi
    
    # Add Helm repositories
    info "Adding HashiCorp Helm repository..."
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would run: helm repo add hashicorp https://helm.releases.hashicorp.com"
    else
        helm repo add hashicorp https://helm.releases.hashicorp.com
        helm repo update
    fi
    
    success "Kubernetes configuration completed"
}

# Deploy Terraform Enterprise
deploy_tfe() {
    info "Deploying Terraform Enterprise..."
    
    # Create namespace
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would create terraform-enterprise namespace"
    else
        kubectl create namespace terraform-enterprise --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    # Create secrets
    info "Creating TFE secrets..."
    if [[ "$DRY_RUN" == "false" ]]; then
        # TFE License
        kubectl create secret generic tfe-license \
            --from-literal=license="$TFE_LICENSE" \
            --namespace=terraform-enterprise \
            --dry-run=client -o yaml | kubectl apply -f -
        
        # Database credentials
        kubectl create secret generic tfe-database-credentials \
            --from-literal=host="$DATABASE_ENDPOINT" \
            --from-literal=database="terraform_enterprise" \
            --from-literal=username="tfe" \
            --from-literal=password="$(openssl rand -base64 32)" \
            --from-literal=url="postgresql://tfe:$(openssl rand -base64 32)@$DATABASE_ENDPOINT:5432/terraform_enterprise?sslmode=require" \
            --namespace=terraform-enterprise \
            --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    # Generate Helm values
    local values_file="/tmp/tfe-values-${ENVIRONMENT}.yaml"
    cat > "$values_file" << EOF
replicaCount: 3

image:
  repository: hashicorp/terraform-enterprise
  tag: "v202401-1"
  pullPolicy: Always

tfe:
  hostname: "${TFE_HOSTNAME}"
  
  database:
    external: true
    host: "${DATABASE_ENDPOINT}"
    name: "terraform_enterprise"
    username: "tfe"
    passwordSecret: "tfe-database-credentials"
    passwordSecretKey: "password"
    
  objectStorage:
    type: "s3"
    bucket: "${S3_BUCKET}"
    region: "${AWS_REGION}"
    
  license:
    secret: "tfe-license"
    key: "license"
    
  resources:
    requests:
      cpu: "2000m"
      memory: "4Gi"
    limits:
      cpu: "4000m"
      memory: "8Gi"

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: "443"
    alb.ingress.kubernetes.io/healthcheck-path: "/_health_check"
  hosts:
    - host: "${TFE_HOSTNAME}"
      paths:
        - path: /
          pathType: Prefix

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

podDisruptionBudget:
  enabled: true
  minAvailable: 2
EOF
    
    # Deploy with Helm
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would deploy TFE with Helm using values from $values_file"
    else
        info "Deploying TFE with Helm..."
        if ! helm upgrade --install terraform-enterprise hashicorp/terraform-enterprise \
                --namespace terraform-enterprise \
                --values "$values_file" \
                --wait --timeout 600s; then
            error "TFE Helm deployment failed"
            return 1
        fi
    fi
    
    success "Terraform Enterprise deployed successfully"
}

# Deploy monitoring stack
deploy_monitoring() {
    if [[ "$ENABLE_MONITORING" == "false" ]]; then
        return 0
    fi
    
    info "Deploying monitoring stack..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would deploy monitoring stack"
        return 0
    fi
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Add monitoring Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Deploy Prometheus
    info "Deploying Prometheus..."
    helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set grafana.adminPassword=admin123 \
        --wait --timeout 600s
    
    # Create TFE ServiceMonitor
    kubectl apply -f - << EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: terraform-enterprise
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: terraform-enterprise
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
  namespaceSelector:
    matchNames:
    - terraform-enterprise
EOF
    
    success "Monitoring stack deployed successfully"
}

# Validate deployment
validate_deployment() {
    info "Validating TFE deployment..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        info "[DRY RUN] Would validate deployment"
        return 0
    fi
    
    # Check pod status
    info "Checking pod status..."
    local ready_pods
    ready_pods=$(kubectl get pods -n terraform-enterprise -o json | jq -r '.items[] | select(.status.phase=="Running") | .metadata.name' | wc -l)
    local total_pods
    total_pods=$(kubectl get pods -n terraform-enterprise --no-headers | wc -l)
    
    info "Pods status: $ready_pods/$total_pods running"
    
    if [[ $ready_pods -eq 0 ]]; then
        error "No pods are running"
        kubectl get pods -n terraform-enterprise
        return 1
    fi
    
    # Wait for TFE to be ready
    info "Waiting for TFE to be accessible..."
    local max_attempts=20
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -sf "https://${TFE_HOSTNAME}/_health_check" > /dev/null 2>&1; then
            success "TFE is accessible at https://${TFE_HOSTNAME}"
            break
        fi
        
        info "Attempt $attempt/$max_attempts: TFE not ready yet, waiting 30 seconds..."
        sleep 30
        ((attempt++))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        error "TFE did not become accessible within expected time"
        return 1
    fi
    
    # Test API endpoint
    info "Testing TFE API..."
    if curl -sf "https://${TFE_HOSTNAME}/api/v2/ping" > /dev/null; then
        success "TFE API is responding"
    else
        warn "TFE API test failed - this may be normal during initial setup"
    fi
    
    success "Deployment validation completed"
}

# Generate deployment report
generate_report() {
    info "Generating deployment report..."
    
    local report_file="${PROJECT_ROOT}/deployment-report-${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" << EOF
# Terraform Enterprise Deployment Report

**Environment**: $ENVIRONMENT  
**Deployment Date**: $(date)  
**Deployed by**: $(whoami)  

## Infrastructure Details

- **AWS Region**: $AWS_REGION
- **EKS Cluster**: ${CLUSTER_NAME:-"Not deployed"}
- **Database**: ${DATABASE_ENDPOINT:-"Not deployed"}
- **S3 Bucket**: ${S3_BUCKET:-"Not deployed"}

## Application Details

- **TFE Hostname**: $TFE_HOSTNAME
- **TFE Version**: v202401-1
- **Replicas**: 3
- **Namespace**: terraform-enterprise

## Access Information

- **Web UI**: https://$TFE_HOSTNAME
- **Health Check**: https://$TFE_HOSTNAME/_health_check
- **API Endpoint**: https://$TFE_HOSTNAME/api/v2

## Next Steps

1. Complete initial admin setup: https://$TFE_HOSTNAME/admin/account/new
2. Configure authentication (SAML/OIDC)
3. Create first organization
4. Create workspaces and upload Terraform configurations
5. Configure team access and permissions

## Support

- **Log File**: $LOG_FILE
- **Deployment Report**: $report_file
- **Documentation**: $PROJECT_ROOT/README.md

EOF
    
    success "Deployment report generated: $report_file"
    
    # Display summary
    echo
    echo "=========================================="
    echo "🎉 TFE Deployment Summary"
    echo "=========================================="
    echo "Environment: $ENVIRONMENT"
    echo "TFE URL: https://$TFE_HOSTNAME"
    echo "Status: $(if [[ "$VALIDATE_ONLY" == "true" ]]; then echo "Validated"; else echo "Deployed"; fi)"
    echo
    echo "Next steps:"
    echo "1. Access TFE at https://$TFE_HOSTNAME"
    echo "2. Complete admin setup"
    echo "3. Configure authentication"
    echo "=========================================="
    echo
}

# Main execution function
main() {
    info "Starting HashiCorp Terraform Enterprise deployment"
    info "Environment: $ENVIRONMENT"
    info "Log file: $LOG_FILE"
    
    # Load configuration
    load_config
    
    # Validate prerequisites
    validate_prerequisites
    
    # Deploy infrastructure
    deploy_infrastructure
    
    if [[ "$VALIDATE_ONLY" == "false" ]]; then
        # Configure Kubernetes
        configure_kubernetes
        
        # Deploy TFE
        deploy_tfe
        
        # Deploy monitoring (if enabled)
        deploy_monitoring
    fi
    
    # Validate deployment
    validate_deployment
    
    # Generate report
    generate_report
    
    success "Deployment completed successfully!"
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_args "$@"
    main
fi
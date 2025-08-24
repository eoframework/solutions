#!/bin/bash

# IBM Ansible Automation Platform - Deployment Script
# This script automates the deployment of IBM Ansible Automation Platform on Red Hat OpenShift

set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
LOG_FILE="/tmp/aap-deployment-$(date +%Y%m%d-%H%M%S).log"
OPENSHIFT_NAMESPACE="${OPENSHIFT_NAMESPACE:-ansible-automation}"
DOMAIN_NAME="${DOMAIN_NAME:-automation.company.com}"
AAP_VERSION="${AAP_VERSION:-2.4}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${2:-$NC}$(date '+%Y-%m-%d %H:%M:%S') - $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1" "$RED"
    exit 1
}

warn() {
    log "WARNING: $1" "$YELLOW"
}

info() {
    log "INFO: $1" "$BLUE"
}

success() {
    log "SUCCESS: $1" "$GREEN"
}

# Function to check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check required tools
    local tools=("oc" "ansible-playbook" "jq")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "$tool is required but not installed"
        fi
    done
    
    # Check environment variables
    local env_vars=("AAP_ADMIN_PASSWORD" "OPENSHIFT_TOKEN" "AAP_LICENSE_MANIFEST")
    for var in "${env_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            error "Environment variable $var is required"
        fi
    done
    
    # Check OpenShift connectivity
    if ! oc whoami &>/dev/null; then
        error "Not logged into OpenShift. Please run 'oc login' first"
    fi
    
    # Verify cluster permissions
    if ! oc auth can-i create namespace &>/dev/null; then
        error "Insufficient permissions. Cluster admin access required"
    fi
    
    success "All prerequisites validated"
}

# Function to setup environment
setup_environment() {
    info "Setting up deployment environment..."
    
    # Create temporary directory for configuration
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT
    
    # Login to OpenShift with token
    oc login --token="$OPENSHIFT_TOKEN" || error "Failed to login to OpenShift"
    
    # Display cluster information
    info "Connected to cluster: $(oc config current-context)"
    info "Current user: $(oc whoami)"
    
    success "Environment setup complete"
}

# Function to validate resources
validate_resources() {
    info "Validating cluster resources..."
    
    # Get cluster resource information
    local nodes
    nodes=$(oc get nodes --no-headers | wc -l)
    info "Available nodes: $nodes"
    
    # Check storage classes
    local storage_classes
    storage_classes=$(oc get storageclass --no-headers | wc -l)
    if [[ $storage_classes -eq 0 ]]; then
        error "No storage classes available. Storage classes are required for persistent volumes"
    fi
    info "Available storage classes: $storage_classes"
    
    # Check if namespace already exists
    if oc get namespace "$OPENSHIFT_NAMESPACE" &>/dev/null; then
        warn "Namespace $OPENSHIFT_NAMESPACE already exists"
        read -p "Continue with existing namespace? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Deployment cancelled by user"
        fi
    fi
    
    success "Resource validation complete"
}

# Function to install operator
install_operator() {
    info "Installing Ansible Automation Platform Operator..."
    
    # Create operator namespace
    oc create namespace ansible-automation-platform-operator --dry-run=client -o yaml | oc apply -f -
    
    # Create operator group
    cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ansible-automation-platform-operator
  namespace: ansible-automation-platform-operator
spec:
  targetNamespaces:
  - ansible-automation-platform-operator
EOF

    # Create subscription
    cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ansible-automation-platform-operator
  namespace: ansible-automation-platform-operator
spec:
  channel: stable-2.4-cluster-scoped
  name: ansible-automation-platform-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    # Wait for operator installation
    info "Waiting for operator installation (this may take a few minutes)..."
    local timeout=600
    local elapsed=0
    
    while [[ $elapsed -lt $timeout ]]; do
        if oc get csv -n ansible-automation-platform-operator | grep -q "Succeeded"; then
            break
        fi
        sleep 10
        elapsed=$((elapsed + 10))
        info "Waiting... ($elapsed/$timeout seconds)"
    done
    
    if [[ $elapsed -ge $timeout ]]; then
        error "Operator installation timed out"
    fi
    
    success "Operator installed successfully"
}

# Function to create namespace and secrets
create_namespace_and_secrets() {
    info "Creating namespace and secrets..."
    
    # Create namespace
    oc create namespace "$OPENSHIFT_NAMESPACE" --dry-run=client -o yaml | oc apply -f -
    
    # Create admin password secret
    oc create secret generic automation-controller-admin-password \
        --from-literal=password="$AAP_ADMIN_PASSWORD" \
        -n "$OPENSHIFT_NAMESPACE" --dry-run=client -o yaml | oc apply -f -
    
    # Create license manifest secret
    echo "$AAP_LICENSE_MANIFEST" | base64 -d > "$TEMP_DIR/manifest.zip"
    oc create secret generic automation-controller-license \
        --from-file=manifest.zip="$TEMP_DIR/manifest.zip" \
        -n "$OPENSHIFT_NAMESPACE" --dry-run=client -o yaml | oc apply -f -
    
    # Generate and create database password secret
    local db_password
    db_password=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)
    oc create secret generic postgres-admin-password \
        --from-literal=password="$db_password" \
        -n "$OPENSHIFT_NAMESPACE" --dry-run=client -o yaml | oc apply -f -
    
    success "Namespace and secrets created"
}

# Function to deploy platform components
deploy_platform() {
    info "Deploying Ansible Automation Platform components..."
    
    # Run the Ansible playbook
    cd "$PROJECT_ROOT"
    ansible-playbook \
        delivery/scripts/ansible/playbook.yml \
        -e "openshift_namespace=$OPENSHIFT_NAMESPACE" \
        -e "domain_name=$DOMAIN_NAME" \
        -e "aap_version=$AAP_VERSION" \
        --tags "operator,namespace,secrets,database,controller,hub,eda,monitoring" \
        -v
    
    success "Platform components deployed"
}

# Function to validate deployment
validate_deployment() {
    info "Validating deployment..."
    
    # Check pod status
    local pods
    pods=$(oc get pods -n "$OPENSHIFT_NAMESPACE" --field-selector=status.phase=Running --no-headers | wc -l)
    info "Running pods: $pods"
    
    # Check routes
    local controller_route
    controller_route=$(oc get route -n "$OPENSHIFT_NAMESPACE" -l app.kubernetes.io/name=automation-controller -o jsonpath='{.items[0].spec.host}' 2>/dev/null || echo "")
    
    if [[ -n "$controller_route" ]]; then
        info "Controller URL: https://$controller_route"
        
        # Test connectivity
        if curl -k -s "https://$controller_route/api/v2/ping/" | jq -r '.version' &>/dev/null; then
            success "Controller is accessible and responding"
        else
            warn "Controller may not be fully ready yet"
        fi
    else
        warn "Controller route not found"
    fi
    
    success "Deployment validation complete"
}

# Function to display summary
display_summary() {
    info "Deployment Summary"
    echo "======================================================" | tee -a "$LOG_FILE"
    echo "🎉 IBM Ansible Automation Platform Deployment Complete!" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Get routes
    local controller_route hub_route eda_route
    controller_route=$(oc get route -n "$OPENSHIFT_NAMESPACE" -l app.kubernetes.io/name=automation-controller -o jsonpath='{.items[0].spec.host}' 2>/dev/null || echo "Not available")
    hub_route=$(oc get route -n "$OPENSHIFT_NAMESPACE" -l app.kubernetes.io/name=automation-hub -o jsonpath='{.items[0].spec.host}' 2>/dev/null || echo "Not available")
    eda_route=$(oc get route -n "$OPENSHIFT_NAMESPACE" -l app.kubernetes.io/name=eda -o jsonpath='{.items[0].spec.host}' 2>/dev/null || echo "Not available")
    
    echo "📊 Controller: https://$controller_route" | tee -a "$LOG_FILE"
    echo "🏪 Hub: https://$hub_route" | tee -a "$LOG_FILE"
    echo "⚡ EDA: https://$eda_route" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "👤 Admin User: admin" | tee -a "$LOG_FILE"
    echo "🔐 Admin Password: [Set via AAP_ADMIN_PASSWORD]" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "📋 Namespace: $OPENSHIFT_NAMESPACE" | tee -a "$LOG_FILE"
    echo "🏗️ Platform Version: $AAP_VERSION" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "Next Steps:" | tee -a "$LOG_FILE"
    echo "1. Access the Controller UI to complete initial setup" | tee -a "$LOG_FILE"
    echo "2. Configure organizations and teams" | tee -a "$LOG_FILE"
    echo "3. Set up credential types and credentials" | tee -a "$LOG_FILE"
    echo "4. Upload automation content to Private Automation Hub" | tee -a "$LOG_FILE"
    echo "5. Configure event-driven automation rules" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "📝 Deployment log: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "======================================================" | tee -a "$LOG_FILE"
}

# Function to cleanup on error
cleanup() {
    warn "Cleaning up due to error..."
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Function to show usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy IBM Ansible Automation Platform on Red Hat OpenShift

OPTIONS:
    -h, --help              Show this help message
    -n, --namespace NAME    OpenShift namespace (default: ansible-automation)
    -d, --domain NAME       Base domain name (default: automation.company.com)
    -v, --version VERSION   AAP version (default: 2.4)
    --cleanup               Remove existing deployment
    --validate-only         Only validate prerequisites
    --dry-run               Show what would be deployed without making changes

ENVIRONMENT VARIABLES (required):
    AAP_ADMIN_PASSWORD      Admin password for the platform
    OPENSHIFT_TOKEN         OpenShift authentication token
    AAP_LICENSE_MANIFEST    Base64 encoded license manifest zip file

EXAMPLES:
    $0                                          # Deploy with defaults
    $0 -n my-aap -d aap.example.com            # Custom namespace and domain
    $0 --cleanup                               # Remove deployment
    $0 --validate-only                         # Check prerequisites only

EOF
}

# Function to cleanup deployment
cleanup_deployment() {
    info "Removing IBM Ansible Automation Platform deployment..."
    
    read -p "Are you sure you want to remove the deployment? This cannot be undone. (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Cleanup cancelled"
        exit 0
    fi
    
    # Run cleanup playbook
    cd "$PROJECT_ROOT"
    ansible-playbook \
        delivery/scripts/ansible/playbook.yml \
        -e "openshift_namespace=$OPENSHIFT_NAMESPACE" \
        --tags "cleanup" \
        -v
    
    # Remove operator if no other instances exist
    if ! oc get automationcontroller --all-namespaces --no-headers 2>/dev/null | grep -q .; then
        info "Removing operator (no other instances found)..."
        oc delete subscription ansible-automation-platform-operator -n ansible-automation-platform-operator --ignore-not-found
        oc delete csv -n ansible-automation-platform-operator -l operators.coreos.com/ansible-automation-platform-operator.ansible-automation-platform-operator --ignore-not-found
        oc delete namespace ansible-automation-platform-operator --ignore-not-found
    fi
    
    success "Cleanup complete"
}

# Main function
main() {
    local cleanup_mode=false
    local validate_only=false
    local dry_run=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -n|--namespace)
                OPENSHIFT_NAMESPACE="$2"
                shift 2
                ;;
            -d|--domain)
                DOMAIN_NAME="$2"
                shift 2
                ;;
            -v|--version)
                AAP_VERSION="$2"
                shift 2
                ;;
            --cleanup)
                cleanup_mode=true
                shift
                ;;
            --validate-only)
                validate_only=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
    
    # Set up error handling
    trap cleanup EXIT
    
    info "Starting IBM Ansible Automation Platform deployment"
    info "Log file: $LOG_FILE"
    
    # Handle cleanup mode
    if [[ "$cleanup_mode" == true ]]; then
        check_prerequisites
        setup_environment
        cleanup_deployment
        exit 0
    fi
    
    # Run deployment steps
    check_prerequisites
    
    if [[ "$validate_only" == true ]]; then
        success "Prerequisites validation complete"
        exit 0
    fi
    
    setup_environment
    validate_resources
    
    if [[ "$dry_run" == true ]]; then
        info "Dry run complete. Would proceed with deployment using:"
        info "  Namespace: $OPENSHIFT_NAMESPACE"
        info "  Domain: $DOMAIN_NAME"
        info "  Version: $AAP_VERSION"
        exit 0
    fi
    
    install_operator
    create_namespace_and_secrets
    deploy_platform
    validate_deployment
    display_summary
    
    success "IBM Ansible Automation Platform deployment completed successfully"
}

# Run main function
main "$@"
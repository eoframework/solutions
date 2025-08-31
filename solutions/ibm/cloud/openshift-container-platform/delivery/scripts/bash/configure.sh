#!/bin/bash
# IBM OpenShift Container Platform - Configuration Script
# Post-deployment OpenShift cluster configuration and setup

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.yml"
LOG_FILE="/var/log/openshift-config.log"

# Logging function
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check if oc CLI is installed
    if ! command -v oc &> /dev/null; then
        log "INFO" "Installing OpenShift CLI..."
        install_oc_cli
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log "INFO" "Installing kubectl..."
        install_kubectl
    fi
    
    # Check cluster connectivity
    if ! oc cluster-info &> /dev/null; then
        error_exit "Cannot connect to OpenShift cluster. Please check kubeconfig."
    fi
    
    log "INFO" "Prerequisites check passed"
}

# Install OpenShift CLI
install_oc_cli() {
    log "INFO" "Installing OpenShift CLI..."
    
    local oc_version="4.13.0"
    local arch="linux"
    
    # Download and install oc
    wget -q "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${oc_version}/openshift-client-${arch}.tar.gz"
    tar -xzf "openshift-client-${arch}.tar.gz"
    sudo mv oc kubectl /usr/local/bin/
    sudo chmod +x /usr/local/bin/oc /usr/local/bin/kubectl
    rm -f "openshift-client-${arch}.tar.gz" oc kubectl
    
    log "INFO" "OpenShift CLI installed successfully"
}

# Install kubectl
install_kubectl() {
    log "INFO" "Installing kubectl..."
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    
    log "INFO" "kubectl installed successfully"
}

# Configure cluster authentication
configure_authentication() {
    log "INFO" "Configuring cluster authentication..."
    
    # Create OAuth configuration for LDAP integration (example)
    cat << EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd_provider
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
EOF

    # Create htpasswd secret with admin user
    htpasswd -c -B -b /tmp/users.htpasswd admin "${ADMIN_PASSWORD:-RedHat123!}"
    oc create secret generic htpass-secret --from-file=htpasswd=/tmp/users.htpasswd -n openshift-config
    rm /tmp/users.htpasswd
    
    # Grant cluster-admin role to admin user
    oc adm policy add-cluster-role-to-user cluster-admin admin
    
    log "INFO" "Cluster authentication configured successfully"
}

# Install operators
install_operators() {
    log "INFO" "Installing essential operators..."
    
    # Install OpenShift Logging Operator
    cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-logging
  namespace: openshift-logging
spec:
  channel: stable
  name: cluster-logging
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    # Create openshift-logging namespace
    oc create namespace openshift-logging || true
    
    # Install OpenShift Monitoring Operator
    cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-monitoring
  namespace: openshift-monitoring
spec:
  channel: stable
  name: cluster-monitoring-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    # Install Red Hat OpenShift Service Mesh
    cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    log "INFO" "Essential operators installed successfully"
}

# Configure persistent storage
configure_storage() {
    log "INFO" "Configuring persistent storage..."
    
    # Create storage class for EBS volumes (AWS)
    cat << EOF | oc apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3-csi
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  fsType: ext4
  encrypted: "true"
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
EOF

    log "INFO" "Persistent storage configured successfully"
}

# Setup monitoring and alerting
setup_monitoring() {
    log "INFO" "Setting up monitoring and alerting..."
    
    # Create cluster monitoring configuration
    cat << EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
    prometheusOperator:
      baseImage: quay.io/prometheus-operator/prometheus-operator
      prometheusConfigReloaderBaseImage: quay.io/prometheus-operator/prometheus-config-reloader
      configReloaderBaseImage: quay.io/prometheus-operator/configmap-reload
    prometheusK8s:
      retention: 15d
      nodeSelector:
        kubernetes.io/os: linux
      volumeClaimTemplate:
        spec:
          storageClassName: gp3-csi
          resources:
            requests:
              storage: 40Gi
    alertmanagerMain:
      nodeSelector:
        kubernetes.io/os: linux
      volumeClaimTemplate:
        spec:
          storageClassName: gp3-csi
          resources:
            requests:
              storage: 20Gi
EOF

    # Wait for monitoring stack to be ready
    log "INFO" "Waiting for monitoring stack to be ready..."
    oc wait --for=condition=Available deployment/prometheus-operator -n openshift-monitoring --timeout=300s
    
    log "INFO" "Monitoring and alerting setup completed successfully"
}

# Configure networking
configure_networking() {
    log "INFO" "Configuring cluster networking..."
    
    # Create network policies for default namespace
    cat << EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: default
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: default
  - to: {}
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
EOF

    log "INFO" "Cluster networking configured successfully"
}

# Setup image registry
setup_image_registry() {
    log "INFO" "Setting up image registry..."
    
    # Configure registry to use S3 storage
    oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{
      "spec": {
        "managementState": "Managed",
        "storage": {
          "s3": {
            "bucket": "'${REGISTRY_BUCKET:-openshift-registry}'",
            "region": "'${AWS_REGION:-us-east-1}'"
          }
        },
        "replicas": 2
      }
    }'
    
    # Wait for registry to be available
    oc wait --for=condition=Available deployment/image-registry -n openshift-image-registry --timeout=300s
    
    log "INFO" "Image registry setup completed successfully"
}

# Create sample applications
create_sample_apps() {
    log "INFO" "Creating sample applications..."
    
    # Create a project for sample applications
    oc new-project sample-apps || oc project sample-apps
    
    # Deploy a simple web application
    cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-openshift
  namespace: sample-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-openshift
  template:
    metadata:
      labels:
        app: hello-openshift
    spec:
      containers:
      - name: hello-openshift
        image: openshift/hello-openshift:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-openshift-service
  namespace: sample-apps
spec:
  selector:
    app: hello-openshift
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: hello-openshift-route
  namespace: sample-apps
spec:
  to:
    kind: Service
    name: hello-openshift-service
  port:
    targetPort: 8080
EOF

    # Wait for deployment to be ready
    oc rollout status deployment/hello-openshift -n sample-apps
    
    log "INFO" "Sample applications created successfully"
}

# Configure backup
configure_backup() {
    log "INFO" "Configuring cluster backup..."
    
    # Install OADP (OpenShift API for Data Protection) operator
    cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redhat-oadp-operator
  namespace: openshift-adp
spec:
  channel: stable-1.2
  name: redhat-oadp-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

    # Create namespace for backup
    oc create namespace openshift-adp || true
    
    log "INFO" "Backup configuration completed successfully"
}

# Validate cluster health
validate_cluster() {
    log "INFO" "Validating cluster health..."
    
    # Check cluster operators
    local failing_operators=$(oc get clusteroperators --no-headers | awk '$3 != "True" || $4 != "False" || $5 != "False" { print $1 }')
    
    if [[ -n "$failing_operators" ]]; then
        log "WARN" "Some cluster operators are not in expected state: $failing_operators"
    else
        log "INFO" "All cluster operators are healthy"
    fi
    
    # Check node status
    local not_ready_nodes=$(oc get nodes --no-headers | awk '$2 != "Ready" { print $1 }')
    
    if [[ -n "$not_ready_nodes" ]]; then
        log "WARN" "Some nodes are not ready: $not_ready_nodes"
    else
        log "INFO" "All nodes are ready"
    fi
    
    # Check pod status in system namespaces
    local failing_pods=$(oc get pods -A --no-headers | awk '$4 != "Running" && $4 != "Completed" && $4 != "Succeeded" { print $1"/"$2 }')
    
    if [[ -n "$failing_pods" ]]; then
        log "WARN" "Some pods are not running: $failing_pods"
    else
        log "INFO" "All system pods are running"
    fi
    
    log "INFO" "Cluster health validation completed"
}

# Generate configuration summary
generate_summary() {
    log "INFO" "Generating configuration summary..."
    
    # Get cluster info
    local cluster_version=$(oc get clusterversion version -o jsonpath='{.status.desired.version}' 2>/dev/null || echo "Unknown")
    local api_url=$(oc whoami --show-server 2>/dev/null || echo "Unknown")
    local console_url=$(oc get routes console -n openshift-console -o jsonpath='{.spec.host}' 2>/dev/null || echo "Unknown")
    
    cat << EOF | tee -a "$LOG_FILE"

================================================================================
IBM OPENSHIFT CONTAINER PLATFORM CONFIGURATION SUMMARY
================================================================================

Configuration Status: COMPLETED
Configuration Date: $(date)

Cluster Information:
- OpenShift Version: $cluster_version
- API Server: $api_url
- Web Console: https://$console_url
- Registry: $(oc get route default-route -n openshift-image-registry -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not exposed")

Authentication:
- Admin User: admin
- Password: ${ADMIN_PASSWORD:-RedHat123!}

Installed Operators:
- Cluster Logging Operator
- Cluster Monitoring Operator  
- Service Mesh Operator
- OADP (Backup) Operator

Sample Applications:
- Hello OpenShift: http://$(oc get route hello-openshift-route -n sample-apps -o jsonpath='{.spec.host}' 2>/dev/null || echo "Not available")

Storage:
- Default Storage Class: gp3-csi
- Registry Storage: S3 (${REGISTRY_BUCKET:-openshift-registry})

Monitoring:
- Prometheus: Enabled with 15 days retention
- Alertmanager: Enabled
- User Workload Monitoring: Enabled

Next Steps:
1. Access the web console to complete setup
2. Configure additional identity providers
3. Set up application deployments
4. Configure backup schedules
5. Set up monitoring alerts
6. Configure SSL certificates
7. Set up CI/CD pipelines

Documentation:
- Configuration: $CONFIG_FILE
- Logs: $LOG_FILE
- OpenShift Documentation: https://docs.openshift.com/

================================================================================
EOF
}

# Main configuration function
main() {
    log "INFO" "Starting IBM OpenShift Container Platform configuration..."
    
    # Set default values
    export ADMIN_PASSWORD="${ADMIN_PASSWORD:-RedHat123!}"
    export AWS_REGION="${AWS_REGION:-us-east-1}"
    export REGISTRY_BUCKET="${REGISTRY_BUCKET:-openshift-registry}"
    
    # Execute configuration steps
    check_prerequisites
    configure_authentication
    install_operators
    configure_storage
    setup_monitoring
    configure_networking
    setup_image_registry
    create_sample_apps
    configure_backup
    validate_cluster
    generate_summary
    
    log "INFO" "IBM OpenShift Container Platform configuration completed successfully!"
}

# Execute main function
main "$@"
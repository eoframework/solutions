#!/bin/bash

# NVIDIA GPU Compute Cluster Deployment Script
# 
# This script automates the deployment and configuration of NVIDIA GPU compute clusters
# including CUDA drivers, container runtime, cluster management, and AI/ML frameworks.
#
# Features:
# - Automated NVIDIA driver and CUDA installation
# - Docker and NVIDIA Container Runtime setup
# - Kubernetes cluster configuration with GPU support
# - NVIDIA device plugin deployment
# - AI/ML framework installation (TensorFlow, PyTorch, etc.)
# - Cluster monitoring and resource management
# - Multi-node GPU cluster orchestration
#
# Author: EO Framework AI Team
# Version: 1.0.0

set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_FILE="${PROJECT_ROOT}/logs/gpu_cluster_deployment_$(date +%Y%m%d_%H%M%S).log"
CONFIG_FILE="${PROJECT_ROOT}/config/deployment.conf"
PYTHON_SCRIPT="${SCRIPT_DIR}/../python/deploy.py"

# Default configuration
CLUSTER_NAME="nvidia-gpu-cluster"
NVIDIA_DRIVER_VERSION="535.129.03"
CUDA_VERSION="12.2"
DOCKER_VERSION="24.0"
KUBERNETES_VERSION="1.28"
NODE_COUNT=3
GPU_TYPE="RTX4090"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

log_warning() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $*" | tee -a "$LOG_FILE"
}

# Help function
show_help() {
    cat << EOF
NVIDIA GPU Compute Cluster Deployment Script

Usage: $0 [OPTIONS]

OPTIONS:
    --cluster-name NAME         Set cluster name (default: nvidia-gpu-cluster)
    --driver-version VERSION    NVIDIA driver version (default: 535.129.03)
    --cuda-version VERSION      CUDA version (default: 12.2)
    --node-count COUNT          Number of worker nodes (default: 3)
    --gpu-type TYPE             GPU type (default: RTX4090)
    --config FILE               Configuration file path
    --dry-run                   Show what would be done without executing
    --skip-prerequisites        Skip prerequisite checks
    --help                      Show this help message

EXAMPLES:
    $0                                      # Deploy with defaults
    $0 --cluster-name my-cluster --node-count 5
    $0 --config custom.conf --dry-run       # Dry run with custom config
    $0 --skip-prerequisites                 # Skip validation checks

For more information, see the documentation in the docs/ directory.
EOF
}

# Configuration loading
load_configuration() {
    log "Loading configuration..."
    
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Found configuration file: $CONFIG_FILE"
        # Source the configuration file
        source "$CONFIG_FILE"
        log "Configuration loaded successfully"
    else
        log_warning "Configuration file not found, using defaults"
    fi
    
    # Override with command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cluster-name)
                CLUSTER_NAME="$2"
                shift 2
                ;;
            --driver-version)
                NVIDIA_DRIVER_VERSION="$2"
                shift 2
                ;;
            --cuda-version)
                CUDA_VERSION="$2"
                shift 2
                ;;
            --node-count)
                NODE_COUNT="$2"
                shift 2
                ;;
            --gpu-type)
                GPU_TYPE="$2"
                shift 2
                ;;
            --config)
                CONFIG_FILE="$2"
                load_configuration
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    log "Final configuration:"
    log "  Cluster Name: $CLUSTER_NAME"
    log "  NVIDIA Driver: $NVIDIA_DRIVER_VERSION"
    log "  CUDA Version: $CUDA_VERSION"
    log "  Node Count: $NODE_COUNT"
    log "  GPU Type: $GPU_TYPE"
}

# Prerequisites validation
validate_prerequisites() {
    log "Validating prerequisites..."
    
    local prerequisites_met=true
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        prerequisites_met=false
    fi
    
    # Check system requirements
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl is required but not installed"
        prerequisites_met=false
    fi
    
    if ! command -v wget >/dev/null 2>&1; then
        log_error "wget is required but not installed"
        prerequisites_met=false
    fi
    
    # Check hardware requirements
    if ! lspci | grep -i nvidia >/dev/null 2>&1; then
        log_error "No NVIDIA GPU detected"
        prerequisites_met=false
    else
        log "NVIDIA GPU detected:"
        lspci | grep -i nvidia | head -5 | while read -r line; do
            log "  $line"
        done
    fi
    
    # Check available disk space (minimum 50GB)
    available_space=$(df / | awk 'NR==2 {print $4}')
    min_space=52428800  # 50GB in KB
    if [[ $available_space -lt $min_space ]]; then
        log_error "Insufficient disk space. Available: $((available_space/1024/1024))GB, Required: 50GB"
        prerequisites_met=false
    fi
    
    # Check memory (minimum 16GB)
    total_memory=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    min_memory=16777216  # 16GB in KB
    if [[ $total_memory -lt $min_memory ]]; then
        log_error "Insufficient memory. Available: $((total_memory/1024/1024))GB, Required: 16GB"
        prerequisites_met=false
    fi
    
    if [[ "$prerequisites_met" == "true" ]]; then
        log_success "Prerequisites validation passed"
        return 0
    else
        log_error "Prerequisites validation failed"
        return 1
    fi
}

# System preparation
prepare_system() {
    log "Preparing system for GPU cluster deployment..."
    
    # Update system packages
    log "Updating system packages..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y
        apt-get upgrade -y
        apt-get install -y build-essential dkms software-properties-common
    elif command -v yum >/dev/null 2>&1; then
        yum update -y
        yum groupinstall -y "Development Tools"
        yum install -y kernel-devel kernel-headers
    elif command -v dnf >/dev/null 2>&1; then
        dnf update -y
        dnf groupinstall -y "Development Tools"
        dnf install -y kernel-devel kernel-headers
    fi
    
    # Disable nouveau driver
    log "Disabling nouveau driver..."
    echo 'blacklist nouveau' > /etc/modprobe.d/blacklist-nouveau.conf
    echo 'options nouveau modeset=0' >> /etc/modprobe.d/blacklist-nouveau.conf
    
    # Update initramfs
    if command -v update-initramfs >/dev/null 2>&1; then
        update-initramfs -u
    elif command -v dracut >/dev/null 2>&1; then
        dracut --force
    fi
    
    log_success "System preparation completed"
}

# NVIDIA driver installation
install_nvidia_driver() {
    log "Installing NVIDIA driver version $NVIDIA_DRIVER_VERSION..."
    
    # Check if driver is already installed
    if nvidia-smi >/dev/null 2>&1; then
        current_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
        log "NVIDIA driver already installed: $current_version"
        
        if [[ "$current_version" == "$NVIDIA_DRIVER_VERSION" ]]; then
            log "Required driver version already installed"
            return 0
        fi
    fi
    
    # Download and install NVIDIA driver
    local driver_url="https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run"
    local driver_file="/tmp/nvidia-driver.run"
    
    log "Downloading NVIDIA driver from $driver_url..."
    if ! wget -O "$driver_file" "$driver_url"; then
        log_error "Failed to download NVIDIA driver"
        return 1
    fi
    
    chmod +x "$driver_file"
    
    # Install driver
    log "Installing NVIDIA driver (this may take several minutes)..."
    if ! "$driver_file" --silent --no-questions --ui=none --no-nouveau-check; then
        log_error "NVIDIA driver installation failed"
        return 1
    fi
    
    # Verify installation
    if nvidia-smi >/dev/null 2>&1; then
        log_success "NVIDIA driver installed successfully"
        nvidia-smi | head -10 | while read -r line; do
            log "  $line"
        done
    else
        log_error "NVIDIA driver installation verification failed"
        return 1
    fi
    
    # Clean up
    rm -f "$driver_file"
}

# CUDA installation
install_cuda() {
    log "Installing CUDA version $CUDA_VERSION..."
    
    # Check if CUDA is already installed
    if command -v nvcc >/dev/null 2>&1; then
        current_cuda=$(nvcc --version | grep "release" | awk '{print $6}' | cut -c2-)
        log "CUDA already installed: $current_cuda"
        
        if [[ "$current_cuda" == "$CUDA_VERSION" ]]; then
            log "Required CUDA version already installed"
            return 0
        fi
    fi
    
    # Install CUDA using package manager
    if command -v apt-get >/dev/null 2>&1; then
        # Ubuntu/Debian
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
        dpkg -i cuda-keyring_1.0-1_all.deb
        apt-get update
        apt-get -y install cuda-toolkit-12-2
    elif command -v yum >/dev/null 2>&1; then
        # RHEL/CentOS
        yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
        yum install -y cuda-toolkit-12-2
    fi
    
    # Set up environment variables
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> /etc/profile.d/cuda.sh
    
    # Source the environment
    export PATH=/usr/local/cuda/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
    
    # Verify installation
    if nvcc --version >/dev/null 2>&1; then
        log_success "CUDA installed successfully"
        nvcc --version | while read -r line; do
            log "  $line"
        done
    else
        log_error "CUDA installation verification failed"
        return 1
    fi
}

# Docker installation with NVIDIA runtime
install_docker_nvidia() {
    log "Installing Docker with NVIDIA runtime..."
    
    # Install Docker
    if ! command -v docker >/dev/null 2>&1; then
        log "Installing Docker..."
        if command -v apt-get >/dev/null 2>&1; then
            # Ubuntu/Debian
            apt-get update
            apt-get install -y ca-certificates curl gnupg lsb-release
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
            apt-get update
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        elif command -v yum >/dev/null 2>&1; then
            # RHEL/CentOS
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        fi
        
        # Start and enable Docker
        systemctl start docker
        systemctl enable docker
        
        log_success "Docker installed successfully"
    else
        log "Docker already installed"
    fi
    
    # Install NVIDIA Container Runtime
    log "Installing NVIDIA Container Runtime..."
    if command -v apt-get >/dev/null 2>&1; then
        distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
        curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
        curl -s -L "https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list" > /etc/apt/sources.list.d/nvidia-docker.list
        
        apt-get update
        apt-get install -y nvidia-docker2
    elif command -v yum >/dev/null 2>&1; then
        curl -s -L https://nvidia.github.io/nvidia-docker/centos8/nvidia-docker.repo > /etc/yum.repos.d/nvidia-docker.repo
        yum install -y nvidia-docker2
    fi
    
    # Configure Docker daemon
    cat > /etc/docker/daemon.json <<EOF
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    }
}
EOF
    
    # Restart Docker
    systemctl restart docker
    
    # Test NVIDIA Docker
    log "Testing NVIDIA Docker integration..."
    if docker run --rm nvidia/cuda:12.2-base-ubuntu20.04 nvidia-smi >/dev/null 2>&1; then
        log_success "NVIDIA Docker runtime configured successfully"
    else
        log_error "NVIDIA Docker runtime test failed"
        return 1
    fi
}

# Kubernetes cluster setup
setup_kubernetes_cluster() {
    log "Setting up Kubernetes cluster with GPU support..."
    
    # Install Kubernetes components
    if ! command -v kubeadm >/dev/null 2>&1; then
        log "Installing Kubernetes components..."
        
        if command -v apt-get >/dev/null 2>&1; then
            # Ubuntu/Debian
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl
            curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
            echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
            apt-get update
            apt-get install -y kubelet kubeadm kubectl
            apt-mark hold kubelet kubeadm kubectl
        elif command -v yum >/dev/null 2>&1; then
            # RHEL/CentOS
            cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
            yum install -y kubelet kubeadm kubectl
            systemctl enable --now kubelet
        fi
        
        log_success "Kubernetes components installed"
    else
        log "Kubernetes already installed"
    fi
    
    # Initialize cluster if this is the master node
    if [[ ! -f /etc/kubernetes/admin.conf ]]; then
        log "Initializing Kubernetes cluster..."
        
        # Disable swap
        swapoff -a
        sed -i '/ swap / s/^/#/' /etc/fstab
        
        # Initialize cluster
        kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///var/run/crio/crio.sock 2>/dev/null || \
        kubeadm init --pod-network-cidr=192.168.0.0/16
        
        # Set up kubectl for root user
        export KUBECONFIG=/etc/kubernetes/admin.conf
        echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> /root/.bashrc
        
        # Install Calico network plugin
        log "Installing Calico network plugin..."
        kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
        
        log_success "Kubernetes cluster initialized"
    else
        log "Kubernetes cluster already initialized"
        export KUBECONFIG=/etc/kubernetes/admin.conf
    fi
}

# NVIDIA device plugin installation
install_nvidia_device_plugin() {
    log "Installing NVIDIA device plugin for Kubernetes..."
    
    # Wait for cluster to be ready
    log "Waiting for cluster to be ready..."
    local timeout=300
    local elapsed=0
    
    while ! kubectl get nodes >/dev/null 2>&1; do
        if [[ $elapsed -ge $timeout ]]; then
            log_error "Timeout waiting for cluster to be ready"
            return 1
        fi
        sleep 10
        elapsed=$((elapsed + 10))
    done
    
    # Install NVIDIA device plugin
    kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.3/nvidia-device-plugin.yml
    
    # Wait for device plugin to be ready
    log "Waiting for NVIDIA device plugin to be ready..."
    timeout=300
    elapsed=0
    
    while ! kubectl get pods -n kube-system -l name=nvidia-device-plugin-ds | grep Running >/dev/null 2>&1; do
        if [[ $elapsed -ge $timeout ]]; then
            log_error "Timeout waiting for NVIDIA device plugin"
            return 1
        fi
        sleep 10
        elapsed=$((elapsed + 10))
    done
    
    log_success "NVIDIA device plugin installed and running"
    
    # Verify GPU resources are available
    log "Verifying GPU resources..."
    if kubectl describe nodes | grep "nvidia.com/gpu" >/dev/null 2>&1; then
        log_success "GPU resources detected in cluster"
        kubectl describe nodes | grep -A 5 -B 5 "nvidia.com/gpu" | while read -r line; do
            log "  $line"
        done
    else
        log_error "GPU resources not detected in cluster"
        return 1
    fi
}

# AI/ML frameworks installation
install_ml_frameworks() {
    log "Installing AI/ML frameworks..."
    
    # Create namespace for ML workloads
    kubectl create namespace ml-workloads 2>/dev/null || true
    
    # Install Helm if not present
    if ! command -v helm >/dev/null 2>&1; then
        log "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    # Add necessary Helm repositories
    helm repo add nvidia https://helm.ngc.nvidia.com/nvidia 2>/dev/null || true
    helm repo add kubeflow https://www.kubeflow.org/helm-charts 2>/dev/null || true
    helm repo update
    
    # Deploy JupyterHub for ML development
    log "Deploying JupyterHub with GPU support..."
    cat > /tmp/jupyterhub-values.yaml <<EOF
hub:
  resources:
    requests:
      cpu: 100m
      memory: 512Mi
    limits:
      cpu: 1
      memory: 1Gi

singleuser:
  image:
    name: tensorflow/tensorflow
    tag: latest-gpu-jupyter
  
  cpu:
    guarantee: 0.5
    limit: 2
  memory:
    guarantee: 1G
    limit: 4G
  
  extraResource:
    guarantees:
      nvidia.com/gpu: "1"
    limits:
      nvidia.com/gpu: "1"

prePuller:
  hook:
    enabled: false
  continuous:
    enabled: false
EOF
    
    helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
    helm repo update
    helm upgrade --install jupyterhub jupyterhub/jupyterhub \
        --namespace ml-workloads \
        --values /tmp/jupyterhub-values.yaml \
        --wait --timeout=600s
    
    log_success "AI/ML frameworks deployed"
}

# Monitoring setup
setup_monitoring() {
    log "Setting up cluster monitoring..."
    
    # Install NVIDIA DCGM exporter for GPU metrics
    kubectl apply -f https://raw.githubusercontent.com/NVIDIA/dcgm-exporter/main/deployment/kubernetes/dcgm-exporter-daemonset.yaml
    
    # Create a simple GPU test job
    cat > /tmp/gpu-test-job.yaml <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: gpu-test
  namespace: default
spec:
  template:
    spec:
      containers:
      - name: gpu-test
        image: nvidia/cuda:12.2-base-ubuntu20.04
        command: ["nvidia-smi"]
        resources:
          limits:
            nvidia.com/gpu: 1
      restartPolicy: Never
  backoffLimit: 4
EOF
    
    kubectl apply -f /tmp/gpu-test-job.yaml
    
    log_success "Monitoring setup completed"
}

# Main deployment function
main() {
    local DRY_RUN=false
    local SKIP_PREREQUISITES=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-prerequisites)
                SKIP_PREREQUISITES=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done
    
    log "========================================="
    log "NVIDIA GPU Compute Cluster Deployment"
    log "========================================="
    log "Start time: $(date)"
    
    # Load configuration
    load_configuration "$@"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN mode - showing deployment plan:"
        log "  - Install NVIDIA driver $NVIDIA_DRIVER_VERSION"
        log "  - Install CUDA $CUDA_VERSION"
        log "  - Setup Docker with NVIDIA runtime"
        log "  - Initialize Kubernetes cluster"
        log "  - Deploy NVIDIA device plugin"
        log "  - Install ML frameworks"
        log "  - Setup monitoring"
        log "DRY RUN completed"
        return 0
    fi
    
    # Validate prerequisites
    if [[ "$SKIP_PREREQUISITES" != "true" ]]; then
        if ! validate_prerequisites; then
            log_error "Prerequisites validation failed"
            return 1
        fi
    fi
    
    # Execute deployment steps
    log "Starting GPU cluster deployment..."
    
    if prepare_system && \
       install_nvidia_driver && \
       install_cuda && \
       install_docker_nvidia && \
       setup_kubernetes_cluster && \
       install_nvidia_device_plugin && \
       install_ml_frameworks && \
       setup_monitoring; then
        
        log_success "========================================="
        log_success "GPU cluster deployment completed successfully!"
        log_success "========================================="
        log_success "Cluster name: $CLUSTER_NAME"
        log_success "NVIDIA driver: $NVIDIA_DRIVER_VERSION"
        log_success "CUDA version: $CUDA_VERSION"
        log_success "Node count: $NODE_COUNT"
        log_success "GPU type: $GPU_TYPE"
        log_success "End time: $(date)"
        
        # Show cluster status
        log "Cluster status:"
        kubectl get nodes -o wide || log_warning "Could not get cluster status"
        kubectl get pods -A | grep -E "(nvidia|gpu)" || log_warning "Could not get GPU pod status"
        
        return 0
    else
        log_error "========================================="
        log_error "GPU cluster deployment failed!"
        log_error "========================================="
        log_error "Check the log file for details: $LOG_FILE"
        return 1
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
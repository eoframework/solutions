#!/bin/bash

# NVIDIA DGX SuperPOD Deployment Script
# Version: 1.0
# Description: Automated deployment and configuration of DGX SuperPOD infrastructure

set -euo pipefail

# Configuration variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/dgx-superpod"
CONFIG_FILE="${SCRIPT_DIR}/../config/deployment.conf"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/deployment_${TIMESTAMP}.log"

# Default configuration
DGX_NODE_COUNT=${DGX_NODE_COUNT:-20}
CLUSTER_NAME=${CLUSTER_NAME:-"dgx-superpod"}
DOMAIN_NAME=${DOMAIN_NAME:-"local"}
ADMIN_EMAIL=${ADMIN_EMAIL:-"admin@company.com"}
NGC_API_KEY=${NGC_API_KEY:-""}

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "$*"
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_warn() {
    log "WARN" "$*"
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    log "ERROR" "$*"
    echo -e "${RED}[ERROR]${NC} $*"
}

log_success() {
    log "SUCCESS" "$*"
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Error handling
error_exit() {
    log_error "$1"
    exit 1
}

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Deployment failed with exit code $exit_code"
        log_info "Check log file: $LOG_FILE"
    fi
    exit $exit_code
}

trap cleanup EXIT

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

wait_for_service() {
    local service=$1
    local timeout=${2:-300}
    local count=0
    
    log_info "Waiting for service $service to be ready..."
    while [ $count -lt $timeout ]; do
        if systemctl is-active --quiet "$service"; then
            log_success "Service $service is ready"
            return 0
        fi
        sleep 5
        count=$((count + 5))
    done
    error_exit "Service $service failed to start within $timeout seconds"
}

# Prerequisites check
check_prerequisites() {
    log_info "Checking deployment prerequisites..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        error_exit "This script must be run as root"
    fi
    
    # Check OS compatibility
    if ! grep -q "Ubuntu 20.04\|Ubuntu 22.04\|Red Hat Enterprise Linux 8" /etc/os-release; then
        log_warn "Unsupported OS detected. Supported: Ubuntu 20.04/22.04, RHEL 8"
    fi
    
    # Check hardware requirements
    local cpu_count=$(nproc)
    local memory_gb=$(free -g | awk '/^Mem:/{print $2}')
    
    if [ $cpu_count -lt 64 ]; then
        log_warn "CPU count ($cpu_count) below recommended minimum (64 cores)"
    fi
    
    if [ $memory_gb -lt 500 ]; then
        log_warn "Memory ($memory_gb GB) below recommended minimum (500 GB)"
    fi
    
    # Check for NVIDIA GPUs
    if ! lspci | grep -i nvidia > /dev/null; then
        error_exit "No NVIDIA GPUs detected"
    fi
    
    # Check network connectivity
    if ! ping -c 3 8.8.8.8 > /dev/null 2>&1; then
        error_exit "No internet connectivity detected"
    fi
    
    log_success "Prerequisites check completed"
}

# System preparation
prepare_system() {
    log_info "Preparing system for DGX SuperPOD deployment..."
    
    # Create necessary directories
    mkdir -p "$LOG_DIR"
    mkdir -p /etc/dgx-superpod
    mkdir -p /opt/nvidia
    mkdir -p /data/shared
    
    # Update system packages
    log_info "Updating system packages..."
    if command_exists apt; then
        apt update && apt upgrade -y
        apt install -y curl wget git vim htop iotop screen tmux build-essential
    elif command_exists yum; then
        yum update -y
        yum install -y curl wget git vim htop iotop screen tmux gcc gcc-c++ make
    fi
    
    # Configure system settings
    log_info "Configuring system settings..."
    
    # Disable swap
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Configure kernel parameters
    cat >> /etc/sysctl.conf << EOF
# DGX SuperPOD optimizations
vm.swappiness=1
vm.nr_hugepages=32768
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 65536 134217728
net.ipv4.tcp_wmem=4096 65536 134217728
EOF
    sysctl -p
    
    # Configure systemd limits
    cat > /etc/systemd/system.conf.d/dgx-limits.conf << EOF
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=1048576
DefaultLimitCORE=infinity
DefaultLimitMEMLOCK=infinity
EOF
    
    systemctl daemon-reload
    
    log_success "System preparation completed"
}

# NVIDIA driver installation
install_nvidia_drivers() {
    log_info "Installing NVIDIA drivers and CUDA toolkit..."
    
    # Check if drivers are already installed
    if command_exists nvidia-smi; then
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)
        log_info "NVIDIA driver already installed: version $driver_version"
        
        # Check if version is acceptable (525.85+)
        if dpkg --compare-versions "$driver_version" ge "525.85"; then
            log_success "NVIDIA driver version is compatible"
            return 0
        else
            log_warn "NVIDIA driver version is too old, upgrading..."
        fi
    fi
    
    # Install NVIDIA repository
    if command_exists apt; then
        # Ubuntu/Debian
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
        dpkg -i cuda-keyring_1.0-1_all.deb
        apt update
        
        # Install driver and CUDA toolkit
        apt install -y nvidia-driver-525 cuda-toolkit-12-0
        
    elif command_exists yum; then
        # RHEL/CentOS
        yum install -y kernel-devel kernel-headers gcc gcc-c++ make
        
        # Install NVIDIA repository
        yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
        yum clean all
        
        # Install driver and CUDA toolkit
        yum module install -y nvidia-driver:latest-dkms
        yum install -y cuda-toolkit-12-0
    fi
    
    # Configure NVIDIA persistence daemon
    systemctl enable nvidia-persistenced
    systemctl start nvidia-persistenced
    
    # Set GPU settings
    nvidia-smi -pm 1  # Enable persistence mode
    nvidia-smi -e 1   # Enable ECC
    
    log_success "NVIDIA drivers installed successfully"
    log_warn "System reboot may be required for driver changes to take effect"
}

# Container runtime installation
install_container_runtime() {
    log_info "Installing container runtime (containerd)..."
    
    if command_exists containerd; then
        log_info "Container runtime already installed"
        return 0
    fi
    
    # Install Docker repository and containerd
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt update
    apt install -y containerd.io
    
    # Configure containerd
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    
    # Enable systemd cgroup driver
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    
    # Restart and enable containerd
    systemctl restart containerd
    systemctl enable containerd
    
    # Install NVIDIA container runtime
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list
    
    apt update
    apt install -y nvidia-container-runtime
    
    # Configure containerd for NVIDIA runtime
    cat >> /etc/containerd/config.toml << EOF

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
  runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
    BinaryName = "/usr/bin/nvidia-container-runtime"
EOF
    
    systemctl restart containerd
    wait_for_service containerd
    
    log_success "Container runtime installed successfully"
}

# Kubernetes installation
install_kubernetes() {
    log_info "Installing Kubernetes cluster..."
    
    if command_exists kubectl; then
        log_info "Kubernetes already installed"
        return 0
    fi
    
    # Install Kubernetes repository
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
    
    apt update
    apt install -y kubelet=1.25.0-00 kubeadm=1.25.0-00 kubectl=1.25.0-00
    apt-mark hold kubelet kubeadm kubectl
    
    # Initialize Kubernetes cluster
    log_info "Initializing Kubernetes cluster..."
    kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.25.0 --node-name="$CLUSTER_NAME-master"
    
    # Set up kubectl for current user
    export KUBECONFIG=/etc/kubernetes/admin.conf
    mkdir -p ~/.kube
    cp /etc/kubernetes/admin.conf ~/.kube/config
    
    # Install network plugin (Flannel)
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
    
    # Install NVIDIA device plugin
    kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
    
    # Wait for cluster to be ready
    log_info "Waiting for Kubernetes cluster to be ready..."
    local count=0
    while [ $count -lt 300 ]; do
        if kubectl get nodes | grep -q "Ready"; then
            log_success "Kubernetes cluster is ready"
            break
        fi
        sleep 10
        count=$((count + 10))
    done
    
    if [ $count -ge 300 ]; then
        error_exit "Kubernetes cluster failed to become ready"
    fi
    
    log_success "Kubernetes installed successfully"
}

# InfiniBand networking
configure_infiniband() {
    log_info "Configuring InfiniBand networking..."
    
    # Check if InfiniBand hardware is present
    if ! lspci | grep -i mellanox > /dev/null; then
        log_warn "No Mellanox InfiniBand hardware detected, skipping IB configuration"
        return 0
    fi
    
    # Install OFED drivers
    log_info "Installing Mellanox OFED drivers..."
    
    # Download and install MLNX_OFED
    cd /tmp
    wget https://content.mellanox.com/ofed/MLNX_OFED-5.8-1.1.2.1/MLNX_OFED_LINUX-5.8-1.1.2.1-ubuntu20.04-x86_64.tgz
    tar -xzf MLNX_OFED_LINUX-5.8-1.1.2.1-ubuntu20.04-x86_64.tgz
    cd MLNX_OFED_LINUX-5.8-1.1.2.1-ubuntu20.04-x86_64
    
    ./mlnxofedinstall --upstream-libs --dpdk --force
    
    # Start OFED services
    /etc/init.d/openibd restart
    systemctl enable openibd
    
    # Install and configure OpenSM (Subnet Manager)
    apt install -y opensm
    
    cat > /etc/opensm/opensm.conf << EOF
# OpenSM Configuration for DGX SuperPOD
guid 0x0000000000000000
log_file /var/log/opensm.log
log_level 0x07
cache_file /var/cache/opensm/opensm.cache
partition_config_file /etc/opensm/partitions.conf
EOF
    
    systemctl enable opensm
    systemctl start opensm
    
    # Configure IPoIB interfaces
    local ib_device=$(ibstat | grep "CA type" | head -1 | awk '{print $1}' | sed 's/:$//')
    if [ -n "$ib_device" ]; then
        cat > /etc/netplan/60-infiniband.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ib0:
      addresses:
        - 192.168.100.1/24
      mtu: 65520
EOF
        netplan apply
    fi
    
    log_success "InfiniBand networking configured"
}

# Storage configuration
configure_storage() {
    log_info "Configuring shared storage..."
    
    # Create shared directories
    mkdir -p /data/shared/{datasets,models,results,scratch}
    mkdir -p /data/home
    
    # Configure NFS exports (if this is the master node)
    if ! command_exists nfs-kernel-server; then
        apt install -y nfs-kernel-server
    fi
    
    cat > /etc/exports << EOF
/data/shared *(rw,sync,no_subtree_check,no_root_squash)
/data/home *(rw,sync,no_subtree_check,no_root_squash)
EOF
    
    systemctl enable nfs-kernel-server
    systemctl restart nfs-kernel-server
    exportfs -ra
    
    # Set up local mounts
    echo "/data/shared /mnt/shared none bind 0 0" >> /etc/fstab
    mkdir -p /mnt/shared
    mount -a
    
    # Set appropriate permissions
    chown -R nobody:nogroup /data/shared
    chmod -R 755 /data/shared
    
    log_success "Storage configuration completed"
}

# Base Command Platform installation
install_base_command() {
    log_info "Installing NVIDIA Base Command Platform..."
    
    if [ -z "$NGC_API_KEY" ]; then
        log_warn "NGC API key not provided, skipping Base Command Platform installation"
        log_warn "Set NGC_API_KEY environment variable to install Base Command Platform"
        return 0
    fi
    
    # Install Helm
    if ! command_exists helm; then
        log_info "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    # Add NVIDIA Helm repository
    helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
    helm repo update
    
    # Create namespace for Base Command
    kubectl create namespace nvidia-base-command || true
    
    # Create NGC secret
    kubectl create secret docker-registry ngc-secret \
        --docker-server=nvcr.io \
        --docker-username='$oauthtoken' \
        --docker-password="$NGC_API_KEY" \
        --namespace=nvidia-base-command || true
    
    # Install Base Command Platform
    helm install base-command nvidia/base-command-platform \
        --namespace nvidia-base-command \
        --set global.registry.secret.name=ngc-secret \
        --timeout=30m
    
    # Wait for Base Command to be ready
    log_info "Waiting for Base Command Platform to be ready..."
    kubectl wait --for=condition=ready pod -l app=base-command --namespace=nvidia-base-command --timeout=900s
    
    log_success "Base Command Platform installed successfully"
}

# SLURM job scheduler installation
install_slurm() {
    log_info "Installing SLURM job scheduler..."
    
    # Install SLURM packages
    apt install -y slurmd slurmctld slurm-client munge
    
    # Configure MUNGE
    create-munge-key
    systemctl enable munge
    systemctl start munge
    
    # Generate SLURM configuration
    cat > /etc/slurm/slurm.conf << EOF
# SLURM Configuration for DGX SuperPOD
ClusterName=$CLUSTER_NAME
SlurmctldHost=$CLUSTER_NAME-master
MpiDefault=none
ProctrackType=proctrack/linuxproc
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
SlurmdSpoolDir=/var/spool/slurmd
StateSaveLocation=/var/spool/slurmctld
SwitchType=switch/none
TaskPlugin=task/affinity,task/cgroup
TreeWidth=50
SlurmctldTimeout=120
SlurmdTimeout=300
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdLogFile=/var/log/slurmd.log
Waittime=0
SchedulerType=sched/backfill
SelectType=select/cons_res
SelectTypeParameters=CR_Core_Memory
FastSchedule=1

# GPU configuration
GresTypes=gpu
EOF
    
    # Add compute nodes configuration
    for i in $(seq 1 $DGX_NODE_COUNT); do
        node_name=$(printf "dgx%03d" $i)
        cat >> /etc/slurm/slurm.conf << EOF
NodeName=$node_name CPUs=256 Sockets=2 CoresPerSocket=64 ThreadsPerCore=2 RealMemory=2000000 Gres=gpu:h100:8 State=UNKNOWN
EOF
    done
    
    # Add partition configuration
    node_list=$(printf "dgx[001-%03d]" $DGX_NODE_COUNT)
    cat >> /etc/slurm/slurm.conf << EOF
PartitionName=dgx Nodes=$node_list Default=YES MaxTime=INFINITE State=UP
EOF
    
    # Configure SLURM directories
    mkdir -p /var/spool/{slurmctld,slurmd}
    chown slurm:slurm /var/spool/{slurmctld,slurmd}
    
    # Start SLURM services
    systemctl enable slurmctld slurmd
    systemctl start slurmctld
    sleep 5
    systemctl start slurmd
    
    wait_for_service slurmctld
    wait_for_service slurmd
    
    log_success "SLURM job scheduler installed successfully"
}

# Monitoring setup
setup_monitoring() {
    log_info "Setting up monitoring and alerting..."
    
    # Install Prometheus and Grafana using Helm
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create monitoring namespace
    kubectl create namespace monitoring || true
    
    # Install Prometheus stack
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.retention=15d \
        --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=100Gi \
        --set grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD:-$(openssl rand -base64 32)}" \
        --timeout=20m
    
    # Install GPU monitoring
    if helm repo list | grep -q nvidia; then
        helm install gpu-monitoring nvidia/gpu-monitoring --namespace monitoring || true
    fi
    
    # Configure port forwarding for Grafana (for initial access)
    nohup kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 --address=0.0.0.0 > /dev/null 2>&1 &
    
    log_success "Monitoring setup completed"
    log_info "Grafana accessible at http://localhost:3000 (admin/admin123)"
}

# AI frameworks deployment
deploy_ai_frameworks() {
    log_info "Deploying AI frameworks and tools..."
    
    # Pull essential containers from NGC
    local containers=(
        "nvcr.io/nvidia/tensorflow:23.08-tf2-py3"
        "nvcr.io/nvidia/pytorch:23.08-py3" 
        "nvcr.io/nvidia/rapids:23.08"
        "nvcr.io/nvidia/tritonserver:23.08-py3"
        "nvcr.io/nvidia/cuda:12.0-devel-ubuntu20.04"
    )
    
    for container in "${containers[@]}"; do
        log_info "Pulling container: $container"
        docker pull "$container" || log_warn "Failed to pull $container"
    done
    
    # Deploy Jupyter notebook service
    cat > /tmp/jupyter-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyter-notebook
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyter-notebook
  template:
    metadata:
      labels:
        app: jupyter-notebook
    spec:
      containers:
      - name: jupyter
        image: nvcr.io/nvidia/tensorflow:23.08-tf2-py3
        ports:
        - containerPort: 8888
        resources:
          limits:
            nvidia.com/gpu: 1
        command: ["jupyter", "lab"]
        args: ["--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
        volumeMounts:
        - name: shared-data
          mountPath: /data
      volumes:
      - name: shared-data
        hostPath:
          path: /data/shared
---
apiVersion: v1
kind: Service
metadata:
  name: jupyter-service
  namespace: default
spec:
  selector:
    app: jupyter-notebook
  ports:
  - port: 8888
    targetPort: 8888
  type: ClusterIP
EOF
    
    kubectl apply -f /tmp/jupyter-deployment.yaml
    
    log_success "AI frameworks deployed successfully"
}

# System optimization
optimize_system() {
    log_info "Optimizing system performance..."
    
    # CPU governor settings
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    
    # GPU optimization
    if command_exists nvidia-smi; then
        # Set persistence mode
        nvidia-smi -pm 1
        
        # Set power limits (adjust based on your setup)
        nvidia-smi -pl 700
        
        # Set GPU clocks to maximum
        nvidia-smi -ac 1593,2619 || true  # Memory,Graphics clocks for H100
    fi
    
    # Network optimization
    cat > /etc/sysctl.d/99-dgx-network.conf << EOF
# Network optimizations for DGX SuperPOD
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_rmem = 4096 65536 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.ipv4.tcp_congestion_control = bbr
EOF
    sysctl --system
    
    # I/O optimization
    echo mq-deadline | tee /sys/block/*/queue/scheduler > /dev/null || true
    
    log_success "System optimization completed"
}

# Health check
run_health_check() {
    log_info "Running deployment health check..."
    
    local issues=0
    
    # Check NVIDIA driver
    if ! nvidia-smi > /dev/null 2>&1; then
        log_error "NVIDIA driver not working properly"
        issues=$((issues + 1))
    else
        log_success "NVIDIA driver is working"
    fi
    
    # Check Kubernetes
    if ! kubectl get nodes > /dev/null 2>&1; then
        log_error "Kubernetes cluster not accessible"
        issues=$((issues + 1))
    else
        log_success "Kubernetes cluster is accessible"
    fi
    
    # Check storage
    if ! df /data/shared > /dev/null 2>&1; then
        log_error "Shared storage not mounted"
        issues=$((issues + 1))
    else
        log_success "Shared storage is mounted"
    fi
    
    # Check InfiniBand (if present)
    if command_exists ibstat; then
        if ! ibstat | grep -q "State: Active"; then
            log_warn "InfiniBand not in active state"
        else
            log_success "InfiniBand is active"
        fi
    fi
    
    # Check SLURM (if installed)
    if command_exists sinfo; then
        if ! sinfo > /dev/null 2>&1; then
            log_warn "SLURM not responding"
        else
            log_success "SLURM is responding"
        fi
    fi
    
    if [ $issues -eq 0 ]; then
        log_success "Health check passed - all critical components are working"
    else
        log_error "Health check failed - $issues critical issues found"
        return 1
    fi
}

# Main deployment function
deploy_dgx_superpod() {
    log_info "Starting DGX SuperPOD deployment..."
    log_info "Configuration: $DGX_NODE_COUNT nodes, cluster name: $CLUSTER_NAME"
    
    # Phase 1: System preparation
    log_info "=== Phase 1: System Preparation ==="
    check_prerequisites
    prepare_system
    
    # Phase 2: Core infrastructure
    log_info "=== Phase 2: Core Infrastructure ==="
    install_nvidia_drivers
    install_container_runtime
    configure_infiniband
    configure_storage
    
    # Phase 3: Compute platform
    log_info "=== Phase 3: Compute Platform ==="
    install_kubernetes
    install_slurm
    
    # Phase 4: AI platform
    log_info "=== Phase 4: AI Platform ==="
    install_base_command
    deploy_ai_frameworks
    
    # Phase 5: Monitoring and optimization
    log_info "=== Phase 5: Monitoring and Optimization ==="
    setup_monitoring
    optimize_system
    
    # Final health check
    log_info "=== Final Health Check ==="
    if run_health_check; then
        log_success "DGX SuperPOD deployment completed successfully!"
        log_info "Deployment log saved to: $LOG_FILE"
        
        # Display access information
        echo ""
        echo "=== Access Information ==="
        echo "Kubernetes Dashboard: kubectl proxy"
        echo "Grafana Monitoring: http://localhost:3000 (admin/admin123)"
        echo "Jupyter Notebook: kubectl port-forward svc/jupyter-service 8888:8888"
        echo "SLURM Status: sinfo"
        echo ""
        
    else
        error_exit "DGX SuperPOD deployment completed with issues. Check logs for details."
    fi
}

# Script entry point
main() {
    # Load configuration if exists
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Loaded configuration from $CONFIG_FILE"
    fi
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --node-count)
                DGX_NODE_COUNT="$2"
                shift 2
                ;;
            --cluster-name)
                CLUSTER_NAME="$2"
                shift 2
                ;;
            --ngc-api-key)
                NGC_API_KEY="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --node-count NUM     Number of DGX nodes (default: 20)"
                echo "  --cluster-name NAME  Cluster name (default: dgx-superpod)"
                echo "  --ngc-api-key KEY    NGC API key for Base Command Platform"
                echo "  --help              Show this help message"
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
    
    # Start deployment
    deploy_dgx_superpod
}

# Run main function
main "$@"
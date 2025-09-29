#!/bin/bash
# NVIDIA Omniverse Enterprise Platform Deployment Script
# Comprehensive deployment automation for Omniverse Enterprise

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.yml"
LOG_FILE="/var/log/omniverse-deploy.log"

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

# Prerequisites check
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
    
    # Check system requirements
    local total_mem=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $total_mem -lt 32 ]]; then
        error_exit "Insufficient memory. Requires at least 32GB RAM"
    fi
    
    # Check GPU presence
    if ! command -v nvidia-smi &> /dev/null; then
        error_exit "NVIDIA drivers not installed or GPU not detected"
    fi
    
    # Check disk space (minimum 500GB)
    local disk_space=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    if [[ $disk_space -lt 500 ]]; then
        error_exit "Insufficient disk space. Requires at least 500GB free"
    fi
    
    log "INFO" "Prerequisites check passed"
}

# Install NVIDIA Container Toolkit
install_nvidia_container_toolkit() {
    log "INFO" "Installing NVIDIA Container Toolkit..."
    
    # Add NVIDIA repository
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
        gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    apt-get update
    apt-get install -y nvidia-container-toolkit
    
    # Configure Docker
    nvidia-ctk runtime configure --runtime=docker
    systemctl restart docker
    
    log "INFO" "NVIDIA Container Toolkit installed successfully"
}

# Install Docker if not present
install_docker() {
    if ! command -v docker &> /dev/null; then
        log "INFO" "Installing Docker..."
        
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
        
        rm get-docker.sh
        log "INFO" "Docker installed successfully"
    else
        log "INFO" "Docker already installed"
    fi
}

# Deploy Omniverse Nucleus Server
deploy_nucleus_server() {
    log "INFO" "Deploying Omniverse Nucleus Server..."
    
    local nucleus_data="/opt/omniverse/nucleus"
    local nucleus_logs="/opt/omniverse/logs"
    
    mkdir -p "$nucleus_data" "$nucleus_logs"
    
    # Pull Nucleus Server image
    docker pull nvcr.io/nvidia/omniverse/nucleus-server:latest
    
    # Create nucleus configuration
    cat > /tmp/nucleus-config.toml << EOF
[server]
data_root = "/var/lib/omni/nucleus"
log_level = "info"
max_upload_size = 1073741824

[database]
url = "postgresql://nucleus:nucleus_password@localhost:5432/nucleus"

[auth]
mode = "database"
session_timeout = 3600
EOF

    # Deploy Nucleus Server
    docker run -d \
        --name omniverse-nucleus \
        --restart unless-stopped \
        -p 3009:3009 \
        -p 3019:3019 \
        -p 3020:3020 \
        -p 3021:3021 \
        -p 3100:3100 \
        -v "$nucleus_data:/var/lib/omni/nucleus" \
        -v "$nucleus_logs:/var/log/omni" \
        -v /tmp/nucleus-config.toml:/etc/omni/nucleus.toml \
        --gpus all \
        nvcr.io/nvidia/omniverse/nucleus-server:latest
    
    log "INFO" "Nucleus Server deployed successfully"
}

# Deploy Omniverse Cache
deploy_cache_server() {
    log "INFO" "Deploying Omniverse Cache Server..."
    
    local cache_data="/opt/omniverse/cache"
    mkdir -p "$cache_data"
    
    # Pull Cache Server image
    docker pull nvcr.io/nvidia/omniverse/cache:latest
    
    # Deploy Cache Server
    docker run -d \
        --name omniverse-cache \
        --restart unless-stopped \
        -p 3030:3030 \
        -v "$cache_data:/var/cache/omni" \
        --gpus all \
        nvcr.io/nvidia/omniverse/cache:latest
    
    log "INFO" "Cache Server deployed successfully"
}

# Configure networking and security
configure_networking() {
    log "INFO" "Configuring networking and security..."
    
    # Configure firewall rules
    ufw allow 3009/tcp  # Nucleus Web Interface
    ufw allow 3019/tcp  # Nucleus Discovery Service
    ufw allow 3020/tcp  # Nucleus API
    ufw allow 3021/tcp  # Nucleus WebRTC
    ufw allow 3030/tcp  # Cache Server
    ufw allow 3100/tcp  # Nucleus Database
    
    # Enable firewall if not enabled
    echo "y" | ufw enable
    
    log "INFO" "Networking configured successfully"
}

# Create admin user
create_admin_user() {
    log "INFO" "Creating admin user..."
    
    # Wait for Nucleus to be ready
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker exec omniverse-nucleus curl -f http://localhost:3009/health > /dev/null 2>&1; then
            break
        fi
        log "INFO" "Waiting for Nucleus to be ready... (attempt $attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        error_exit "Nucleus server failed to start within expected time"
    fi
    
    # Create admin user via API
    docker exec omniverse-nucleus omni-cli user create \
        --username admin \
        --password "${ADMIN_PASSWORD:-$(openssl rand -base64 32)}" \
        --email admin@company.com \
        --role administrator
    
    log "INFO" "Admin user created successfully"
}

# Generate deployment summary
generate_summary() {
    log "INFO" "Generating deployment summary..."
    
    cat << EOF | tee -a "$LOG_FILE"

================================================================================
NVIDIA OMNIVERSE ENTERPRISE DEPLOYMENT SUMMARY
================================================================================

Deployment Status: SUCCESSFUL
Deployment Date: $(date)

Services Deployed:
- Nucleus Server: http://$(hostname -I | awk '{print $1}'):3009
- Cache Server: http://$(hostname -I | awk '{print $1}'):3030

Admin Credentials:
- Username: admin
- Password: ${ADMIN_PASSWORD:-[Generated randomly - check deployment logs]}

Next Steps:
1. Access the Nucleus Web Interface at http://$(hostname -I | awk '{print $1}'):3009
2. Configure user accounts and permissions
3. Install Omniverse Connect applications on client workstations
4. Configure backup and monitoring procedures

Documentation:
- Configuration: $CONFIG_FILE
- Logs: $LOG_FILE
- Docker containers: docker ps | grep omniverse

================================================================================
EOF
}

# Main deployment function
main() {
    log "INFO" "Starting NVIDIA Omniverse Enterprise deployment..."
    
    # Get admin password from user if not set
    if [[ -z "${ADMIN_PASSWORD:-}" ]]; then
        read -s -p "Enter admin password (or press Enter to generate randomly): " ADMIN_PASSWORD
        ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(openssl rand -base64 32)}
        echo
    fi
    
    # Execute deployment steps
    check_prerequisites
    install_docker
    install_nvidia_container_toolkit
    deploy_nucleus_server
    deploy_cache_server
    configure_networking
    create_admin_user
    generate_summary
    
    log "INFO" "NVIDIA Omniverse Enterprise deployment completed successfully!"
}

# Execute main function
main "$@"
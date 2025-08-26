#!/bin/bash
# Dell Precision AI Workstation Deployment Script

set -e

WORKSTATION_MODEL="Precision-7860"
GPU_MODEL="RTX-A6000"
LOG_FILE="/var/log/workstation-deploy.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

deploy_workstation() {
    log "Starting Dell Precision AI Workstation deployment"
    
    # Update system
    log "Updating system packages"
    sudo apt update && sudo apt upgrade -y
    
    # Install NVIDIA drivers
    log "Installing NVIDIA GPU drivers"
    sudo apt install nvidia-driver-535 -y
    
    # Install CUDA toolkit
    log "Installing CUDA toolkit"
    wget -q https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda_12.2.0_535.54.03_linux.run
    sudo sh cuda_12.2.0_535.54.03_linux.run --silent --toolkit
    
    # Configure environment
    log "Configuring environment variables"
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    
    # Install Miniconda
    log "Installing Miniconda"
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
    
    # Create AI environment
    log "Creating AI development environment"
    $HOME/miniconda3/bin/conda create -n ai-workstation python=3.10 -y
    
    log "Dell Precision AI Workstation deployment completed successfully"
}

# Main execution
deploy_workstation
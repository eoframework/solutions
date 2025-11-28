---
document_title: Implementation Guide
solution_name: Dell Precision AI Workstation Infrastructure
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: Dell Technologies
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the Dell Precision AI Workstation Infrastructure. The guide follows a logical progression from prerequisite validation through production deployment, covering hardware installation, Ubuntu/NVIDIA configuration, PowerScale NAS setup, and ML framework deployment.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying 10 Dell Precision 7960 workstations with NVIDIA RTX A6000 GPUs and Dell PowerScale F600 shared storage.

## Implementation Approach

The implementation follows a phased methodology with three main phases over 6 weeks: Planning and Procurement (Weeks 1-2), Hardware and Configuration (Weeks 3-4), and Validation and Training (Weeks 5-6).

## Scope Summary

### In Scope

The following components are deployed using this guide.

- 10 Dell Precision 7960 workstations with RTX A6000 GPUs
- Ubuntu 22.04 LTS with NVIDIA drivers and CUDA 12.2
- ML frameworks: PyTorch 2.1, TensorFlow 2.14, Jupyter Lab
- Dell PowerScale F600 NAS (100TB) with NFS configuration
- Datadog monitoring with GPU metrics
- Dataset migration from AWS S3 to PowerScale

### Out of Scope

The following items are excluded from this deployment guide.

- Custom ML model development
- Distributed training configuration (Phase 2)
- MLOps pipeline setup
- End-user model training procedures

## Timeline Overview

The implementation follows a phased deployment approach with validation gates at each stage.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Planning, procurement, data center prep | 2 weeks | Hardware ordered, site ready |
| 2 | Hardware install, OS/GPU configuration | 2 weeks | All workstations operational |
| 3 | Validation, training, go-live | 2 weeks | Production handover complete |

# Prerequisites

This section documents all requirements that must be satisfied before hardware deployment can begin.

## Data Center Requirements

The following data center requirements must be validated before hardware delivery.

### Power Requirements

Each workstation requires dedicated power circuit meeting specifications below.

- **Voltage:** 208V single-phase
- **Amperage:** 15A dedicated circuit per workstation
- **Connector:** NEMA L6-20P or IEC C19
- **Total Load:** 15kW for 10 workstations + PowerScale
- **UPS:** Recommended but not required

### Cooling Requirements

The data center must support adequate cooling for GPU workloads.

- **Heat Load:** 1.4kW per workstation under full GPU load
- **Total Cooling:** 15kW (51,000 BTU/hour)
- **Ambient Temperature:** 18-27C (64-80F)
- **Humidity:** 20-80% non-condensing

### Space Requirements

Tower workstations require desk or floor space with clearance.

- **Footprint:** 50cm x 50cm per workstation
- **Height Clearance:** 60cm
- **Airflow:** Front-to-back, 30cm clearance rear
- **Total Area:** 10 workstation positions

## Network Requirements

Network infrastructure must support 10GbE connectivity to PowerScale.

### Required Network Equipment

Validate the following network components are available.

- 10GbE switch with 12+ SFP+ ports
- 10GbE NICs in workstations (included with Precision 7960)
- Cat6a or fiber cabling to each workstation
- VLAN support on switches

### Network Configuration Prerequisites

The following network configurations must be prepared.

- Storage VLAN ID allocated (recommended: VLAN 200)
- Management VLAN ID allocated (recommended: VLAN 100)
- IP address ranges for storage network (e.g., 10.200.0.0/24)
- IP address ranges for management network (e.g., 10.100.0.0/24)
- Jumbo frame support enabled on switches (MTU 9000)

## Software Requirements

Download and stage the following software before deployment.

### Operating System

Prepare Ubuntu installation media for deployment.

```bash
# Download Ubuntu 22.04.3 LTS Server ISO
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Verify checksum
sha256sum ubuntu-22.04.3-live-server-amd64.iso
# Expected: a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd

# Create bootable USB (replace /dev/sdX with your USB device)
sudo dd if=ubuntu-22.04.3-live-server-amd64.iso of=/dev/sdX bs=4M status=progress
```

### NVIDIA Software

Download NVIDIA drivers and CUDA toolkit.

```bash
# NVIDIA Driver 535.86.05
wget https://us.download.nvidia.com/XFree86/Linux-x86_64/535.86.05/NVIDIA-Linux-x86_64-535.86.05.run

# CUDA Toolkit 12.2
wget https://developer.download.nvidia.com/compute/cuda/12.2.0/local_installers/cuda_12.2.0_535.54.03_linux.run

# cuDNN 8.9.5 (requires NVIDIA Developer account)
# Download from: https://developer.nvidia.com/cudnn
```

## Access Requirements

Validate the following access credentials and permissions.

- Dell TechDirect account for ProDeploy coordination
- Dell PowerScale administrative credentials
- Datadog API key and application key
- AWS CLI credentials (for S3 dataset migration)
- SSH key pairs for all administrators

# Phase 1: Hardware Installation

This section covers the physical installation of Dell Precision 7960 workstations.

## Dell ProDeploy Coordination

Dell ProDeploy handles physical installation and initial configuration.

### Pre-Installation Checklist

Complete the following before Dell ProDeploy arrival.

- [ ] Confirm delivery date with Dell logistics
- [ ] Prepare data center space and power circuits
- [ ] Verify network cabling is in place
- [ ] Assign workstation hostnames and IP addresses
- [ ] Schedule IT staff availability during installation

### ProDeploy Installation Tasks

Dell ProDeploy performs the following tasks.

1. Unpack and inventory all hardware components
2. Position workstations in designated locations
3. Connect power cables to 208V circuits
4. Connect network cables (10GbE and 1GbE)
5. Power on and verify POST completion
6. Configure iDRAC for remote management
7. Document serial numbers and MAC addresses

### Post-Installation Verification

Verify the following after ProDeploy completes.

```bash
# Verify all workstations power on
# Check iDRAC connectivity from management network
ping 10.100.0.11  # Workstation 1 iDRAC
ping 10.100.0.12  # Workstation 2 iDRAC
# ... repeat for all workstations

# Access iDRAC web interface
# https://10.100.0.11 (default credentials: root/calvin)
```

## Hardware Inventory Documentation

Document all hardware details for asset management.

<!-- TABLE_CONFIG: widths=[15, 20, 20, 20, 25] -->
| Workstation | Service Tag | iDRAC IP | 10GbE MAC | Location |
|-------------|-------------|----------|-----------|----------|
| ai-ws-01 | [SERVICE_TAG] | 10.100.0.11 | [MAC_ADDR] | DC-Row1-Pos1 |
| ai-ws-02 | [SERVICE_TAG] | 10.100.0.12 | [MAC_ADDR] | DC-Row1-Pos2 |
| ai-ws-03 | [SERVICE_TAG] | 10.100.0.13 | [MAC_ADDR] | DC-Row1-Pos3 |
| ai-ws-04 | [SERVICE_TAG] | 10.100.0.14 | [MAC_ADDR] | DC-Row1-Pos4 |
| ai-ws-05 | [SERVICE_TAG] | 10.100.0.15 | [MAC_ADDR] | DC-Row1-Pos5 |
| ai-ws-06 | [SERVICE_TAG] | 10.100.0.16 | [MAC_ADDR] | DC-Row2-Pos1 |
| ai-ws-07 | [SERVICE_TAG] | 10.100.0.17 | [MAC_ADDR] | DC-Row2-Pos2 |
| ai-ws-08 | [SERVICE_TAG] | 10.100.0.18 | [MAC_ADDR] | DC-Row2-Pos3 |
| ai-ws-09 | [SERVICE_TAG] | 10.100.0.19 | [MAC_ADDR] | DC-Row2-Pos4 |
| ai-ws-10 | [SERVICE_TAG] | 10.100.0.20 | [MAC_ADDR] | DC-Row2-Pos5 |

# Phase 2: Operating System Installation

This section covers Ubuntu 22.04 LTS installation and base configuration.

## Ubuntu Installation

Install Ubuntu Server on each workstation using the following procedure.

### Boot from USB

Configure workstation to boot from USB installation media.

1. Insert Ubuntu USB into workstation
2. Power on and press F12 for boot menu
3. Select USB device from boot menu
4. Choose "Install Ubuntu Server"

### Installation Options

Select the following options during installation.

```
Language: English
Keyboard: US (or appropriate layout)
Network: DHCP for initial install (configure static later)
Storage: Use entire disk (4TB NVMe)
  - Enable LVM
  - Encrypt with LUKS (recommended)
Your name: Administrator
Server name: ai-ws-01 (adjust for each workstation)
Username: admin
Password: [SECURE_PASSWORD]
SSH: Install OpenSSH server
  - Import SSH identity: No
Featured snaps: None
```

### Post-Installation Base Configuration

After Ubuntu installation completes, perform base configuration.

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y \
  build-essential \
  linux-headers-$(uname -r) \
  dkms \
  net-tools \
  htop \
  vim \
  curl \
  wget \
  git \
  nfs-common

# Configure timezone
sudo timedatectl set-timezone America/New_York

# Configure hostname (if not set during install)
sudo hostnamectl set-hostname ai-ws-01
```

## Network Configuration

Configure static IP addresses for storage and management networks.

### Netplan Configuration

Create network configuration file for static IPs.

```bash
# Create netplan configuration
sudo vim /etc/netplan/00-installer-config.yaml
```

```yaml
# /etc/netplan/00-installer-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    # Management network (1GbE)
    eno1:
      addresses:
        - 10.100.0.21/24
      routes:
        - to: default
          via: 10.100.0.1
      nameservers:
        addresses:
          - 10.100.0.1
          - 8.8.8.8
    # Storage network (10GbE)
    enp61s0f0:
      addresses:
        - 10.200.0.21/24
      mtu: 9000
```

```bash
# Apply network configuration
sudo netplan apply

# Verify network configuration
ip addr show
ip route show
```

### Verify Network Connectivity

Test network connectivity to all required destinations.

```bash
# Test management network
ping -c 4 10.100.0.1

# Test storage network
ping -c 4 10.200.0.250  # PowerScale IP

# Test internet connectivity
ping -c 4 8.8.8.8
```

## SSH Configuration

Configure SSH for secure key-based authentication.

### Generate SSH Keys

Generate SSH key pairs on administrator workstation.

```bash
# Generate ed25519 SSH key (on admin workstation)
ssh-keygen -t ed25519 -C "admin@ai-workstations"

# Copy public key to each workstation
ssh-copy-id -i ~/.ssh/id_ed25519.pub admin@10.100.0.21
```

### Harden SSH Configuration

Configure SSH daemon for security.

```bash
# Edit SSH configuration
sudo vim /etc/ssh/sshd_config
```

```
# /etc/ssh/sshd_config modifications
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ClientAliveInterval 300
ClientAliveCountMax 2
```

```bash
# Restart SSH daemon
sudo systemctl restart sshd
```

# Phase 3: GPU and CUDA Installation

This section covers NVIDIA driver and CUDA toolkit installation.

## NVIDIA Driver Installation

Install NVIDIA proprietary drivers for RTX A6000 GPU.

### Disable Nouveau Driver

Blacklist the open-source Nouveau driver before installing NVIDIA drivers.

```bash
# Create blacklist file
sudo bash -c 'echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf'
sudo bash -c 'echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf'

# Regenerate initramfs
sudo update-initramfs -u

# Reboot system
sudo reboot
```

### Install NVIDIA Driver

Install the NVIDIA 535.x production driver.

```bash
# Install prerequisites
sudo apt install -y build-essential linux-headers-$(uname -r)

# Make driver installer executable
chmod +x NVIDIA-Linux-x86_64-535.86.05.run

# Run driver installer
sudo ./NVIDIA-Linux-x86_64-535.86.05.run

# Follow prompts:
# - Accept license agreement
# - Install 32-bit compatibility libraries: Yes
# - Update X configuration: Yes (not required for server)

# Reboot to load driver
sudo reboot
```

### Verify Driver Installation

Confirm NVIDIA driver is correctly installed.

```bash
# Check driver version
nvidia-smi

# Expected output:
# +-----------------------------------------------------------------------------+
# | NVIDIA-SMI 535.86.05    Driver Version: 535.86.05    CUDA Version: 12.2     |
# |-------------------------------+----------------------+----------------------+
# | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
# | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
# |===============================+======================+======================|
# |   0  NVIDIA RTX A6000    Off  | 00000000:61:00.0 Off |                  Off |
# | 30%   25C    P8    19W / 300W |      0MiB / 49140MiB |      0%      Default |
# +-------------------------------+----------------------+----------------------+

# Verify GPU detected
lspci | grep -i nvidia
```

## CUDA Toolkit Installation

Install CUDA 12.2 toolkit for GPU computing.

### Install CUDA

Run CUDA installer with appropriate options.

```bash
# Make installer executable
chmod +x cuda_12.2.0_535.54.03_linux.run

# Run installer (skip driver since already installed)
sudo ./cuda_12.2.0_535.54.03_linux.run --toolkit --silent

# Add CUDA to PATH
echo 'export PATH=/usr/local/cuda-12.2/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

### Verify CUDA Installation

Confirm CUDA toolkit is correctly installed.

```bash
# Check CUDA version
nvcc --version
# Expected: nvcc: NVIDIA (R) Cuda compiler driver
# Cuda compilation tools, release 12.2, V12.2.91

# Compile and run CUDA sample
cd /usr/local/cuda-12.2/samples/1_Utilities/deviceQuery
sudo make
./deviceQuery

# Expected: Result = PASS
```

## cuDNN Installation

Install cuDNN library for deep learning acceleration.

```bash
# Extract cuDNN archive (downloaded from NVIDIA)
tar -xvf cudnn-linux-x86_64-8.9.5.29_cuda12-archive.tar.xz

# Copy files to CUDA directory
sudo cp cudnn-linux-x86_64-8.9.5.29_cuda12-archive/include/* /usr/local/cuda-12.2/include/
sudo cp cudnn-linux-x86_64-8.9.5.29_cuda12-archive/lib/* /usr/local/cuda-12.2/lib64/

# Set permissions
sudo chmod a+r /usr/local/cuda-12.2/include/cudnn*.h
sudo chmod a+r /usr/local/cuda-12.2/lib64/libcudnn*

# Verify cuDNN installation
cat /usr/local/cuda-12.2/include/cudnn_version.h | grep CUDNN_MAJOR -A 2
```

# Phase 4: PowerScale NAS Configuration

This section covers Dell PowerScale NFS configuration for shared storage.

## PowerScale Initial Setup

Configure PowerScale F600 for NFS exports.

### Create NFS Exports

Create NFS exports for dataset storage using PowerScale web interface or CLI.

```bash
# PowerScale CLI commands (run on PowerScale)
# Create directories
isi create /ifs/ai-workstations
isi create /ifs/ai-workstations/datasets
isi create /ifs/ai-workstations/projects
isi create /ifs/ai-workstations/checkpoints
isi create /ifs/ai-workstations/home

# Create NFS exports
isi nfs exports create /ifs/ai-workstations/datasets --clients="10.200.0.0/24"
isi nfs exports create /ifs/ai-workstations/projects --clients="10.200.0.0/24"
isi nfs exports create /ifs/ai-workstations/checkpoints --clients="10.200.0.0/24"
isi nfs exports create /ifs/ai-workstations/home --clients="10.200.0.0/24"
```

### Configure User Quotas

Set storage quotas for data scientist accounts.

```bash
# Create user quotas (10TB per user)
isi quota quotas create /ifs/ai-workstations/home/user1 user --hard-threshold=10T
isi quota quotas create /ifs/ai-workstations/home/user2 user --hard-threshold=10T
# ... repeat for all users
```

## NFS Mount Configuration on Workstations

Configure NFS mounts on each workstation.

### Create Mount Points

Create directories for NFS mounts.

```bash
# Create mount points
sudo mkdir -p /mnt/datasets
sudo mkdir -p /mnt/projects
sudo mkdir -p /mnt/checkpoints
sudo mkdir -p /mnt/nas-home
```

### Configure fstab

Add NFS mounts to /etc/fstab for persistent mounting.

```bash
# Edit fstab
sudo vim /etc/fstab
```

```
# /etc/fstab NFS entries
10.200.0.250:/ifs/ai-workstations/datasets    /mnt/datasets    nfs4  rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  0  0
10.200.0.250:/ifs/ai-workstations/projects    /mnt/projects    nfs4  rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  0  0
10.200.0.250:/ifs/ai-workstations/checkpoints /mnt/checkpoints nfs4  rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  0  0
10.200.0.250:/ifs/ai-workstations/home        /mnt/nas-home    nfs4  rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport  0  0
```

```bash
# Mount all NFS shares
sudo mount -a

# Verify mounts
df -h | grep mnt
```

### Verify NFS Performance

Validate NFS throughput meets target specifications.

```bash
# Install fio for benchmarking
sudo apt install -y fio

# Test NFS write performance
fio --name=nfs-write --directory=/mnt/projects --ioengine=libaio \
    --rw=write --bs=1M --direct=1 --size=10G --numjobs=1 --runtime=60

# Test NFS read performance
fio --name=nfs-read --directory=/mnt/projects --ioengine=libaio \
    --rw=read --bs=1M --direct=1 --size=10G --numjobs=1 --runtime=60

# Target: 1GB/s+ aggregate with concurrent streams
```

# Phase 5: ML Framework Installation

This section covers Python environment and ML framework setup.

## Miniconda Installation

Install Miniconda for Python environment management.

```bash
# Download Miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-py311_23.10.0-1-Linux-x86_64.sh

# Run installer
bash Miniconda3-py311_23.10.0-1-Linux-x86_64.sh -b -p $HOME/miniconda3

# Initialize conda
~/miniconda3/bin/conda init bash
source ~/.bashrc

# Update conda
conda update -n base -c defaults conda -y
```

## Create ML Environment

Create conda environment with ML frameworks.

```bash
# Create environment with Python 3.11
conda create -n ml python=3.11 -y
conda activate ml

# Install PyTorch with CUDA 12.1 support
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install TensorFlow
pip install tensorflow==2.14.0

# Install common ML packages
pip install \
  numpy \
  pandas \
  scikit-learn \
  matplotlib \
  seaborn \
  jupyterlab \
  ipykernel

# Install Jupyter kernel
python -m ipykernel install --user --name=ml --display-name="Python (ML)"
```

## Verify ML Framework Installation

Confirm frameworks can access GPU.

```bash
# Activate ML environment
conda activate ml

# Test PyTorch GPU access
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0)}')"

# Expected output:
# PyTorch: 2.1.0+cu121
# CUDA available: True
# GPU: NVIDIA RTX A6000

# Test TensorFlow GPU access
python -c "import tensorflow as tf; print(f'TensorFlow: {tf.__version__}'); print(f'GPUs: {tf.config.list_physical_devices(\"GPU\")}')"

# Expected output:
# TensorFlow: 2.14.0
# GPUs: [PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
```

## Configure Jupyter Lab

Set up Jupyter Lab for remote access.

```bash
# Generate Jupyter config
jupyter lab --generate-config

# Set password
jupyter lab password

# Configure for remote access (edit ~/.jupyter/jupyter_lab_config.py)
# c.ServerApp.ip = '0.0.0.0'
# c.ServerApp.port = 8888
# c.ServerApp.open_browser = False
```

# Phase 6: Monitoring Setup

This section covers Datadog monitoring configuration.

## Datadog Agent Installation

Install Datadog agent for infrastructure monitoring.

```bash
# Install Datadog agent (replace DD_API_KEY)
DD_API_KEY=your_api_key_here DD_SITE="datadoghq.com" bash -c \
  "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Verify agent status
sudo datadog-agent status
```

## NVIDIA GPU Integration

Configure Datadog to collect GPU metrics.

```bash
# Enable NVIDIA integration
sudo vim /etc/datadog-agent/conf.d/nvml.d/conf.yaml
```

```yaml
# /etc/datadog-agent/conf.d/nvml.d/conf.yaml
init_config:

instances:
  - name: gpu_metrics
```

```bash
# Restart Datadog agent
sudo systemctl restart datadog-agent

# Verify GPU metrics
sudo datadog-agent check nvml
```

## Custom Dashboards

Import or create dashboards for AI workstation monitoring.

Key metrics to display on dashboards include the following.

- GPU utilization percentage
- GPU memory usage
- GPU temperature
- NVMe disk usage
- NFS mount availability
- System CPU and memory

# Phase 7: Validation and Testing

This section covers validation procedures to confirm successful deployment.

## GPU Performance Validation

Run GPU benchmarks to validate performance.

```bash
# Install gpu-burn for stress testing
git clone https://github.com/wilicc/gpu-burn.git
cd gpu-burn
make

# Run 5-minute stress test
./gpu_burn 300

# Monitor temperature during test
watch -n 1 nvidia-smi

# Expected: 38+ TFLOPS, temperature below 83C
```

## Storage Performance Validation

Validate local and NFS storage performance.

```bash
# Local NVMe benchmark
sudo fio --name=nvme-seq-read --filename=/tmp/fio-test \
  --ioengine=libaio --rw=read --bs=1M --direct=1 \
  --size=10G --numjobs=4 --runtime=60

# Expected: 7000+ MB/s sequential read

# NFS aggregate benchmark (run on multiple workstations simultaneously)
fio --name=nfs-concurrent --directory=/mnt/projects \
  --ioengine=libaio --rw=read --bs=1M --direct=1 \
  --size=5G --numjobs=1 --runtime=60

# Expected: 1GB/s+ aggregate across all workstations
```

## End-to-End Training Test

Validate complete training workflow.

```bash
# Activate ML environment
conda activate ml

# Download sample dataset
mkdir -p /tmp/mnist-test
cd /tmp/mnist-test

# Create training script
cat > train_mnist.py << 'EOF'
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms
from torch.utils.data import DataLoader
import time

# Check GPU
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")
print(f"GPU: {torch.cuda.get_device_name(0)}")

# Load MNIST dataset
transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.1307,), (0.3081,))])
train_dataset = datasets.MNIST('./data', train=True, download=True, transform=transform)
train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)

# Simple CNN model
class SimpleCNN(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, 1)
        self.conv2 = nn.Conv2d(32, 64, 3, 1)
        self.fc1 = nn.Linear(9216, 128)
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        x = torch.relu(self.conv1(x))
        x = torch.relu(self.conv2(x))
        x = torch.max_pool2d(x, 2)
        x = torch.flatten(x, 1)
        x = torch.relu(self.fc1(x))
        x = self.fc2(x)
        return x

model = SimpleCNN().to(device)
optimizer = optim.Adam(model.parameters())
criterion = nn.CrossEntropyLoss()

# Training loop
start_time = time.time()
for epoch in range(5):
    model.train()
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        loss.backward()
        optimizer.step()
    print(f"Epoch {epoch+1}/5 completed")

elapsed = time.time() - start_time
print(f"Training completed in {elapsed:.2f} seconds")
print("GPU validation: PASSED")
EOF

# Run training test
python train_mnist.py
```

# Troubleshooting

This section provides solutions for common issues during deployment.

## NVIDIA Driver Issues

### Driver Installation Fails

If NVIDIA driver installation fails, follow these steps.

```bash
# Check for Nouveau driver
lsmod | grep nouveau

# If Nouveau is loaded, ensure blacklist is configured
cat /etc/modprobe.d/blacklist-nouveau.conf
# Should contain:
# blacklist nouveau
# options nouveau modeset=0

# Regenerate initramfs and reboot
sudo update-initramfs -u
sudo reboot
```

### nvidia-smi Shows No Devices

If GPU is not detected after driver installation.

```bash
# Check if GPU is visible to system
lspci | grep -i nvidia

# Check driver module is loaded
lsmod | grep nvidia

# If not loaded, try loading manually
sudo modprobe nvidia

# Check dmesg for errors
dmesg | grep -i nvidia
```

## NFS Mount Issues

### Mount Fails with Permission Denied

Verify NFS export configuration on PowerScale.

```bash
# Check export permissions on PowerScale
isi nfs exports list
isi nfs exports view 1  # Check client list

# Verify workstation IP is in allowed client range
# Check firewall rules allow NFS traffic (port 2049)
```

### Poor NFS Performance

If NFS throughput is below target.

```bash
# Verify jumbo frames are enabled
ip link show enp61s0f0 | grep mtu
# Should show mtu 9000

# Test network bandwidth
iperf3 -c 10.200.0.250 -t 30

# Verify NFS mount options include rsize/wsize
mount | grep nfs4
```

# Environment Setup

This section covers the initial setup of workstation configurations and environment-specific settings.

## Workstation Naming Convention

All workstations follow standardized naming for management and monitoring.

```
ai-ws-01 through ai-ws-10
```

## IP Address Assignment

Configure static IP addresses as documented in the Network Configuration section above.

## Environment Variables

Configure environment variables for CUDA and ML frameworks in user profiles.

```bash
# Add to ~/.bashrc for all users
export CUDA_HOME=/usr/local/cuda-12.2
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
```

# Infrastructure Deployment

This section covers the deployment of all infrastructure components including hardware, networking, storage, and monitoring.

## Phase 1: Networking Layer

Deploy the foundational networking infrastructure.

### Networking Components

The networking layer deploys the following resources.

- Storage VLAN (VLAN 200) for 10GbE NFS traffic
- Management VLAN (VLAN 100) for SSH and monitoring
- Switch configuration with jumbo frames (MTU 9000)
- Static IP assignments for all workstations

### Networking Deployment Steps

Execute the following to deploy networking.

```bash
# Configure VLAN 200 on switch (example Dell OS10)
interface vlan 200
  description "AI Workstation Storage Network"
  mtu 9000
  no shutdown

# Configure VLAN 100 on switch
interface vlan 100
  description "AI Workstation Management Network"
  no shutdown
```

### Networking Validation

Verify networking deployment.

```bash
# Verify VLAN connectivity
ping -c 4 10.200.0.1  # Storage gateway
ping -c 4 10.100.0.1  # Management gateway

# Verify jumbo frames
ping -c 4 -M do -s 8972 10.200.0.250  # PowerScale
```

## Phase 2: Security Layer

Deploy security controls including SSH hardening and access controls.

### Security Components

The security layer deploys the following resources.

- SSH key-based authentication on all workstations
- LUKS encryption on local NVMe drives
- User groups for access control (ai-admins, data-scientists)
- PowerScale quotas for storage management

### Security Deployment Steps

Execute SSH security hardening on all workstations.

```bash
# Disable password authentication
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Disable root login
sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH
sudo systemctl restart sshd
```

### Security Validation

Verify security controls.

```bash
# Verify password auth disabled
grep PasswordAuthentication /etc/ssh/sshd_config

# Verify root login disabled
grep PermitRootLogin /etc/ssh/sshd_config
```

## Phase 3: Compute Layer

Deploy compute resources including workstations, GPUs, and local storage.

### Compute Components

The compute layer deploys the following resources.

- 10 Dell Precision 7960 tower workstations
- NVIDIA RTX A6000 48GB GPUs (one per workstation)
- 4TB NVMe SSDs for local training data
- 512GB RAM per workstation for data preprocessing

### Compute Deployment Steps

Dell ProDeploy handles hardware installation. Post-ProDeploy:

```bash
# Verify all workstations powered on
for ip in 10.100.0.{21..30}; do
  echo "Checking $ip"
  ping -c 1 $ip && echo "OK" || echo "FAIL"
done

# Verify GPU in each workstation
for ip in 10.100.0.{21..30}; do
  ssh admin@$ip "nvidia-smi --query-gpu=name,memory.total --format=csv,noheader"
done
```

### Compute Validation

Verify compute deployment.

```bash
# Run GPU benchmark on each workstation
for ip in 10.100.0.{21..30}; do
  ssh admin@$ip "nvidia-smi dmon -d 1 -c 5"
done
```

## Phase 4: Monitoring Layer

Deploy monitoring infrastructure using Datadog.

### Monitoring Components

The monitoring layer deploys the following resources.

- Datadog agent on all workstations
- GPU metrics collection via NVML integration
- Custom dashboards for AI workstation monitoring
- Alerting for GPU temperature and utilization

### Monitoring Deployment Steps

Install Datadog agent on all workstations.

```bash
# Install Datadog agent (run on each workstation)
DD_API_KEY=your_api_key DD_SITE="datadoghq.com" bash -c \
  "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Enable NVIDIA integration
sudo mkdir -p /etc/datadog-agent/conf.d/nvml.d/
sudo tee /etc/datadog-agent/conf.d/nvml.d/conf.yaml << EOF
init_config:
instances:
  - name: gpu_metrics
EOF

# Restart agent
sudo systemctl restart datadog-agent
```

### Monitoring Validation

Verify monitoring deployment.

```bash
# Verify agent status
sudo datadog-agent status | grep -A 5 "Running Checks"

# Verify GPU metrics
sudo datadog-agent check nvml
```

# Application Configuration

This section covers post-infrastructure application configuration.

## Operating System Configuration

Ubuntu 22.04 LTS configuration is documented in Phase 2 above.

## ML Framework Configuration

PyTorch, TensorFlow, and Jupyter Lab installation is documented in Phase 5 above.

## Monitoring Agent Configuration

Datadog agent installation is documented in Phase 6 above.

# Integration Testing

This section covers integration testing procedures.

## GPU Integration Testing

Validate GPU access from ML frameworks as documented in Phase 5 ML Framework Installation.

## Storage Integration Testing

Validate NFS mounts and throughput as documented in Phase 4 PowerScale NAS Configuration.

## End-to-End Integration Testing

Complete end-to-end validation is documented in Phase 7 Validation and Testing.

# Security Validation

This section covers security validation procedures.

## SSH Key Authentication Validation

Verify SSH key authentication is properly configured on all workstations.

```bash
# Verify password authentication disabled
grep PasswordAuthentication /etc/ssh/sshd_config
# Expected: PasswordAuthentication no

# Verify key authentication works
ssh -i ~/.ssh/id_ed25519 admin@ai-ws-01
```

## Storage Quota Validation

Verify PowerScale user quotas are enforced.

```bash
# Test quota enforcement (on PowerScale)
isi quota quotas list --path=/ifs/ai-workstations/home
```

## Network Security Validation

Verify VLAN isolation and firewall rules.

```bash
# Verify storage network isolation
ping -c 4 10.200.0.250  # Should succeed from storage VLAN
# Management network should not reach storage VLAN directly
```

# Migration & Cutover

This section covers data migration and production cutover.

## Dataset Migration from Cloud

Migrate datasets from AWS S3 to PowerScale NAS.

```bash
# Configure AWS CLI on temporary workstation
aws configure

# Sync S3 bucket to PowerScale
aws s3 sync s3://source-bucket/datasets/ /mnt/datasets/ --request-payer requester

# Verify file integrity
find /mnt/datasets -type f -exec md5sum {} \; > /tmp/checksums.txt
```

## Production Cutover

Execute production cutover by completing validation and beginning production training workloads.

```bash
# Verify all workstations operational
for i in {01..10}; do
  echo "Checking ai-ws-$i"
  ssh admin@ai-ws-$i "nvidia-smi --query-gpu=name,memory.total --format=csv"
done

# Begin production workloads
# Data scientists can now submit training jobs
```

# Operational Handover

This section covers transition to steady-state operations.

## Monitoring Dashboard Handover

Provide Datadog dashboard access to IT operations team.

## Documentation Handover

Transfer all documentation to client IT team including this Implementation Guide, Detailed Design, and Test Plan.

## Support Transition

Transition from implementation support to steady-state Dell ProSupport Plus.

# Training Program

This section documents the training program for administrators and data scientists.

## Training Overview

The training program ensures administrators and data scientists achieve competency with the AI workstation infrastructure.

### Training Objectives

Upon completion of training, participants will be able to perform the following.

- Access workstations via SSH and run GPU-accelerated training jobs
- Monitor GPU utilization and troubleshoot common issues
- Manage conda environments and install ML packages
- Use Jupyter Lab for interactive development
- Understand PowerScale storage structure and quotas

### Training Approach

Training is delivered in two sessions over Week 5-6.

1. **Data Scientist Workshop (2 days):** Hands-on training for 10 data scientists
2. **Administrator Training (1 day):** Ubuntu, GPU drivers, PowerScale management

## Training Schedule

The following training modules are scheduled for delivery.

<!-- TABLE_CONFIG: widths=[10, 30, 17, 10, 15, 18] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | CUDA and GPU Optimization | Data Scientists | 4 | Hands-On | None |
| TRN-002 | PyTorch GPU Training | Data Scientists | 4 | Hands-On | TRN-001 |
| TRN-003 | TensorFlow GPU Training | Data Scientists | 4 | Hands-On | TRN-001 |
| TRN-004 | Jupyter Lab Workflows | Data Scientists | 4 | Hands-On | None |
| TRN-005 | Ubuntu System Administration | Administrators | 4 | Hands-On | None |
| TRN-006 | NVIDIA Driver Management | Administrators | 2 | Hands-On | TRN-005 |
| TRN-007 | PowerScale NAS Administration | Administrators | 2 | Hands-On | None |

## Data Scientist Training

### TRN-001: CUDA and GPU Optimization (4 hours, Hands-On)

This module provides hands-on GPU optimization training.

**Learning Objectives:**

- Understand CUDA architecture and GPU memory hierarchy
- Profile GPU utilization using nvidia-smi and nvprof
- Optimize data loading to maximize GPU utilization
- Debug common GPU memory issues

**Content:** CUDA basics, profiling tools, optimization techniques, memory management

### TRN-002: PyTorch GPU Training (4 hours, Hands-On)

This module covers PyTorch-specific GPU training techniques.

**Learning Objectives:**

- Configure PyTorch for GPU training
- Use DataLoader with multiple workers for efficient data loading
- Implement mixed precision training for faster execution
- Save and load model checkpoints

**Content:** PyTorch GPU basics, DataLoader optimization, mixed precision, checkpointing

## Administrator Training

### TRN-005: Ubuntu System Administration (4 hours, Hands-On)

This module covers Ubuntu administration for AI workstations.

**Learning Objectives:**

- Manage user accounts and groups
- Configure network settings and firewall rules
- Monitor system resources and troubleshoot issues
- Apply security updates safely

**Content:** User management, networking, monitoring, security updates

### TRN-006: NVIDIA Driver Management (2 hours, Hands-On)

This module covers NVIDIA driver administration.

**Learning Objectives:**

- Update NVIDIA drivers safely
- Troubleshoot driver issues
- Configure GPU persistence mode
- Monitor GPU health

**Content:** Driver updates, troubleshooting, persistence mode, health monitoring

## Training Materials

The following training materials are provided.

- Quick Start Guide for Data Scientists
- Administrator Runbook
- CUDA Optimization Cheat Sheet
- Troubleshooting Guide
- Video recordings of training sessions

# Appendices

## Appendix A: Workstation Inventory

Complete workstation inventory for the deployment.

<!-- TABLE_CONFIG: widths=[15, 20, 20, 25, 20] -->
| Hostname | Service Tag | iDRAC IP | Storage IP | Location |
|----------|-------------|----------|------------|----------|
| ai-ws-01 | [TAG] | 10.100.0.11 | 10.200.0.21 | Row 1 Pos 1 |
| ai-ws-02 | [TAG] | 10.100.0.12 | 10.200.0.22 | Row 1 Pos 2 |
| ai-ws-03 | [TAG] | 10.100.0.13 | 10.200.0.23 | Row 1 Pos 3 |
| ai-ws-04 | [TAG] | 10.100.0.14 | 10.200.0.24 | Row 1 Pos 4 |
| ai-ws-05 | [TAG] | 10.100.0.15 | 10.200.0.25 | Row 1 Pos 5 |
| ai-ws-06 | [TAG] | 10.100.0.16 | 10.200.0.26 | Row 2 Pos 1 |
| ai-ws-07 | [TAG] | 10.100.0.17 | 10.200.0.27 | Row 2 Pos 2 |
| ai-ws-08 | [TAG] | 10.100.0.18 | 10.200.0.28 | Row 2 Pos 3 |
| ai-ws-09 | [TAG] | 10.100.0.19 | 10.200.0.29 | Row 2 Pos 4 |
| ai-ws-10 | [TAG] | 10.100.0.20 | 10.200.0.30 | Row 2 Pos 5 |

## Appendix B: Software Versions

Standardized software versions for all workstations.

<!-- TABLE_CONFIG: widths=[35, 30, 35] -->
| Software | Version | Notes |
|----------|---------|-------|
| Ubuntu | 22.04.3 LTS | Jammy Jellyfish |
| NVIDIA Driver | 535.86.05 | Production branch |
| CUDA | 12.2 | Toolkit |
| cuDNN | 8.9.5 | For CUDA 12.x |
| PyTorch | 2.1.0 | With CUDA 12.1 support |
| TensorFlow | 2.14.0 | With CUDA 12.2 support |
| Miniconda | 23.10.0 | Python 3.11 default |

## Appendix C: Contact Information

This appendix provides contact information for the implementation team.

### Implementation Team

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Project Manager | [NAME] | pm@company.com | [PHONE] |
| Technical Lead | [NAME] | tech@company.com | [PHONE] |
| Solutions Architect | [NAME] | architect@company.com | [PHONE] |
| Dell Specialist | [NAME] | dell@company.com | [PHONE] |

### Support Contacts

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Support Level | Contact | Email | Response |
|---------------|---------|-------|----------|
| Dell ProSupport Plus | Dell | 1-800-xxx-xxxx | 4 hours |
| NVIDIA Enterprise | NVIDIA | enterprise.nvidia.com | Business hours |
| Datadog Support | Datadog | support@datadoghq.com | Business hours |
| Client IT | Help Desk | helpdesk@client.com | Business hours |

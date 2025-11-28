---
document_title: Implementation Guide
solution_name: NVIDIA DGX SuperPOD AI Infrastructure
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: nvidia
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the NVIDIA DGX SuperPOD AI Infrastructure. The guide covers datacenter preparation, DGX H100 installation, NVIDIA Quantum-2 InfiniBand fabric configuration, Base Command storage deployment, and enterprise software stack setup including Slurm workload manager and NGC containers.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying the 8-node DGX SuperPOD with 64 H100 GPUs, InfiniBand fabric, and enterprise AI platform.

## Implementation Approach

The implementation follows NVIDIA DGX SuperPOD Reference Architecture guidelines with Ansible automation for configuration management, NVIDIA-provided tools for hardware validation, and enterprise integration for authentication and monitoring.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| Ansible | DGX configuration management | `scripts/ansible/` | Ansible 2.14+, SSH access |
| Python | Validation and automation scripts | `scripts/python/` | Python 3.10+ |
| Bash | System administration scripts | `scripts/bash/` | Bash 4.0+ |
| NVIDIA Tools | Hardware validation | DGX OS included | DGX OS 6.0+ |

## Scope Summary

### In Scope

The following components are deployed using this implementation guide.

- 8x DGX H100 systems with hardware validation
- NVIDIA Quantum-2 InfiniBand 400 Gbps fabric (4x QM9700 switches)
- Base Command 1 PB NVMe storage cluster
- Slurm workload manager with GPU-aware scheduling
- NGC container runtime and AI frameworks
- DCGM monitoring with Prometheus/Grafana
- LDAP/AD integration for user authentication

### Out of Scope

The following items are excluded from this implementation.

- Datacenter facilities upgrades (power/cooling managed separately)
- Custom ML model development
- Ongoing managed services operations
- Phase 2 expansion planning

## Timeline Overview

The implementation follows a phased deployment approach with validation gates.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & Site Validation | 1 week | Site survey complete |
| 2 | DGX Hardware Installation | 2 weeks | All nodes powered on |
| 3 | InfiniBand Fabric Configuration | 1 week | Fabric validated |
| 4 | Storage & Software Stack | 2 weeks | Full stack operational |
| 5 | Testing & Validation | 1 week | All benchmarks passing |
| 6 | Training & Hypercare | 4 weeks | Team self-sufficient |

# Prerequisites

This section documents all requirements that must be satisfied before DGX SuperPOD deployment.

## Tool Installation

The following tools must be installed on the deployment workstation.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **Ansible** >= 2.14 - Configuration management
- [ ] **Python** >= 3.10 - Automation scripts
- [ ] **SSH Client** - Remote access to DGX nodes
- [ ] **Git** - Version control for playbooks
- [ ] **ibstat/perftest** - InfiniBand validation tools

### Ansible Installation

Install Ansible for DGX configuration management.

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ansible

# RHEL/CentOS
sudo dnf install -y ansible

# macOS (using Homebrew)
brew install ansible

# Verify installation
ansible --version
```

### Python Environment Setup

Set up Python environment for automation scripts.

```bash
# Verify Python version
python3 --version

# Create virtual environment
python3 -m venv dgx-deploy
source dgx-deploy/bin/activate

# Install required packages
pip install paramiko pyyaml jinja2

# Verify installation
python3 -c "import paramiko; print('Paramiko installed')"
```

## Datacenter Requirements

Verify the following datacenter prerequisites before hardware delivery.

### Power Requirements

```bash
# Power capacity verification checklist
# - Total capacity: 500 kW minimum for 8 DGX H100 systems
# - Per-node requirement: ~10.2 kW per DGX H100
# - PDU configuration: Redundant A+B feeds per node
# - Circuit breaker sizing: Sized for inrush current

# Document power panel locations and circuit assignments
cat > power-inventory.txt << 'EOF'
DGX-01: PDU-A1 Circuit 1-3, PDU-B1 Circuit 1-3
DGX-02: PDU-A1 Circuit 4-6, PDU-B1 Circuit 4-6
DGX-03: PDU-A2 Circuit 1-3, PDU-B2 Circuit 1-3
DGX-04: PDU-A2 Circuit 4-6, PDU-B2 Circuit 4-6
DGX-05: PDU-A3 Circuit 1-3, PDU-B3 Circuit 1-3
DGX-06: PDU-A3 Circuit 4-6, PDU-B3 Circuit 4-6
DGX-07: PDU-A4 Circuit 1-3, PDU-B4 Circuit 1-3
DGX-08: PDU-A4 Circuit 4-6, PDU-B4 Circuit 4-6
EOF
```

### Cooling Requirements

```bash
# Cooling capacity verification
# - Total cooling: 500 kW thermal capacity
# - Inlet temperature: 18-27°C (64-80°F)
# - Humidity: 20-80% non-condensing
# - Airflow: Front-to-back through DGX systems

# Verify CRAC/CRAH capacity
echo "Cooling capacity check:"
echo "- Required: 500 kW"
echo "- Available: [DOCUMENT_ACTUAL_CAPACITY]"
echo "- Hot aisle containment: [YES/NO]"
```

### Network Requirements

```bash
# Management network requirements
# - 100 GbE or 25 GbE for management traffic
# - VLAN for DGX management network
# - DHCP or static IP allocation

# Document network allocations
cat > network-inventory.txt << 'EOF'
Management VLAN: 100
Management Subnet: 10.100.0.0/24
Gateway: 10.100.0.1
DNS Servers: 10.100.0.10, 10.100.0.11
NTP Servers: 10.100.0.20, 10.100.0.21

DGX-01: 10.100.0.101
DGX-02: 10.100.0.102
DGX-03: 10.100.0.103
DGX-04: 10.100.0.104
DGX-05: 10.100.0.105
DGX-06: 10.100.0.106
DGX-07: 10.100.0.107
DGX-08: 10.100.0.108
EOF
```

## Prerequisite Validation

Run the prerequisite validation script to verify all requirements.

```bash
#!/bin/bash
# prerequisite-check.sh - Validate deployment prerequisites

echo "=== DGX SuperPOD Prerequisite Validation ==="

# Check Ansible
echo -n "Checking Ansible... "
if command -v ansible &> /dev/null; then
    ansible --version | head -1
else
    echo "FAILED - Ansible not installed"
fi

# Check Python
echo -n "Checking Python... "
python3 --version

# Check SSH connectivity to management network
echo -n "Checking network connectivity... "
ping -c 1 10.100.0.1 &> /dev/null && echo "OK" || echo "FAILED"

# Check LDAP connectivity
echo -n "Checking LDAP connectivity... "
ldapsearch -x -H ldap://ldap.example.com -b "dc=example,dc=com" &> /dev/null && echo "OK" || echo "FAILED"

echo "=== Validation Complete ==="
```

### Validation Checklist

Complete this checklist before proceeding to hardware installation.

- [ ] Power capacity confirmed (500 kW available)
- [ ] Cooling capacity confirmed (500 kW thermal)
- [ ] Rack space available (4x 42U racks)
- [ ] Management network configured
- [ ] LDAP/AD connectivity verified
- [ ] DNS and NTP servers accessible
- [ ] SSH keys generated for automation

# Environment Setup

This section covers the initial setup of the deployment environment and DGX node configuration.

## Ansible Directory Structure

The Ansible automation follows a structured layout for DGX configuration.

```
delivery/scripts/ansible/
├── inventory/
│   ├── production/
│   │   └── hosts.yml              # DGX node inventory
│   └── group_vars/
│       └── dgx_nodes.yml          # Common DGX variables
├── playbooks/
│   ├── site.yml                   # Main playbook
│   ├── dgx-base-config.yml        # Base OS configuration
│   ├── slurm-setup.yml            # Slurm installation
│   ├── monitoring-setup.yml       # DCGM and Prometheus
│   └── user-management.yml        # LDAP integration
├── roles/
│   ├── dgx-common/                # Common DGX configuration
│   ├── slurm-node/                # Slurm compute node
│   ├── slurm-controller/          # Slurm controller
│   └── monitoring/                # Monitoring stack
└── templates/
    ├── slurm.conf.j2              # Slurm configuration
    └── gres.conf.j2               # GPU resource configuration
```

## Inventory Configuration

Configure the Ansible inventory with DGX node details.

```yaml
# inventory/production/hosts.yml
all:
  children:
    dgx_nodes:
      hosts:
        dgx-01:
          ansible_host: 10.100.0.101
          ib_ip: 10.200.0.101
        dgx-02:
          ansible_host: 10.100.0.102
          ib_ip: 10.200.0.102
        dgx-03:
          ansible_host: 10.100.0.103
          ib_ip: 10.200.0.103
        dgx-04:
          ansible_host: 10.100.0.104
          ib_ip: 10.200.0.104
        dgx-05:
          ansible_host: 10.100.0.105
          ib_ip: 10.200.0.105
        dgx-06:
          ansible_host: 10.100.0.106
          ib_ip: 10.200.0.106
        dgx-07:
          ansible_host: 10.100.0.107
          ib_ip: 10.200.0.107
        dgx-08:
          ansible_host: 10.100.0.108
          ib_ip: 10.200.0.108
    slurm_controller:
      hosts:
        slurm-ctrl-01:
          ansible_host: 10.100.0.50
```

## SSH Key Setup

Configure SSH key-based authentication for Ansible.

```bash
# Generate SSH key pair for deployment
ssh-keygen -t ed25519 -f ~/.ssh/dgx_deploy -N ""

# Copy public key to all DGX nodes
for i in {1..8}; do
    ssh-copy-id -i ~/.ssh/dgx_deploy.pub dgxadmin@10.100.0.10${i}
done

# Test connectivity
ansible dgx_nodes -i inventory/production/hosts.yml -m ping
```

# Infrastructure Deployment

This section covers the phased deployment of DGX SuperPOD infrastructure following NVIDIA best practices.

## Deployment Overview

Infrastructure deployment follows a dependency-ordered sequence.

<!-- TABLE_CONFIG: widths=[15, 25, 35, 25] -->
| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | Management VLAN, BMC Network, InfiniBand Fabric | None |
| 2 | Security | SSH Hardening, Firewall Rules, LDAP Integration | Networking |
| 3 | Compute | DGX H100 Installation, InfiniBand Validation | Security |
| 4 | Monitoring | DCGM, Prometheus, Grafana, Alerting | Compute |

## Phase 1: Networking Layer

### Management Network Configuration

```bash
# Configure management VLAN on network switches
# VLAN 100: DGX Management (10.100.0.0/24)

# Example Cisco NX-OS configuration
configure terminal
vlan 100
  name DGX-Management
exit

interface Ethernet1/1-8
  description DGX Management Ports
  switchport mode access
  switchport access vlan 100
exit

# Configure DHCP relay (if using DHCP)
interface Vlan100
  ip address 10.100.0.1/24
  ip dhcp relay address 10.50.0.10
exit
```

### BMC Network Configuration

```bash
# Configure BMC/IPMI network
# VLAN 101: BMC Out-of-Band Management (10.100.1.0/24)

configure terminal
vlan 101
  name DGX-BMC
exit

interface Ethernet1/9-16
  description DGX BMC Ports
  switchport mode access
  switchport access vlan 101
exit
```

### InfiniBand Fabric Setup

```bash
# InfiniBand Switch Configuration
# 4x QM9700 switches in leaf-spine topology

# Connect to switch management interface
ssh admin@ib-sw-01

# Verify switch firmware version
show version

# Configure switch hostname
config terminal
hostname ib-sw-01
exit

# Configure management IP
config terminal
interface mgmt0
  ip address 10.100.1.11/24
exit

# Enable Subnet Manager (on 2 switches for redundancy)
config terminal
ib sm
  sm-enable
  sm-priority 14
exit
```

## Phase 2: Security Layer

### SSH Hardening

```bash
# Disable password authentication on all DGX nodes
# Run via Ansible for all nodes
ansible dgx_nodes -i inventory/production/hosts.yml -m lineinfile -a \
  "path=/etc/ssh/sshd_config regexp='^PasswordAuthentication' line='PasswordAuthentication no'"

# Restart SSH service
ansible dgx_nodes -i inventory/production/hosts.yml -m service -a \
  "name=sshd state=restarted"

# Verify password authentication disabled
ssh -o PreferredAuthentications=password dgxadmin@dgx-01
# Expected: Permission denied
```

### Firewall Configuration

```bash
# Configure firewall rules on DGX nodes
# Allow SSH from management network only
iptables -A INPUT -p tcp --dport 22 -s 10.100.0.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

# Allow Slurm communication
iptables -A INPUT -p tcp --dport 6817:6819 -s 10.100.0.0/24 -j ACCEPT

# Allow monitoring
iptables -A INPUT -p tcp --dport 9090 -s 10.100.0.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 9400 -s 10.100.0.0/24 -j ACCEPT

# Save firewall rules
iptables-save > /etc/iptables/rules.v4
```

### LDAP Integration

```bash
# Install LDAP client packages
apt update
apt install -y sssd sssd-ldap ldap-utils

# Configure SSSD for LDAP authentication
cat > /etc/sssd/sssd.conf << 'EOF'
[sssd]
config_file_version = 2
services = nss, pam
domains = LDAP

[domain/LDAP]
id_provider = ldap
auth_provider = ldap
ldap_uri = ldap://ldap.example.com
ldap_search_base = dc=example,dc=com
ldap_id_use_start_tls = true
ldap_tls_reqcert = demand
ldap_tls_cacert = /etc/ssl/certs/ca-certificates.crt
cache_credentials = true
EOF

chmod 600 /etc/sssd/sssd.conf
systemctl enable --now sssd

# Verify LDAP integration
getent passwd ldapuser
id ldapuser
```

## Phase 3: Compute Layer

### DGX H100 Hardware Installation

#### Physical Installation

```bash
# DGX H100 Physical Installation Checklist
# Execute for each DGX node (dgx-01 through dgx-08)

echo "=== DGX H100 Installation Checklist ==="
echo "Node: dgx-0X"
echo ""
echo "[ ] Rack mounting hardware installed"
echo "[ ] DGX system mounted in rack (42U clearance)"
echo "[ ] Power cables connected (A+B feeds)"
echo "[ ] Management Ethernet connected (Port 1)"
echo "[ ] BMC Ethernet connected (IPMI port)"
echo "[ ] InfiniBand cables connected (8x ports)"
echo "[ ] Power on and POST validation"
```

### Initial Boot and BIOS Validation

```bash
# Connect to DGX BMC for initial configuration
ipmitool -I lanplus -H dgx-01-bmc -U admin -P [PASSWORD] chassis status

# Verify BIOS settings via BMC
# - Secure Boot: Enabled
# - SR-IOV: Enabled
# - Virtualization: Enabled
# - Boot Order: Disk first

# Power on the DGX system
ipmitool -I lanplus -H dgx-01-bmc -U admin -P [PASSWORD] chassis power on

# Monitor boot via serial console
ipmitool -I lanplus -H dgx-01-bmc -U admin -P [PASSWORD] sol activate
```

### DGX OS Validation

```bash
# SSH to DGX node after boot
ssh dgxadmin@dgx-01

# Verify DGX OS version
cat /etc/dgx-release

# Expected output:
# DGX_NAME="DGX Server"
# DGX_VERSION="6.0.0"
# DGX_SWBUILD_DATE="2024-01-15"

# Verify GPU detection
nvidia-smi

# Expected: 8x H100 80GB GPUs
# +-----------------------------------------------------------------------------+
# | NVIDIA-SMI 535.154.05   Driver Version: 535.154.05   CUDA Version: 12.2    |
# |-------------------------------+----------------------+----------------------+
# | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
# |   0  NVIDIA H100 80GB HBM3    |   00000000:18:00.0 Off |                    0 |
# |   1  NVIDIA H100 80GB HBM3    |   00000000:2A:00.0 Off |                    0 |
# |   2  NVIDIA H100 80GB HBM3    |   00000000:3A:00.0 Off |                    0 |
# |   3  NVIDIA H100 80GB HBM3    |   00000000:5D:00.0 Off |                    0 |
# |   4  NVIDIA H100 80GB HBM3    |   00000000:9A:00.0 Off |                    0 |
# |   5  NVIDIA H100 80GB HBM3    |   00000000:AB:00.0 Off |                    0 |
# |   6  NVIDIA H100 80GB HBM3    |   00000000:BA:00.0 Off |                    0 |
# |   7  NVIDIA H100 80GB HBM3    |   00000000:DB:00.0 Off |                    0 |
# +-------------------------------+----------------------+----------------------+

# Verify NVLink topology
nvidia-smi topo -m

# Verify GPU memory
nvidia-smi -q | grep "FB Memory"
# Expected: 81559 MiB per GPU
```

### InfiniBand Fabric Validation

```bash
# Verify InfiniBand switch connectivity
# Validate switch firmware versions
ssh admin@ib-sw-01 "show version"
# Expected: MLNX-OS version 3.11.x or later

# Verify all switches in fabric
ibswitches
# Expected: 4 switches listed
```

### Fabric Cabling Validation

```bash
# Verify InfiniBand port connectivity on each DGX node
ibstat

# Expected output for each port:
# Port 1:
#     State: Active
#     Physical state: LinkUp
#     Rate: 400 Gbps
#     Link layer: InfiniBand

# Verify all 8 ports per node
for port in {1..8}; do
    echo "Port $port:"
    ibstat mlx5_$((port-1)) | grep -E "State|Rate"
done

# Check fabric topology
ibnetdiscover > fabric-topology.txt

# Verify all nodes visible in fabric
cat fabric-topology.txt | grep -c "dgx-"
# Expected: 8
```

### InfiniBand Performance Validation

```bash
# Run InfiniBand bandwidth test between nodes
# On dgx-01 (server):
ib_send_bw -d mlx5_0

# On dgx-02 (client):
ib_send_bw -d mlx5_0 dgx-01

# Expected bandwidth: >380 Gbps per port

# Run latency test
# On dgx-01 (server):
ib_send_lat -d mlx5_0

# On dgx-02 (client):
ib_send_lat -d mlx5_0 dgx-01

# Expected latency: <2 microseconds
```

## Phase 4: Monitoring Layer

### DCGM Installation

```bash
# Install NVIDIA Data Center GPU Manager
# DCGM is pre-installed on DGX OS, verify version
dcgmi --version

# Start DCGM service
systemctl enable --now nvidia-dcgm

# Verify DCGM can discover GPUs
dcgmi discovery -l
# Expected: 8 GPUs listed per node
```

### Prometheus Setup

```bash
# Install Prometheus on monitoring server
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar xvfz prometheus-2.47.0.linux-amd64.tar.gz
cd prometheus-2.47.0.linux-amd64

# Configure Prometheus for DGX monitoring
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'dcgm'
    static_configs:
      - targets:
        - dgx-01:9400
        - dgx-02:9400
        - dgx-03:9400
        - dgx-04:9400
        - dgx-05:9400
        - dgx-06:9400
        - dgx-07:9400
        - dgx-08:9400

  - job_name: 'node'
    static_configs:
      - targets:
        - dgx-01:9100
        - dgx-02:9100
        - dgx-03:9100
        - dgx-04:9100
        - dgx-05:9100
        - dgx-06:9100
        - dgx-07:9100
        - dgx-08:9100
EOF

# Start Prometheus
./prometheus --config.file=prometheus.yml &
```

### Grafana Setup

```bash
# Install Grafana
apt install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
apt update
apt install -y grafana

# Start Grafana
systemctl enable --now grafana-server

# Access Grafana at http://monitoring-server:3000
# Default credentials: admin/admin

# Import NVIDIA DCGM dashboard (ID: 12239)
# Configure Prometheus data source
```

### DCGM Exporter Deployment

```bash
# Deploy DCGM exporter on each DGX node
ansible dgx_nodes -i inventory/production/hosts.yml -m shell -a '
docker run -d --gpus all --rm -p 9400:9400 \
  nvcr.io/nvidia/k8s/dcgm-exporter:3.3.0-3.2.0-ubuntu22.04
'

# Verify metrics export
curl http://dgx-01:9400/metrics | grep DCGM_FI_DEV_GPU_UTIL
```

# Application Configuration

This section covers Slurm workload manager and AI software stack deployment.

## Slurm Installation

### Slurm Controller Setup

```bash
# Install Slurm controller on slurm-ctrl-01
ansible-playbook -i inventory/production/hosts.yml playbooks/slurm-controller.yml

# Manual installation steps (if not using Ansible):
# Install Slurm packages
apt update
apt install -y slurm-wlm slurm-client munge

# Generate Munge key (on controller)
dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# Start Munge service
systemctl enable --now munge
```

### Slurm Configuration

```bash
# Create Slurm configuration
cat > /etc/slurm/slurm.conf << 'EOF'
# slurm.conf - DGX SuperPOD Configuration
ClusterName=dgx-superpod
SlurmctldHost=slurm-ctrl-01

# Scheduling
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core_Memory

# GPU Configuration
GresTypes=gpu
ProctrackType=proctrack/cgroup
TaskPlugin=task/cgroup,task/affinity

# Logging
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log

# Timeouts
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0

# Accounting
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=slurm-ctrl-01
JobAcctGatherType=jobacct_gather/cgroup

# Node Definitions
NodeName=dgx-[01-08] CPUs=112 Boards=1 SocketsPerBoard=2 CoresPerSocket=56 ThreadsPerCore=1 RealMemory=2048000 Gres=gpu:h100:8 State=UNKNOWN

# Partition Definitions
PartitionName=gpu-h100 Nodes=dgx-[01-08] Default=YES MaxTime=168:00:00 State=UP
EOF

# Create GRES configuration
cat > /etc/slurm/gres.conf << 'EOF'
# gres.conf - GPU Resource Configuration
NodeName=dgx-[01-08] Name=gpu Type=h100 File=/dev/nvidia[0-7]
EOF
```

### Slurm Compute Node Setup

```bash
# Deploy Slurm to all DGX nodes via Ansible
ansible-playbook -i inventory/production/hosts.yml playbooks/slurm-node.yml

# Manual steps per node:
# Copy Munge key from controller
scp slurm-ctrl-01:/etc/munge/munge.key /etc/munge/
chown munge:munge /etc/munge/munge.key
chmod 400 /etc/munge/munge.key

# Start Munge
systemctl enable --now munge

# Copy Slurm configuration from controller
scp slurm-ctrl-01:/etc/slurm/slurm.conf /etc/slurm/
scp slurm-ctrl-01:/etc/slurm/gres.conf /etc/slurm/

# Start Slurmd
systemctl enable --now slurmd
```

### Slurm Validation

```bash
# Verify Slurm controller status
systemctl status slurmctld

# Check node status
sinfo
# Expected:
# PARTITION   AVAIL  TIMELIMIT  NODES  STATE NODELIST
# gpu-h100*      up 7-00:00:00      8   idle dgx-[01-08]

# Verify GPU resources
sinfo -o "%N %G"
# Expected: dgx-[01-08] gpu:h100:8

# Submit test job
srun --gres=gpu:1 nvidia-smi

# Submit multi-node job
srun -N 2 --gres=gpu:8 --ntasks-per-node=1 hostname
```

## NGC Container Setup

### Container Runtime Configuration

```bash
# Verify NVIDIA Container Toolkit installation
nvidia-container-cli info

# Configure NGC registry access
docker login nvcr.io
# Username: $oauthtoken
# Password: [NGC_API_KEY]

# Pull common AI containers
docker pull nvcr.io/nvidia/pytorch:24.01-py3
docker pull nvcr.io/nvidia/tensorflow:24.01-tf2-py3
docker pull nvcr.io/nvidia/tritonserver:24.01-py3
```

### Singularity Configuration for Slurm

```bash
# Configure Singularity for HPC workloads
cat >> /etc/singularity/singularity.conf << 'EOF'
# NGC Registry Configuration
library = nvcr.io
EOF

# Pull container as Singularity image
singularity pull docker://nvcr.io/nvidia/pytorch:24.01-py3

# Test container with GPU
singularity exec --nv pytorch_24.01-py3.sif python -c "import torch; print(torch.cuda.device_count())"
# Expected: 8
```

# Integration Testing

This section covers end-to-end testing of the DGX SuperPOD deployment.

## Functional Testing

### GPU Validation Tests

```bash
# Run NVIDIA DCGM diagnostics
dcgmi diag -r 3

# Expected: All tests PASS
# +---------------------------+------------------------------------------------+
# | Diagnostic                | Result                                         |
# +===========================+================================================+
# | GPU Deployment            | PASS                                           |
# | GPU Memory                | PASS                                           |
# | PCIe Bandwidth            | PASS                                           |
# | GPU Thermal               | PASS                                           |
# +---------------------------+------------------------------------------------+

# Run GPU memory stress test
nvidia-smi -pm 1
dcgmi diag -r 2 -j report.json
```

### Multi-Node Communication Test

```bash
# Run NCCL all-reduce performance test
# Allocate 2 nodes with all GPUs
srun -N 2 --gres=gpu:8 --ntasks-per-node=8 \
    nccl-tests/build/all_reduce_perf -b 1M -e 1G -f 2

# Expected output:
# size(B)    count(B)  type  redop  time(us)  algbw(GB/s) busbw(GB/s)
# 1048576    262144    float sum    45.2      23.2        43.5
# ...
# 1073741824 268435456 float sum    2890      371.4       696.4

# Run all-to-all bandwidth test for full fabric validation
srun -N 8 --gres=gpu:8 --ntasks-per-node=8 \
    nccl-tests/build/all_reduce_perf -b 1G -e 1G
```

### Storage Performance Test

```bash
# Run IOR benchmark for storage throughput
srun -N 4 --ntasks-per-node=16 \
    ior -t 1m -b 16g -s 1 -F -C -e -o /shared/test/ior_test

# Expected output:
# Max Write: 14200.00 MiB/sec
# Max Read:  14500.00 MiB/sec

# Clean up test files
rm -rf /shared/test/ior_test*
```

## Performance Validation

### MLPerf Benchmark Execution

```bash
# Clone MLPerf training benchmarks
git clone https://github.com/mlcommons/training.git
cd training/image_classification

# Run ResNet-50 benchmark on single DGX
srun -N 1 --gres=gpu:8 ./run_and_time.sh

# Run ResNet-50 on full cluster (8 nodes, 64 GPUs)
srun -N 8 --gres=gpu:8 --ntasks-per-node=8 ./run_and_time.sh

# Record throughput for validation
# Expected: Near-linear scaling from 8 to 64 GPUs
```

### Distributed Training Test

```bash
# Create PyTorch distributed training test script
cat > distributed_test.py << 'EOF'
import torch
import torch.distributed as dist
import os

def main():
    dist.init_process_group(backend='nccl')
    rank = dist.get_rank()
    world_size = dist.get_world_size()
    local_rank = int(os.environ['LOCAL_RANK'])

    device = torch.device(f'cuda:{local_rank}')
    tensor = torch.ones(1000, 1000, device=device)

    dist.all_reduce(tensor, op=dist.ReduceOp.SUM)

    if rank == 0:
        print(f"World size: {world_size}")
        print(f"All-reduce successful: tensor sum = {tensor[0,0].item()}")

    dist.destroy_process_group()

if __name__ == '__main__':
    main()
EOF

# Run distributed test across 64 GPUs
srun -N 8 --gres=gpu:8 --ntasks-per-node=8 \
    torchrun --nnodes=8 --nproc_per_node=8 \
    --rdzv_backend=c10d --rdzv_endpoint=dgx-01:29500 \
    distributed_test.py
```

# Security Validation

This section covers security testing and hardening validation.

## Access Control Validation

### SSH Key Authentication Test

```bash
# Verify password authentication is disabled
grep "PasswordAuthentication" /etc/ssh/sshd_config
# Expected: PasswordAuthentication no

# Test SSH with password (should fail)
ssh -o PreferredAuthentications=password dgxadmin@dgx-01
# Expected: Permission denied

# Test SSH with key (should succeed)
ssh -i ~/.ssh/dgx_deploy dgxadmin@dgx-01
# Expected: Login successful
```

### LDAP Integration Test

```bash
# Verify LDAP user resolution
getent passwd ldapuser
# Expected: ldapuser:*:10001:10001:LDAP User:/home/ldapuser:/bin/bash

# Verify LDAP group resolution
getent group ai-researchers
# Expected: ai-researchers:*:20001:user1,user2,user3

# Test LDAP authentication via SSH
ssh ldapuser@dgx-01
# Expected: Login successful with home directory creation
```

### Slurm Access Control Test

```bash
# Verify partition access control
# As authorized user:
srun -p gpu-h100 --gres=gpu:1 hostname
# Expected: Job runs successfully

# Verify account-based limits
sacctmgr show assoc user=testuser format=user,account,partition,maxjobs
```

## Network Security Validation

```bash
# Verify management network isolation
# From DGX node, attempt to reach unauthorized network
ping 192.168.1.1
# Expected: Network unreachable (if properly segmented)

# Verify firewall rules
iptables -L -n | head -20

# Verify InfiniBand traffic isolation
ibnetdiscover | grep -v "dgx-\|ib-sw-"
# Expected: No unauthorized devices in fabric
```

# Migration & Cutover

This section covers the transition of workloads from cloud to DGX SuperPOD.

## Migration Preparation

### Dataset Migration

```bash
# Transfer training datasets to shared storage
rsync -avP --progress /source/datasets/ /shared/datasets/

# Verify data integrity
find /shared/datasets -type f -exec md5sum {} \; > dataset_checksums.txt

# Compare with source checksums
diff dataset_checksums.txt /source/dataset_checksums.txt
```

### User Migration

```bash
# Create Slurm accounts for teams
sacctmgr add account nlp-team Description="NLP Research Team"
sacctmgr add account cv-team Description="Computer Vision Team"
sacctmgr add account ml-team Description="Machine Learning Team"

# Add users to accounts
sacctmgr add user name=researcher1 account=nlp-team
sacctmgr add user name=researcher2 account=cv-team

# Configure fair-share scheduling
sacctmgr modify account nlp-team set fairshare=100
sacctmgr modify account cv-team set fairshare=100
sacctmgr modify account ml-team set fairshare=50
```

## Cutover Execution

### Go-Live Checklist

```bash
#!/bin/bash
# go-live-checklist.sh - Final validation before production

echo "=== DGX SuperPOD Go-Live Checklist ==="

# 1. Hardware validation
echo "Checking GPU status..."
nvidia-smi --query-gpu=gpu_name,memory.total --format=csv,noheader | head -8

# 2. Slurm validation
echo "Checking Slurm status..."
sinfo

# 3. Storage validation
echo "Checking storage..."
df -h /shared

# 4. Network validation
echo "Checking InfiniBand..."
ibstat | grep -E "State|Rate" | head -4

# 5. Monitoring validation
echo "Checking DCGM..."
dcgmi discovery -l

echo "=== Go-Live Checklist Complete ==="
```

# Operational Handover

This section covers the transition to steady-state operations.

## Operations Documentation

### Runbook Handover

```bash
# Key runbook procedures to review with operations team:

# 1. Daily health check
cat > /opt/dgx/scripts/daily-health-check.sh << 'EOF'
#!/bin/bash
echo "=== DGX SuperPOD Daily Health Check ==="
date

# Check all GPUs
nvidia-smi --query-gpu=gpu_name,temperature.gpu,utilization.gpu,memory.used --format=csv

# Check Slurm queue
squeue

# Check node status
sinfo

# Check storage
df -h /shared
EOF
chmod +x /opt/dgx/scripts/daily-health-check.sh

# 2. GPU troubleshooting
echo "GPU Troubleshooting Procedures:"
echo "- nvidia-smi for basic status"
echo "- dcgmi diag -r 1 for quick diagnostics"
echo "- dcgmi diag -r 3 for comprehensive diagnostics"
echo "- Check /var/log/nvidia-fabricmanager.log for fabric issues"

# 3. InfiniBand troubleshooting
echo "InfiniBand Troubleshooting Procedures:"
echo "- ibstat for port status"
echo "- ibnetdiscover for fabric topology"
echo "- iblinkinfo for link health"
```

### Monitoring Handover

```bash
# Grafana dashboard access
echo "Grafana URL: https://grafana.dgx.internal"
echo "Default dashboards:"
echo "- DGX GPU Overview"
echo "- Slurm Job Queue"
echo "- InfiniBand Fabric Health"
echo "- Storage Utilization"

# Alert escalation path
echo "Alert Escalation:"
echo "1. P1 (Critical): PagerDuty -> On-call engineer"
echo "2. P2 (High): Email notification -> Team channel"
echo "3. P3 (Medium): Ticket creation -> Queue review"
```

# Training Program

This section covers the training delivered to administrators and users.

## Administrator Training

### DGX Administration (4 hours)

```bash
# Training agenda:
# 1. DGX H100 Hardware Overview (30 min)
#    - GPU architecture and specifications
#    - NVLink and NVSwitch topology
#    - Power and cooling requirements

# 2. DGX OS Administration (60 min)
#    - System updates and patching
#    - Driver management
#    - DCGM configuration

# 3. Slurm Administration (90 min)
#    - Configuration management
#    - User and account management
#    - Partition and QoS setup
#    - Troubleshooting job issues

# 4. Monitoring and Alerting (60 min)
#    - Grafana dashboard navigation
#    - Alert response procedures
#    - Log analysis

# Hands-on exercises:
echo "Exercise 1: Create new Slurm partition"
echo "Exercise 2: Add new user with GPU quota"
echo "Exercise 3: Investigate stuck job"
echo "Exercise 4: Respond to GPU temperature alert"
```

## Data Scientist Training

### User Onboarding (2 hours)

```bash
# Training agenda:
# 1. DGX SuperPOD Overview (20 min)
#    - Available resources (64 GPUs, 1 PB storage)
#    - Access methods (SSH, JupyterHub)

# 2. Slurm Job Submission (40 min)
#    - Basic job submission (sbatch, srun)
#    - Requesting GPU resources
#    - Array jobs and job dependencies

# 3. NGC Container Usage (30 min)
#    - Pulling NGC containers
#    - Running containers with GPUs
#    - Custom container builds

# 4. Distributed Training (30 min)
#    - PyTorch DDP basics
#    - Multi-node job submission
#    - Checkpoint and resume

# Example job script for users:
cat > /shared/examples/pytorch-training.sbatch << 'EOF'
#!/bin/bash
#SBATCH --job-name=pytorch-training
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=8
#SBATCH --gres=gpu:8
#SBATCH --time=24:00:00
#SBATCH --output=training_%j.log

# Load environment
source /opt/dgx/env.sh

# Run distributed training
srun torchrun \
    --nnodes=$SLURM_NNODES \
    --nproc_per_node=8 \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$(scontrol show hostnames $SLURM_JOB_NODELIST | head -1):29500 \
    train.py
EOF
```

# Appendices

## Troubleshooting Guide

### Common Issues and Resolutions

```bash
# Issue: GPU not visible in nvidia-smi
# Resolution:
lspci | grep -i nvidia  # Verify GPU in PCIe
dmesg | grep -i nvidia  # Check driver messages
systemctl restart nvidia-fabricmanager  # Restart fabric manager

# Issue: InfiniBand port down
# Resolution:
ibstat  # Check port status
iblinkinfo  # Check link health
# If cable issue, reseat or replace cable

# Issue: Slurm job stuck in pending
# Resolution:
squeue -j <jobid> -o "%R"  # Check reason
sinfo -N  # Check node availability
scontrol show job <jobid>  # Detailed job info

# Issue: Storage performance degraded
# Resolution:
df -h /shared  # Check capacity
ior -t 1m -b 1g  # Test throughput
# Contact storage vendor if hardware issue
```

## Reference Commands

```bash
# GPU Commands
nvidia-smi                    # GPU status
nvidia-smi topo -m           # GPU topology
dcgmi diag -r 3              # GPU diagnostics

# InfiniBand Commands
ibstat                       # Port status
ibnetdiscover                # Fabric topology
ib_send_bw                   # Bandwidth test
ib_send_lat                  # Latency test

# Slurm Commands
sinfo                        # Node status
squeue                       # Job queue
sbatch script.sh            # Submit job
srun command                # Interactive job
scancel jobid               # Cancel job

# Container Commands
docker pull nvcr.io/...     # Pull container
singularity exec --nv       # Run with GPU
```

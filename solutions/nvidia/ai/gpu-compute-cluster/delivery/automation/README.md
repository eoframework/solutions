# NVIDIA GPU Compute Cluster - Automation

This directory contains Ansible automation for deploying and configuring NVIDIA GPU Compute Clusters with A100/H100 GPUs.

## Directory Structure

```
automation/
├── README.md                    # This file
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Ansible Galaxy dependencies
    ├── inventory/
    │   ├── prod/               # Production environment
    │   │   ├── hosts.yml       # Host inventory
    │   │   └── group_vars/
    │   │       └── all.yml     # Environment variables
    │   ├── test/               # Test environment
    │   │   ├── hosts.yml
    │   │   └── group_vars/
    │   │       └── all.yml
    │   └── dr/                 # DR environment
    │       ├── hosts.yml
    │       └── group_vars/
    │           └── all.yml
    ├── playbooks/
    │   ├── site.yml            # Master orchestration playbook
    │   ├── 01-foundation.yml   # OS and driver setup
    │   ├── 02-network.yml      # RoCE fabric configuration
    │   ├── 03-slurm.yml        # Slurm workload manager
    │   ├── 04-containers.yml   # NGC containers
    │   ├── 05-monitoring.yml   # Prometheus/Grafana/DCGM
    │   └── 06-validation.yml   # System validation
    ├── roles/
    │   ├── common/             # Base OS configuration
    │   ├── nvidia-drivers/     # NVIDIA driver installation
    │   ├── cuda-toolkit/       # CUDA toolkit installation
    │   ├── nccl/               # NCCL library installation
    │   ├── nvidia-docker/      # Container toolkit
    │   ├── roce-network/       # RoCE v2 network setup
    │   ├── slurm-controller/   # Slurm controller setup
    │   └── slurm-compute/      # Slurm compute node setup
    ├── templates/              # Jinja2 templates
    └── vars/
        └── secrets.yml         # Ansible Vault encrypted secrets
```

## Prerequisites

- Ansible 2.14 or higher
- SSH access to all target hosts
- Ansible Vault password for secrets

## Quick Start

### 1. Install Ansible Dependencies

```bash
cd ansible
ansible-galaxy install -r requirements.yml
```

### 2. Configure Secrets

```bash
cp vars/secrets.yml.template vars/secrets.yml
ansible-vault encrypt vars/secrets.yml
```

### 3. Deploy to Environment

```bash
# Production deployment
ansible-playbook -i inventory/prod playbooks/site.yml --ask-vault-pass

# Test deployment
ansible-playbook -i inventory/test playbooks/site.yml --ask-vault-pass

# DR deployment
ansible-playbook -i inventory/dr playbooks/site.yml --ask-vault-pass
```

### 4. Deploy Specific Phase

```bash
# Only foundation (OS, drivers)
ansible-playbook -i inventory/prod playbooks/site.yml --tags foundation

# Only RoCE network
ansible-playbook -i inventory/prod playbooks/site.yml --tags network

# Only Slurm
ansible-playbook -i inventory/prod playbooks/site.yml --tags slurm
```

## Environment Configuration

Environment-specific variables are stored in `inventory/{env}/group_vars/all.yml`.

These files are generated from `delivery/raw/configuration.csv` using:
```bash
python generate-ansible-vars.py --env prod
python generate-ansible-vars.py --env test
python generate-ansible-vars.py --env dr
```

## Tags Reference

| Tag | Description |
|-----|-------------|
| `foundation` | Base OS configuration, NVIDIA drivers, CUDA |
| `network` | RoCE v2 fabric configuration |
| `slurm` | Slurm workload manager installation |
| `containers` | NGC containers and NVIDIA container toolkit |
| `monitoring` | Prometheus, Grafana, DCGM exporters |
| `validation` | GPU tests and benchmark validation |

## Key Differences from DGX SuperPOD

- Uses RoCE v2 instead of InfiniBand for GPU interconnect
- Standard OEM servers with PCIe A100/H100 GPUs
- No Base Command Manager (BCM) - direct Slurm management
- Simpler fabric architecture (leaf switches only)

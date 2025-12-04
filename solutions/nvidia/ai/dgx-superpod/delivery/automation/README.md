# NVIDIA DGX SuperPOD - Automation

This directory contains Ansible automation for deploying and configuring NVIDIA DGX SuperPOD infrastructure.

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
    │   │       └── all.yml     # Environment variables (from configuration.csv)
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
    │   ├── 02-infiniband.yml   # InfiniBand fabric configuration
    │   ├── 03-slurm.yml        # Slurm workload manager
    │   ├── 04-containers.yml   # NGC containers and dev tools
    │   ├── 05-monitoring.yml   # Prometheus/Grafana/DCGM
    │   └── 06-validation.yml   # System validation and benchmarks
    ├── roles/
    │   ├── common/             # Base OS configuration
    │   ├── nvidia-drivers/     # NVIDIA driver installation
    │   ├── cuda-toolkit/       # CUDA toolkit installation
    │   ├── nccl/               # NCCL library installation
    │   ├── infiniband/         # InfiniBand/MLNX OFED setup
    │   ├── nvidia-docker/      # Container toolkit
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
# Copy template and edit
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

# Only Slurm
ansible-playbook -i inventory/prod playbooks/site.yml --tags slurm

# Only monitoring
ansible-playbook -i inventory/prod playbooks/site.yml --tags monitoring
```

### 5. Limit to Specific Hosts

```bash
# Only DGX nodes
ansible-playbook -i inventory/prod playbooks/site.yml --limit dgx_nodes

# Only management nodes
ansible-playbook -i inventory/prod playbooks/site.yml --limit management
```

## Environment Configuration

Environment-specific variables are stored in `inventory/{env}/group_vars/all.yml`.

These files are generated from `delivery/raw/configuration.csv` using:
```bash
python generate-ansible-vars.py --env prod
python generate-ansible-vars.py --env test
python generate-ansible-vars.py --env dr
```

## Validation

```bash
# Syntax check
ansible-playbook --syntax-check playbooks/site.yml

# Dry run
ansible-playbook -i inventory/prod playbooks/site.yml --check --diff

# Verify connectivity
ansible -i inventory/prod all -m ping
```

## Tags Reference

| Tag | Description |
|-----|-------------|
| `foundation` | Base OS configuration, NVIDIA drivers, CUDA |
| `infiniband` | InfiniBand fabric and MLNX OFED setup |
| `slurm` | Slurm workload manager installation |
| `containers` | NGC containers and development tools |
| `monitoring` | Prometheus, Grafana, DCGM exporters |
| `validation` | NCCL tests and benchmark validation |

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**
   - Verify SSH keys are deployed
   - Check firewall rules on target hosts

2. **Vault Password Issues**
   - Ensure `vars/secrets.yml` is encrypted
   - Use `--ask-vault-pass` or `ANSIBLE_VAULT_PASSWORD_FILE`

3. **Driver Installation Failures**
   - Verify kernel headers are installed
   - Check NVIDIA driver compatibility with kernel version

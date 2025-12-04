# Dell Precision AI Workstation - Ansible Automation

This folder contains Ansible playbooks and configuration for automating the deployment and configuration of Dell Precision AI Workstation infrastructure.

## Prerequisites

### Software Requirements
- Python 3.9+
- Ansible 2.14+
- Ansible Galaxy collections (see requirements.yml)

### Installation

```bash
# Create virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate

# Install Ansible
pip install ansible

# Install required collections
ansible-galaxy install -r requirements.yml
```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Galaxy collection dependencies
├── inventory/
│   ├── production/          # Production workstations
│   │   ├── hosts.yml
│   │   └── group_vars/all.yml
│   ├── test/                # Test/lab workstations
│   └── dr/                  # DR environment
├── playbooks/
│   ├── site.yml             # Master orchestration playbook
│   ├── workstation-provision.yml  # Phase 1: Workstation provisioning
│   ├── nvidia-drivers.yml   # Phase 2: GPU driver installation
│   ├── ml-stack.yml         # Phase 2: ML framework setup
│   ├── powerscale-mount.yml # Phase 3: NFS mount configuration
│   ├── monitoring-setup.yml # Phase 3: Datadog agent setup
│   └── validate.yml         # Phase 4: Post-deployment validation
├── vars/
│   ├── generated/           # Auto-generated from configuration.csv
│   │   ├── project.yml
│   │   ├── hardware.yml
│   │   ├── storage.yml
│   │   ├── network.yml
│   │   ├── software.yml
│   │   ├── application.yml
│   │   ├── monitoring.yml
│   │   ├── security.yml
│   │   ├── operations.yml
│   │   ├── support.yml
│   │   ├── performance.yml
│   │   └── dr.yml
│   ├── secrets.yml.template # Template for sensitive values
│   └── secrets.yml          # Ansible Vault encrypted (DO NOT COMMIT)
├── roles/                   # Custom roles (future)
└── logs/                    # Playbook execution logs
```

## Configuration

### 1. Generate Variables from Configuration

Variables are auto-generated from `delivery/raw/configuration.csv`:

```bash
# From eof-tools
python /path/to/eof-tools/automation/scripts/generate-ansible-vars.py /path/to/solution
```

### 2. Set Up Secrets

```bash
# Copy template
cp vars/secrets.yml.template vars/secrets.yml

# Edit and add actual secrets
vi vars/secrets.yml

# Encrypt with Ansible Vault
ansible-vault encrypt vars/secrets.yml
```

### 3. Vault Password

Create a vault password file (add to .gitignore):

```bash
echo 'your-vault-password' > .vault_password
chmod 600 .vault_password
```

## Usage

### Full Deployment

```bash
# Run all phases
ansible-playbook playbooks/site.yml --ask-vault-pass

# Or with vault password file
ansible-playbook playbooks/site.yml --vault-password-file .vault_password
```

### Phase-by-Phase Deployment

```bash
# Phase 1: Workstation Provisioning
ansible-playbook playbooks/workstation-provision.yml --ask-vault-pass

# Phase 2: NVIDIA Drivers and CUDA
ansible-playbook playbooks/nvidia-drivers.yml --ask-vault-pass

# Phase 2: ML Stack (PyTorch, TensorFlow, Jupyter)
ansible-playbook playbooks/ml-stack.yml --ask-vault-pass

# Phase 3: PowerScale NFS Mounts
ansible-playbook playbooks/powerscale-mount.yml --ask-vault-pass

# Phase 3: Monitoring Setup
ansible-playbook playbooks/monitoring-setup.yml --ask-vault-pass

# Phase 4: Validation
ansible-playbook playbooks/validate.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only foundation tasks
ansible-playbook playbooks/site.yml --tags foundation --ask-vault-pass

# Run multiple phases
ansible-playbook playbooks/site.yml --tags "foundation,core" --ask-vault-pass
```

### Dry Run (Check Mode)

```bash
# Preview changes without applying
ansible-playbook playbooks/site.yml --check --ask-vault-pass
```

## Deployment Phases

| Phase | Playbook | Description |
|-------|----------|-------------|
| 1 | workstation-provision.yml | iDRAC setup, BIOS, OS installation |
| 2 | nvidia-drivers.yml | NVIDIA driver, CUDA, cuDNN installation |
| 2 | ml-stack.yml | PyTorch, TensorFlow, Jupyter setup |
| 3 | powerscale-mount.yml | PowerScale NFS mount configuration |
| 3 | monitoring-setup.yml | Datadog agent and GPU monitoring |
| 4 | validate.yml | Post-deployment verification |

## Secrets Reference

The following secrets must be configured in `vars/secrets.yml`:

| Variable | Description |
|----------|-------------|
| `vault_powerscale_admin_user` | PowerScale admin username |
| `vault_powerscale_admin_password` | PowerScale admin password |
| `vault_idrac_user` | iDRAC username |
| `vault_idrac_password` | iDRAC password |
| `vault_datadog_api_key` | Datadog API key (if monitoring enabled) |
| `vault_ssh_private_key` | SSH key for workstation access |

## Infrastructure Overview

```
                    ┌─────────────────────────────────────┐
                    │       Dell PowerScale F600          │
                    │    (Shared Storage - 100TB NFS)     │
                    └───────────────┬─────────────────────┘
                                    │ 10GbE
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
┌───────┴───────┐          ┌───────┴───────┐          ┌───────┴───────┐
│ Precision 7960│          │ Precision 7960│          │ Precision 7960│
│   RTX A6000   │    ...   │   RTX A6000   │    ...   │   RTX A6000   │
│   512GB RAM   │          │   512GB RAM   │          │   512GB RAM   │
└───────────────┘          └───────────────┘          └───────────────┘
    Workstation 1              Workstation N         Workstation 10
```

## Troubleshooting

### iDRAC Connection Issues

```bash
# Test iDRAC connectivity
curl -k -u "root:password" https://idrac-ip/redfish/v1/Systems

# Verify SSH access to workstation
ssh -i ~/.ssh/dell_key user@workstation-ip
```

### GPU Driver Issues

```bash
# Check NVIDIA driver status
nvidia-smi

# Check CUDA version
nvcc --version
```

### Ansible Verbose Output

```bash
# Increase verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### View Logs

Logs are stored in `logs/ansible.log` and validation reports in `logs/validation_report_*.txt`.

## Support

- **Dell ProSupport Plus**: 24x7 hardware support
- **NVIDIA Enterprise Support**: GPU driver support
- **Escalation**: ai-team@company.com

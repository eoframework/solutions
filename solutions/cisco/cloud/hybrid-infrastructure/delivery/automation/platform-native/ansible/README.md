# Cisco HyperFlex Hybrid Infrastructure - Ansible Automation

This folder contains Ansible playbooks and configuration for automating the deployment and configuration of Cisco HyperFlex hyperconverged infrastructure.

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
│   └── hosts.yml           # Inventory file (uses vars from generated/)
├── playbooks/
│   ├── site.yml            # Master orchestration playbook
│   ├── 01-foundation.yml   # Phase 1: Fabric Interconnects, networking
│   ├── 02-cluster.yml      # Phase 1: HyperFlex cluster deployment
│   ├── 03-storage.yml      # Phase 2: Datastores, storage policies
│   ├── 04-integration.yml  # Phase 2: Intersight, vSphere, backup
│   ├── 05-validation.yml   # Phase 3: Go-live validation
│   └── rollback.yml        # Emergency rollback
├── vars/
│   ├── generated/          # Auto-generated from configuration.csv
│   │   ├── hyperflex.yml
│   │   ├── vmware.yml
│   │   └── ...
│   ├── secrets.yml.template # Template for sensitive values
│   └── secrets.yml         # Ansible Vault encrypted (DO NOT COMMIT)
├── roles/                  # Custom roles (future)
└── logs/                   # Playbook execution logs
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
# Phase 1: Foundation (Fabric Interconnects, VLANs)
ansible-playbook playbooks/01-foundation.yml --ask-vault-pass

# Phase 1: Cluster (HyperFlex cluster deployment)
ansible-playbook playbooks/02-cluster.yml --ask-vault-pass

# Phase 2: Storage (Datastores, storage policies)
ansible-playbook playbooks/03-storage.yml --ask-vault-pass

# Phase 2: Integrations (Intersight, vSphere, backup)
ansible-playbook playbooks/04-integration.yml --ask-vault-pass

# Phase 3: Validation (health checks, reporting)
ansible-playbook playbooks/05-validation.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only foundation tasks
ansible-playbook playbooks/site.yml --tags foundation --ask-vault-pass

# Run multiple phases
ansible-playbook playbooks/site.yml --tags "foundation,cluster" --ask-vault-pass
```

### Dry Run (Check Mode)

```bash
# Preview changes without applying
ansible-playbook playbooks/site.yml --check --ask-vault-pass
```

### Rollback

```bash
# Emergency rollback
ansible-playbook playbooks/rollback.yml --ask-vault-pass
```

## Deployment Phases

| Phase | Playbook | Description |
|-------|----------|-------------|
| 1 | 01-foundation.yml | Fabric Interconnects, VLANs, network policies |
| 1 | 02-cluster.yml | HyperFlex cluster deployment and verification |
| 2 | 03-storage.yml | Datastores, storage policies |
| 2 | 04-integration.yml | Intersight, vSphere, backup integrations |
| 3 | 05-validation.yml | Health checks, validation report |

## Secrets Reference

The following secrets must be configured in `vars/secrets.yml`:

| Variable | Description |
|----------|-------------|
| `vault_hx_admin_password` | HyperFlex admin password |
| `vault_ucs_admin_password` | UCS Manager admin password |
| `vault_vcenter_password` | vCenter admin password |
| `vault_esxi_root_password` | ESXi root password |
| `vault_intersight_api_key` | Intersight API key ID |
| `vault_intersight_secret_key` | Intersight API secret key |

## API Reference

This automation uses:
- **HyperFlex Connect API**: Cluster management and monitoring
- **Cisco Intersight API**: Cloud-based infrastructure management
- **VMware vSphere API**: vCenter and ESXi management
- **UCS Manager XML API**: Fabric Interconnect configuration

## Troubleshooting

### HyperFlex Connection Issues

```bash
# Test HyperFlex API connectivity
curl -k -u "admin:password" \
  https://hx-cluster-ip/api/v1/cluster

# Check cluster status via SSH
ssh admin@hx-cluster-ip
cluster status
```

### Ansible Verbose Output

```bash
# Increase verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### View Logs

Logs are stored in `logs/ansible.log` and validation reports in `logs/validation_report_*.txt`.

## Support

- **Cisco TAC**: For HyperFlex issues, open a TAC case
- **SmartNet Contract**: See `support.smartnet_contract` in configuration
- **Escalation**: See `support.escalation_contact` in configuration

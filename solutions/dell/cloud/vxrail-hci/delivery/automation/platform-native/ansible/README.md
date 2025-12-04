# Dell VxRail HCI - Ansible Automation

This folder contains Ansible playbooks and configuration for automating the deployment and configuration of Dell VxRail Hyperconverged Infrastructure.

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
│   ├── production/          # Production cluster
│   │   ├── hosts.yml
│   │   └── group_vars/all.yml
│   ├── test/                # Test/lab cluster
│   └── dr/                  # DR cluster
├── playbooks/
│   ├── site.yml             # Master orchestration playbook
│   ├── vxrail-precheck.yml  # Pre-deployment validation
│   ├── vxrail-deploy.yml    # VxRail cluster deployment
│   ├── vcenter-config.yml   # vCenter configuration
│   ├── vsan-config.yml      # vSAN storage setup
│   ├── networking-config.yml # Network configuration
│   ├── lifecycle-update.yml # VxRail LCM updates
│   └── validate.yml         # Post-deployment validation
├── vars/
│   ├── generated/           # Auto-generated from configuration.csv
│   │   ├── project.yml
│   │   ├── vxrail.yml
│   │   ├── hardware.yml
│   │   ├── vsan.yml
│   │   ├── network.yml
│   │   ├── idrac.yml
│   │   ├── vmware.yml
│   │   ├── security.yml
│   │   ├── backup.yml
│   │   ├── monitoring.yml
│   │   ├── support.yml
│   │   ├── operations.yml
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
# Pre-checks
ansible-playbook playbooks/vxrail-precheck.yml --ask-vault-pass

# VxRail Cluster Deployment
ansible-playbook playbooks/vxrail-deploy.yml --ask-vault-pass

# vCenter Configuration
ansible-playbook playbooks/vcenter-config.yml --ask-vault-pass

# vSAN Storage
ansible-playbook playbooks/vsan-config.yml --ask-vault-pass

# Networking
ansible-playbook playbooks/networking-config.yml --ask-vault-pass

# Validation
ansible-playbook playbooks/validate.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only pre-checks
ansible-playbook playbooks/site.yml --tags precheck --ask-vault-pass

# Run deployment and vSAN setup
ansible-playbook playbooks/site.yml --tags "deployment,vsan" --ask-vault-pass
```

### Dry Run (Check Mode)

```bash
# Preview changes without applying
ansible-playbook playbooks/site.yml --check --ask-vault-pass
```

## Deployment Phases

| Phase | Playbook | Description |
|-------|----------|-------------|
| 0 | vxrail-precheck.yml | Hardware and network validation |
| 1 | vxrail-deploy.yml | VxRail cluster initialization |
| 2 | vcenter-config.yml | vCenter Server configuration |
| 3 | vsan-config.yml | vSAN storage policies |
| 4 | networking-config.yml | vMotion, vSAN networks |
| 5 | validate.yml | Post-deployment verification |

## Secrets Reference

The following secrets must be configured in `vars/secrets.yml`:

| Variable | Description |
|----------|-------------|
| `vault_vxrail_admin_user` | VxRail Manager admin username |
| `vault_vxrail_admin_password` | VxRail Manager admin password |
| `vault_vcenter_admin_user` | vCenter admin username |
| `vault_vcenter_admin_password` | vCenter admin password |
| `vault_esxi_root_password` | ESXi root password |
| `vault_idrac_user` | iDRAC username |
| `vault_idrac_password` | iDRAC password |

## VxRail Architecture

```
                    ┌─────────────────────────────────────┐
                    │         VxRail Manager              │
                    │        (10.10.3.100)                │
                    └───────────────┬─────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
┌───────┴───────┐          ┌───────┴───────┐          ┌───────┴───────┐
│  VxRail E560  │          │  VxRail E560  │          │  VxRail E560  │
│   Node 01     │    ...   │   Node 02     │    ...   │   Node 04     │
│ vSAN: 46TB    │          │ vSAN: 46TB    │          │ vSAN: 46TB    │
└───────────────┘          └───────────────┘          └───────────────┘
    ESXi 8.0 U2               ESXi 8.0 U2               ESXi 8.0 U2
```

## Troubleshooting

### VxRail Manager API Issues

```bash
# Test VxRail Manager connectivity
curl -k -u "admin:password" \
  https://vxrail-manager/rest/vxm/v1/system

# Check cluster status
curl -k -u "admin:password" \
  https://vxrail-manager/rest/vxm/v1/cluster
```

### vSAN Health Check

```bash
# Via vCenter
esxcli vsan health cluster get
```

### Ansible Verbose Output

```bash
# Increase verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### View Logs

Logs are stored in `logs/ansible.log` and validation reports in `logs/validation_report_*.txt`.

## Support

- **Dell ProSupport Plus**: 24x7 mission-critical support
- **VMware Support**: vSphere and vSAN support
- **Escalation**: vxrail-team@company.com

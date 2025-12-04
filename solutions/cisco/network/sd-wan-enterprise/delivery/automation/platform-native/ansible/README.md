# Cisco SD-WAN Enterprise - Ansible Automation

This folder contains Ansible playbooks and configuration for automating the deployment and configuration of Cisco SD-WAN (Catalyst SD-WAN) enterprise solution.

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
│   ├── 01-foundation.yml   # Phase 1: Controller infrastructure
│   ├── 02-fabric.yml       # Phase 1: SD-WAN fabric and overlay
│   ├── 03-policies.yml     # Phase 2: QoS, security, routing policies
│   ├── 04-integration.yml  # Phase 2: Cloud OnRamp, SaaS
│   ├── 05-validation.yml   # Phase 3: Go-live validation
│   └── rollback.yml        # Emergency rollback
├── vars/
│   ├── generated/          # Auto-generated from configuration.csv
│   │   ├── vmanage.yml
│   │   ├── vsmart.yml
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
# Phase 1: Foundation (vManage, vSmart, vBond)
ansible-playbook playbooks/01-foundation.yml --ask-vault-pass

# Phase 1: Fabric (transports, VPNs, OMP, BFD)
ansible-playbook playbooks/02-fabric.yml --ask-vault-pass

# Phase 2: Policies (QoS, security, routing)
ansible-playbook playbooks/03-policies.yml --ask-vault-pass

# Phase 2: Integrations (Cloud OnRamp, SaaS)
ansible-playbook playbooks/04-integration.yml --ask-vault-pass

# Phase 3: Validation (health checks, reporting)
ansible-playbook playbooks/05-validation.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only foundation tasks
ansible-playbook playbooks/site.yml --tags foundation --ask-vault-pass

# Run multiple phases
ansible-playbook playbooks/site.yml --tags "foundation,fabric" --ask-vault-pass
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
| 1 | 01-foundation.yml | vManage, vSmart, vBond controller setup |
| 1 | 02-fabric.yml | Transport, VPN, OMP, BFD configuration |
| 2 | 03-policies.yml | QoS, security, and routing policies |
| 2 | 04-integration.yml | Cloud OnRamp, SaaS integrations |
| 3 | 05-validation.yml | Health checks, validation report |

## Secrets Reference

The following secrets must be configured in `vars/secrets.yml`:

| Variable | Description |
|----------|-------------|
| `vault_vmanage_admin_password` | vManage admin password |
| `vault_device_netconf_password` | Device NETCONF password |
| `vault_tacacs_key` | TACACS+ shared key |
| `vault_snmp_community` | SNMP community string |
| `vault_aws_access_key` | AWS access key (Cloud OnRamp) |
| `vault_aws_secret_key` | AWS secret key (Cloud OnRamp) |
| `vault_azure_client_secret` | Azure client secret (Cloud OnRamp) |

## SD-WAN Architecture

```
                    ┌─────────────┐
                    │   vManage   │ Management
                    └─────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌─────────┐      ┌─────────┐      ┌─────────┐
   │ vBond   │      │ vSmart  │      │ vSmart  │
   │(Orch)   │      │(Control)│      │(Control)│
   └─────────┘      └─────────┘      └─────────┘
        │                 │                 │
   ─────┴─────────────────┴─────────────────┴─────
                     SD-WAN Fabric
   ─────┬─────────────────┬─────────────────┬─────
        │                 │                 │
   ┌─────────┐      ┌─────────┐      ┌─────────┐
   │Hub vEdge│      │Branch   │      │Branch   │
   │(DC)     │      │vEdge    │      │vEdge    │
   └─────────┘      └─────────┘      └─────────┘
```

## Troubleshooting

### vManage Connection Issues

```bash
# Test vManage API connectivity
curl -k -u "admin:password" \
  https://vmanage-ip/dataservice/system/device/controllers

# Check vManage services
ssh admin@vmanage-ip
request nms all status
```

### Ansible Verbose Output

```bash
# Increase verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### View Logs

Logs are stored in `logs/ansible.log` and validation reports in `logs/validation_report_*.txt`.

## Support

- **Cisco TAC**: For SD-WAN issues, open a TAC case
- **SmartNet Contract**: See `support.smartnet_contract` in configuration
- **Escalation**: See `support.escalation_contact` in configuration

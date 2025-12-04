# Cisco DNA Center Network Analytics - Ansible Automation

This folder contains Ansible playbooks and configuration for automating the deployment and configuration of Cisco DNA Center Network Analytics.

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
│   ├── 01-foundation.yml   # Phase 1: Initial setup
│   ├── 02-discovery.yml    # Phase 1: Device discovery
│   ├── 03-policies.yml     # Phase 2: Policy deployment
│   ├── 04-integration.yml  # Phase 2: External integrations
│   ├── 05-validation.yml   # Phase 3: Go-live validation
│   └── rollback.yml        # Emergency rollback
├── vars/
│   ├── generated/          # Auto-generated from configuration.csv
│   │   ├── dnac.yml
│   │   ├── integrations.yml
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
# Phase 1: Foundation (site hierarchy, credentials, AD)
ansible-playbook playbooks/01-foundation.yml --ask-vault-pass

# Phase 1: Discovery (device discovery)
ansible-playbook playbooks/02-discovery.yml --ask-vault-pass

# Phase 2: Policies (AI analytics, application monitoring)
ansible-playbook playbooks/03-policies.yml --ask-vault-pass

# Phase 2: Integrations (ServiceNow, syslog, SMTP)
ansible-playbook playbooks/04-integration.yml --ask-vault-pass

# Phase 3: Validation (health checks, reporting)
ansible-playbook playbooks/05-validation.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only foundation tasks
ansible-playbook playbooks/site.yml --tags foundation --ask-vault-pass

# Run multiple phases
ansible-playbook playbooks/site.yml --tags "foundation,discovery" --ask-vault-pass
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
| 1 | 01-foundation.yml | Site hierarchy, credentials, AD integration |
| 1 | 02-discovery.yml | Device discovery and inventory |
| 2 | 03-policies.yml | AI Analytics, application monitoring, compliance |
| 2 | 04-integration.yml | ServiceNow, syslog, SMTP integrations |
| 3 | 05-validation.yml | Health checks, validation report |

## Secrets Reference

The following secrets must be configured in `vars/secrets.yml`:

| Variable | Description |
|----------|-------------|
| `vault_dnac_admin_password` | DNA Center admin password |
| `vault_ad_bind_password` | AD/LDAP bind password |
| `vault_servicenow_password` | ServiceNow integration password |
| `vault_netbox_api_token` | NetBox API token |
| `vault_device_cli_password` | Network device CLI password |
| `vault_device_enable_secret` | Network device enable secret |
| `vault_snmp_ro_community` | SNMP read-only community |
| `vault_snmp_rw_community` | SNMP read-write community |
| `vault_slack_webhook` | Slack webhook URL (optional) |

## Troubleshooting

### DNA Center Connection Issues

```bash
# Test connectivity
curl -k -u "admin:password" https://dnac-vip/dna/system/api/v1/auth/token -X POST

# Check certificate
openssl s_client -connect dnac-vip:443 -showcerts
```

### Ansible Verbose Output

```bash
# Increase verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### View Logs

Logs are stored in `logs/ansible.log` and validation reports in `logs/validation_report_*.txt`.

## Support

- **Cisco TAC**: For DNA Center issues, open a TAC case
- **SmartNet Contract**: See `support.smartnet_contract` in configuration
- **Escalation**: See `support.escalation_contact` in configuration

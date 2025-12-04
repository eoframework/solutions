# Cisco ISE Secure Access - Ansible Automation

This folder contains Ansible playbooks and configuration for automating the deployment and configuration of Cisco Identity Services Engine (ISE) for secure access.

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
│   ├── 01-foundation.yml   # Phase 1: Cluster setup, certificates
│   ├── 02-identity.yml     # Phase 1: AD/LDAP integration
│   ├── 03-policies.yml     # Phase 2: Auth/authz policies
│   ├── 04-integration.yml  # Phase 2: Duo, Umbrella, SecureX
│   ├── 05-validation.yml   # Phase 3: Go-live validation
│   └── rollback.yml        # Emergency rollback
├── vars/
│   ├── generated/          # Auto-generated from configuration.csv
│   │   ├── ise.yml
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
# Phase 1: Foundation (cluster, certificates, device groups)
ansible-playbook playbooks/01-foundation.yml --ask-vault-pass

# Phase 1: Identity (AD/LDAP integration)
ansible-playbook playbooks/02-identity.yml --ask-vault-pass

# Phase 2: Policies (authentication/authorization policies)
ansible-playbook playbooks/03-policies.yml --ask-vault-pass

# Phase 2: Integrations (Duo MFA, Umbrella, SecureX)
ansible-playbook playbooks/04-integration.yml --ask-vault-pass

# Phase 3: Validation (health checks, reporting)
ansible-playbook playbooks/05-validation.yml --ask-vault-pass
```

### Using Tags

```bash
# Run only foundation tasks
ansible-playbook playbooks/site.yml --tags foundation --ask-vault-pass

# Run multiple phases
ansible-playbook playbooks/site.yml --tags "foundation,identity" --ask-vault-pass
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
| 1 | 01-foundation.yml | Cluster verification, network device groups |
| 1 | 02-identity.yml | Active Directory, LDAP, SAML configuration |
| 2 | 03-policies.yml | Authentication/authorization policies |
| 2 | 04-integration.yml | Duo MFA, Umbrella, SecureX integrations |
| 3 | 05-validation.yml | Health checks, validation report |

## Secrets Reference

The following secrets must be configured in `vars/secrets.yml`:

| Variable | Description |
|----------|-------------|
| `vault_ise_admin_password` | ISE admin password |
| `vault_ad_join_password` | AD service account password for ISE join |
| `vault_duo_secret_key` | Duo integration secret key |
| `vault_duo_integration_key` | Duo integration key |
| `vault_umbrella_api_secret` | Umbrella API secret |
| `vault_securex_client_secret` | SecureX API client secret |
| `vault_radius_shared_secret` | RADIUS shared secret for NADs |
| `vault_tacacs_shared_secret` | TACACS+ shared secret for NADs |

## ISE API Reference

This automation uses:
- **ERS API**: External RESTful Services for configuration (port 9060)
- **OpenAPI**: For newer ISE 3.x features
- **cisco.ise Ansible Collection**: Native ISE modules

## Troubleshooting

### ISE Connection Issues

```bash
# Test ERS API connectivity
curl -k -u "admin:password" \
  https://ise-primary/ers/config/node \
  -H "Accept: application/json"

# Check ISE services
ssh admin@ise-primary
show application status ise
```

### Ansible Verbose Output

```bash
# Increase verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### View Logs

Logs are stored in `logs/ansible.log` and validation reports in `logs/validation_report_*.txt`.

## Support

- **Cisco TAC**: For ISE issues, open a TAC case
- **SmartNet Contract**: See `support.smartnet_contract` in configuration
- **Escalation**: See `support.escalation_contact` in configuration

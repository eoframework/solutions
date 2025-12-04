# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── anyconnect.yml
│   ├── deployment.yml
│   ├── duo.yml
│   ├── infrastructure.yml
│   ├── integrations.yml
│   ├── ise.yml
│   ├── monitoring.yml
│   ├── notifications.yml
│   ├── project.yml
│   ├── saml.yml
│   ├── securex.yml
│   ├── support.yml
│   ├── umbrella.yml
├── secrets.yml.template # Template for Ansible Vault secrets
├── secrets.yml          # Encrypted secrets (DO NOT COMMIT)
└── README.md            # This file
```

## Usage

### Regenerate vars from configuration.csv

```bash
python /path/to/eof-tools/automation/scripts/generate-ansible-vars.py /path/to/solution
```

### Set up secrets

```bash
# Copy template
cp secrets.yml.template secrets.yml

# Edit and add actual secrets
vi secrets.yml

# Encrypt with Ansible Vault
ansible-vault encrypt secrets.yml
```

### Include in playbooks

```yaml
- name: Example playbook
  hosts: all
  vars_files:
    - "{{ playbook_dir }}/../vars/generated/dnac.yml"
    - "{{ playbook_dir }}/../vars/generated/integrations.yml"
    - "{{ playbook_dir }}/../vars/secrets.yml"
```

## Generated Files

| File | Description |
|------|-------------|
| `generated/anyconnect.yml` | Anyconnect configuration |
| `generated/deployment.yml` | Deployment configuration |
| `generated/duo.yml` | Duo configuration |
| `generated/infrastructure.yml` | Infrastructure configuration |
| `generated/integrations.yml` | Integrations configuration |
| `generated/ise.yml` | Ise configuration |
| `generated/monitoring.yml` | Monitoring configuration |
| `generated/notifications.yml` | Notifications configuration |
| `generated/project.yml` | Project configuration |
| `generated/saml.yml` | Saml configuration |
| `generated/securex.yml` | Securex configuration |
| `generated/support.yml` | Support configuration |
| `generated/umbrella.yml` | Umbrella configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

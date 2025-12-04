# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── ai_analytics.yml
│   ├── app_monitoring.yml
│   ├── deployment.yml
│   ├── devices.yml
│   ├── dnac.yml
│   ├── ha.yml
│   ├── infrastructure.yml
│   ├── integrations.yml
│   ├── licensing.yml
│   ├── monitoring.yml
│   ├── notifications.yml
│   ├── operations.yml
│   ├── policies.yml
│   ├── project.yml
│   ├── security.yml
│   ├── support.yml
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
| `generated/ai_analytics.yml` | Ai Analytics configuration |
| `generated/app_monitoring.yml` | App Monitoring configuration |
| `generated/deployment.yml` | Deployment configuration |
| `generated/devices.yml` | Devices configuration |
| `generated/dnac.yml` | Dnac configuration |
| `generated/ha.yml` | Ha configuration |
| `generated/infrastructure.yml` | Infrastructure configuration |
| `generated/integrations.yml` | Integrations configuration |
| `generated/licensing.yml` | Licensing configuration |
| `generated/monitoring.yml` | Monitoring configuration |
| `generated/notifications.yml` | Notifications configuration |
| `generated/operations.yml` | Operations configuration |
| `generated/policies.yml` | Policies configuration |
| `generated/project.yml` | Project configuration |
| `generated/security.yml` | Security configuration |
| `generated/support.yml` | Support configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

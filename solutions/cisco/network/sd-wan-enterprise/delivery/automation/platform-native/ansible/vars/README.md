# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── bfd.yml
│   ├── cloud_onramp.yml
│   ├── deployment.yml
│   ├── infrastructure.yml
│   ├── monitoring.yml
│   ├── notifications.yml
│   ├── project.yml
│   ├── qos.yml
│   ├── saas.yml
│   ├── sdwan_fabric.yml
│   ├── security.yml
│   ├── support.yml
│   ├── transport.yml
│   ├── vbond.yml
│   ├── vedge.yml
│   ├── vmanage.yml
│   ├── vsmart.yml
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
| `generated/bfd.yml` | Bfd configuration |
| `generated/cloud_onramp.yml` | Cloud Onramp configuration |
| `generated/deployment.yml` | Deployment configuration |
| `generated/infrastructure.yml` | Infrastructure configuration |
| `generated/monitoring.yml` | Monitoring configuration |
| `generated/notifications.yml` | Notifications configuration |
| `generated/project.yml` | Project configuration |
| `generated/qos.yml` | Qos configuration |
| `generated/saas.yml` | Saas configuration |
| `generated/sdwan_fabric.yml` | Sdwan Fabric configuration |
| `generated/security.yml` | Security configuration |
| `generated/support.yml` | Support configuration |
| `generated/transport.yml` | Transport configuration |
| `generated/vbond.yml` | Vbond configuration |
| `generated/vedge.yml` | Vedge configuration |
| `generated/vmanage.yml` | Vmanage configuration |
| `generated/vsmart.yml` | Vsmart configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

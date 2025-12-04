# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── backup.yml
│   ├── fabric_interconnect.yml
│   ├── hyperflex.yml
│   ├── infrastructure.yml
│   ├── integrations.yml
│   ├── intersight.yml
│   ├── monitoring.yml
│   ├── network.yml
│   ├── notifications.yml
│   ├── project.yml
│   ├── support.yml
│   ├── vmware.yml
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
| `generated/backup.yml` | Backup configuration |
| `generated/fabric_interconnect.yml` | Fabric Interconnect configuration |
| `generated/hyperflex.yml` | Hyperflex configuration |
| `generated/infrastructure.yml` | Infrastructure configuration |
| `generated/integrations.yml` | Integrations configuration |
| `generated/intersight.yml` | Intersight configuration |
| `generated/monitoring.yml` | Monitoring configuration |
| `generated/network.yml` | Network configuration |
| `generated/notifications.yml` | Notifications configuration |
| `generated/project.yml` | Project configuration |
| `generated/support.yml` | Support configuration |
| `generated/vmware.yml` | Vmware configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

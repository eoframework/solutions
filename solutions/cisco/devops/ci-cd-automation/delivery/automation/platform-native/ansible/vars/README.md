# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── ansible_config.yml
│   ├── cisco_dna_center.yml
│   ├── container.yml
│   ├── gitlab.yml
│   ├── itsm.yml
│   ├── jenkins.yml
│   ├── kubernetes.yml
│   ├── logging.yml
│   ├── monitoring.yml
│   ├── netbox.yml
│   ├── notifications.yml
│   ├── nso.yml
│   ├── operations.yml
│   ├── pipeline.yml
│   ├── project.yml
│   ├── support.yml
│   ├── terraform.yml
│   ├── vault.yml
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
| `generated/ansible_config.yml` | Ansible Config configuration |
| `generated/cisco_dna_center.yml` | Cisco Dna Center configuration |
| `generated/container.yml` | Container configuration |
| `generated/gitlab.yml` | Gitlab configuration |
| `generated/itsm.yml` | Itsm configuration |
| `generated/jenkins.yml` | Jenkins configuration |
| `generated/kubernetes.yml` | Kubernetes configuration |
| `generated/logging.yml` | Logging configuration |
| `generated/monitoring.yml` | Monitoring configuration |
| `generated/netbox.yml` | Netbox configuration |
| `generated/notifications.yml` | Notifications configuration |
| `generated/nso.yml` | Nso configuration |
| `generated/operations.yml` | Operations configuration |
| `generated/pipeline.yml` | Pipeline configuration |
| `generated/project.yml` | Project configuration |
| `generated/support.yml` | Support configuration |
| `generated/terraform.yml` | Terraform configuration |
| `generated/vault.yml` | Vault configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

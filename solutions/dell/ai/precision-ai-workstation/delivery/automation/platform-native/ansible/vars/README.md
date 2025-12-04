# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── project.yml
│   ├── hardware.yml
│   ├── storage.yml
│   ├── network.yml
│   ├── software.yml
│   ├── application.yml
│   ├── monitoring.yml
│   ├── security.yml
│   ├── operations.yml
│   ├── support.yml
│   ├── performance.yml
│   └── dr.yml
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
    - "{{ playbook_dir }}/../vars/generated/project.yml"
    - "{{ playbook_dir }}/../vars/generated/hardware.yml"
    - "{{ playbook_dir }}/../vars/generated/storage.yml"
    - "{{ playbook_dir }}/../vars/secrets.yml"
```

## Generated Files

| File | Description |
|------|-------------|
| `generated/project.yml` | Project and ownership metadata |
| `generated/hardware.yml` | Dell Precision workstation hardware specs |
| `generated/storage.yml` | PowerScale NAS configuration |
| `generated/network.yml` | Network and VLAN settings |
| `generated/software.yml` | OS, NVIDIA, and ML framework versions |
| `generated/application.yml` | Jupyter and TensorBoard settings |
| `generated/monitoring.yml` | Datadog and alerting thresholds |
| `generated/security.yml` | SSH, firewall, and user groups |
| `generated/operations.yml` | Backup and update policies |
| `generated/support.yml` | Dell ProSupport configuration |
| `generated/performance.yml` | Target performance metrics |
| `generated/dr.yml` | Disaster recovery settings |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

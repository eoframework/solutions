# Ansible Variables

This directory contains Ansible variables for the solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── base_command_manager.yml
│   ├── cluster.yml
│   ├── containers.yml
│   ├── development.yml
│   ├── dr.yml
│   ├── facilities.yml
│   ├── hardware.yml
│   ├── mlops.yml
│   ├── monitoring.yml
│   ├── network.yml
│   ├── operations.yml
│   ├── project.yml
│   ├── security.yml
│   ├── software_stack.yml
│   ├── storage.yml
│   ├── support.yml
│   ├── workload_management.yml
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
| `generated/base_command_manager.yml` | Base Command Manager configuration |
| `generated/cluster.yml` | Cluster configuration |
| `generated/containers.yml` | Containers configuration |
| `generated/development.yml` | Development configuration |
| `generated/dr.yml` | Dr configuration |
| `generated/facilities.yml` | Facilities configuration |
| `generated/hardware.yml` | Hardware configuration |
| `generated/mlops.yml` | Mlops configuration |
| `generated/monitoring.yml` | Monitoring configuration |
| `generated/network.yml` | Network configuration |
| `generated/operations.yml` | Operations configuration |
| `generated/project.yml` | Project configuration |
| `generated/security.yml` | Security configuration |
| `generated/software_stack.yml` | Software Stack configuration |
| `generated/storage.yml` | Storage configuration |
| `generated/support.yml` | Support configuration |
| `generated/workload_management.yml` | Workload Management configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

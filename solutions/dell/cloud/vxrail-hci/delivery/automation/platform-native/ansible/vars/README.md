# Ansible Variables

This directory contains Ansible variables for the VxRail HCI solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── project.yml
│   ├── vxrail.yml
│   ├── hardware.yml
│   ├── vsan.yml
│   ├── network.yml
│   ├── idrac.yml
│   ├── vmware.yml
│   ├── security.yml
│   ├── backup.yml
│   ├── monitoring.yml
│   ├── support.yml
│   ├── operations.yml
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
    - "{{ playbook_dir }}/../vars/generated/vxrail.yml"
    - "{{ playbook_dir }}/../vars/generated/vmware.yml"
    - "{{ playbook_dir }}/../vars/secrets.yml"
```

## Generated Files

| File | Description |
|------|-------------|
| `generated/project.yml` | Project and ownership metadata |
| `generated/vxrail.yml` | VxRail cluster configuration |
| `generated/hardware.yml` | Dell PowerEdge hardware specs |
| `generated/vsan.yml` | vSAN storage configuration |
| `generated/network.yml` | Network and VLAN settings |
| `generated/idrac.yml` | iDRAC and OpenManage settings |
| `generated/vmware.yml` | VMware version information |
| `generated/security.yml` | Security and encryption settings |
| `generated/backup.yml` | PowerProtect backup configuration |
| `generated/monitoring.yml` | CloudIQ monitoring settings |
| `generated/support.yml` | Dell ProSupport configuration |
| `generated/operations.yml` | Lifecycle and maintenance settings |
| `generated/dr.yml` | Disaster recovery configuration |
| `secrets.yml.template` | Template for sensitive values |

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data
- Regenerate vars whenever `configuration.csv` changes

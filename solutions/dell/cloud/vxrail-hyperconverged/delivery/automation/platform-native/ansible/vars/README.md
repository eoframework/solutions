# Ansible Variables

This directory contains Ansible variables for the VxRail Enterprise Hyperconverged solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── project.yml
│   ├── vxrail.yml
│   ├── hardware.yml
│   ├── vsan.yml
│   ├── network.yml
│   ├── nsx.yml
│   ├── vmware.yml
│   ├── idrac.yml
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
cp secrets.yml.template secrets.yml
vi secrets.yml
ansible-vault encrypt secrets.yml
```

## Important Notes

- **DO NOT EDIT** files in `generated/` - they will be overwritten
- **DO NOT COMMIT** `secrets.yml` - it contains sensitive data

# Ansible Variables

This directory contains Ansible variables for the Dell PowerSwitch Datacenter solution.

## Directory Structure

```
vars/
├── generated/           # Auto-generated from configuration.csv
│   ├── project.yml
│   ├── fabric.yml
│   ├── bgp.yml
│   ├── evpn.yml
│   ├── network.yml
│   ├── authentication.yml
│   ├── management.yml
│   ├── security.yml
│   ├── operations.yml
│   ├── support.yml
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

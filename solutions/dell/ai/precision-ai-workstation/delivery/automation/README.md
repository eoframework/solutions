# Deployment Automation

This folder contains deployment automation for the Dell Precision AI Workstation solution.

```
automation/
└── platform-native/     # Ansible-based Dell workstation automation
    └── ansible/
```

## Choosing an Approach

For Dell Precision AI Workstation infrastructure, **Ansible is the recommended automation tool** as it provides:

- First-party Dell Ansible collections (`dellemc.openmanage`)
- Native support for workstation and iDRAC configuration
- Idempotent configuration management
- Comprehensive OS, GPU driver, and ML stack automation
- Dell PowerScale NFS mount automation

## Quick Start

```bash
cd platform-native/ansible/

# 1. Install required collections
ansible-galaxy collection install -r requirements.yml

# 2. Configure inventory for your environment
vim inventory/production/hosts.yml

# 3. Run the deployment
./scripts/deploy.sh production
```

## Environment Support

Three environments are supported:
- **production** - Live AI workstation deployment, full 10-workstation configuration
- **test** - Lab environment for validation, reduced scale (2 workstations)
- **dr** - Not applicable for workstation infrastructure

## Documentation

| Document | Description |
|----------|-------------|
| [platform-native/ansible/README.md](platform-native/ansible/README.md) | Ansible deployment guide |
| [../raw/configuration.csv](../raw/configuration.csv) | Configuration parameters |
| [../raw/detailed-design.md](../raw/detailed-design.md) | Solution architecture |

## Configuration Source

All automation parameters are derived from `delivery/raw/configuration.csv`. Use the EO Framework configuration generator to update Ansible variables:

```bash
# Generate Ansible group_vars from configuration.csv
python /mnt/c/projects/wsl/eof-tools/automation/scripts/generate-ansible-vars.py \
    /path/to/configuration.csv \
    production
```

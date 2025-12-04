# Deployment Automation

This folder contains deployment automation for the Dell PowerSwitch Datacenter solution.

```
automation/
└── platform-native/     # Ansible-based Dell network automation
    └── ansible/
```

## Choosing an Approach

For Dell PowerSwitch network infrastructure, **Ansible is the recommended automation tool** as it provides:

- First-party Dell Ansible collections (`dellemc.os10`)
- Native support for network device configuration
- Idempotent configuration management
- Comprehensive switch automation capabilities

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
- **production** - Live datacenter fabric, full spine-leaf topology
- **test** - Lab environment for validation, reduced scale
- **dr** - Disaster recovery site, standby configuration

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

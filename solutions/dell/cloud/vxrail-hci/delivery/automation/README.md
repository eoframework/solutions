# Deployment Automation

This folder contains deployment automation for the Dell VxRail Hyperconverged Infrastructure solution.

```
automation/
└── platform-native/     # Ansible-based Dell VxRail automation
    └── ansible/
```

## Choosing an Approach

For Dell VxRail HCI infrastructure, **Ansible is the recommended automation tool** as it provides:

- First-party Dell Ansible collections (`dellemc.openmanage`)
- VMware automation capabilities (`community.vmware`)
- Native support for VxRail lifecycle management
- Idempotent configuration management
- Comprehensive hyperconverged infrastructure automation

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
- **production** - Live VxRail cluster, full production workload capacity
- **test** - Lab environment for validation, reduced node count
- **dr** - Disaster recovery site, standby cluster with replication

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

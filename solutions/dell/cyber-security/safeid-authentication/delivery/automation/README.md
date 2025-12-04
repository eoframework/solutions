# Deployment Automation

This folder contains deployment automation for the Dell SafeID Authentication solution.

```
automation/
└── platform-native/     # Ansible-based Dell SafeID automation
    └── ansible/
```

## Choosing an Approach

For Dell SafeID Enterprise Authentication, **Ansible is the recommended automation tool** as it provides:

- Comprehensive Linux server management
- API integration for SafeID appliance configuration
- LDAP, RADIUS, and SAML integration capabilities
- Idempotent configuration management
- Token provisioning and user enrollment automation

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
- **production** - Live authentication system for all users
- **test** - Lab environment for validation and testing
- **dr** - Disaster recovery site with standby configuration

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

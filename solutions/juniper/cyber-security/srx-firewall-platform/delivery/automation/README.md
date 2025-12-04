# SRX Firewall Platform - Deployment Automation

Infrastructure automation for Juniper SRX Firewall Platform deployment using Ansible and PyEZ.

## Architecture

```
automation/
├── ansible/                  # Ansible automation
│   ├── inventory/            # Environment inventories
│   │   ├── prod/
│   │   ├── test/
│   │   └── dr/
│   ├── playbooks/            # Deployment playbooks
│   ├── roles/                # Reusable roles
│   ├── vars/                 # Variables
│   └── templates/            # Jinja2 templates
├── scripts/                  # Helper scripts
│   ├── python/               # PyEZ automation
│   └── bash/                 # Shell utilities
└── config/                   # Environment configurations
```

## Prerequisites

### System Requirements

- Python 3.9+
- Ansible 2.15+
- Network connectivity to SRX devices (SSH/NETCONF)

### Python Dependencies

```bash
pip install -r scripts/python/requirements.txt
```

### Ansible Collections

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## Quick Start

### 1. Configure Inventory

Edit the inventory for your environment:

```bash
vim ansible/inventory/prod/hosts.yml
```

### 2. Set Variables

Configure device-specific variables:

```bash
vim ansible/inventory/prod/group_vars/all.yml
```

### 3. Encrypt Secrets

Create Ansible Vault for sensitive data:

```bash
ansible-vault create ansible/vars/secrets.yml
```

### 4. Run Deployment

```bash
# Syntax check
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml --syntax-check

# Dry run
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml --check

# Deploy
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml
```

## Playbooks

| Playbook | Description |
|----------|-------------|
| `site.yml` | Complete SRX deployment (all roles) |
| `srx-deploy.yml` | Initial firewall configuration |
| `cluster-setup.yml` | Chassis cluster configuration |
| `security-policies.yml` | Security zone and policy deployment |
| `backup.yml` | Configuration backup |
| `validate.yml` | Post-deployment validation |

## Roles

| Role | Description |
|------|-------------|
| `junos-base` | Base configuration (hostname, NTP, DNS, users) |
| `junos-security` | Security zones, policies, NAT rules |
| `junos-routing` | Static routes, BGP, OSPF configuration |
| `junos-vpn` | IPSec VPN tunnel configuration |

## Environment-Specific Deployment

### Production

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml
```

### Test

```bash
ansible-playbook -i ansible/inventory/test ansible/playbooks/site.yml
```

### Disaster Recovery

```bash
ansible-playbook -i ansible/inventory/dr ansible/playbooks/site.yml
```

## Configuration Source

All configuration values are derived from:
- `delivery/raw/configuration.csv` - Master configuration
- `delivery/configuration.xlsx` - Excel version

Generate Ansible variables from configuration.csv:

```bash
python scripts/python/generate_ansible_vars.py prod
```

## Troubleshooting

### Test Connectivity

```bash
ansible -i ansible/inventory/prod srx_firewalls -m ping
```

### Check NETCONF

```bash
ansible -i ansible/inventory/prod srx_firewalls -m junipernetworks.junos.junos_facts
```

### Verbose Output

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml -vvv
```

## Security Notes

- Store all secrets in Ansible Vault
- Use NETCONF over SSH (port 830)
- Enable RBAC on SRX devices
- Rotate credentials quarterly

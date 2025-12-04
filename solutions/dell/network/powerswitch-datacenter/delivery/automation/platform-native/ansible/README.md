# Dell PowerSwitch Datacenter - Ansible Automation

Ansible-based automation for deploying and configuring Dell PowerSwitch datacenter network fabric.

## Overview

This automation deploys a spine-leaf datacenter fabric using Dell PowerSwitch S5200-series switches with OS10 Enterprise. The solution supports BGP underlay, EVPN/VXLAN overlay, and comprehensive monitoring integration.

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Ansible | >= 2.14 | Automation engine |
| Python | >= 3.9 | Ansible runtime |
| Dell OS10 Collection | >= 1.1.0 | Switch automation |

### Network Access

- SSH access to all PowerSwitch management IPs
- TACACS+ or local credentials configured
- Management VLAN connectivity from Ansible control node

### Dell Collections

Install required Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

## Directory Structure

```
ansible/
├── ansible.cfg                    # Ansible configuration
├── requirements.yml               # Galaxy dependencies
├── inventory/
│   ├── production/
│   │   ├── hosts.yml              # Production switch inventory
│   │   └── group_vars/
│   │       ├── all.yml            # Common variables
│   │       ├── spine_switches.yml # Spine-specific vars
│   │       └── leaf_switches.yml  # Leaf-specific vars
│   ├── test/
│   │   ├── hosts.yml
│   │   └── group_vars/
│   │       └── all.yml
│   └── dr/
│       ├── hosts.yml
│       └── group_vars/
│           └── all.yml
├── playbooks/
│   ├── site.yml                   # Master playbook
│   ├── fabric-deploy.yml          # Full fabric deployment
│   ├── spine-config.yml           # Spine configuration
│   ├── leaf-config.yml            # Leaf configuration
│   ├── bgp-config.yml             # BGP underlay setup
│   ├── vxlan-config.yml           # VXLAN overlay (optional)
│   ├── monitoring-config.yml      # SNMP/syslog setup
│   └── validate.yml               # Post-deployment validation
├── roles/
│   ├── os10-base/                 # Base switch configuration
│   ├── os10-interfaces/           # Interface configuration
│   ├── os10-vlans/                # VLAN configuration
│   ├── os10-bgp/                  # BGP routing
│   ├── os10-vxlan/                # VXLAN overlay
│   └── os10-monitoring/           # Monitoring setup
├── vars/
│   ├── common.yml                 # Shared variables
│   └── secrets.yml                # Vault-encrypted secrets
├── templates/
│   └── deployment_report.j2       # Report template
└── scripts/
    ├── deploy.sh                  # Deployment wrapper
    ├── validate.sh                # Validation script
    └── backup.sh                  # Configuration backup
```

## Quick Start

### 1. Install Dependencies

```bash
# Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# Verify installation
ansible-galaxy collection list | grep dellemc
```

### 2. Configure Inventory

Edit the inventory file for your environment:

```bash
vim inventory/production/hosts.yml
```

Update switch hostnames and management IPs:

```yaml
all:
  children:
    spine_switches:
      hosts:
        spine-01:
          ansible_host: 10.10.0.1
        spine-02:
          ansible_host: 10.10.0.2
    leaf_switches:
      hosts:
        leaf-01:
          ansible_host: 10.10.0.11
        # ... additional leaves
```

### 3. Configure Variables

Edit group variables to match your design:

```bash
vim inventory/production/group_vars/all.yml
```

### 4. Set Up Vault Secrets

Create encrypted secrets file:

```bash
ansible-vault create vars/secrets.yml
```

Add credentials:

```yaml
tacacs_secret: "your-tacacs-secret"
snmp_community: "your-snmp-community"
```

### 5. Deploy

```bash
# Full fabric deployment
./scripts/deploy.sh production

# Or run specific playbooks
ansible-playbook -i inventory/production playbooks/spine-config.yml
ansible-playbook -i inventory/production playbooks/leaf-config.yml
```

## Playbook Reference

| Playbook | Description | Tags |
|----------|-------------|------|
| `site.yml` | Master orchestration - runs all playbooks | all |
| `fabric-deploy.yml` | Complete fabric deployment | fabric |
| `spine-config.yml` | Spine switch configuration | spine |
| `leaf-config.yml` | Leaf switch configuration | leaf |
| `bgp-config.yml` | BGP underlay routing | bgp |
| `vxlan-config.yml` | VXLAN overlay (if enabled) | vxlan |
| `monitoring-config.yml` | SNMP, syslog, NTP | monitoring |
| `validate.yml` | Post-deployment validation | validate |

### Running with Tags

```bash
# Deploy only BGP configuration
ansible-playbook -i inventory/production playbooks/site.yml --tags bgp

# Skip VXLAN configuration
ansible-playbook -i inventory/production playbooks/site.yml --skip-tags vxlan
```

## Role Reference

### os10-base

Base switch configuration including:
- Hostname and management settings
- User accounts and authentication
- NTP configuration
- Console and VTY settings

### os10-interfaces

Interface configuration including:
- Physical interface settings
- Port-channel/LAG configuration
- Interface descriptions
- Speed/duplex settings

### os10-vlans

VLAN configuration including:
- VLAN creation and naming
- SVI (interface VLAN) configuration
- Trunk/access port assignment
- VLAN tagging

### os10-bgp

BGP underlay routing including:
- BGP ASN configuration
- Neighbor relationships
- Address family configuration
- Route redistribution

### os10-vxlan

VXLAN overlay (when enabled):
- EVPN control plane
- VNI to VLAN mapping
- VTEP configuration
- Anycast gateway

### os10-monitoring

Monitoring integration:
- SNMPv3 configuration
- Syslog servers
- OpenManage Enterprise integration
- Dell SupportAssist

## Validation

Run post-deployment validation:

```bash
./scripts/validate.sh production
```

Validation checks:
- BGP neighbor adjacencies
- VXLAN tunnel status (if enabled)
- VLAN presence across fabric
- Interface operational status
- NTP synchronization
- SNMP reachability

## Backup and Recovery

### Configuration Backup

```bash
# Backup all switch configurations
./scripts/backup.sh production
```

Backups are stored in `backups/YYYYMMDD_HHMMSS/`

### Configuration Recovery

```bash
# Restore from backup
ansible-playbook -i inventory/production playbooks/restore.yml \
  -e "backup_dir=backups/20250101_120000"
```

## Troubleshooting

### Connection Issues

```bash
# Test SSH connectivity
ansible -i inventory/production all -m ping

# Verbose output
ansible-playbook -i inventory/production playbooks/validate.yml -vvv
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `SSH connection timeout` | Network/firewall issue | Verify management VLAN routing |
| `Authentication failed` | Wrong credentials | Check vault secrets |
| `Module not found` | Missing collection | Run `ansible-galaxy collection install` |

## Support

- Dell OS10 documentation: https://www.dell.com/support
- Dell Ansible collection: https://galaxy.ansible.com/dellemc/os10
- EO Framework: Contact Dell Solutions Team

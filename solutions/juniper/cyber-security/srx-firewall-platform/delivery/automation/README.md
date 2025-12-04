# SRX Firewall Platform - Deployment Automation

Infrastructure automation for Juniper SRX Firewall Platform deployment using Ansible and NETCONF.

## Architecture

```
delivery/automation/
├── README.md                       # This file
└── ansible/                        # Ansible automation
    ├── ansible.cfg                 # Ansible configuration
    ├── requirements.yml            # Ansible collections
    ├── inventory/                  # Environment inventories
    │   ├── prod/
    │   │   ├── hosts.yml
    │   │   └── group_vars/
    │   │       └── all.yml        # Production variables
    │   ├── test/
    │   │   ├── hosts.yml
    │   │   └── group_vars/
    │   │       └── all.yml        # Test variables
    │   └── dr/
    │       ├── hosts.yml
    │       └── group_vars/
    │           └── all.yml        # DR variables
    ├── playbooks/                  # Deployment playbooks
    │   ├── site.yml               # Master orchestration
    │   ├── srx-deploy.yml         # Initial deployment
    │   ├── cluster-setup.yml      # Chassis cluster
    │   ├── security-policies.yml  # Security configuration
    │   ├── backup.yml             # Configuration backup
    │   └── validate.yml           # Validation
    ├── roles/                      # Reusable roles
    │   ├── junos-base/            # Base configuration
    │   ├── junos-security/        # Security zones/policies
    │   ├── junos-routing/         # Routing configuration
    │   └── junos-vpn/             # VPN configuration
    ├── templates/                  # Jinja2 templates
    │   └── security-policies.j2
    └── vars/                       # Variables
        ├── common.yml             # Common variables
        ├── security_policies.yml  # Policy definitions
        ├── secrets.yml.example    # Secrets template
        └── generated/             # Auto-generated vars
```

## Prerequisites

### System Requirements

- Python 3.9+
- Ansible 2.15+
- Network connectivity to SRX devices (SSH/NETCONF port 830)

### Python Dependencies

```bash
pip install ansible netaddr jmespath junos-eznc
```

### Ansible Collections

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

Required collections:
- `junipernetworks.junos` - Junos device automation
- `juniper.device` - PyEZ-based operations

## Configuration Source

All configuration values are derived from:
- `delivery/raw/configuration.csv` - Master configuration (single source of truth)
- `delivery/configuration.xlsx` - Excel version for documentation

### Regenerate Variables from Configuration

```bash
# From eof-tools directory
python automation/scripts/generate-ansible-vars.py /path/to/solutions/juniper/cyber-security/srx-firewall-platform
```

This generates:
- `vars/generated/*.yml` - Category-grouped variables
- `vars/secrets.yml.template` - Vault secrets template

## Quick Start

### 1. Install Dependencies

```bash
# Python packages
pip install ansible netaddr jmespath junos-eznc

# Ansible collections
cd ansible
ansible-galaxy collection install -r requirements.yml
```

### 2. Configure Inventory

Edit the inventory for your environment:

```bash
vim ansible/inventory/prod/hosts.yml
```

Example inventory:
```yaml
all:
  children:
    srx_firewalls:
      hosts:
        srx-prod-fw01:
          ansible_host: 10.0.0.1
        srx-prod-fw02:
          ansible_host: 10.0.0.2
      vars:
        ansible_network_os: junipernetworks.junos.junos
        ansible_connection: netconf
        ansible_netconf_ssh_port: 830
```

### 3. Set Up Secrets

```bash
# Copy secrets template
cp ansible/vars/secrets.yml.example ansible/vars/secrets.yml

# Edit and add actual credentials
vim ansible/vars/secrets.yml

# Encrypt with Ansible Vault
ansible-vault encrypt ansible/vars/secrets.yml
```

### 4. Run Deployment

```bash
cd ansible

# Syntax check
ansible-playbook -i inventory/prod playbooks/site.yml --syntax-check

# Dry run (check mode)
ansible-playbook -i inventory/prod playbooks/site.yml --check --diff

# Deploy
ansible-playbook -i inventory/prod playbooks/site.yml --ask-vault-pass
```

## Playbooks

| Playbook | Description |
|----------|-------------|
| `site.yml` | Complete SRX deployment (all roles in sequence) |
| `srx-deploy.yml` | Initial firewall configuration |
| `cluster-setup.yml` | Chassis cluster (HA) configuration |
| `security-policies.yml` | Security zone and policy deployment |
| `backup.yml` | Configuration backup to remote server |
| `validate.yml` | Post-deployment validation checks |

## Roles

| Role | Description |
|------|-------------|
| `junos-base` | Base configuration: hostname, NTP, DNS, syslog, users |
| `junos-security` | Security zones, policies, NAT, screens, UTM, IPS |
| `junos-routing` | Static routes, BGP, OSPF configuration |
| `junos-vpn` | IPSec VPN: IKE, IPSec proposals, tunnels |

### Role Tags

```bash
# Run only specific roles
ansible-playbook -i inventory/prod playbooks/site.yml --tags "base,security"

# Skip specific roles
ansible-playbook -i inventory/prod playbooks/site.yml --skip-tags "vpn"
```

## Environment-Specific Deployment

### Production

```bash
ansible-playbook -i inventory/prod playbooks/site.yml --ask-vault-pass
```

Features enabled:
- Chassis cluster (HA)
- IPS, ATP Cloud, SecIntel
- TACACS+ authentication
- Full monitoring and backup

### Test

```bash
ansible-playbook -i inventory/test playbooks/site.yml --ask-vault-pass
```

Features:
- Standalone (no cluster)
- IPS only (no ATP/SecIntel)
- Local authentication
- Reduced logging

### Disaster Recovery

```bash
ansible-playbook -i inventory/dr playbooks/site.yml --ask-vault-pass
```

Features:
- Chassis cluster (HA)
- Full security services (mirrors production)
- DR-specific syslog and TACACS servers

## Validation

### Test Connectivity

```bash
# Ping test
ansible -i inventory/prod srx_firewalls -m ping

# Gather facts
ansible -i inventory/prod srx_firewalls -m junipernetworks.junos.junos_facts
```

### Run Validation Playbook

```bash
ansible-playbook -i inventory/prod playbooks/validate.yml
```

Checks:
- Cluster status and sync
- Security zone configuration
- Policy hit counters
- VPN tunnel status
- Interface status

## Backup and Restore

### Create Backup

```bash
ansible-playbook -i inventory/prod playbooks/backup.yml
```

### Restore Configuration

```bash
ansible-playbook -i inventory/prod playbooks/srx-deploy.yml -e "restore_config=true restore_file=/path/to/backup.conf"
```

## Troubleshooting

### Verbose Output

```bash
ansible-playbook -i inventory/prod playbooks/site.yml -vvv
```

### Check NETCONF Connectivity

```bash
ssh -p 830 admin@10.0.0.1 -s netconf
```

### Debug Mode

```bash
ANSIBLE_DEBUG=1 ansible-playbook -i inventory/prod playbooks/site.yml
```

### Common Issues

| Issue | Solution |
|-------|----------|
| NETCONF connection refused | Verify `set system services netconf ssh` on device |
| Authentication failure | Check credentials in secrets.yml |
| Commit failed | Review junos_config error, check rescue config |
| Cluster not forming | Verify fabric link, check cluster IDs |

## Security Best Practices

- Store all secrets in Ansible Vault (never plain text)
- Use NETCONF over SSH (port 830, encrypted)
- Enable RBAC on SRX devices for automation user
- Rotate credentials per security policy
- Use dedicated automation service account
- Review commit logs for audit trail

## Integration Points

| Integration | Description |
|-------------|-------------|
| SIEM | Syslog forwarding to security monitoring |
| TACACS+ | Centralized authentication |
| Security Director | Centralized policy management |
| SNMP | Network monitoring |
| Backup Server | Configuration backup via SCP |

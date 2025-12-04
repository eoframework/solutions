# Mist AI Network - Deployment Automation

Infrastructure automation for Juniper Mist AI Network deployment using Ansible and Mist Cloud API.

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
    │   ├── mist-site-setup.yml    # Site and WLAN configuration
    │   ├── switch-config.yml      # EX switch configuration
    │   └── validate.yml           # Post-deployment validation
    ├── roles/                      # Reusable roles
    │   ├── mist-org/              # Organization settings
    │   ├── mist-site/             # Site creation
    │   ├── mist-wlan/             # WLAN configuration
    │   └── mist-switch/           # Switch templates
    └── vars/                       # Variables
        ├── common.yml             # Common variables
        ├── secrets.yml.example    # Secrets template
        └── generated/             # Auto-generated vars
```

## Prerequisites

### System Requirements

- Python 3.9+
- Ansible 2.15+
- Mist Cloud API access
- Network connectivity to EX switches (SSH/NETCONF port 830)

### Python Dependencies

```bash
pip install ansible requests junos-eznc mistapi
```

### Ansible Collections

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

Required collections:
- `junipernetworks.junos` - Junos device automation
- Community modules for REST API operations

## Configuration Source

All configuration values are derived from:
- `delivery/raw/configuration.csv` - Master configuration (single source of truth)
- `delivery/configuration.xlsx` - Excel version for documentation

### Regenerate Variables from Configuration

```bash
# From eof-tools directory
python automation/scripts/generate-ansible-vars.py /path/to/solutions/juniper/network/mist-ai-network
```

This generates:
- `vars/generated/*.yml` - Category-grouped variables
- `vars/secrets.yml.template` - Vault secrets template

## Quick Start

### 1. Obtain Mist API Token

1. Login to https://manage.mist.com
2. Navigate to Organization > Settings > API Token
3. Create new token with appropriate permissions:
   - Sites: Read/Write
   - WLANs: Read/Write
   - Switches: Read/Write (if managing EX switches)
   - Location: Read/Write (if using location services)

### 2. Configure Inventory

Edit the inventory for your environment:

```bash
vim ansible/inventory/prod/hosts.yml
```

Example inventory:
```yaml
all:
  children:
    mist_managed:
      hosts:
        localhost:
          ansible_connection: local
    ex_switches:
      hosts:
        ex4400-1:
          ansible_host: 10.10.100.2
        ex4400-2:
          ansible_host: 10.10.100.3
      vars:
        ansible_network_os: junipernetworks.junos.junos
        ansible_connection: netconf
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

Required secrets:
```yaml
mist_api_token: "your-mist-api-token"
mist_org_id: "your-org-uuid"
radius_secret: "your-radius-shared-secret"
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
| `site.yml` | Complete Mist deployment (all roles) |
| `mist-site-setup.yml` | Site creation and WLAN configuration |
| `switch-config.yml` | EX switch template and port profiles |
| `validate.yml` | Post-deployment validation checks |

## Roles

| Role | Description |
|------|-------------|
| `mist-org` | Organization-level settings: RF templates, network templates |
| `mist-site` | Site creation: address, GPS, timezone, template assignment |
| `mist-wlan` | WLAN configuration: SSIDs, authentication, VLANs |
| `mist-switch` | Switch templates: port profiles, VLANs, PoE |

### Role Tags

```bash
# Deploy only WLANs
ansible-playbook -i inventory/prod playbooks/site.yml --tags "wlans"

# Deploy only switches
ansible-playbook -i inventory/prod playbooks/site.yml --tags "switches"

# Skip location services
ansible-playbook -i inventory/prod playbooks/site.yml --skip-tags "location"
```

## Environment-Specific Deployment

### Production

```bash
ansible-playbook -i inventory/prod playbooks/site.yml --ask-vault-pass
```

Features enabled:
- Full WLAN suite (corporate, guest, IoT)
- 802.1X RADIUS authentication
- WiFi 6E (6 GHz band)
- Location services with vBLE
- Marvis AI with automated actions

### Test

```bash
ansible-playbook -i inventory/test playbooks/site.yml --ask-vault-pass
```

Features:
- Corporate and guest WLANs only
- PSK authentication (no RADIUS)
- Reduced RF power
- No location services
- Marvis recommendations only

### Disaster Recovery

```bash
ansible-playbook -i inventory/dr playbooks/site.yml --ask-vault-pass
```

Features:
- Full WLAN suite (mirrors production)
- Full security features
- Location services enabled
- Different timezone (Los Angeles)

## Validation

### Test Mist API Connectivity

```bash
# Using Python client
curl -H "Authorization: Token <your-api-token>" \
     https://api.mist.com/api/v1/self
```

### Run Validation Playbook

```bash
ansible-playbook -i inventory/prod playbooks/validate.yml
```

Checks:
- Site status and AP count
- WLAN broadcast status
- SLE metric collection
- Switch adoption status
- RADIUS server connectivity

## Mist Cloud Operations

### Site Management

```bash
# Get all sites
curl -H "Authorization: Token <token>" \
     "https://api.mist.com/api/v1/orgs/<org_id>/sites"

# Get site devices
curl -H "Authorization: Token <token>" \
     "https://api.mist.com/api/v1/sites/<site_id>/devices"
```

### WLAN Management

```bash
# Get WLANs
curl -H "Authorization: Token <token>" \
     "https://api.mist.com/api/v1/sites/<site_id>/wlans"
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| API 401 Unauthorized | Check API token is valid and has required permissions |
| Site not found | Verify org_id and site name in variables |
| RADIUS auth fails | Check RADIUS secret, server IPs, firewall rules |
| APs not adopting | Verify DHCP Option 43 or DNS _mist._tcp SRV record |

### Debug Mode

```bash
ANSIBLE_DEBUG=1 ansible-playbook -i inventory/prod playbooks/site.yml -vvv
```

### Check Mist Cloud Logs

1. Login to https://manage.mist.com
2. Navigate to site > Insights > Events
3. Filter by event type for specific issues

## Security Best Practices

- Store API tokens in Ansible Vault (never plain text)
- Use organization-level tokens with minimum required permissions
- Rotate API tokens per security policy
- Use WPA3-Enterprise for corporate WLANs
- Enable RADIUS CoA for dynamic policy enforcement
- Monitor API usage in Mist Cloud portal

## Integration Points

| Integration | Description |
|-------------|-------------|
| Mist Cloud | API-based configuration management |
| RADIUS/ISE | 802.1X authentication |
| Webhook | Event notifications to ITSM/SIEM |
| Syslog | Log forwarding to SIEM |
| Marvis AI | Automated troubleshooting |

## API Reference

- Mist API Documentation: https://api.mist.com/api/v1/docs
- Python SDK (mistapi): https://github.com/tmunzer/mistapi
- Mist APIs GitHub: https://github.com/Mist-Automation-Programmability

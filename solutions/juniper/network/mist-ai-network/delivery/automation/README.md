# Mist AI Network - Deployment Automation

Infrastructure automation for Juniper Mist AI Network deployment using Ansible and Mist Cloud API.

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
│   ├── python/               # Mist API client
│   └── bash/                 # Shell utilities
└── config/                   # Environment configurations
```

## Prerequisites

### System Requirements

- Python 3.9+
- Ansible 2.15+
- Mist Cloud API access
- Network connectivity to EX switches (SSH/NETCONF)

### Python Dependencies

```bash
pip install -r scripts/python/requirements.txt
```

### Ansible Collections

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## Quick Start

### 1. Configure Mist API Token

Obtain API token from Mist Cloud portal:
1. Login to https://manage.mist.com
2. Go to Organization > Settings > API Token
3. Create new token with appropriate permissions

### 2. Set Variables

Configure your environment:

```bash
vim ansible/inventory/prod/group_vars/all.yml
```

### 3. Encrypt Secrets

```bash
ansible-vault create ansible/vars/secrets.yml
```

Add:
```yaml
mist_api_token: "your-token-here"
```

### 4. Run Deployment

```bash
# Deploy site configuration
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml

# Deploy WLANs only
ansible-playbook -i ansible/inventory/prod ansible/playbooks/mist-site-setup.yml --tags wlans
```

## Playbooks

| Playbook | Description |
|----------|-------------|
| `site.yml` | Complete Mist deployment |
| `mist-site-setup.yml` | Site and WLAN configuration |
| `switch-config.yml` | EX switch configuration |
| `validate.yml` | Post-deployment validation |

## Roles

| Role | Description |
|------|-------------|
| `mist-org` | Organization-level settings |
| `mist-site` | Site creation and configuration |
| `mist-wlan` | WLAN and RF profile configuration |
| `mist-switch` | EX switch template configuration |

## Environment-Specific Deployment

### Production

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml
```

### Test

```bash
ansible-playbook -i ansible/inventory/test ansible/playbooks/site.yml
```

## Configuration Source

All configuration values are derived from:
- `delivery/raw/configuration.csv` - Master configuration
- `delivery/configuration.xlsx` - Excel version

## Mist API Reference

- API Documentation: https://api.mist.com/api/v1/docs
- Python SDK: https://github.com/tmunzer/mistapi

## Troubleshooting

### Test API Connectivity

```bash
python scripts/python/mist_client.py --action test
```

### Check Site Status

```bash
python scripts/python/mist_client.py --action sites
```

## Security Notes

- Store API tokens in Ansible Vault
- Use organization-level tokens with minimum required permissions
- Rotate API tokens quarterly
- Monitor API usage in Mist Cloud portal

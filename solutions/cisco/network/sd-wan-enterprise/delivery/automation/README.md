# SD-WAN Enterprise - Deployment Automation

Infrastructure automation for Cisco SD-WAN Enterprise deployment using Ansible and vManage REST API.

## Architecture

```
automation/
├── ansible/                  # Ansible automation
│   ├── inventory/            # Environment inventories
│   │   ├── prod/             # Production environment
│   │   │   ├── hosts.yml
│   │   │   └── group_vars/all.yml
│   │   ├── test/             # Test environment
│   │   │   ├── hosts.yml
│   │   │   └── group_vars/all.yml
│   │   └── dr/               # DR environment
│   │       ├── hosts.yml
│   │       └── group_vars/all.yml
│   ├── playbooks/            # Deployment playbooks
│   │   ├── site.yml          # Master playbook
│   │   ├── controllers-deploy.yml
│   │   ├── edge-provision.yml
│   │   ├── templates-deploy.yml
│   │   ├── policies-deploy.yml
│   │   └── monitoring-setup.yml
│   ├── roles/                # Reusable roles
│   │   ├── sdwan-auth/       # vManage API authentication
│   │   ├── sdwan-controllers/ # Controller setup
│   │   ├── sdwan-templates/  # Device templates
│   │   ├── sdwan-policies/   # Policy configuration
│   │   ├── sdwan-edge/       # Edge device onboarding
│   │   └── sdwan-validation/ # Pre/post validation
│   ├── vars/                 # Variables
│   │   ├── common.yml
│   │   └── secrets.yml
│   ├── templates/            # Jinja2 templates
│   ├── ansible.cfg           # Ansible configuration
│   └── requirements.yml      # Ansible collections
├── scripts/                  # Helper scripts
│   ├── python/               # Python automation
│   │   ├── vmanage_client.py # vManage REST API wrapper
│   │   └── requirements.txt
│   └── bash/                 # Shell utilities
│       └── health-check.sh
└── config/                   # Environment configurations
    ├── prod/
    │   └── site-definitions.yml
    ├── test/
    │   └── site-definitions.yml
    └── dr/
        └── site-definitions.yml
```

## Prerequisites

### System Requirements

- Python 3.9+
- Ansible 2.15+
- Network connectivity to vManage, vSmart, vBond (HTTPS/SSH)
- Network connectivity to vEdge devices (SSH/NETCONF)

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

Add vManage credentials:
```yaml
vault_vmanage_username: admin
vault_vmanage_password: your-secure-password
vault_vsmart_omp_key: your-omp-key
vault_snmp_community: your-snmp-community
```

### 4. Run Deployment

```bash
# Syntax check
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml --syntax-check

# Dry run
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml --check

# Deploy
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml --ask-vault-pass
```

## Playbooks

| Playbook | Description |
|----------|-------------|
| `site.yml` | Complete SD-WAN deployment (all roles) |
| `controllers-deploy.yml` | Deploy vManage, vSmart, vBond controllers |
| `edge-provision.yml` | Provision edge devices (cEdge/vEdge) |
| `templates-deploy.yml` | Deploy device and feature templates |
| `policies-deploy.yml` | Deploy security and routing policies |
| `monitoring-setup.yml` | Configure monitoring and alerting |

## Roles

| Role | Description |
|------|-------------|
| `sdwan-auth` | vManage API authentication and session management |
| `sdwan-controllers` | vManage, vSmart, vBond controller configuration |
| `sdwan-templates` | Device templates and feature templates |
| `sdwan-policies` | Security policies, routing policies, QoS |
| `sdwan-edge` | Edge device onboarding and provisioning |
| `sdwan-validation` | Pre-deployment and post-deployment validation |

## Environment-Specific Deployment

### Production

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml --ask-vault-pass
```

### Test

```bash
ansible-playbook -i ansible/inventory/test ansible/playbooks/site.yml --ask-vault-pass
```

### Disaster Recovery

```bash
ansible-playbook -i ansible/inventory/dr ansible/playbooks/site.yml --ask-vault-pass
```

## Specific Deployment Tasks

### Deploy Controllers Only

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/controllers-deploy.yml --ask-vault-pass
```

### Provision Edge Devices

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/edge-provision.yml --ask-vault-pass
```

### Deploy Policies

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/policies-deploy.yml --ask-vault-pass
```

## Configuration Source

All configuration values are derived from:
- `delivery/raw/configuration.csv` - Master configuration
- `delivery/configuration.xlsx` - Excel version

The CSV contains environment-specific columns:
- **Production** - Full 25-site deployment with HA
- **Test** - 3-site pilot with reduced features
- **DR** - 5-site DR deployment

## vManage REST API

The Python vManage client provides REST API wrapper:

```python
from scripts.python.vmanage_client import VManageClient

# Initialize client
vmanage = VManageClient(
    host='10.100.1.10',
    username='vmanage-admin',
    password='your-password'
)

# Authenticate
vmanage.authenticate()

# Get device list
devices = vmanage.get_devices()

# Deploy template
vmanage.attach_device_template(
    template_id='template-123',
    device_id='device-456'
)
```

## Health Check

Run health check script to verify SD-WAN deployment:

```bash
bash scripts/bash/health-check.sh prod
```

The script checks:
- vManage reachability and API status
- vSmart control connections
- vBond orchestrator status
- vEdge device reachability
- OMP peer relationships
- BFD sessions
- Policy deployment status

## Troubleshooting

### Test vManage Connectivity

```bash
ansible -i ansible/inventory/prod vmanage -m ping
```

### Check vManage API

```bash
curl -k -u admin:password https://10.100.1.10/dataservice/client/server
```

### Test vEdge Connectivity

```bash
ansible -i ansible/inventory/prod vedge -m cisco.ios.ios_command -a "commands='show control connections'"
```

### Verbose Output

```bash
ansible-playbook -i ansible/inventory/prod ansible/playbooks/site.yml -vvv --ask-vault-pass
```

### View Ansible Logs

```bash
tail -f ansible/ansible.log
```

## Zero-Touch Provisioning (ZTP)

SD-WAN supports zero-touch provisioning for edge devices:

1. **Device Registration**: Register device serial numbers in vManage
2. **Certificate Generation**: Generate device certificates via vManage
3. **Configuration Templates**: Create device templates in vManage
4. **Physical Installation**: Connect device to network with Internet access
5. **Automatic Onboarding**: Device contacts vBond, downloads config, joins fabric

ZTP workflow automated in `sdwan-edge` role.

## Application-Aware Routing

SD-WAN provides application-aware routing with SLA policies:

- **Business Critical Apps**: Office 365, Salesforce, Webex (high priority)
- **Voice Traffic**: VoIP applications (strict SLA, low latency)
- **Video Traffic**: Video conferencing (medium priority)
- **Best Effort**: General internet traffic (low priority)

Application policies configured in `sdwan-policies` role.

## Security Features

- **IPSec Encryption**: All SD-WAN tunnels encrypted with AES-256
- **Zone-Based Firewall**: Security zones on edge devices
- **IPS/IDS**: Intrusion prevention on security license
- **URL Filtering**: Web security and content filtering
- **AMP**: Advanced Malware Protection

Security policies configured in `sdwan-policies` role.

## Monitoring and Analytics

- **vManage Dashboard**: Real-time network visibility
- **NetFlow Export**: Traffic analytics to NetFlow collector
- **Syslog**: Centralized logging to syslog server
- **SNMP**: Device monitoring via SNMP v3
- **SLA Monitoring**: Application SLA compliance tracking

Monitoring configured in `monitoring-setup` playbook.

## Circuit Failover

SD-WAN provides automatic circuit failover:

- **Primary**: Business Internet (100 Mbps)
- **Secondary**: MPLS (50 Mbps)
- **Backup**: LTE (25 Mbps)

Failover time: < 1 second with BFD detection

## Best Practices

1. **Always use Ansible Vault** for sensitive data
2. **Test in test environment** before production deployment
3. **Run syntax check** before executing playbooks
4. **Use --check mode** for dry runs
5. **Review logs** in ansible.log for troubleshooting
6. **Backup configurations** before making changes
7. **Validate deployment** with validation playbook
8. **Document changes** in configuration management

## Support

### Cisco TAC Support

- SmartNet Contract: See SUPPORT_SMARTNET_CONTRACT in configuration.csv
- Default Severity: 2 (Production down)
- Escalation: SUPPORT_ESCALATION_CONTACT in configuration.csv

### Internal Support

- Network Team: OWNER_EMAIL in configuration.csv
- NOC Alerts: NOTIFICATIONS_ALERT_EMAIL in configuration.csv

## Security Notes

- Store all secrets in Ansible Vault
- Use HTTPS for vManage API (port 443)
- Use SSH for device access (port 22)
- Enable RBAC on vManage
- Rotate credentials quarterly
- Audit access logs monthly

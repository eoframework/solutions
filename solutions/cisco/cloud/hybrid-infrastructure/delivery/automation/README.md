# Cisco HyperFlex Hybrid Infrastructure - Automation

This directory contains automation scripts and configuration for deploying and managing Cisco HyperFlex hyperconverged infrastructure using platform-native tools.

## Overview

The automation framework uses:
- **Cisco Intersight REST API** - Cloud-based infrastructure management and orchestration
- **cisco.intersight Ansible collection** - HyperFlex cluster deployment and configuration
- **cisco.ucs Ansible collection** - Fabric Interconnect and UCS domain management
- **community.vmware Ansible collection** - vSphere and ESXi integration
- **Python scripts** - Custom Intersight API clients and helper utilities

## Directory Structure

```
automation/
├── README.md                           # This file
└── platform-native/
    ├── ansible/                        # Ansible automation
    │   ├── ansible.cfg                 # Ansible configuration
    │   ├── requirements.yml            # Galaxy collection dependencies
    │   ├── inventory/                  # Environment-specific inventories
    │   │   ├── prod/hosts.yml         # Production environment
    │   │   ├── test/hosts.yml         # Test environment
    │   │   └── dr/hosts.yml           # DR environment
    │   ├── playbooks/                  # Deployment playbooks
    │   │   ├── site.yml               # Master orchestration
    │   │   ├── 01-foundation.yml      # Fabric Interconnects, VLANs
    │   │   ├── 02-cluster.yml         # HyperFlex cluster deployment
    │   │   ├── 03-storage.yml         # Datastores, storage policies
    │   │   ├── 04-integration.yml     # Intersight, vSphere, backup
    │   │   ├── 05-validation.yml      # Health checks, validation
    │   │   └── rollback.yml           # Emergency rollback
    │   ├── roles/                      # Custom Ansible roles (future)
    │   ├── vars/                       # Variable files
    │   │   ├── generated/             # Auto-generated from configuration.csv
    │   │   ├── secrets.yml.template   # Template for secrets
    │   │   └── secrets.yml            # Ansible Vault encrypted (gitignored)
    │   └── logs/                       # Execution logs
    └── scripts/
        └── python/                     # Python helper scripts
            ├── intersight_client.py   # Intersight API client
            ├── requirements.txt       # Python dependencies
            └── README.md              # Python scripts documentation
```

## Prerequisites

### Software Requirements
- Python 3.9+
- Ansible 2.14+
- pip package manager

### Cisco Requirements
- Cisco Intersight account with API access
- Cisco SmartNet support contract
- HyperFlex hardware (nodes and Fabric Interconnects)
- VMware vSphere 8.x licenses

### Network Requirements
- Network connectivity to Intersight cloud (https://intersight.com)
- Management network access to HyperFlex cluster
- Access to Fabric Interconnect management interfaces
- vCenter Server network connectivity

## Quick Start

### 1. Install Dependencies

```bash
cd automation/platform-native/ansible

# Create Python virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate

# Install Ansible
pip install ansible

# Install Ansible Galaxy collections
ansible-galaxy install -r requirements.yml

# Install Python dependencies for helper scripts
pip install -r ../scripts/python/requirements.txt
```

### 2. Configure Variables

Variables are auto-generated from `/delivery/raw/configuration.csv`:

```bash
# Use eof-tools to generate Ansible variables
python /path/to/eof-tools/automation/scripts/generate-ansible-vars.py \
  /path/to/cisco/cloud/hybrid-infrastructure
```

This generates environment-specific variable files in `vars/generated/`:
- `hyperflex.yml` - HyperFlex cluster configuration
- `fabric_interconnect.yml` - UCS Fabric Interconnect settings
- `vmware.yml` - vSphere configuration
- `intersight.yml` - Intersight API credentials
- And more...

### 3. Set Up Secrets

```bash
cd automation/platform-native/ansible

# Copy secrets template
cp vars/secrets.yml.template vars/secrets.yml

# Edit and add actual credentials
vi vars/secrets.yml

# Encrypt with Ansible Vault
ansible-vault encrypt vars/secrets.yml

# Create vault password file (add to .gitignore)
echo 'your-vault-password' > .vault_password
chmod 600 .vault_password
```

### 4. Validate Configuration

```bash
# Validate Intersight API connectivity
python ../scripts/python/intersight_client.py \
  --api-key YOUR_API_KEY \
  --secret-file /path/to/SecretKey.txt \
  --action validate

# Check Ansible syntax
ansible-playbook playbooks/site.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbooks/site.yml --check --ask-vault-pass
```

## Deployment

### Environment Selection

Choose the target environment (production, test, or DR):

```bash
# Production deployment
ansible-playbook playbooks/site.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password

# Test environment deployment
ansible-playbook playbooks/site.yml \
  -i inventory/test/hosts.yml \
  --vault-password-file .vault_password

# DR environment deployment
ansible-playbook playbooks/site.yml \
  -i inventory/dr/hosts.yml \
  --vault-password-file .vault_password
```

### Phase-by-Phase Deployment

Deploy in phases for better control and validation:

```bash
# Phase 1: Foundation (Fabric Interconnects, VLANs, networking)
ansible-playbook playbooks/01-foundation.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password

# Phase 1: Cluster (HyperFlex cluster deployment)
ansible-playbook playbooks/02-cluster.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password

# Phase 2: Storage (Datastores, storage policies)
ansible-playbook playbooks/03-storage.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password

# Phase 2: Integration (Intersight, vSphere, backup)
ansible-playbook playbooks/04-integration.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password

# Phase 3: Validation (health checks, go-live validation)
ansible-playbook playbooks/05-validation.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password
```

### Using Tags

Run specific tasks using tags:

```bash
# Run only foundation tasks
ansible-playbook playbooks/site.yml \
  -i inventory/prod/hosts.yml \
  --tags foundation \
  --vault-password-file .vault_password

# Run multiple phases
ansible-playbook playbooks/site.yml \
  -i inventory/prod/hosts.yml \
  --tags "foundation,cluster" \
  --vault-password-file .vault_password

# Skip specific phases
ansible-playbook playbooks/site.yml \
  -i inventory/prod/hosts.yml \
  --skip-tags validation \
  --vault-password-file .vault_password
```

## Configuration Management

### Multi-Environment Support

The automation supports three environments with different configurations:

| Environment | Purpose | Cluster Size | Network | Use Case |
|-------------|---------|--------------|---------|----------|
| **Production** | Live workloads | 4 nodes (HX240c M5) | 10.100.x.x | Primary production environment |
| **Test** | Pre-production testing | 3 nodes (HX220c M5) | 10.101.x.x | Testing and validation |
| **DR** | Disaster recovery | 4 nodes (HX240c M5) | 10.102.x.x | Backup site for production |

Configuration differences are managed via:
- Environment-specific inventory files (`inventory/{prod,test,dr}/hosts.yml`)
- Multi-column configuration in `configuration.csv` (Production, Test, DR)
- Environment variables in playbook execution

### Updating Configuration

1. Edit `/delivery/raw/configuration.csv` with new values
2. Regenerate Ansible variables:
   ```bash
   python /path/to/eof-tools/automation/scripts/generate-ansible-vars.py \
     /path/to/solution
   ```
3. Review changes in `vars/generated/`
4. Run specific playbooks to apply changes

## Deployment Phases

The deployment follows the SOW phases:

| Phase | Playbooks | Description | Duration |
|-------|-----------|-------------|----------|
| **Phase 1: Design & Planning** | Manual | Infrastructure assessment, architecture design | Weeks 1-2 |
| **Phase 1: Infrastructure Deployment** | 01-foundation.yml, 02-cluster.yml | Fabric Interconnects, HyperFlex cluster, vSphere | Weeks 3-4 |
| **Phase 2: VM Migration** | Manual (vMotion) | Phased VM migration in waves | Weeks 5-8 |
| **Phase 2: Integration** | 03-storage.yml, 04-integration.yml | Storage policies, Intersight, backup | Weeks 5-8 |
| **Phase 3: Optimization** | 05-validation.yml | Performance tuning, validation, training | Weeks 9-12 |

## Monitoring & Validation

### Health Checks

```bash
# Check cluster health via Intersight API
python scripts/python/intersight_client.py \
  --api-key YOUR_API_KEY \
  --secret-file /path/to/SecretKey.txt \
  --cluster-name hx-cluster-prod \
  --action health

# Get active alarms
python scripts/python/intersight_client.py \
  --api-key YOUR_API_KEY \
  --secret-file /path/to/SecretKey.txt \
  --cluster-name hx-cluster-prod \
  --action alarms

# Run validation playbook
ansible-playbook playbooks/05-validation.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password
```

### Logs

Execution logs are stored in:
- `ansible/logs/ansible.log` - Ansible playbook execution logs
- `ansible/logs/validation_report_*.txt` - Validation test results

## Rollback

In case of deployment issues:

```bash
# Emergency rollback playbook
ansible-playbook playbooks/rollback.yml \
  -i inventory/prod/hosts.yml \
  --vault-password-file .vault_password
```

**Note:** Rollback procedures should be tested in the test environment first.

## Troubleshooting

### Common Issues

#### 1. Intersight API Authentication Errors

```bash
# Validate connectivity
python scripts/python/intersight_client.py \
  --api-key YOUR_API_KEY \
  --secret-file /path/to/SecretKey.txt \
  --action validate
```

**Solutions:**
- Verify API key ID is correct
- Check secret key file path and permissions
- Ensure clock sync (authentication uses timestamps)
- Verify API key has appropriate Intersight permissions

#### 2. Ansible Vault Errors

```bash
Error: Decryption failed
```

**Solutions:**
- Verify vault password is correct
- Check `.vault_password` file exists and has correct permissions (600)
- Re-encrypt secrets: `ansible-vault rekey vars/secrets.yml`

#### 3. Collection Import Errors

```bash
ERROR! couldn't resolve module/action 'cisco.intersight.intersight_rest_api'
```

**Solutions:**
```bash
# Reinstall collections
ansible-galaxy collection install -r requirements.yml --force
```

#### 4. Network Connectivity Issues

**Solutions:**
- Verify management network connectivity to cluster IP
- Check firewall rules allow HTTPS (443) to Intersight
- Test connectivity: `curl -k https://intersight.com`
- Verify VPN connection if required

### Verbose Output

```bash
# Increase Ansible verbosity
ansible-playbook playbooks/site.yml -vvv --ask-vault-pass
```

### Check Mode (Dry Run)

```bash
# Preview changes without applying
ansible-playbook playbooks/site.yml --check --ask-vault-pass
```

## Security Best Practices

1. **Never commit secrets to git**
   - Use Ansible Vault for sensitive data
   - Add `secrets.yml` and `.vault_password` to `.gitignore`

2. **API Key Management**
   - Use separate API keys per environment
   - Rotate keys regularly (every 90 days)
   - Store secret keys securely (not in project directory)

3. **Network Security**
   - Use management VLANs for infrastructure access
   - Restrict Intersight API access to authorized IPs
   - Enable MFA for Intersight accounts

4. **Audit Logging**
   - Review Ansible logs regularly
   - Monitor Intersight audit logs
   - Track configuration changes in version control

## Support

### Documentation
- [Cisco Intersight Documentation](https://intersight.com/help)
- [HyperFlex Installation Guide](https://www.cisco.com/c/en/us/support/hyperconverged-infrastructure/hyperflex-hx-series/products-installation-guides-list.html)
- [Ansible cisco.intersight Collection](https://galaxy.ansible.com/cisco/intersight)

### Cisco TAC Support
- SmartNet Contract: See `support.cisco_smartnet` in configuration
- Open TAC case: https://mycase.cloudapps.cisco.com
- Severity levels: 1=Critical, 2=High, 3=Medium, 4=Low

### Escalation
- Primary Contact: See `support.escalation_contact` in configuration
- After-hours escalation: Follow company procedures
- Intersight SaaS issues: Cisco TAC

## Contributing

When modifying automation:

1. Test changes in test environment first
2. Document new playbooks/roles in README
3. Update configuration.csv if adding new parameters
4. Regenerate Ansible variables after CSV changes
5. Commit with descriptive messages (no AI/tool references per CLAUDE.md)

## References

- [Statement of Work](../../presales/raw/statement-of-work.md)
- [Solution Briefing](../../presales/raw/solution-briefing.md)
- [Configuration Parameters](../raw/configuration.csv)
- [Ansible Documentation](ansible/README.md)
- [Python Scripts Documentation](platform-native/scripts/python/README.md)

---

**Last Updated:** 2025-12-03
**Solution Version:** 1.0
**Maintained By:** EO Framework Cisco Solutions Team

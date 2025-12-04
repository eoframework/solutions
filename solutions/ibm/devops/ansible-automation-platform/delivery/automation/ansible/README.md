# Ansible Automation Platform - Platform-Native Automation

This directory contains Ansible playbooks for post-deployment configuration of AAP.

## Directory Structure

```
ansible/
├── site.yml                 # Master playbook
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Collection dependencies
├── inventory/
│   ├── prod/hosts.yml       # Production inventory
│   ├── test/hosts.yml       # Test inventory
│   └── dr/hosts.yml         # DR inventory
├── vars/
│   ├── environments/        # Environment-specific variables
│   │   ├── prod.yml
│   │   ├── test.yml
│   │   └── dr.yml
│   └── generated/           # Auto-generated from configuration.xlsx
│       └── project.yml
└── roles/
    ├── aap-controller/      # Controller settings
    ├── aap-credentials/     # Credential management
    ├── aap-projects/        # Project configuration
    ├── aap-inventories/     # Inventory management
    ├── aap-templates/       # Job templates
    ├── aap-workflows/       # Workflow templates
    ├── aap-hub/             # Private Automation Hub
    ├── aap-collections/     # Collection sync
    ├── aap-ee/              # Execution environments
    ├── aap-execution/       # Execution node config
    ├── aap-ldap/            # LDAP authentication
    ├── aap-vault/           # HashiCorp Vault
    ├── aap-cyberark/        # CyberArk integration
    ├── aap-servicenow/      # ServiceNow integration
    ├── aap-monitoring/      # Monitoring setup
    ├── aap-logging/         # Log aggregation
    ├── aap-rbac/            # RBAC configuration
    └── aap-backup/          # Backup configuration
```

## Prerequisites

1. Install required collections:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. Set up vault password:
   ```bash
   export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
   ```

3. Configure sensitive variables in vault:
   ```bash
   ansible-vault create vars/vault.yml
   ```

## Usage

### Run full configuration (Production)
```bash
ansible-playbook site.yml -i inventory/prod/hosts.yml -e env=prod
```

### Run specific roles
```bash
# Configure LDAP only
ansible-playbook site.yml -i inventory/prod/hosts.yml -e env=prod --tags ldap

# Configure credentials and projects
ansible-playbook site.yml -i inventory/prod/hosts.yml -e env=prod --tags credentials,projects
```

### Test environment
```bash
ansible-playbook site.yml -i inventory/test/hosts.yml -e env=test
```

### DR environment
```bash
ansible-playbook site.yml -i inventory/dr/hosts.yml -e env=dr
```

## Vault Variables

Create `vars/vault.yml` with:

```yaml
aap_admin_password: <admin_password>
aap_ldap_bind_password: <ldap_bind_password>
aap_vault_token: <hashicorp_vault_token>
aap_servicenow_password: <servicenow_password>
aap_hub_token: <hub_api_token>
aap_aws_access_key: <aws_access_key>
aap_aws_secret_key: <aws_secret_key>
```

## Integration with Terraform

The inventory files are designed to be populated from Terraform outputs:

```bash
# Generate inventory from Terraform
terraform output -json | python scripts/generate_inventory.py > inventory/prod/hosts.yml
```

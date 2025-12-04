# Platform-Native Automation

This folder contains **Ansible-based automation** for the Dell SafeID Authentication solution.

## Tool Selection

| Solution Type | Selected Tool | Reason |
|---------------|---------------|--------|
| Dell SafeID Enterprise | Ansible | Linux server management and API integration |

## Folder Structure

```
platform-native/
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Galaxy collection dependencies
    ├── inventory/
    │   ├── production/          # Production environment
    │   ├── test/                # Test/lab environment
    │   └── dr/                  # DR site
    ├── playbooks/
    │   ├── site.yml             # Master orchestration
    │   ├── safeid-deploy.yml    # SafeID appliance deployment
    │   ├── ldap-integration.yml # LDAP/AD integration
    │   ├── radius-config.yml    # RADIUS configuration
    │   ├── token-enrollment.yml # Token provisioning
    │   └── validate.yml         # Post-deployment validation
    ├── roles/
    │   ├── safeid-appliance/    # Base appliance configuration
    │   ├── safeid-ldap/         # LDAP/AD integration
    │   ├── safeid-radius/       # RADIUS authentication
    │   ├── safeid-saml/         # SAML IdP configuration
    │   ├── safeid-tokens/       # Token management
    │   └── safeid-backup/       # Backup and HA
    └── scripts/
        ├── deploy.sh            # Deployment wrapper
        └── validate.sh          # Validation script
```

## Getting Started

See [ansible/README.md](ansible/README.md) for detailed deployment instructions.

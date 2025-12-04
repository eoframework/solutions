# Platform-Native Automation

This folder contains **Ansible-based automation** for the Dell VxRail Hyperconverged (Enterprise) solution.

## Tool Selection

| Solution Type | Selected Tool | Reason |
|---------------|---------------|--------|
| Dell VxRail + VMware | Ansible | Dell-supported `dellemc.openmanage` and `community.vmware` collections |

## Folder Structure

```
platform-native/
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Galaxy collection dependencies
    ├── inventory/
    │   ├── production/          # Production cluster (8 nodes)
    │   ├── test/                # Lab environment (4 nodes)
    │   └── dr/                  # DR site (8 nodes)
    ├── playbooks/
    │   ├── site.yml             # Master orchestration
    │   ├── vxrail-precheck.yml  # Pre-deployment validation
    │   ├── vxrail-deploy.yml    # VxRail cluster deployment
    │   ├── vcenter-config.yml   # vCenter configuration
    │   ├── nsx-deploy.yml       # NSX-T deployment
    │   ├── srm-config.yml       # Site Recovery Manager
    │   ├── database-setup.yml   # Database deployment
    │   └── validate.yml         # Post-deployment validation
    ├── roles/
    │   ├── vxrail-precheck/     # Pre-deployment checks
    │   ├── vxrail-deploy/       # VxRail deployment
    │   ├── vmware-vcenter/      # vCenter configuration
    │   ├── vmware-nsx/          # NSX-T deployment
    │   ├── vmware-srm/          # SRM configuration
    │   ├── dell-idrac/          # iDRAC management
    │   ├── oracle-rac/          # Oracle RAC deployment
    │   └── sql-always-on/       # SQL Server Always On
    └── scripts/
        ├── deploy.sh            # Deployment wrapper
        └── validate.sh          # Validation script
```

## Getting Started

See [ansible/README.md](ansible/README.md) for detailed deployment instructions.

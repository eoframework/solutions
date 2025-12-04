# Platform-Native Automation

This folder contains **Ansible-based automation** for the Dell VxRail Hyperconverged Infrastructure solution.

## Tool Selection

| Solution Type | Selected Tool | Reason |
|---------------|---------------|--------|
| Dell VxRail HCI | Ansible | Dell-supported `dellemc.openmanage` and VMware `community.vmware` collections |

## Folder Structure

```
platform-native/
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Galaxy collection dependencies
    ├── inventory/
    │   ├── production/          # Production VxRail cluster
    │   ├── test/                # Lab environment
    │   └── dr/                  # DR site cluster
    ├── playbooks/
    │   ├── site.yml             # Master orchestration
    │   ├── vxrail-precheck.yml  # Pre-deployment validation
    │   ├── vxrail-deploy.yml    # VxRail cluster deployment
    │   ├── vcenter-config.yml   # vCenter Server configuration
    │   ├── vsan-config.yml      # vSAN storage configuration
    │   ├── networking-config.yml # Network configuration
    │   ├── lifecycle-update.yml # VxRail LCM updates
    │   └── validate.yml         # Post-deployment validation
    ├── roles/
    │   ├── vxrail-precheck/     # Pre-deployment checks
    │   ├── vxrail-deploy/       # VxRail deployment
    │   ├── vmware-vcenter/      # vCenter configuration
    │   ├── vmware-vsan/         # vSAN configuration
    │   ├── dell-idrac/          # iDRAC management
    │   └── dell-openmanage/     # OpenManage Enterprise
    └── scripts/
        ├── deploy.sh            # Deployment wrapper
        └── validate.sh          # Validation script
```

## Getting Started

See [ansible/README.md](ansible/README.md) for detailed deployment instructions.

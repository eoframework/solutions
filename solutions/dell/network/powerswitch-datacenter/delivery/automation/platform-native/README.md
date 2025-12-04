# Platform-Native Automation

This folder contains **Ansible-based automation** for the Dell PowerSwitch Datacenter solution.

## Tool Selection

| Solution Type | Selected Tool | Reason |
|---------------|---------------|--------|
| Dell PowerSwitch OS10 | Ansible | Dell-supported `dellemc.os10` collection |

## Folder Structure

```
platform-native/
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Galaxy collection dependencies
    ├── inventory/
    │   ├── production/          # Production datacenter
    │   ├── test/                # Lab environment
    │   └── dr/                  # DR site
    ├── playbooks/
    │   ├── site.yml             # Master orchestration
    │   ├── fabric-deploy.yml    # Full fabric deployment
    │   ├── spine-config.yml     # Spine switch configuration
    │   ├── leaf-config.yml      # Leaf switch configuration
    │   └── validate.yml         # Post-deployment validation
    ├── roles/
    │   ├── os10-base/           # Base switch configuration
    │   ├── os10-interfaces/     # Interface configuration
    │   ├── os10-vlans/          # VLAN configuration
    │   ├── os10-bgp/            # BGP underlay
    │   ├── os10-vxlan/          # VXLAN overlay (if enabled)
    │   └── os10-monitoring/     # SNMP, syslog, monitoring
    └── scripts/
        ├── deploy.sh            # Deployment wrapper
        ├── validate.sh          # Validation script
        └── backup.sh            # Configuration backup
```

## Getting Started

See [ansible/README.md](ansible/README.md) for detailed deployment instructions.

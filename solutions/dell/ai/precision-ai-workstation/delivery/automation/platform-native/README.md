# Platform-Native Automation

This folder contains **Ansible-based automation** for the Dell Precision AI Workstation solution.

## Tool Selection

| Solution Type | Selected Tool | Reason |
|---------------|---------------|--------|
| Dell Precision Workstations | Ansible | Dell-supported `dellemc.openmanage` collection |

## Folder Structure

```
platform-native/
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Galaxy collection dependencies
    ├── inventory/
    │   ├── production/          # Production workstations
    │   ├── test/                # Test/lab workstations
    │   └── dr/                  # DR environment
    ├── playbooks/
    │   ├── site.yml             # Master orchestration
    │   ├── workstation-provision.yml  # Full workstation provisioning
    │   ├── nvidia-drivers.yml   # GPU driver installation
    │   ├── ml-stack.yml         # ML framework setup
    │   ├── powerscale-mount.yml # NFS mount configuration
    │   ├── monitoring-setup.yml # Datadog agent setup
    │   └── validate.yml         # Post-deployment validation
    ├── vars/
    │   ├── generated/           # Auto-generated from configuration.csv
    │   │   ├── project.yml      # Solution metadata
    │   │   ├── hardware.yml     # Workstation hardware specs
    │   │   ├── storage.yml      # PowerScale configuration
    │   │   ├── network.yml      # Network settings
    │   │   ├── software.yml     # OS and NVIDIA versions
    │   │   ├── application.yml  # Jupyter settings
    │   │   ├── monitoring.yml   # Datadog configuration
    │   │   ├── security.yml     # SSH and firewall
    │   │   ├── operations.yml   # Backup policies
    │   │   ├── support.yml      # Dell ProSupport
    │   │   ├── performance.yml  # Target metrics
    │   │   └── dr.yml           # DR settings
    │   ├── secrets.yml.template # Template for sensitive values
    │   └── secrets.yml          # Ansible Vault encrypted (DO NOT COMMIT)
    ├── roles/                   # Custom roles
    └── logs/                    # Execution logs
```

## Getting Started

See [ansible/README.md](ansible/README.md) for detailed deployment instructions.

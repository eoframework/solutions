# Platform-Native Automation

This folder contains **Ansible-based automation** for the Dell PowerEdge CI Infrastructure solution.

## Tool Selection

| Solution Type | Selected Tool | Reason |
|---------------|---------------|--------|
| Dell PowerEdge CI/CD | Ansible | Dell-supported `dellemc.openmanage` collection |

## Folder Structure

```
platform-native/
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Galaxy collection dependencies
    ├── inventory/
    │   ├── production/          # Production CI/CD infrastructure
    │   ├── test/                # Lab environment
    │   └── dr/                  # DR site
    ├── playbooks/
    │   ├── site.yml             # Master orchestration
    │   ├── gitlab-deploy.yml    # GitLab server deployment
    │   ├── runners-provision.yml # GitLab Runner provisioning
    │   ├── artifactory-setup.yml # Artifactory artifact repository
    │   ├── docker-config.yml    # Docker configuration
    │   ├── monitoring-setup.yml # Prometheus/Grafana monitoring
    │   └── validate.yml         # Post-deployment validation
    ├── roles/
    │   ├── poweredge-provision/ # Dell PowerEdge R650 provisioning
    │   ├── gitlab-server/       # GitLab server configuration
    │   ├── gitlab-runners/      # GitLab Runner setup
    │   ├── docker-hosts/        # Docker Enterprise setup
    │   ├── artifactory/         # JFrog Artifactory setup
    │   └── prometheus-grafana/  # Monitoring stack
    └── scripts/
        ├── deploy.sh            # Deployment wrapper
        └── validate.sh          # Validation script
```

## Getting Started

See [ansible/README.md](ansible/README.md) for detailed deployment instructions.

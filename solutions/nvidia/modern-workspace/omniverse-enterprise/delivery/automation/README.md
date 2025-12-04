# NVIDIA Omniverse Enterprise - Automation

This directory contains Ansible automation for deploying NVIDIA Omniverse Enterprise for collaborative 3D design workflows.

## Directory Structure

```
automation/
├── README.md                    # This file
└── ansible/
    ├── ansible.cfg              # Ansible configuration
    ├── requirements.yml         # Ansible Galaxy dependencies
    ├── inventory/
    │   ├── prod/               # Production environment
    │   │   ├── hosts.yml       # Host inventory
    │   │   └── group_vars/
    │   │       └── all.yml     # Environment variables
    │   ├── test/               # Test environment
    │   │   ├── hosts.yml
    │   │   └── group_vars/
    │   │       └── all.yml
    │   └── dr/                 # DR environment
    │       ├── hosts.yml
    │       └── group_vars/
    │           └── all.yml
    ├── playbooks/
    │   ├── site.yml            # Master orchestration playbook
    │   ├── 01-foundation.yml   # Storage and network prep
    │   ├── 02-nucleus.yml      # Nucleus server deployment
    │   ├── 03-workstations.yml # Workstation configuration
    │   ├── 04-connectors.yml   # Application connectors
    │   ├── 05-monitoring.yml   # Prometheus/Grafana
    │   └── 06-validation.yml   # System validation
    ├── roles/
    │   ├── common/             # Base configuration
    │   ├── nucleus-server/     # Nucleus server setup
    │   ├── workstation-setup/  # RTX workstation config
    │   └── omniverse-connectors/  # App connectors
    ├── templates/              # Jinja2 templates
    └── vars/
        └── secrets.yml         # Ansible Vault encrypted secrets
```

## Prerequisites

- Ansible 2.14 or higher
- SSH access to Linux hosts (Nucleus servers)
- WinRM access to Windows workstations
- Ansible Vault password for secrets

## Quick Start

### 1. Install Ansible Dependencies

```bash
cd ansible
ansible-galaxy install -r requirements.yml
```

### 2. Configure Secrets

```bash
cp vars/secrets.yml.template vars/secrets.yml
ansible-vault encrypt vars/secrets.yml
```

### 3. Deploy to Environment

```bash
# Production deployment
ansible-playbook -i inventory/prod playbooks/site.yml --ask-vault-pass

# Test deployment
ansible-playbook -i inventory/test playbooks/site.yml --ask-vault-pass

# DR deployment
ansible-playbook -i inventory/dr playbooks/site.yml --ask-vault-pass
```

### 4. Deploy Specific Components

```bash
# Only Nucleus servers
ansible-playbook -i inventory/prod playbooks/site.yml --tags nucleus

# Only workstations
ansible-playbook -i inventory/prod playbooks/site.yml --tags workstations

# Only connectors
ansible-playbook -i inventory/prod playbooks/site.yml --tags connectors
```

## Environment Configuration

Environment-specific variables are stored in `inventory/{env}/group_vars/all.yml`.

These files are generated from `delivery/raw/configuration.csv` using:
```bash
python generate-ansible-vars.py --env prod
python generate-ansible-vars.py --env test
python generate-ansible-vars.py --env dr
```

## Tags Reference

| Tag | Description |
|-----|-------------|
| `foundation` | Storage and network preparation |
| `nucleus` | Nucleus server deployment |
| `workstations` | RTX workstation configuration |
| `connectors` | Application connector installation |
| `monitoring` | Prometheus and Grafana setup |
| `validation` | System health checks |

## Supported Connectors

- Autodesk Revit
- Dassault SolidWorks
- Rhino 3D
- Blender (USD)
- Autodesk Maya
- Autodesk 3ds Max

## Notes

- Windows workstations require WinRM to be enabled
- Nucleus servers run as Docker containers
- High availability requires two Nucleus servers
- All connectors are optional and configurable per environment

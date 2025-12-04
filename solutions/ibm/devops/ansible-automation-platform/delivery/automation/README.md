# Ansible Automation Platform Automation

This automation deploys and configures Red Hat Ansible Automation Platform using Ansible itself (self-referential automation):

- **Ansible**: Platform installation, Controller configuration, Hub setup

## Prerequisites

- Red Hat Ansible Automation Platform subscription
- Target infrastructure access (AWS/Azure/on-premises)
- Ansible 2.14+ with awx.awx collection
- Python 3.9+
- SSH/WinRM access to managed nodes

## Quick Start

### 1. Install Collections

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
```

### 2. Generate Configuration

```bash
# Generate Ansible group_vars from configuration.csv
python /mnt/c/projects/wsl/eof-tools/automation/scripts/generate-ansible-vars.py \
    /mnt/c/projects/wsl/solutions/solutions/ibm/devops/ansible-automation-platform prod
```

### 3. Install Platform

```bash
cd ansible
ansible-playbook -i inventory/prod playbooks/aap-install.yml
```

### 4. Configure Controller

```bash
ansible-playbook -i inventory/prod playbooks/controller-config.yml
ansible-playbook -i inventory/prod playbooks/hub-config.yml
```

## Folder Structure

```
automation/
├── README.md                     # This file
├── ansible/
│   ├── ansible.cfg               # Ansible configuration
│   ├── collections/
│   │   └── requirements.yml      # Collection dependencies
│   ├── inventory/
│   │   ├── prod/                 # Production inventory
│   │   ├── test/                 # Test inventory
│   │   └── dr/                   # DR inventory
│   ├── playbooks/
│   │   ├── aap-install.yml       # Platform installation
│   │   ├── controller-config.yml # Controller configuration
│   │   ├── hub-config.yml        # Automation Hub setup
│   │   └── ee-build.yml          # Execution environment build
│   └── roles/
│       ├── aap-controller/       # Controller configuration role
│       ├── aap-hub/              # Hub configuration role
│       ├── aap-eda/              # Event-Driven Ansible role
│       └── execution-environments/ # EE build role
└── execution-environments/
    ├── ee-base/                  # Base execution environment
    │   └── execution-environment.yml
    └── ee-network/               # Network automation EE
        └── execution-environment.yml
```

## Environment Differences

| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Controller Nodes | 2 (HA) | 1 | 2 (HA) |
| Execution Nodes | 4 | 2 | 4 |
| LDAP Integration | Enabled | Disabled | Enabled |
| Vault Integration | Enabled | Disabled | Enabled |
| ServiceNow Integration | Enabled | Disabled | Enabled |
| Backup | Daily, 30-day retention | Daily, 7-day | Daily, 30-day |

## Playbook Descriptions

| Playbook | Purpose |
|----------|---------|
| `aap-install.yml` | Install AAP Controller and Hub infrastructure |
| `controller-config.yml` | Configure organizations, credentials, projects |
| `hub-config.yml` | Configure Hub with collections and EEs |
| `ee-build.yml` | Build custom execution environments |

## Validation

```bash
# Check playbook syntax
ansible-playbook --syntax-check playbooks/controller-config.yml

# Verify Controller accessibility
curl -k https://aap.example.com/api/v2/ping/

# List configured resources
awx organizations list
awx projects list
awx job_templates list
```

## Troubleshooting

| Issue | Resolution |
|-------|------------|
| Controller unreachable | Check firewall rules and load balancer |
| LDAP auth fails | Verify bind credentials and search base DN |
| Jobs timeout | Increase execution node capacity |
| Hub sync fails | Check network connectivity and authentication |

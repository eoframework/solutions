# Cisco Network CI/CD Automation - Ansible Automation

This directory contains Ansible automation for deploying and managing the Cisco Network CI/CD Automation solution.

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── requirements.yml         # Galaxy dependencies
├── README.md               # This file
├── inventory/
│   ├── prod/hosts.yml      # Production environment
│   ├── test/hosts.yml      # Test environment
│   └── dr/hosts.yml        # DR environment
├── playbooks/
│   ├── site.yml            # Main orchestration playbook
│   ├── 01-foundation.yml   # GitOps and pipeline setup
│   ├── 02-core.yml         # Network orchestration platform
│   ├── 03-integrations.yml # External system connections
│   ├── 04-operations.yml   # Monitoring and logging
│   ├── 05-validation.yml   # Testing and verification
│   └── rollback.yml        # Rollback procedures
├── roles/
│   ├── gitlab-setup/       # GitLab CI/CD configuration
│   ├── jenkins-setup/      # Jenkins pipeline setup
│   ├── vault-integration/  # HashiCorp Vault secrets
│   ├── dnac-integration/   # DNA Center API integration
│   └── ...
├── vars/
│   ├── generated/          # Auto-generated from configuration.csv
│   ├── secrets.yml.template
│   └── README.md
└── logs/                   # Execution logs
```

## Quick Start

### Prerequisites

1. Install Ansible 2.12+
2. Install Python dependencies: `pip install -r requirements.txt`
3. Install Galaxy collections: `ansible-galaxy install -r requirements.yml`

### Setup Secrets

```bash
# Copy and edit secrets template
cp vars/secrets.yml.template vars/secrets.yml
vi vars/secrets.yml

# Encrypt with Ansible Vault
ansible-vault encrypt vars/secrets.yml
```

### Deploy

```bash
# Production deployment
ansible-playbook -i inventory/prod/hosts.yml playbooks/site.yml --ask-vault-pass

# Test environment
ansible-playbook -i inventory/test/hosts.yml playbooks/site.yml --ask-vault-pass

# DR environment
ansible-playbook -i inventory/dr/hosts.yml playbooks/site.yml --ask-vault-pass
```

### Phase-based Execution

```bash
# Run only foundation setup
ansible-playbook -i inventory/prod/hosts.yml playbooks/site.yml --tags "phase1"

# Run validation only
ansible-playbook -i inventory/prod/hosts.yml playbooks/05-validation.yml
```

### Rollback

```bash
# Execute rollback
ansible-playbook -i inventory/prod/hosts.yml playbooks/rollback.yml
```

## Regenerating Variables

When `configuration.csv` is updated, regenerate the vars:

```bash
python /path/to/eof-tools/automation/scripts/generate-ansible-vars.py \
  /path/to/solutions/cisco/devops/ci-cd-automation
```

## Components Configured

| Component | Description |
|-----------|-------------|
| GitLab | Source control and CI/CD pipelines |
| Jenkins | Alternative CI/CD automation |
| HashiCorp Vault | Secrets management |
| DNA Center | Network controller API |
| NSO | Network Services Orchestrator |
| NetBox | DCIM/IPAM source of truth |
| Prometheus/Grafana | Monitoring and dashboards |
| Splunk | Log aggregation |
| ServiceNow | ITSM integration |

## Troubleshooting

### Check connectivity
```bash
ansible-playbook -i inventory/prod/hosts.yml playbooks/05-validation.yml
```

### Verbose output
```bash
ansible-playbook -i inventory/prod/hosts.yml playbooks/site.yml -vvv
```

### Check specific tag
```bash
ansible-playbook -i inventory/prod/hosts.yml playbooks/site.yml --tags "gitlab" --check
```

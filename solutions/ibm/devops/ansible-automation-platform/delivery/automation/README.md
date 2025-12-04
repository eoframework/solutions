# Ansible Automation Platform Automation

This automation deploys and configures Red Hat Ansible Automation Platform:

- **Terraform**: AWS infrastructure provisioning (VPC, EC2, RDS, ALB)
- **Ansible**: Platform configuration (Controller, Hub, credentials, projects)

## Prerequisites

- Red Hat Ansible Automation Platform subscription
- AWS account with appropriate permissions
- Terraform 1.5+
- Ansible 2.14+ with awx.awx collection
- Python 3.9+

## Quick Start

### 1. Provision Infrastructure (Terraform)

```bash
cd terraform/environments/prod
terraform init
terraform plan -var-file=config/solution.tfvars
terraform apply -var-file=config/solution.tfvars
```

### 2. Install Collections (Ansible)

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
```

### 3. Configure Platform (Ansible)

```bash
cd ansible
ansible-playbook -i inventory/prod/hosts.yml site.yml -e env=prod
```

## Folder Structure

```
automation/
├── README.md                     # This file
├── terraform/
│   ├── environments/
│   │   ├── prod/                 # Production environment
│   │   ├── test/                 # Test environment
│   │   └── dr/                   # DR environment
│   └── modules/
│       ├── solution/             # Solution-level modules
│       │   ├── core/             # VPC, EC2, RDS, ALB
│       │   └── operations/       # Monitoring, backup
│       └── aws/                  # AWS provider modules
│           ├── vpc/
│           ├── rds-postgres/
│           └── ec2-aap/
└── ansible/
    ├── ansible.cfg               # Ansible configuration
    ├── requirements.yml          # Collection dependencies
    ├── site.yml                  # Main playbook
    ├── inventory/
    │   ├── prod/                 # Production inventory
    │   ├── test/                 # Test inventory
    │   └── dr/                   # DR inventory
    ├── roles/
    │   ├── aap-controller/       # Controller configuration
    │   ├── aap-hub/              # Hub configuration
    │   ├── aap-credentials/      # Credential management
    │   ├── aap-projects/         # Project setup
    │   ├── aap-templates/        # Job templates
    │   ├── aap-workflows/        # Workflow templates
    │   ├── aap-inventories/      # Inventory sources
    │   ├── aap-rbac/             # RBAC configuration
    │   ├── aap-ldap/             # LDAP integration
    │   ├── aap-vault/            # HashiCorp Vault integration
    │   ├── aap-servicenow/       # ServiceNow integration
    │   ├── aap-monitoring/       # Monitoring setup
    │   ├── aap-logging/          # Log aggregation
    │   ├── aap-backup/           # Backup configuration
    │   ├── aap-ee/               # Execution environments
    │   ├── aap-execution/        # Execution nodes
    │   ├── aap-collections/      # Collection sync
    │   └── aap-cyberark/         # CyberArk integration
    ├── vars/
    │   ├── environments/         # Environment-specific vars
    │   │   ├── prod.yml
    │   │   ├── test.yml
    │   │   └── dr.yml
    │   └── generated/            # Generated from configuration.csv
    │       └── project.yml
    └── execution-environments/
        ├── ee-base/              # Base execution environment
        └── ee-network/           # Network automation EE
```

## Environment Differences

| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Controller Nodes | 2 (HA) | 1 | 2 (HA) |
| Execution Nodes | 4 | 2 | 4 |
| Database | Multi-AZ RDS | Single RDS | Multi-AZ RDS |
| LDAP Integration | Enabled | Disabled | Enabled |
| Vault Integration | Enabled | Disabled | Enabled |
| ServiceNow | Enabled | Disabled | Enabled |
| Backup | Daily, 30-day | Disabled | Daily, 30-day |

## Ansible Roles

| Role | Purpose |
|------|---------|
| `aap-controller` | Configure Automation Controller settings |
| `aap-hub` | Configure Private Automation Hub |
| `aap-credentials` | Create and manage credentials |
| `aap-projects` | Set up Git-based projects |
| `aap-templates` | Create job templates |
| `aap-workflows` | Create workflow templates |
| `aap-inventories` | Configure inventory sources |
| `aap-rbac` | Set up organizations, teams, users |
| `aap-ldap` | Configure LDAP authentication |
| `aap-vault` | HashiCorp Vault credential lookup |
| `aap-servicenow` | ServiceNow ITSM integration |
| `aap-monitoring` | Prometheus/Grafana metrics |
| `aap-logging` | Splunk/ELK log forwarding |
| `aap-backup` | Automated backup configuration |
| `aap-ee` | Execution environment management |
| `aap-execution` | Execution node configuration |

## Validation

```bash
# Terraform validation
cd terraform/environments/prod
terraform validate

# Ansible syntax check
cd ansible
ansible-playbook --syntax-check site.yml

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
| Terraform init fails | Check AWS credentials and S3 backend access |
| Controller unreachable | Check security groups and ALB health |
| LDAP auth fails | Verify bind credentials and search base DN |
| Jobs timeout | Increase execution node count or instance size |
| Hub sync fails | Check network connectivity and registry auth |

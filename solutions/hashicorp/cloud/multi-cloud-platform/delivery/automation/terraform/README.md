# HashiCorp Multi-Cloud Platform - Terraform Automation

This Terraform configuration deploys HashiCorp's multi-cloud infrastructure automation platform including Terraform Cloud, HashiCorp Vault, and HashiCorp Consul.

## Architecture Overview

- **Terraform Cloud/Enterprise**: Centralized infrastructure as code platform on AWS EKS
- **HashiCorp Vault**: Secrets management with dynamic credentials for AWS, Azure, GCP
- **HashiCorp Consul**: Service mesh for cross-cloud service discovery
- **Sentinel Policies**: Policy as code for governance and compliance

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform >= 1.6.0
3. HashiCorp product licenses (Terraform Cloud Business, Vault Plus, Consul Enterprise)
4. VCS access (GitHub/GitLab) for workspace automation

## Directory Structure

```
terraform/
├── README.md                    # This file
├── setup/
│   ├── backend/                 # Remote state configuration
│   │   ├── state-backend.sh     # Linux/Mac
│   │   └── state-backend.bat    # Windows
│   └── secrets/                 # Initial secrets provisioning
├── environments/
│   ├── prod/                    # Production environment
│   ├── test/                    # Test environment
│   └── dr/                      # Disaster Recovery environment
└── modules/
    ├── aws/                     # AWS infrastructure modules
    │   ├── vpc/
    │   ├── eks/
    │   ├── rds/
    │   └── kms/
    ├── tfe/                     # Terraform Cloud/Enterprise modules
    │   ├── organization/
    │   ├── workspace/
    │   ├── team/
    │   └── policy-set/
    ├── vault/                   # HashiCorp Vault modules
    │   ├── cluster/
    │   ├── secrets-engine/
    │   └── auth-method/
    ├── consul/                  # HashiCorp Consul modules
    │   ├── cluster/
    │   └── mesh-gateway/
    └── solution/                # Solution composition modules
        ├── platform/
        ├── security/
        ├── monitoring/
        └── dr/
```

## Quick Start

### 1. Setup Backend State

```bash
# Linux/Mac
./setup/backend/state-backend.sh prod

# Windows
setup\backend\state-backend.bat prod
```

### 2. Initialize Terraform

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
```

### 3. Plan and Apply

```bash
# Using the deploy script
./eo-deploy.sh plan
./eo-deploy.sh apply

# Or manually with all tfvars
terraform plan \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/compute.tfvars \
  -var-file=config/database.tfvars \
  -var-file=config/tfc.tfvars \
  -var-file=config/vault.tfvars \
  -var-file=config/consul.tfvars \
  -var-file=config/monitoring.tfvars \
  -var-file=config/backup.tfvars \
  -var-file=config/dr.tfvars
```

## Environment Differences

| Feature | prod | test | dr |
|---------|------|------|-----|
| EKS Nodes | 3 | 2 | 3 |
| Vault HA | Yes (3 nodes) | No (1 node) | Yes (3 nodes) |
| Consul | Enabled | Disabled | Enabled |
| Sentinel | hard-mandatory | advisory | hard-mandatory |
| Multi-AZ RDS | Yes | No | Yes |
| WAF | Enabled | Disabled | Disabled |
| Backup | Full retention | Minimal | Full retention |

## Validation

```bash
# Initialize without backend for validation
terraform init -backend=false

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check -recursive
```

## Outputs

After successful deployment:
- Terraform Cloud organization URL
- Vault cluster endpoint
- Consul cluster endpoint (if enabled)
- EKS cluster endpoint
- CloudWatch dashboard URL

## Related Documentation

- [Statement of Work](../../presales/raw/statement-of-work.md)
- [Solution Briefing](../../presales/raw/solution-briefing.md)
- [Configuration Parameters](../raw/configuration.csv)

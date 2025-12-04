# Terraform Enterprise Infrastructure Automation

This directory contains Terraform configurations for deploying and managing HashiCorp Terraform Enterprise on AWS EKS.

## Architecture Overview

```
├── environments/
│   ├── prod/           # Production environment
│   │   ├── main.tf     # Main configuration
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── config/     # Environment-specific tfvars
│   ├── test/           # Test environment
│   └── dr/             # Disaster Recovery environment
├── modules/
│   ├── tfe/            # TFE-specific modules
│   │   ├── organization/
│   │   ├── workspace/
│   │   ├── team/
│   │   ├── policy-set/
│   │   ├── eks-cluster/
│   │   └── rds-postgresql/
│   └── solution/       # Solution modules
│       ├── networking/
│       ├── security/
│       ├── monitoring/
│       ├── backup/
│       └── dr/
└── setup/
    └── backend/        # State backend configuration
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0
- kubectl (for EKS management)
- HashiCorp Terraform Enterprise license

## Deployment

### 1. Initialize Backend

```bash
cd setup/backend
./state-backend.sh
```

### 2. Deploy Environment

```bash
cd environments/prod
./eo-deploy.sh init
./eo-deploy.sh plan
./eo-deploy.sh apply
```

### 3. Configure TFE

After deployment:
1. Access TFE at the configured hostname
2. Complete initial admin setup
3. Configure SSO/SAML if required
4. Create additional teams and workspaces

## Environments

| Environment | Purpose | Region | HA Mode |
|------------|---------|--------|---------|
| prod | Production platform | us-east-1 | Active-Active |
| test | Testing and validation | us-east-1 | Standalone |
| dr | Disaster Recovery | us-west-2 | Active-Active |

## Configuration

Configuration is managed through:
- `delivery/raw/configuration.csv` - Source of truth
- `delivery/configuration.xlsx` - Excel version for editing
- `environments/*/config/*.tfvars` - Generated from configuration.csv

To regenerate tfvars:
```bash
python3 /path/to/eof-tools/automation/scripts/generate-tfvars.py /path/to/solution
```

## Modules

### TFE Modules

- **organization**: TFE organization and settings
- **workspace**: Workspace management with VCS integration
- **team**: Team RBAC configuration
- **policy-set**: Sentinel policy management
- **eks-cluster**: EKS cluster for TFE
- **rds-postgresql**: PostgreSQL for state storage

### Solution Modules

- **networking**: VPC, subnets, NAT gateways
- **security**: KMS, WAF, GuardDuty, CloudTrail
- **monitoring**: CloudWatch dashboards and alarms
- **backup**: AWS Backup configuration
- **dr**: Disaster recovery configuration

## Security

- All data encrypted at rest with AWS KMS
- TLS 1.3 for data in transit
- SSO/SAML integration for authentication
- MFA required for all users
- WAF protection on ALB
- GuardDuty threat detection
- CloudTrail audit logging

## DR Strategy

- Active-Passive configuration
- RTO: 4 hours
- RPO: 1 hour
- Manual failover (recommended for safety)
- Cross-region RDS replication
- Cross-region backup replication

# Terraform Infrastructure

Infrastructure as Code for deploying this solution to AWS.

## Structure

```
terraform/
├── environments/          # Environment-specific deployments
│   ├── prod/              # Production environment
│   ├── test/              # Test environment
│   └── dr/                # Disaster recovery environment
├── modules/               # Reusable Terraform modules
│   ├── aws/               # Generic AWS modules (vpc, alb, asg, rds, etc.)
│   └── solution/          # Solution-specific module compositions
└── setup/                 # Backend state setup scripts
```

## Quick Start

### 1. Configure Environment

Edit the configuration files in `environments/{env}/config/`:

```bash
# Required: Set your org_prefix for unique S3 bucket names
vim environments/prod/config/project.tfvars
```

### 2. Setup Remote State Backend

```bash
# Linux/Mac
./setup/state-backend.sh prod

# Windows
setup\state-backend.bat prod
```

### 3. Deploy

```bash
cd environments/prod/
./deploy.sh init
./deploy.sh plan
./deploy.sh apply
```

## Environments

| Environment | Purpose | Sizing |
|-------------|---------|--------|
| **prod** | Production workloads | Full HA, multi-AZ |
| **test** | Development/testing | Minimal, single-AZ |
| **dr** | Disaster recovery | Standby capacity |

## Commands

Each environment includes a `deploy.sh` wrapper:

```bash
./deploy.sh init      # Initialize Terraform
./deploy.sh plan      # Preview changes
./deploy.sh apply     # Apply changes
./deploy.sh destroy   # Tear down (with confirmation)
./deploy.sh output    # Show outputs
```

## Configuration Files

Configuration is split by concern in `config/`:

| File | Contents |
|------|----------|
| `project.tfvars` | Solution identity, AWS region, cost center |
| `networking.tfvars` | VPC, subnets, NAT gateway |
| `compute.tfvars` | EC2, ASG, ALB settings |
| `database.tfvars` | RDS, ElastiCache settings |
| `security.tfvars` | Access controls, encryption |
| `monitoring.tfvars` | CloudWatch, logging |

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials

# DR Web Application - Terraform Automation

Infrastructure as Code for AWS Disaster Recovery Web Application solution.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Route 53 (Failover Routing)                         │
│                    app.example.com → PRIMARY / SECONDARY                    │
└─────────────────────────────────────────────────────────────────────────────┘
          │                                           │
          ▼                                           ▼
┌─────────────────────────────┐         ┌─────────────────────────────┐
│   PRIMARY (us-east-1)       │         │   DR (us-west-2)            │
│                             │         │                             │
│  ┌───────────────────────┐  │         │  ┌───────────────────────┐  │
│  │    WAF + ALB          │  │         │  │    ALB (Standby)      │  │
│  └───────────────────────┘  │         │  └───────────────────────┘  │
│           │                 │         │           │                 │
│  ┌───────────────────────┐  │         │  ┌───────────────────────┐  │
│  │  EC2 ASG (2-10)       │  │         │  │  EC2 ASG (0-10)       │  │
│  │  t3.medium            │  │         │  │  Pilot Light          │  │
│  └───────────────────────┘  │         │  └───────────────────────┘  │
│           │                 │         │           │                 │
│  ┌───────────────────────┐  │────────▶│  ┌───────────────────────┐  │
│  │  Aurora Global DB     │  │ Replica │  │  Aurora Secondary     │  │
│  │  (Primary Writer)     │  │         │  │  (Read Replica)       │  │
│  └───────────────────────┘  │         │  └───────────────────────┘  │
│           │                 │         │           │                 │
│  ┌───────────────────────┐  │────────▶│  ┌───────────────────────┐  │
│  │  S3 Bucket            │  │ CRR     │  │  S3 Bucket (DR)       │  │
│  └───────────────────────┘  │         │  └───────────────────────┘  │
│                             │         │                             │
│  RTO: 4 hours | RPO: 1 hour │         │  Backup Vault Destination   │
└─────────────────────────────┘         └─────────────────────────────┘
```

## Directory Structure

```
terraform/
├── README.md                    # This file
├── setup/
│   ├── backend/                 # Remote state setup scripts
│   └── secrets/                 # Secrets provisioning (SSM/Secrets Manager)
├── environments/
│   ├── prod/                    # Production (Primary Region)
│   │   ├── main.tf              # Module composition
│   │   ├── variables.tf         # Variable definitions
│   │   ├── outputs.tf           # Output definitions
│   │   ├── providers.tf         # AWS provider configuration
│   │   └── config/              # tfvars by category
│   │       ├── project.tfvars
│   │       ├── networking.tfvars
│   │       ├── compute.tfvars
│   │       ├── database.tfvars
│   │       ├── storage.tfvars
│   │       ├── security.tfvars
│   │       ├── dns.tfvars
│   │       ├── dr.tfvars
│   │       └── monitoring.tfvars
│   ├── test/                    # Test environment (no DR)
│   └── dr/                      # DR region (us-west-2)
└── modules/
    ├── aws/                     # AWS primitive modules
    └── solution/                # Solution-specific compositions
        ├── core/                # VPC + ALB + ASG
        ├── security/            # KMS + WAF + Security Groups
        ├── database/            # Aurora Global Database
        ├── storage/             # S3 with CRR
        ├── dr/                  # Route 53 + Backup + Replication
        └── monitoring/          # CloudWatch Dashboard + Alarms
```

## Configuration

All configuration is derived from `delivery/raw/configuration.csv`. The CSV contains columns for Production, Test, and DR environments.

### Generate tfvars from CSV

```bash
cd /mnt/c/projects/wsl/eof-tools
python automation/scripts/generate-tfvars.py /path/to/solution prod
python automation/scripts/generate-tfvars.py /path/to/solution test
python automation/scripts/generate-tfvars.py /path/to/solution dr
```

## Deployment

### 1. Initialize Backend

```bash
cd setup/backend
./state-backend.sh prod
```

### 2. Deploy Production (Primary Region)

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
terraform plan -var-file=config/project.tfvars \
               -var-file=config/networking.tfvars \
               -var-file=config/compute.tfvars \
               -var-file=config/database.tfvars \
               -var-file=config/storage.tfvars \
               -var-file=config/security.tfvars \
               -var-file=config/dns.tfvars \
               -var-file=config/dr.tfvars \
               -var-file=config/monitoring.tfvars
terraform apply ...
```

### 3. Deploy DR Region

```bash
cd environments/dr
terraform init -backend-config=backend.tfvars
terraform plan ...
terraform apply ...
```

### 4. Update Production with DR Outputs

After DR deployment, update production with DR region resource ARNs for replication.

## DR Operations

### Failover Procedure

1. **Verify Health Check Failure**: Route 53 automatically detects primary unhealthy
2. **DNS Failover**: Traffic routes to DR region ALB
3. **Scale DR ASG**: Increase desired capacity to handle production load
4. **Promote Aurora**: Promote DR cluster to standalone (if needed)

### Failback Procedure

1. **Restore Primary**: Rebuild primary infrastructure
2. **Resync Data**: Re-establish replication from DR to Primary
3. **Test Primary**: Validate primary functionality
4. **DNS Failback**: Update Route 53 to PRIMARY policy

## Environment Differences

| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Region | us-east-1 | us-east-1 | us-west-2 |
| VPC CIDR | 10.0.0.0/16 | 10.100.0.0/16 | 10.1.0.0/16 |
| Instance Type | t3.medium | t3.small | t3.medium |
| ASG Capacity | 2-10 (desired: 3) | 1-4 (desired: 1) | 0-10 (desired: 1) |
| Aurora Instances | 2 | 1 | 2 |
| Aurora Class | db.r6g.large | db.t3.medium | db.r6g.large |
| WAF | Enabled | Disabled | Disabled |
| GuardDuty | Enabled | Disabled | Disabled |
| S3 Replication | Enabled | Disabled | Receives |
| Backup Retention | 30 days | 7 days | 90 days |

## Cost Optimization

- **Pilot Light DR**: DR ASG starts at 0 instances, scales on failover
- **Reserved Instances**: Use RIs for production compute
- **Savings Plans**: Use Compute Savings Plans for DR
- **S3 Lifecycle**: Transition to IA/Glacier for cost savings
- **Aurora Serverless v2**: Consider for variable workloads

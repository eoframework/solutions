# AWS Cloud Migration - Terraform Automation

Infrastructure as Code for AWS on-premises to cloud migration landing zone.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Internet                                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AWS Cloud (us-east-1)                                    │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │                         VPC (10.0.0.0/16)                                │ │
│ │                                                                         │ │
│ │  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐              │ │
│ │  │ Public       │    │ Private      │    │ Database     │              │ │
│ │  │ Subnets      │    │ Subnets      │    │ Subnets      │              │ │
│ │  │              │    │              │    │              │              │ │
│ │  │   WAF+ALB    │───▶│  EC2 ASG     │───▶│  RDS MySQL   │              │ │
│ │  │   NAT GW     │    │  (2-10)      │    │  Multi-AZ    │              │ │
│ │  │              │    │              │    │              │              │ │
│ │  └──────────────┘    └──────────────┘    └──────────────┘              │ │
│ │                              │                                          │ │
│ │                              ▼                                          │ │
│ │                    ┌──────────────────┐                                 │ │
│ │                    │   S3 Bucket      │                                 │ │
│ │                    │   (App Data)     │                                 │ │
│ │                    └──────────────────┘                                 │ │
│ │                                                                         │ │
│ │                    ┌──────────────────┐                                 │ │
│ │                    │   VPN Gateway    │                                 │ │
│ │                    │                  │                                 │ │
│ └─────────────────────────────│─────────────────────────────────────────────┘ │
│                               │                                             │
└───────────────────────────────│─────────────────────────────────────────────┘
                                │
                    Site-to-Site VPN / Direct Connect
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    On-Premises Data Center                                  │
│                    (192.168.0.0/16)                                         │
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │ Web Servers  │    │ App Servers  │    │ Databases    │                  │
│  │ (Source)     │    │ (Source)     │    │ (Source)     │                  │
│  └──────────────┘    └──────────────┘    └──────────────┘                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Migration Strategy

Based on SOW:
- **Rehost (70%)**: Lift-and-shift VMs to EC2
- **Replatform (20%)**: Minor optimizations (e.g., MySQL to RDS)
- **Retain (10%)**: Keep on-premises during transition

## Directory Structure

```
terraform/
├── README.md
├── setup/
│   ├── backend/
│   └── secrets/
├── environments/
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── config/
│   │       ├── project.tfvars
│   │       ├── networking.tfvars
│   │       ├── compute.tfvars
│   │       ├── database.tfvars
│   │       ├── storage.tfvars
│   │       └── security.tfvars
│   └── test/
└── modules/
    └── solution/
        ├── core/         # VPC + ALB + ASG + VPN
        ├── security/     # KMS + WAF + Security Groups
        ├── database/     # RDS Multi-AZ
        ├── storage/      # S3 buckets
        └── monitoring/   # CloudWatch
```

## Configuration

All configuration derived from `delivery/raw/configuration.csv` with Production and Test columns.

### Key Parameters from SOW

| Parameter | Production | Test |
|-----------|------------|------|
| Region | us-east-1 | us-east-1 |
| VPC CIDR | 10.0.0.0/16 | 10.100.0.0/16 |
| On-Prem CIDR | 192.168.0.0/16 | 192.168.0.0/16 |
| Instance Type | t3.medium | t3.small |
| ASG Capacity | 2-10 | 1-4 |
| RDS Class | db.r5.large | db.t3.medium |
| RDS Multi-AZ | Yes | No |

## Deployment

### 1. Initialize Backend

```bash
cd setup/backend
./state-backend.sh prod
```

### 2. Deploy Production

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars

# Plan
terraform plan \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/compute.tfvars \
  -var-file=config/database.tfvars \
  -var-file=config/storage.tfvars \
  -var-file=config/security.tfvars

# Apply
terraform apply ...
```

### 3. Configure VPN

After deployment:
1. Get VPN Gateway ID from outputs
2. Create Customer Gateway in AWS Console
3. Configure on-premises VPN device
4. Test connectivity to VPC

## Migration Phases

### Phase 1: Discovery & Assessment (Months 1-2)
- Deploy landing zone infrastructure
- Configure hybrid connectivity (VPN/Direct Connect)
- Discover on-premises applications

### Phase 2: Migration Execution (Months 3-6)
- **Wave 1**: Non-critical applications
- **Wave 2**: Business-critical applications
- **Wave 3**: Complex/legacy applications

### Phase 3: Optimization (Months 7-9)
- Right-size instances
- Implement Reserved Instances/Savings Plans
- Security hardening

## Environment Differences

| Feature | Production | Test |
|---------|------------|------|
| VPC CIDR | 10.0.0.0/16 | 10.100.0.0/16 |
| Instance Type | t3.medium | t3.small |
| ASG Capacity | 2-10 | 1-4 |
| RDS Class | db.r5.large | db.t3.medium |
| RDS Multi-AZ | Enabled | Disabled |
| WAF | Enabled | Disabled |
| GuardDuty | Enabled | Disabled |
| Flow Logs | Enabled | Disabled |

# Deployment Automation

This folder contains deployment automation for the GCP Landing Zone solution.

```
automation/
└── terraform/           # Terraform approach for GCP
```

## Recommended Approach: Terraform

GCP Landing Zone is best deployed using **Terraform** due to:
- Excellent GCP provider support from HashiCorp
- Cloud Foundation Toolkit (CFT) module compatibility
- Consistent patterns with other cloud landing zones
- Built-in state management with GCS backend
- Plan/apply workflow with change preview

## Folder Structure

```
terraform/
├── setup/
│   ├── backend/         # State bucket and service account setup
│   └── bootstrap/       # Initial organization bootstrap
├── environments/
│   ├── prod/            # Production environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   ├── eo-deploy.sh
│   │   └── config/
│   │       ├── project.tfvars
│   │       ├── organization.tfvars
│   │       ├── networking.tfvars
│   │       ├── security.tfvars
│   │       ├── monitoring.tfvars
│   │       ├── automation.tfvars
│   │       └── dr.tfvars
│   ├── test/            # Test environment (minimal)
│   └── dr/              # Disaster recovery environment
└── modules/
    └── gcp/
        ├── organization/  # Organization policies
        ├── folders/       # Folder hierarchy
        ├── projects/      # Project factory
        ├── vpc/           # Shared VPC network
        ├── kms/           # Cloud KMS encryption
        ├── logging/       # Cloud Logging
        └── monitoring/    # Cloud Monitoring
```

## Getting Started

### Prerequisites

1. GCP Organization with billing enabled
2. Terraform >= 1.6.0 installed
3. gcloud CLI authenticated with Organization Admin role
4. Service account with required permissions

### Deployment Steps

```bash
# 1. Navigate to environment
cd terraform/environments/prod/

# 2. Update configuration
# Edit config/*.tfvars with your values

# 3. Initialize Terraform
./eo-deploy.sh init

# 4. Preview changes
./eo-deploy.sh plan

# 5. Apply deployment
./eo-deploy.sh apply
```

## Environment Comparison

| Feature | Production | Test | DR |
|---------|------------|------|-----|
| Folder Hierarchy | Full | Full | Full |
| Shared VPC | 4 subnets | 4 subnets | 4 subnets |
| Flow Logs | Enabled | Disabled | Enabled |
| Cloud NAT | 3 gateways | 1 gateway | 3 gateways |
| Interconnect | Dedicated 10G | Partner 1G | Dedicated 10G |
| SCC Tier | Premium | Standard | Premium |
| Chronicle | Enabled | Disabled | Enabled |
| Cloud Armor | Enabled | Disabled | Enabled |
| Budget Alerts | Enabled | Disabled | Enabled |

## Configuration Reference

Configuration is loaded from `delivery/raw/configuration.csv` and converted to tfvars files using the EO Framework tooling:

```bash
# Generate tfvars from configuration.csv
python /path/to/eof-tools/automation/scripts/generate-tfvars.py \
  --config ../../../raw/configuration.csv \
  --environment prod \
  --output config/
```

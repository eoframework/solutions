# GCP Landing Zone Terraform Automation

Infrastructure as Code (IaC) for deploying and managing GCP Landing Zone resources using Terraform.

## Overview

This directory contains environment-specific Terraform configurations that share common modules. Each environment is self-contained with its own state, variables, and deployment script.

```
terraform/
├── README.md                 # This file
├── modules/                  # Reusable Terraform modules
│   └── gcp/
│       ├── organization/     # Organization policies, essential contacts
│       ├── folders/          # Folder hierarchy
│       ├── vpc/              # Shared VPC, subnets, NAT, firewall
│       ├── kms/              # Cloud KMS keys
│       ├── logging/          # Cloud Logging sinks, BigQuery/GCS
│       ├── projects/         # Project factory
│       └── iam/              # Custom roles, service accounts
├── setup/
│   └── backend/              # State backend setup scripts
└── environments/
    ├── test/                 # Test environment
    ├── prod/                 # Production environment
    └── dr/                   # Disaster Recovery environment
```

## Prerequisites

### Required Tools

| Tool | Minimum Version | Purpose |
|------|-----------------|---------|
| Terraform | 1.6+ | Infrastructure provisioning |
| gcloud CLI | Latest | GCP authentication and operations |
| Bash | 4.x | Running eo-deploy.sh (Linux/macOS/WSL) |

### GCP Authentication

Configure GCP credentials before running any Terraform commands:

```bash
# Option 1: User credentials (development)
gcloud auth application-default login

# Option 2: Service account key
export GOOGLE_CREDENTIALS="path/to/service-account-key.json"

# Option 3: Workload Identity (CI/CD)
# Automatically uses service account when running in GKE/Cloud Build
```

## Module Structure

### Organization Module
Creates organization-level policies:
- Shielded VM requirement
- Serial port access restriction
- Service account key creation policy
- VM external IP restrictions
- Resource location constraints
- Essential contacts

### Folders Module
Creates folder hierarchy:
- Development folder
- Staging folder
- Production folder
- Shared Services folder
- Sandbox folder (optional)

### VPC Module
Creates Shared VPC architecture:
- VPC network with custom subnets
- Cloud Router for NAT and Interconnect
- Cloud NAT for outbound connectivity
- Baseline firewall rules (deny-all, allow-internal, IAP, health checks)

### KMS Module
Creates Cloud KMS resources:
- Key ring
- Crypto keys (primary, storage, compute, database)
- Key rotation configuration

### Logging Module (New)
Creates centralized logging:
- Organization-wide log sink
- BigQuery dataset or GCS bucket for logs
- Audit log configuration
- Log-based metrics for monitoring

### Projects Module (New)
Creates standardized projects:
- Host project (Shared VPC)
- Logging project
- Security project
- Monitoring project
- Workload projects with API enablement

### IAM Module (New)
Creates IAM resources:
- Custom roles (network viewer, security reviewer, project creator)
- Service accounts for automation
- Workload Identity Pool (optional)
- Group-based IAM bindings

## Quick Start

1. **Set up the state backend:**
   ```bash
   cd setup/backend
   ./state-backend.sh
   ```

2. **Navigate to the target environment:**
   ```bash
   cd environments/prod   # or test, dr
   ```

3. **Initialize Terraform:**
   ```bash
   ./eo-deploy.sh init
   ```

4. **Review the execution plan:**
   ```bash
   ./eo-deploy.sh plan
   ```

5. **Apply the configuration:**
   ```bash
   ./eo-deploy.sh apply
   ```

## Environment Comparison

| Aspect | Test | Prod | DR |
|--------|------|------|-----|
| Organization policies | Relaxed | Full enforcement | Full enforcement |
| VPC subnets | Dev only | All environments | Mirrors prod |
| KMS keys | Reduced set | Full key set | Cross-region |
| Logging | Basic | BigQuery + GCS | BigQuery + GCS |
| Budget alerts | Low threshold | Production budget | DR budget |
| Monitoring | Minimal | Comprehensive | Comprehensive |

## Configuration Files

Configuration is split into modular `.tfvars` files in the `config/` directory:

| File | Purpose |
|------|---------|
| `project.tfvars` | Solution identity, GCP project, ownership |
| `organization.tfvars` | Org ID, domain, billing account |
| `folders.tfvars` | Folder display names |
| `projects.tfvars` | Project names and counts |
| `network.tfvars` | VPC, subnets, NAT configuration |
| `security.tfvars` | SCC, Chronicle, Cloud Armor settings |
| `logging.tfvars` | Log sink, retention configuration |
| `monitoring.tfvars` | Dashboard, alerts, uptime checks |
| `budget.tfvars` | Budget amount and thresholds |
| `dr.tfvars` | Disaster recovery settings |

## Required GCP APIs

The following APIs must be enabled in your project:

```bash
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  compute.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  cloudkms.googleapis.com \
  cloudbilling.googleapis.com \
  billingbudgets.googleapis.com \
  securitycenter.googleapis.com
```

## Best Practices

1. **Always run `plan` before `apply`** - Review changes before applying
2. **Use version control** - Commit configuration changes before applying
3. **Environment isolation** - Each environment has separate state
4. **Least privilege** - Use minimal IAM permissions
5. **State locking** - GCS provides native state locking

## Troubleshooting

### State lock error
```bash
# If a previous run was interrupted
terraform force-unlock <lock-id>
```

### Authentication error
```bash
# Verify GCP credentials
gcloud auth print-access-token
```

### Module not found
```bash
# Re-initialize to download modules
./eo-deploy.sh init -upgrade
```

## Related Documentation

- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GCP Landing Zone Best Practices](https://cloud.google.com/architecture/landing-zones)
- [Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit)

# Azure Virtual Desktop - Terraform Infrastructure

Enterprise-grade Azure Virtual Desktop (AVD) deployment with terraform automation.

## Architecture Overview

This solution deploys a complete AVD environment with:

- **Host Pools**: Pooled or personal desktop configurations
- **Session Hosts**: Windows 11 multi-session VMs with auto-scaling
- **FSLogix Profiles**: Azure Files storage for user profile management
- **Application Groups**: Desktop and RemoteApp delivery
- **Azure AD Integration**: Native Azure AD join for session hosts
- **Monitoring**: Azure Monitor, Log Analytics, and Application Insights
- **Security**: Private endpoints, managed identities, Key Vault integration
- **Disaster Recovery**: Cross-region replication for business continuity

## Directory Structure

```
terraform/
├── environments/          # Environment-specific configurations
│   ├── prod/             # Production environment
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── providers.tf
│   │   ├── outputs.tf
│   │   └── config/       # Configuration files
│   │       ├── project.tfvars
│   │       ├── networking.tfvars
│   │       ├── security.tfvars
│   │       ├── storage.tfvars
│   │       ├── avd.tfvars
│   │       ├── application.tfvars
│   │       ├── monitoring.tfvars
│   │       ├── best-practices.tfvars
│   │       └── dr.tfvars
│   ├── test/             # Test environment
│   └── dr/               # Disaster recovery environment
├── modules/              # Reusable terraform modules
│   └── solution/         # Solution-specific modules
│       ├── core/         # Resource group, VNet, Key Vault
│       ├── avd/          # Host pools, workspaces, session hosts
│       ├── storage/      # Azure Files for FSLogix
│       ├── security/     # Managed identities, RBAC
│       ├── monitoring/   # Log Analytics, App Insights, alerts
│       ├── best-practices/ # Backup, budgets, policies
│       └── dr/           # Disaster recovery resources
└── setup/                # Setup scripts
    └── backend/          # Terraform state backend setup
        ├── state-backend.sh
        └── README.md
```

## Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.6.0
- Azure subscription with appropriate permissions
- Azure AD tenant with required groups configured

## Quick Start

### 1. Set Up Backend Storage

First, create the Azure Storage backend for Terraform state:

```bash
cd setup/backend
./state-backend.sh prod
```

This creates:
- Resource group for Terraform state
- Storage account with encryption
- Blob container for state files
- `backend.tfvars` configuration file

### 2. Configure Variables

Update the configuration files in `environments/prod/config/`:

```bash
cd environments/prod/config
```

Edit the following files with your values:
- `project.tfvars` - Azure subscription, tenant, region
- `security.tfvars` - Azure AD group IDs
- `networking.tfvars` - Network CIDRs
- `storage.tfvars` - FSLogix storage settings
- `avd.tfvars` - Session host and scaling configuration
- `monitoring.tfvars` - Alert email addresses
- `best-practices.tfvars` - Budget settings

### 3. Initialize Terraform

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
```

### 4. Plan Deployment

```bash
terraform plan \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/storage.tfvars \
  -var-file=config/avd.tfvars \
  -var-file=config/application.tfvars \
  -var-file=config/monitoring.tfvars \
  -var-file=config/best-practices.tfvars \
  -var-file=config/dr.tfvars
```

### 5. Deploy Infrastructure

```bash
terraform apply \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/storage.tfvars \
  -var-file=config/avd.tfvars \
  -var-file=config/application.tfvars \
  -var-file=config/monitoring.tfvars \
  -var-file=config/best-practices.tfvars \
  -var-file=config/dr.tfvars
```

## Module Architecture

### Core Module
- Resource Group
- Virtual Network with subnets
- Key Vault for secrets
- Network security groups

### AVD Module
- Host Pool (pooled or personal)
- Desktop Application Group
- RemoteApp Application Group
- AVD Workspace
- Session Host VMs with extensions:
  - Azure AD Join
  - AVD Agent
  - FSLogix Configuration
- Auto-scaling Plan

### Storage Module
- Premium FileStorage account
- File share for FSLogix profiles
- Private endpoint (optional)
- SMB multichannel support

### Security Module
- User-assigned managed identity
- RBAC role assignments
- Customer-managed encryption keys (optional)

### Monitoring Module
- Log Analytics Workspace
- Application Insights
- Diagnostic settings
- Metric alerts
- Azure Workbooks

### Best Practices Module
- Recovery Services Vault
- VM backup policies
- Budget alerts
- Azure Policy assignments

### DR Module
- DR resource group
- Cross-region storage replication
- Failover configuration

## Configuration Files

Each environment has separate configuration files organized by category:

- **project.tfvars**: Solution metadata, subscription, tenant
- **networking.tfvars**: VNet, subnet CIDRs, private endpoints
- **security.tfvars**: Azure AD groups, encryption settings
- **storage.tfvars**: FSLogix storage tier, replication, quotas
- **avd.tfvars**: Host pool, session hosts, auto-scaling
- **application.tfvars**: Environment, logging
- **monitoring.tfvars**: Alerts, retention, dashboard
- **best-practices.tfvars**: Backup, budget, policies
- **dr.tfvars**: Disaster recovery settings

## Auto-Scaling

The solution includes intelligent auto-scaling with time-based schedules:

- **Ramp Up** (7:00 AM): Increase capacity for morning logons
- **Peak Hours** (9:00 AM - 5:00 PM): Full capacity during business hours
- **Ramp Down** (5:00 PM): Gradually reduce capacity
- **Off-Peak** (7:00 PM+): Minimal capacity for after-hours usage

Configure scaling thresholds and times in `avd.tfvars`.

## FSLogix Profiles

User profiles are stored on Azure Files with:

- Premium or Standard tier storage
- Zone-redundant storage (ZRS) for high availability
- Large file share support (up to 100 TiB)
- SMB multichannel for improved performance
- Azure AD DS authentication

## Security Features

- **Azure AD Join**: Native Azure AD integration for session hosts
- **Managed Identity**: Passwordless authentication for Azure resources
- **Private Endpoints**: Secure, private connectivity to PaaS services
- **Key Vault**: Centralized secrets management
- **Customer-Managed Keys**: Optional encryption key management
- **RBAC**: Granular role-based access control

## Monitoring & Alerts

Built-in monitoring includes:

- **Session Host Health**: Availability and health check failures
- **Host Pool Capacity**: Connection success rates and capacity
- **Storage Performance**: Latency and throughput metrics
- **Cost Management**: Budget alerts at configurable thresholds
- **Diagnostic Logs**: Comprehensive logging to Log Analytics

## Disaster Recovery

Optional DR configuration provides:

- Cross-region resource deployment
- Storage account replication
- Automated failover capabilities
- Independent DR environment for testing

## Validation

Validate the terraform configuration:

```bash
cd environments/prod
terraform init -backend=false
terraform validate
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/storage.tfvars \
  -var-file=config/avd.tfvars \
  -var-file=config/application.tfvars \
  -var-file=config/monitoring.tfvars \
  -var-file=config/best-practices.tfvars \
  -var-file=config/dr.tfvars
```

## Cost Optimization

Recommendations for cost optimization:

1. Use **Standard tier** storage for non-production environments
2. Enable **auto-scaling** to match capacity with demand
3. Configure **off-peak hours** to minimize running VMs
4. Use **Reserved Instances** for predictable workloads
5. Monitor **budget alerts** to prevent overspending
6. Right-size **VM SKUs** based on usage patterns

## Support

For issues or questions:
- Review the configuration.csv for parameter documentation
- Check Azure Monitor for deployment errors
- Review Terraform state for resource status
- Consult Azure Virtual Desktop documentation

## Version Information

- Terraform: >= 1.6.0
- AzureRM Provider: ~> 3.80
- AzureAD Provider: ~> 2.45

# Azure Virtual WAN Global - Terraform Infrastructure

This directory contains Terraform infrastructure-as-code for deploying Azure Virtual WAN Global networking solution across multiple regions.

## Solution Overview

Azure Virtual WAN Global provides:
- **Global Network Hub**: Virtual WAN with multi-region hubs
- **VPN Connectivity**: Site-to-Site VPN gateways for branch connectivity
- **ExpressRoute Integration**: ExpressRoute gateways for dedicated connectivity
- **Security**: Azure Firewall with threat intelligence and policies
- **Monitoring**: Log Analytics, Network Watcher, and alerting

## Directory Structure

```
terraform/
├── environments/          # Environment-specific configurations
│   ├── prod/             # Production environment
│   │   ├── main.tf       # Main infrastructure orchestration
│   │   ├── variables.tf  # Variable definitions
│   │   ├── outputs.tf    # Output values
│   │   ├── providers.tf  # Provider configuration
│   │   └── config/       # Environment configuration files
│   │       ├── project.tfvars
│   │       ├── vwan.tfvars
│   │       ├── connectivity.tfvars
│   │       ├── security.tfvars
│   │       └── monitoring.tfvars
│   ├── test/             # Test environment
│   └── dr/               # Disaster recovery environment
│
├── modules/              # Reusable Terraform modules
│   ├── azure/           # Azure resource modules
│   │   ├── virtual-wan/
│   │   ├── virtual-hub/
│   │   ├── vpn-gateway/
│   │   ├── expressroute-gateway/
│   │   └── firewall/
│   └── solution/        # Solution-level modules
│       ├── core/        # VWAN + Hubs
│       ├── connectivity/# VPN + ExpressRoute
│       ├── security/    # Firewall + Policies
│       └── monitoring/  # Observability
│
└── setup/               # Setup and initialization
    └── backend/         # Terraform state backend setup
```

## Prerequisites

1. **Azure CLI** (version 2.40.0 or higher)
   ```bash
   az --version
   az login
   ```

2. **Terraform** (version 1.6.0 or higher)
   ```bash
   terraform --version
   ```

3. **Azure Permissions**
   - Contributor or Owner role on the subscription
   - Ability to create resource groups, Virtual WAN, and network resources

## Deployment Guide

### Step 1: Set Up Terraform Backend

First, create the Azure Storage backend for Terraform state:

```bash
cd setup/backend
./state-backend.sh prod  # or test, dr
```

This creates:
- Resource group for state storage
- Storage account with encryption
- Blob container for state files
- Backend configuration file

### Step 2: Configure Environment Variables

Navigate to the environment directory and update configuration files:

```bash
cd ../../environments/prod/config
```

Edit the following files with your values:
- `project.tfvars` - Subscription ID, Tenant ID, regions
- `vwan.tfvars` - Virtual WAN settings
- `connectivity.tfvars` - VPN and ExpressRoute settings
- `security.tfvars` - Firewall rules and policies
- `monitoring.tfvars` - Log Analytics and alerting

### Step 3: Initialize Terraform

```bash
cd ..  # Back to prod directory
terraform init -backend-config=backend.tfvars
```

### Step 4: Plan the Deployment

```bash
terraform plan \
  -var-file=config/project.tfvars \
  -var-file=config/vwan.tfvars \
  -var-file=config/connectivity.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/monitoring.tfvars \
  -out=tfplan
```

### Step 5: Apply the Configuration

```bash
terraform apply tfplan
```

## Environment Configurations

### Production Environment

- **Primary Region**: East US
- **Secondary Region**: West US 2
- **Features**:
  - Dual-hub deployment
  - VPN Gateway (2 scale units)
  - ExpressRoute Gateway (2 scale units)
  - Azure Firewall (Standard tier)
  - Full monitoring and alerting

### Test Environment

- **Primary Region**: East US
- **Secondary Region**: None (single hub)
- **Features**:
  - Single-hub deployment
  - VPN Gateway (1 scale unit)
  - No ExpressRoute
  - No Firewall (cost optimization)
  - Basic monitoring

### DR Environment

- **Primary Region**: West US 2
- **Secondary Region**: East US
- **Features**:
  - Dual-hub deployment (reversed regions)
  - VPN Gateway (1 scale unit)
  - ExpressRoute Gateway (1 scale unit)
  - Azure Firewall (Standard tier)
  - Full monitoring and alerting

## Key Resources Created

### Core Infrastructure
- Virtual WAN (Standard SKU)
- Virtual Hubs (primary and secondary regions)
- Resource Groups
- Route Tables

### Connectivity
- VPN Gateways (S2S and P2S)
- ExpressRoute Gateways
- BGP configurations

### Security
- Azure Firewall instances
- Firewall Policies
- Network Rules
- Application Rules
- Threat Intelligence

### Monitoring
- Log Analytics Workspace
- Network Watcher
- Diagnostic Settings
- Metric Alerts
- Action Groups

## Outputs

After deployment, Terraform provides:
- Virtual WAN ID and name
- Hub IDs and names
- Gateway endpoints
- Firewall private IPs
- Log Analytics workspace details

Access outputs:
```bash
terraform output
terraform output -json > outputs.json
```

## Maintenance Operations

### Update Configuration

1. Modify tfvars files
2. Run plan to review changes
3. Apply changes

```bash
terraform plan -var-file=config/...
terraform apply -var-file=config/...
```

### Add Firewall Rules

1. Edit `config/security.tfvars`
2. Add rules to `network_rule_collections` or `application_rule_collections`
3. Apply changes

### Scale Gateways

1. Edit `config/connectivity.tfvars`
2. Update scale_unit values
3. Apply changes

## Disaster Recovery

### DR Failover Process

1. Verify DR environment is deployed and healthy
2. Update DNS records to point to DR region
3. Verify connectivity through DR hub
4. Monitor traffic flow through DR firewall

### Failback Process

1. Ensure production environment is restored
2. Synchronize any configuration changes
3. Update DNS records back to production
4. Verify connectivity through production hub

## Cost Optimization

### Production Costs (Approximate Monthly)
- Virtual WAN Standard: $0.25/hour per hub = ~$360/month (2 hubs)
- VPN Gateway: ~$300/month per gateway (2 gateways)
- ExpressRoute Gateway: ~$200/month per gateway (2 gateways)
- Azure Firewall: ~$1.25/hour = ~$900/month (2 firewalls)
- Log Analytics: Based on ingestion volume
- **Total**: ~$2,100-2,500/month

### Test Environment Costs
- Single hub, no firewall, minimal gateways
- **Total**: ~$400-500/month

### Cost Reduction Tips
- Use Basic tier for test environments
- Disable unused gateways
- Adjust scale units based on actual traffic
- Set log retention to minimum required
- Use reserved instances for predictable workloads

## Troubleshooting

### Common Issues

**Issue**: Terraform init fails
- **Solution**: Check Azure CLI authentication (`az account show`)

**Issue**: Backend not found
- **Solution**: Run `setup/backend/state-backend.sh` first

**Issue**: Insufficient permissions
- **Solution**: Verify you have Contributor role on subscription

**Issue**: Resource naming conflicts
- **Solution**: Update `solution.abbr` in project.tfvars

**Issue**: Validation errors
- **Solution**: Run `terraform validate` to see specific errors

### Debug Mode

Enable detailed logging:
```bash
export TF_LOG=DEBUG
terraform plan ...
```

## Security Considerations

1. **State File Security**
   - State files contain sensitive data
   - Use Azure Storage with encryption
   - Enable soft delete on storage account
   - Restrict access with RBAC

2. **Secrets Management**
   - Never commit secrets to version control
   - Use Azure Key Vault for sensitive values
   - Use service principals with minimal permissions

3. **Network Security**
   - Enable firewall policies
   - Configure threat intelligence
   - Use private endpoints where possible
   - Regularly review firewall rules

4. **Monitoring**
   - Enable diagnostic logging
   - Set up security alerts
   - Monitor threat intelligence hits
   - Review access logs regularly

## Support and Documentation

- [Azure Virtual WAN Documentation](https://docs.microsoft.com/azure/virtual-wan/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Firewall Documentation](https://docs.microsoft.com/azure/firewall/)

## License

Copyright (c) 2025. All rights reserved.

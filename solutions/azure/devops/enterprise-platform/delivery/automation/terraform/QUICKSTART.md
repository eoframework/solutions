# Azure DevOps Enterprise Platform - Quick Start Guide

## Prerequisites

1. **Terraform** installed (v1.5+)
2. **Azure CLI** installed and authenticated
3. **Permissions**: Subscription Contributor or Owner
4. **Azure DevOps**: Organization admin access

## Quick Deployment Steps

### 1. Navigate to Environment

```bash
cd delivery/automation/terraform/environments/prod
```

### 2. Update Configuration

Edit configuration values in `../../../raw/configuration.csv` then regenerate tfvars:

```bash
# From solution root
python /path/to/eof-tools/automation/scripts/generate-tfvars.py .
```

Or manually edit config files:

```bash
# Edit project configuration
nano config/project.tfvars

# Replace placeholder values:
# - [SUBSCRIPTION_ID]
# - [TENANT_ID]
# - [ADMIN_GROUP_ID]
# - [USER_GROUP_ID]
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Review

```bash
terraform plan -var-file="config/project.tfvars" \
  -var-file="config/networking.tfvars" \
  -var-file="config/acr.tfvars" \
  -var-file="config/aks.tfvars" \
  -var-file="config/platform.tfvars" \
  -var-file="config/security.tfvars" \
  -var-file="config/monitoring.tfvars" \
  -var-file="config/best-practices.tfvars" \
  -var-file="config/dr.tfvars"
```

### 5. Deploy to Test First

```bash
cd ../test
terraform init && terraform apply -auto-approve ...
```

### 6. Deploy to Production

```bash
cd ../prod
terraform apply -auto-approve -var-file="config/project.tfvars" ...
```

## Environment Configurations

| Component | Production | Test | DR |
|-----------|-----------|------|-----|
| Region | East US | East US | West US 2 |
| AKS Nodes | 5 | 3 | 3 |
| AKS Size | D4s_v3 | D2s_v3 | D4s_v3 |
| ACR SKU | Premium | Standard | Premium |
| Geo-Replication | Enabled | Disabled | Enabled |
| Private Endpoints | Enabled | Disabled | Enabled |
| Log Retention | 90 days | 30 days | 90 days |
| Parallel Jobs | 10 hosted | 5 hosted | 5 hosted |

## Post-Deployment Tasks

### 1. Verify Resources

```bash
# Check resource group
az group show --name <resource-group-name>

# Check AKS cluster
az aks show --resource-group <rg> --name <aks-name>

# Check Container Registry
az acr show --resource-group <rg> --name <acr-name>
```

### 2. Configure Azure DevOps

```bash
# Login to Azure DevOps
az devops configure --defaults organization=https://dev.azure.com/<org>

# Create service connection
az devops service-endpoint azurerm create \
  --name "azure-production" \
  --azure-rm-subscription-id <subscription-id> \
  --azure-rm-tenant-id <tenant-id>
```

### 3. Connect AKS to ACR

```bash
az aks update -n <aks-name> -g <rg-name> --attach-acr <acr-name>
```

## Common Issues

### Issue: Terraform Init Fails

```bash
# Clear cache and re-init
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade
```

### Issue: AKS Creation Timeout

AKS clusters can take 10-15 minutes. Monitor in Azure Portal.

### Issue: ACR Geo-Replication Fails

Ensure Premium SKU is selected for geo-replication support.

## Support

- Review README.md for detailed documentation
- Check Azure DevOps docs: https://docs.microsoft.com/azure/devops/
- Contact: devops-team@company.com

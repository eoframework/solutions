# Azure Virtual Desktop - Quick Start Guide

## Prerequisites

1. **Terraform** installed (v1.5+)
2. **Azure CLI** installed and authenticated
3. **Permissions**: Subscription Contributor or Owner
4. **Azure AD**: User and Admin group object IDs
5. **Windows License**: Valid M365 E3/E5 or Windows 10/11 Enterprise license

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
  -var-file="config/avd.tfvars" \
  -var-file="config/sessionhost.tfvars" \
  -var-file="config/storage.tfvars" \
  -var-file="config/autoscale.tfvars" \
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
terraform apply -auto-approve ...
```

## Environment Configurations

| Component | Production | Test | DR |
|-----------|-----------|------|-----|
| Region | East US | East US | West US 2 |
| Session Hosts | 3 | 1 | 2 |
| VM Size | D4s_v5 | D2s_v5 | D4s_v5 |
| Storage Tier | Premium | Standard | Premium |
| FSLogix Quota | 5TB | 1TB | 5TB |
| Max Sessions | 10/host | 5/host | 10/host |
| Auto-Scale | Enabled | Disabled | Enabled |
| Private Endpoints | Enabled | Disabled | Enabled |

## Post-Deployment Tasks

### 1. Verify Resources

```bash
# Check host pool
az desktopvirtualization hostpool show \
  --resource-group <rg> --name <hostpool-name>

# Check session hosts
az desktopvirtualization sessionhost list \
  --resource-group <rg> --host-pool-name <hostpool-name>

# Check app groups
az desktopvirtualization applicationgroup list \
  --resource-group <rg>
```

### 2. Assign Users

```bash
# Assign Azure AD group to desktop app group
az role assignment create \
  --assignee-object-id <user-group-id> \
  --role "Desktop Virtualization User" \
  --scope <app-group-resource-id>
```

### 3. Configure FSLogix

Session hosts are pre-configured with FSLogix. Verify profile container:

```bash
# Check Azure Files share
az storage share show --name profiles --account-name <storage-account>
```

### 4. Access Virtual Desktop

1. Open https://rdweb.wvd.microsoft.com/arm/webclient
2. Sign in with Azure AD credentials
3. Launch desktop or RemoteApp

## Common Issues

### Issue: Session Host Registration Fails

```bash
# Check registration token
az desktopvirtualization hostpool show \
  --name <hostpool> --resource-group <rg> \
  --query registrationInfo.token
```

### Issue: FSLogix Profile Mount Fails

Check storage account network rules and private endpoint configuration.

### Issue: Autoscale Not Working

Ensure managed identity has Virtual Machine Contributor role.

## Support

- Review README.md for detailed documentation
- AVD docs: https://docs.microsoft.com/azure/virtual-desktop/
- Contact: workspace-team@company.com

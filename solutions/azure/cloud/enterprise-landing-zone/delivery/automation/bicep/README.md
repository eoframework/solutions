# Azure Enterprise Landing Zone - Bicep Automation

This directory contains Bicep templates and automation scripts for deploying Azure Enterprise Landing Zone infrastructure following Microsoft's Cloud Adoption Framework and Landing Zone best practices.

## Directory Structure

```
bicep/
├── main.bicep                          # Main orchestration template
├── modules/                            # Modular Bicep templates
│   ├── management-group/              # Management group hierarchy
│   ├── policy/                        # Azure Policy assignments
│   ├── networking/                    # Hub-spoke networking
│   ├── identity/                      # Identity and Key Vault
│   ├── logging/                       # Log Analytics and Sentinel
│   └── security-center/               # Defender for Cloud
├── parameters/                         # Environment-specific parameters
│   ├── prod.parameters.json           # Production configuration
│   ├── test.parameters.json           # Test configuration
│   └── dr.parameters.json             # DR configuration
└── scripts/                           # Deployment automation
    ├── deploy.sh                      # Main deployment script
    └── validate.sh                    # Template validation script
```

## Components

### Management Group Hierarchy
- Root Management Group
- Platform Management Group (shared services)
- Landing Zones Management Group (workload subscriptions)
- Corp Management Group (internal workloads)
- Online Management Group (public-facing workloads)
- Sandbox Management Group (development/testing)
- Decommissioned Management Group (retired subscriptions)

### Azure Policy Framework
- Azure Security Benchmark initiative
- Security baseline policies
- Network security controls
- Tagging and governance policies
- Monitoring and diagnostics policies
- Location restrictions
- Cost management policies
- Backup and DR policies

### Hub-Spoke Networking
- Primary hub VNet with Azure Firewall
- Secondary hub VNet for DR
- VPN Gateway for site-to-site connectivity
- ExpressRoute Gateway for dedicated connectivity
- Azure Bastion for secure VM access
- Network Security Groups (NSGs)
- DDoS Protection Standard

### Identity and Access
- Azure Key Vault for secrets management
- User-assigned Managed Identities
- RBAC role assignments
- Azure AD integration
- Conditional Access (production)
- Privileged Identity Management (production)

### Logging and Monitoring
- Log Analytics workspace
- Azure Sentinel (SIEM)
- Diagnostic settings for all resources
- Security alerts and analytics rules
- Data connectors (Activity, AAD, ASC, MCAS)

### Security Center
- Microsoft Defender for Cloud
- Defender plans for VMs, App Service, SQL, Storage, Containers, Key Vault, ARM, DNS
- Security policies and assessments
- Security contacts and alert notifications

## Prerequisites

1. **Azure CLI** - Install from https://docs.microsoft.com/cli/azure/install-azure-cli
   ```bash
   az version
   ```

2. **Bicep CLI** - Installed automatically with Azure CLI 2.20.0+
   ```bash
   az bicep install
   az bicep version
   ```

3. **Azure Permissions**
   - Management Group Contributor or Owner at root management group
   - Subscription Owner on connectivity, identity, and management subscriptions
   - Azure AD permissions for role assignments

4. **Required Information**
   - Azure subscription IDs (connectivity, identity, management)
   - Azure AD tenant ID
   - Azure AD admin group object ID
   - Azure AD reader group object ID
   - Alert email addresses

## Configuration

### 1. Update Parameter Files

Edit the parameter files for each environment:

**Production** (`parameters/prod.parameters.json`):
```json
{
  "subscriptionIdConnectivity": { "value": "YOUR_CONNECTIVITY_SUB_ID" },
  "subscriptionIdIdentity": { "value": "YOUR_IDENTITY_SUB_ID" },
  "subscriptionIdManagement": { "value": "YOUR_MANAGEMENT_SUB_ID" },
  "managementGroupRoot": { "value": "YOUR_TENANT_ROOT_GROUP" },
  "azureAdAdminGroup": { "value": "YOUR_ADMIN_GROUP_OBJECT_ID" },
  "azureAdReaderGroup": { "value": "YOUR_READER_GROUP_OBJECT_ID" },
  "alertEmail": { "value": "security-alerts@company.com" }
}
```

**Test** (`parameters/test.parameters.json`):
- Lower SKUs and capacity for cost optimization
- Disabled DDoS Protection
- Shorter log retention (30 days)

**DR** (`parameters/dr.parameters.json`):
- Different IP address ranges
- DR region as primary location
- Production-level settings

### 2. Replace Placeholder Values

Search for `REPLACE_WITH_` in parameter files and replace with actual values:
```bash
grep -r "REPLACE_WITH_" parameters/
```

## Deployment

### Validation Only

Validate templates before deployment:
```bash
./scripts/validate.sh           # Validate all environments
./scripts/validate.sh prod      # Validate production only
```

### What-If Analysis

Preview changes without deploying:
```bash
./scripts/deploy.sh prod --what-if
```

### Deploy Environment

Deploy to specific environment:
```bash
# Production
./scripts/deploy.sh prod

# Test
./scripts/deploy.sh test

# DR
./scripts/deploy.sh dr
```

### Manual Deployment

Use Azure CLI directly:
```bash
# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>

# Deploy to management group
az deployment mg create \
  --name "alz-deployment-$(date +%Y%m%d-%H%M%S)" \
  --management-group-id <management-group-id> \
  --location eastus \
  --template-file main.bicep \
  --parameters @parameters/prod.parameters.json \
  --verbose
```

## Environment Configurations

### Production
- **Regions**: East US (primary), West US 2 (secondary)
- **Firewall**: Premium SKU with TLS inspection
- **ExpressRoute**: 1 Gbps bandwidth
- **DDoS Protection**: Enabled
- **Key Vault**: Purge protection enabled
- **Defender for Cloud**: Standard tier
- **Log Retention**: 90 days
- **Conditional Access**: Enabled
- **PIM**: Enabled

### Test
- **Regions**: East US (primary), West US 2 (secondary)
- **Firewall**: Standard SKU
- **ExpressRoute**: 500 Mbps bandwidth
- **DDoS Protection**: Disabled (cost savings)
- **Key Vault**: Standard tier
- **Defender for Cloud**: Free tier
- **Log Retention**: 30 days
- **Conditional Access**: Disabled
- **PIM**: Disabled

### Disaster Recovery
- **Regions**: West US 2 (primary), Central US (secondary)
- **Firewall**: Premium SKU
- **ExpressRoute**: 1 Gbps bandwidth
- **DDoS Protection**: Enabled
- **Settings**: Mirror production configuration

## Post-Deployment

### Verify Deployment

1. **Check Management Groups**:
   ```bash
   az account management-group list --query "[].{Name:name, DisplayName:displayName}" -o table
   ```

2. **Check Policy Assignments**:
   ```bash
   az policy assignment list --disable-scope-strict-match -o table
   ```

3. **Check Hub Networks**:
   ```bash
   az network vnet list --query "[?contains(name,'hub')].{Name:name,Location:location,AddressSpace:addressSpace.addressPrefixes[0]}" -o table
   ```

4. **Check Firewall**:
   ```bash
   az network firewall list -o table
   ```

5. **Check Log Analytics**:
   ```bash
   az monitor log-analytics workspace list -o table
   ```

### Connect ExpressRoute Circuit

After deployment, complete ExpressRoute setup:
```bash
# Get service key
az network express-route show --resource-group <rg-name> --name <circuit-name> --query serviceKey -o tsv

# Provide service key to carrier
# Wait for carrier to provision circuit

# Create connection
az network vpn-connection create \
  --name <connection-name> \
  --resource-group <rg-name> \
  --vnet-gateway1 <gateway-name> \
  --express-route-circuit2 <circuit-id> \
  --location <location>
```

### Configure VPN Gateway

Set up site-to-site VPN:
```bash
# Create local network gateway
az network local-gateway create \
  --resource-group <rg-name> \
  --name <local-gw-name> \
  --gateway-ip-address <on-prem-ip> \
  --local-address-prefixes <on-prem-cidr>

# Create VPN connection
az network vpn-connection create \
  --resource-group <rg-name> \
  --name <connection-name> \
  --vnet-gateway1 <vpn-gateway-name> \
  --local-gateway2 <local-gw-name> \
  --shared-key <pre-shared-key>
```

## Troubleshooting

### Common Issues

1. **Insufficient Permissions**:
   - Ensure you have Owner or Contributor role at management group level
   - Verify Azure AD permissions for role assignments

2. **Parameter Validation Errors**:
   - Check all placeholder values are replaced
   - Verify subscription IDs are valid GUIDs
   - Confirm management group IDs exist

3. **Bicep Build Errors**:
   - Update Bicep CLI: `az bicep upgrade`
   - Check syntax: `az bicep build --file main.bicep`

4. **Deployment Timeout**:
   - Gateway deployments can take 30-45 minutes
   - Monitor in Azure Portal: Deployments section

5. **Policy Assignment Failures**:
   - Some policies require specific Azure AD permissions
   - Check policy definition IDs are correct for your Azure region

### View Deployment Logs

```bash
# List recent deployments
az deployment mg list --management-group-id <mg-id> -o table

# Show deployment details
az deployment mg show \
  --name <deployment-name> \
  --management-group-id <mg-id>

# View deployment operations
az deployment mg operation list \
  --name <deployment-name> \
  --management-group-id <mg-id>
```

### Clean Up Resources

To remove deployed resources:
```bash
# Delete resource groups
az group delete --name <rg-name> --yes --no-wait

# Remove policy assignments
az policy assignment delete --name <assignment-name>

# Delete management groups (requires removing subscriptions first)
az account management-group delete --name <mg-name>
```

## Best Practices

1. **Testing**: Always deploy to test environment first
2. **What-If**: Run what-if analysis before production deployments
3. **Validation**: Validate templates after any changes
4. **Version Control**: Commit parameter file changes with descriptive messages
5. **Documentation**: Update this README when adding new modules
6. **Security**: Never commit secrets or credentials to Git
7. **Monitoring**: Set up alerts for failed deployments
8. **Backups**: Export ARM templates before major changes

## Module Development

To add a new module:

1. Create module directory: `modules/<module-name>/`
2. Create Bicep template: `modules/<module-name>/<module-name>.bicep`
3. Add parameters and outputs
4. Reference in `main.bicep`
5. Update parameter files
6. Test with validation script
7. Update this README

## Support

For issues or questions:
- Review Azure Landing Zone documentation: https://aka.ms/alz
- Check Bicep documentation: https://aka.ms/bicep
- Contact platform team: platform-team@company.com

## Version History

- **v1.0.0** (2025-01-03): Initial Bicep implementation
  - Management group hierarchy
  - Azure Policy assignments
  - Hub-spoke networking
  - Identity and Key Vault
  - Logging and Sentinel
  - Microsoft Defender for Cloud

## License

Copyright (c) 2025 - Internal Use Only

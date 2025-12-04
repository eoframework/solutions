# Azure Enterprise Landing Zone - Quick Start Guide

## Prerequisites

1. **Azure CLI** installed
2. **Bicep CLI** installed (comes with Azure CLI 2.20.0+)
3. **Permissions**: Management Group Contributor or Owner
4. **Azure AD**: Admin group and Reader group object IDs

## Quick Deployment Steps

### 1. Update Parameter Files

Edit the parameter files and replace placeholder values:

```bash
cd parameters/

# Edit production parameters
nano prod.parameters.json

# Replace these values:
# - REPLACE_WITH_CONNECTIVITY_SUBSCRIPTION_ID
# - REPLACE_WITH_IDENTITY_SUBSCRIPTION_ID
# - REPLACE_WITH_MANAGEMENT_SUBSCRIPTION_ID
# - REPLACE_WITH_TENANT_ROOT_GROUP
# - REPLACE_WITH_ADMIN_GROUP_ID
# - REPLACE_WITH_READER_GROUP_ID
```

### 2. Validate Templates

```bash
# From the bicep directory
./scripts/validate.sh
```

### 3. Run What-If Analysis

```bash
# Preview changes before deployment
./scripts/deploy.sh prod --what-if
```

### 4. Deploy to Test Environment First

```bash
# Deploy to test environment
./scripts/deploy.sh test
```

### 5. Deploy to Production

```bash
# Deploy to production
./scripts/deploy.sh prod
```

### 6. Deploy to DR

```bash
# Deploy to disaster recovery
./scripts/deploy.sh dr
```

## Environment Configurations

| Component | Production | Test | DR |
|-----------|-----------|------|-----|
| Primary Region | East US | East US | West US 2 |
| Secondary Region | West US 2 | West US 2 | Central US |
| Firewall SKU | Premium | Standard | Premium |
| ExpressRoute BW | 1 Gbps | 500 Mbps | 1 Gbps |
| DDoS Protection | Enabled | Disabled | Enabled |
| Defender Tier | Standard | Free | Standard |
| Log Retention | 90 days | 30 days | 90 days |
| Conditional Access | Enabled | Disabled | Enabled |
| PIM | Enabled | Disabled | Enabled |

## Post-Deployment Tasks

### 1. Verify Deployment

```bash
# Check management groups
az account management-group list -o table

# Check hub networks
az network vnet list --query "[?contains(name,'hub')]" -o table

# Check Azure Firewall
az network firewall list -o table

# Check Log Analytics
az monitor log-analytics workspace list -o table
```

### 2. Configure ExpressRoute

```bash
# Get service key
CIRCUIT_NAME="erc-alz-prod"
RG_NAME="rg-alz-networking-prod"

az network express-route show \
  --resource-group $RG_NAME \
  --name $CIRCUIT_NAME \
  --query serviceKey -o tsv

# Provide service key to carrier for provisioning
```

### 3. Configure VPN Gateway

```bash
# Create local network gateway for on-premises
az network local-gateway create \
  --resource-group $RG_NAME \
  --name lng-onprem-site1 \
  --gateway-ip-address <ON_PREM_PUBLIC_IP> \
  --local-address-prefixes <ON_PREM_CIDR>

# Create VPN connection
az network vpn-connection create \
  --resource-group $RG_NAME \
  --name conn-onprem-site1 \
  --vnet-gateway1 vpn-alz-prod \
  --local-gateway2 lng-onprem-site1 \
  --shared-key <PRE_SHARED_KEY>
```

### 4. Set Up Spoke VNets

Create spoke virtual networks and peer them with the hub:

```bash
# Create spoke VNet
az network vnet create \
  --resource-group rg-spoke-app1 \
  --name vnet-spoke-app1 \
  --address-prefix 10.100.0.0/16 \
  --subnet-name snet-app \
  --subnet-prefix 10.100.1.0/24

# Create peering from hub to spoke
az network vnet peering create \
  --resource-group rg-alz-networking-prod \
  --name hub-to-spoke-app1 \
  --vnet-name vnet-alz-hub-prod \
  --remote-vnet /subscriptions/.../vnet-spoke-app1 \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --allow-gateway-transit

# Create peering from spoke to hub
az network vnet peering create \
  --resource-group rg-spoke-app1 \
  --name spoke-app1-to-hub \
  --vnet-name vnet-spoke-app1 \
  --remote-vnet /subscriptions/.../vnet-alz-hub-prod \
  --allow-vnet-access \
  --allow-forwarded-traffic \
  --use-remote-gateways
```

## Common Issues

### Issue: Bicep Build Errors

```bash
# Update Bicep CLI
az bicep upgrade

# Verify version
az bicep version
```

### Issue: Insufficient Permissions

Ensure you have:
- Management Group Contributor at root MG level
- Subscription Owner on all platform subscriptions
- Azure AD permissions for role assignments

### Issue: Parameter Validation Failed

```bash
# Check for placeholder values
grep -r "REPLACE_WITH_" parameters/

# Validate JSON syntax
jq empty parameters/prod.parameters.json
```

### Issue: Deployment Timeout

Gateway deployments can take 30-45 minutes. Be patient and monitor in Azure Portal.

## Support

For issues:
1. Check deployment logs: `az deployment mg list`
2. Review Azure Portal: Management Group > Deployments
3. Contact platform team: platform-team@company.com

## Resources

- [Azure Landing Zone Documentation](https://aka.ms/alz)
- [Bicep Documentation](https://aka.ms/bicep)
- [Azure Architecture Center](https://aka.ms/architecture)
- [Cloud Adoption Framework](https://aka.ms/caf)

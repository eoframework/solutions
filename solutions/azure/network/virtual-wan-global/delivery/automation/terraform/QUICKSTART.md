# Azure Virtual WAN Global - Quick Start Guide

## Prerequisites

1. **Terraform** installed (v1.5+)
2. **Azure CLI** installed and authenticated
3. **Permissions**: Subscription Contributor or Owner
4. **Network Planning**: CIDR ranges for hubs and on-premises

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
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan and Review

```bash
terraform plan -var-file="config/project.tfvars" \
  -var-file="config/vwan.tfvars" \
  -var-file="config/connectivity.tfvars" \
  -var-file="config/security.tfvars" \
  -var-file="config/monitoring.tfvars"
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
| Primary Region | East US | East US | West US 2 |
| Secondary Region | West US 2 | - | East US |
| VWAN Type | Standard | Standard | Standard |
| VPN Gateway | Enabled (2 units) | Enabled (1 unit) | Enabled (1 unit) |
| ExpressRoute GW | Enabled (2 units) | Disabled | Enabled (1 unit) |
| Azure Firewall | Premium | Disabled | Premium |
| DNS Proxy | Enabled | Disabled | Enabled |
| Threat Intel | Alert | Off | Alert |
| Multi-Hub | Yes | No | Yes |

## Post-Deployment Tasks

### 1. Verify Resources

```bash
# Check Virtual WAN
az network vwan show --name <vwan-name> --resource-group <rg>

# Check Virtual Hubs
az network vhub list --resource-group <rg> -o table

# Check VPN Gateway
az network vpn-gateway list --resource-group <rg> -o table

# Check Azure Firewall
az network firewall list --resource-group <rg> -o table
```

### 2. Configure VPN Site

```bash
# Create VPN site for on-premises
az network vpn-site create \
  --resource-group <rg> \
  --name site-onprem-hq \
  --virtual-wan <vwan-name> \
  --ip-address <on-prem-public-ip> \
  --address-prefixes <on-prem-cidr> \
  --device-vendor <vendor-name> \
  --device-model <model>

# Download VPN configuration
az network vpn-site download \
  --resource-group <rg> \
  --name site-onprem-hq \
  --output-blob-sas-url <sas-url>
```

### 3. Connect ExpressRoute

```bash
# Create ExpressRoute connection
az network express-route gateway connection create \
  --resource-group <rg> \
  --gateway-name <er-gateway-name> \
  --name conn-expressroute \
  --peering <peering-id> \
  --associated-route-table <default-route-table-id>
```

### 4. Connect Spoke VNets

```bash
# Create hub VNet connection
az network vhub connection create \
  --resource-group <rg> \
  --vhub-name <hub-name> \
  --name conn-spoke-app1 \
  --remote-vnet <spoke-vnet-id> \
  --associated-route-table <default-route-table-id>
```

## Common Issues

### Issue: Gateway Deployment Slow

VPN and ExpressRoute gateways take 30-45 minutes to deploy.

### Issue: Firewall Policy Not Applied

Ensure firewall policy is associated with the firewall in each hub.

### Issue: Routing Not Working

Check route tables and ensure proper propagation settings.

## Support

- Review README.md for detailed documentation
- VWAN docs: https://docs.microsoft.com/azure/virtual-wan/
- Contact: network-team@company.com

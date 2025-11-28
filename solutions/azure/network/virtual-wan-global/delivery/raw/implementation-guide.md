---
document_title: Azure Virtual WAN Global Network - Implementation Guide
solution_name: Azure Virtual WAN Global Network
client: "[CLIENT NAME]"
project: Azure Virtual WAN Global Network Implementation
document_version: "1.0"
last_updated: "[DATE]"
status: Final
author: Implementation Team
classification: Confidential
---

# Executive Summary

This Implementation Guide provides comprehensive, step-by-step procedures for deploying the Azure Virtual WAN Global Network solution. The guide is designed for network engineers, cloud architects, and operations teams responsible for implementing and operating the solution.

## Guide Overview

**Purpose**: Enable technical teams to deploy, configure, and validate the Azure Virtual WAN infrastructure following enterprise best practices and Microsoft recommendations.

**Scope**: Complete implementation from initial Azure setup through production validation, including:
- Azure subscription and resource configuration
- Virtual WAN hub deployment across three regions
- VPN and ExpressRoute connectivity setup
- Azure Firewall security implementation
- Network monitoring and operations configuration
- Testing, validation, and go-live procedures

**Target Audience**:
- Cloud Network Engineers
- Azure Architects
- Network Operations Teams
- Security Engineers
- DevOps Engineers

## Implementation Approach

The implementation follows a phased approach over 12-16 weeks:

1. **Prerequisites & Planning** (Weeks 1-2): Environment preparation and readiness validation
2. **Environment Setup** (Weeks 3-4): Azure foundation and base infrastructure
3. **Infrastructure Deployment** (Weeks 5-10): Hub deployment, connectivity, security
4. **Application Configuration** (Weeks 11-12): Spoke VNets and application integration
5. **Integration Testing** (Week 13): End-to-end validation
6. **Security Validation** (Week 14): Comprehensive security testing
7. **Migration & Cutover** (Weeks 15-16): Production migration and validation
8. **Operational Handover** (Post-implementation): Training and support transition

## Key Success Factors

- **Infrastructure as Code**: All deployments automated with Terraform
- **Phased Migration**: Gradual cutover minimizes business risk
- **Comprehensive Testing**: Validation before production traffic
- **Thorough Documentation**: Operational procedures and troubleshooting guides
- **Knowledge Transfer**: Hands-on training for operations teams

---

# Prerequisites

## Azure Environment Requirements

### Azure Subscription

**Requirements**:
- Active Azure subscription with Owner or Contributor role
- Subscription must support Virtual WAN service (available in most regions)
- Adequate subscription quotas for network resources
- Azure AD tenant for identity and access management

**Quota Verification**:
```bash
# Check current Virtual WAN quotas
az network vwan list --subscription <subscription-id>

# Check VPN Gateway quotas
az network vnet-gateway list --subscription <subscription-id>

# Request quota increase if needed (via Azure Portal Support)
```

**Required Quotas**:
| Resource | Required Minimum | Recommended |
|----------|------------------|-------------|
| Virtual WAN | 1 | 2 (prod + non-prod) |
| Virtual Hubs | 3 | 5 |
| VPN Gateways | 3 | 5 |
| ExpressRoute Gateways | 2 | 3 |
| Azure Firewalls | 3 | 5 |
| Virtual Networks | 20 | 50 |

### Azure AD and RBAC

**Identity Requirements**:
- Azure AD tenant with Global Administrator access (initial setup)
- Service Principal for automation (Terraform/CI-CD)
- Managed identities for Azure resources
- Multi-Factor Authentication (MFA) enabled for all admin accounts

**Required RBAC Roles**:
```bash
# Assign Network Contributor role
az role assignment create \
  --assignee <user-or-sp-object-id> \
  --role "Network Contributor" \
  --scope /subscriptions/<subscription-id>

# Assign Security Admin for firewall management
az role assignment create \
  --assignee <user-or-sp-object-id> \
  --role "Security Admin" \
  --scope /subscriptions/<subscription-id>/resourceGroups/rg-vwan-security
```

### IP Address Planning

**Pre-Allocated Address Spaces**:
- Virtual WAN Hubs: 10.0.0.0/24, 10.1.0.0/24, 10.2.0.0/24
- Spoke VNets: 10.10.0.0/14 range
- Branch Sites: 192.168.0.0/16 range
- Point-to-Site VPN: 172.16.0.0/16
- On-premises Data Centers: 10.100.0.0/16, 10.101.0.0/16

**Conflict Detection**:
```bash
# Verify no overlapping address spaces in subscription
az network vnet list --query "[].{Name:name, AddressSpace:addressSpace.addressPrefixes}" -o table
```

## Network Requirements

### Existing Infrastructure Assessment

**Required Information**:
- [ ] Current network topology documented
- [ ] Branch office public IP addresses collected
- [ ] On-premises BGP AS numbers identified
- [ ] ExpressRoute peering locations confirmed
- [ ] Internet bandwidth per location documented
- [ ] VPN CPE device models and firmware versions

### Branch Office CPE Requirements

**Compatible Devices**:
- Cisco ISR 4000 series (IOS XE 16.9+)
- Fortinet FortiGate (FortiOS 6.0+)
- Palo Alto Networks PA-Series
- Generic IPsec/IKEv2 capable devices

**Minimum CPE Specifications**:
- IKEv2 support (mandatory)
- IPsec with AES-256-GCM encryption
- BGP routing protocol (recommended, not required)
- Dual WAN interfaces for redundancy (recommended)
- Static or dynamic public IP address

### ExpressRoute Requirements

**Circuit Planning**:
- Peering location selected (Equinix, Megaport, etc.)
- Bandwidth determined (1 Gbps, 10 Gbps)
- Service provider engaged
- Lead time: 8-12 weeks from order to activation

**Circuit Specifications**:
```
Primary Circuit:
- Location: [Peering Location]
- Bandwidth: 1 Gbps
- Provider: [Service Provider]
- Service Key: [Provided by Microsoft]

Secondary Circuit:
- Location: [Different Peering Location]
- Bandwidth: 1 Gbps
- Provider: [Service Provider]
- Service Key: [Provided by Microsoft]
```

## Tool Requirements

### Development Tools

**Required Software**:
```bash
# Terraform (>= 1.5.0)
terraform --version

# Azure CLI (>= 2.50.0)
az --version

# PowerShell (>= 7.0) or Bash
pwsh --version

# Git for version control
git --version

# Visual Studio Code (recommended IDE)
code --version
```

**Installation**:
```bash
# Install Azure CLI (Linux)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Terraform (Linux)
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install Azure PowerShell Module
Install-Module -Name Az -Repository PSGallery -Force
```

### Authentication Setup

**Azure CLI Login**:
```bash
# Interactive login
az login

# Select correct subscription
az account set --subscription "<subscription-id>"

# Verify context
az account show
```

**Service Principal for Terraform**:
```bash
# Create service principal
az ad sp create-for-rbac \
  --name "terraform-vwan-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id>

# Output (save securely):
# {
#   "appId": "<application-id>",
#   "password": "<client-secret>",
#   "tenant": "<tenant-id>"
# }

# Set environment variables for Terraform
export ARM_CLIENT_ID="<application-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"
```

## Pre-Deployment Checklist

**Infrastructure Readiness**:
- [ ] Azure subscription accessible with appropriate permissions
- [ ] IP address plan finalized and documented
- [ ] No IP address conflicts with existing networks
- [ ] Azure quotas sufficient for deployment
- [ ] Terraform and Azure CLI installed and configured
- [ ] Service principal created for automation

**Network Readiness**:
- [ ] Branch office public IP addresses collected
- [ ] CPE device compatibility verified
- [ ] ExpressRoute circuits ordered (if applicable)
- [ ] On-premises BGP AS numbers assigned
- [ ] Firewall rules for Azure management endpoints configured

**Team Readiness**:
- [ ] Implementation team identified and available
- [ ] Stakeholders informed of deployment schedule
- [ ] Change management approvals obtained
- [ ] Communication plan activated
- [ ] Support contacts and escalation procedures documented

---

# Environment Setup

## Resource Group Creation

### Primary Resource Groups

```bash
# Create resource group for Virtual WAN core components
az group create \
  --name rg-vwan-core-prod \
  --location eastus \
  --tags Environment=Production Component=VirtualWAN ManagedBy=Terraform

# Create resource group for security components
az group create \
  --name rg-vwan-security-prod \
  --location eastus \
  --tags Environment=Production Component=Security ManagedBy=Terraform

# Create resource group for monitoring
az group create \
  --name rg-vwan-monitoring-prod \
  --location eastus \
  --tags Environment=Production Component=Monitoring ManagedBy=Terraform

# Verify creation
az group list --query "[?contains(name, 'vwan')].{Name:name, Location:location, ProvisioningState:properties.provisioningState}" -o table
```

### Regional Resource Groups

```bash
# West US resource group for regional components
az group create \
  --name rg-vwan-westus-prod \
  --location westus2 \
  --tags Environment=Production Component=Regional Region=WestUS

# Europe resource group
az group create \
  --name rg-vwan-europe-prod \
  --location westeurope \
  --tags Environment=Production Component=Regional Region=Europe
```

## Monitoring Infrastructure

### Log Analytics Workspace

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group rg-vwan-monitoring-prod \
  --workspace-name law-vwan-prod \
  --location eastus \
  --retention-time 90

# Get workspace ID and key
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group rg-vwan-monitoring-prod \
  --workspace-name law-vwan-prod \
  --query customerId -o tsv)

WORKSPACE_KEY=$(az monitor log-analytics workspace get-shared-keys \
  --resource-group rg-vwan-monitoring-prod \
  --workspace-name law-vwan-prod \
  --query primarySharedKey -o tsv)

echo "Workspace ID: $WORKSPACE_ID"
```

### Storage Accounts

```bash
# Create storage account for diagnostics and logs
az storage account create \
  --name stvwanlogsprod$(date +%s | tail -c 6) \
  --resource-group rg-vwan-monitoring-prod \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --encryption-services blob file

# Enable soft delete
az storage account blob-service-properties update \
  --account-name <storage-account-name> \
  --enable-delete-retention true \
  --delete-retention-days 30
```

## Terraform Initialization

### Repository Structure Setup

```bash
# Clone or create infrastructure repository
mkdir -p ~/azure-vwan-iac
cd ~/azure-vwan-iac

# Create directory structure
mkdir -p {modules,environments/{prod,nonprod},scripts}
mkdir -p modules/{virtual-wan,hub,vpn-site,firewall,monitoring}

# Initialize git
git init
git remote add origin <repository-url>
```

### Terraform Backend Configuration

**backend.tf**:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "vwan-prod.tfstate"
  }

  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = true
      skip_shutdown_and_force_delete = false
    }
  }
}
```

**Create Backend Storage**:
```bash
# Create resource group for Terraform state
az group create \
  --name rg-terraform-state \
  --location eastus

# Create storage account
az storage account create \
  --name stterraformstate$(date +%s | tail -c 6) \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob

# Create container
az storage container create \
  --name tfstate \
  --account-name <storage-account-name>

# Enable versioning
az storage account blob-service-properties update \
  --account-name <storage-account-name> \
  --enable-versioning true
```

### Initialize Terraform

```bash
# Navigate to environment directory
cd environments/prod

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan deployment (dry run)
terraform plan -out=tfplan
```

## Azure Policy Assignment

### Network Policies

```bash
# Require NSG on subnets
az policy assignment create \
  --name "require-nsg-on-subnet" \
  --display-name "Network Security Groups Required on Subnets" \
  --policy "/providers/Microsoft.Authorization/policyDefinitions/e71308d3-144b-4262-b144-efdc3cc90517" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rg-vwan-core-prod"

# Require specific address spaces
az policy assignment create \
  --name "allowed-vnet-address-spaces" \
  --display-name "Allowed Virtual Network Address Spaces" \
  --policy <custom-policy-definition-id> \
  --params '{"allowedAddressPrefixes":{"value":["10.0.0.0/8","192.168.0.0/16"]}}'
```

### Tagging Policies

```bash
# Require tags on resources
az policy assignment create \
  --name "require-tags" \
  --display-name "Require Tags on Resources" \
  --policy "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025" \
  --params '{
    "tagNames": {
      "value": ["Environment", "Component", "Owner", "CostCenter"]
    }
  }'
```

---

# Infrastructure Deployment

The infrastructure deployment is organized into four phases covering networking, security, compute, and monitoring layers of the solution architecture. Each phase builds upon the previous phase, ensuring dependencies are met before proceeding.

## Phase 1: Networking Layer

### Virtual WAN Creation

**Terraform Module** (`modules/virtual-wan/main.tf`):
```hcl
resource "azurerm_virtual_wan" "main" {
  name                = var.vwan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Standard"

  office365_local_breakout_category = "Optimize"
  allow_branch_to_branch_traffic    = true
  disable_vpn_encryption            = false

  tags = var.tags
}

output "virtual_wan_id" {
  value = azurerm_virtual_wan.main.id
}
```

**Deploy Virtual WAN**:
```bash
# From environments/prod directory
terraform plan -target=module.virtual_wan -out=tfplan-vwan
terraform apply tfplan-vwan

# Verify deployment
az network vwan show \
  --resource-group rg-vwan-core-prod \
  --name vwan-global-prod
```

### Virtual Hub Deployment

**Terraform Module** (`modules/hub/main.tf`):
```hcl
resource "azurerm_virtual_hub" "main" {
  name                = var.hub_name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = var.virtual_wan_id
  address_prefix      = var.address_prefix
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_vpn_gateway" "main" {
  name                = "${var.hub_name}-vpngw"
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_hub_id      = azurerm_virtual_hub.main.id
  scale_unit          = var.vpn_gateway_scale_unit

  bgp_settings {
    asn         = var.bgp_asn
    peer_weight = 0
  }

  tags = var.tags
}

resource "azurerm_express_route_gateway" "main" {
  count               = var.enable_expressroute ? 1 : 0
  name                = "${var.hub_name}-ergw"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_hub_id      = azurerm_virtual_hub.main.id
  scale_units         = var.er_gateway_scale_unit

  tags = var.tags
}
```

**Deploy Hubs**:
```bash
# Deploy all three hubs
terraform plan -target=module.hub_east_us -target=module.hub_west_us -target=module.hub_europe -out=tfplan-hubs
terraform apply tfplan-hubs

# Monitor deployment (hubs take 30-45 minutes)
az network vhub list \
  --resource-group rg-vwan-core-prod \
  --query "[].{Name:name, ProvisioningState:provisioningState, Location:location}" -o table

# Wait for all hubs to show "Succeeded"
```

### Verify Hub-to-Hub Connectivity

```bash
# Check hub routing status
az network vhub show \
  --resource-group rg-vwan-core-prod \
  --name hub-eastus-prod \
  --query "{Name:name, RoutingState:routingState, VirtualWanId:virtualWan.id}"

# Verify hub-to-hub mesh
az network vhub route-table show \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name defaultRouteTable
```

## Phase 2: Security Layer

### Azure Firewall Deployment

**Firewall Policy** (`modules/firewall/policy.tf`):
```hcl
resource "azurerm_firewall_policy" "main" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  threat_intelligence_mode = "Deny"

  dns {
    proxy_enabled = true
    servers       = []
  }

  threat_intelligence_allowlist {
    fqdns        = []
    ip_addresses = []
  }

  intrusion_detection {
    mode = "Alert"
  }

  tags = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  name               = "NetworkRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 200

  network_rule_collection {
    name     = "AllowOutboundCore"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "AllowHTTPS"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "AllowDNS"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["168.63.129.16"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "AllowNTP"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  }

  network_rule_collection {
    name     = "AllowHubToHub"
    priority = 150
    action   = "Allow"

    rule {
      name                  = "InterHubTraffic"
      protocols             = ["Any"]
      source_addresses      = var.hub_address_spaces
      destination_addresses = var.hub_address_spaces
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "application_rules" {
  name               = "ApplicationRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 300

  application_rule_collection {
    name     = "AllowMicrosoftServices"
    priority = 100
    action   = "Allow"

    rule {
      name = "AllowAzureServices"
      source_addresses = ["*"]
      destination_fqdns = [
        "*.microsoft.com",
        "*.azure.com",
        "*.windows.net"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name = "AllowOffice365"
      source_addresses = ["*"]
      destination_fqdn_tags = ["Microsoft365"]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}
```

**Deploy Firewall**:
```bash
# Deploy firewall policy and firewalls to all hubs
terraform plan -target=module.firewall -out=tfplan-firewall
terraform apply tfplan-firewall

# Verify firewall deployment
az network firewall list \
  --resource-group rg-vwan-security-prod \
  --query "[].{Name:name, ProvisioningState:provisioningState, ThreatIntelMode:threatIntelMode}" -o table

# Check firewall policy
az network firewall policy show \
  --name fw-policy-vwan-global \
  --resource-group rg-vwan-security-prod
```

### Configure Routing to Firewall

```bash
# Create custom route table for secure internet breakout
az network vhub route-table create \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name SecureInternetRouteTable \
  --labels "Secure"

# Add default route to firewall
FIREWALL_ID=$(az network firewall show \
  --resource-group rg-vwan-security-prod \
  --name fw-hub-eastus-prod \
  --query id -o tsv)

az network vhub route-table route add \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name SecureInternetRouteTable \
  --destination-type CIDR \
  --destinations "0.0.0.0/0" \
  --next-hop-type ResourceId \
  --next-hop $FIREWALL_ID
```

## Phase 3: Compute Layer

### VPN Site Configuration

**VPN Site Terraform** (`modules/vpn-site/main.tf`):
```hcl
resource "azurerm_vpn_site" "main" {
  name                = var.site_name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = var.virtual_wan_id
  address_cidrs       = var.address_spaces

  device_vendor = var.device_vendor
  device_model  = var.device_model

  link {
    name       = "${var.site_name}-link"
    ip_address = var.public_ip
    provider_name = var.provider_name
    speed_in_mbps = var.bandwidth_mbps

    bgp {
      asn             = var.bgp_asn
      peering_address = var.bgp_peer_address
    }
  }

  tags = var.tags
}

resource "azurerm_vpn_gateway_connection" "main" {
  name               = "${var.site_name}-connection"
  vpn_gateway_id     = var.vpn_gateway_id
  remote_vpn_site_id = azurerm_vpn_site.main.id

  vpn_link {
    name             = "${var.site_name}-link"
    vpn_site_link_id = azurerm_vpn_site.main.link[0].id
    shared_key       = var.shared_key
    protocol         = "IKEv2"
    connection_mode  = "Default"
    bandwidth_mbps   = var.bandwidth_mbps

    ipsec_policy {
      sa_lifetime_sec = 3600
      sa_data_size_kb = 102400000
      encryption_algorithm = "AES256"
      integrity_algorithm  = "SHA256"
      ike_encryption_algorithm = "AES256"
      ike_integrity_algorithm  = "SHA256"
      dh_group                 = "DHGroup2"
      pfs_group                = "PFS2"
    }

    bgp_enabled = var.enable_bgp
  }
}
```

**Deploy VPN Sites**:
```bash
# Deploy VPN sites for all branches
terraform plan -target=module.vpn_sites -out=tfplan-vpn
terraform apply tfplan-vpn

# Verify VPN sites
az network vpn-site list \
  --resource-group rg-vwan-core-prod \
  --query "[].{Name:name, PublicIP:ipAddress, AddressSpaces:addressSpace.addressPrefixes}" -o table

# Check VPN gateway connections
az network vpn-gateway connection list \
  --resource-group rg-vwan-core-prod \
  --gateway-name vpngw-hub-eastus-prod \
  --query "[].{Name:name, ConnectionStatus:connectionStatus, ProvisioningState:provisioningState}" -o table
```

### Branch CPE Configuration

**Generate CPE Configuration**:
```bash
# Download VPN configuration for branch site
az network vpn-gateway connection vpn-site-link-conn show \
  --resource-group rg-vwan-core-prod \
  --gateway-name vpngw-hub-eastus-prod \
  --connection-name site-newyork-connection \
  --name site-newyork-link

# Get VPN gateway public IPs
az network vpn-gateway show \
  --resource-group rg-vwan-core-prod \
  --name vpngw-hub-eastus-prod \
  --query "bgpSettings.bgpPeeringAddresses[].{Tunnel:tunnelIpAddresses, BGP:defaultBgpIpAddresses}"
```

**Cisco IOS XE Configuration Template**:
```cisco
! Interface Configuration
interface Tunnel0
 description Primary VPN to Azure Hub East US
 ip address 192.168.1.254 255.255.255.255
 tunnel source GigabitEthernet0/0/0
 tunnel mode ipsec ipv4
 tunnel destination <AZURE_VPN_GATEWAY_PUBLIC_IP_1>
 tunnel protection ipsec profile AZURE_IPSEC_PROFILE

interface Tunnel1
 description Secondary VPN to Azure Hub East US
 ip address 192.168.1.253 255.255.255.255
 tunnel source GigabitEthernet0/0/0
 tunnel mode ipsec ipv4
 tunnel destination <AZURE_VPN_GATEWAY_PUBLIC_IP_2>
 tunnel protection ipsec profile AZURE_IPSEC_PROFILE

! BGP Configuration
router bgp 64501
 bgp log-neighbor-changes
 neighbor <AZURE_BGP_IP_1> remote-as 65515
 neighbor <AZURE_BGP_IP_1> ebgp-multihop 5
 neighbor <AZURE_BGP_IP_1> update-source Tunnel0
 neighbor <AZURE_BGP_IP_2> remote-as 65515
 neighbor <AZURE_BGP_IP_2> ebgp-multihop 5
 neighbor <AZURE_BGP_IP_2> update-source Tunnel1

 address-family ipv4
  network 192.168.1.0 mask 255.255.255.0
  neighbor <AZURE_BGP_IP_1> activate
  neighbor <AZURE_BGP_IP_2> activate
 exit-address-family
```

### ExpressRoute Integration

```bash
# Connect ExpressRoute circuit to Virtual WAN
CIRCUIT_ID="/subscriptions/<sub-id>/resourceGroups/rg-expressroute/providers/Microsoft.Network/expressRouteCircuits/er-circuit-primary"

az network express-route gateway connection create \
  --resource-group rg-vwan-core-prod \
  --gateway-name ergw-hub-eastus-prod \
  --name er-connection-primary \
  --peering $CIRCUIT_ID/peerings/AzurePrivatePeering \
  --enable-internet-security false

# Verify ExpressRoute connection
az network express-route gateway connection show \
  --resource-group rg-vwan-core-prod \
  --gateway-name ergw-hub-eastus-prod \
  --name er-connection-primary \
  --query "{Name:name, ProvisioningState:provisioningState, RoutingWeight:routingWeight}"
```

## Phase 4: Monitoring Layer

### Diagnostic Settings

```bash
# Enable diagnostics on Virtual WAN
VWAN_ID=$(az network vwan show \
  --resource-group rg-vwan-core-prod \
  --name vwan-global-prod \
  --query id -o tsv)

az monitor diagnostic-settings create \
  --name vwan-diagnostics \
  --resource $VWAN_ID \
  --workspace $WORKSPACE_ID \
  --logs '[{"category": "AllLogs", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# Enable diagnostics on VPN Gateway
VPNGW_ID=$(az network vpn-gateway show \
  --resource-group rg-vwan-core-prod \
  --name vpngw-hub-eastus-prod \
  --query id -o tsv)

az monitor diagnostic-settings create \
  --name vpngw-diagnostics \
  --resource $VPNGW_ID \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "GatewayDiagnosticLog", "enabled": true},
    {"category": "TunnelDiagnosticLog", "enabled": true},
    {"category": "RouteDiagnosticLog", "enabled": true},
    {"category": "IKEDiagnosticLog", "enabled": true}
  ]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# Enable diagnostics on Azure Firewall
FIREWALL_ID=$(az network firewall show \
  --resource-group rg-vwan-security-prod \
  --name fw-hub-eastus-prod \
  --query id -o tsv)

az monitor diagnostic-settings create \
  --name firewall-diagnostics \
  --resource $FIREWALL_ID \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "AzureFirewallApplicationRule", "enabled": true},
    {"category": "AzureFirewallNetworkRule", "enabled": true},
    {"category": "AzureFirewallDnsProxy", "enabled": true}
  ]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

### Network Watcher Configuration

```bash
# Enable Network Watcher in all regions
az network watcher configure \
  --resource-group NetworkWatcherRG \
  --locations eastus westus2 westeurope \
  --enabled true

# Create Connection Monitor
az network watcher connection-monitor create \
  --name cm-vwan-monitoring \
  --location eastus \
  --endpoints '[
    {
      "name": "hub-eastus",
      "resourceId": "'$VPNGW_ID'",
      "type": "AzureVM"
    },
    {
      "name": "hub-westus",
      "resourceId": "<WESTUS_VPNGW_ID>",
      "type": "AzureVM"
    }
  ]' \
  --test-configurations '[
    {
      "name": "tcp443",
      "protocol": "Tcp",
      "tcpConfiguration": {
        "port": 443,
        "disableTraceRoute": false
      },
      "testFrequencySec": 60
    }
  ]' \
  --test-groups '[
    {
      "name": "hub-to-hub",
      "sources": ["hub-eastus"],
      "destinations": ["hub-westus"],
      "testConfigurations": ["tcp443"]
    }
  ]'
```

### Alert Rules

```bash
# Create action group
az monitor action-group create \
  --resource-group rg-vwan-monitoring-prod \
  --name ag-vwan-alerts \
  --short-name VWanAlerts \
  --email-receiver name=NetworkTeam email=network-team@company.com

# VPN Connection Down Alert
az monitor metrics alert create \
  --name "VPN Connection Down" \
  --resource-group rg-vwan-monitoring-prod \
  --scopes $VPNGW_ID \
  --condition "avg TunnelBandwidth < 1" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 1 \
  --description "VPN tunnel completely offline" \
  --action ag-vwan-alerts

# Firewall Health Alert
FIREWALL_ID=$(az network firewall show --resource-group rg-vwan-security-prod --name fw-hub-eastus-prod --query id -o tsv)

az monitor metrics alert create \
  --name "Firewall Health Degraded" \
  --resource-group rg-vwan-monitoring-prod \
  --scopes $FIREWALL_ID \
  --condition "avg FirewallHealth < 90" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --severity 2 \
  --description "Azure Firewall health below 90%" \
  --action ag-vwan-alerts
```

---

# Application Configuration

## Spoke VNet Connections

### Create Spoke VNets

```bash
# Create production spoke VNet
az network vnet create \
  --resource-group rg-spoke-prod-eastus \
  --name vnet-spoke-prod-001 \
  --address-prefixes 10.10.1.0/16 \
  --location eastus

# Create subnets
az network vnet subnet create \
  --resource-group rg-spoke-prod-eastus \
  --vnet-name vnet-spoke-prod-001 \
  --name subnet-frontend \
  --address-prefixes 10.10.1.0/24

az network vnet subnet create \
  --resource-group rg-spoke-prod-eastus \
  --vnet-name vnet-spoke-prod-001 \
  --name subnet-application \
  --address-prefixes 10.10.2.0/24

az network vnet subnet create \
  --resource-group rg-spoke-prod-eastus \
  --vnet-name vnet-spoke-prod-001 \
  --name subnet-database \
  --address-prefixes 10.10.3.0/24
```

### Connect VNet to Virtual Hub

```bash
# Create VNet connection
az network vhub connection create \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name connection-spoke-prod-001 \
  --remote-vnet /subscriptions/<sub-id>/resourceGroups/rg-spoke-prod-eastus/providers/Microsoft.Network/virtualNetworks/vnet-spoke-prod-001 \
  --enable-internet-security true

# Verify connection
az network vhub connection show \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name connection-spoke-prod-001 \
  --query "{Name:name, ProvisioningState:provisioningState, EnableInternetSecurity:enableInternetSecurity}"

# Check effective routes
az network vhub get-effective-routes \
  --resource-group rg-vwan-core-prod \
  --name hub-eastus-prod \
  --resource-type VirtualNetworkConnection \
  --resource-id connection-spoke-prod-001
```

## Network Security Groups

```bash
# Create NSG for application tier
az network nsg create \
  --resource-group rg-spoke-prod-eastus \
  --name nsg-app-tier \
  --location eastus

# Allow traffic from frontend subnet
az network nsg rule create \
  --resource-group rg-spoke-prod-eastus \
  --nsg-name nsg-app-tier \
  --name Allow-Frontend \
  --priority 100 \
  --source-address-prefixes 10.10.1.0/24 \
  --destination-port-ranges 8080 \
  --access Allow \
  --protocol Tcp \
  --description "Allow traffic from frontend tier"

# Allow management access
az network nsg rule create \
  --resource-group rg-spoke-prod-eastus \
  --nsg-name nsg-app-tier \
  --name Allow-Management \
  --priority 110 \
  --source-address-prefixes 10.10.4.0/24 \
  --destination-port-ranges 22 443 \
  --access Allow \
  --protocol Tcp \
  --description "Allow SSH and HTTPS from management subnet"

# Associate NSG with subnet
az network vnet subnet update \
  --resource-group rg-spoke-prod-eastus \
  --vnet-name vnet-spoke-prod-001 \
  --name subnet-application \
  --network-security-group nsg-app-tier
```

## Private DNS Configuration

```bash
# Create private DNS zone
az network private-dns zone create \
  --resource-group rg-vwan-monitoring-prod \
  --name internal.company.com

# Link DNS zone to spoke VNets
az network private-dns link vnet create \
  --resource-group rg-vwan-monitoring-prod \
  --zone-name internal.company.com \
  --name link-spoke-prod-001 \
  --virtual-network vnet-spoke-prod-001 \
  --registration-enabled true
```

---

# Integration Testing

## Connectivity Tests

### Hub-to-Hub Connectivity

```bash
# Test hub-to-hub routing
az network vhub show \
  --resource-group rg-vwan-core-prod \
  --name hub-eastus-prod \
  --query "routingState"

# Should return "Provisioned"

# Check learned routes
az network vhub route-table show \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name defaultRouteTable \
  --query "routes"
```

### VPN Site Connectivity

```bash
# Check VPN connection status
az network vpn-gateway connection show \
  --resource-group rg-vwan-core-prod \
  --gateway-name vpngw-hub-eastus-prod \
  --name site-newyork-connection \
  --query "{Name:name, ConnectionStatus:connectionStatus, IngressBytesTransferred:ingressBytesTransferred, EgressBytesTransferred:egressBytesTransferred}"

# Check BGP peer status
az network vpn-gateway connection list \
  --resource-group rg-vwan-core-prod \
  --gateway-name vpngw-hub-eastus-prod \
  --query "[].{Name:name, ConnectionStatus:connectionStatus, RoutingConfiguration:routingConfiguration.associatedRouteTable.id}"
```

### End-to-End Connectivity

**From Branch to Azure VM**:
```bash
# From branch office, test ping to Azure VM
ping 10.10.1.5

# Test application access
curl https://10.10.1.5

# Traceroute to Azure
traceroute 10.10.1.5
# Expected path: Branch → VPN → Hub → Spoke VNet → VM
```

## Performance Testing

### Bandwidth Testing

**iPerf3 Testing**:
```bash
# On Azure VM (server)
iperf3 -s -p 5201

# From branch office (client)
iperf3 -c 10.10.1.5 -p 5201 -t 60 -P 10

# Expected throughput: ~900 Mbps (for 1 Gbps VPN gateway)
```

### Latency Testing

```bash
# Measure latency to Azure
ping -c 100 10.10.1.5

# Calculate statistics
# Expected: <50ms for regional connections, <150ms for transatlantic
```

## Security Validation

### Firewall Rule Testing

```bash
# Test allowed traffic (should succeed)
curl https://www.microsoft.com

# Test blocked traffic (should fail)
curl http://malicious-domain.example.com

# Review firewall logs
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "AzureDiagnostics | where Category == 'AzureFirewallApplicationRule' | order by TimeGenerated desc | take 20" \
  --output table
```

### NSG Validation

```bash
# Test NSG rules
az network nic effective-nsg show \
  --resource-group rg-spoke-prod-eastus \
  --name vm-app-001-nic

# Verify expected rules are in place
```

---

# Security Validation

## Vulnerability Assessment

### Azure Security Center

```bash
# Enable Security Center
az security auto-provisioning-setting update \
  --name default \
  --auto-provision On

# Check security posture
az security secure-score-controls list \
  --query "[].{Name:name, CurrentScore:current, MaxScore:max}" -o table
```

### Network Security Scanning

```bash
# Run NSG flow log analysis
az network watcher flow-log show \
  --location eastus \
  --name nsg-flow-log \
  --query "flowAnalyticsConfiguration.enabled"

# Enable traffic analytics
az network watcher flow-log configure \
  --location eastus \
  --nsg nsg-app-tier \
  --enabled true \
  --workspace $WORKSPACE_ID \
  --traffic-analytics true
```

## Compliance Validation

### Policy Compliance Report

```bash
# Check Azure Policy compliance
az policy state summarize \
  --resource-group rg-vwan-core-prod \
  --query "results[].{Policy:policyDefinitionName, ComplianceState:complianceState}" -o table
```

### Audit Logging Verification

```bash
# Query audit logs
az monitor activity-log list \
  --resource-group rg-vwan-core-prod \
  --start-time 2024-01-01T00:00:00Z \
  --query "[?contains(authorization.action, 'Microsoft.Network')].{Time:eventTimestamp, Action:authorization.action, User:caller}" -o table
```

---

# Migration & Cutover

## Pre-Cutover Validation

**Checklist**:
- [ ] All hubs deployed and routing properly
- [ ] VPN sites connected with green status
- [ ] Azure Firewall deployed and policies validated
- [ ] Spoke VNets connected with proper routing
- [ ] Monitoring and alerting functional
- [ ] Performance testing passed
- [ ] Security validation complete
- [ ] Rollback procedure documented and tested

## Migration Execution

### Wave 1: Non-Production Workloads

```bash
# Update VNet connection routing
az network vhub connection update \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name connection-spoke-nonprod-001 \
  --labels "NonProduction"

# Monitor for 24 hours
# Check connectivity, performance, security logs
```

### Wave 2: Production Cutover

```bash
# Schedule maintenance window
# Announce to stakeholders

# Execute cutover
az network vhub connection update \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name connection-spoke-prod-001 \
  --enable-internet-security true

# Validate immediately
az network vhub connection show \
  --resource-group rg-vwan-core-prod \
  --vhub-name hub-eastus-prod \
  --name connection-spoke-prod-001

# Monitor for issues
```

## Post-Migration Validation

```bash
# Verify all connections
az network vpn-gateway connection list \
  --resource-group rg-vwan-core-prod \
  --gateway-name vpngw-hub-eastus-prod \
  --query "[].{Name:name, Status:connectionStatus}" -o table

# Check routing
az network vhub get-effective-routes \
  --resource-group rg-vwan-core-prod \
  --name hub-eastus-prod

# Monitor firewall logs for denies
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "AzureDiagnostics | where Category == 'AzureFirewallNetworkRule' and Action == 'Deny' | summarize count() by bin(TimeGenerated, 5m)" \
  --output table
```

---

# Operational Handover

## Training Program

### Administrator Training

**Day 1: Architecture and Components**
- Virtual WAN architecture overview
- Hub-and-spoke topology
- Routing and connectivity options
- Security implementation

**Day 2: Operations and Management**
- Azure Portal navigation
- Monitoring dashboards and alerts
- Common operational tasks
- Troubleshooting procedures

**Day 3: Hands-On Labs**
- Adding new VPN site
- Modifying firewall rules
- Investigating connectivity issues
- Performance troubleshooting

### Operations Runbooks

**SOP-001: Add New Branch Site**
1. Collect site information (IP, subnets, CPE model)
2. Create VPN site in Azure Portal or Terraform
3. Generate CPE configuration
4. Configure branch CPE device
5. Validate connectivity and routing
6. Update documentation

**SOP-002: Troubleshoot VPN Connectivity**
1. Check VPN site status in portal
2. Review VPN gateway diagnostics
3. Verify BGP peering if enabled
4. Check effective routes
5. Review firewall logs for denies
6. Escalate to Microsoft if Azure-side issue

**SOP-003: Investigate Performance Issue**
1. Check Network Watcher metrics
2. Review VPN gateway throughput
3. Analyze firewall performance metrics
4. Check for routing asymmetry
5. Run bandwidth test from branch
6. Review application-level metrics

## Support Structure

### Tier 1 (NOC)
- Monitor dashboards and alerts
- Basic connectivity checks
- Escalate to Tier 2 if needed
- Response time: 30 minutes

### Tier 2 (Network Engineers)
- Complex routing issues
- Performance troubleshooting
- Firewall rule modifications
- Configuration changes
- Response time: 2 hours

### Tier 3 (Architects + Microsoft)
- Architecture modifications
- Azure platform issues
- Major capacity changes
- Complex multi-region problems
- Response time: 4 hours

---

# Training Program

## Administrator Certification

**Certification Path**:
1. Review all documentation
2. Complete hands-on labs
3. Shadow implementation team
4. Perform operational tasks independently
5. Pass knowledge assessment (80% minimum)

**Assessment Topics**:
- Virtual WAN architecture and components
- Routing and connectivity configuration
- Firewall policy management
- Monitoring and troubleshooting
- Incident response procedures

## Ongoing Training

- Monthly Virtual WAN feature updates
- Quarterly security best practices review
- Annual Azure networking certification renewal
- Access to Microsoft Learn resources
- Vendor-led training sessions as needed

---

# Appendices

## Appendix A: Troubleshooting Guide

### VPN Connectivity Issues

**Symptom**: VPN site shows "Not Connected"

**Troubleshooting Steps**:
1. Check branch CPE status and logs
2. Verify public IP hasn't changed
3. Check shared key matches on both sides
4. Review IKE/IPsec logs on CPE
5. Verify Azure VPN gateway health
6. Check for Azure service issues

**Common Resolutions**:
- Restart VPN gateway on CPE
- Re-enter shared key
- Update CPE configuration
- Engage Microsoft support for Azure issues

### Routing Problems

**Symptom**: Branch can't reach specific Azure subnet

**Troubleshooting Steps**:
1. Check BGP peering status
2. Review effective routes on hub
3. Verify VNet connection routing
4. Check firewall rules for denies
5. Verify NSG rules on target subnet

### Performance Degradation

**Symptom**: Slow application response times

**Troubleshooting Steps**:
1. Run bandwidth test to Azure
2. Check VPN gateway metrics for saturation
3. Review firewall throughput metrics
4. Check for packet loss
5. Analyze latency to identify bottleneck
6. Review application-side performance

## Appendix B: Command Reference

### Common Azure CLI Commands

```bash
# Show Virtual WAN
az network vwan show --resource-group rg-vwan-core-prod --name vwan-global-prod

# List Virtual Hubs
az network vhub list --resource-group rg-vwan-core-prod -o table

# Check VPN Gateway
az network vpn-gateway show --resource-group rg-vwan-core-prod --name vpngw-hub-eastus-prod

# View VPN Connections
az network vpn-gateway connection list --resource-group rg-vwan-core-prod --gateway-name vpngw-hub-eastus-prod -o table

# Check Firewall Status
az network firewall show --resource-group rg-vwan-security-prod --name fw-hub-eastus-prod --query "provisioningState"

# View Effective Routes
az network vhub get-effective-routes --resource-group rg-vwan-core-prod --name hub-eastus-prod --resource-type VirtualNetworkConnection --resource-id connection-spoke-prod-001
```

### Monitoring Queries (KQL)

**VPN Connection Status**:
```kusto
AzureDiagnostics
| where Category == "TunnelDiagnosticLog"
| where TimeGenerated > ago(1h)
| summarize arg_max(TimeGenerated, *) by remoteIP_s
| project TimeGenerated, remoteIP_s, status_s, stateChangeReason_s
```

**Firewall Denied Connections**:
```kusto
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule"
| where Action == "Deny"
| where TimeGenerated > ago(1h)
| summarize count() by SourceIP, DestinationIP, DestinationPort
| order by count_ desc
```

## Appendix C: Configuration Templates

Available in separate files:
- `templates/vpn-site-config.json` - VPN site configuration template
- `templates/branch-cpe-cisco.txt` - Cisco IOS XE configuration
- `templates/branch-cpe-fortinet.txt` - FortiGate configuration
- `templates/firewall-rules.json` - Azure Firewall rule templates
- `templates/nsg-rules.json` - Network Security Group templates

## Document Control

This document follows standard version control practices. All changes are tracked and approved through the document management system.

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [DATE] | Implementation Team | Initial release |

**Document Classification**: Confidential - Internal Use Only

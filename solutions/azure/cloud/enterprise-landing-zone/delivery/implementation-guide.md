# Azure Enterprise Landing Zone - Implementation Guide

## Overview

This comprehensive implementation guide provides step-by-step instructions for deploying the Azure Enterprise Landing Zone following Microsoft's Cloud Adoption Framework (CAF) recommendations. The implementation follows a phased approach to minimize risk and ensure successful deployment.

**Implementation Timeline:** 8-12 weeks  
**Complexity Level:** Advanced  
**Prerequisites:** Azure administrative access, network planning, compliance requirements

## Implementation Phases

### Phase 1: Environment Preparation and Planning (Weeks 1-2)

#### 1.1 Prerequisites Validation

**Required Permissions:**
- Global Administrator in Azure Active Directory
- Owner role on Azure subscriptions
- Appropriate licensing for Azure AD Premium and security services

**Technical Prerequisites:**
```bash
# Verify Azure CLI version
az version
# Required: Azure CLI 2.37.0 or later

# Verify PowerShell modules
Get-InstalledModule -Name Az
# Required: Az PowerShell 8.0.0 or later

# Verify Terraform version
terraform version
# Required: Terraform 1.2.0 or later
```

**Network Planning Requirements:**
- IP address allocation for hub and spoke VNets
- On-premises network documentation
- ExpressRoute or VPN connectivity planning
- DNS architecture design

#### 1.2 Azure Tenant Preparation

**Configure Azure AD Tenant:**
```powershell
# Connect to Azure AD
Connect-AzureAD

# Configure conditional access policies
$policy = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessPolicy
$policy.DisplayName = "Require MFA for Azure Management"
$policy.State = "Enabled"

# Apply baseline security configuration
Set-AzureADDirectorySetting -Id $tenantId -DirectorySetting $securityDefaults
```

**Subscription Organization:**
```bash
# List available subscriptions
az account list --output table

# Create subscription aliases for automation
az account alias create --name "platform-identity" --billing-scope "/providers/Microsoft.Billing/billingAccounts/{billingAccountId}"
az account alias create --name "platform-management" --billing-scope "/providers/Microsoft.Billing/billingAccounts/{billingAccountId}"
az account alias create --name "platform-connectivity" --billing-scope "/providers/Microsoft.Billing/billingAccounts/{billingAccountId}"
```

#### 1.3 Infrastructure as Code Setup

**Repository Structure Creation:**
```bash
# Clone the enterprise landing zone repository
git clone https://github.com/Azure/Enterprise-Scale.git
cd Enterprise-Scale

# Create custom configuration directory
mkdir -p custom-config/{management-groups,policies,networking,security}

# Initialize Terraform workspace
terraform workspace new production
terraform workspace new nonproduction
terraform workspace new sandbox
```

### Phase 2: Management Groups and Governance (Weeks 2-3)

#### 2.1 Management Group Hierarchy Deployment

**Create Management Group Structure:**
```bash
# Deploy management groups using Terraform
cat > management-groups.tf << EOF
resource "azurerm_management_group" "enterprise_root" {
  name         = "mg-enterprise-root"
  display_name = "Enterprise Root"
}

resource "azurerm_management_group" "platform" {
  name                   = "mg-platform"
  display_name          = "Platform"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

resource "azurerm_management_group" "landing_zones" {
  name                   = "mg-landingzones"
  display_name          = "Landing Zones"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

resource "azurerm_management_group" "identity" {
  name                   = "mg-platform-identity"
  display_name          = "Platform Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  name                   = "mg-platform-management"
  display_name          = "Platform Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "connectivity" {
  name                   = "mg-platform-connectivity"
  display_name          = "Platform Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "corp" {
  name                   = "mg-landingzones-corp"
  display_name          = "Corporate Landing Zones"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "online" {
  name                   = "mg-landingzones-online"
  display_name          = "Online Landing Zones"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

resource "azurerm_management_group" "sandbox" {
  name                   = "mg-sandbox"
  display_name          = "Sandbox"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}

resource "azurerm_management_group" "decommissioned" {
  name                   = "mg-decommissioned"
  display_name          = "Decommissioned"
  parent_management_group_id = azurerm_management_group.enterprise_root.id
}
EOF

# Apply management group configuration
terraform init
terraform plan
terraform apply
```

#### 2.2 Azure Policy Implementation

**Deploy Foundation Policies:**
```bash
# Create policy definitions directory
mkdir -p policies/{definitions,initiatives,assignments}

# Deploy security baseline policies
cat > policies/definitions/require-resource-tags.json << EOF
{
  "properties": {
    "displayName": "Require specific tags on resources",
    "policyType": "Custom",
    "mode": "Indexed",
    "description": "Enforces the existence of required tags on resources",
    "parameters": {
      "tagNames": {
        "type": "Array",
        "metadata": {
          "displayName": "Tag Names",
          "description": "List of required tag names"
        },
        "defaultValue": ["Environment", "Owner", "CostCenter", "Application"]
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "notIn": [
              "Microsoft.Resources/subscriptions",
              "Microsoft.Resources/resourceGroups"
            ]
          },
          {
            "anyOf": [
              {
                "not": {
                  "field": "[concat('tags[', parameters('tagNames')[0], ']')]",
                  "exists": "true"
                }
              },
              {
                "not": {
                  "field": "[concat('tags[', parameters('tagNames')[1], ']')]",
                  "exists": "true"
                }
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "deny"
      }
    }
  }
}
EOF

# Deploy policy using Azure CLI
az policy definition create --name "require-resource-tags" --rules policies/definitions/require-resource-tags.json --management-group "mg-enterprise-root"
```

**Create Policy Initiative:**
```bash
# Create security baseline initiative
cat > policies/initiatives/security-baseline.json << EOF
{
  "properties": {
    "displayName": "Enterprise Security Baseline",
    "description": "Comprehensive security policies for enterprise landing zones",
    "policyDefinitions": [
      {
        "policyDefinitionId": "/providers/Microsoft.Management/managementGroups/mg-enterprise-root/providers/Microsoft.Authorization/policyDefinitions/require-resource-tags",
        "parameters": {}
      },
      {
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/0a15ec92-a229-4763-bb14-0ea34a568f8d",
        "parameters": {}
      }
    ]
  }
}
EOF

# Deploy initiative
az policy set-definition create --name "enterprise-security-baseline" --definitions policies/initiatives/security-baseline.json --management-group "mg-enterprise-root"
```

### Phase 3: Platform Subscriptions and Core Services (Weeks 3-5)

#### 3.1 Identity Platform Deployment

**Deploy Identity Subscription Resources:**
```bash
# Set identity subscription context
az account set --subscription "platform-identity"

# Create identity resource group
az group create --name "rg-identity-prod-eus2-001" --location "East US 2"

# Deploy Azure AD Connect infrastructure
cat > identity-platform.tf << EOF
resource "azurerm_resource_group" "identity" {
  name     = "rg-identity-prod-eus2-001"
  location = "East US 2"
  
  tags = {
    Environment = "Production"
    Owner       = "Platform Team"
    CostCenter  = "IT-Infrastructure"
    Application = "Identity Platform"
  }
}

resource "azurerm_virtual_network" "identity_vnet" {
  name                = "vnet-identity-prod-eus2-001"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  
  tags = azurerm_resource_group.identity.tags
}

resource "azurerm_subnet" "identity_subnet" {
  name                 = "snet-identity-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.identity.name
  virtual_network_name = azurerm_virtual_network.identity_vnet.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_network_security_group" "identity_nsg" {
  name                = "nsg-identity-prod-eus2-001"
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = azurerm_resource_group.identity.tags
}

resource "azurerm_key_vault" "identity_kv" {
  name                = "kv-identity-prod-eus2-001"
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  sku_name = "premium"
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.identity_subnet.id]
  }
  
  tags = azurerm_resource_group.identity.tags
}
EOF

# Deploy identity platform infrastructure
terraform plan
terraform apply
```

#### 3.2 Management Platform Deployment

**Deploy Management Subscription Resources:**
```bash
# Set management subscription context
az account set --subscription "platform-management"

# Create management platform resources
cat > management-platform.tf << EOF
resource "azurerm_resource_group" "management" {
  name     = "rg-management-prod-eus2-001"
  location = "East US 2"
  
  tags = {
    Environment = "Production"
    Owner       = "Platform Team"
    CostCenter  = "IT-Infrastructure"
    Application = "Management Platform"
  }
}

resource "azurerm_log_analytics_workspace" "management" {
  name                = "law-management-prod-eus2-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  
  tags = azurerm_resource_group.management.tags
}

resource "azurerm_automation_account" "management" {
  name                = "aa-management-prod-eus2-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku_name           = "Basic"
  
  tags = azurerm_resource_group.management.tags
}

resource "azurerm_log_analytics_linked_service" "management" {
  resource_group_name = azurerm_resource_group.management.name
  workspace_id        = azurerm_log_analytics_workspace.management.id
  read_access_id      = azurerm_automation_account.management.id
}

resource "azurerm_recovery_services_vault" "management" {
  name                = "rsv-management-prod-eus2-001"
  location            = azurerm_resource_group.management.location
  resource_group_name = azurerm_resource_group.management.name
  sku                 = "Standard"
  
  soft_delete_enabled = true
  
  tags = azurerm_resource_group.management.tags
}
EOF

# Deploy management platform
terraform plan
terraform apply
```

#### 3.3 Connectivity Platform Deployment

**Deploy Hub Network Infrastructure:**
```bash
# Set connectivity subscription context
az account set --subscription "platform-connectivity"

# Create connectivity platform resources
cat > connectivity-platform.tf << EOF
resource "azurerm_resource_group" "connectivity" {
  name     = "rg-connectivity-prod-eus2-001"
  location = "East US 2"
  
  tags = {
    Environment = "Production"
    Owner       = "Platform Team"
    CostCenter  = "IT-Infrastructure"
    Application = "Connectivity Platform"
  }
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-hub-prod-eus2-001"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  tags = azurerm_resource_group.connectivity.tags
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.10.0.0/24"]
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_public_ip" "firewall_pip" {
  name                = "pip-firewall-prod-eus2-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = azurerm_resource_group.connectivity.tags
}

resource "azurerm_firewall" "hub_firewall" {
  name                = "afw-hub-prod-eus2-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
  
  tags = azurerm_resource_group.connectivity.tags
}

resource "azurerm_public_ip" "vpn_gateway_pip" {
  name                = "pip-vpn-gateway-prod-eus2-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  allocation_method   = "Dynamic"
  
  tags = azurerm_resource_group.connectivity.tags
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "vgw-vpn-prod-eus2-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  type     = "Vpn"
  vpn_type = "RouteBased"
  
  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"
  
  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
  
  tags = azurerm_resource_group.connectivity.tags
}

# Route table for spoke networks
resource "azurerm_route_table" "spoke_rt" {
  name                = "rt-spoke-prod-eus2-001"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  
  route {
    name                   = "default-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  }
  
  tags = azurerm_resource_group.connectivity.tags
}
EOF

# Deploy connectivity platform
terraform plan
terraform apply
```

### Phase 4: Landing Zone Deployment (Weeks 5-8)

#### 4.1 Corporate Landing Zone

**Deploy Production Corporate Landing Zone:**
```bash
# Create new subscription for corporate workloads
az account alias create --name "corp-prod" --billing-scope "/providers/Microsoft.Billing/billingAccounts/{billingAccountId}"

# Set subscription context
az account set --subscription "corp-prod"

# Deploy corporate landing zone
cat > corp-landing-zone.tf << EOF
resource "azurerm_resource_group" "corp_prod" {
  name     = "rg-corp-prod-eus2-001"
  location = "East US 2"
  
  tags = {
    Environment = "Production"
    Owner       = "Business Unit"
    CostCenter  = "BU-Operations"
    Application = "Corporate Workloads"
  }
}

resource "azurerm_virtual_network" "corp_spoke_vnet" {
  name                = "vnet-corp-prod-eus2-001"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.corp_prod.location
  resource_group_name = azurerm_resource_group.corp_prod.name
  
  tags = azurerm_resource_group.corp_prod.tags
}

resource "azurerm_subnet" "corp_workload_subnet" {
  name                 = "snet-workload-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.corp_prod.name
  virtual_network_name = azurerm_virtual_network.corp_spoke_vnet.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "corp_data_subnet" {
  name                 = "snet-data-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.corp_prod.name
  virtual_network_name = azurerm_virtual_network.corp_spoke_vnet.name
  address_prefixes     = ["10.20.2.0/24"]
}

# VNet peering to hub
resource "azurerm_virtual_network_peering" "corp_to_hub" {
  name                = "peer-corp-to-hub"
  resource_group_name = azurerm_resource_group.corp_prod.name
  virtual_network_name = azurerm_virtual_network.corp_spoke_vnet.name
  remote_virtual_network_id = "/subscriptions/{connectivity-subscription-id}/resourceGroups/rg-connectivity-prod-eus2-001/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod-eus2-001"
}

resource "azurerm_virtual_network_peering" "hub_to_corp" {
  name                = "peer-hub-to-corp"
  resource_group_name = "rg-connectivity-prod-eus2-001"
  virtual_network_name = "vnet-hub-prod-eus2-001"
  remote_virtual_network_id = azurerm_virtual_network.corp_spoke_vnet.id
  provider = azurerm.connectivity
}

# Network Security Groups
resource "azurerm_network_security_group" "corp_workload_nsg" {
  name                = "nsg-workload-prod-eus2-001"
  location            = azurerm_resource_group.corp_prod.location
  resource_group_name = azurerm_resource_group.corp_prod.name
  
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.10.0.0/16"
    destination_address_prefix = "*"
  }
  
  tags = azurerm_resource_group.corp_prod.tags
}

resource "azurerm_subnet_network_security_group_association" "corp_workload_nsg_assoc" {
  subnet_id                 = azurerm_subnet.corp_workload_subnet.id
  network_security_group_id = azurerm_network_security_group.corp_workload_nsg.id
}

# Associate route table
resource "azurerm_subnet_route_table_association" "corp_workload_rt_assoc" {
  subnet_id      = azurerm_subnet.corp_workload_subnet.id
  route_table_id = "/subscriptions/{connectivity-subscription-id}/resourceGroups/rg-connectivity-prod-eus2-001/providers/Microsoft.Network/routeTables/rt-spoke-prod-eus2-001"
}
EOF

# Deploy corporate landing zone
terraform plan
terraform apply
```

#### 4.2 Online Landing Zone

**Deploy Internet-Facing Application Landing Zone:**
```bash
# Create subscription for online workloads
az account alias create --name "online-prod" --billing-scope "/providers/Microsoft.Billing/billingAccounts/{billingAccountId}"
az account set --subscription "online-prod"

# Deploy online landing zone with additional security
cat > online-landing-zone.tf << EOF
resource "azurerm_resource_group" "online_prod" {
  name     = "rg-online-prod-eus2-001"
  location = "East US 2"
  
  tags = {
    Environment = "Production"
    Owner       = "Digital Team"
    CostCenter  = "DIG-Operations"
    Application = "Online Services"
  }
}

resource "azurerm_virtual_network" "online_spoke_vnet" {
  name                = "vnet-online-prod-eus2-001"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.online_prod.location
  resource_group_name = azurerm_resource_group.online_prod.name
  
  tags = azurerm_resource_group.online_prod.tags
}

resource "azurerm_subnet" "online_web_subnet" {
  name                 = "snet-web-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.online_prod.name
  virtual_network_name = azurerm_virtual_network.online_spoke_vnet.name
  address_prefixes     = ["10.30.1.0/24"]
}

resource "azurerm_subnet" "online_app_subnet" {
  name                 = "snet-app-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.online_prod.name
  virtual_network_name = azurerm_virtual_network.online_spoke_vnet.name
  address_prefixes     = ["10.30.2.0/24"]
}

resource "azurerm_subnet" "online_data_subnet" {
  name                 = "snet-data-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.online_prod.name
  virtual_network_name = azurerm_virtual_network.online_spoke_vnet.name
  address_prefixes     = ["10.30.3.0/24"]
}

# Application Gateway subnet (for internet-facing apps)
resource "azurerm_subnet" "online_appgw_subnet" {
  name                 = "snet-appgw-prod-eus2-001"
  resource_group_name  = azurerm_resource_group.online_prod.name
  virtual_network_name = azurerm_virtual_network.online_spoke_vnet.name
  address_prefixes     = ["10.30.0.0/24"]
}

# Web Application Firewall
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw-prod-eus2-001"
  location            = azurerm_resource_group.online_prod.location
  resource_group_name = azurerm_resource_group.online_prod.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = azurerm_resource_group.online_prod.tags
}

resource "azurerm_application_gateway" "online_appgw" {
  name                = "appgw-online-prod-eus2-001"
  resource_group_name = azurerm_resource_group.online_prod.name
  location            = azurerm_resource_group.online_prod.location
  
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.online_appgw_subnet.id
  }
  
  frontend_port {
    name = "frontend-port"
    port = 443
  }
  
  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }
  
  backend_address_pool {
    name = "backend-pool"
  }
  
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port"
    protocol                       = "Https"
  }
  
  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }
  
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
  
  tags = azurerm_resource_group.online_prod.tags
}
EOF

terraform plan
terraform apply
```

### Phase 5: Security and Compliance (Weeks 8-10)

#### 5.1 Azure Security Center Configuration

**Enable Security Center and Defender:**
```bash
# Enable Security Center for all subscriptions
for subscription in $(az account list --query '[].id' -o tsv); do
  az account set --subscription $subscription
  
  # Enable Security Center Standard tier
  az security pricing create --name "VirtualMachines" --tier "Standard"
  az security pricing create --name "StorageAccounts" --tier "Standard"
  az security pricing create --name "SqlServers" --tier "Standard"
  az security pricing create --name "KeyVaults" --tier "Standard"
  az security pricing create --name "AppServices" --tier "Standard"
  az security pricing create --name "KubernetesService" --tier "Standard"
  
  # Configure data collection
  az security workspace-setting create --name "default" --target-workspace "/subscriptions/{management-subscription}/resourceGroups/rg-management-prod-eus2-001/providers/Microsoft.OperationalInsights/workspaces/law-management-prod-eus2-001"
  
  # Enable auto-provisioning
  az security auto-provisioning-setting update --name "default" --auto-provision "On"
done
```

#### 5.2 Azure Sentinel Deployment

**Deploy Sentinel in Management Subscription:**
```bash
# Set management subscription context
az account set --subscription "platform-management"

# Enable Sentinel
az sentinel workspace create --resource-group "rg-management-prod-eus2-001" --workspace-name "law-management-prod-eus2-001"

# Deploy analytics rules
cat > sentinel-analytics-rules.json << EOF
{
  "properties": {
    "displayName": "Suspicious Sign-in Activity",
    "description": "Detects suspicious sign-in patterns",
    "severity": "Medium",
    "enabled": true,
    "query": "SigninLogs | where ResultType != 0 | summarize count() by UserPrincipalName, IPAddress | where count_ > 10",
    "queryFrequency": "PT1H",
    "queryPeriod": "PT1H",
    "triggerOperator": "GreaterThan",
    "triggerThreshold": 1,
    "suppressionDuration": "PT1H",
    "suppressionEnabled": false
  }
}
EOF

# Create analytics rule
az sentinel alert-rule create --resource-group "rg-management-prod-eus2-001" --workspace-name "law-management-prod-eus2-001" --rule-name "suspicious-signin" --rule sentinel-analytics-rules.json
```

### Phase 6: Monitoring and Optimization (Weeks 10-12)

#### 6.1 Comprehensive Monitoring Setup

**Deploy Azure Monitor and Log Analytics:**
```bash
# Configure diagnostic settings for all resources
for subscription in $(az account list --query '[].id' -o tsv); do
  az account set --subscription $subscription
  
  # Get all resource groups
  for rg in $(az group list --query '[].name' -o tsv); do
    # Configure diagnostic settings for resource group
    az monitor diagnostic-settings create \
      --name "diag-${rg}" \
      --resource "/subscriptions/${subscription}/resourceGroups/${rg}" \
      --workspace "/subscriptions/{management-subscription}/resourceGroups/rg-management-prod-eus2-001/providers/Microsoft.OperationalInsights/workspaces/law-management-prod-eus2-001" \
      --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"ServiceHealth","enabled":true},{"category":"Alert","enabled":true},{"category":"Recommendation","enabled":true},{"category":"Policy","enabled":true},{"category":"Autoscale","enabled":true},{"category":"ResourceHealth","enabled":true}]'
  done
done
```

#### 6.2 Cost Management Configuration

**Configure Cost Management and Budgets:**
```bash
# Create budget for each subscription
for subscription in $(az account list --query '[].id' -o tsv); do
  subscription_name=$(az account show --subscription $subscription --query 'name' -o tsv)
  
  # Create monthly budget
  az consumption budget create \
    --subscription $subscription \
    --budget-name "budget-${subscription_name}-monthly" \
    --amount 10000 \
    --time-grain Monthly \
    --start-date $(date -d "first day of this month" +%Y-%m-01T00:00:00Z) \
    --end-date $(date -d "first day of next year" +%Y-01-01T00:00:00Z) \
    --notifications amount=80,threshold-type=Actual,contact-emails=['admin@company.com'] \
    --notifications amount=100,threshold-type=Forecasted,contact-emails=['admin@company.com']
done
```

## Post-Deployment Validation

### Connectivity Testing
```bash
# Test hub-spoke connectivity
./scripts/test-connectivity.sh

# Validate firewall rules
az network firewall application-rule list --resource-group "rg-connectivity-prod-eus2-001" --firewall-name "afw-hub-prod-eus2-001"

# Test VPN connectivity
az network vnet-gateway list-bgp-peer-status --name "vgw-vpn-prod-eus2-001" --resource-group "rg-connectivity-prod-eus2-001"
```

### Security Validation
```bash
# Security Center compliance scan
az security task list --resource-group "rg-management-prod-eus2-001"

# Policy compliance check
az policy state list --management-group "mg-enterprise-root"

# Key Vault access validation
az keyvault secret list --vault-name "kv-identity-prod-eus2-001"
```

### Performance Testing
```bash
# Network latency testing
./scripts/network-latency-test.sh

# Resource utilization check
az monitor metrics list --resource "/subscriptions/{subscription}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm}" --metric "Percentage CPU"
```

This comprehensive implementation guide provides the foundation for deploying an enterprise-grade Azure landing zone that meets security, compliance, and governance requirements while enabling scalable cloud operations.
# Azure Enterprise Landing Zone - Training Materials

## Overview

This comprehensive training curriculum provides structured learning paths for all stakeholders involved in the Azure Enterprise Landing Zone platform. The training materials are organized by role and include theoretical concepts, hands-on exercises, and practical scenarios to ensure effective knowledge transfer and operational readiness.

**Training Program Duration:** 5 days (40 hours)  
**Delivery Format:** Instructor-led with hands-on labs  
**Prerequisites:** Basic cloud computing knowledge  
**Certification:** Azure Fundamentals recommended

## Training Program Structure

### Learning Tracks

1. **Executive Track** (4 hours): Strategic overview and business value
2. **Platform Administrator Track** (40 hours): Complete technical training
3. **Business User Track** (8 hours): Usage and governance focus
4. **Developer Track** (16 hours): Application deployment and integration

### Training Delivery Methods

- **In-Person Workshops**: Instructor-led training with hands-on labs
- **Virtual Training**: Remote delivery with interactive components
- **Self-Paced Learning**: Documentation and recorded materials
- **Mentoring**: One-on-one support for complex topics

## Executive Track (4 Hours)

### Module E1: Azure Enterprise Landing Zone Strategic Overview (1 Hour)

#### Learning Objectives
- Understand the business value of Azure Enterprise Landing Zone
- Recognize the strategic impact on digital transformation
- Identify key success metrics and ROI drivers

#### Content Outline
**Business Case and Value Proposition (20 minutes)**
```
Business Drivers
├── Cost Optimization
│   ├── 60-80% reduction in infrastructure costs
│   ├── Elimination of manual processes
│   └── Resource utilization optimization
├── Operational Efficiency  
│   ├── Automated provisioning and governance
│   ├── Centralized management and monitoring
│   └── Standardized security and compliance
├── Innovation Acceleration
│   ├── Self-service capabilities for development teams
│   ├── Faster time-to-market for applications
│   └── Foundation for advanced cloud services
└── Risk Mitigation
    ├── Enhanced security posture
    ├── Automated compliance monitoring
    └── Disaster recovery and business continuity
```

**Digital Transformation Impact (15 minutes)**
- Cloud-first strategy alignment
- Organizational agility and scalability
- Competitive advantage through technology

**Financial Analysis (15 minutes)**
- Total Cost of Ownership (TCO) comparison
- Return on Investment (ROI) projections
- Budget allocation and cost management

**Implementation Roadmap (10 minutes)**
- Phased deployment approach
- Timeline and milestones
- Resource requirements and dependencies

#### Executive Presentation Materials
```markdown
# Slide 1: Enterprise Landing Zone Value Proposition
**Transforming IT Infrastructure for Digital Success**

Key Benefits:
- 10x faster application deployment
- 300-400% ROI within 24 months  
- 99.9% infrastructure availability
- Enterprise-grade security and compliance

# Slide 2: Financial Impact
**3-Year Financial Projection**

Investment: $2.5M
Benefits: $15M
Net ROI: 500%
Payback Period: 16 months

# Slide 3: Strategic Alignment
**Supporting Business Objectives**

- Accelerate digital transformation initiatives
- Enable cloud-first technology strategy
- Improve operational efficiency and agility
- Reduce technology debt and complexity
```

### Module E2: Governance and Compliance Framework (1 Hour)

#### Learning Objectives
- Understand enterprise governance requirements
- Learn about compliance and security standards
- Review policy management and enforcement

#### Content Outline
**Enterprise Governance Model (20 minutes)**
- Management group hierarchy and organization
- Role-based access control (RBAC) strategy
- Resource organization and naming conventions
- Cost management and budget controls

**Compliance and Security (20 minutes)**
- Industry regulatory requirements
- Azure Policy framework and enforcement
- Security Center and compliance monitoring
- Audit and reporting capabilities

**Risk Management (10 minutes)**
- Security risk assessment and mitigation
- Operational risk controls
- Business continuity planning

**Policy Management (10 minutes)**
- Policy definition and assignment
- Exception handling processes
- Continuous improvement and optimization

### Module E3: Operational Model and Support (1 Hour)

#### Learning Objectives
- Understand the operational support model
- Learn about service level agreements
- Review change management processes

#### Content Outline
**Service Management Framework (20 minutes)**
- Platform operations team structure
- Service level agreements and metrics
- Incident response and escalation procedures
- Performance monitoring and optimization

**Change Management Process (20 minutes)**
- Infrastructure change approval workflow
- Testing and validation requirements
- Rollback procedures and contingency planning
- Communication and stakeholder management

**Continuous Improvement (20 minutes)**
- Performance metrics and KPI tracking
- Regular assessment and optimization
- Technology roadmap and evolution planning
- Feedback collection and implementation

### Module E4: Success Metrics and KPIs (1 Hour)

#### Learning Objectives
- Define success criteria and measurement
- Establish key performance indicators
- Review reporting and dashboard capabilities

#### Content Outline
**Business KPIs (15 minutes)**
- Application deployment velocity
- Infrastructure cost optimization
- Service availability and reliability
- Security incident reduction

**Technical KPIs (15 minutes)**
- Network performance and latency
- Resource utilization efficiency
- Automated provisioning success rate
- Compliance score and policy adherence

**Operational KPIs (15 minutes)**
- Incident response time and resolution
- Change success rate and rollback frequency
- User satisfaction and support ticket volume
- Training completion and skill development

**Reporting and Dashboards (15 minutes)**
- Executive dashboard and scorecards
- Operational monitoring and alerting
- Cost management and budget tracking
- Compliance and security reporting

## Platform Administrator Track (40 Hours)

### Day 1: Foundation and Architecture (8 Hours)

#### Module A1: Azure Enterprise Landing Zone Architecture (2 Hours)

##### Learning Objectives
- Master the hub-spoke network architecture
- Understand management group hierarchy
- Learn subscription organization strategies

##### Hands-on Lab: Architecture Exploration
```powershell
# Lab Exercise: Explore Management Group Structure
# Duration: 30 minutes

# Connect to Azure
Connect-AzAccount
Set-AzContext -SubscriptionId $managementSubscriptionId

# Explore management group hierarchy
Write-Host "=== Management Group Structure ===" -ForegroundColor Green
$rootMG = Get-AzManagementGroup -GroupId "mg-enterprise-root" -Expand -Recurse

function Show-ManagementGroupHierarchy {
    param(
        [Parameter(Mandatory)]
        $ManagementGroup,
        [int]$IndentLevel = 0
    )
    
    $indent = "  " * $IndentLevel
    Write-Host "$indent$($ManagementGroup.DisplayName) ($($ManagementGroup.Name))" -ForegroundColor Yellow
    
    foreach ($child in $ManagementGroup.Children) {
        if ($child.Type -eq "Microsoft.Management/managementGroups") {
            $childMG = Get-AzManagementGroup -GroupId $child.Name -Expand
            Show-ManagementGroupHierarchy -ManagementGroup $childMG -IndentLevel ($IndentLevel + 1)
        } else {
            Write-Host "$indent  Subscription: $($child.DisplayName)" -ForegroundColor Cyan
        }
    }
}

Show-ManagementGroupHierarchy -ManagementGroup $rootMG

# Exercise Questions:
# 1. How many management groups are in the hierarchy?
# 2. Which subscriptions are assigned to each management group?
# 3. What policies are assigned at each level?
```

##### Lab Exercise: Network Architecture Analysis
```bash
#!/bin/bash
# Lab: Network Architecture Deep Dive
# Duration: 45 minutes

echo "=== Network Architecture Analysis ==="

# Explore hub virtual network
echo "--- Hub Virtual Network ---"
hub_vnet=$(az network vnet show --resource-group "rg-connectivity-prod-eus2-001" --name "vnet-hub-prod-eus2-001")
echo "Hub VNet Address Space: $(echo $hub_vnet | jq -r '.addressSpace.addressPrefixes[0]')"

# List all subnets in hub
echo "--- Hub Subnets ---"
az network vnet subnet list --resource-group "rg-connectivity-prod-eus2-001" --vnet-name "vnet-hub-prod-eus2-001" --query "[].{Name:name, AddressPrefix:addressPrefix, ProvisioningState:provisioningState}" --output table

# Explore spoke networks
echo "--- Spoke Virtual Networks ---"
for rg in $(az group list --query "[?contains(name, 'corp') || contains(name, 'online')].name" --output tsv); do
    echo "Resource Group: $rg"
    az network vnet list --resource-group $rg --query "[].{Name:name, AddressSpace:addressSpace.addressPrefixes[0], PeeringCount:virtualNetworkPeerings[length(@)]}" --output table
done

# Analyze VNet peering connections
echo "--- VNet Peering Analysis ---"
az network vnet peering list --resource-group "rg-connectivity-prod-eus2-001" --vnet-name "vnet-hub-prod-eus2-001" --query "[].{Name:name, RemoteVNet:remoteVirtualNetwork.id, PeeringState:peeringState, ProvisioningState:provisioningState}" --output table

# Exercise Tasks:
# 1. Document the IP address allocation strategy
# 2. Verify all spoke networks are properly peered
# 3. Check route table configurations
# 4. Validate NSG rules for each subnet
```

#### Module A2: Infrastructure as Code with Terraform (3 Hours)

##### Learning Objectives
- Master Terraform for Azure infrastructure deployment
- Understand state management and workspace strategies
- Learn modular infrastructure design patterns

##### Hands-on Lab: Terraform Infrastructure Deployment
```hcl
# Lab Exercise: Deploy a Spoke Network using Terraform
# Duration: 2 hours

# Create workspace directory
# mkdir terraform-lab && cd terraform-lab

# main.tf
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate001"
    container_name       = "tfstate"
    key                  = "training-lab.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Local values
locals {
  common_tags = {
    Environment = "Training"
    Owner       = "Platform Team"
    Purpose     = "Training Lab"
    DeleteAfter = formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))
  }
}

# Resource group
resource "azurerm_resource_group" "lab" {
  name     = "rg-training-lab-${random_integer.suffix.result}"
  location = "East US 2"
  tags     = local.common_tags
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}

# Virtual network
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-training-${random_integer.suffix.result}"
  address_space       = ["10.100.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags
}

# Subnets
resource "azurerm_subnet" "workload" {
  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.100.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.100.2.0/24"]
}

# Network Security Groups
resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload-training"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.10.0.0/16"  # Hub network
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.10.2.0/24"  # Bastion subnet
    destination_address_prefix = "*"
  }
  
  tags = local.common_tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}

output "virtual_network_id" {
  value = azurerm_virtual_network.spoke.id
}

output "workload_subnet_id" {
  value = azurerm_subnet.workload.id
}
```

##### Lab Exercise: Terraform State Management
```bash
#!/bin/bash
# Terraform State Management Lab
# Duration: 1 hour

echo "=== Terraform State Management Lab ==="

# Initialize Terraform
terraform init

# Create workspace for training
terraform workspace new training 2>/dev/null || terraform workspace select training

# Plan deployment
echo "Planning infrastructure deployment..."
terraform plan -out=tfplan

# Apply deployment
echo "Deploying infrastructure..."
terraform apply tfplan

# Explore state
echo "--- Terraform State Analysis ---"
terraform show
terraform state list

# Import existing resource (demonstration)
echo "--- State Import Demonstration ---"
# terraform import azurerm_resource_group.existing /subscriptions/{subscription-id}/resourceGroups/{existing-rg-name}

# State manipulation commands
echo "--- State Commands ---"
terraform state show azurerm_resource_group.lab
terraform output

# Lab Questions:
echo "=== Lab Exercise Questions ==="
echo "1. How many resources are in the Terraform state?"
echo "2. What is the resource ID of the virtual network?"
echo "3. How would you add a new subnet to this configuration?"
echo "4. What happens if you run 'terraform plan' again?"

# Cleanup (commented out for learning - students should run manually)
# terraform destroy -auto-approve
# terraform workspace select default
# terraform workspace delete training
```

#### Module A3: Azure Policy and Governance (2 Hours)

##### Learning Objectives
- Understand Azure Policy framework
- Learn policy definition and assignment
- Master compliance monitoring and reporting

##### Hands-on Lab: Policy Implementation
```powershell
# Lab Exercise: Implement Custom Azure Policies
# Duration: 1.5 hours

Write-Host "=== Azure Policy Implementation Lab ===" -ForegroundColor Green

# Policy Definition: Require specific tags
$tagPolicyDefinition = @"
{
  "properties": {
    "displayName": "Require Training Lab Tags",
    "policyType": "Custom",
    "mode": "Indexed",
    "description": "This policy requires specific tags on all resources in training environments",
    "parameters": {
      "requiredTags": {
        "type": "Object",
        "metadata": {
          "displayName": "Required Tags",
          "description": "Object containing required tag names and values"
        },
        "defaultValue": {
          "Environment": "Training",
          "Owner": "Platform Team",
          "DeleteAfter": ""
        }
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "notEquals": "Microsoft.Resources/subscriptions"
          },
          {
            "anyOf": [
              {
                "not": {
                  "field": "tags['Environment']",
                  "equals": "[parameters('requiredTags')['Environment']]"
                }
              },
              {
                "not": {
                  "field": "tags['Owner']",
                  "equals": "[parameters('requiredTags')['Owner']]"
                }
              },
              {
                "field": "tags['DeleteAfter']",
                "exists": "false"
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
"@

# Create custom policy definition
Write-Host "Creating custom policy definition..." -ForegroundColor Yellow
$policyDef = New-AzPolicyDefinition -Name "require-training-tags" -Policy $tagPolicyDefinition -ManagementGroupName "mg-enterprise-root"

Write-Host "Policy Definition created: $($policyDef.Name)" -ForegroundColor Green

# Create policy assignment
Write-Host "Assigning policy to training resource group..." -ForegroundColor Yellow

$rgScope = "/subscriptions/$((Get-AzContext).Subscription.Id)/resourceGroups/rg-training-*"
$policyAssignment = New-AzPolicyAssignment -Name "training-tag-enforcement" -PolicyDefinition $policyDef -Scope $rgScope

Write-Host "Policy assigned successfully" -ForegroundColor Green

# Test policy enforcement
Write-Host "Testing policy enforcement..." -ForegroundColor Yellow

# This should fail due to missing tags
try {
    $testStorage = New-AzStorageAccount -ResourceGroupName "rg-training-test" -Name "sttest$(Get-Random)" -Location "East US 2" -SkuName "Standard_LRS"
    Write-Host "ERROR: Resource created without required tags!" -ForegroundColor Red
}
catch {
    Write-Host "SUCCESS: Policy correctly denied resource creation" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# This should succeed with proper tags
try {
    $properTags = @{
        Environment = "Training"
        Owner = "Platform Team"
        DeleteAfter = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    }
    
    $testStorage = New-AzStorageAccount -ResourceGroupName "rg-training-test" -Name "sttest$(Get-Random)" -Location "East US 2" -SkuName "Standard_LRS" -Tag $properTags
    Write-Host "SUCCESS: Resource created with proper tags" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Resource creation failed even with proper tags" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Check policy compliance
Write-Host "Checking policy compliance..." -ForegroundColor Yellow
Start-Sleep -Seconds 30  # Wait for compliance evaluation

$complianceResults = Get-AzPolicyState | Where-Object { $_.PolicyAssignmentName -eq "training-tag-enforcement" }
$complianceResults | Format-Table ResourceId, ComplianceState, PolicyDefinitionName

Write-Host "=== Lab Exercise Complete ===" -ForegroundColor Green
```

#### Module A4: Security and Compliance Implementation (1 Hour)

##### Learning Objectives
- Configure Security Center and Defender
- Implement Key Vault security practices
- Set up compliance monitoring

##### Lab Exercise: Security Configuration
```bash
#!/bin/bash
# Security Configuration Lab
# Duration: 1 hour

echo "=== Security Configuration Lab ==="

# Enable Security Center Standard tier
echo "--- Enabling Security Center ---"
az security pricing create --name "VirtualMachines" --tier "Standard"
az security pricing create --name "StorageAccounts" --tier "Standard"
az security pricing create --name "SqlServers" --tier "Standard"
az security pricing create --name "KeyVaults" --tier "Standard"

echo "Security Center Standard tier enabled"

# Configure Key Vault with security best practices
echo "--- Creating Secure Key Vault ---"
KV_NAME="kv-training-$(date +%s)"
RESOURCE_GROUP="rg-training-security"

# Create resource group
az group create --name $RESOURCE_GROUP --location "East US 2" --tags Environment=Training Owner="Platform Team"

# Create Key Vault with security features
az keyvault create \
    --name $KV_NAME \
    --resource-group $RESOURCE_GROUP \
    --location "East US 2" \
    --enable-soft-delete true \
    --enable-purge-protection true \
    --retention-days 90 \
    --sku premium \
    --tags Environment=Training Owner="Platform Team"

# Configure network access restrictions
az keyvault network-rule add --name $KV_NAME --vnet-name "vnet-hub-prod-eus2-001" --subnet "AzureBastionSubnet"
az keyvault update --name $KV_NAME --default-action Deny

echo "Key Vault $KV_NAME created with security features"

# Create and store secrets
echo "--- Managing Key Vault Secrets ---"
az keyvault secret set --vault-name $KV_NAME --name "training-secret" --value "SecurePassword123!"
az keyvault secret set --vault-name $KV_NAME --name "api-key" --value "abcdef123456"

# Set secret expiration
EXPIRY_DATE=$(date -d "+30 days" +%Y-%m-%dT%H:%M:%SZ)
az keyvault secret set-attributes --vault-name $KV_NAME --name "training-secret" --expires $EXPIRY_DATE

# Test secret retrieval
echo "Testing secret retrieval..."
SECRET_VALUE=$(az keyvault secret show --vault-name $KV_NAME --name "training-secret" --query "value" --output tsv)
if [ -n "$SECRET_VALUE" ]; then
    echo "SUCCESS: Secret retrieved successfully"
else
    echo "ERROR: Failed to retrieve secret"
fi

# Security assessment
echo "--- Security Assessment ---"
az security task list --resource-group $RESOURCE_GROUP --query "[].{Name:displayName, Severity:severity, State:state}" --output table

echo "=== Security Lab Complete ==="
echo "Key Vault Name: $KV_NAME"
echo "Resource Group: $RESOURCE_GROUP"
```

### Day 2: Network and Connectivity (8 Hours)

#### Module B1: Hub-Spoke Network Implementation (3 Hours)

##### Learning Objectives
- Implement hub-spoke network architecture
- Configure VNet peering and routing
- Set up hybrid connectivity

##### Hands-on Lab: Network Architecture Deployment
```powershell
# Lab Exercise: Implement Hub-Spoke Network
# Duration: 2.5 hours

param(
    [string]$HubResourceGroup = "rg-training-hub",
    [string]$SpokeResourceGroup = "rg-training-spoke",
    [string]$Location = "East US 2"
)

Write-Host "=== Hub-Spoke Network Implementation Lab ===" -ForegroundColor Green

# Create resource groups
Write-Host "Creating resource groups..." -ForegroundColor Yellow
New-AzResourceGroup -Name $HubResourceGroup -Location $Location -Tag @{Environment="Training"; Purpose="Hub Network"}
New-AzResourceGroup -Name $SpokeResourceGroup -Location $Location -Tag @{Environment="Training"; Purpose="Spoke Network"}

# Create Hub Virtual Network
Write-Host "Creating Hub Virtual Network..." -ForegroundColor Yellow
$hubVNet = New-AzVirtualNetwork -ResourceGroupName $HubResourceGroup -Location $Location -Name "vnet-training-hub" -AddressPrefix "10.200.0.0/16"

# Create Hub Subnets
Write-Host "Creating Hub subnets..." -ForegroundColor Yellow

# Gateway subnet
$hubVNet | Add-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -AddressPrefix "10.200.0.0/24"

# Azure Firewall subnet
$hubVNet | Add-AzVirtualNetworkSubnetConfig -Name "AzureFirewallSubnet" -AddressPrefix "10.200.1.0/24"

# Bastion subnet
$hubVNet | Add-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix "10.200.2.0/24"

# Shared services subnet
$hubVNet | Add-AzVirtualNetworkSubnetConfig -Name "SharedServicesSubnet" -AddressPrefix "10.200.3.0/24"

# Apply subnet configuration
$hubVNet | Set-AzVirtualNetwork

Write-Host "Hub VNet created successfully" -ForegroundColor Green

# Create Spoke Virtual Network
Write-Host "Creating Spoke Virtual Network..." -ForegroundColor Yellow
$spokeVNet = New-AzVirtualNetwork -ResourceGroupName $SpokeResourceGroup -Location $Location -Name "vnet-training-spoke" -AddressPrefix "10.201.0.0/16"

# Create Spoke Subnets
$spokeVNet | Add-AzVirtualNetworkSubnetConfig -Name "WorkloadSubnet" -AddressPrefix "10.201.1.0/24"
$spokeVNet | Add-AzVirtualNetworkSubnetConfig -Name "DataSubnet" -AddressPrefix "10.201.2.0/24"
$spokeVNet | Set-AzVirtualNetwork

Write-Host "Spoke VNet created successfully" -ForegroundColor Green

# Create VNet Peering
Write-Host "Creating VNet peering..." -ForegroundColor Yellow

# Hub to Spoke peering
$hubToSpokePeering = Add-AzVirtualNetworkPeering -Name "hub-to-spoke" -VirtualNetwork $hubVNet -RemoteVirtualNetworkId $spokeVNet.Id -AllowForwardedTraffic -AllowGatewayTransit

# Spoke to Hub peering
$spokeToHubPeering = Add-AzVirtualNetworkPeering -Name "spoke-to-hub" -VirtualNetwork $spokeVNet -RemoteVirtualNetworkId $hubVNet.Id -AllowForwardedTraffic -UseRemoteGateways

Write-Host "VNet peering configured successfully" -ForegroundColor Green

# Create Route Table for Spoke
Write-Host "Creating route table..." -ForegroundColor Yellow
$routeTable = New-AzRouteTable -ResourceGroupName $SpokeResourceGroup -Location $Location -Name "rt-spoke-training"

# Add default route (will point to firewall when deployed)
$routeTable | Add-AzRouteConfig -Name "DefaultRoute" -AddressPrefix "0.0.0.0/0" -NextHopType "VirtualAppliance" -NextHopIpAddress "10.200.1.4" | Set-AzRouteTable

# Associate route table with spoke subnets
$spokeVNet = Get-AzVirtualNetwork -ResourceGroupName $SpokeResourceGroup -Name "vnet-training-spoke"
$workloadSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $spokeVNet -Name "WorkloadSubnet"
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spokeVNet -Name "WorkloadSubnet" -AddressPrefix $workloadSubnet.AddressPrefix -RouteTable $routeTable | Set-AzVirtualNetwork

Write-Host "Route table configured successfully" -ForegroundColor Green

# Create Network Security Groups
Write-Host "Creating Network Security Groups..." -ForegroundColor Yellow

# Hub NSG
$hubNSG = New-AzNetworkSecurityGroup -ResourceGroupName $HubResourceGroup -Location $Location -Name "nsg-training-hub"

# Spoke NSG with security rules
$spokeNSG = New-AzNetworkSecurityGroup -ResourceGroupName $SpokeResourceGroup -Location $Location -Name "nsg-training-spoke"

# Add security rules to spoke NSG
$spokeNSG | Add-AzNetworkSecurityRuleConfig -Name "AllowHTTPS" -Description "Allow HTTPS from Hub" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix "10.200.0.0/16" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "443" | Set-AzNetworkSecurityGroup

$spokeNSG | Add-AzNetworkSecurityRuleConfig -Name "AllowSSHFromBastion" -Description "Allow SSH from Bastion" -Access Allow -Protocol Tcp -Direction Inbound -Priority 1001 -SourceAddressPrefix "10.200.2.0/24" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange "22" | Set-AzNetworkSecurityGroup

# Associate NSG with subnets
$spokeVNet = Get-AzVirtualNetwork -ResourceGroupName $SpokeResourceGroup -Name "vnet-training-spoke"
$workloadSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $spokeVNet -Name "WorkloadSubnet"
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $spokeVNet -Name "WorkloadSubnet" -AddressPrefix $workloadSubnet.AddressPrefix -RouteTable $routeTable -NetworkSecurityGroup $spokeNSG | Set-AzVirtualNetwork

Write-Host "Network Security Groups configured successfully" -ForegroundColor Green

# Verification
Write-Host "=== Network Configuration Verification ===" -ForegroundColor Cyan

# Check VNet peering status
$hubPeering = Get-AzVirtualNetworkPeering -VirtualNetworkName "vnet-training-hub" -ResourceGroupName $HubResourceGroup
$spokePeering = Get-AzVirtualNetworkPeering -VirtualNetworkName "vnet-training-spoke" -ResourceGroupName $SpokeResourceGroup

Write-Host "Hub to Spoke Peering: $($hubPeering.PeeringState)" -ForegroundColor White
Write-Host "Spoke to Hub Peering: $($spokePeering.PeeringState)" -ForegroundColor White

# List all subnets
Write-Host "`nHub VNet Subnets:" -ForegroundColor White
Get-AzVirtualNetwork -ResourceGroupName $HubResourceGroup -Name "vnet-training-hub" | Get-AzVirtualNetworkSubnetConfig | Format-Table Name, AddressPrefix

Write-Host "Spoke VNet Subnets:" -ForegroundColor White
Get-AzVirtualNetwork -ResourceGroupName $SpokeResourceGroup -Name "vnet-training-spoke" | Get-AzVirtualNetworkSubnetConfig | Format-Table Name, AddressPrefix

Write-Host "=== Hub-Spoke Network Lab Complete ===" -ForegroundColor Green

# Lab exercises for students:
Write-Host "`n=== Lab Exercises ===" -ForegroundColor Yellow
Write-Host "1. Deploy a test VM in the spoke network"
Write-Host "2. Verify connectivity between hub and spoke"
Write-Host "3. Test NSG rules by attempting different connections"
Write-Host "4. Add an additional spoke network and configure peering"
```

#### Module B2: Azure Firewall and Security (2 Hours)

##### Learning Objectives
- Deploy and configure Azure Firewall
- Implement network and application rules
- Set up threat intelligence and monitoring

##### Lab Exercise: Azure Firewall Implementation
```bash
#!/bin/bash
# Azure Firewall Implementation Lab
# Duration: 1.5 hours

echo "=== Azure Firewall Implementation Lab ==="

HUB_RG="rg-training-hub"
HUB_VNET="vnet-training-hub"
FIREWALL_NAME="afw-training-hub"
LOCATION="East US 2"

# Create public IP for Azure Firewall
echo "--- Creating Azure Firewall Public IP ---"
az network public-ip create \
    --name "pip-$FIREWALL_NAME" \
    --resource-group $HUB_RG \
    --location "$LOCATION" \
    --allocation-method Static \
    --sku Standard \
    --tags Environment=Training Purpose="Firewall"

echo "Public IP created successfully"

# Create Azure Firewall
echo "--- Creating Azure Firewall ---"
az network firewall create \
    --name $FIREWALL_NAME \
    --resource-group $HUB_RG \
    --location "$LOCATION" \
    --tier Standard \
    --sku AZFW_VNet \
    --tags Environment=Training Purpose="Hub Firewall"

# Configure Azure Firewall
echo "--- Configuring Azure Firewall ---"
az network firewall ip-config create \
    --firewall-name $FIREWALL_NAME \
    --name "firewall-config" \
    --public-ip-address "pip-$FIREWALL_NAME" \
    --resource-group $HUB_RG \
    --vnet-name $HUB_VNET

echo "Azure Firewall configured successfully"

# Get firewall private IP
FIREWALL_PRIVATE_IP=$(az network firewall show --name $FIREWALL_NAME --resource-group $HUB_RG --query "ipConfigurations[0].privateIpAddress" --output tsv)
echo "Firewall Private IP: $FIREWALL_PRIVATE_IP"

# Create network rule collection
echo "--- Creating Network Rules ---"
az network firewall network-rule create \
    --collection-name "AllowAzureServices" \
    --firewall-name $FIREWALL_NAME \
    --name "AllowAzureCloud" \
    --protocols TCP \
    --resource-group $HUB_RG \
    --destination-addresses "AzureCloud" \
    --destination-ports "443" "80" \
    --source-addresses "10.201.0.0/16" \
    --action Allow \
    --priority 100

echo "Network rules created successfully"

# Create application rule collection
echo "--- Creating Application Rules ---"
az network firewall application-rule create \
    --collection-name "AllowWebBrowsing" \
    --firewall-name $FIREWALL_NAME \
    --name "AllowMicrosoft" \
    --protocols "Http=80" "Https=443" \
    --resource-group $HUB_RG \
    --source-addresses "10.201.0.0/16" \
    --target-fqdns "*.microsoft.com" "*.azure.com" "*.windows.net" \
    --action Allow \
    --priority 200

echo "Application rules created successfully"

# Update route table to point to firewall
echo "--- Updating Route Table ---"
SPOKE_RG="rg-training-spoke"
ROUTE_TABLE="rt-spoke-training"

az network route-table route update \
    --name "DefaultRoute" \
    --resource-group $SPOKE_RG \
    --route-table-name $ROUTE_TABLE \
    --next-hop-ip-address $FIREWALL_PRIVATE_IP \
    --next-hop-type VirtualAppliance

echo "Route table updated successfully"

# Configure firewall diagnostics
echo "--- Configuring Diagnostics ---"
LOG_WORKSPACE_ID=$(az monitor log-analytics workspace show --workspace-name "law-management-prod-eus2-001" --resource-group "rg-management-prod-eus2-001" --query "id" --output tsv 2>/dev/null || echo "")

if [ -n "$LOG_WORKSPACE_ID" ]; then
    az monitor diagnostic-settings create \
        --name "firewall-diagnostics" \
        --resource "/subscriptions/$(az account show --query id --output tsv)/resourceGroups/$HUB_RG/providers/Microsoft.Network/azureFirewalls/$FIREWALL_NAME" \
        --workspace "$LOG_WORKSPACE_ID" \
        --logs '[
            {
                "category": "AzureFirewallApplicationRule",
                "enabled": true
            },
            {
                "category": "AzureFirewallNetworkRule", 
                "enabled": true
            },
            {
                "category": "AzureFirewallDnsProxy",
                "enabled": true
            }
        ]' \
        --metrics '[
            {
                "category": "AllMetrics",
                "enabled": true
            }
        ]'
    
    echo "Diagnostics configured successfully"
else
    echo "Warning: Log Analytics workspace not found - skipping diagnostics configuration"
fi

# Test firewall configuration
echo "--- Testing Firewall Configuration ---"

# Show firewall status
echo "Firewall Status:"
az network firewall show --name $FIREWALL_NAME --resource-group $HUB_RG --query "{Name:name, ProvisioningState:provisioningState, ThreatIntelMode:threatIntelMode}" --output table

# Show network rules
echo "Network Rules:"
az network firewall network-rule list --collection-name "AllowAzureServices" --firewall-name $FIREWALL_NAME --resource-group $HUB_RG --output table

# Show application rules
echo "Application Rules:"
az network firewall application-rule list --collection-name "AllowWebBrowsing" --firewall-name $FIREWALL_NAME --resource-group $HUB_RG --output table

echo "=== Azure Firewall Lab Complete ==="

# Lab exercises
echo ""
echo "=== Lab Exercises ==="
echo "1. Deploy a test VM in the spoke network"
echo "2. Test internet connectivity through the firewall"
echo "3. Review firewall logs in Log Analytics"
echo "4. Add additional network and application rules"
echo "5. Configure threat intelligence features"
```

#### Module B3: VPN and ExpressRoute Connectivity (2 Hours)

##### Learning Objectives
- Implement site-to-site VPN connectivity
- Understand ExpressRoute integration
- Configure hybrid DNS and routing

##### Lab Exercise: VPN Gateway Configuration
```powershell
# Lab Exercise: Site-to-Site VPN Configuration
# Duration: 1.5 hours

param(
    [string]$ResourceGroup = "rg-training-hub",
    [string]$VNetName = "vnet-training-hub", 
    [string]$Location = "East US 2"
)

Write-Host "=== VPN Gateway Configuration Lab ===" -ForegroundColor Green

# Create public IP for VPN Gateway
Write-Host "Creating public IP for VPN Gateway..." -ForegroundColor Yellow
$vpnPip = New-AzPublicIpAddress -Name "pip-vpn-gateway-training" -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Dynamic -Tag @{Environment="Training"}

# Get the virtual network and gateway subnet
Write-Host "Retrieving virtual network configuration..." -ForegroundColor Yellow
$vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name $VNetName
$gatewaySubnet = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet

# Create VPN Gateway IP configuration
$vpnIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name "gwIpConfig" -Subnet $gatewaySubnet -PublicIpAddress $vpnPip

# Create VPN Gateway (this takes 20-45 minutes)
Write-Host "Creating VPN Gateway (this will take 20-45 minutes)..." -ForegroundColor Yellow
Write-Host "Gateway creation started at: $(Get-Date)" -ForegroundColor White

$vpnGateway = New-AzVirtualNetworkGateway -Name "vgw-training-hub" -ResourceGroupName $ResourceGroup -Location $Location -IpConfigurations $vpnIpConfig -GatewayType Vpn -VpnType RouteBased -EnableBgp $true -AsnsidePrefix 65515 -Sku VpnGw1 -Tag @{Environment="Training"}

Write-Host "VPN Gateway created successfully at: $(Get-Date)" -ForegroundColor Green

# Create Local Network Gateway (simulating on-premises)
Write-Host "Creating Local Network Gateway..." -ForegroundColor Yellow
$localGateway = New-AzLocalNetworkGateway -Name "lgw-onpremises" -ResourceGroupName $ResourceGroup -Location $Location -GatewayIpAddress "203.0.113.1" -AddressPrefix @("192.168.0.0/16") -Tag @{Environment="Training"}

# Create VPN Connection
Write-Host "Creating VPN Connection..." -ForegroundColor Yellow
$vpnConnection = New-AzVirtualNetworkGatewayConnection -Name "conn-hub-to-onprem" -ResourceGroupName $ResourceGroup -Location $Location -VirtualNetworkGateway1 $vpnGateway -LocalNetworkGateway2 $localGateway -ConnectionType IPsec -SharedKey "TrainingSharedKey123!"

Write-Host "VPN Connection configured successfully" -ForegroundColor Green

# Configure BGP settings
Write-Host "Configuring BGP settings..." -ForegroundColor Yellow
$bgpPeerConfig = New-AzVirtualNetworkGatewayBgpPeerConfig -PeerAsn 65001 -PeerIp "192.168.1.1"
Set-AzVirtualNetworkGateway -VirtualNetworkGateway $vpnGateway -BgpPeerConfig $bgpPeerConfig

# Verification and status checks
Write-Host "=== VPN Gateway Configuration Verification ===" -ForegroundColor Cyan

# Check gateway status
$gatewayStatus = Get-AzVirtualNetworkGateway -Name "vgw-training-hub" -ResourceGroupName $ResourceGroup
Write-Host "Gateway Status: $($gatewayStatus.ProvisioningState)" -ForegroundColor White
Write-Host "Gateway Type: $($gatewayStatus.GatewayType)" -ForegroundColor White
Write-Host "VPN Type: $($gatewayStatus.VpnType)" -ForegroundColor White
Write-Host "SKU: $($gatewayStatus.Sku.Name)" -ForegroundColor White
Write-Host "BGP Enabled: $($gatewayStatus.EnableBgp)" -ForegroundColor White

if ($gatewayStatus.EnableBgp) {
    Write-Host "BGP ASN: $($gatewayStatus.BgpSettings.Asn)" -ForegroundColor White
    Write-Host "BGP Peer IP: $($gatewayStatus.BgpSettings.BgpPeeringAddress)" -ForegroundColor White
}

# Check connection status
$connectionStatus = Get-AzVirtualNetworkGatewayConnection -Name "conn-hub-to-onprem" -ResourceGroupName $ResourceGroup
Write-Host "`nConnection Status: $($connectionStatus.ConnectionStatus)" -ForegroundColor White
Write-Host "Connection Type: $($connectionStatus.ConnectionType)" -ForegroundColor White

# Get gateway public IP for on-premises configuration
$gatewayPublicIp = Get-AzPublicIpAddress -Name "pip-vpn-gateway-training" -ResourceGroupName $ResourceGroup
Write-Host "`nGateway Public IP: $($gatewayPublicIp.IpAddress)" -ForegroundColor Yellow
Write-Host "Use this IP address for on-premises VPN device configuration" -ForegroundColor Yellow

# Create sample routing configuration
Write-Host "`n=== Sample On-Premises Configuration ===" -ForegroundColor Cyan
$onPremConfig = @"
# Sample configuration for on-premises VPN device
Gateway IP: $($gatewayPublicIp.IpAddress)
Shared Key: TrainingSharedKey123!
IKE Version: IKEv2
Encryption: AES256
Authentication: SHA256
PFS Group: Group 14
Local Networks: 192.168.0.0/16
Remote Networks: 10.200.0.0/16, 10.201.0.0/16

# BGP Configuration (if supported)
Local BGP ASN: 65001
Local BGP IP: 192.168.1.1
Remote BGP ASN: 65515
Remote BGP IP: $($gatewayStatus.BgpSettings.BgpPeeringAddress)
"@

Write-Host $onPremConfig -ForegroundColor Gray

# Save configuration to file
$onPremConfig | Out-File -FilePath "onpremises-vpn-config.txt" -Encoding UTF8
Write-Host "`nOn-premises configuration saved to: onpremises-vpn-config.txt" -ForegroundColor Green

Write-Host "=== VPN Gateway Lab Complete ===" -ForegroundColor Green

# Lab exercises for students
Write-Host "`n=== Lab Exercises ===" -ForegroundColor Yellow
Write-Host "1. Monitor VPN connection status and BGP peers"
Write-Host "2. Configure custom IPsec policies"
Write-Host "3. Test routing between hub, spoke, and simulated on-premises"
Write-Host "4. Implement redundant VPN tunnels for high availability"
Write-Host "5. Configure point-to-site VPN for remote users"
```

#### Module B4: DNS and Traffic Management (1 Hour)

##### Learning Objectives
- Configure Azure DNS zones
- Implement DNS forwarding and conditional forwarding
- Set up traffic routing and load balancing

This comprehensive training materials document provides structured learning paths for all stakeholders, with hands-on labs and practical exercises to ensure effective knowledge transfer and operational readiness for the Azure Enterprise Landing Zone platform.
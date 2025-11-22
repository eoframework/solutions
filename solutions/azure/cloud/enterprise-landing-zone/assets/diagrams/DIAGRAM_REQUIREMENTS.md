# Azure Enterprise Landing Zone - Architecture Diagram Requirements

## Overview
Architecture diagram for Azure Enterprise Landing Zone following Microsoft Cloud Adoption Framework (CAF) best practices.

## Required Components

### 1. Management Groups Hierarchy
- **Root Management Group**
  - Platform management group
  - Landing Zones management group
  - Sandbox management group
- **Subscription Organization**
  - Management subscription
  - Connectivity subscription
  - Identity subscription
  - Landing zone subscriptions (Production, Dev, Test)

### 2. Hub-Spoke Network Architecture
- **Hub VNet (Connectivity Subscription)**
  - Azure Firewall (Premium tier)
  - VPN Gateway / ExpressRoute Gateway
  - Azure Bastion
  - Private DNS Zones
  - Network Watcher

- **Spoke VNets (Landing Zone Subscriptions)**
  - Application subnets
  - Data subnets
  - VNet peering to Hub
  - Route tables
  - Network Security Groups (NSGs)

### 3. Identity & Access
- **Azure Active Directory / Microsoft Entra ID**
  - Conditional Access policies
  - Privileged Identity Management (PIM)
  - Multi-factor authentication (MFA)

- **Identity Subscription**
  - Domain Controllers (optional)
  - Azure AD Connect
  - Azure AD Domain Services

### 4. Governance & Policy
- **Azure Policy**
  - Built-in policy assignments
  - Custom policy definitions
  - Policy initiatives
  - Compliance dashboard

- **Azure Blueprints (optional)**
  - Landing zone blueprints
  - Governance artifacts
  - Role assignments

### 5. Security & Compliance
- **Microsoft Defender for Cloud**
  - Security posture management
  - Workload protection
  - Regulatory compliance dashboard

- **Azure Sentinel (optional)**
  - SIEM integration
  - Security monitoring
  - Threat detection

### 6. Monitoring & Operations
- **Azure Monitor**
  - Log Analytics workspace
  - Application Insights
  - Workbooks and dashboards
  - Alert rules

- **Automation Account**
  - Runbooks for operational tasks
  - Update Management
  - Change Tracking

### 7. Cost Management
- **Azure Cost Management + Billing**
  - Cost analysis
  - Budgets and alerts
  - Cost allocation
  - Reservation recommendations

## Azure Icon Quick Reference

| Component | Azure Service | Color |
|-----------|--------------|-------|
| Management Groups | Management Groups | Gray |
| Virtual Network | Virtual Networks | Purple |
| Azure Firewall | Firewall | Red |
| VPN Gateway | VPN Gateways | Purple |
| Azure AD | Microsoft Entra ID | Blue |
| Azure Policy | Azure Policy | Gray |
| Azure Monitor | Azure Monitor | Gray |

## References
- **Azure Landing Zones**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/
- **Hub-Spoke Topology**: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke

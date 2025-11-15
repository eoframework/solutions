# Architecture Diagram Requirements - Azure Enterprise Landing Zone

## Diagram Purpose
Illustrate the complete Azure Enterprise-Scale Landing Zone architecture showing management groups, hub-spoke networking, security controls, and governance framework for enterprise cloud adoption.

## Architecture Components

### Management Groups Hierarchy
- **Tenant Root Group**: Top-level Azure AD tenant with organization-wide policies
- **Platform Management Group**: Shared infrastructure services (Management, Connectivity, Identity)
- **Landing Zones Management Group**: Application workload subscriptions (Production, Non-Production, Sandbox)
- **Decommissioned Management Group**: Archived and sunset resources

### Networking Architecture
- **Hub VNet**: Central network hub with Azure Virtual WAN, Azure Firewall, ExpressRoute Gateway, VPN Gateway
- **Spoke VNets**: Application landing zones with NSGs, route tables, private endpoints
- **Azure Virtual WAN**: Global network backbone for site-to-site connectivity and ExpressRoute integration
- **Azure Firewall Premium**: Network security with TLS inspection, IDPS, and URL filtering
- **ExpressRoute**: Hybrid connectivity to on-premises data centers (1 Gbps circuit)
- **Private Endpoints**: Secure connectivity to Azure PaaS services (Storage, SQL, Key Vault, etc.)

### Identity & Access Management
- **Azure Active Directory**: Identity provider with Conditional Access and MFA
- **Privileged Identity Management (PIM)**: Just-in-time privileged access for administrative operations
- **RBAC**: Role-based access control with custom roles and least-privilege assignments
- **Managed Identities**: Service-to-service authentication without credentials

### Security & Compliance
- **Microsoft Defender for Cloud**: Cloud security posture management (CSPM) and threat protection
- **Azure Sentinel**: Cloud-native SIEM/SOAR for security operations and threat hunting
- **Azure Policy**: Centralized governance with 150+ built-in policies for compliance enforcement
- **Azure DDoS Protection Standard**: Network-wide DDoS protection for public IPs
- **Azure Key Vault**: Centralized secrets, keys, and certificate management

### Monitoring & Operations
- **Azure Monitor**: Unified monitoring platform for metrics, logs, and application insights
- **Log Analytics Workspace**: Centralized logging repository for all Azure resources
- **Azure Bastion**: Secure RDP/SSH access without exposing VMs to the internet
- **Azure Automation**: Runbooks for operational tasks and remediation workflows

### Subscription Vending
- **Automated Provisioning**: Self-service subscription creation with pre-configured policies
- **Naming Convention Enforcement**: Automated resource naming with tags for cost allocation
- **Network Integration**: Automatic spoke VNet creation with hub peering
- **Security Baseline**: Auto-deployment of Defender for Cloud, diagnostic settings, and policy assignments

## Data Flow

### Subscription Provisioning Flow
1. User submits subscription request → Self-service portal (Power Apps or Azure Portal)
2. Approval workflow executes → Logic Apps or Power Automate
3. Subscription created → Azure Subscription API
4. Management group assignment → Platform or Landing Zones hierarchy
5. Azure Policy applied → Security baseline, compliance, and cost management policies
6. Network provisioning → Spoke VNet with hub peering and route table
7. Security services enabled → Defender for Cloud, diagnostic logging to Log Analytics
8. Subscription ready → Email notification to requester with access instructions

### Hybrid Connectivity Flow
1. On-premises application → ExpressRoute Circuit (1 Gbps)
2. ExpressRoute Gateway → Hub VNet
3. Azure Firewall inspection → Network security policies and IDPS
4. Route to spoke VNet → Azure resources (VMs, databases, storage)
5. Response path → Same route back to on-premises

### Security Monitoring Flow
1. Azure resources generate logs → Diagnostic settings
2. Logs forwarded → Log Analytics Workspace (centralized)
3. Sentinel analytics rules → Threat detection and correlation
4. Security alerts triggered → Azure Security Center dashboard
5. Automated response → Logic Apps playbooks for remediation

## Visual Representation Guidelines

### Layout
- **Top Section**: Management groups hierarchy (tree structure)
- **Middle Section**: Hub-spoke network topology (hub in center, spokes radiating outward)
- **Right Section**: Security and governance controls (Azure Policy, Sentinel, Defender)
- **Bottom Section**: Monitoring and operations (Log Analytics, Azure Monitor, Azure Bastion)

### Color Coding
- **Management Groups**: Light blue (#E1F0FF)
- **Networking**: Green (#D4EDDA)
- **Security**: Purple (#E1D5E7)
- **Monitoring**: Orange (#FFF4E6)
- **Identity**: Pink (#F8D7DA)

### Connections
- **Solid Lines**: Primary data flow and network connectivity
- **Dashed Lines**: Policy inheritance and governance relationships
- **Dotted Lines**: Security monitoring and logging flows

### Labels
- Clear service names with brief descriptions (e.g., "Azure Firewall\n(Premium Tier)")
- Numbered flow indicators for complex workflows (1. Upload → 2. Process → 3. Store)
- Azure service icons from official Azure icon set

## Technical Details to Include

### Network CIDR Ranges
- Hub VNet: 10.0.0.0/22 (1,024 IPs)
- Spoke VNets: 10.1.0.0/16 (65,536 IPs available for applications)
- Azure Firewall Subnet: 10.0.0.0/26 (64 IPs)
- Azure Bastion Subnet: 10.0.0.64/26 (64 IPs)
- Gateway Subnet: 10.0.0.128/27 (32 IPs)

### Management Group Policy Assignments
- Platform MG: Diagnostic logging required, Azure Monitor agents required
- Landing Zones MG: Allowed regions, allowed resource types, tag enforcement
- Production MG: Resource locks, backup policies, disaster recovery requirements

### Security Baselines
- All VMs: Microsoft Defender for Endpoint, Azure Monitor agent, update management
- All Storage Accounts: Private endpoints only, encryption at-rest with customer-managed keys
- All Databases: TDE encryption, private endpoints, Azure AD authentication required

## Success Criteria
- Diagram clearly shows management group hierarchy and policy inheritance
- Hub-spoke network topology is visually distinct with connectivity paths
- Security controls (Sentinel, Defender, Firewall) are prominently displayed
- Data flows are numbered and easy to follow
- Diagram fits on single slide/page without text being too small

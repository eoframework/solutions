# Azure Enterprise Landing Zone - Architecture Diagram

## Overview
Architecture diagram showing Azure Enterprise Landing Zone implementation with management groups, hub-spoke networking, and governance framework.

## Key Components

### Management Structure
1. **Management Groups** - Hierarchical organization (Root → Platform → Landing Zones)
2. **Subscriptions** - Management, Connectivity, Identity, and Workload subscriptions
3. **Azure Policy** - Centralized governance and compliance enforcement

### Network Architecture  
4. **Hub VNet** - Central connectivity with Azure Firewall, VPN/ExpressRoute Gateway, Bastion
5. **Spoke VNets** - Workload networks with VNet peering to Hub
6. **Hybrid Connectivity** - ExpressRoute or Site-to-Site VPN to on-premises

### Security & Monitoring
7. **Microsoft Entra ID** - Identity and access management with Conditional Access
8. **Defender for Cloud** - Security posture management and workload protection
9. **Azure Monitor** - Centralized logging and monitoring across all subscriptions

## Processing Flow
```
1. Management Groups hierarchy defines organization structure
2. Azure Policy applied at management group level cascades to subscriptions
3. Hub VNet provides centralized connectivity and security (Firewall)
4. Spoke VNets host workloads with private connectivity through Hub
5. On-premises connects via ExpressRoute or VPN to Hub
6. All traffic routed through Azure Firewall for inspection
7. Azure Monitor collects logs from all resources
8. Defender for Cloud provides security recommendations
```

## References
- **Diagram Requirements**: See `DIAGRAM_REQUIREMENTS.md`
- **Azure CAF**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/

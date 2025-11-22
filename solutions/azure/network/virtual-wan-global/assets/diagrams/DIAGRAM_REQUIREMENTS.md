# Azure Virtual WAN - Architecture Diagram Requirements

## Required Components

### 1. Virtual WAN Components
- **Virtual WAN** - Global transit network
- **Virtual Hubs** - Regional hubs (East US, West Europe, etc.)
- **Hub VNet Connections** - Connect VNets to hubs

### 2. Site Connectivity
- **VPN Gateway (Site-to-Site)** - Branch office connectivity
- **ExpressRoute Gateway** - Private connectivity to on-premises
- **Point-to-Site VPN** - Remote user access

### 3. Security
- **Azure Firewall** - Secured virtual hub with firewall
- **Firewall Policy** - Centralized firewall rules
- **DDoS Protection** - Network protection

### 4. Routing
- **Route Tables** - Custom routing policies
- **Route Propagation** - Dynamic route learning
- **BGP Configuration** - Border Gateway Protocol

### 5. Monitoring
- **Network Watcher** - Network diagnostics
- **Connection Monitor** - End-to-end monitoring
- **NSG Flow Logs** - Traffic analysis

## Azure Services

| Component | Icon Color |
|-----------|-----------|
| Virtual WAN | Purple |
| VPN Gateway | Purple |
| ExpressRoute | Purple |
| Azure Firewall | Red |

## References
- **Virtual WAN**: https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about

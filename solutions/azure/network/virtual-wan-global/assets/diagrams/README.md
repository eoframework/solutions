# Azure Virtual WAN Global Network - Architecture Diagram

## Key Components
1. **Virtual WAN** - Global network backbone with any-to-any connectivity
2. **Virtual Hubs** - Regional hub instances (e.g., East US, West Europe, Asia Pacific)
3. **Site-to-Site VPN** - Connect branch offices to virtual hubs
4. **ExpressRoute** - Private high-bandwidth connectivity to data centers
5. **Azure Firewall** - Secured hubs with centralized security policies
6. **Spoke VNets** - Application VNets connected to nearest hub

## Flow
```
1. Branch offices connect → Virtual Hub via Site-to-Site VPN
2. Data centers connect → Virtual Hub via ExpressRoute
3. Spoke VNets peer → To regional virtual hub
4. Virtual hubs interconnect → Global mesh network
5. All traffic routed → Through Azure Firewall in secured hub
6. Network Watcher monitors → Connectivity and performance
```

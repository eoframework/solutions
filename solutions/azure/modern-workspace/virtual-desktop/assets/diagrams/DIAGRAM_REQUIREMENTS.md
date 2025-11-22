# Azure Virtual Desktop - Architecture Diagram Requirements

## Required Components

### 1. Session Hosts
- **Virtual Machines** - Windows 10/11 multi-session or single-session
- **Availability Sets / Zones** - High availability
- **VM Scale Sets (optional)** - Auto-scaling

### 2. User Profiles
- **Azure Files (FSLogix)** - Profile containers
- **Azure NetApp Files (optional)** - High-performance profiles
- **Storage Account** - MSIX app attach

### 3. Identity & Access
- **Microsoft Entra ID (Azure AD)** - User authentication
- **AD Domain Services** - Domain join (hybrid identity)
- **Conditional Access** - Secure access policies

### 4. Networking
- **Virtual Network** - Isolated network for session hosts
- **Azure Bastion** - Secure RDP/SSH access
- **VPN Gateway** - On-premises connectivity

### 5. Monitoring
- **Azure Monitor** - Performance metrics
- **Log Analytics** - Diagnostics and usage
- **Virtual Desktop Insights** - AVD-specific monitoring

## Azure Services

| Component | Icon Color |
|-----------|-----------|
| Virtual Desktop | Blue |
| Virtual Machines | Blue |
| Azure Files | Green |
| Azure AD | Blue |

## References
- **AVD Architecture**: https://learn.microsoft.com/en-us/azure/architecture/example-scenario/wvd/windows-virtual-desktop

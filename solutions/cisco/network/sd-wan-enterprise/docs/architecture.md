# Architecture - Cisco SD-WAN Enterprise

## Solution Overview

Cisco SD-WAN Enterprise provides a cloud-delivered WAN architecture that simplifies branch connectivity while improving application performance and security.

## High-Level Architecture

```
                Internet Cloud
                      |
    ┌─────────────────┼─────────────────┐
    │                 │                 │
[vBond]          [vManage]         [vSmart]
 (Orchestrator)   (Management)    (Controller)
    │                 │                 │
    └─────────────────┼─────────────────┘
                      │
              Branch Locations
                   [vEdge]
```

## Core Components

### Control Plane
- **vManage**: Centralized management and orchestration
- **vSmart**: Policy and control plane intelligence
- **vBond**: Zero-touch provisioning and discovery

### Data Plane
- **vEdge/cEdge**: Branch gateway routers
- **Secure Tunnels**: IPsec overlay network
- **Application Awareness**: Intelligent path selection

## Key Benefits

- **Cost Reduction**: 40% savings on WAN costs
- **Performance**: 3x improvement in application response
- **Agility**: 90% faster deployment times
- **Security**: Integrated threat protection

## Deployment Models

- **Cloud-hosted controllers**
- **On-premises deployment**
- **Hybrid architecture**
- **Multi-tenant support**

---

**Document Version**: 1.0  
**Last Updated**: January 2025
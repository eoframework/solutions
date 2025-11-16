# ExpressRoute Connectivity Diagram
## On-Premises Data Center Integration

```
                    EXPRESSROUTE CONNECTIVITY
            On-Premises Data Centers to Azure


┌────────────────────────────────────────────────────────────────┐
│                          MICROSOFT AZURE                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           VIRTUAL WAN HUB (US EAST)                      │  │
│  │                                                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │     ExpressRoute Gateway (High Performance)        │  │  │
│  │  │                                                    │  │  │
│  │  │  Circuit 1 (Primary)    Circuit 2 (Secondary)     │  │  │
│  │  │  ◆ 50 Mbps              ◆ 50 Mbps                │  │  │
│  │  │  ◆ BGP Peering 1        ◆ BGP Peering 2          │  │  │
│  │  │  ◆ SLA: 99.95%          ◆ SLA: 99.95%            │  │  │
│  │  │  ◆ Active               ◆ Active (Standby)       │  │  │
│  │  │                                                    │  │  │
│  │  └──────────┬──────────────────────┬──────────────────┘  │  │
│  │             │                      │                     │  │
│  │             │ BGP Routes           │ BGP Routes          │  │
│  │             │ (192.168.0.0/16)     │ (192.168.0.0/16)    │  │
│  │             │ (10.x.x.x learned)   │ (10.x.x.x learned)  │  │
│  │             │                      │                     │  │
│  └─────────────┼──────────────────────┼─────────────────────┘  │
│                │ Microsoft Backbone    │                        │
│                │ Private Network       │                        │
└────────────────┼──────────────────────┼────────────────────────┘
                 │                      │
         ┌───────▼──────────────────────▼──────┐
         │   EXPRESSROUTE PROVIDER              │
         │   (e.g., Equinix, Megaport, etc)    │
         │                                      │
         │  • Private Peering Setup             │
         │  • Layer 3 BGP Routing               │
         │  • Redundant physical circuits       │
         └───────┬──────────────────────┬───────┘
                 │                      │
         ┌───────▼──┐          ┌────────▼───────┐
         │ Circuit 1│          │  Circuit 2     │
         │(Primary) │          │ (Standby)      │
         │50 Mbps   │          │ 50 Mbps        │
         └───────┬──┘          └────────┬───────┘
                 │                      │
              ┌──▼──────────────────────▼──┐
              │   CUSTOMER EDGE (CE)        │
              │   Network Provider Router   │
              │                             │
              │  ◆ BGP Route Advertisement │
              │  ◆ Multiple paths (ECMP)   │
              │  ◆ Route filtering         │
              └──┬──────────────────────┬──┘
                 │                      │
        ┌────────▼────┐      ┌─────────▼─────┐
        │ Data Center │      │ Data Center 2 │
        │    SITE 1   │      │    SITE 2     │
        │             │      │               │
        │ On-Premises │      │ On-Premises   │
        │ Network     │      │ Network       │
        │             │      │               │
        │ 100 Mbps    │      │ 50 Mbps       │
        │ BGP AS 65xxx│      │ BGP AS 65xxx  │
        │             │      │               │
        │ Routers:    │      │ Routers:      │
        │ • Cisco     │      │ • Juniper     │
        │ • Juniper   │      │ • Arista      │
        │             │      │               │
        │ Networks:   │      │ Networks:     │
        │ • 192.168.0 │      │ • 192.168.128 │
        │   .0/24     │      │   .0/24       │
        │ • 192.168.1 │      │ • 10.0.0.0    │
        │   .0/24     │      │   /24         │
        │             │      │               │
        └────────┬────┘      └────────┬──────┘
                 │                    │
                 │ Firewall/Security  │
                 │ Inspection         │
                 │                    │
              ┌──▼────────────────────▼──┐
              │   DATA CENTER NETWORK     │
              │                           │
              │  ◆ Database Servers       │
              │  ◆ Application Servers    │
              │  ◆ Storage Arrays         │
              │  ◆ Legacy Systems         │
              │  ◆ DR/Backup Systems     │
              └───────────────────────────┘


EXPRESSROUTE CONFIGURATION:
───────────────────────────

Circuit 1 (Primary - Active-Active):
─────────────────────────────────────
Provider: Equinix/Megaport/etc
Peering Location: DC1 (nearest to primary DC)
Bandwidth: 50 Mbps
Peering Type: Private Peering
BGP Configuration:
  • Microsoft ASN: 12076
  • Customer ASN: 65xxx
  • Primary Subnet: 192.168.1.0/30
  • Secondary Subnet: 192.168.1.4/30
Route Advertisement (to Azure):
  • 192.168.0.0/16 (Data Center Network)
Route Advertisement (from Azure):
  • 10.0.0.0/8 (All VNets + Virtual WAN)

Circuit 2 (Secondary - Active-Active):
──────────────────────────────────────
Provider: Different provider (redundancy)
Peering Location: DC2 (geographically diverse)
Bandwidth: 50 Mbps
Peering Type: Private Peering
BGP Configuration:
  • Microsoft ASN: 12076
  • Customer ASN: 65xxx
  • Primary Subnet: 192.168.2.0/30
  • Secondary Subnet: 192.168.2.4/30
Route Advertisement (to Azure):
  • 192.168.0.0/16 (Data Center Network)
Route Advertisement (from Azure):
  • 10.0.0.0/8 (All VNets + Virtual WAN)


BGP ROUTING BEHAVIOR:
─────────────────────

Equal Cost Multi-Path (ECMP) - Load Balancing:
┌──────────────────────────────┐
│  Destination: 10.0.0.0/8     │
│  Next Hop 1: Circuit 1 (50%)  │
│  Next Hop 2: Circuit 2 (50%)  │
│  Result: Traffic split 50/50  │
└──────────────────────────────┘

Failover Scenario (Circuit 1 Down):
┌──────────────────────────────┐
│  Destination: 10.0.0.0/8     │
│  Next Hop 1: [FAILED]         │
│  Next Hop 2: Circuit 2 (100%) │
│  Result: All traffic via Cir2 │
│  Failover Time: <10 seconds   │
└──────────────────────────────┘

Return Path Optimization:
┌──────────────────────────────┐
│  From Azure to DC:           │
│  10.0.0.0 ──► 192.168.0.0   │
│  Uses ECMP across both       │
│  circuits (symmetric)        │
└──────────────────────────────┘


PERFORMANCE CHARACTERISTICS:
────────────────────────────

Latency (Data Center to Azure):
  Circuit 1: 8-12 ms (DC1 to Azure US-East)
  Circuit 2: 12-15 ms (DC2 to Azure US-East)
  Target: <20 ms one-way

Bandwidth Utilization:
  Average: 15-25 Mbps (30-50% of provisioned)
  Peak: 45-48 Mbps (90% of provisioned)
  Growth Plan: Upgrade to 100 Mbps Year 2

Traffic Profile:
  • Data Center to Azure VNets: 60%
  • Inter-datacenter (via Azure): 20%
  • Backup/DR traffic: 15%
  • Management: 5%


SLA & RELIABILITY:
──────────────────

ExpressRoute SLA:
  • Availability: 99.95% (monthly)
  • Down Time: ~22 minutes/month maximum
  • Microsoft reimburses 25% of monthly fee if SLA breached

Redundancy Provided:
  ✓ Dual circuits (independent providers)
  ✓ Diverse peering locations
  ✓ ECMP load balancing (no single point of failure)
  ✓ Automatic failover (BGP convergence <10 seconds)
  ✓ No manual intervention required

Backup Strategy:
  • VPN tunnels as secondary failover (slower but available)
  • Manual failover to VPN if both ER circuits down
  • Expected RTO: <30 minutes via VPN
  • Expected RPO: Near zero (packet-level failover)


COST ANALYSIS:
──────────────

Year 1 Cost:
┌─────────────────────────────────┐
│ ExpressRoute Circuits:          │
│ • Circuit 1 (50 Mbps): $9,000   │
│ • Circuit 2 (50 Mbps): $9,000   │
│ • Total: $18,000 annually       │
└─────────────────────────────────┘

Year 2+ Cost:
┌─────────────────────────────────┐
│ Upgrade to 100 Mbps (Year 2):   │
│ • Circuit 1 (100 Mbps): $18,000 │
│ • Circuit 2 (100 Mbps): $18,000 │
│ • Total: $36,000 annually       │
│                                 │
│ (Scaling is linear with bandwidth
└─────────────────────────────────┘

Cost Savings vs. Legacy:
  Legacy MPLS: $200-300K per data center circuit
  ExpressRoute: $18K for both circuits combined
  Savings: ~$200K+ annually for data center connectivity
```

## Implementation Timeline

**Week 1:**
- ExpressRoute circuit provisioning (order form submission)
- Provider confirmation (4-6 week lead time)

**Week 4-8:**
- Circuit activation (as circuits become available)
- BGP configuration at data centers
- Route advertisement testing

**Week 9-10:**
- Production traffic migration
- Failover testing
- VPN teardown (MPLS no longer needed for DC connectivity)

## Benefits

1. **Dedicated Bandwidth:** Guaranteed 50 Mbps per circuit (not internet contention)
2. **Low Latency:** 8-15 ms to Azure (vs. 50-100 ms over internet)
3. **High Reliability:** 99.95% SLA, automatic failover
4. **Cost Efficiency:** $18K for dual circuits vs. $50-100K for legacy options
5. **Scalability:** Easy upgrade to 100 Mbps, 500 Mbps, 10 Gbps
6. **Security:** Private peering (no internet exposure)
7. **Performance:** Optimized routing via Microsoft backbone
8. **BGP Control:** Fine-grained traffic engineering capabilities

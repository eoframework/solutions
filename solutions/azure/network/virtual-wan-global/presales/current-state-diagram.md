# Current State Network Diagram
## Legacy MPLS + Internet Hybrid Architecture

```
                          LEGACY WAN TOPOLOGY
                        (MPLS + Internet Hybrid)

┌─────────────────────────────────────────────────────────────────────────┐
│                          AZURE (Cloud)                                   │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐             │
│  │  US VNet 1   │     │  US VNet 2   │     │  EU VNet 1   │             │
│  │  (Manual)    │────┤ (Manual Peering)──┤   (Manual)    │             │
│  │  10.0.0.0/16 │  ╲  │  10.1.0.0/16 │     │  10.2.0.0/16 │             │
│  └──────────────┘   ╲ └──────────────┘     └──────────────┘             │
│                      ╲                            ▲                       │
│                       ╲ (VPN Tunnel)            /  (No Direct Link)     │
│                        ╲                        /                        │
│                         ╲                      /                         │
│                          ╲                    /                          │
│                    ┌──────────────────────────┐                          │
│                    │   VPN Gateway (US)       │                          │
│                    │   (Single Instance)      │                          │
│                    └──────────────────────────┘                          │
└────────────────────────────┬─────────────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │    INTERNET (ISP)       │
                │   (Unreliable, Slow)    │
                └────────┬────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────────┐       ┌────────┐      ┌────────┐
   │Branch1 │       │Branch5 │      │Branch8 │
   │  HQ    │       │ Remote │      │ Remote │
   └────────┘       └────────┘      └────────┘

        ┌─────────────────────────┐
        │  MPLS WAN (Provider)    │
        │  ◆ 10 Sites Connected   │
        │  ◆ Premium Circuits     │
        │  ◆ High Cost (~$180K/y) │
        └────┬────────┬───────────┘
             │        │
        ┌────────┐ ┌────────────┐
        │Branch2 │ │ Data Center│
        │ (Site) │ │ (On-Prem)  │
        └────────┘ └────────────┘

        ┌─────────────────────────┐
        │ More Sites (3-10)       │
        │ Connected via MPLS      │
        │ or Internet             │
        └─────────────────────────┘

ISSUES:
✗ Manual VNet peering (complex, error-prone)
✗ No inter-region redundancy
✗ High MPLS cost (~$180K/year)
✗ Limited scalability to cloud
✗ Inconsistent security policies
✗ Difficult to manage 10+ sites
✗ Latency issues (150-250ms avg)
✗ No centralized firewall
```

## Current State Details

**Azure Components (Fragmented):**
- 3 VNets in US/EU with manual peering
- Single VPN gateway in US region only
- No ExpressRoute connectivity to on-prem
- Manual route management
- Distributed firewalls (NSGs only)

**WAN Components:**
- 10 branch offices on MPLS or Internet
- Premium MPLS circuits (2-3 sites)
- Internet-based VPN for smaller sites
- Inconsistent failover capabilities

**Data Centers:**
- 2 on-premises data centers
- VPN tunnels via Internet (unreliable)
- No direct ExpressRoute connectivity
- Manual BGP route management

**Pain Points:**
1. **Operational Complexity:** Manual VNet peering, separate MPLS and cloud management
2. **Cost:** ~$180K/year MPLS + cloud networking overhead
3. **Security:** No central threat protection, distributed firewall rules
4. **Scalability:** Adding a new site requires manual VNet peering updates
5. **Reliability:** Internet-based links not suitable for critical apps
6. **Visibility:** No unified monitoring across MPLS and cloud networks

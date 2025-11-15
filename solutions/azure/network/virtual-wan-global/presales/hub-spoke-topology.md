# Hub-and-Spoke Topology Detail
## Virtual WAN Hub Connectivity Model

```
                    HUB-AND-SPOKE CONNECTIVITY MODEL

                          VIRTUAL WAN
                      (Hub-and-Spoke Design)

                      ┌──────────────────┐
                      │  BRANCH SITE 1   │
                      │  (Remote Office) │
                      │  VPN Connection  │
                      └────────┬─────────┘
                               │
                               │ VPN Tunnel
                               │ (1 Mbps - 100 Mbps)
                               │
                               ▼
                    ┌──────────────────────┐
           ┌────────┤   VIRTUAL WAN HUB    │◄───────┐
           │        │   (US Region)        │        │
           │        │                      │        │
      Branch 2      │ • VPN Gateway        │    Branch 3
       VPN        ◄─┤ • ExpressRoute GW    ├─►  VPN
      Tunnel         │ • Azure Firewall     │   Tunnel
           │        │ • Route Tables       │        │
           │        │ • DNS Resolver       │        │
           └────────┤                      │◄───────┘
                    └──────┬────────────────┘
                           │
                ┌──────────┼──────────┐
                │          │          │
                ▼          ▼          ▼
        ┌──────────┐  ┌──────────┐  ┌──────────┐
        │ US VNet  │  │ US VNet  │  │ EU VNet  │
        │  (Apps)  │  │ (Data)   │  │ (GDPR)   │
        │          │  │          │  │          │
        └──────────┘  └──────────┘  └──────────┘
                │          │          │
                └──────────┼──────────┘
                           │
                    ┌──────▼──────────┐
                    │  Data Center    │
                    │  (On-Premises)  │
                    │  ExpressRoute   │
                    │  Connection     │
                    └─────────────────┘

TRAFFIC FLOWS:
──────────────

1. Branch-to-Azure VNet:
   Branch 1 ──VPN──► Hub ──Direct Link──► US VNet (App)

2. Branch-to-Branch (via Hub):
   Branch 2 ──VPN──► Hub ──Route──► Branch 1 (automatic)

3. Branch-to-Data Center (via Hub):
   Branch 3 ──VPN──► Hub ──ExpressRoute──► Data Center

4. Cross-Region (via Hub-to-Hub):
   US Hub ──Backbone──► EU Hub ──► EU VNet (GDPR)

5. Firewall Processing (all traffic):
   Any Source ──► Firewall ──► Destination
   (Implicit Deny, Explicit Allow)


HUB REDUNDANCY MODEL:
─────────────────────

Primary Hub (US)           Secondary Hub (EU)
┌──────────────────┐      ┌──────────────────┐
│  Active-Active   │      │  Active-Active   │
│  ◆ VPN Gateway   │◄────►│  ◆ VPN Gateway   │
│  ◆ Firewall      │      │  ◆ Firewall      │
│  ◆ Route Tables  │      │  ◆ Route Tables  │
│                  │      │                  │
│  Failover: <30s  │      │  Failover: <30s  │
└──────────────────┘      └──────────────────┘

If US Hub fails:
• Existing US-based branches auto-failover to EU Hub (via backup VPN)
• No manual intervention required
• Data center ExpressRoute remains active
• EU branches unaffected


AUTOMATIC ROUTING:
──────────────────

Hub maintains route table:
┌─────────────────────────────────────┐
│ Destination  │ Next Hop  │ Type    │
├──────────────────────────────────────┤
│ 10.0.0.0/16  │ US VNet   │ Direct  │
│ 10.1.0.0/16  │ US VNet   │ Direct  │
│ 10.2.0.0/16  │ EU Hub    │ Backbone│
│ 192.168.0/16 │ ExpressRt │ On-Prem │
│ 0.0.0.0/0    │ Firewall  │ Policy  │
└─────────────────────────────────────┘

Benefits:
✓ No manual BGP configuration
✓ Automatic failover routes
✓ Policy-based traffic steering
✓ Symmetric routing (return path optimized)


SCALABILITY:
────────────

Initial Deployment (Year 1):
├─ Hub 1 (US): 6 branch sites (active)
├─ Hub 2 (EU): 4 branch sites (active)
├─ Data Centers: 2 ExpressRoute circuits
└─ VNets: 3 (integrated)

Growth Scenario (Year 2):
├─ Hub 1 (US): 12 branch sites
├─ Hub 2 (EU): 8 branch sites
├─ New Hub 3 (APAC): 5 branch sites
└─ VNets: 8 (additional enterprise divisions)

Hub Capacity:
─────────────
┌──────────────────────────┐
│ Virtual WAN Hub Limits   │
├──────────────────────────┤
│ Max VPN connections: 20k │
│ Max VNets: 1000          │
│ Max ExpressRoute: 4      │
│ Max bandwidth: 50 Gbps   │
└──────────────────────────┘

Current usage: ~10-15% of capacity
Growth runway: 6-8 years at current expansion rate
```

## Hub Connectivity Patterns

### Pattern 1: Branch-to-Cloud (Typical)
```
Branch Office (VPN) ──► Hub ──► Azure VNet
                        │
                        └──► Firewall (inspection)
```

### Pattern 2: Hub-to-Hub Redundancy
```
US Hub (Active)              EU Hub (Active)
   │                            │
   ├──► Branch 1                └──► Branch 8
   ├──► Branch 2                    Branch 9
   ├──► US VNet                     EU VNet
   │
   └──► Firewall (Primary)
        Data Center (ExpressRoute)
```

### Pattern 3: Multi-Region Failover
```
Scenario: US Hub fails

Branch 1 ──┐                  ┌──► EU Hub ◄──── Branch 1 (redirected)
Branch 2 ──┤  US Hub (DOWN)  │
Branch 3 ──┘                  └──► BackupRoute
                                   (alternate path)
```

## Implementation Advantages

1. **Centralized Management:** Single control plane for all 10 sites + 3 VNets
2. **Dynamic Routing:** No manual route updates when new branch added
3. **Security Enforcement:** All traffic through central firewall
4. **Automatic Failover:** <30 seconds to alternate hub or data center
5. **Cost Savings:** $128K Year 1 (vs. $180K for legacy MPLS)
6. **Self-Service:** Branch provisioning via Azure Portal (admin capability)
7. **Compliance:** Centralized audit logging, policy enforcement
8. **Scalability:** Add 100+ more sites without architecture changes

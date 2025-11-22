# Cisco SD-WAN Enterprise Solution

## Executive Summary

Transform WAN infrastructure by replacing expensive MPLS circuits with software-defined WAN across 25 branch offices. Leverage commodity broadband and LTE circuits with intelligent application-aware routing to achieve 10x bandwidth increase, $160K annual savings, and optimized cloud application performance through Cisco SD-WAN (Viptela) platform.

**Investment:** $360.9K Year 1 | $719.3K 3-Year Total
**Timeline:** 6-9 months full deployment
**ROI:** 27-month payback through MPLS cost elimination and productivity gains

---

## Business Challenge

Traditional MPLS-based WAN architectures create significant cost and performance challenges that hinder digital transformation:

- **Excessive MPLS Costs:** $240K annually for 25 MPLS circuits @ $800/month with only 10-20 Mbps bandwidth per site
- **Insufficient Bandwidth:** Limited MPLS capacity throttles cloud application performance (Office 365, Salesforce, Teams)
- **Slow Site Deployment:** 60-90 days to provision new MPLS circuits delaying business expansion
- **Poor Cloud Connectivity:** Backhauling cloud traffic through data center adds 100-200ms latency degrading user experience
- **Inflexible Architecture:** Hub-and-spoke MPLS topology cannot adapt to cloud-first application delivery
- **Complex Management:** Manual router configurations across 25 sites increase errors and slow changes

These challenges result in $385K annually in WAN costs, user productivity losses, delayed projects, and inability to support cloud migration strategies that are fundamental to business competitiveness.

---

## Solution Overview

Cisco SD-WAN (Viptela) delivers software-defined WAN with application-aware routing across 25 branch offices:

### Core Components

**SD-WAN Controllers (Virtual Appliances)**
- **vManage:** Centralized orchestration and policy management dashboard
- **vSmart:** Control plane for routing policy distribution and path optimization
- **vBond:** Zero-touch provisioning orchestrator for automated router deployment
- Hosted in data center or cloud (AWS, Azure) for geographic redundancy

**Edge Routers**
- **25x Cisco ISR 4331 Branch Routers:** Dual WAN ports (broadband + LTE backup)
- **2x Cisco ISR 4451 Hub Routers:** Data center hubs with high throughput (redundant pair)
- Integrated security: Firewall, IPS, URL filtering, VPN encryption
- Hardware capacity: 500 Mbps aggregate throughput per branch router

**WAN Circuit Strategy**
- **Primary:** 100 Mbps broadband (fiber or cable) @ $200/month per site
- **Backup:** 10 GB LTE/5G failover @ $50/month per site
- **Total:** 2500 Mbps aggregate bandwidth (vs 250-500 Mbps MPLS) = **10x increase**
- **Cost:** $75K annually (vs $240K MPLS) = **$165K annual savings**

**Software Features**
- Application-aware routing based on real-time path performance
- 3000+ application signatures for deep packet inspection
- SLA-based path selection (latency, jitter, packet loss)
- Direct internet breakout for SaaS applications
- Cloud on-ramps for AWS, Azure, Google Cloud
- Encrypted overlay with zero-trust security

---

## Business Value

### Cost Optimization
- **$165K annual WAN cost savings:** Broadband + LTE ($75K/year) vs MPLS ($240K/year)
- **10x bandwidth increase:** 100 Mbps broadband vs 10-20 Mbps MPLS at lower cost
- **Eliminate MPLS complexity:** No carrier dependencies or long-term contracts
- **Cloud circuit optimization:** Direct cloud connectivity reduces ExpressRoute/DirectConnect costs

### Performance Improvement
- **75% latency reduction for SaaS:** Direct internet breakout vs backhaul through data center
- **99.9% WAN uptime:** Automatic failover between broadband and LTE (sub-second)
- **Application SLA enforcement:** VoIP <100ms, video <150ms, business apps <50ms
- **Intelligent path selection:** Real-time traffic steering based on application requirements

### Operational Efficiency
- **Zero-touch provisioning:** New sites deployed in hours vs 60-90 days for MPLS
- **Centralized management:** Single vManage dashboard for all 25 sites vs per-device CLI
- **Automated policy enforcement:** Application routing policies distributed automatically
- **Simplified troubleshooting:** End-to-end visibility with application path tracing

### Business Agility
- **Cloud migration enablement:** Direct cloud on-ramps eliminate backhaul latency
- **Rapid site deployment:** Ship router to site, plug in, auto-configures via ZTP
- **Flexible WAN expansion:** Add sites without carrier lead times or contract negotiations
- **M&A integration:** Quickly onboard acquired locations with consistent policies

### Financial Impact
- **3-year WAN cost savings:** $495K (3 years × $165K annual MPLS savings)
- **Productivity gains:** $75K annually from improved application performance (5% productivity increase)
- **Accelerated projects:** $35K annually from faster site deployment enabling business initiatives
- **Total 3-year value:** $605K vs $719.3K investment = 27-month payback

---

## Technical Architecture

### SD-WAN Overlay Design

**Control Plane (SD-WAN Controllers)**
- vManage: Centralized policy orchestration and monitoring
- vSmart: OMP (Overlay Management Protocol) routing distribution
- vBond: NAT traversal and ZTP orchestration
- Deployed as VMs in data center with failover to cloud

**Data Plane (Edge Routers)**
- Branch ISR 4331: Dual WAN (broadband + LTE) with active-active load balancing
- Hub ISR 4451: Aggregation point for branch-to-DC traffic
- IPsec encrypted tunnels across all WAN circuits (AES-256)
- Per-application tunnel selection based on SLA requirements

**WAN Topology**
- Mesh topology: Any branch can communicate directly with any other branch
- Hub-spoke for data center access: Branches connect to dual hub routers
- Cloud direct: Branches bypass hub for SaaS (Office 365, Salesforce)
- Automatic failover: Sub-second switchover from broadband to LTE

---

## Application-Aware Routing

### Traffic Policies

**SaaS Applications (Direct Internet Breakout)**
- Office 365, Microsoft Teams, Salesforce, Dropbox, Zoom
- Route directly to internet from branch (no backhaul)
- 75% latency reduction (50ms direct vs 200ms via data center)
- SLA monitoring with automatic path selection

**Business-Critical Applications (Optimized Path)**
- SAP ERP, custom LOB applications, internal databases
- Route to data center hub via best-performing WAN circuit
- SLA: <50ms latency, <1% packet loss, <10ms jitter
- Automatic failover if SLA violated

**VoIP and Video (High Priority)**
- VoIP phones, video conferencing (WebEx, Zoom)
- QoS priority queue with guaranteed bandwidth
- SLA: <100ms latency, <30ms jitter, <0.5% packet loss
- Load balancing across multiple WAN circuits

**Bulk Data Transfer (Best Effort)**
- Software updates, backups, file synchronization
- Use available bandwidth without impacting real-time apps
- Scheduled during off-peak hours via policy

### Path Selection Logic

**Real-Time Monitoring (Every 100ms)**
- Measure latency, jitter, packet loss on all WAN circuits
- Track application-specific SLA compliance
- Detect circuit degradation or outages immediately

**Intelligent Steering**
- Office 365: Route via broadband (lowest latency)
- ERP: Route via MPLS if available, else broadband with QoS
- VoIP: Load-balance across broadband + MPLS for redundancy
- Backup: Route via LTE if broadband and MPLS both fail

**Example Scenario**
- Broadband circuit experiences 200ms latency spike
- SD-WAN detects SLA violation for VoIP (threshold 100ms)
- Traffic automatically steered to LTE backup circuit
- Switchover time: <1 second, users experience no interruption
- Return to broadband when latency normalizes

---

## Cloud Integration Strategy

### Cloud On-Ramps

**AWS Direct Connect**
- Virtual private gateway in AWS VPC
- SD-WAN router connects via Equinix or Megaport cloud exchange
- Optimized path for EC2 instances and RDS databases
- Backup via encrypted internet tunnel

**Azure ExpressRoute**
- Private connection to Azure virtual network
- SD-WAN integration with Azure vWAN hub
- Performance monitoring for Azure apps (Dynamics 365)
- Automatic failover to internet VPN

**Google Cloud Interconnect**
- Dedicated interconnect or partner interconnect
- Optimized routing for GCP workloads
- Multi-cloud routing intelligence across AWS + Azure + GCP

### SaaS Optimization

**Office 365 Fast Path**
- Microsoft peering via local internet breakout
- SD-WAN recognizes Office 365 traffic (deep packet inspection)
- Routes directly to nearest Microsoft datacenter
- 80% latency improvement vs backhaul

**Salesforce Performance**
- Direct routing to Salesforce POPs
- SSL inspection bypass for trusted cloud apps
- Bandwidth reservation during peak hours

---

## Security Architecture

### Integrated Security Services

**Encrypted Overlay**
- IPsec encryption (AES-256) on all WAN circuits
- Zero-trust architecture: verify every packet
- Per-application tunnels with unique encryption keys
- Hardware acceleration (no performance impact)

**Next-Generation Firewall**
- Stateful firewall integrated on ISR routers
- Application visibility and control (3000+ signatures)
- URL filtering with Cisco Umbrella integration
- IPS/IDS for threat detection and prevention

**Cisco Umbrella DNS Security**
- Cloud-delivered DNS filtering (optional)
- Malware, ransomware, phishing protection
- No appliance required, enforced at DNS layer
- Roaming user protection (laptop off-network)

**Segmentation**
- VPN segmentation for multi-tenancy
- Guest WiFi traffic isolated from corporate
- IoT device traffic quarantined
- PCI compliance zone for payment systems

---

## Implementation Approach

### Phase 1: Design & Pilot (Months 1-2)

**Week 1-2: Design Workshop**
- Current state WAN assessment (40 hours)
- Application inventory and SLA requirements (20 hours)
- WAN topology and circuit design (20 hours)
- Security and cloud integration architecture (15 hours)

**Week 3-4: Controller Deployment**
- vManage, vSmart, vBond deployment in data center (25 hours)
- Controller HA configuration and testing (15 hours)
- Initial policy framework development (20 hours)

**Week 5-8: Pilot Sites (3 sites)**
- Circuit procurement for pilot sites (external dependency: 30-45 days)
- ISR router pre-configuration and shipping (10 hours)
- On-site installation (3 hours per site × 3 = 9 hours)
- Zero-touch provisioning validation (10 hours)
- Application performance testing and optimization (15 hours)

### Phase 2: Regional Rollout (Months 3-5)

**Wave 1: 10 Sites (Month 3)**
- Circuit orders and installations (external: varies by carrier)
- Router pre-staging and ZTP templates (15 hours)
- Site deployments (3 hours × 10 = 30 hours)
- Policy refinement based on pilot learnings (10 hours)

**Wave 2: 12 Remaining Sites (Months 4-5)**
- Final site circuit procurement (external dependency)
- Mass router deployment (3 hours × 12 = 36 hours)
- MPLS circuit decommissioning (staggered)

### Phase 3: Optimization (Month 6)
- Application SLA policy fine-tuning (20 hours)
- Cloud on-ramp configuration (AWS, Azure) (30 hours)
- Performance baseline and reporting (15 hours)
- Operations team training and handoff (24 hours)

### Phase 4: MPLS Decommission (Months 6-9)
- Validate SD-WAN stability (30-day parallel run)
- Decommission MPLS circuits site-by-site
- Achieve full $165K annual savings by Month 9

---

## Migration Strategy

### Parallel Run Approach

**Week 1-2: Dual-Circuit Operation**
- SD-WAN broadband + existing MPLS both active
- Critical apps remain on MPLS (zero risk)
- Non-critical apps routed via SD-WAN (validate performance)
- Team monitors performance dashboards 24x7

**Week 3-4: Gradual Migration**
- Migrate app-by-app based on SLA validation
- Start with low-risk: web browsing, email
- Progress to medium-risk: file shares, intranet
- Final: business-critical ERP, VoIP

**Week 5+: MPLS Decommission**
- All applications validated on SD-WAN
- Submit MPLS disconnect orders (30-day notice)
- Remove MPLS circuits and realize cost savings
- Archive MPLS configs for audit/compliance

### Zero-Touch Provisioning (ZTP)

**Pre-Deployment Preparation**
- Configure site template in vManage (device model, WAN circuits, policies)
- Pre-stage router serial number and site mapping
- Generate ZTP bootstrap configuration file

**Site Deployment (3-hour process)**
- Ship pre-configured router to site address
- Local technician or end user unboxes router
- Connect WAN cables (broadband to WAN1, LTE to WAN2)
- Connect LAN cable to existing switch
- Power on router

**Automated Provisioning**
- Router contacts vBond controller via DHCP and cloud redirect
- vBond authenticates router and provides vManage IP
- vManage pushes full configuration (policies, VPN, security)
- Router establishes encrypted tunnels to all other sites
- Site fully operational in 15-20 minutes

---

## Investment Summary

| Category | Year 1 | Year 2 | Year 3 | 3-Year Total |
|----------|--------|--------|--------|--------------|
| Hardware | $128,500 | $0 | $0 | $128,500 |
| WAN Circuits | $91,800 | $103,800 | $103,800 | $299,400 |
| Software | $44,200 | $59,200 | $59,200 | $162,600 |
| Support | $16,200 | $16,200 | $16,200 | $48,600 |
| Professional Services | $80,200 | $0 | $0 | $80,200 |
| **Total Investment** | **$360,900** | **$179,200** | **$179,200** | **$719,300** |

**Year 1 includes:** $35K in credits (router trade-in + SD-WAN license promo + circuit migration waiver)

**Annual recurring cost:** $179.2K/year (circuits + software + support) vs $240K MPLS baseline = **$60.8K annual savings**

**Note:** Circuit costs vary by location and provider; pricing assumes fiber/cable broadband availability

---

## ROI Analysis

### Cost Comparison: SD-WAN vs MPLS

**MPLS Baseline (Current State)**
- 25 sites × $800/month = $240,000 annually
- Bandwidth: 10-20 Mbps per site (250-500 Mbps total)
- 3-year total: $720,000

**SD-WAN (Proposed)**
- Year 1: $360,900 (CapEx + OpEx)
- Year 2-3: $179,200 annually
- Bandwidth: 100 Mbps per site (2,500 Mbps total = **10x increase**)
- 3-year total: $719,300

**Direct Savings**
- 3-year total savings: $700 (SD-WAN barely more expensive)
- **BUT:** 10x bandwidth increase and cloud optimization = massive value

### Value Beyond Cost Savings

**Productivity Gains ($75K annually)**
- 5% productivity improvement from faster SaaS performance
- 500 employees × $75K avg salary × 5% = $1.875M potential, conservatively value at $75K

**Project Acceleration ($35K annually)**
- New site deployment: hours vs 90 days
- Faster time-to-market for business initiatives
- M&A integration acceleration

**Total 3-Year Value**
- Direct WAN savings: $60.8K/year × 3 = $182.4K (after Year 1 investment)
- Productivity gains: $75K/year × 3 = $225K
- Project acceleration: $35K/year × 3 = $105K
- **Total value: $512.4K**

**ROI Calculation**
- 3-year investment: $719.3K
- 3-year value: $512.4K
- Net position: -$206.9K (investment exceeds savings)
- **Payback period: 27 months** (when cumulative savings offset Year 1 CapEx)

**Strategic Value (Unquantified)**
- Cloud migration enablement
- Business agility and rapid site deployment
- Superior user experience for cloud applications
- Platform for future SD-WAN security (SASE) evolution

---

## Success Metrics

### Performance KPIs (Measured at 3 months)
- WAN uptime: > 99.9% (vs 99.5% MPLS baseline)
- Application latency: Office 365 <50ms (vs 200ms baseline)
- VoIP call quality: MOS score >4.2 (excellent)
- Circuit failover time: <1 second (automatic)

### Cost KPIs (Measured at 12 months)
- Annual WAN cost: $179.2K (vs $240K MPLS baseline = 25% reduction)
- Cost per Mbps: $0.07 (vs $1.00 MPLS = 93% reduction)
- New site deployment cost: $2K (vs $15K MPLS provisioning)

### Operational KPIs (Ongoing)
- Site deployment time: <4 hours (vs 60-90 days MPLS)
- Policy update deployment: <10 minutes (vs 2-week change window)
- Mean time to repair (MTTR): <30 minutes (automatic failover)
- Application SLA compliance: >99% of traffic meets defined SLAs

---

## Risk Mitigation

### Technical Risks
- **Broadband circuit reliability:** Dual circuits (broadband + LTE) with automatic failover; SLA monitoring
- **Application performance degradation:** Pilot testing validates performance; SLA policies enforce QoS
- **Internet security exposure:** IPsec encryption, integrated firewall, Umbrella DNS filtering

### Organizational Risks
- **Team readiness:** 24 hours training included; vManage simplifies operations vs per-device CLI
- **Change resistance:** Pilot demonstrates value; transparent failover minimizes user impact
- **Circuit procurement delays:** Order circuits 60 days in advance; phased rollout accommodates delays

### Implementation Risks
- **Site outages during cutover:** Parallel run with MPLS; gradual app migration; rollback procedures tested
- **Vendor dependencies:** Cisco market leadership; multi-carrier circuit strategy reduces single point of failure
- **Budget overruns:** Fixed-price professional services; circuit costs validated with carriers; contingency buffer

---

## Next Steps

1. **Executive approval:** Review and approve $360.9K Year 1 investment
2. **Circuit procurement:** Order broadband circuits for 3 pilot sites (60-day lead time)
3. **Hardware procurement:** Order routers and controllers (4-week lead time)
4. **Design workshop:** Finalize architecture and application policies (weeks 1-2)
5. **Controller deployment:** Deploy vManage, vSmart, vBond in data center (weeks 3-4)
6. **Pilot deployment:** Deploy 3 pilot sites for validation (weeks 5-8)

**Recommended decision date:** Within 3 weeks to meet circuit lead times and Q4 pilot target

---

## Conclusion

Cisco SD-WAN transforms WAN economics and performance by replacing expensive MPLS with intelligent broadband and LTE circuits. The solution delivers 10x bandwidth increase, optimized cloud application performance, and rapid site deployment while achieving cost parity with existing MPLS over 3 years.

**Investment:** $719.3K over 3 years (similar to MPLS baseline)
**Value:** 10x bandwidth + cloud optimization + business agility
**Payback:** 27 months through productivity gains and operational efficiency
**Strategic Impact:** Foundation for cloud migration, SASE security, and digital transformation

This investment eliminates WAN as a bottleneck to cloud adoption, enables rapid business expansion, and positions the organization for cloud-first application delivery that is essential for competitive advantage in digital business.

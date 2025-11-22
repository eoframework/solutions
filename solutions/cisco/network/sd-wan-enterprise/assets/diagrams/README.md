# Cisco SD-WAN Enterprise - Architecture Diagram

## 📊 **Create with Draw.io**

### Required Components

**SD-WAN Controllers (Virtual):**
- vManage (management and orchestration)
- vSmart (control plane, routing policies)
- vBond (zero-touch provisioning orchestration)
- Hosted in data center or cloud (AWS/Azure)

**Hub Routers (Data Centers):**
- 2x Cisco ISR 4451 routers (redundant HA pair)
- Dual WAN circuits (1 Gbps internet + MPLS or direct cloud)
- Hub for all branch IPsec tunnels

**Branch Routers (25 Sites):**
- 25x Cisco ISR 4331 edge routers
- Dual WAN per site:
  - Primary: 100 Mbps broadband (fiber or cable)
  - Backup: LTE 4G/5G (10 GB/month)
- Zero-touch provisioning via vBond

**WAN Transport:**
- Broadband internet circuits (25x sites)
- LTE backup circuits (25x sites)
- Legacy MPLS (shown faded - being decommissioned)

**Application Optimization:**
- Application-aware routing policies
- SaaS optimization (Office 365, Salesforce, Webex)
- Direct cloud on-ramps to AWS/Azure (optional)

**Security:**
- Integrated firewall (zone-based)
- IPsec encryption for all SD-WAN tunnels
- Umbrella DNS security (optional)

**Cloud Connectivity:**
- AWS VPC (optional cloud on-ramp)
- Azure VNet (optional cloud on-ramp)

### Architecture Layout

**Top:** SD-WAN controllers (vManage, vSmart, vBond in cloud or data center)
**Center-Left:** 2 Hub routers (ISR 4451 pair) at data centers
**Center-Right:** Branch sites (25x ISR 4331) grouped into regions
**Bottom-Left:** WAN circuits (broadband, LTE) with circuit provider icons
**Bottom-Right:** Cloud providers (AWS, Azure) with direct connections
**Background (faded):** Legacy MPLS network being replaced

### Key Data Flows

1. **Zero-Touch Provisioning:**
   - New branch router → vBond orchestrator
   - vBond → vSmart (control plane policies)
   - vSmart → Branch router (routing configuration)

2. **Application Traffic:**
   - Office 365 traffic → Direct internet breakout (local site)
   - ERP/business apps → IPsec tunnel → Data center hubs
   - VoIP → SLA-enforced path (lowest latency)
   - Backup traffic → Cloud storage (AWS S3, Azure Blob)

3. **Circuit Failover:**
   - Primary broadband failure → Automatic LTE failover
   - Continuous monitoring with sub-second detection
   - Seamless application session continuity

4. **Management:**
   - vManage dashboard → All routers (monitoring, config, troubleshooting)
   - Centralized policy management → Pushed to all sites

### Export Settings
- 300 DPI PNG
- Transparent background
- Save as: `architecture-diagram.png`

### Color Coding
- **Blue:** Cisco SD-WAN infrastructure (controllers, routers)
- **Green:** WAN circuits (broadband, LTE)
- **Purple:** Cloud providers (AWS, Azure)
- **Orange:** Applications and data flows
- **Gray/Faded:** Legacy MPLS (being decommissioned)

### Annotations
- Show cost savings: "$300K MPLS → $176K SD-WAN (60% savings)"
- Highlight circuit diversity: "Dual circuits + LTE backup"
- Note zero-touch: "New sites deployed in 2 hours vs 8 weeks"
- Application optimization: "Direct Office 365 breakout (50% faster)"

---

## 🎯 **Key Architectural Principles**

- **Transport Independence:** Broadband, LTE, MPLS, 5G
- **Application-Aware:** SLA-based routing for business apps
- **Cloud-Ready:** Direct breakout for SaaS, cloud on-ramps for AWS/Azure
- **Zero-Touch Provisioning:** New sites online in hours, not weeks
- **Centralized Management:** Single vManage dashboard for all sites

---

## 📚 **References**

- **Cisco SD-WAN:** https://www.cisco.com/c/en/us/solutions/enterprise-networks/sd-wan/index.html
- **vManage:** https://www.cisco.com/c/en/us/td/docs/routers/sdwan/configuration/sdwan-xe-gs-book/system-overview.html
- **ISR 4000 Series:** https://www.cisco.com/c/en/us/products/routers/4000-series-integrated-services-routers-isr/index.html
- **SD-WAN Design Guide:** https://www.cisco.com/c/en/us/td/docs/solutions/CVD/SDWAN/cisco-sdwan-design-guide.html

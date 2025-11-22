# Juniper SRX Firewall Platform - Architecture Diagrams

## Overview
This directory contains architecture diagrams for the Juniper SRX Firewall Platform solution.

## Required Files

### 1. Architecture Diagram
- **File:** `srx-firewall-architecture.drawio` (Draw.io source file)
- **Export:** `srx-firewall-architecture.png` (PNG export for documents)
- **Purpose:** Primary architecture diagram showing datacenter HA pair, branch firewalls, security zones, and cloud connectivity

## Creating the Architecture Diagram

Follow these steps to create the architecture diagram:

### Step 1: Read Requirements
Review `DIAGRAM_REQUIREMENTS.md` for complete component list and layout specifications.

### Step 2: Create Diagram in Draw.io
1. Open Draw.io (https://app.diagrams.net/ or desktop app)
2. Create new diagram: File → New
3. Save as: `srx-firewall-architecture.drawio`

### Step 3: Add Components
Follow the layout specified in DIAGRAM_REQUIREMENTS.md:
- **Center-Top:** SRX4600 HA pair (datacenter firewalls)
- **Center:** Security zones (Untrust, DMZ, Trust, Management)
- **Left:** Branch offices with SRX300 firewalls
- **Right:** Multi-cloud environments (AWS, Azure, GCP)
- **Bottom:** Management infrastructure (Security Director, SIEM)

### Step 4: Add Security Services
Include visual indicators for:
- IPS (Intrusion Prevention) - 40 Gbps
- ATP Cloud (malware sandbox)
- SSL Inspection - 20 Gbps
- SecIntel (threat intelligence feeds)

### Step 5: Add Connections
Show traffic flows with colored arrows:
- Red: Untrust/Internet traffic
- Green: Trust/Internal traffic
- Purple (dashed): VPN tunnels
- Black (dotted): Management traffic

### Step 6: Export as PNG
1. Select all components (Ctrl+A)
2. File → Export as → PNG
3. Settings:
   - Resolution: 300 DPI
   - Border: 20px
   - Background: White
4. Save as: `srx-firewall-architecture.png`

## Diagram Specifications

### Resolution Requirements
- **Minimum:** 1920x1080 pixels
- **Recommended:** 2560x1440 pixels for 4K presentations
- **DPI:** 300 for print quality

### Color Scheme
- **Red:** Untrust zone and Internet-facing
- **Orange:** DMZ zone
- **Green:** Trust zone (internal)
- **Blue:** Management zone
- **Purple:** VPN tunnels
- **Gray:** Infrastructure components
- **Yellow:** Security services

### Key Components to Include

#### Datacenter (Primary Focus)
- [x] SRX4600 Primary (Active) - 80 Gbps throughput
- [x] SRX4600 Secondary (Passive) - HA cluster
- [x] Chassis cluster link (control + data)
- [x] Security zones: Untrust, DMZ, Trust, Management

#### Branch Offices (10 Sites)
- [x] SRX300 branch firewalls - 1 Gbps each
- [x] SD-WAN capabilities
- [x] IPsec VPN to datacenter
- [x] Show 2-3 representative sites with "x10" notation

#### Multi-Cloud Connectivity
- [x] AWS VPN Gateway - IPsec tunnel
- [x] Azure VPN Gateway - IPsec tunnel
- [x] Google Cloud VPN - IPsec tunnel
- [x] BGP routing integration

#### Advanced Security
- [x] IPS - 40 Gbps throughput
- [x] ATP Cloud - zero-day malware detection
- [x] SSL Inspection - 20 Gbps throughput
- [x] SecIntel - real-time threat feeds

#### Management Infrastructure
- [x] Junos Space Security Director - centralized policy management
- [x] Splunk SIEM - security event correlation
- [x] NetFlow collector - traffic analytics
- [x] Monitoring and alerting platform

## Usage in Documents

These diagrams are automatically embedded in:
- `presales/raw/solution-briefing.md` - Slide 4 (Solution Overview)
- Generated PowerPoint presentations
- Technical documentation

## Diagram Maintenance

Update diagrams when:
- Architecture changes (new zones, cloud providers)
- Performance specifications change (throughput upgrades)
- New security services added (additional threat prevention)
- Compliance requirements change (new audit controls)

## Tools and Resources

### Draw.io Desktop
- Download: https://github.com/jgraph/drawio-desktop/releases
- Platform: Windows, macOS, Linux
- Offline editing with full feature set

### Draw.io Web
- URL: https://app.diagrams.net/
- No installation required
- Cloud storage integration (Google Drive, OneDrive)

### Icon Libraries
- Networking icons: Built-in "Networking" library in Draw.io
- Cloud icons: AWS, Azure, GCP libraries
- Security icons: "Security" library for shields, locks

### Reference Materials
- Juniper SRX documentation: https://www.juniper.net/documentation/product/us/en/srx-series/
- Juniper validated designs: https://www.juniper.net/us/en/solutions/
- Network diagram best practices: Clean layout, logical flow, clear labels

## Quality Checklist

Before finalizing diagrams:
- [x] All components labeled with model numbers (SRX4600, SRX300)
- [x] Performance specifications visible (80 Gbps, 40 Gbps IPS, 20 Gbps SSL)
- [x] Security zones clearly demarcated with color coding
- [x] VPN tunnels shown with encryption indicators
- [x] HA cluster configuration visible (active/passive)
- [x] Management connections indicated (dotted lines)
- [x] Legend provided for arrow types and colors
- [x] Export resolution meets requirements (300 DPI)
- [x] File naming convention followed (lowercase, hyphens)

## File Naming Convention
- Source files: `[solution-name]-architecture.drawio`
- Exported diagrams: `[solution-name]-architecture.png`
- Example: `srx-firewall-architecture.drawio` → `srx-firewall-architecture.png`

---

**Status:** Awaiting diagram creation
**Last Updated:** 2025-11-22
**Created By:** EO Framework Migration Team

# Cisco DNA Center Network Analytics - Architecture Diagram

This directory contains instructions for creating the Cisco DNA Center Network Analytics architecture diagram.

## 📊 **Manual Creation with Draw.io**

### Overview
Create a professional architecture diagram using Draw.io Desktop with Cisco network icons.

### Prerequisites
- Download Draw.io Desktop: https://github.com/jgraph/drawio-desktop/releases
- Cisco icon library (optional): https://www.cisco.com/c/en/us/products/visio-stencil-listing.html

### Steps to Create the Diagram

1. **Enable Cisco Network Icons:**
   - Click "More Shapes..." in left sidebar
   - Scroll to "Networking" section
   - Check "Cisco" or "Cisco 19" (Cisco architecture icons)
   - Click "Apply"

2. **Build the Architecture (Components to Include):**

   **Management Layer:**
   - Cisco DNA Center (Primary + Secondary HA appliances)
   - vManage orchestration platform
   - Cisco Intersight cloud management

   **Network Infrastructure:**
   - Catalyst 9000 series switches (campus core/distribution)
   - Catalyst 3850/9300 access switches (100+ devices)
   - ISR 4000 series routers (WAN/branch)
   - Cisco Wireless LAN Controllers

   **Integration Layer:**
   - Active Directory (LDAP server icon)
   - ServiceNow (ITSM integration)
   - NetBox IPAM (database icon)

   **Monitoring & Analytics:**
   - AI Network Analytics engine
   - Application Experience monitoring (Office 365, Webex, SAP)
   - Telemetry collection (NetFlow, SNMP, syslog)

3. **Layout Recommendations:**
   - **Top:** Management plane (DNA Center, Intersight)
   - **Middle:** Network infrastructure (switches, routers, APs in hierarchical layout)
   - **Right:** Integration points (AD, ServiceNow, NetBox)
   - **Bottom:** Monitoring and analytics components

4. **Connections and Data Flows:**
   - NETCONF/RESTCONF connections from DNA Center to managed devices
   - Telemetry flows (NetFlow, syslog) from devices to DNA Center
   - API connections to ServiceNow and NetBox
   - LDAP authentication to Active Directory
   - Intersight cloud connection (dotted line showing cloud connectivity)

5. **Export to PNG:**
   - Select all (Ctrl+A / Cmd+A)
   - File > Export as > PNG
   - Settings: 300 DPI, 10px border, transparent background
   - Save as: `architecture-diagram.png` (in this directory)

### Required Components

**Cisco DNA Center Infrastructure (HA Pair):**
- Primary DN2-HW-APL appliance
- Secondary DN2-HW-APL appliance (HA failover)
- Connection between primary/secondary

**Network Devices (200 total):**
- Campus Core Switches (2x Catalyst 9500)
- Distribution Switches (10x Catalyst 9300)
- Access Switches (150x Catalyst 9200)
- Branch Routers (30x ISR 4000)
- Wireless Controllers (8x WLC 9800)

**External Integrations:**
- Active Directory server
- ServiceNow ITSM platform
- NetBox IPAM database

**Monitoring Components:**
- AI Analytics engine (inside DNA Center)
- Application monitoring dashboards
- Telemetry collectors

### Color Coding Recommendations
- **Blue:** Cisco infrastructure (DNA Center, switches, routers)
- **Green:** External integrations (AD, ServiceNow, NetBox)
- **Orange:** Monitoring and analytics
- **Gray:** Network connections and data flows

### Labels and Annotations
- Label each major component with its role
- Use arrows to show:
  - Management traffic (DNA Center → devices)
  - Telemetry flows (devices → DNA Center)
  - API calls (DNA Center ↔ integrations)
- Add brief descriptions for key integration points

---

## 📐 **Architecture Overview**

The diagram should illustrate:

1. **Centralized Management:** DNA Center (HA pair) as the orchestration hub
2. **Hierarchical Network:** Campus core → distribution → access topology
3. **AI Analytics:** Predictive insights and anomaly detection within DNA Center
4. **Application Monitoring:** SaaS app performance tracking (Office 365, Webex, SAP)
5. **Integration Points:** AD for authentication, ServiceNow for ITSM, NetBox for IPAM

---

## 🎯 **Key Architectural Principles**

- **High Availability:** Primary + Secondary DNA Center appliances
- **Scalability:** 200-device capacity with room to grow to 500+
- **Intent-Based Networking:** Policy-driven automation through DNA Center
- **AI-Powered:** Predictive analytics with 14-day failure warnings
- **Cloud-Managed:** Cisco Intersight for unified cloud management

---

## 📁 **File Naming**

- **Source:** `architecture-diagram.drawio` (editable Draw.io file)
- **Export:** `architecture-diagram.png` (300 DPI PNG for documentation)

---

## 🔄 **After Creating the Diagram**

The PNG file will be automatically embedded in:
- `presales/raw/solution-briefing.md` (Slide 4: Solution Overview)
- `presales/raw/statement-of-work.md` (Architecture & Design section)
- Generated PowerPoint and Word deliverables

No need to manually update the markdown files - they already reference `assets/diagrams/architecture-diagram.png`.

---

## 📚 **References**

- **Cisco DNA Center:** https://www.cisco.com/c/en/us/products/cloud-systems-management/dna-center/index.html
- **Cisco Icons:** https://www.cisco.com/c/en/us/products/visio-stencil-listing.html
- **Draw.io Documentation:** https://www.diagrams.net/doc/
- **DNA Center Design Guide:** https://www.cisco.com/c/en/us/solutions/collateral/enterprise-networks/dna-center/nb-06-dna-center-design-guide-cte-en.html

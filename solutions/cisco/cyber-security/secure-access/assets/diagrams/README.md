# Cisco ISE Secure Network Access - Architecture Diagram

## 📊 **Create with Draw.io**

### Required Components

**ISE Infrastructure (HA Deployment):**
- Cisco ISE 3615 Primary appliance (Policy Service Node + Admin)
- Cisco ISE 3615 Secondary appliance (HA failover + PSN)
- ISE Plus licenses (3000 endpoints with TrustSec)

**Identity Source:**
- Active Directory (LDAP server)
- User groups and OUs
- Computer accounts

**Network Enforcement Points:**
- Catalyst 9000 series switches (wired 802.1X)
- Wireless LAN Controllers (wireless 802.1X)
- Access layer switches configured for authentication

**User Access Methods:**
- Corporate users (domain-joined computers with 802.1X)
- BYOD devices (iOS, Android with self-service portal)
- Guest users (portal-based authentication)
- IoT/Printers (MAC Authentication Bypass - MAB)

**Portals:**
- BYOD self-service portal (certificate provisioning)
- Guest portal (sponsor-based workflow)
- Sponsor portal (guest approval)

**TrustSec Segmentation:**
- Security Group Tags (SGT) assignment
- Security Group ACL (SGACL) policy matrix
- Inline tagging and enforcement

### Architecture Layout

**Top-Center:** ISE HA pair (primary + secondary)
**Top-Left:** Active Directory server
**Middle:** Network infrastructure (switches and WLCs)
**Bottom:** User devices grouped by type:
  - Corporate computers (802.1X authenticated)
  - BYOD devices (iOS, Android with certificates)
  - Guest devices (portal authentication)
  - IoT devices (MAB)

**Right:** Portals and workflows (BYOD, Guest, Sponsor)

### Key Data Flows

1. **Authentication Flow:**
   - User device → Switch/WLC → RADIUS → ISE
   - ISE → Active Directory (LDAP lookup)
   - ISE → Device (authorization policy: VLAN, ACL, SGT)

2. **BYOD Onboarding:**
   - BYOD device → Captive portal → ISE portal
   - User login (AD credentials) → Certificate provisioning
   - Device profile installed → 802.1X authentication

3. **Guest Access:**
   - Guest connects → Captive portal → Guest portal
   - Self-registration or sponsor approval
   - Time-limited access granted

4. **TrustSec Enforcement:**
   - ISE assigns SGT based on user/device identity
   - Switch tags traffic with SGT
   - SGACL policy matrix enforces micro-segmentation

### Export Settings
- 300 DPI PNG
- Transparent background
- Save as: `architecture-diagram.png`

### Color Coding
- **Blue:** ISE infrastructure and RADIUS
- **Green:** Network devices (switches, WLCs)
- **Purple:** Active Directory
- **Orange:** User devices
- **Red:** TrustSec security policies
- **Gray:** Portals and workflows

### Annotations
- Label authentication methods: "802.1X (EAP-TLS)", "MAB", "Guest Portal"
- Show RADIUS connections between ISE and network devices
- Indicate TrustSec SGT assignment and enforcement points

---

## 🎯 **Key Architectural Principles**

- **Zero Trust:** Mandatory authentication for all network access
- **Identity-Based:** Access control based on who/what, not just where
- **Micro-Segmentation:** TrustSec SGT policies without VLANs
- **Self-Service:** Automated BYOD onboarding reduces helpdesk load
- **High Availability:** Primary + Secondary ISE ensures 99.9% uptime

---

## 📚 **References**

- **Cisco ISE:** https://www.cisco.com/c/en/us/products/security/identity-services-engine/index.html
- **TrustSec:** https://www.cisco.com/c/en/us/solutions/enterprise-networks/trustsec/index.html
- **ISE Design Guide:** https://www.cisco.com/c/en/us/td/docs/security/ise/end-user-documentation/Cisco_ISE_End_User_Documentation.html

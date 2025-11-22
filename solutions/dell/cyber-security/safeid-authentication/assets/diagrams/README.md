# Dell SafeID Authentication Platform - Architecture Diagram

## Current Status

✅ **Draw.io Source File:** `architecture-diagram.drawio` (complete)
⚠️ **PNG Export:** `architecture-diagram.png` (needs export)

## Export Instructions

### Step 1: Open Draw.io
- https://app.diagrams.net or Draw.io Desktop
- Open `architecture-diagram.drawio`

### Step 2: Verify Security Components

**Users & Access:**
- ✓ End users (desktop, mobile, laptop)
- ✓ Access methods (VPN, web SSO, corporate network)

**Dell SafeID Platform:**
- ✓ SafeID servers (HA pair with load balancer)
- ✓ Authentication methods: Hardware tokens, soft tokens, biometric, push notifications
- ✓ Active Directory / LDAP integration

**Protected Resources:**
- ✓ Enterprise applications (Salesforce, Office 365, custom apps)
- ✓ Network access (VPN gateways, WiFi 802.1X)
- ✓ Privileged access (admin consoles, servers)

**Integration Protocols:**
- ✓ SAML 2.0 (web SSO)
- ✓ RADIUS (network access)
- ✓ LDAP (legacy apps)
- ✓ OAuth 2.0/OIDC (modern APIs)

**Security & Monitoring:**
- ✓ SIEM integration (Splunk, QRadar)
- ✓ Audit logging
- ✓ Anomaly detection

### Step 3: Export PNG

1. Select All (Ctrl+A)
2. File → Export as → PNG
3. Settings:
   - Zoom: 100%
   - Border: 10px
   - Transparent: ✓
4. Save as `architecture-diagram.png`

### Step 4: Regenerate Documents

```bash
cd /mnt/c/projects/wsl/eof-tools/converters/presales/scripts
python3 solution-presales-converter.py \
  --path /mnt/c/projects/wsl/solutions/solutions/dell/cyber-security/safeid-authentication \
  --force
```

## Authentication Flow

1. User attempts login → Application
2. SAML/RADIUS request → SafeID Server
3. Primary auth → AD/LDAP validates username/password
4. MFA challenge → SafeID requests second factor
5. Token validation → OTP, biometric, or push approved
6. Access granted → SAML assertion or RADIUS accept
7. Audit log → Event recorded for compliance

## Key Security Features

- **Multi-Factor Authentication:** Hardware/soft tokens, biometric, push
- **Adaptive Authentication:** Risk-based MFA policies
- **Zero Trust:** Always verify, never trust
- **High Availability:** Active-active or active-passive HA
- **Compliance:** Audit logs, SIEM integration, reporting

---

**Last Updated:** November 22, 2025
**Status:** Ready for PNG export

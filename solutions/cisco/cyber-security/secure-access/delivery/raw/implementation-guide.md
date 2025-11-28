---
document_title: Implementation Guide
solution_name: Cisco Secure Access Zero Trust Implementation
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: cisco
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the Cisco Secure Access Zero Trust solution. The guide covers Cisco Duo MFA deployment, Cisco Umbrella DNS security configuration, Cisco ISE network access control, Cisco AnyConnect VPN replacement, and Cisco SecureX unified orchestration. The solution protects 2,500 users with enterprise-grade zero trust security.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying the zero trust security platform and enrolling users. All procedures have been validated against Cisco Secure Access platform specifications.

## Implementation Approach

The implementation follows a phased methodology starting with core platform deployment, progressing through integration configuration, and concluding with phased user enrollment across multiple waves to minimize risk and ensure adoption.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| Duo Admin API | User enrollment automation | `scripts/duo/` | Duo API credentials |
| ISE ERS API | Endpoint and policy management | `scripts/ise/` | ISE admin access |
| PowerShell | AD and enrollment scripts | `scripts/powershell/` | PowerShell 7.0+ |
| SecureX Orchestration | Incident response workflows | SecureX cloud | SecureX tenant |

## Scope Summary

### In Scope

The following components are deployed using the procedures in this guide.

- Cisco Duo MFA for 2,500 users with adaptive authentication
- Cisco Umbrella DNS security and Secure Web Gateway
- Cisco ISE network access control (802.1X, posture)
- Cisco AnyConnect VPN replacement deployment
- Cisco SecureX unified security dashboard
- Active Directory and SAML SSO integration
- SIEM integration for security monitoring
- Operations team training (32 hours total)

### Out of Scope

The following items are excluded from this implementation guide.

- Endpoint detection and response (EDR) deployment
- Security awareness training content creation
- Third-party application code remediation
- Physical security controls

## Timeline Overview

The implementation follows a phased deployment approach with validation gates.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & Planning | 2 weeks | Requirements validated |
| 2 | Platform Deployment | 4 weeks | Core platforms operational |
| 3 | Integration Configuration | 2 weeks | SSO and integrations working |
| 4 | Testing & Validation | 2 weeks | Security tests passed |
| 5 | User Enrollment | 2 weeks | All 2,500 users enrolled |
| 6 | Go-Live & Hypercare | 2 weeks | Production stable |

**Total Implementation:** ~14 weeks including hypercare

# Prerequisites

This section documents all requirements that must be satisfied before security platform deployment can begin.

## Tool Installation

The following tools must be installed on the deployment workstation before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **PowerShell 7.0+** - For automation scripts
- [ ] **Duo Admin Portal Access** - For MFA configuration
- [ ] **Umbrella Dashboard Access** - For DNS security management
- [ ] **ISE Admin Access** - For NAC policy configuration
- [ ] **Active Directory Tools** - For user and group management

### PowerShell Module Installation

Install required PowerShell modules for automation.

```powershell
# Install Active Directory module
Install-WindowsFeature RSAT-AD-PowerShell

# Install Duo PowerShell module (if available)
Install-Module -Name DuoSecurity -Scope CurrentUser

# Verify installation
Get-Module -ListAvailable | Where-Object {$_.Name -like "*Duo*" -or $_.Name -like "*AD*"}
```

### Duo API Client Setup

Configure Duo Admin API access for automation.

```bash
# Duo API credentials required:
# - Integration Key (ikey)
# - Secret Key (skey)
# - API Hostname

# Test API connectivity
curl -X GET "https://api-xxxxxxxx.duosecurity.com/admin/v1/info/summary" \
  --header "Authorization: Basic $(echo -n 'ikey:skey' | base64)"
```

## Infrastructure Prerequisites

The following infrastructure must be available before platform deployment.

### Network Requirements

- [ ] Internet connectivity for Duo, Umbrella, SecureX (HTTPS outbound)
- [ ] DNS infrastructure accessible for Umbrella redirection
- [ ] Network switches support 802.1X authentication
- [ ] VPN headend (ASA/FTD) accessible for AnyConnect
- [ ] Certificate authority available for RADIUS certificates

### Identity Requirements

- [ ] Active Directory operational with required user groups
- [ ] Service accounts created for Cisco platform integration
- [ ] LDAPS connectivity tested from ISE deployment network
- [ ] User groups created for security policy assignment

### Security Requirements

- [ ] Firewall rules allow cloud platform connectivity
- [ ] SIEM available for security event integration
- [ ] Certificate chain for RADIUS authentication
- [ ] API credentials provisioned for automation

## Prerequisite Validation

Run the prerequisite validation to verify all requirements.

```bash
# Validate Duo API connectivity
curl -s "https://api-xxxxxxxx.duosecurity.com/auth/v2/ping" | jq .

# Validate Umbrella connectivity
nslookup resolver1.opendns.com

# Validate Active Directory connectivity
Test-NetConnection -ComputerName dc01.client.local -Port 636

# Validate ISE connectivity (after deployment)
curl -k -u admin:password https://ise-pan-01.client.local/ers/config/endpoint
```

### Validation Checklist

Complete this checklist before proceeding to platform deployment.

- [ ] Duo tenant provisioned with Admin API enabled
- [ ] Umbrella organization created with API credentials
- [ ] ISE hardware/VM resources allocated
- [ ] AnyConnect licenses available
- [ ] SecureX tenant provisioned
- [ ] Active Directory service accounts created
- [ ] Network firewall rules configured
- [ ] SIEM integration endpoints documented

# Environment Setup

This section covers the initial environment configuration for security platform deployment.

## Duo Tenant Configuration

Configure the Duo tenant for enterprise deployment.

### Duo Admin Portal Access

```
# Access Duo Admin Portal
URL: https://admin.duosecurity.com

# Create Admin API application
1. Navigate to Applications > Protect an Application
2. Search for "Admin API"
3. Click "Protect"
4. Note Integration Key, Secret Key, API Hostname
5. Enable required Admin API permissions:
   - Grant read information
   - Grant write resource
   - Grant read log
```

### Duo Authentication Proxy Setup

Deploy Duo Authentication Proxy for AD integration.

```bash
# Download Duo Authentication Proxy
wget https://dl.duosecurity.com/duoauthproxy-latest.tar.gz

# Extract and install
tar xzf duoauthproxy-latest.tar.gz
cd duoauthproxy-*
./configure
make install

# Configure authproxy.cfg
cat > /opt/duoauthproxy/conf/authproxy.cfg << 'EOF'
[ad_client]
host=dc01.client.local
service_account_username=svc_duo_auth
service_account_password_protected=encrypted_password
search_dn=DC=client,DC=local
security_group_dn=CN=Duo-Users,OU=Security Groups,DC=client,DC=local

[radius_server_auto]
ikey=YOUR_INTEGRATION_KEY
skey=YOUR_SECRET_KEY
api_host=api-xxxxxxxx.duosecurity.com
radius_ip_1=10.100.1.50
radius_secret_1=your_radius_secret
client=ad_client
EOF

# Start Authentication Proxy
/opt/duoauthproxy/bin/authproxyctl start
```

## Umbrella Organization Setup

Configure Umbrella organization and policies.

### Umbrella Dashboard Configuration

```
# Access Umbrella Dashboard
URL: https://dashboard.umbrella.com

# Configure Organization Settings
1. Navigate to Admin > Settings
2. Configure organization name and timezone
3. Enable Intelligent Proxy (SIG)
4. Configure API credentials in Admin > API Keys
```

### Umbrella Virtual Appliance Deployment

Deploy Umbrella Virtual Appliance for internal DNS forwarding.

```bash
# Download Umbrella VA OVA
# Deploy to VMware environment

# Configure VA via console
umbrella-va configure
# Enter Organization ID
# Enter Registration Token
# Configure network settings

# Verify registration
umbrella-va status
```

## ISE Deployment Preparation

Prepare environment for ISE deployment.

### ISE VM Requirements

```
# ISE Node Requirements for 2,500 users:

# Primary PAN (Policy Administration Node)
- vCPU: 8 cores
- Memory: 64 GB
- Disk: 600 GB

# Policy Service Node (PSN) x2
- vCPU: 8 cores
- Memory: 96 GB
- Disk: 300 GB

# MnT Node (Monitoring and Troubleshooting)
- vCPU: 8 cores
- Memory: 64 GB
- Disk: 600 GB (log storage)
```

### ISE Network Configuration

```bash
# Configure DNS entries before deployment
# ise-pan-01.client.local -> 10.100.1.60
# ise-pan-02.client.local -> 10.100.1.61
# ise-psn-01.client.local -> 10.100.1.62
# ise-psn-02.client.local -> 10.100.1.63

# Verify DNS resolution
nslookup ise-pan-01.client.local
nslookup ise-psn-01.client.local
```

# Infrastructure Deployment

This section covers the phased deployment of security infrastructure.

## Deployment Overview

Infrastructure deployment follows a dependency-ordered sequence.

<!-- TABLE_CONFIG: widths=[15, 25, 35, 25] -->
| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | DNS config, firewall rules, RADIUS | Prerequisites complete |
| 2 | Security | Duo, Umbrella, ISE deployment | Networking |
| 3 | Compute | ISE cluster, auth proxy | Security platforms |
| 4 | Monitoring | SecureX, SIEM integration | All platforms |

## Phase 1: Networking Layer

Configure network infrastructure for security platform connectivity.

### Networking Components

The networking layer configures the following resources.

- DNS forwarding to Umbrella resolvers
- Firewall rules for cloud platform connectivity
- RADIUS ports for ISE authentication
- VPN ports for AnyConnect

### DNS Configuration for Umbrella

```bash
# Configure internal DNS to forward to Umbrella
# For Umbrella Virtual Appliance deployment:

# Primary DNS: Umbrella VA (10.100.1.70)
# Secondary DNS: Umbrella VA (10.100.1.71)

# For direct Umbrella:
# Primary: 208.67.222.222 (with Umbrella org ID)
# Secondary: 208.67.220.220

# Verify DNS forwarding
nslookup www.google.com 10.100.1.70
```

### Firewall Rules

```bash
# Required outbound firewall rules:

# Duo (HTTPS)
- api-xxxxxxxx.duosecurity.com:443
- admin.duosecurity.com:443

# Umbrella (DNS, HTTPS)
- 208.67.222.222:53
- 208.67.220.220:53
- *.umbrella.com:443

# SecureX (HTTPS)
- *.securex.cisco.com:443
- *.amp.cisco.com:443

# Verify connectivity
curl -I https://api-xxxxxxxx.duosecurity.com
curl -I https://dashboard.umbrella.com
```

### Networking Validation

```bash
# Verify DNS resolution via Umbrella
dig @208.67.222.222 +short myip.opendns.com

# Verify Duo API connectivity
curl -s "https://api-xxxxxxxx.duosecurity.com/auth/v2/check" | jq .

# Verify ISE management access
ping ise-pan-01.client.local
```

## Phase 2: Security Layer

Deploy and configure core security platforms.

### Cisco Duo Deployment

Configure Duo MFA platform and authentication policies.

```
# Duo Admin Portal Configuration

# 1. Configure Authentication Policy
Navigation: Policies > Authentication Policy
- Create policy: "Corporate-Adaptive"
- Enable: Adaptive authentication
- Enable: Device health check
- Enable: Remembered devices (14 days)

# 2. Configure Protected Applications
Navigation: Applications > Protect an Application
- Add: RADIUS (for ISE integration)
- Add: Generic SAML (for SSO)
- Add: Microsoft Azure AD (if applicable)

# 3. Configure User Groups
Navigation: Users > Groups
- Create: "DUO-Standard-Users"
- Create: "DUO-Privileged-Users"
- Configure group policies
```

### Cisco Umbrella Configuration

```
# Umbrella Dashboard Configuration

# 1. Configure DNS Policy
Navigation: Policies > DNS Policies
- Create policy: "Corporate-Security"
- Block: Malware, Phishing, Botnet
- Block: Command & Control
- Enable: Intelligent Proxy

# 2. Configure Web Policy (SWG)
Navigation: Policies > Web Policies
- Create policy: "Corporate-Web"
- Enable: HTTPS inspection
- Block: High-risk categories
- Allow: Business applications

# 3. Configure Identities
Navigation: Deployments > Configuration > Identities
- Add: AD Integration
- Map: User groups to policies
```

### Cisco ISE Deployment

Deploy ISE cluster for network access control.

```bash
# ISE Initial Setup via CLI

# 1. Boot ISE VM from ISO
# 2. Complete initial setup wizard:
setup
# Enter hostname: ise-pan-01
# Enter IP address: 10.100.1.60
# Enter netmask: 255.255.255.0
# Enter gateway: 10.100.1.1
# Enter DNS: 10.100.5.10
# Enter NTP: 10.100.4.10
# Enter admin password: ********

# 3. After initial boot, access GUI
# https://ise-pan-01.client.local

# 4. Configure ISE Deployment
# Administration > System > Deployment
# - Register secondary PAN for HA
# - Add PSN nodes for authentication
# - Configure MnT node for logging
```

### ISE Active Directory Integration

```
# ISE AD Integration

# 1. Add AD Join Point
Navigation: Administration > Identity Management > External Identity Sources
- Add: Active Directory
- Domain: client.local
- Join Point: ise-ad-join
- Credentials: svc_ise_ad / ********

# 2. Configure AD Groups
Navigation: Administration > Identity Management > External Identity Sources > AD
- Import groups for authorization:
  - Domain Users
  - IT-Admins
  - Security-Admins
  - Contractors

# 3. Test AD Connectivity
- Run: Test User (with valid AD credentials)
- Verify: Group membership retrieval
```

### Security Validation

```bash
# Verify Duo enrollment portal
curl -I https://enrollment.duosecurity.com

# Verify Umbrella DNS blocking
nslookup examplemalwaredomain.com
# Should return Umbrella block page IP

# Verify ISE admin access
curl -k https://ise-pan-01.client.local/admin/
```

## Phase 3: Compute Layer

Deploy compute resources for security platform scaling.

### ISE Cluster Configuration

```
# ISE Cluster Setup

# 1. Register Secondary PAN
# On Primary PAN:
Navigation: Administration > System > Deployment
- Click: Register
- Enter secondary PAN hostname
- Wait for sync completion

# 2. Add PSN Nodes
Navigation: Administration > System > Deployment
- Register: ise-psn-01
- Register: ise-psn-02
- Enable: Policy Service persona
- Configure: Node groups for failover

# 3. Configure Load Distribution
Navigation: Administration > System > Deployment
- Configure: PSN node group
- Enable: PSN load balancing
```

### Duo Authentication Proxy Scaling

```bash
# Deploy secondary Authentication Proxy for HA

# On secondary proxy server:
# Install Duo Authentication Proxy (same as primary)

# Configure for failover
cat > /opt/duoauthproxy/conf/authproxy.cfg << 'EOF'
[ad_client]
host=dc01.client.local
host_2=dc02.client.local
service_account_username=svc_duo_auth
service_account_password_protected=encrypted_password
search_dn=DC=client,DC=local

[radius_server_auto]
ikey=YOUR_INTEGRATION_KEY
skey=YOUR_SECRET_KEY
api_host=api-xxxxxxxx.duosecurity.com
radius_ip_1=10.100.1.50
radius_ip_2=10.100.1.51
radius_secret_1=your_radius_secret
radius_secret_2=your_radius_secret
client=ad_client
failmode=safe
EOF

# Start service
/opt/duoauthproxy/bin/authproxyctl start
```

### Compute Validation

```bash
# Verify ISE cluster status
# ISE GUI: Administration > System > Deployment
# All nodes should show "Connected"

# Verify Authentication Proxy
/opt/duoauthproxy/bin/authproxyctl status
# Should show: running

# Test RADIUS authentication
radtest testuser testpassword 10.100.1.60 1812 testing123
```

## Phase 4: Monitoring Layer

Configure monitoring and security orchestration.

### SecureX Configuration

```
# SecureX Dashboard Setup

# 1. Access SecureX
URL: https://securex.cisco.com

# 2. Add Integration Modules
Navigation: Administration > Integrations
- Add: Cisco Duo
- Add: Cisco Umbrella
- Add: Cisco ISE (via pxGrid)

# 3. Configure Dashboard
Navigation: Dashboard
- Add tiles for:
  - Duo authentication events
  - Umbrella threat blocks
  - ISE session summary
  - SecureX incidents

# 4. Create Orchestration Workflows
Navigation: Orchestration
- Import: Account lockout workflow
- Import: Threat containment workflow
```

### SIEM Integration

```bash
# Configure ISE syslog to SIEM
# ISE GUI: Administration > System > Logging > Remote Logging Targets

# Add SIEM target
# Name: SIEM-Primary
# Target Type: Syslog
# IP: siem.client.local
# Port: 514
# Protocol: TCP-TLS

# Configure Duo syslog
# Duo Admin Panel: Reports > Logs > Syslog
# Enable: Syslog export
# Target: siem.client.local:514

# Configure Umbrella log export
# Umbrella Dashboard: Admin > Log Export
# Enable: Amazon S3 or SIEM integration
```

### Monitoring Validation

```bash
# Verify SecureX connectivity
# SecureX Dashboard: Administration > Integrations
# All integrations should show "Connected"

# Verify SIEM log receipt
# Check SIEM for events from:
# - Duo authentication logs
# - Umbrella DNS logs
# - ISE RADIUS logs

# Generate test event
# Trigger failed Duo authentication
# Verify event appears in SIEM and SecureX
```

# Application Configuration

This section covers application integration and SSO configuration.

## AnyConnect Deployment

Deploy Cisco AnyConnect for VPN replacement.

### AnyConnect Headend Configuration

```
# ASA/FTD Configuration for AnyConnect

# Enable AnyConnect
webvpn
 enable outside
 anyconnect image disk0:/anyconnect-win-4.x.pkg
 anyconnect enable

# Configure connection profile
tunnel-group secure-access type remote-access
tunnel-group secure-access general-attributes
 address-pool vpn-pool
 authentication-server-group ISE
 secondary-authentication-server-group DUO

tunnel-group secure-access webvpn-attributes
 group-alias secure-access enable
```

### AnyConnect Profile Configuration

```xml
<!-- AnyConnect Profile: secure-access-profile.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<AnyConnectProfile xmlns="http://schemas.xmlsoap.org/encoding/">
  <ServerList>
    <HostEntry>
      <HostName>Secure Access</HostName>
      <HostAddress>vpn.client.local</HostAddress>
    </HostEntry>
  </ServerList>
  <AutomaticVPNPolicy>
    <TrustedNetworkPolicy>Disconnect</TrustedNetworkPolicy>
    <UntrustedNetworkPolicy>Connect</UntrustedNetworkPolicy>
  </AutomaticVPNPolicy>
</AnyConnectProfile>
```

## SAML SSO Configuration

Configure SAML SSO for enterprise applications.

### Duo as SAML IdP

```
# Configure Duo as SAML Identity Provider

# Duo Admin Portal: Applications > Protect an Application
# Search: Generic SAML Service Provider

# Configure SAML settings:
# - Entity ID: https://app.client.local/saml
# - ACS URL: https://app.client.local/saml/acs
# - Name ID: email
# - Signed Response: Yes
# - Signed Assertion: Yes

# Download metadata for SP configuration
# Configure SP with Duo IdP metadata
```

### Application Integration Example

```bash
# Example: Integrate SaaS application with Duo SSO

# 1. In Duo Admin Portal:
#    - Create Generic SAML application
#    - Configure SP metadata from application

# 2. In Application Admin:
#    - Configure SAML SSO
#    - Import Duo IdP metadata
#    - Map user attributes

# 3. Test SSO flow:
#    - Access application
#    - Redirect to Duo
#    - Complete MFA
#    - Return to application authenticated
```

## ISE Policy Configuration

Configure ISE network access policies.

### Authorization Policies

```
# ISE Authorization Policy Configuration

# 1. Create Authorization Profiles
Navigation: Policy > Policy Elements > Results > Authorization > Authorization Profiles

# Profile: Corporate-Full-Access
- Access Type: ACCESS_ACCEPT
- VLAN: Corporate (VLAN 100)
- dACL: Permit-All

# Profile: Guest-Limited-Access
- Access Type: ACCESS_ACCEPT
- VLAN: Guest (VLAN 200)
- dACL: Permit-Internet-Only

# 2. Create Authorization Policies
Navigation: Policy > Authorization Policy

# Rule: IT-Admin-Access
- Condition: AD:ExternalGroups CONTAINS IT-Admins
- Profile: Corporate-Full-Access

# Rule: Employee-Access
- Condition: AD:ExternalGroups CONTAINS Domain Users
- AND Posture:Compliant EQUALS Compliant
- Profile: Corporate-Full-Access

# Rule: Non-Compliant
- Condition: Posture:Compliant EQUALS Non-Compliant
- Profile: Quarantine
```

# Integration Testing

This section covers security platform integration testing.

## Test Environment Preparation

Prepare test environment for validation.

```powershell
# Create test users in Active Directory
$TestUsers = @(
    @{Name="test.user1"; Groups=@("Domain Users", "Duo-Users")},
    @{Name="test.admin1"; Groups=@("IT-Admins", "Duo-Users")},
    @{Name="test.guest1"; Groups=@("Contractors")}
)

foreach ($User in $TestUsers) {
    New-ADUser -Name $User.Name -AccountPassword (ConvertTo-SecureString "TestPassword1!" -AsPlainText -Force) -Enabled $true
    foreach ($Group in $User.Groups) {
        Add-ADGroupMember -Identity $Group -Members $User.Name
    }
}
```

## Integration Test Execution

### Authentication Flow Test

```powershell
# Test Duo MFA authentication flow

# 1. Test user enrollment
# - Access Duo enrollment portal
# - Complete device enrollment
# - Verify user appears in Duo Admin

# 2. Test push authentication
# - Initiate login requiring MFA
# - Receive Duo push on mobile
# - Approve authentication
# - Verify access granted

# 3. Test adaptive authentication
# - Login from trusted location (no step-up)
# - Login from new device (require step-up)
# - Verify policy enforcement
```

### Network Access Test

```bash
# Test ISE 802.1X authentication

# 1. Configure test workstation for 802.1X
# - Enable wired/wireless 802.1X
# - Configure EAP-PEAP with machine cert

# 2. Connect to network
# - Verify RADIUS authentication to ISE
# - Check Duo secondary authentication
# - Verify VLAN assignment

# 3. Check ISE session
# ISE GUI: Operations > RADIUS > Live Sessions
# Verify: Username, VLAN, Posture status
```

### DNS Security Test

```bash
# Test Umbrella DNS protection

# 1. Test malware domain blocking
nslookup examplemalwaredomain.com
# Should return Umbrella block page

# 2. Test phishing protection
nslookup phishing-test.umbrella.com
# Should return block page

# 3. Verify logging
# Umbrella Dashboard: Reports > Activity Search
# Verify block events appear
```

## Test Success Criteria

Complete this checklist before proceeding.

- [ ] Duo user enrollment completes successfully
- [ ] Duo push authentication works from mobile app
- [ ] Umbrella blocks test malware domains
- [ ] ISE authenticates users via 802.1X
- [ ] ISE enforces VLAN based on user group
- [ ] AnyConnect VPN connects with Duo MFA
- [ ] SSO applications authenticate via Duo SAML
- [ ] SecureX shows events from all platforms
- [ ] SIEM receives security logs

# Security Validation

This section covers security testing and compliance validation.

## Security Scan Execution

### Penetration Testing

```bash
# Penetration test scope:
# - External: VPN headend, web SSO endpoints
# - Internal: ISE, Duo Auth Proxy
# - Credential: MFA bypass attempts

# Test categories:
# 1. Authentication bypass attempts
# 2. Session hijacking tests
# 3. Policy circumvention tests
# 4. Credential stuffing tests
```

### Policy Validation

```bash
# Validate security policies

# 1. Test MFA enforcement
# - Attempt login without MFA device
# - Verify access denied

# 2. Test device trust
# - Login from untrusted device
# - Verify step-up authentication required

# 3. Test network segmentation
# - Connect as guest
# - Attempt access to corporate resources
# - Verify blocked by ISE policy
```

## Compliance Validation Checklist

- [ ] All access requires MFA (SOC 2)
- [ ] Authentication events logged (SOC 2, HIPAA)
- [ ] Encryption in transit verified (HIPAA)
- [ ] Role-based access enforced (SOC 2)
- [ ] Failed login attempts logged (HIPAA)
- [ ] Session timeouts configured (SOC 2)
- [ ] Network segmentation validated (PCI DSS)

# Migration & Cutover

This section covers user enrollment and migration procedures.

## Pre-Migration Checklist

- [ ] All platforms deployed and validated
- [ ] Integration testing completed
- [ ] User communication sent
- [ ] Help desk trained on procedures
- [ ] Rollback procedures documented
- [ ] Executive approval obtained

## User Enrollment Execution

### Pilot Enrollment: 100 Users

```powershell
# Pilot user enrollment

# 1. Select pilot users (IT staff, early adopters)
$PilotUsers = Get-ADGroupMember -Identity "Duo-Pilot-Users"

# 2. Send enrollment invitations
foreach ($User in $PilotUsers) {
    # Duo Admin API: Send enrollment email
    Invoke-DuoEnrollment -Username $User.SamAccountName -Email $User.Email
}

# 3. Monitor enrollment progress
# Duo Admin: Users > Pending Enrollments
# Target: 100% pilot enrollment within 3 days
```

### Wave Enrollment

```powershell
# Wave-based user enrollment

# Wave 1: 500 users (Department A)
$Wave1Users = Get-ADGroupMember -Identity "Duo-Wave1-Users"
foreach ($User in $Wave1Users) {
    Invoke-DuoEnrollment -Username $User.SamAccountName
}
# Wait: 4 days for enrollment

# Wave 2: 1000 users (Departments B, C)
$Wave2Users = Get-ADGroupMember -Identity "Duo-Wave2-Users"
foreach ($User in $Wave2Users) {
    Invoke-DuoEnrollment -Username $User.SamAccountName
}
# Wait: 4 days for enrollment

# Wave 3: Remaining 900 users
$Wave3Users = Get-ADGroupMember -Identity "Duo-Wave3-Users"
foreach ($User in $Wave3Users) {
    Invoke-DuoEnrollment -Username $User.SamAccountName
}
```

## Rollback Procedures

If critical issues occur, execute rollback.

```bash
# Duo bypass for emergency access
# Duo Admin: Users > Select User > Bypass Codes
# Generate temporary bypass code

# ISE policy modification
# ISE: Policy > Authorization Policy
# Add temporary bypass rule for affected users

# AnyConnect fallback
# Configure legacy VPN profile as backup
# Users can select fallback connection profile
```

# Operational Handover

This section covers the transition to ongoing operations.

## Monitoring Dashboard Access

### SecureX Dashboard

```
# Access SecureX
URL: https://securex.cisco.com
Login: Use organization SSO

# Key dashboards:
# - Overview: Unified security summary
# - Incidents: Active security incidents
# - Threat Intelligence: Talos threat data
# - Automation: Orchestration workflows
```

### Platform Dashboards

```
# Duo Admin Portal
URL: https://admin.duosecurity.com
Purpose: User management, authentication reports

# Umbrella Dashboard
URL: https://dashboard.umbrella.com
Purpose: DNS policy, threat reports

# ISE Admin Portal
URL: https://ise-pan-01.client.local/admin
Purpose: NAC policy, session monitoring
```

### Key Metrics to Monitor

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Auth Failure Rate | > 5% | Warning | Investigate users |
| Threat Blocks | Any malware | Info | Review and document |
| ISE Session Failures | > 10/hour | Warning | Check PSN health |
| Duo Push Timeout | > 5% | Warning | User communication |
| Posture Non-Compliance | > 10% | Warning | Remediation campaign |

## Support Transition

### Support Model

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Password reset, enrollment | Help Desk | 15 minutes |
| L2 | Policy issues, troubleshooting | Security Team | 1 hour |
| L3 | Platform issues | Cisco TAC | 4 hours |
| SOC | Threat response, incidents | Security Operations | Immediate |

### Escalation Contacts

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Security Lead | [NAME] | [EMAIL] | [PHONE] |
| Project Manager | [NAME] | [EMAIL] | [PHONE] |
| Cisco TAC | N/A | support@cisco.com | 1-800-553-2447 |

# Training Program

This section documents the training program for the security solution.

## Training Overview

Training ensures all user groups achieve competency with the zero trust security platform.

### Training Schedule

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | Security Administrator | Security Team | 8 | Hands-On | None |
| TRN-002 | SOC Analyst Training | SOC Team | 8 | Hands-On | TRN-001 |
| TRN-003 | Help Desk Training | Help Desk | 8 | Hands-On | None |
| TRN-004 | End User Awareness | All Users | 4 | Online | None |
| TRN-005 | ISE Administration | Network Team | 4 | Hands-On | TRN-001 |

**Total Training Hours:** 32 hours per SOW

## Training Materials

The following training materials are provided.

- Duo Administrator Quick Start Guide
- Umbrella Policy Configuration Guide
- ISE Network Access Control Guide
- SecureX Orchestration Guide
- End User MFA Enrollment Guide
- Troubleshooting Runbook

# Appendices

## Appendix A: Environment Reference

### Production Environment

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Duo Tenant | api-xxxxxxxx.duosecurity.com | Duo API hostname |
| Umbrella Org | [org-id] | Umbrella organization ID |
| ISE Primary | ise-pan-01.client.local | ISE admin node |
| VPN Headend | vpn.client.local | AnyConnect endpoint |
| SecureX | securex.cisco.com | Security dashboard |

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Duo push not received | Network/app issue | Check mobile connectivity, reinstall app |
| ISE auth failure | RADIUS misconfiguration | Verify shared secret, check logs |
| Umbrella not blocking | DNS not forwarded | Check DNS configuration |
| SSO loop | Certificate issue | Verify SAML certificate validity |
| VPN connection fails | Profile mismatch | Reinstall AnyConnect profile |

### Diagnostic Commands

```bash
# Duo Authentication Proxy
/opt/duoauthproxy/bin/authproxyctl status
tail -f /opt/duoauthproxy/log/authproxy.log

# ISE RADIUS troubleshooting
# ISE GUI: Operations > Troubleshoot > Diagnostic Tools
# Run: RADIUS Authentication Test

# Umbrella DNS test
nslookup -type=txt debug.opendns.com
```

## Appendix C: Reference Documentation

### Cisco Documentation

- Cisco Duo Administration Guide
- Cisco Umbrella Deployment Guide
- Cisco ISE Administrator Guide
- Cisco AnyConnect Administrator Guide
- Cisco SecureX User Guide

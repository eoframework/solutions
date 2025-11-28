---
document_title: Implementation Guide
solution_name: Google Workspace Migration
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: google
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

## Project Overview

This Implementation Guide provides step-by-step procedures for deploying Google Workspace Business Plus and migrating 500 users from on-premises Exchange 2016. The guide covers all phases from initial tenant configuration through Azure AD SSO integration, security policy deployment, wave-based migration, and operational handover.

## Scope

The implementation delivers a complete Google Workspace environment:

- Google Workspace Business Plus tenant for 500 users across 5 departments
- Azure AD SAML SSO integration with 2-Step Verification enforcement
- Google Cloud Directory Sync (GCDS) for automated user provisioning
- Security baseline with DLP policies, Google Vault retention, and MDM
- Wave-based email migration (2.5 TB) and file migration (3 TB)
- End-user and administrator training programs

## Timeline

The implementation spans 12 weeks with 2 weeks of hypercare support:

- **Phase 1 (Weeks 1-2)**: Planning - Assessment, wave planning, communication
- **Phase 2 (Weeks 3-4)**: Setup - Tenant configuration, SSO, security policies
- **Phase 3 (Weeks 5-6)**: Pilot - 25 pilot users, validation, training refinement
- **Phase 4 (Weeks 7-10)**: Migration - 5 waves of 95 users each
- **Phase 5 (Weeks 11-12)**: Closure - MX cutover, documentation, training
- **Hypercare (Weeks 13-14)**: Support and optimization

# Prerequisites

## Technical Requirements

The following technical prerequisites must be met before implementation begins:

### Google Workspace Access

- Google Workspace Business Plus licenses procured (500 users)
- Domain ownership verification capability (DNS access)
- Super Admin credentials for Google Admin Console
- Billing account configured with payment method

### Source Environment Access

- Exchange 2016 Server administrative credentials
- Active Directory domain admin credentials
- File server read permissions for migration source
- Network access to Google services (ports 443, 587)

### Identity Requirements

- Azure AD tenant with SAML SSO capability
- Service account for Google Cloud Directory Sync (GCDS)
- Administrator list with email addresses for pilot
- Security group structure documentation for role mapping

## Organizational Requirements

The following organizational prerequisites ensure successful delivery:

### Stakeholder Availability

- Executive sponsor for escalations and go/no-go decisions
- IT lead as primary technical contact
- Security lead for policy approval
- Department managers for wave scheduling and communication
- Change champions in each department (5 total)

### Documentation Required

- Current Exchange environment inventory
- File server share structure and permissions
- Distribution list membership export
- Security and compliance requirements documentation

## Environmental Requirements

The following environment setup is required:

### Administrative Workstations

- Chrome browser (latest version) for Admin Console access
- Network connectivity to Google services verified
- GCDS installation server with AD connectivity
- Access to DNS management console

### Service Accounts

- GWMT service account with Exchange impersonation rights
- GCDS service account with AD read permissions
- Google Admin service account for API access

# Environment Setup

## Google Workspace Tenant Configuration

### Step 1: Domain Verification

1. Access Google Admin Console at admin.google.com
2. Navigate to **Account** > **Domains** > **Manage domains**
3. Add primary domain: `[domain.com]`
4. Select DNS verification method (TXT record recommended)
5. Add TXT record to DNS:
   ```
   google-site-verification=[verification-code]
   ```
6. Wait for DNS propagation (up to 48 hours)
7. Click **Verify** in Admin Console

### Step 2: Organization Structure Setup

1. Navigate to **Directory** > **Organizational units**
2. Create the following OU structure:
   ```
   /Sales (95 users)
   /Marketing (95 users)
   /Operations (95 users)
   /Finance (95 users)
   /Executive (95 users)
   ```
3. Document OU path for GCDS mapping configuration

### Step 3: License Assignment

1. Navigate to **Billing** > **Subscriptions**
2. Verify 500 Business Plus licenses available
3. Configure automatic license assignment:
   - Navigate to **Account** > **License settings**
   - Enable automatic licensing for new users
4. Document license count for ongoing management

# Infrastructure Deployment

## Networking

### DNS Configuration

Prepare DNS records for post-migration cutover. Do not apply MX changes until Wave 5 completion:

The following DNS records will be configured at MX cutover:

| Record Type | Host | Value | TTL | Purpose |
|-------------|------|-------|-----|---------|
| MX | @ | aspmx.l.google.com (priority 1) | 3600 | Primary mail |
| MX | @ | alt1.aspmx.l.google.com (priority 5) | 3600 | Secondary mail |
| MX | @ | alt2.aspmx.l.google.com (priority 5) | 3600 | Tertiary mail |
| TXT | @ | v=spf1 include:_spf.google.com ~all | 3600 | SPF |
| TXT | google._domainkey | [DKIM public key from Admin Console] | 3600 | DKIM |
| TXT | _dmarc | v=DMARC1; p=quarantine; rua=mailto:dmarc@[domain] | 3600 | DMARC |

### Firewall Requirements

Ensure outbound access to the following Google services:

```
Required Access:
- Destination: *.google.com, *.googleapis.com, *.gstatic.com
- Ports: 443 (HTTPS), 587 (SMTP TLS)
- Protocol: TCP

Optional (Meet video optimization):
- Destination: meet.google.com
- Ports: 19302-19309
- Protocol: UDP
```

## Security

### Azure AD SAML SSO Configuration

**Step 1: Create Enterprise Application in Azure AD**

1. Navigate to Azure Portal > Azure Active Directory
2. Select **Enterprise applications** > **New application**
3. Search for "Google Workspace" and select it
4. Configure application name: "Google Workspace SSO"
5. Assign users and groups for SSO access

**Step 2: Configure SAML Settings**

1. Navigate to **Single sign-on** > **SAML**
2. Configure Basic SAML Configuration:
   ```
   Identifier (Entity ID): google.com
   Reply URL: https://www.google.com/a/[domain.com]/acs
   Sign on URL: https://www.google.com/a/[domain.com]/ServiceLogin
   ```
3. Download Federation Metadata XML
4. Copy the following values for Google configuration:
   - Login URL
   - Azure AD Identifier
   - Logout URL
   - Certificate (Base64)

**Step 3: Configure Google Workspace SSO**

1. In Google Admin Console, navigate to **Security** > **Authentication** > **SSO with third party IdP**
2. Check "Set up SSO with third party identity provider"
3. Configure the following:
   - Sign-in page URL: [Azure AD Login URL]
   - Sign-out page URL: https://login.microsoftonline.com/common/wsfederation?wa=wsignout1.0
   - Upload verification certificate from Azure AD
4. Save configuration
5. Test with pilot user account

### 2-Step Verification Enforcement

1. Navigate to **Security** > **2-Step Verification**
2. Configure enforcement settings:
   ```
   Enforcement: ON
   New user enrollment period: 7 days
   Allowed methods: Any
   Frequency: New sign-in only
   ```
3. Apply to all organizational units
4. Communicate 2SV requirement to users before enforcement

### Google Cloud Directory Sync Setup

**Step 1: Install GCDS**

1. Download GCDS from Google Admin support site
2. Install on Windows Server with Active Directory connectivity
3. Launch Configuration Manager
4. Authenticate with Google Admin credentials

**Step 2: Configure GCDS Connection**

Configure LDAP and Google connections:

```xml
LDAP Connection:
- Server: ldap://[domain-controller-fqdn]
- Authentication: Simple
- User: [service-account]@[domain.com]
- Base DN: DC=[domain],DC=com

Google Connection:
- Domain: [domain.com]
- Admin Email: [admin]@[domain.com]
```

**Step 3: Configure User Sync Rules**

1. Define user search base: `OU=Users,DC=[domain],DC=com`
2. Configure attribute mapping:
   ```
   AD sAMAccountName → Google primaryEmail (append @domain.com)
   AD givenName → Google givenName
   AD sn → Google familyName
   AD department → Google orgUnitPath (use mapping table)
   ```
3. Set sync interval: 4 hours
4. Enable password sync if required

**Step 4: Configure Group Sync**

1. Define group search base: `OU=Distribution Groups,DC=[domain],DC=com`
2. Map distribution lists to Google Groups
3. Configure membership synchronization
4. Run test sync and validate

## Compute

### Shared Drives Configuration

Create 15 Shared Drives for team collaboration:

| Shared Drive Name | Purpose | Initial Members |
|-------------------|---------|-----------------|
| Sales-Team | Sales documents and resources | Sales OU |
| Marketing-Team | Marketing assets and campaigns | Marketing OU |
| Operations-Team | Operations procedures and docs | Operations OU |
| Finance-Team | Financial documents (restricted) | Finance OU |
| Executive-Team | Executive communications | Executive OU |
| All-Company | Company-wide resources | All users |
| HR-Documents | HR policies and forms | HR team |
| IT-Resources | IT documentation and tools | IT team |
| Project-Alpha | Cross-functional project | Project members |
| Project-Beta | Cross-functional project | Project members |
| Training-Materials | Training and onboarding | All users (viewer) |
| Templates | Document templates | All users |
| Archive-2024 | Historical documents | Managers |
| Legal-Hold | Legal matter documents | Legal team |
| Vendor-Collaboration | External vendor sharing | Designated users |

### External Sharing Configuration

1. Navigate to **Apps** > **Google Workspace** > **Drive and Docs** > **Sharing settings**
2. Configure sharing options:
   ```
   Sharing outside of [domain.com]: Allowlisted domains only
   Allowlisted domains: [Add partner domains as required]
   Warning when sharing outside: Enabled
   Access checker: Enabled
   ```

## Monitoring

### Admin Alert Configuration

Navigate to **Security** > **Alert center** > **Manage rules** and configure the following alerts:

| Alert Name | Trigger | Recipients |
|------------|---------|------------|
| Suspicious Login | Login from new device or location | security-team@[domain.com] |
| DLP Policy Violation | Sensitive data detected | security-team@[domain.com] |
| User Suspended | Account suspended | it-admin@[domain.com] |
| Mobile Device Compromised | Compromised device detected | security-team@[domain.com] |
| Delegated Admin Activity | Admin role changed | it-management@[domain.com] |

### Audit Log Configuration

1. Navigate to **Reporting** > **Audit and investigation**
2. Enable BigQuery export for long-term analysis (optional)
3. Configure scheduled reports:
   - Daily: Login activity summary
   - Weekly: DLP violation report
   - Monthly: License utilization report

# Application Configuration

## Gmail Configuration

### Routing and Delivery

1. Navigate to **Apps** > **Google Workspace** > **Gmail** > **Routing**
2. Configure default routing for inbound mail
3. Set up compliance footer if required:
   ```
   Footer text: [Company confidentiality statement]
   Apply to: Outbound external email
   ```
4. Configure attachment compliance settings per security policy

### Spam and Phishing Protection

1. Navigate to **Apps** > **Google Workspace** > **Gmail** > **Safety**
2. Enable enhanced pre-delivery message scanning
3. Configure phishing protection:
   ```
   Protect against domain spoofing: Enabled
   Protect against employee name spoofing: Enabled
   Protect against inbound emails spoofing: Enabled
   ```

## Google Meet Configuration

1. Navigate to **Apps** > **Google Workspace** > **Google Meet**
2. Configure meeting settings:
   ```
   Video calling: Enabled for all OUs
   Recording: Enabled (stored in organizer's Drive)
   Live streaming: Disabled
   Attendance reports: Enabled
   ```

## Data Loss Prevention Configuration

### Create DLP Rules

1. Navigate to **Security** > **Data protection** > **Manage rules**
2. Create the following rules:

**Rule 1: PII Detection**
```
Name: Block PII External Sharing
Condition: Content matches PII detectors (SSN, Driver License)
Action: Block external sharing, Warn user, Alert admin
Scope: Gmail, Drive
```

**Rule 2: Financial Data Protection**
```
Name: Protect Financial Data
Condition: Content matches financial detectors (Credit Card, Bank Account)
Action: Block external sharing, Alert admin
Scope: All applications
```

**Rule 3: Custom Keywords**
```
Name: Confidential Document Detection
Condition: Content contains "CONFIDENTIAL" or "INTERNAL ONLY"
Action: Warn on external sharing
Scope: Drive
```

## Google Vault Configuration

### Retention Rules

1. Navigate to **Apps** > **Google Workspace** > **Google Vault** > **Retention**
2. Create default retention rules:

| Rule Name | Service | Duration | Scope |
|-----------|---------|----------|-------|
| Gmail 7-Year | Gmail | 2555 days | All users |
| Drive 7-Year | Drive | 2555 days | All users |
| Meet 7-Year | Meet | 2555 days | All users |

### Legal Hold Procedures

Document the legal hold creation process for compliance:

1. Receive legal hold request from Legal department
2. Create matter in Vault with descriptive name
3. Apply hold to specified custodians
4. Generate preservation confirmation report
5. Document matter details in legal hold register

## Mobile Device Management Configuration

1. Navigate to **Devices** > **Mobile & endpoints** > **Settings**
2. Configure universal settings:
   ```
   Mobile management: Advanced
   Require screen lock: Yes (6+ characters)
   Require encryption: Yes
   Allow camera: Yes
   Remote wipe: Enabled
   ```
3. Configure iOS-specific settings
4. Configure Android-specific settings
5. Enable device inventory tracking
6. Configure compliance actions for non-compliant devices

# Integration Testing

## SSO Authentication Testing

Validate Azure AD SSO integration with the following test cases:

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| TC-SSO-01 | Access mail.google.com, enter corporate email | Redirect to Azure AD login page |
| TC-SSO-02 | Complete Azure AD authentication with valid credentials | Redirect to Gmail inbox successfully |
| TC-SSO-03 | Click sign out from Gmail | Session terminated, redirect to IdP logout page |
| TC-SSO-04 | Attempt login with invalid credentials | Azure AD displays authentication error |
| TC-SSO-05 | Test session timeout after inactivity | Re-authentication required after configured period |

## Directory Sync Testing

Validate GCDS synchronization with the following test cases:

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| TC-GCDS-01 | Create user in AD, wait for sync cycle | User appears in Google Admin Console |
| TC-GCDS-02 | Modify user department attribute in AD | User moved to correct OU in Google |
| TC-GCDS-03 | Disable user in AD, wait for sync | User suspended in Google Workspace |
| TC-GCDS-04 | Add user to distribution list in AD | User added to corresponding Google Group |
| TC-GCDS-05 | Delete user from AD, wait for sync | User account handled per deletion policy |

## DLP Policy Testing

Validate DLP policies detect and respond to sensitive data:

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| TC-DLP-01 | Create document with SSN pattern, attempt external share | Warning displayed, share blocked |
| TC-DLP-02 | Compose email with credit card number to external recipient | Email blocked, admin alerted |
| TC-DLP-03 | Share sensitive document internally | Action allowed (internal sharing permitted) |
| TC-DLP-04 | Upload file with CONFIDENTIAL keyword | Warning triggered on external share attempt |

# Security Validation

## Security Control Verification

### Authentication Controls

Verify the following authentication controls are operational:

- [ ] SSO authentication working for all OUs
- [ ] 2-Step Verification enforced for all users
- [ ] Session timeout configured correctly (14 days max)
- [ ] Password policy enforced via Azure AD
- [ ] Failed login attempts logged and alerted

### Data Protection Controls

Verify the following data protection controls:

- [ ] DLP policies detecting test patterns correctly
- [ ] External sharing restricted to allowlisted domains
- [ ] Vault retention rules active and verified
- [ ] Legal hold capability tested
- [ ] Audit logs capturing required events

### Device Security Controls

Verify MDM controls are functioning:

- [ ] MDM enrollment working on iOS devices
- [ ] MDM enrollment working on Android devices
- [ ] Remote wipe capability verified on test device
- [ ] Non-compliant device access blocked
- [ ] Device inventory accurate in Admin Console

## Compliance Verification

Document evidence of compliance controls:

| Requirement | Evidence | Status |
|-------------|----------|--------|
| 7-year email retention | Vault retention rule screenshot | Pending |
| PII protection | DLP policy configuration export | Pending |
| Access logging | Sample audit log report | Pending |
| Device encryption | MDM policy configuration | Pending |

# Migration & Cutover

## Pre-Migration Checklist

Complete before starting pilot migration:

- [ ] GWMT service account configured with Exchange impersonation
- [ ] Network connectivity to Exchange 2016 verified from migration server
- [ ] Bandwidth allocation confirmed (500 Mbps recommended for migration)
- [ ] User communication sent (T-7 days before pilot)
- [ ] Support team briefed on escalation procedures
- [ ] Rollback plan documented and approved by stakeholders

## Pilot Migration (25 Users)

### Pilot User Selection Criteria

Select pilot users meeting the following criteria:

- Mix of departments (5 per department)
- Include power users and typical users
- Include mobile device users (iOS and Android)
- Willing to provide detailed feedback
- Availability for training and testing sessions

### Pilot Execution Steps

**Day 1: Mailbox Migration**
1. Configure GWMT for pilot batch
2. Start migration for 25 pilot mailboxes
3. Monitor migration progress in GWMT console
4. Validate mail, calendar, and contacts migration

**Day 2: File Migration**
1. Migrate pilot user personal files to My Drive
2. Migrate pilot shared files to appropriate Shared Drive
3. Verify permissions preserved
4. Test file access from web and desktop

**Day 3-5: Training and Validation**
1. Conduct pilot training session
2. Distribute quick reference guides
3. Collect user feedback daily
4. Document issues for resolution

**Day 5-8: Optimization**
1. Resolve pilot issues
2. Update training materials based on feedback
3. Refine migration procedures
4. Obtain pilot sign-off

## Wave Migration Schedule

Execute wave migrations according to the following schedule:

| Wave | Department | Users | Start | End | Training |
|------|------------|-------|-------|-----|----------|
| Pilot | Mixed | 25 | Week 5 Day 1 | Week 5 Day 3 | Week 5 Day 3-5 |
| Wave 1 | Sales | 95 | Week 6 Day 1 | Week 6 Day 5 | Week 6 Day 4-5 |
| Wave 2 | Marketing | 95 | Week 7 Day 1 | Week 7 Day 5 | Week 7 Day 4-5 |
| Wave 3 | Operations | 95 | Week 8 Day 1 | Week 8 Day 5 | Week 8 Day 4-5 |
| Wave 4 | Finance | 95 | Week 9 Day 1 | Week 9 Day 5 | Week 9 Day 4-5 |
| Wave 5 | Executive | 95 | Week 10 Day 1 | Week 10 Day 5 | Week 10 Day 4-5 |

## MX Record Cutover

### Cutover Preparation (Week 10 Day 4)

1. Verify all 500 mailboxes migrated successfully
2. Confirm delta sync completed (final mail capture from Exchange)
3. Prepare DNS change request with IT operations
4. Brief support team for cutover day procedures
5. Send final user communication about cutover timing

### Cutover Execution (Week 10 Day 5)

**Morning (before business hours)**:
1. Disable mail flow to Exchange
2. Update MX records to Google (priority 1: aspmx.l.google.com)
3. Update SPF record to include Google
4. Enable DKIM signing in Admin Console
5. Update DMARC policy

**Business Hours**:
1. Monitor email flow in Admin Console
2. Track support tickets for email issues
3. Verify external email delivery with test messages
4. Test internal email routing between users

**Post-Cutover Monitoring**:
1. Monitor for bounce-backs (check Admin Console reports)
2. Address any routing issues immediately
3. Confirm DNS propagation complete (24-48 hours)
4. Document cutover completion with timestamps

## Rollback Procedures

### Trigger Conditions for Rollback

- Greater than 10% of users unable to access email for >4 hours
- Critical business process failure affecting operations
- Data integrity issues discovered during validation

### Rollback Steps

If rollback is required, execute the following:

1. Revert MX records to Exchange (priority 1)
2. Disable mail forwarding rules from Exchange
3. Communicate rollback to all users via alternate channel
4. Document issues encountered for root cause analysis
5. Schedule remediation activities and re-migration planning

# Training Program

## Administrator Training

### Training Schedule

Administrator training is delivered in Week 11:

| Topic | Duration | Attendees |
|-------|----------|-----------|
| Admin Console Navigation | 2 hours | IT Admins |
| User Management (CRUD operations) | 2 hours | IT Admins |
| Group and OU Management | 1 hour | IT Admins |
| Security Policies and DLP | 2 hours | IT Admins, Security |
| Reporting and Audit Logs | 1 hour | IT Admins |
| Troubleshooting Common Issues | 2 hours | IT Admins, Helpdesk |
| Vault Administration | 2 hours | IT Admins, Legal |
| MDM Administration | 1 hour | IT Admins |

### Administrator Certification

Administrators should complete Google Workspace Administrator Fundamentals certification within 60 days of go-live.

## End-User Training

### Training Delivery Model

End-user training is delivered per wave:

- **Live Sessions**: 2-hour instructor-led training per wave
- **Self-Paced**: Google Workspace Learning Center modules
- **Reference Materials**: Quick start guides and tip sheets
- **Change Champions**: 5 department representatives for peer support

### Training Content

Training covers the following topics:

1. Gmail basics: compose, organize, search
2. Google Drive: upload, share, organize
3. Google Docs/Sheets/Slides: create, collaborate, comment
4. Google Meet: join, schedule, record
5. Google Calendar: schedule, share, room booking
6. Mobile access: Gmail and Drive apps

## Change Champion Program

### Change Champion Responsibilities

- Attend advanced training session
- Provide first-line support within department
- Escalate complex issues to IT helpdesk
- Gather and relay user feedback
- Promote adoption of Google Workspace features

### Change Champion Training

Additional training topics for change champions:

- Advanced collaboration features
- Tips and shortcuts for power users
- Common issues and resolutions
- Escalation procedures

# Operational Handover

## Support Runbook

### Common Issues and Resolutions

Document common issues and resolution procedures:

| Issue | Resolution |
|-------|------------|
| User cannot sign in | 1. Verify user not suspended in Admin Console 2. Check Azure AD sign-in logs 3. Verify 2SV enrollment status 4. Test SSO bypass if needed |
| 2SV enrollment issues | 1. Admin generates backup codes in Admin Console 2. Temporarily disable 2SV for user if needed 3. Guide user through enrollment |
| Email not delivered | 1. Check spam and trash folders 2. Verify sender not blocked 3. Review DLP logs for policy blocks 4. Check routing in Admin Console |
| Drive sync issues | 1. Restart Drive File Stream application 2. Verify network connectivity to Google 3. Clear Drive cache 4. Re-sign in to Drive |
| Mobile device not syncing | 1. Verify MDM enrollment in Devices 2. Check device compliance status 3. Re-enroll device if needed 4. Verify network access |

### Escalation Matrix

| Level | Response Time | Contact | Scope |
|-------|---------------|---------|-------|
| L1 - Helpdesk | <15 minutes | helpdesk@[domain.com] | Password resets, basic troubleshooting |
| L2 - IT Admin | <1 hour | it-admin@[domain.com] | Configuration changes, complex issues |
| L3 - Google Support | <4 hours | Google Workspace Support Portal | Platform issues, escalations |

## Documentation Deliverables

The following documentation is delivered at project closure:

| Document | Description | Location |
|----------|-------------|----------|
| Admin Guide | Day-to-day administration procedures | SharePoint/IT |
| User Quick Start | End-user getting started guide | Intranet/Help |
| Security Policies | Security configuration documentation | SharePoint/Security |
| Disaster Recovery | DR procedures and contacts | SharePoint/IT |
| Troubleshooting Guide | Common issues and resolutions | ServiceNow KB |
| Configuration Export | Admin Console settings backup | SharePoint/IT |

## Hypercare Support (Weeks 13-14)

### Daily Activities

During hypercare period:

- **9:30 AM**: Daily standup with support team
- Review overnight tickets and escalations
- Monitor service health dashboard
- Proactive user outreach to identified struggling users
- Issue resolution and documentation
- Daily status email to project stakeholders

### Success Criteria for Hypercare Exit

Exit hypercare when the following criteria are met:

- [ ] Ticket volume below 10 per day for 3 consecutive days
- [ ] No P1 or P2 issues open
- [ ] IT team demonstrating self-sufficiency on L1/L2 issues
- [ ] All documentation complete and accepted by client
- [ ] User satisfaction survey shows >80% positive response
- [ ] Change champions active and supporting users

# Appendices

## Appendix A: Configuration Checklist

### Pre-Migration Checklist

- [ ] Domain verified in Google Admin Console
- [ ] 5 organizational units created
- [ ] Azure AD SAML SSO configured and tested
- [ ] GCDS installed and initial sync verified
- [ ] 2-Step Verification policy configured
- [ ] DLP policies created and tested
- [ ] Vault 7-year retention rules active
- [ ] MDM policies configured
- [ ] 15 Shared Drives created with permissions
- [ ] Admin alerts configured

### Post-Migration Checklist

- [ ] All 500 mailboxes migrated with validation
- [ ] All 150 distribution lists converted to Groups
- [ ] 3 TB files migrated with permissions
- [ ] MX records updated to Google
- [ ] SPF, DKIM, DMARC configured
- [ ] All training delivered (>95% attendance)
- [ ] Admin documentation accepted
- [ ] Hypercare support period complete

## Appendix B: Rollback Procedures

### Detailed Rollback Steps

If rollback is required during migration:

1. **Immediate Actions (0-30 minutes)**
   - Notify project sponsor of rollback decision
   - Send user communication via alternate channel (SMS/phone tree)
   - Stop any in-progress migrations

2. **DNS Reversion (30-60 minutes)**
   - Revert MX records to Exchange (lower TTL in advance)
   - Update SPF record to remove Google
   - Disable DKIM signing

3. **Exchange Restoration (1-4 hours)**
   - Re-enable mail flow on Exchange
   - Verify mail delivery to Exchange mailboxes
   - Disable forwarding rules to Gmail

4. **Communication (Ongoing)**
   - Update users on rollback status
   - Document issues encountered
   - Schedule post-mortem review

---

**Document Version**: 1.0
**Last Updated**: [DATE]
**Review Status**: Approved by Implementation Team

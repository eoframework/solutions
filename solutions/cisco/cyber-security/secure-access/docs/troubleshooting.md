# Troubleshooting Guide - Cisco Secure Access Solution

## Document Information

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Document Owner**: Cisco Security Solutions Team  
**Review Schedule**: Quarterly  
**Classification**: Internal Use

## Table of Contents

1. [Overview](#overview)
2. [General Troubleshooting Methodology](#general-troubleshooting-methodology)
3. [ISE Authentication Issues](#ise-authentication-issues)
4. [Network Access Control Problems](#network-access-control-problems)
5. [Guest Portal Issues](#guest-portal-issues)
6. [Certificate and PKI Issues](#certificate-and-pki-issues)
7. [BYOD and Device Registration](#byod-and-device-registration)
8. [VPN and Remote Access Issues](#vpn-and-remote-access-issues)
9. [Policy Enforcement Problems](#policy-enforcement-problems)
10. [Performance and Scalability Issues](#performance-and-scalability-issues)
11. [Integration Issues](#integration-issues)
12. [System and Infrastructure Problems](#system-and-infrastructure-problems)
13. [Log Analysis and Monitoring](#log-analysis-and-monitoring)
14. [Emergency Procedures](#emergency-procedures)
15. [Escalation Guidelines](#escalation-guidelines)

## Overview

This troubleshooting guide provides comprehensive solutions for common issues encountered in Cisco Secure Access implementations. It covers authentication problems, policy enforcement issues, integration challenges, and performance optimization.

### When to Use This Guide
- Authentication failures or intermittent access issues
- Policy enforcement not working as expected
- Guest portal or BYOD enrollment problems
- Integration issues with third-party systems
- Performance degradation or scalability concerns
- System maintenance and health issues

### Troubleshooting Philosophy
1. **Systematic approach**: Follow logical troubleshooting steps
2. **Data collection**: Gather relevant logs and diagnostic information
3. **Root cause analysis**: Identify underlying causes, not just symptoms
4. **Documentation**: Record findings and solutions for future reference
5. **Prevention**: Implement monitoring to prevent recurring issues

## General Troubleshooting Methodology

### The STRIDE Approach
```
S - Symptoms: What is the user experiencing?
T - Timeline: When did the issue start? Is it intermittent?
R - Reproduce: Can the issue be consistently reproduced?
I - Isolate: Narrow down to specific components or conditions
D - Diagnose: Analyze logs and data to find root cause
E - Execute: Implement solution and verify resolution
```

### Essential Diagnostic Commands

#### ISE CLI Commands
```bash
# System status and health
show application status ise
show system cpu
show system memory
show system disk
show process

# Authentication and session information
show authentication sessions
show logging application prrt-server.log tail
show logging application ise-psc.log tail
show logging application guest.log tail

# Network and connectivity
show interface summary
show ip route
show ntp status
show clock detail

# Database and replication
show ads
show replication status
show repository
```

#### Network Device Commands
```bash
# Cisco Switch Troubleshooting
show authentication sessions
show dot1x all
show authentication registrations
show mab
show radius statistics
show aaa servers radius
show ip access-lists

# Wireless Controller Commands (9800)
show wireless client summary
show wireless client mac-address <mac>
show wireless client summary r0
show wlan summary
show radius summary

# ASA/FTD VPN Troubleshooting
show vpn-sessiondb summary
show vpn-sessiondb detail anyconnect
show crypto ca certificates
show ssl errors
show aaa-server <server-tag> host
```

### Log File Locations and Analysis

#### ISE Log Files
```yaml
Authentication_Logs:
  Location: /opt/CSCOcpm/logs/
  Primary_Files:
    - ise-psc.log (Policy Service Node)
    - prrt-server.log (RADIUS transactions)
    - ad_agent.log (Active Directory integration)
    - guest.log (Guest portal activities)
    - profiler.log (Device profiling)

Administration_Logs:
  Location: /opt/CSCOcpm/logs/
  Primary_Files:
    - iseadmin.log (Administrative operations)
    - replication.log (Node replication)
    - backup-restore.log (Backup operations)
    - system.log (System events)

Performance_Logs:
  Location: /opt/CSCOcpm/logs/
  Primary_Files:
    - performancemon.log (Performance monitoring)
    - jvm.log (Java Virtual Machine)
    - database.log (Database operations)
```

## ISE Authentication Issues

### Common Authentication Failures

#### Issue: Users Cannot Authenticate (802.1X)

**Symptoms**:
- Authentication timeouts
- Continuous re-authentication attempts  
- Users placed in guest or quarantine VLAN
- "Access denied" messages

**Troubleshooting Steps**:

1. **Verify User Account Status**
```bash
# Check user in Active Directory
ldapsearch -x -H ldap://dc.company.com -D "username@company.com" \
  -W -b "dc=company,dc=com" "(sAMAccountName=username)"

# Verify account is not locked or disabled
net user username /domain
```

2. **Check ISE Authentication Policies**
```sql
-- ISE SQL query to check authentication policy
SELECT * FROM LiveAuthenticationLog 
WHERE UserName='username' 
ORDER BY Timestamp DESC LIMIT 10;
```

3. **Analyze RADIUS Communication**
```bash
# On ISE CLI - Monitor RADIUS messages
debug radius all
debug authentication all

# Check RADIUS server statistics
show radius statistics

# Verify shared secret configuration
show radius server-private <switch-ip>
```

4. **Network Device Configuration Verification**
```bash
# Verify 802.1X configuration on switch
show dot1x interface gi1/0/1 details
show authentication sessions interface gi1/0/1

# Check AAA configuration
show aaa servers radius
show radius server-group ISE
```

**Common Root Causes and Solutions**:

| Root Cause | Solution | Prevention |
|------------|----------|------------|
| Incorrect RADIUS shared secret | Update shared secret on device and ISE | Use configuration management |
| Certificate trust issues | Install root CA certificate on client | Automated certificate deployment |
| User account locked/disabled | Unlock account, verify AD connectivity | Account monitoring and alerting |
| Switch port configuration | Verify 802.1X configuration | Configuration templates |
| Time synchronization | Synchronize NTP on all devices | NTP monitoring |

#### Issue: Certificate Authentication Failures

**Symptoms**:
- Certificate validation errors
- "Certificate not found" messages
- EAP-TLS authentication timeouts

**Diagnostic Steps**:

1. **Certificate Chain Validation**
```bash
# Verify certificate chain on ISE
openssl verify -CAfile ca-bundle.crt client-cert.crt

# Check certificate expiration
openssl x509 -in certificate.crt -noout -dates

# Validate certificate against CRL
openssl crl -in crl.pem -noout -text | grep -A2 "Serial Number"
```

2. **Client Certificate Analysis**
```powershell
# Windows - Check client certificate store
certlm.msc  # Local machine certificates
certmgr.msc # User certificates

# PowerShell - List certificates
Get-ChildItem -Path Cert:\LocalMachine\My
Get-ChildItem -Path Cert:\CurrentUser\My
```

3. **ISE Certificate Configuration**
```bash
# ISE CLI - Check certificate configuration
show crypto ca certificates
show crypto ca trustpoints

# Verify certificate services
show application status ise
```

**Resolution Steps**:
```yaml
Certificate_Issues:
  Expired_Certificate:
    Solution: Renew certificate through CA
    Commands: |
      # Generate new certificate request
      crypto ca enroll <trustpoint-name>
      
  Wrong_Certificate_Template:
    Solution: Use correct template for authentication
    Validation: Check EKU includes Client Authentication
    
  Missing_Root_CA:
    Solution: Install root CA certificate
    Location: ISE Admin Portal > Certificates > Certificate Management
    
  Certificate_Revocation:
    Solution: Check CRL/OCSP status
    Commands: |
      # Enable CRL checking
      crypto ca crl request <trustpoint-name>
```

### RADIUS Server Communication Issues

#### Issue: RADIUS Server Not Responding

**Symptoms**:
- RADIUS timeout messages in switch logs
- Authentication falling back to local accounts
- No RADIUS accounting records in ISE

**Diagnostic Commands**:
```bash
# Network connectivity test
ping <ise-server-ip>
telnet <ise-server-ip> 1812  # RADIUS auth port
telnet <ise-server-ip> 1813  # RADIUS accounting port

# RADIUS server testing from switch
test aaa group radius username <testuser> password <password> legacy

# ISE RADIUS service status
show application status ise
show process network radius
```

**Resolution Matrix**:
```yaml
RADIUS_Issues:
  Network_Connectivity:
    Tests:
      - ping: Basic connectivity
      - traceroute: Path analysis  
      - telnet: Port accessibility
    Solutions:
      - Check firewall rules
      - Verify routing tables
      - Confirm ISE service status
      
  Shared_Secret_Mismatch:
    Symptoms: "Bad authenticator" in logs
    Validation: Compare secrets on NAD and ISE
    Solution: Update shared secret consistently
    
  ISE_Service_Down:
    Check: show application status ise
    Resolution: application start ise
    Prevention: Service monitoring and alerting
    
  Port_Configuration:
    Standard_Ports:
      - Authentication: 1812
      - Accounting: 1813
    Custom_Ports: Configure consistently on ISE and NAD
```

### Active Directory Integration Issues

#### Issue: AD Authentication Failures

**Symptoms**:
- Users exist in AD but cannot authenticate
- "User not found" errors in ISE logs
- AD join status shows "Not Connected"

**Troubleshooting Steps**:

1. **AD Connectivity Verification**
```bash
# ISE CLI - Test AD connectivity
test ads <domain> <username> <password>

# Check AD join status
show ads domain <domain-name>

# Verify AD operational attributes
show ads operationalstate
```

2. **LDAP Query Testing**
```bash
# Test LDAP search from ISE
ldapsearch -x -H ldap://<dc-ip> -D "<service-account@domain>" \
  -W -b "<base-dn>" "(sAMAccountName=<username>)"

# Verify group membership
ldapsearch -x -H ldap://<dc-ip> -D "<service-account@domain>" \
  -W -b "<base-dn>" "(&(objectClass=group)(cn=<groupname>))"
```

3. **Service Account Validation**
```powershell
# Windows - Test service account
runas /user:domain\service-account "cmd.exe"

# Verify account permissions
dsacls "CN=Users,DC=domain,DC=com" | findstr service-account
```

**Common AD Issues and Solutions**:
```yaml
AD_Integration_Problems:
  Time_Synchronization:
    Issue: Kerberos authentication fails
    Solution: Synchronize time between ISE and DC
    Commands: |
      # ISE CLI
      ntp server <ntp-server-ip>
      show ntp status
      
  Service_Account_Issues:
    Locked_Account:
      Check: net user service-account /domain
      Solution: Unlock account, verify password
      
    Insufficient_Permissions:
      Required: Read all user information
      Solution: Add to Domain Users, delegate permissions
      
  DNS_Resolution:
    Issue: Cannot resolve domain controllers
    Test: nslookup <domain-controller-fqdn>
    Solution: Configure correct DNS servers
    
  Firewall_Blocking:
    Required_Ports:
      - 53 (DNS)
      - 88 (Kerberos)
      - 135 (RPC Endpoint Mapper)
      - 389 (LDAP)
      - 636 (LDAPS)
      - 3268 (Global Catalog)
    Solution: Allow required ports through firewall
```

## Network Access Control Problems

### Switch Configuration Issues

#### Issue: 802.1X Authentication Not Working

**Common Switch Misconfigurations**:

1. **Missing Global 802.1X Configuration**
```bash
# Required global configuration
dot1x system-auth-control
aaa new-model
aaa authentication dot1x default group radius
aaa authorization network default group radius
aaa accounting dot1x default start-stop group radius

# Verify current configuration
show dot1x
show aaa methods
```

2. **Incorrect Interface Configuration**
```bash
# Proper interface configuration
interface GigabitEthernet1/0/1
 switchport mode access
 switchport access vlan 200
 dot1x port-control auto
 dot1x host-mode multi-auth
 dot1x timeout quiet-period 10
 dot1x timeout tx-period 10
 authentication periodic
 authentication timer reauthenticate 3600

# Common mistakes to check
show dot1x interface gi1/0/1 details
show authentication sessions interface gi1/0/1
```

3. **RADIUS Server Configuration Issues**
```bash
# Proper RADIUS configuration
radius server ISE-1
 address ipv4 192.168.1.100 auth-port 1812 acct-port 1813
 key 7 <encrypted-shared-secret>
 
radius server ISE-2
 address ipv4 192.168.1.101 auth-port 1812 acct-port 1813  
 key 7 <encrypted-shared-secret>
 
aaa group server radius ISE
 server name ISE-1
 server name ISE-2
 deadtime 10
 
# Verify configuration
show radius server-group all
show aaa servers radius
```

#### Issue: MAC Authentication Bypass (MAB) Problems

**Symptoms**:
- Devices not authenticating via MAB
- Unknown devices not being profiled
- Incorrect VLAN assignment for MAB devices

**Troubleshooting Steps**:

1. **MAB Configuration Verification**
```bash
# Interface MAB configuration
interface range gi1/0/1-48
 mab
 dot1x port-control auto
 authentication port-control auto
 authentication host-mode multi-auth
 authentication order dot1x mab
 authentication priority dot1x mab
 authentication fallback dot1x

# Verify MAB status
show mab interface gi1/0/1
show authentication sessions
```

2. **Device Profiling Analysis**
```bash
# Check device profiling in ISE
# Navigate to Context Visibility > Endpoints
# Look for unknown endpoints and profiling status

# CLI verification
show endpoint mac <mac-address>
show profiling status
```

**MAB Troubleshooting Matrix**:
```yaml
MAB_Issues:
  Device_Not_Profiling:
    Cause: Insufficient profiling probes
    Solution: Enable additional probes (DHCP, DNS, HTTP)
    Validation: Check profiling policies match
    
  Wrong_VLAN_Assignment:
    Cause: Authorization policy mismatch
    Solution: Review authorization policies
    Debug: Check policy evaluation logs
    
  MAC_Address_Format:
    Issue: Format inconsistency (xx:xx vs xx-xx)
    Solution: Normalize MAC address format
    Configuration: Set consistent format in ISE
```

### Wireless Authentication Issues

#### Issue: WiFi Authentication Failures

**Common Wireless Problems**:

1. **SSID Configuration Issues**
```bash
# 9800 WLC - SSID configuration verification
show wlan summary
show wlan name <ssid-name>

# Common configuration
wlan <ssid-name> <id> <ssid-name>
 client vlan <vlan-id>
 security wpa psk set-key ascii 0 <password>
 security wpa akm dot1x
 security dot1x authentication-list <auth-list>
 no shutdown
```

2. **RADIUS Configuration on WLC**
```bash
# RADIUS server configuration
radius server <server-name>
 address ipv4 <ise-ip-address>
 key 0 <shared-secret>
 authentication-port 1812
 accounting-port 1813

# Apply to authentication list  
aaa authentication dot1x <auth-list> group radius
aaa accounting network <acct-list> start-stop group radius
```

3. **Certificate Issues on Wireless**
```bash
# Check certificates on WLC
show crypto pki certificates

# Client certificate validation
show wireless client mac-address <client-mac> detail
show wireless client summary r0
```

**Wireless Troubleshooting Commands**:
```bash
# Client connection analysis
debug dot11 mgmt interface
debug client <mac-address>
show wireless client mac-address <mac> detail

# RADIUS debugging
debug radius all
debug aaa authentication
debug aaa authorization
```

### Policy Enforcement Issues

#### Issue: Incorrect VLAN Assignment

**Symptoms**:
- Users getting wrong VLAN assignment
- Policy not applied as expected
- Authorized users placed in quarantine VLAN

**Policy Troubleshooting Steps**:

1. **ISE Policy Analysis**
```sql
-- Check authentication results
SELECT UserName, AuthenticationPolicy, AuthorizationPolicy, 
       NetworkDeviceName, AuthenticationResult, Time
FROM LiveAuthenticationLog 
WHERE UserName='<username>' 
ORDER BY Time DESC LIMIT 5;
```

2. **Authorization Policy Validation**
```yaml
Policy_Conditions_Check:
  User_Identity_Groups:
    Location: Administration > Identity Management > Groups
    Validation: Verify user membership in correct groups
    
  Device_Profiling:
    Location: Context Visibility > Endpoints  
    Check: Device correctly profiled and categorized
    
  Network_Device_Groups:
    Location: Administration > Network Resources > Network Devices
    Validation: Device in correct location/device type group
    
  Time_Date_Conditions:
    Check: Current time falls within policy time window
    Validation: Time zone settings correct
```

3. **Policy Evaluation Testing**
```bash
# ISE Policy simulation
# Administration > System > Tools > Policy Evaluation Tool

# Input parameters:
- Username: target username
- Device MAC: device MAC address  
- Network Device: switch/AP IP
- Protocol: 802.1X, MAB, etc.
```

**Policy Resolution Steps**:
```yaml
Authorization_Problems:
  Policy_Order:
    Issue: Policies evaluated top-to-bottom
    Solution: Reorder policies by specificity
    Best_Practice: Most specific conditions first
    
  Condition_Logic:
    Issue: AND/OR logic in conditions
    Solution: Review condition combinations
    Testing: Use policy simulation tool
    
  Default_Policy:
    Issue: Fallback to default deny/permit
    Solution: Create catch-all policy at bottom
    Monitoring: Alert on default policy hits
```

## Guest Portal Issues

### Guest Registration Problems

#### Issue: Guest Portal Not Loading

**Symptoms**:
- Portal page doesn't load
- HTTP redirect not working
- Certificate errors in browser

**Diagnostic Steps**:

1. **Portal Service Status**
```bash
# ISE CLI - Check guest service
show application status ise
show process network guest

# Portal configuration verification
show guest-access
show portal configuration
```

2. **Network Configuration**
```bash
# Verify guest VLAN and ACL
show vlan id <guest-vlan>
show ip access-list GUEST_REDIRECT

# Common guest ACL  
ip access-list extended GUEST_REDIRECT
 permit udp any host <dns-server> eq domain
 permit tcp any host <portal-ip> eq 8443
 permit tcp any host <portal-ip> eq 8080
 deny ip any any
```

3. **Certificate and HTTPS Issues**
```bash
# Check portal certificates
show crypto ca certificates
openssl s_client -connect <portal-ip>:8443

# Browser certificate validation
# Check for self-signed certificate warnings
# Verify certificate subject matches portal FQDN
```

**Guest Portal Troubleshooting Matrix**:
```yaml
Portal_Issues:
  HTTP_to_HTTPS_Redirect:
    Problem: Portal not redirecting properly
    Solution: Configure redirect ACL on switch
    ACL_Example: |
      ip access-list extended GUEST_REDIRECT
      permit tcp any host <portal-ip> eq 80
      permit tcp any host <portal-ip> eq 8443
      
  Certificate_Errors:
    Self_Signed_Certificate:
      Issue: Browser security warnings
      Solution: Install CA-signed certificate
      Process: Generate CSR, get signed, install
      
    Subject_Name_Mismatch:
      Issue: Certificate CN doesn't match URL
      Solution: Use SAN certificate or correct FQDN
      
  Portal_Customization:
    CSS_JavaScript_Errors:
      Issue: Custom portal code errors
      Solution: Validate custom code
      Debugging: Browser developer tools
      
  Database_Connectivity:
    Sponsor_Approval_Issues:
      Issue: Cannot process sponsor requests
      Solution: Check database connectivity
      Validation: Test sponsor account login
```

### BYOD Registration Issues

#### Issue: Device Enrollment Failures

**Symptoms**:
- Certificate installation fails
- Native supplicant provisioning errors
- Profile download failures

**BYOD Troubleshooting Steps**:

1. **Client Provisioning Analysis**
```yaml
BYOD_Flow_Validation:
  Initial_Authentication:
    Method: User credentials (username/password)
    VLAN: Provisioning VLAN with limited access
    Validation: Check initial authentication logs
    
  Portal_Access:
    URL: https://portal-ip:8443/portal
    Certificate: Must be trusted by client
    Validation: Manual portal access test
    
  Agent_Download:
    Platform: Windows, macOS, iOS, Android
    Requirements: App store access or direct download
    Validation: Check download logs and success rate
    
  Certificate_Installation:
    Method: SCEP, manual, or agent-assisted
    Trust: Root CA must be trusted
    Validation: Check client certificate store
```

2. **Platform-Specific Issues**

**iOS BYOD Problems**:
```yaml
iOS_Issues:
  Profile_Installation:
    Error: "Cannot install profile"
    Cause: iOS restrictions or MDM conflicts
    Solution: Check device restrictions, remove conflicting profiles
    
  Certificate_Trust:
    Error: "Untrusted certificate"
    Solution: Install root CA certificate first
    Process: Settings > General > About > Certificate Trust Settings
    
  WiFi_Profile:
    Error: "Cannot connect to WiFi"
    Solution: Verify WiFi profile configuration
    Validation: Check SSID, security type, certificate
```

**Android BYOD Problems**:
```yaml
Android_Issues:
  Certificate_Installation:
    Error: "Certificate not installed"
    Cause: Android security restrictions
    Solution: Manual certificate installation
    Process: Settings > Security > Install certificates
    
  App_Installation:
    Error: Cannot install ISE agent
    Solution: Enable "Unknown sources" temporarily
    Security: Disable after installation
```

**Windows BYOD Problems**:
```yaml
Windows_Issues:
  Native_Supplicant:
    Error: "Cannot create WiFi profile"
    Cause: Group Policy restrictions
    Solution: Modify GP or use manual configuration
    
  Certificate_Store:
    Error: "Certificate not in correct store"
    Solution: Install in Computer or User store as required
    Validation: certlm.msc or certmgr.msc
```

## Certificate and PKI Issues

### Certificate Authority Problems

#### Issue: Certificate Enrollment Failures

**Symptoms**:
- SCEP enrollment timeouts
- Certificate requests pending indefinitely
- Invalid certificate templates

**Certificate Troubleshooting Steps**:

1. **CA Service Validation**
```bash
# Windows CA - Check service status
services.msc  # Look for Certificate Services
Get-Service -Name CertSvc

# Event logs
eventvwr.msc  # Application and Services Logs > Microsoft > Windows > CertificationAuthority
```

2. **Certificate Template Analysis**
```powershell
# List available templates
certutil -template

# Check template permissions
# Certificate Templates console (certtmpl.msc)
# Verify "Enroll" permissions for users/computers
```

3. **SCEP Configuration Verification**
```bash
# Test SCEP enrollment
# Browse to: http://ca-server/certsrv/mscep/mscep.dll

# ISE SCEP configuration
show crypto ca trustpoint
show crypto ca certificate
```

**Certificate Issues Resolution**:
```yaml
PKI_Problems:
  Template_Issues:
    Missing_Template:
      Cause: Template not published or permissions incorrect
      Solution: Publish template, verify permissions
      Validation: Check CA template list
      
    Wrong_Template_Configuration:
      Issue: EKU or key usage incorrect
      Solution: Modify template for correct usage
      Example: Add "Client Authentication" EKU
      
  SCEP_Enrollment:
    Network_Connectivity:
      Test: HTTP/HTTPS access to SCEP URL
      Solution: Check firewall, proxy settings
      
    Authentication_Failure:
      Cause: Challenge password incorrect
      Solution: Verify SCEP challenge password
      
  Certificate_Validation:
    Chain_Building:
      Issue: Cannot build certificate chain
      Solution: Install intermediate CA certificates
      Validation: openssl verify -CAfile bundle.crt cert.crt
      
    Revocation_Checking:
      Issue: CRL or OCSP not accessible
      Solution: Configure CRL distribution points
      Alternative: Disable revocation checking (not recommended)
```

### Certificate Lifecycle Issues

#### Issue: Certificate Expiration

**Prevention and Response**:

1. **Certificate Monitoring Setup**
```bash
# ISE certificate expiration monitoring
# Administration > System > Certificates > Certificate Management
# Set up alerts for certificates expiring in 60, 30, 7 days

# CLI monitoring
show crypto ca certificates | include Valid
```

2. **Automated Renewal Process**
```yaml
Certificate_Renewal:
  Automated_Renewal:
    Method: SCEP auto-renewal
    Configuration: Set renewal threshold to 80% of validity
    Validation: Monitor renewal success/failure
    
  Manual_Renewal:
    Process:
      1. Generate new certificate request
      2. Submit to CA for signing  
      3. Install new certificate
      4. Update certificate bindings
      5. Restart services if required
      
  Emergency_Procedures:
    Expired_Certificate:
      Impact: Service unavailable, authentication failures
      Solution: Emergency certificate installation
      Rollback: Keep previous certificate as backup
```

## VPN and Remote Access Issues

### AnyConnect VPN Problems

#### Issue: VPN Connection Failures

**Common VPN Issues**:

1. **Authentication Problems**
```bash
# ASA debugging
debug webvpn anyconnect
debug crypto ca
debug aaa authentication

# Check user authentication
show vpn-sessiondb detail anyconnect filter name <username>
```

2. **Certificate Issues**
```bash
# ASA certificate verification
show crypto ca certificates
show ssl errors

# Client certificate validation
show vpn-sessiondb detail anyconnect filter name <username>
```

3. **Network Connectivity**
```bash
# Basic connectivity tests
ping <asa-outside-interface>
telnet <asa-ip> 443

# ASA interface status
show interface
show route
```

**VPN Troubleshooting Matrix**:
```yaml
VPN_Issues:
  Authentication_Failures:
    LDAP_Integration:
      Issue: Cannot authenticate against AD
      Solution: Check LDAP configuration
      Commands: |
        show aaa-server <server-tag> host <host-ip>
        test aaa-server authentication <server-tag> host <host-ip> username <user> password <pass>
        
    Certificate_Authentication:
      Issue: Certificate not recognized
      Solution: Verify certificate chain and CRL
      Validation: Check certificate subject and EKU
      
  Connection_Problems:
    License_Exhaustion:
      Issue: No available SSL VPN licenses
      Check: show version | include SSL
      Solution: Purchase additional licenses or disconnect idle sessions
      
    MTU_Issues:
      Symptom: Connection established but no data flow
      Solution: Adjust MTU size
      Configuration: |
        webvpn
         anyconnect mtu 1200
         
  Performance_Issues:
    Bandwidth_Limitations:
      Issue: Slow VPN performance
      Solution: Configure bandwidth policies
      QoS: Implement traffic shaping
      
    DNS_Resolution:
      Issue: Cannot resolve internal names
      Solution: Configure split DNS
      Configuration: Split tunneling and DNS settings
```

### Remote Access Policy Issues

#### Issue: Incorrect VPN Policy Application

**Policy Troubleshooting**:

1. **Group Policy Analysis**
```bash
# ASA group policy verification
show vpn-sessiondb detail anyconnect filter name <username>
show group-policy <policy-name>

# User attribute verification  
show username <username> attributes
```

2. **Dynamic Access Policy (DAP)**
```bash
# DAP evaluation
show dynamic-access-policy-record <dap-name>
show vpn-sessiondb dap

# DAP debugging
debug dap trace
debug dap errors
```

**Policy Resolution Steps**:
```yaml
VPN_Policy_Issues:
  Group_Policy_Assignment:
    Problem: Wrong group policy applied
    Cause: User not in correct AD group
    Solution: Verify AD group membership and ISE mapping
    
  Split_Tunneling:
    Issue: All traffic through VPN or no access to internal
    Configuration: Verify split tunnel ACL
    Example: |
      access-list SPLIT_TUNNEL permit ip 10.0.0.0 255.0.0.0
      group-policy VPN_USERS attributes
       split-tunnel-policy tunnelspecified
       split-tunnel-network-list value SPLIT_TUNNEL
       
  Address_Pool_Exhaustion:
    Issue: Cannot assign IP address to client
    Solution: Expand IP pool or clean up stale sessions
    Commands: |
      show vpn-sessiondb summary
      vpn-sessiondb logoff name <username>
```

## Performance and Scalability Issues

### ISE Performance Problems

#### Issue: Slow Authentication Response

**Performance Analysis Steps**:

1. **System Resource Monitoring**
```bash
# ISE CLI - Resource utilization
show system cpu
show system memory  
show system disk
show application status ise

# Process monitoring
top
show process cpu

# Database performance
show database status
show replication status
```

2. **Authentication Metrics**
```sql
-- SQL query for authentication performance
SELECT AVG(ResponseTime), COUNT(*) as Total,
       NetworkDeviceName, AuthenticationProtocol
FROM LiveAuthenticationLog 
WHERE Time > DATEADD(hour, -1, GETDATE())
GROUP BY NetworkDeviceName, AuthenticationProtocol
ORDER BY AVG(ResponseTime) DESC;
```

3. **Network Latency Analysis**
```bash
# Network latency testing
ping <network-device-ip>
traceroute <network-device-ip>

# RADIUS response time monitoring
show radius statistics
show authentication summary
```

**Performance Optimization**:
```yaml
Performance_Tuning:
  Hardware_Resources:
    CPU_Usage:
      Threshold: > 80% sustained
      Solution: Add CPU cores or additional PSN
      Monitoring: Set CPU usage alerts
      
    Memory_Usage:
      Threshold: > 85% usage
      Solution: Add RAM or optimize JVM heap
      Configuration: Adjust ISE JVM settings
      
    Disk_I/O:
      Issue: High database I/O wait
      Solution: SSD storage, RAID 10 configuration
      Monitoring: Disk queue length and utilization
      
  Database_Optimization:
    Log_Retention:
      Issue: Large log database slowing queries
      Solution: Adjust retention policies
      Configuration: |
        Administration > Maintenance > Log Cleanup
        Set appropriate retention periods
        
    Index_Optimization:
      Issue: Slow database queries
      Solution: Database maintenance tasks
      Schedule: Weekly database optimization
      
  Network_Optimization:
    RADIUS_Timeout:
      Issue: Retransmissions due to timeout
      Solution: Adjust timeout values
      Configuration: Increase on NAD and ISE
      
    Concurrent_Sessions:
      Limit: Monitor concurrent authentication requests
      Solution: Load balancing across multiple PSNs
      Architecture: Deploy distributed PSN nodes
```

### Scalability Planning

#### Issue: Approaching System Limits

**Capacity Monitoring**:

1. **User and Device Scaling**
```bash
# Current endpoint count
show endpoint summary
show authentication sessions count

# License utilization
show license summary
show license usage
```

2. **Performance Baselines**
```yaml
Scalability_Metrics:
  Authentication_Rate:
    Current: Monitor authentications per second
    Baseline: Establish normal load patterns
    Threshold: Set alerts at 80% of maximum capacity
    
  Concurrent_Sessions:
    Current: Track active session count
    Growth: Monitor growth rate over time
    Planning: Project future capacity needs
    
  Database_Growth:
    Log_Volume: Monitor daily log generation
    Storage: Track database size growth
    Retention: Optimize retention policies
```

**Scaling Solutions**:
```yaml
Horizontal_Scaling:
  Additional_PSN_Nodes:
    Deployment: Add PSN nodes for load distribution
    Load_Balancing: Configure NADs to use multiple PSNs
    Geographic: Deploy PSNs closer to user populations
    
  Database_Scaling:
    Dedicated_MnT: Deploy dedicated monitoring nodes
    Log_Separation: Separate logging from policy processing
    External_Storage: Use external log storage systems
    
Vertical_Scaling:
  Hardware_Upgrades:
    CPU: Upgrade to higher core count processors
    Memory: Increase RAM for larger caches
    Storage: Upgrade to faster SSD storage
    Network: Use 10Gbps network interfaces
    
  Configuration_Optimization:
    JVM_Tuning: Optimize Java heap settings
    Thread_Pools: Adjust thread pool sizes
    Caching: Enable appropriate caching mechanisms
```

## Integration Issues

### Active Directory Integration Problems

#### Issue: AD Authentication Intermittent

**Advanced AD Troubleshooting**:

1. **Domain Controller Health**
```powershell
# Check DC health
dcdiag /s:<dc-name>
repadmin /showrepl
netdom query fsmo

# AD site and services validation
Get-ADReplicationSite
Get-ADDomainController -Filter *
```

2. **ISE AD Connection Analysis**
```bash
# ISE CLI - AD connection testing  
test ads <domain> <username> <password>
show ads operationalstate
show ads performance <domain>

# AD connector status
show application status ise
show ads status
```

3. **Kerberos Authentication Issues**
```bash
# Time synchronization critical for Kerberos
show clock detail
show ntp status

# Kerberos ticket analysis (Windows)
klist tickets
klist purge  # Clear tickets if needed
```

**AD Integration Solutions**:
```yaml
AD_Problems:
  Multi_Domain_Forest:
    Issue: Cannot authenticate users from trusted domains
    Solution: Configure forest-wide authentication
    Requirements: Global Catalog access
    
  Site_Topology:
    Issue: Slow authentication due to DC distance
    Solution: Configure site-aware AD integration
    Configuration: Specify preferred DCs per ISE node
    
  Service_Account_Delegation:
    Issue: Cannot perform operations on behalf of users
    Solution: Configure constrained delegation
    Security: Use service principal names (SPNs)
    
  Password_Synchronization:
    Issue: Password changes not reflected immediately
    Cause: AD replication delay
    Solution: Configure multiple DCs, check replication
```

### SIEM Integration Issues

#### Issue: Logs Not Appearing in SIEM

**Log Integration Troubleshooting**:

1. **ISE Log Configuration**
```bash
# Verify syslog configuration
show logging
show logging application ise

# Test syslog connectivity
# Administration > System > Logging > Syslog Targets
# Test connection to SIEM server
```

2. **Syslog Format Verification**
```bash
# Sample ISE syslog message format
tail -f /opt/CSCOcpm/logs/ise-psc.log
tail -f /var/log/messages

# Verify message format matches SIEM expectations
# Check CEF, LEEF, or custom format configuration
```

3. **Network Connectivity**
```bash
# Syslog connectivity testing
nc -u <siem-server> 514  # UDP syslog
nc <siem-server> 6514    # TCP syslog with TLS

# Firewall rule verification
show ip access-lists
netstat -an | grep 514
```

**SIEM Integration Resolution**:
```yaml
SIEM_Issues:
  Log_Format_Mismatch:
    Problem: SIEM cannot parse ISE logs
    Solution: Configure correct log format
    Options: CEF, LEEF, JSON, or custom format
    
  Message_Loss:
    Cause: UDP syslog packet loss
    Solution: Use TCP syslog with reliability
    Configuration: Enable TLS for secure transport
    
  Rate_Limiting:
    Issue: Too many logs overwhelming SIEM
    Solution: Configure log filtering and rate limiting
    Balance: Security visibility vs. performance
    
  Time_Zone_Issues:
    Problem: Log timestamps incorrect in SIEM
    Solution: Standardize on UTC timestamps
    Configuration: Set consistent time zones
```

### Cloud Service Integration

#### Issue: Umbrella/Cloud Connector Problems

**Cloud Integration Troubleshooting**:

1. **Umbrella Connector Validation**
```bash
# Umbrella virtual appliance status
show system status
show network interface

# DNS forwarding verification
nslookup <test-domain> <umbrella-ip>
dig @<umbrella-ip> <test-domain>
```

2. **API Integration Issues**
```python
# Python script to test Umbrella API
import requests

api_key = "your-api-key"
api_secret = "your-api-secret"
base_url = "https://api.umbrella.com"

# Test API connectivity
response = requests.get(f"{base_url}/deployments/v2/deployments", 
                       auth=(api_key, api_secret))
print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")
```

**Cloud Integration Solutions**:
```yaml
Cloud_Integration:
  API_Authentication:
    Issue: API calls failing with 401/403 errors
    Solution: Verify API credentials and permissions
    Validation: Test API calls manually
    
  Rate_Limiting:
    Problem: API calls being throttled
    Solution: Implement exponential backoff
    Monitoring: Track API usage and limits
    
  Network_Connectivity:
    Issue: Cannot reach cloud services
    Solution: Check proxy, firewall, DNS resolution
    Requirements: HTTPS outbound access
    
  Data_Synchronization:
    Problem: User/device data out of sync
    Solution: Implement regular sync jobs
    Validation: Compare data consistency
```

## System and Infrastructure Problems

### ISE Node Issues

#### Issue: ISE Node Down/Unreachable

**Node Troubleshooting Steps**:

1. **Basic Connectivity**
```bash
# Network connectivity
ping <ise-node-ip>
ssh admin@<ise-node-ip>

# Service status check
show application status ise
show version
```

2. **Cluster Status Validation**
```bash
# ISE cluster health
show cluster status
show replication status
show database status

# Node roles and services
show application server
show cluster node-status
```

3. **Log Analysis**
```bash
# System logs
show logging application system.log tail 50
show logging application iseadmin.log tail 50
show logging application replication.log tail 50

# Critical error detection
grep -i "error\|failed\|exception" /opt/CSCOcpm/logs/*.log
```

**Node Recovery Procedures**:
```yaml
Node_Recovery:
  Service_Restart:
    Command: application stop ise && application start ise
    Duration: 10-15 minutes for full startup
    Validation: show application status ise
    
  Database_Corruption:
    Symptoms: Replication failures, service crashes
    Recovery: Restore from backup or re-sync
    Process: |
      1. Stop ISE services
      2. Clear database
      3. Restore from backup or rejoin cluster
      4. Start services and validate
      
  Hardware_Failure:
    Symptoms: System crashes, hardware alerts
    Recovery: Replace hardware or restore VM
    High_Availability: Failover to secondary node
    
  Configuration_Corruption:
    Symptoms: Services won't start, configuration errors
    Recovery: Restore configuration backup
    Process: |
      1. Boot from rescue mode if necessary
      2. Restore configuration from backup
      3. Restart services
      4. Validate functionality
```

### Infrastructure Problems

#### Issue: Network Infrastructure Failures

**Infrastructure Troubleshooting**:

1. **Network Device Failures**
```bash
# Switch/AP status verification
show system status
show interface status
show log

# ISE network device status
show network-devices
show authentication sessions device <device-ip>
```

2. **DNS/NTP Issues**
```bash
# DNS resolution testing
nslookup <ise-fqdn>
dig <domain-controller-fqdn>

# NTP synchronization
show ntp status
ntpq -p
```

3. **Certificate Authority Issues**
```bash
# CA connectivity
telnet <ca-server> 80   # HTTP CRL
telnet <ca-server> 443  # HTTPS/SCEP

# Certificate validation
openssl verify -CAfile ca-bundle.crt server-cert.crt
curl -I http://ca-server/certsrv/
```

**Infrastructure Recovery**:
```yaml
Infrastructure_Recovery:
  Network_Device_Failure:
    Impact: Authentication failures in affected areas
    Response: |
      1. Identify failed device and scope of impact
      2. Activate redundant paths if available
      3. Replace/repair failed device
      4. Restore configuration and test authentication
      
  DNS_Server_Failure:
    Impact: Name resolution failures, service disruption
    Response: |
      1. Switch to secondary DNS servers
      2. Update DNS configuration if needed
      3. Clear DNS caches
      4. Validate name resolution
      
  Time_Synchronization_Loss:
    Impact: Kerberos failures, certificate validation issues
    Response: |
      1. Identify NTP server issues
      2. Configure alternate NTP sources
      3. Force time synchronization
      4. Monitor for time drift
      
  Certificate_Authority_Outage:
    Impact: Certificate enrollment/validation failures
    Response: |
      1. Identify CA service issues
      2. Restart certificate services
      3. Update CRL distribution if needed
      4. Test certificate operations
```

## Log Analysis and Monitoring

### Log Interpretation Guide

#### Authentication Log Analysis

**ISE Authentication Log Fields**:
```yaml
Key_Log_Fields:
  Timestamp: Event occurrence time
  UserName: Authenticated username
  CallingStationID: Client MAC address  
  CalledStationID: Network device MAC/identifier
  NAS-IP-Address: Network device IP address
  Radius-Username: RADIUS username attribute
  AuthenticationPolicy: Applied authentication policy
  AuthorizationPolicy: Applied authorization policy
  AuthenticationResult: Success/Failure result
  FailureReason: Specific failure reason
  ResponseTime: Authentication response time
```

**Common Log Patterns**:

1. **Successful Authentication**
```
2024-01-15T10:30:15Z ISE-NODE1 INFO Authentication succeeded for user john.doe from device 00:1A:2B:3C:4D:5E via switch 192.168.1.10
AuthenticationPolicy: Dot1X_Authentication  
AuthorizationPolicy: Employee_Access
VLAN: 200 (Employee_Data)
```

2. **Failed Authentication**
```
2024-01-15T10:30:15Z ISE-NODE1 ERROR Authentication failed for user john.doe from device 00:1A:2B:3C:4D:5E
FailureReason: 11009 User credentials are invalid
AuthenticationPolicy: Dot1X_Authentication
```

3. **Device Profiling**
```  
2024-01-15T10:30:15Z ISE-NODE1 INFO Device profiled: 00:1A:2B:3C:4D:5E
DeviceType: Windows-Workstation
Profiler: DHCP, HTTP-User-Agent
Certainty: 90
```

### Automated Log Analysis

#### Log Parsing Scripts

**Python Log Analysis Script**:
```python
#!/usr/bin/env python3
import re
import sys
from collections import Counter
from datetime import datetime, timedelta

def parse_ise_logs(logfile):
    """Parse ISE authentication logs and extract key metrics"""
    
    patterns = {
        'auth_success': r'Authentication succeeded.*user (\S+)',
        'auth_failure': r'Authentication failed.*user (\S+).*FailureReason: (\d+)',
        'device_profiling': r'Device profiled: (\S+).*DeviceType: (\S+)',
        'response_time': r'ResponseTime: (\d+)ms'
    }
    
    metrics = {
        'total_auth': 0,
        'successful_auth': 0,
        'failed_auth': 0,
        'failure_reasons': Counter(),
        'users': set(),
        'devices': Counter(),
        'response_times': []
    }
    
    with open(logfile, 'r') as f:
        for line in f:
            metrics['total_auth'] += 1
            
            # Parse successful authentications
            if re.search(patterns['auth_success'], line):
                metrics['successful_auth'] += 1
                user = re.search(patterns['auth_success'], line).group(1)
                metrics['users'].add(user)
            
            # Parse failed authentications  
            elif re.search(patterns['auth_failure'], line):
                metrics['failed_auth'] += 1
                match = re.search(patterns['auth_failure'], line)
                user = match.group(1)
                failure_code = match.group(2)
                metrics['users'].add(user)
                metrics['failure_reasons'][failure_code] += 1
            
            # Parse response times
            if re.search(patterns['response_time'], line):
                response_time = int(re.search(patterns['response_time'], line).group(1))
                metrics['response_times'].append(response_time)
    
    return metrics

def generate_report(metrics):
    """Generate summary report from log metrics"""
    
    print("=== ISE Authentication Log Analysis ===\n")
    
    print(f"Total Authentication Attempts: {metrics['total_auth']}")
    print(f"Successful Authentications: {metrics['successful_auth']}")
    print(f"Failed Authentications: {metrics['failed_auth']}")
    
    if metrics['total_auth'] > 0:
        success_rate = (metrics['successful_auth'] / metrics['total_auth']) * 100
        print(f"Success Rate: {success_rate:.2f}%\n")
    
    print(f"Unique Users: {len(metrics['users'])}")
    
    if metrics['failure_reasons']:
        print("\nTop Failure Reasons:")
        for code, count in metrics['failure_reasons'].most_common(5):
            print(f"  {code}: {count} occurrences")
    
    if metrics['response_times']:
        avg_response = sum(metrics['response_times']) / len(metrics['response_times'])
        max_response = max(metrics['response_times'])
        print(f"\nAverage Response Time: {avg_response:.2f}ms")
        print(f"Maximum Response Time: {max_response}ms")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 ise_log_analyzer.py <logfile>")
        sys.exit(1)
    
    logfile = sys.argv[1]
    metrics = parse_ise_logs(logfile)
    generate_report(metrics)
```

#### Automated Alerting

**Bash Monitoring Script**:
```bash
#!/bin/bash
# ISE Health Monitoring Script

ISE_HOST="ise-primary.company.com"
LOG_FILE="/var/log/ise-monitoring.log" 
ALERT_EMAIL="admin@company.com"
THRESHOLD_FAILURE_RATE=10  # Alert if failure rate > 10%

# Function to send alert
send_alert() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
    echo "$(date): ALERT - $subject" >> "$LOG_FILE"
}

# Check ISE service status
check_ise_status() {
    local status=$(ssh admin@$ISE_HOST "show application status ise" | grep -c "running")
    if [ "$status" -eq 0 ]; then
        send_alert "ISE Service Down" "ISE application is not running on $ISE_HOST"
        return 1
    fi
    return 0
}

# Check authentication failure rate
check_failure_rate() {
    local total_auth=$(grep -c "Authentication" /tmp/recent-auth.log)
    local failed_auth=$(grep -c "Authentication failed" /tmp/recent-auth.log)
    
    if [ "$total_auth" -gt 0 ]; then
        local failure_rate=$((failed_auth * 100 / total_auth))
        if [ "$failure_rate" -gt "$THRESHOLD_FAILURE_RATE" ]; then
            send_alert "High Authentication Failure Rate" \
                "Failure rate is ${failure_rate}% (${failed_auth}/${total_auth})"
        fi
    fi
}

# Check system resources
check_resources() {
    local cpu_usage=$(ssh admin@$ISE_HOST "show system cpu" | awk '/CPU Usage/ {print $3}' | sed 's/%//')
    local memory_usage=$(ssh admin@$ISE_HOST "show system memory" | awk '/Memory Usage/ {print $3}' | sed 's/%//')
    
    if [ "$cpu_usage" -gt 80 ]; then
        send_alert "High CPU Usage" "CPU usage is ${cpu_usage}% on $ISE_HOST"
    fi
    
    if [ "$memory_usage" -gt 85 ]; then
        send_alert "High Memory Usage" "Memory usage is ${memory_usage}% on $ISE_HOST"
    fi
}

# Main monitoring loop
echo "$(date): Starting ISE monitoring" >> "$LOG_FILE"

check_ise_status
check_failure_rate  
check_resources

echo "$(date): Monitoring check completed" >> "$LOG_FILE"
```

### Performance Monitoring

#### Key Performance Indicators (KPIs)

```yaml
ISE_Performance_Metrics:
  Authentication_Metrics:
    Success_Rate:
      Target: "> 99%"
      Alert_Threshold: "< 95%"
      Calculation: (Successful / Total) * 100
      
    Response_Time:
      Target: "< 3 seconds average"
      Alert_Threshold: "> 5 seconds"
      Measurement: End-to-end authentication time
      
    Throughput:
      Target: "1000+ auth/sec during peak"
      Alert_Threshold: "< 500 auth/sec"
      Measurement: Authentications per second
      
  System_Metrics:
    CPU_Usage:
      Target: "< 70% average"
      Alert_Threshold: "> 80%"
      Measurement: Overall CPU utilization
      
    Memory_Usage:
      Target: "< 80% average"  
      Alert_Threshold: "> 85%"
      Measurement: RAM utilization
      
    Disk_Usage:
      Target: "< 80% full"
      Alert_Threshold: "> 85%"
      Measurement: Storage utilization
      
  Network_Metrics:
    RADIUS_Latency:
      Target: "< 100ms"
      Alert_Threshold: "> 200ms"
      Measurement: RADIUS request/response time
      
    Packet_Loss:
      Target: "< 0.1%"
      Alert_Threshold: "> 1%"
      Measurement: Network packet loss rate
```

## Emergency Procedures

### Critical System Failures

#### ISE Complete Outage

**Emergency Response Steps**:

1. **Immediate Assessment**
```bash
# Quick status check
ping <ise-primary-ip>
ping <ise-secondary-ip>
ssh admin@<ise-ip> "show application status ise"
```

2. **Failover to Secondary**
```yaml
Manual_Failover:
  Prerequisites:
    - Secondary ISE node operational
    - Database replication current
    - Network devices configured with secondary RADIUS
    
  Steps:
    1. Verify secondary node status
    2. Update DNS to point to secondary
    3. Update load balancer configuration
    4. Notify network devices of primary failure
    5. Monitor authentication success rate
    
  Rollback_Plan:
    - Keep primary node configuration backup
    - Document all changes made during failover
    - Plan restoration when primary is restored
```

3. **Local Authentication Fallback**
```bash
# Enable local authentication on network devices
# Switch configuration
aaa authentication dot1x default group radius local
aaa authentication mab default group radius local

# Create emergency local accounts
username emergency privilege 15 password emergency123
```

#### Network Device Failures

**Emergency Network Response**:

1. **Identify Scope of Impact**
```bash
# Check affected devices and users
show authentication sessions
show ip arp | grep <failed-device-subnet>
```

2. **Activate Redundant Paths**
```bash
# Enable backup links
interface <backup-interface>
no shutdown

# Adjust spanning tree priority if needed
spanning-tree vlan <vlan-id> priority <value>
```

3. **Emergency Access Procedures**
```yaml
Emergency_Access:
  Guest_VLAN_Expansion:
    - Temporarily allow guest VLAN full access
    - Monitor and log all emergency access
    - Plan immediate security review
    
  Bypass_Authentication:
    - Last resort only for critical systems
    - Time-limited bypass (maximum 4 hours)
    - Require management approval
    - Full audit trail required
```

### Security Incident Response

#### Suspected Security Breach

**Incident Response Procedures**:

1. **Immediate Containment**
```bash
# Quarantine suspected devices
# ISE - Move device to quarantine authorization policy
# Or disconnect from network entirely
```

2. **Evidence Collection**
```bash
# Collect relevant logs immediately
tar -czf incident-logs-$(date +%Y%m%d).tar.gz \
  /opt/CSCOcpm/logs/ise-psc.log \
  /opt/CSCOcpm/logs/prrt-server.log \
  /opt/CSCOcpm/logs/guest.log
```

3. **Communication Plan**
```yaml
Incident_Communication:
  Internal_Notifications:
    - Security team (immediate)
    - Network operations (immediate)
    - Management (within 30 minutes)
    - Legal team (if required)
    
  External_Notifications:
    - Regulatory bodies (as required)
    - Law enforcement (if criminal activity)
    - Customers/users (as appropriate)
    
  Documentation:
    - Incident timeline
    - Actions taken
    - Evidence collected
    - Lessons learned
```

### Disaster Recovery Procedures

#### Site-Wide Disaster

**DR Activation Steps**:

1. **Assessment and Declaration**
```yaml
Disaster_Criteria:
  Primary_Site_Unavailable:
    - Physical damage to facility
    - Extended power outage
    - Network connectivity loss
    - Critical system failures
    
  RTO_RPO_Targets:
    - Recovery Time Objective: 4 hours
    - Recovery Point Objective: 1 hour
    - Data loss tolerance: Minimal
```

2. **DR Site Activation**
```bash
# Activate DR site ISE nodes
# Restore from latest backup
application start ise

# Verify database consistency
show database status
show replication status

# Update DNS records to DR site
# Update network device configurations
```

3. **Service Validation**
```bash
# Test authentication flows
# Verify all critical services
show authentication sessions
show application status ise

# Test external integrations
test ads <domain> <user> <password>
```

## Escalation Guidelines

### Internal Escalation

#### Level 1 → Level 2 Escalation
```yaml
L1_to_L2_Criteria:
  Time_Based:
    - Issue not resolved within 2 hours
    - Multiple attempts at standard resolution failed
    
  Complexity_Based:
    - Requires advanced troubleshooting skills
    - Involves multiple system integration
    - Policy or configuration changes needed
    
  Impact_Based:
    - Affects > 100 users
    - Critical business function impacted
    - Security incident suspected
```

#### Level 2 → Level 3 Escalation
```yaml
L2_to_L3_Criteria:
  Technical_Complexity:
    - Root cause not identified after 4 hours
    - Requires vendor support engagement
    - System architecture changes needed
    
  Business_Impact:
    - Service-wide outage
    - Data breach suspected
    - Regulatory compliance issue
```

### External Escalation

#### Cisco TAC Escalation

**When to Engage Cisco TAC**:
```yaml
TAC_Engagement_Criteria:
  Software_Issues:
    - ISE software bugs or unexpected behavior
    - Performance issues beyond configuration
    - Feature functionality problems
    
  Hardware_Issues:
    - ISE appliance hardware failures
    - Performance degradation on appliances
    - Warranty and RMA requests
    
  Integration_Issues:
    - Third-party integration problems
    - API or protocol compatibility issues
    - Documented feature not working as expected
```

**TAC Case Information**:
```yaml
Required_Information:
  System_Details:
    - ISE version and patch level
    - Hardware model and specifications
    - Network topology diagram
    - Configuration backups
    
  Problem_Description:
    - Detailed symptom description
    - Timeline of issue occurrence
    - Steps to reproduce problem
    - Business impact assessment
    
  Diagnostic_Data:
    - Relevant log files
    - Debug outputs
    - Performance statistics
    - Configuration exports
```

#### Vendor Partner Escalation

**Third-Party Vendor Engagement**:
```yaml
Partner_Escalation:
  Microsoft_Active_Directory:
    Scenarios: AD integration issues, authentication problems
    Contact: Microsoft Premier Support
    Information: Domain topology, replication status, error logs
    
  Certificate_Authority:
    Scenarios: PKI issues, certificate enrollment problems  
    Contact: CA vendor support
    Information: CA hierarchy, certificate templates, SCEP logs
    
  Network_Equipment:
    Scenarios: Switch/AP configuration issues
    Contact: Hardware vendor support
    Information: Device configurations, firmware versions, logs
```

---

**Document Maintenance**: This troubleshooting guide should be updated regularly with new issues and solutions discovered during operations.

**Training Requirements**: All support staff should be familiar with the procedures outlined in this guide and receive regular training updates.

**Feedback Process**: Encourage feedback from users and support staff to continuously improve troubleshooting procedures and documentation accuracy.
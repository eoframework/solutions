# Configuration Templates - Cisco Secure Access

## Overview

This document provides comprehensive configuration templates for all Cisco Secure Access components. These templates are production-ready and follow Cisco best practices for zero trust security architecture implementation.

## Template Categories

### 1. Cisco Umbrella Configuration Templates
### 2. Cisco ISE (Identity Services Engine) Templates  
### 3. Cisco AnyConnect Templates
### 4. Cisco Duo Integration Templates
### 5. Network Infrastructure Templates
### 6. Integration Templates

---

## 1. Cisco Umbrella Configuration Templates

### DNS Security Policy Template

```yaml
# Umbrella DNS Security Policy Configuration
dns_security_policy:
  name: "Corporate-DNS-Security-Policy"
  description: "Enterprise DNS security and web filtering policy"
  
  # Content Categories - Block malicious content
  blocked_categories:
    - malware
    - phishing
    - botnet
    - cryptomining
    - newly_seen_domains
    - risky_domains
    - suspicious
    - potentially_harmful
    
  # Custom Block Lists
  custom_blocked_domains:
    - "*.suspicious-domain.com"
    - "*.known-malicious.net"
    
  # Allow Lists for Business Applications
  allowed_domains:
    - "*.salesforce.com"
    - "*.microsoft.com"
    - "*.cisco.com"
    - "*.webex.com"
    
  # Advanced Settings
  settings:
    enable_intelligent_proxy: true
    enable_safe_search: true
    enable_youtube_filtering: true
    block_dynamic_dns: true
    block_parked_domains: true
```

### Firewall Policy Template

```yaml
# Umbrella Cloud-Delivered Firewall Policy
firewall_policy:
  name: "Zero-Trust-Firewall-Policy"
  description: "Zero trust network access firewall rules"
  
  # Default Action
  default_action: "block"
  
  # Application Control Rules
  application_rules:
    - name: "Allow-Business-Applications"
      action: "allow"
      applications:
        - "Microsoft-Office-365"
        - "Salesforce"
        - "WebEx"
        - "Zoom"
      source: "internal_networks"
      
    - name: "Block-High-Risk-Applications"
      action: "block"
      applications:
        - "BitTorrent"
        - "Anonymous-Proxies"
        - "Cryptocurrency-Mining"
      source: "any"
      
  # Network Rules
  network_rules:
    - name: "Allow-HTTPS-Outbound"
      action: "allow"
      protocol: "tcp"
      destination_port: 443
      source: "internal_networks"
      destination: "any"
      
    - name: "Block-Unencrypted-Traffic"
      action: "block"
      protocol: "tcp"
      destination_port: [80, 21, 23]
      source: "any"
      destination: "any"
```

### Secure Web Gateway Configuration

```yaml
# Umbrella Secure Web Gateway Settings
web_gateway:
  name: "Corporate-Web-Gateway"
  
  # SSL Inspection Configuration
  ssl_inspection:
    enabled: true
    certificate_authority: "Corporate-CA"
    inspection_categories:
      - "social_networking"
      - "web_based_email" 
      - "file_sharing"
      - "streaming_media"
    
    # Bypass SSL inspection for sensitive sites
    bypass_domains:
      - "*.bank-website.com"
      - "*.healthcare-portal.com"
      - "*.government-site.gov"
  
  # Data Loss Prevention Integration
  dlp_integration:
    enabled: true
    scan_file_uploads: true
    scan_web_forms: true
    blocked_file_types: [".exe", ".msi", ".bat", ".cmd"]
    max_file_size: "100MB"
  
  # Advanced Threat Protection
  atp_settings:
    enable_file_analysis: true
    enable_url_analysis: true
    sandbox_analysis: true
    threat_intelligence: "cisco_talos"
```

---

## 2. Cisco ISE Configuration Templates

### Network Access Control Policy Template

```yaml
# ISE Network Access Control Policy
nac_policy:
  name: "Zero-Trust-NAC-Policy"
  description: "Zero trust network access control and segmentation"
  
  # Authentication Rules
  authentication_rules:
    - name: "Corporate-Device-Authentication"
      condition: "device_certificate_exists AND device_compliance_status = compliant"
      authentication_method: "certificate"
      result: "allow"
      
    - name: "BYOD-Device-Authentication" 
      condition: "user_authentication = success AND device_registration = complete"
      authentication_method: "eap_tls"
      result: "allow_limited"
      
    - name: "Guest-Authentication"
      condition: "user_type = guest AND sponsor_approval = granted"
      authentication_method: "web_portal"
      result: "allow_guest_network"
  
  # Authorization Rules
  authorization_rules:
    - name: "Executive-Full-Access"
      condition: "user_group = executives AND device_compliance = high"
      permissions: "full_network_access"
      vlan: "executive_vlan"
      
    - name: "Employee-Standard-Access"
      condition: "user_group = employees AND device_compliance = medium"
      permissions: "standard_network_access"
      vlan: "employee_vlan"
      
    - name: "Contractor-Limited-Access"
      condition: "user_group = contractors"
      permissions: "limited_network_access"
      vlan: "contractor_vlan"
      time_restriction: "business_hours"
```

### Device Compliance Policy Template

```yaml
# ISE Device Compliance Policy
device_compliance:
  name: "Corporate-Device-Compliance"
  
  # Windows Compliance Requirements
  windows_requirements:
    operating_system:
      minimum_version: "Windows 10 1909"
      automatic_updates: "enabled"
      
    antivirus:
      required: true
      real_time_protection: "enabled"
      definition_age: "max_7_days"
      
    firewall:
      windows_firewall: "enabled"
      third_party_firewall: "acceptable"
      
    encryption:
      bitlocker: "required"
      tpm_chip: "required"
      
  # macOS Compliance Requirements  
  macos_requirements:
    operating_system:
      minimum_version: "macOS 11.0"
      automatic_updates: "enabled"
      
    security:
      filevault_encryption: "required"
      gatekeeper: "enabled"
      system_integrity_protection: "enabled"
      
    antivirus:
      required: true
      real_time_protection: "enabled"
  
  # Mobile Device Requirements
  mobile_requirements:
    ios_requirements:
      minimum_version: "iOS 14.0"
      passcode_required: true
      device_encryption: "required"
      jailbreak_detection: "block_if_detected"
      
    android_requirements:
      minimum_version: "Android 10"
      screen_lock: "required"
      device_encryption: "required"
      root_detection: "block_if_detected"
```

### Guest Portal Configuration Template

```yaml
# ISE Guest Portal Configuration
guest_portal:
  name: "Corporate-Guest-Portal"
  
  # Portal Settings
  portal_settings:
    portal_name: "Guest Network Access"
    portal_description: "Secure guest network access for visitors"
    language_support: ["English", "Spanish", "French"]
    session_timeout: "8_hours"
    idle_timeout: "1_hour"
    
  # Guest User Settings
  guest_user_settings:
    account_duration: "1_day"
    max_concurrent_sessions: 2
    bandwidth_limit: "10_mbps"
    time_restrictions: "business_hours_only"
    
  # Registration Requirements
  registration_requirements:
    sponsor_approval: "required"
    terms_and_conditions: "required"
    acceptable_use_policy: "required"
    contact_information: "required"
    
  # Sponsor Settings
  sponsor_settings:
    notification_method: "email"
    approval_timeout: "24_hours"
    sponsor_groups: ["hr_team", "reception", "it_team"]
    
  # Network Access
  network_access:
    allowed_protocols: ["HTTP", "HTTPS", "DNS"]
    blocked_categories: ["social_media", "streaming", "file_sharing"]
    download_limit: "500_mb_per_day"
```

---

## 3. Cisco AnyConnect Configuration Templates

### AnyConnect Client Profile Template

```xml
<!-- AnyConnect Client Profile Configuration -->
<AnyConnectProfile xmlns="http://schemas.xmlsoap.org/soap/envelope/">
    <ClientInitialization>
        <UseStartBeforeLogon UserControllable="false">true</UseStartBeforeLogon>
        <AutomaticCertSelection UserControllable="false">true</AutomaticCertSelection>
        <ShowPreConnectMessage>false</ShowPreConnectMessage>
        <CertificateStore>All</CertificateStore>
        <CertificateStoreOverride>false</CertificateStoreOverride>
        <ProxySettings>Native</ProxySettings>
        <AllowLocalProxyConnections>true</AllowLocalProxyConnections>
        <AuthenticationTimeout>60</AuthenticationTimeout>
        <AutoConnectOnStart UserControllable="true">false</AutoConnectOnStart>
        <MinimizeOnConnect UserControllable="true">true</MinimizeOnConnect>
        <LocalLanAccess UserControllable="false">false</LocalLanAccess>
        <DisableCaptivePortalDetection UserControllable="false">true</DisableCaptivePortalDetection>
        <AutoReconnect UserControllable="false">true</AutoReconnect>
        <AutoReconnectBehavior UserControllable="false">ReconnectAfterResume</AutoReconnectBehavior>
    </ClientInitialization>

    <ServerList>
        <HostEntry>
            <HostName>vpn-primary.company.com</HostName>
            <HostAddress>vpn-primary.company.com</HostAddress>
            <PrimaryProtocol>IPsec</PrimaryProtocol>
            <Port>443</Port>
        </HostEntry>
        <HostEntry>
            <HostName>vpn-secondary.company.com</HostName>
            <HostAddress>vpn-secondary.company.com</HostAddress>
            <PrimaryProtocol>IPsec</PrimaryProtocol>
            <Port>443</Port>
        </HostEntry>
    </ServerList>
</AnyConnectProfile>
```

### ASA VPN Configuration Template

```cisco
! Cisco ASA VPN Configuration for AnyConnect
! Basic Interface Configuration
interface GigabitEthernet0/0
 nameif outside
 security-level 0
 ip address 203.0.113.1 255.255.255.0
!
interface GigabitEthernet0/1
 nameif inside
 security-level 100
 ip address 192.168.1.1 255.255.255.0
!

! SSL VPN Configuration
webvpn
 enable outside
 anyconnect image disk0:/anyconnect-win-4.10.0-webdeploy-pkg.pkg
 anyconnect enable
 tunnel-group-list enable
!

! Group Policy Configuration
group-policy ANYCONNECT_POLICY internal
group-policy ANYCONNECT_POLICY attributes
 vpn-tunnel-protocol ssl-client
 split-tunnel-policy tunnelspecified
 split-tunnel-network-list SPLIT_TUNNEL_ACL
 address-pools value VPN_POOL
 anyconnect profiles value "AnyConnect_Client_Profile" type user
 anyconnect keep-installer installed
 anyconnect ssl compression deflate
 anyconnect ssl rekey time 30
 anyconnect ssl rekey method new-tunnel
!

! IP Pool Configuration
ip local pool VPN_POOL 192.168.100.1-192.168.100.100 mask 255.255.255.0
!

! Split Tunnel ACL
access-list SPLIT_TUNNEL_ACL standard permit 192.168.0.0 255.255.0.0
access-list SPLIT_TUNNEL_ACL standard permit 10.0.0.0 255.0.0.0
access-list SPLIT_TUNNEL_ACL standard permit 172.16.0.0 255.240.0.0
!

! Username Configuration (for testing)
username testuser password Temp123!
username testuser attributes
 vpn-group-policy ANYCONNECT_POLICY
!

! Certificate-based Authentication
crypto ca trustpoint CORPORATE_CA
 enrollment url http://ca-server.company.com/certsrv
 subject-name CN=ASA-Certificate,OU=IT,O=Company,C=US
 keypair-name ASA_KEYPAIR
 crl configure
!

crypto ca authenticate CORPORATE_CA
crypto ca enroll CORPORATE_CA
```

### Host Compliance Module Configuration

```xml
<!-- AnyConnect Host Compliance Module Configuration -->
<hcm:HostCompliance xmlns:hcm="http://www.cisco.com/schemas/hcm">
    <hcm:ComplianceModules>
        <!-- Windows Compliance Rules -->
        <hcm:ComplianceModule name="Windows_Compliance" platform="win">
            <hcm:Rules>
                <hcm:Rule name="Antivirus_Check">
                    <hcm:RuleType>registry</hcm:RuleType>
                    <hcm:Path>HKLM\SOFTWARE\Symantec\Symantec Endpoint Protection\AV\Storages\Filesystem\RealTimeScan</hcm:Path>
                    <hcm:Key>OnOff</hcm:Key>
                    <hcm:Value>1</hcm:Value>
                    <hcm:ComplianceAction>allow</hcm:ComplianceAction>
                    <hcm:NonComplianceAction>block</hcm:NonComplianceAction>
                </hcm:Rule>
                
                <hcm:Rule name="Windows_Firewall_Check">
                    <hcm:RuleType>registry</hcm:RuleType>
                    <hcm:Path>HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile</hcm:Path>
                    <hcm:Key>EnableFirewall</hcm:Key>
                    <hcm:Value>1</hcm:Value>
                    <hcm:ComplianceAction>allow</hcm:ComplianceAction>
                    <hcm:NonComplianceAction>block</hcm:NonComplianceAction>
                </hcm:Rule>
                
                <hcm:Rule name="OS_Version_Check">
                    <hcm:RuleType>registry</hcm:RuleType>
                    <hcm:Path>HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion</hcm:Path>
                    <hcm:Key>CurrentBuild</hcm:Key>
                    <hcm:MinValue>19041</hcm:MinValue>
                    <hcm:ComplianceAction>allow</hcm:ComplianceAction>
                    <hcm:NonComplianceAction>quarantine</hcm:NonComplianceAction>
                </hcm:Rule>
            </hcm:Rules>
        </hcm:ComplianceModule>
        
        <!-- macOS Compliance Rules -->
        <hcm:ComplianceModule name="macOS_Compliance" platform="mac">
            <hcm:Rules>
                <hcm:Rule name="FileVault_Check">
                    <hcm:RuleType>exec</hcm:RuleType>
                    <hcm:Command>fdesetup status | grep "FileVault is On"</hcm:Command>
                    <hcm:ComplianceAction>allow</hcm:ComplianceAction>
                    <hcm:NonComplianceAction>block</hcm:NonComplianceAction>
                </hcm:Rule>
                
                <hcm:Rule name="Gatekeeper_Check">
                    <hcm:RuleType>exec</hcm:RuleType>
                    <hcm:Command>spctl --status | grep "assessments enabled"</hcm:Command>
                    <hcm:ComplianceAction>allow</hcm:ComplianceAction>
                    <hcm:NonComplianceAction>quarantine</hcm:NonComplianceAction>
                </hcm:Rule>
            </hcm:Rules>
        </hcm:ComplianceModule>
    </hcm:ComplianceModules>
</hcm:HostCompliance>
```

---

## 4. Cisco Duo Integration Templates

### Duo RADIUS Configuration Template

```yaml
# Duo RADIUS Integration Configuration
duo_radius:
  name: "Corporate-Duo-RADIUS"
  
  # Authentication Settings
  authentication:
    integration_key: "DI_INTEGRATION_KEY_HERE"
    secret_key: "SECRET_KEY_HERE" 
    api_hostname: "api-12345678.duosecurity.com"
    
  # RADIUS Configuration
  radius_settings:
    client_ip: "192.168.1.100"
    secret: "shared_radius_secret"
    auth_port: 1812
    acct_port: 1813
    timeout: 60
    
  # Failsafe Options
  failsafe:
    failmode: "secure"  # secure or safe
    http_timeout: 10
    max_retries: 3
    
  # User Settings
  user_settings:
    autopush: true
    prompts: 3
    fallback_local_ip: true
    trusted_networks:
      - "192.168.1.0/24"
      - "10.0.0.0/8"
```

### Duo SAML Configuration Template

```xml
<!-- Duo SAML Configuration for SSO Integration -->
<saml:Configuration xmlns:saml="http://schemas.xmlsoap.org/soap/saml/">
    <saml:ServiceProvider>
        <saml:EntityID>https://company.duosecurity.com</saml:EntityID>
        <saml:AssertionConsumerService>
            <saml:Binding>urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST</saml:Binding>
            <saml:Location>https://company.duosecurity.com/saml/acs</saml:Location>
            <saml:Index>0</saml:Index>
            <saml:IsDefault>true</saml:IsDefault>
        </saml:AssertionConsumerService>
        
        <saml:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</saml:NameIDFormat>
        
        <saml:AttributeConsumingService>
            <saml:ServiceName>Duo Security Service</saml:ServiceName>
            <saml:RequestedAttribute Name="email" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" IsRequired="true"/>
            <saml:RequestedAttribute Name="firstName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" IsRequired="false"/>
            <saml:RequestedAttribute Name="lastName" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:basic" IsRequired="false"/>
        </saml:AttributeConsumingService>
    </saml:ServiceProvider>
    
    <saml:IdentityProvider>
        <saml:EntityID>https://adfs.company.com/adfs/services/trust</saml:EntityID>
        <saml:SingleSignOnService>
            <saml:Binding>urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect</saml:Binding>
            <saml:Location>https://adfs.company.com/adfs/ls/</saml:Location>
        </saml:SingleSignOnService>
        <saml:X509Certificate>
            MIICertificateDataGoesHere==
        </saml:X509Certificate>
    </saml:IdentityProvider>
</saml:Configuration>
```

---

## 5. Network Infrastructure Templates

### Switch Configuration Template (802.1X)

```cisco
! Cisco Switch 802.1X Configuration for ISE Integration
! Global 802.1X Configuration
aaa new-model
aaa authentication dot1x default group radius
aaa authorization network default group radius
aaa accounting dot1x default start-stop group radius

! RADIUS Configuration
radius server ISE-PRIMARY
 address ipv4 192.168.1.50 auth-port 1812 acct-port 1813
 key SharedSecretKey123!
 automate-tester username test-user idle-time 5
 timeout 5
 retransmit 3

radius server ISE-SECONDARY  
 address ipv4 192.168.1.51 auth-port 1812 acct-port 1813
 key SharedSecretKey123!
 timeout 5
 retransmit 3

aaa group server radius ISE-SERVERS
 server name ISE-PRIMARY
 server name ISE-SECONDARY
 ip radius source-interface Vlan100

! Global 802.1X Settings
dot1x system-auth-control
dot1x critical eapol

! Interface Template for Access Ports
interface range GigabitEthernet1/0/1-48
 switchport mode access
 switchport access vlan 999
 authentication host-mode multi-auth
 authentication order dot1x mab
 authentication priority dot1x mab
 authentication port-control auto
 authentication periodic
 authentication timer restart 30
 authentication timer reauthenticate 3600
 mab
 dot1x pae authenticator
 dot1x timeout tx-period 10
 spanning-tree portfast
 spanning-tree bpduguard enable

! CoA (Change of Authorization) Configuration
aaa server radius dynamic-author
 client 192.168.1.50 server-key SharedSecretKey123!
 client 192.168.1.51 server-key SharedSecretKey123!
 port 3799
 auth-type any

! VLAN Configuration
vlan 100
 name MANAGEMENT
vlan 200  
 name EMPLOYEES
vlan 300
 name GUESTS
vlan 400
 name QUARANTINE
vlan 999
 name DEFAULT_UNAUTH
```

### Wireless Controller Template

```cisco
! Cisco WLC Configuration for ISE Integration
! RADIUS Configuration
config radius auth add 1 192.168.1.50 1812 SharedSecretKey123!
config radius auth add 2 192.168.1.51 1812 SharedSecretKey123!
config radius acct add 1 192.168.1.50 1813 SharedSecretKey123!
config radius acct add 2 192.168.1.51 1813 SharedSecretKey123!

! AAA Configuration  
config aaa auth mgmt radius
config local-auth user-credentials admin admin123! all
config netuser add testuser testpass123! wlan 1 description "Test User"

! WLAN Configuration for Corporate Network
config wlan create 1 CORPORATE-SECURE CORPORATE-SECURE
config wlan interface 1 management
config wlan security wpa enable 1
config wlan security wpa wpa2 enable 1  
config wlan security wpa wpa2 ciphers aes enable 1
config wlan security wpa akm 802.1x enable 1
config wlan radius_server auth add 1 1
config wlan radius_server auth add 1 2
config wlan radius_server acct add 1 1
config wlan radius_server acct add 1 2
config wlan accounting radius enable 1
config wlan enable 1

! WLAN Configuration for Guest Network
config wlan create 2 GUEST-NETWORK GUEST-NETWORK
config wlan interface 2 guest
config wlan security web-auth enable 2
config wlan security web-auth server-precedence 2 local radius ldap
config wlan radius_server auth add 2 1
config wlan radius_server auth add 2 2
config wlan session-timeout 2 28800
config wlan enable 2

! Advanced Security Settings
config wlan security pmf enable 1 required
config wlan hotspot disable-dgaf 1 enable
config advanced 802.11 monitor mode enable
config rogue detection enable
```

---

## 6. Integration Templates

### SIEM Integration Template (Splunk)

```yaml
# Splunk Integration Configuration for Cisco Secure Access
splunk_integration:
  name: "Cisco-Secure-Access-SIEM"
  
  # Data Sources Configuration
  data_sources:
    umbrella:
      log_types:
        - "dns_logs"
        - "proxy_logs" 
        - "firewall_logs"
        - "threat_logs"
      collection_method: "syslog"
      syslog_server: "splunk-collector.company.com"
      syslog_port: 514
      format: "json"
      
    ise:
      log_types:
        - "authentication_logs"
        - "authorization_logs"  
        - "radius_accounting"
        - "admin_audit_logs"
      collection_method: "syslog"
      syslog_server: "splunk-collector.company.com"
      syslog_port: 515
      format: "cef"
      
    anyconnect:
      log_types:
        - "vpn_session_logs"
        - "connection_logs"
        - "disconnect_logs"
      collection_method: "asa_syslog"
      syslog_server: "splunk-collector.company.com"
      syslog_port: 516
      
    duo:
      log_types:
        - "authentication_logs"
        - "telephony_logs"
        - "administrator_logs"
      collection_method: "api_pull"
      api_endpoint: "https://api-12345678.duosecurity.com/admin/v1/logs"
      pull_frequency: "5_minutes"

  # Correlation Rules
  correlation_rules:
    - name: "Failed_Authentication_Burst"
      description: "Detect multiple failed authentication attempts"
      query: "source=ise eventType=authentication result=failure | stats count by user | where count > 5"
      severity: "high"
      action: "alert"
      
    - name: "Suspicious_DNS_Activity"  
      description: "Detect DNS queries to suspicious domains"
      query: "source=umbrella action=blocked category=suspicious | stats count by user | where count > 10"
      severity: "medium"
      action: "alert"
      
    - name: "VPN_Geographic_Anomaly"
      description: "VPN connection from unusual geographic location"
      query: "source=asa vpn_session=start | eval geo_distance=geodistance(user_normal_location, connection_location) | where geo_distance > 1000"
      severity: "high"
      action: "block_user"

  # Dashboards
  dashboards:
    executive_dashboard:
      - "security_incidents_trend"
      - "user_access_metrics"
      - "threat_detection_summary"
      - "compliance_status"
      
    operations_dashboard:
      - "real_time_threats"
      - "vpn_connection_status"
      - "authentication_failures"
      - "system_health_metrics"
```

### Active Directory Integration Template

```powershell
# Active Directory Integration Script for ISE and Duo
# PowerShell script for AD configuration

# Create Service Account for ISE
$ISEServiceAccount = @{
    Name = "svc-ise-ldap"
    AccountPassword = (ConvertTo-SecureString "ComplexPassword123!" -AsPlainText -Force)
    Description = "Service account for ISE LDAP integration"
    PasswordNeverExpires = $true
    CannotChangePassword = $true
    Enabled = $true
}
New-ADUser @ISEServiceAccount

# Create Service Account for Duo
$DuoServiceAccount = @{
    Name = "svc-duo-ldap"
    AccountPassword = (ConvertTo-SecureString "ComplexPassword456!" -AsPlainText -Force)  
    Description = "Service account for Duo LDAP integration"
    PasswordNeverExpires = $true
    CannotChangePassword = $true
    Enabled = $true
}
New-ADUser @DuoServiceAccount

# Create Security Groups for Access Control
$SecurityGroups = @(
    "ISE-Admin-Users",
    "ISE-Network-Admin", 
    "ISE-Helpdesk-Users",
    "VPN-Full-Access-Users",
    "VPN-Limited-Access-Users",
    "Duo-Bypass-Users",
    "Duo-Admin-Users"
)

foreach ($Group in $SecurityGroups) {
    New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security -Description "Access control group for Cisco Secure Access"
}

# Set Service Account Permissions
# Grant ISE service account read permissions to relevant OUs
$ISEServiceAccountDN = (Get-ADUser -Identity "svc-ise-ldap").DistinguishedName
$UsersOU = "OU=Users,DC=company,DC=com"

# Set permissions (this would typically be done through ADSI Edit or PowerShell ADSI modules)
$ACL = Get-ACL -Path "AD:\$UsersOU"
$AccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $ISEServiceAccountDN,
    "ReadProperty,GenericRead", 
    "Allow",
    "Descendents",
    [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
)
$ACL.SetAccessRule($AccessRule)
Set-ACL -Path "AD:\$UsersOU" -AclObject $ACL
```

---

## Configuration Deployment Guidelines

### Pre-Deployment Checklist

- [ ] Backup all existing configurations
- [ ] Verify network connectivity between components
- [ ] Validate certificate requirements and PKI infrastructure
- [ ] Confirm DNS resolution for all FQDNs
- [ ] Test LDAP/Active Directory connectivity
- [ ] Verify NTP synchronization across all components
- [ ] Document all custom modifications to templates

### Deployment Sequence

1. **Foundation Components**
   - Deploy Cisco ISE infrastructure nodes
   - Configure basic network connectivity and certificates
   - Establish Active Directory integration

2. **Security Services**
   - Deploy Cisco Umbrella cloud policies
   - Configure DNS redirection and policy enforcement
   - Implement cloud firewall rules

3. **Access Control**
   - Deploy ISE network access control policies
   - Configure switch and wireless infrastructure
   - Test device authentication and authorization

4. **Remote Access**
   - Deploy ASA/FTD VPN infrastructure
   - Configure AnyConnect client profiles
   - Implement host compliance checking

5. **Multi-Factor Authentication**
   - Deploy Duo Security infrastructure
   - Configure RADIUS and SAML integrations
   - Test MFA workflows

6. **Integration and Monitoring**
   - Configure SIEM integration
   - Deploy monitoring and alerting
   - Validate end-to-end functionality

### Post-Deployment Validation

- [ ] End-to-end authentication testing
- [ ] Policy enforcement validation
- [ ] Failover and redundancy testing
- [ ] Performance baseline establishment
- [ ] Security incident response testing
- [ ] Documentation handover and training completion

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Review Schedule**: Monthly  
**Document Owner**: Cisco Security Engineering Team
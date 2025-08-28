# Dell SafeID Authentication Configuration Templates

## Overview

This document provides comprehensive configuration templates for Dell SafeID Authentication implementations, including hardware security modules, biometric authentication, smart card integration, and enterprise directory services.

## Core SafeID Configuration

### SafeID Service Configuration

```xml
<?xml version="1.0" encoding="utf-8"?>
<SafeIDConfiguration>
  <ServiceSettings>
    <ServiceName>DellSafeIDService</ServiceName>
    <ServicePort>8443</ServicePort>
    <SSLEnabled>true</SSLEnabled>
    <CertificateThumbprint>YOUR_CERT_THUMBPRINT</CertificateThumbprint>
    <LogLevel>Information</LogLevel>
    <LogRetentionDays>90</LogRetentionDays>
  </ServiceSettings>
  
  <SecuritySettings>
    <EncryptionProvider>AES256</EncryptionProvider>
    <HashAlgorithm>SHA256</HashAlgorithm>
    <TokenLifetime>3600</TokenLifetime>
    <MaxFailedAttempts>3</MaxFailedAttempts>
    <LockoutDuration>900</LockoutDuration>
  </SecuritySettings>
  
  <PolicySettings>
    <RequireBiometric>true</RequireBiometric>
    <RequireSmartCard>false</RequireSmartCard>
    <AllowPasswordFallback>false</AllowPasswordFallback>
    <EnforceDeviceBinding>true</EnforceDeviceBinding>
  </PolicySettings>
</SafeIDConfiguration>
```

### Dell ControlVault Configuration

```json
{
  "controlVault": {
    "enabled": true,
    "version": "3.0",
    "securityLevel": "FIPS140-2",
    "encryptionSettings": {
      "algorithm": "AES-256-GCM",
      "keyDerivation": "PBKDF2",
      "iterations": 100000
    },
    "biometricSettings": {
      "fingerprintEnabled": true,
      "faceRecognitionEnabled": true,
      "qualityThreshold": 75,
      "templateStorage": "hardware"
    },
    "smartCardSettings": {
      "pivEnabled": true,
      "cacEnabled": true,
      "certificateValidation": "strict",
      "ocspChecking": true
    }
  }
}
```

## Active Directory Integration

### LDAP Configuration

```xml
<LDAPConfiguration>
  <ConnectionSettings>
    <ServerAddress>ldap://your-domain-controller.company.com:636</ServerAddress>
    <UseSSL>true</UseSSL>
    <BaseDN>DC=company,DC=com</BaseDN>
    <BindDN>CN=SafeID Service,OU=Service Accounts,DC=company,DC=com</BindDN>
    <BindPassword>ENCRYPTED_PASSWORD</BindPassword>
    <ConnectionTimeout>30</ConnectionTimeout>
    <SearchTimeout>60</SearchTimeout>
  </ConnectionSettings>
  
  <AttributeMapping>
    <UserPrincipalName>userPrincipalName</UserPrincipalName>
    <DisplayName>displayName</DisplayName>
    <Email>mail</Email>
    <Department>department</Department>
    <EmployeeID>employeeID</EmployeeID>
    <Groups>memberOf</Groups>
  </AttributeMapping>
  
  <SynchronizationSettings>
    <EnableAutoSync>true</EnableAutoSync>
    <SyncInterval>3600</SyncInterval>
    <SyncScope>OU=Users,DC=company,DC=com</SyncScope>
    <GroupFilter>(&amp;(objectClass=group)(cn=SafeID*))</GroupFilter>
  </SynchronizationSettings>
</LDAPConfiguration>
```

### Group Policy Templates

```xml
<!-- SafeID Authentication Policy -->
<GroupPolicy>
  <PolicyName>Dell SafeID Authentication Policy</PolicyName>
  <RegistrySettings>
    <Registry>
      <Key>HKLM\SOFTWARE\Dell\SafeID</Key>
      <ValueName>EnforceBiometric</ValueName>
      <ValueType>DWORD</ValueType>
      <ValueData>1</ValueData>
    </Registry>
    <Registry>
      <Key>HKLM\SOFTWARE\Dell\SafeID</Key>
      <ValueName>AllowPasswordFallback</ValueName>
      <ValueType>DWORD</ValueType>
      <ValueData>0</ValueData>
    </Registry>
    <Registry>
      <Key>HKLM\SOFTWARE\Dell\SafeID</Key>
      <ValueName>TokenTimeout</ValueName>
      <ValueType>DWORD</ValueType>
      <ValueData>3600</ValueData>
    </Registry>
  </RegistrySettings>
</GroupPolicy>
```

## Cloud Identity Provider Integration

### Azure Active Directory Configuration

```json
{
  "azureAD": {
    "tenantId": "YOUR_TENANT_ID",
    "clientId": "YOUR_CLIENT_ID",
    "clientSecret": "YOUR_CLIENT_SECRET",
    "authority": "https://login.microsoftonline.com/YOUR_TENANT_ID",
    "scopes": [
      "https://graph.microsoft.com/User.Read",
      "https://graph.microsoft.com/Group.Read.All"
    ],
    "conditionalAccess": {
      "requireMFA": true,
      "allowedLocations": ["US", "CA", "GB"],
      "blockedCountries": ["CN", "RU", "KP"],
      "deviceComplianceRequired": true
    },
    "tokenSettings": {
      "accessTokenLifetime": "PT1H",
      "refreshTokenLifetime": "P14D",
      "sessionTokenLifetime": "PT8H"
    }
  }
}
```

### Okta Integration Configuration

```yaml
okta:
  domain: "your-company.okta.com"
  clientId: "YOUR_OKTA_CLIENT_ID"
  clientSecret: "YOUR_OKTA_CLIENT_SECRET"
  scopes:
    - "openid"
    - "profile"
    - "email"
    - "groups"
  
  authorizationServer: "default"
  
  policies:
    - name: "SafeID MFA Policy"
      priority: 1
      conditions:
        applications: ["safeid-app"]
        users: ["Everyone"]
      actions:
        signOn:
          requireFactor: true
          factorPromptMode: "ALWAYS"
          rememberDeviceByDefault: false
```

## FIDO2/WebAuthn Configuration

### FIDO2 Relying Party Settings

```json
{
  "relyingParty": {
    "name": "Dell SafeID Authentication",
    "id": "safeid.company.com",
    "icon": "https://safeid.company.com/icon.png"
  },
  "authenticatorSelection": {
    "authenticatorAttachment": "platform",
    "requireResidentKey": true,
    "residentKey": "required",
    "userVerification": "required"
  },
  "attestation": "direct",
  "extensions": {
    "credProps": true,
    "largeBlob": {
      "support": "required"
    }
  },
  "timeout": 60000,
  "excludeCredentials": [],
  "pubKeyCredParams": [
    {
      "type": "public-key",
      "alg": -7
    },
    {
      "type": "public-key",
      "alg": -257
    }
  ]
}
```

### WebAuthn Client Configuration

```javascript
const webAuthnConfig = {
  rp: {
    name: "Dell SafeID",
    id: "safeid.company.com"
  },
  user: {
    id: new TextEncoder().encode("user@company.com"),
    name: "user@company.com",
    displayName: "John Doe"
  },
  challenge: new Uint8Array(32),
  pubKeyCredParams: [
    { alg: -7, type: "public-key" },  // ES256
    { alg: -257, type: "public-key" } // RS256
  ],
  authenticatorSelection: {
    authenticatorAttachment: "platform",
    userVerification: "required",
    residentKey: "required"
  },
  timeout: 60000,
  attestation: "direct"
};
```

## Network and Security Configuration

### Firewall Rules Template

```bash
#!/bin/bash
# Dell SafeID Firewall Configuration

# Inbound rules
iptables -A INPUT -p tcp --dport 8443 -j ACCEPT  # SafeID Service
iptables -A INPUT -p tcp --dport 443 -j ACCEPT   # HTTPS Web Interface
iptables -A INPUT -p tcp --dport 636 -j ACCEPT   # LDAPS
iptables -A INPUT -p tcp --dport 88 -j ACCEPT    # Kerberos
iptables -A INPUT -p udp --dport 88 -j ACCEPT    # Kerberos UDP

# Outbound rules for cloud integration
iptables -A OUTPUT -p tcp --dport 443 -d login.microsoftonline.com -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -d graph.microsoft.com -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -d your-company.okta.com -j ACCEPT

# Block all other traffic
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
```

### SSL/TLS Certificate Configuration

```yaml
certificates:
  safeid-service:
    keyFile: "/etc/ssl/private/safeid.key"
    certFile: "/etc/ssl/certs/safeid.crt"
    caFile: "/etc/ssl/certs/ca-bundle.crt"
    keySize: 2048
    algorithm: "RSA"
    validityPeriod: 365
    
  ldap-client:
    keyFile: "/etc/ssl/private/ldap-client.key"
    certFile: "/etc/ssl/certs/ldap-client.crt"
    caFile: "/etc/ssl/certs/domain-ca.crt"
    
  webauthn:
    keyFile: "/etc/ssl/private/webauthn.key"
    certFile: "/etc/ssl/certs/webauthn.crt"
    san:
      - "safeid.company.com"
      - "auth.company.com"
      - "*.company.com"
```

## Biometric Authentication Templates

### Fingerprint Reader Configuration

```xml
<BiometricConfiguration>
  <FingerprintSettings>
    <Enabled>true</Enabled>
    <MinQuality>70</MinQuality>
    <MaxAttempts>3</MaxAttempts>
    <TimeoutSeconds>10</TimeoutSeconds>
    <AntiSpoofing>true</AntiSpoofing>
    <LivenessDetection>true</LivenessDetection>
    <TemplateFormat>ISO19794-2</TemplateFormat>
    <EncryptionEnabled>true</EncryptionEnabled>
  </FingerprintSettings>
  
  <FaceRecognitionSettings>
    <Enabled>true</Enabled>
    <MinConfidence>85</MinConfidence>
    <MaxAttempts>3</MaxAttempts>
    <TimeoutSeconds>15</TimeoutSeconds>
    <AntiSpoofing>true</AntiSpoofing>
    <LivenessDetection>true</LivenessDetection>
    <InfraredRequired>true</InfraredRequired>
  </FaceRecognitionSettings>
</BiometricConfiguration>
```

## Smart Card Integration

### PIV/CAC Card Configuration

```json
{
  "smartCard": {
    "pivEnabled": true,
    "cacEnabled": true,
    "certificateStore": "MY",
    "certificateValidation": {
      "checkRevocation": true,
      "ocspEnabled": true,
      "crlEnabled": true,
      "allowSelfSigned": false,
      "requiredEku": ["1.3.6.1.5.5.7.3.2"] // Client Authentication
    },
    "pinPolicy": {
      "minLength": 6,
      "maxLength": 12,
      "complexityRequired": true,
      "maxAttempts": 3,
      "lockoutDuration": 900
    },
    "cardReaderSettings": {
      "timeout": 30,
      "autoEject": false,
      "warmReset": true
    }
  }
}
```

## Privileged Access Management

### PAM Integration Configuration

```yaml
pam:
  provider: "CyberArk"
  apiEndpoint: "https://pam.company.com/api"
  authentication:
    method: "certificate"
    certificate: "/etc/ssl/certs/pam-client.crt"
    privateKey: "/etc/ssl/private/pam-client.key"
  
  policies:
    - name: "Administrative Access"
      accounts: ["admin-*", "sa-*"]
      requireJustification: true
      approvalRequired: true
      sessionRecording: true
      maxSessionDuration: 3600
      
    - name: "Service Account Access"
      accounts: ["svc-*"]
      requireJustification: false
      approvalRequired: false
      sessionRecording: true
      maxSessionDuration: 86400
```

## Monitoring and Logging

### Log Configuration Template

```xml
<LoggingConfiguration>
  <Appenders>
    <FileAppender name="SecurityLog">
      <FileName>/var/log/safeid/security.log</FileName>
      <MaxFileSize>100MB</MaxFileSize>
      <MaxBackupFiles>10</MaxBackupFiles>
      <Layout>
        <Pattern>[%timestamp] [%level] [%thread] %logger - %message%newline</Pattern>
      </Layout>
      <Filters>
        <LevelRangeFilter levelMin="WARN" levelMax="FATAL"/>
      </Filters>
    </FileAppender>
    
    <SyslogAppender name="SyslogAudit">
      <RemoteHost>siem.company.com</RemoteHost>
      <Port>514</Port>
      <Protocol>UDP</Protocol>
      <Facility>AUTH</Facility>
      <Layout>
        <Pattern>SafeID: %message</Pattern>
      </Layout>
    </SyslogAppender>
  </Appenders>
  
  <Loggers>
    <Logger name="Dell.SafeID.Authentication" level="INFO" additivity="false">
      <AppenderRef ref="SecurityLog"/>
      <AppenderRef ref="SyslogAudit"/>
    </Logger>
  </Loggers>
</LoggingConfiguration>
```

## Environment-Specific Configurations

### Development Environment

```yaml
environment: development
safeid:
  debug: true
  logLevel: debug
  testMode: true
  skipCertValidation: true
  allowHttpRedirects: true
  
security:
  requireBiometric: false
  allowPasswordFallback: true
  tokenLifetime: 86400
  
database:
  connectionString: "Server=dev-db;Database=SafeID_Dev;Integrated Security=true"
  connectionTimeout: 30
```

### Production Environment

```yaml
environment: production
safeid:
  debug: false
  logLevel: info
  testMode: false
  skipCertValidation: false
  allowHttpRedirects: false
  
security:
  requireBiometric: true
  allowPasswordFallback: false
  tokenLifetime: 3600
  encryptionAtRest: true
  
database:
  connectionString: "Server=prod-cluster;Database=SafeID_Prod;Integrated Security=true;Encrypt=true"
  connectionTimeout: 15
  connectionPoolSize: 100
```

## Configuration Validation Scripts

### PowerShell Configuration Validator

```powershell
# SafeID Configuration Validation Script
function Test-SafeIDConfiguration {
    param(
        [string]$ConfigPath = "C:\Program Files\Dell\SafeID\config.xml"
    )
    
    Write-Host "Validating SafeID Configuration..." -ForegroundColor Green
    
    # Test configuration file exists
    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Configuration file not found: $ConfigPath"
        return $false
    }
    
    # Load and validate XML
    try {
        [xml]$config = Get-Content $ConfigPath
        Write-Host "✓ Configuration file is valid XML" -ForegroundColor Green
    }
    catch {
        Write-Error "Invalid XML configuration: $_"
        return $false
    }
    
    # Validate required settings
    $requiredSettings = @(
        "ServiceSettings/ServiceName",
        "SecuritySettings/EncryptionProvider",
        "PolicySettings/RequireBiometric"
    )
    
    foreach ($setting in $requiredSettings) {
        $node = $config.SelectSingleNode("//$setting")
        if ($null -eq $node) {
            Write-Error "Missing required setting: $setting"
            return $false
        }
        Write-Host "✓ Found required setting: $setting" -ForegroundColor Green
    }
    
    Write-Host "Configuration validation completed successfully!" -ForegroundColor Green
    return $true
}
```

---

**Note**: Replace placeholder values (YOUR_TENANT_ID, YOUR_CLIENT_ID, etc.) with actual values specific to your environment. All configuration files should be secured with appropriate file permissions and encryption where sensitive data is involved.
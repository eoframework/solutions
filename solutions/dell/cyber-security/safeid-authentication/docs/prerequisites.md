# Dell SafeID Authentication Prerequisites

## Overview

This document outlines the comprehensive prerequisites for implementing Dell SafeID Authentication solutions. It covers technical requirements, access requirements, knowledge prerequisites, and environmental considerations necessary for successful deployment and operation.

## Technical Prerequisites

### Hardware Requirements

#### Dell Device Requirements

```yaml
Supported Dell Systems:
  
  Laptops:
    - Latitude 7000 series (2018+)
    - Latitude 5000 series (2019+)  
    - Precision 7000 series (2018+)
    - Precision 5000 series (2019+)
    - XPS 15 (9570, 9500, 9510, 9520+)
    - XPS 13 (9370, 9380, 9300, 9310+)
  
  Desktops:
    - OptiPlex 7000 series (2018+)
    - OptiPlex 5000 series (2019+)
    - Precision 7000 Tower (2018+)
    - Precision 5000 Tower (2019+)
  
  Workstations:
    - Precision 7920 Tower
    - Precision 7820 Tower  
    - Precision 5820 Tower
    - Precision 3630 Tower

Required Hardware Components:
  ✓ Dell ControlVault 3.0 or higher
  ✓ TPM 2.0 chip (enabled and activated)
  ✓ UEFI BIOS with Secure Boot capability
  ✓ At least one biometric sensor:
    • Fingerprint reader (recommended: touch sensor)
    • Infrared camera for face recognition
    • Combined fingerprint/smartcard reader
  
Optional Hardware:
  ○ Smart card reader (PIV/CAC compatible)
  ○ NFC reader for proximity cards
  ○ External USB biometric devices
```

#### Server Infrastructure Requirements

##### SafeID Server Specifications

```yaml
Minimum Requirements (Up to 500 users):
  CPU: 4 cores, 2.4 GHz (Intel Xeon or equivalent)
  RAM: 8 GB DDR4
  Storage: 
    - OS Drive: 100 GB SSD
    - Data Drive: 200 GB SSD
    - Backup Drive: 500 GB (local or network)
  Network: 1 Gbps Ethernet
  OS: Windows Server 2019 Standard or higher

Recommended Requirements (500-2000 users):
  CPU: 8 cores, 2.8 GHz (Intel Xeon Gold or equivalent)
  RAM: 16 GB DDR4 ECC
  Storage:
    - OS Drive: 200 GB NVMe SSD
    - Data Drive: 500 GB NVMe SSD
    - Log Drive: 200 GB SSD
    - Backup: Enterprise backup solution
  Network: Dual 1 Gbps Ethernet (bonded)
  OS: Windows Server 2022 Standard or Datacenter

Enterprise Requirements (2000+ users):
  CPU: 16+ cores, 3.0+ GHz (Intel Xeon Platinum)
  RAM: 32+ GB DDR4 ECC
  Storage:
    - OS Drive: 500 GB NVMe SSD
    - Data Drive: 1+ TB NVMe SSD (RAID 10)
    - Log Drive: 500 GB SSD (RAID 1)
    - Backup: Enterprise SAN/NAS
  Network: Dual 10 Gbps Ethernet
  OS: Windows Server 2022 Datacenter
  High Availability: Cluster configuration
```

##### Database Requirements

```yaml
Database Options:

SQL Server LocalDB (Small deployments):
  - Included with SafeID installation
  - Maximum database size: 10 GB
  - Suitable for: <500 users
  - No additional licensing required

SQL Server Express (Medium deployments):  
  - Free edition of SQL Server
  - Maximum database size: 10 GB
  - Suitable for: 500-1500 users
  - No additional licensing required

SQL Server Standard (Enterprise deployments):
  - Full SQL Server functionality
  - No database size limit
  - Suitable for: 1500+ users
  - Requires SQL Server licensing
  - High availability options

SQL Server Enterprise (Large deployments):
  - Advanced features and performance
  - Always On Availability Groups
  - Suitable for: 5000+ users
  - Premium licensing required
  - Full disaster recovery capabilities
```

### Software Requirements

#### Operating System Requirements

##### Client Operating Systems

```yaml
Supported Client OS:

Windows 11 (Recommended):
  - Windows 11 Pro (22H2 or later)
  - Windows 11 Enterprise (22H2 or later)  
  - Windows 11 Education (22H2 or later)
  
Windows 10 (Supported):
  - Windows 10 Pro (21H2 or later)
  - Windows 10 Enterprise (21H2 or later)
  - Windows 10 Education (21H2 or later)
  - Windows 10 IoT Enterprise (21H2 or later)

Minimum Build Requirements:
  - Windows 11: Build 22621 or later
  - Windows 10: Build 19044 or later
  
Required Windows Features:
  ✓ Windows Biometric Framework
  ✓ Windows Hello for Business (if integrating)
  ✓ .NET Framework 4.8 or later
  ✓ PowerShell 5.1 or later
  ✓ Windows Management Framework 5.1
  ✓ Microsoft Visual C++ 2019 Redistributable

Unsupported Operating Systems:
  ✗ Windows 10 Home
  ✗ Windows 8.1 and earlier
  ✗ Windows Server OS (as client)
  ✗ Non-Windows operating systems
```

##### Server Operating Systems

```yaml
Supported Server OS:

Windows Server 2022 (Recommended):
  - Windows Server 2022 Standard
  - Windows Server 2022 Datacenter
  - Windows Server 2022 Essentials

Windows Server 2019 (Supported):
  - Windows Server 2019 Standard  
  - Windows Server 2019 Datacenter
  - Windows Server 2019 Essentials

Windows Server 2016 (Limited Support):
  - Windows Server 2016 Standard
  - Windows Server 2016 Datacenter
  - End of support: December 2024

Required Server Roles and Features:
  ✓ IIS (Internet Information Services)
  ✓ .NET Framework 4.8
  ✓ ASP.NET 4.8
  ✓ Windows Authentication
  ✓ PowerShell 5.1 or later
  ✓ Windows Management Framework 5.1
  ✓ Remote Server Administration Tools
```

#### Database Software Requirements

```yaml
Supported Database Platforms:

Microsoft SQL Server:
  - SQL Server 2022 (Recommended)
  - SQL Server 2019 (Supported)
  - SQL Server 2017 (Limited support)
  
SQL Server Editions:
  - Enterprise Edition (Full features)
  - Standard Edition (Recommended)
  - Express Edition (Small deployments)
  - LocalDB (Development/testing)

Required SQL Server Features:
  ✓ Database Engine Services
  ✓ Full-Text and Semantic Extractions
  ✓ Client Tools Connectivity
  ✓ Management Tools (SSMS recommended)
  ✓ SQL Server Replication (if using HA)
  ✓ Always On Availability Groups (Enterprise)

Database Compatibility Level:
  - Minimum: SQL Server 2017 (140)
  - Recommended: SQL Server 2019 (150) or higher
```

### Network Prerequisites

#### Network Infrastructure

```yaml
Network Requirements:

Bandwidth Requirements:
  Per User (Authentication):
    - Minimum: 64 Kbps
    - Recommended: 256 Kbps
    - Peak enrollment: 1 Mbps
  
  Server Infrastructure:
    - Internet connectivity: 100 Mbps (for cloud integration)
    - Internal network: 1 Gbps minimum
    - Database replication: 10 Gbps (enterprise)

Network Protocols:
  ✓ HTTP/HTTPS (ports 80/443)
  ✓ LDAP/LDAPS (ports 389/636)
  ✓ Kerberos (port 88 TCP/UDP)
  ✓ DNS (port 53 TCP/UDP)
  ✓ NTP (port 123 UDP)
  ✓ SMTP (port 25/587) for notifications

Quality of Service (QoS):
  - Authentication traffic: High priority
  - Biometric data transfer: Medium priority
  - Management traffic: Standard priority
  - Bulk operations: Low priority
```

#### Firewall Requirements

```yaml
Required Firewall Rules:

Inbound Rules (SafeID Server):
  - Port 8443 (HTTPS) - SafeID Service
  - Port 443 (HTTPS) - Web Management Console
  - Port 1433 (SQL Server) - Database access
  - Port 445 (SMB) - File sharing (if needed)
  - Port 135 (RPC) - Remote management
  - Port 3389 (RDP) - Remote desktop (management)

Outbound Rules (SafeID Server):
  - Port 443 (HTTPS) - Internet/cloud services
  - Port 636 (LDAPS) - Active Directory
  - Port 389 (LDAP) - Active Directory (fallback)
  - Port 88 (Kerberos) - Authentication
  - Port 53 (DNS) - Name resolution
  - Port 25/587 (SMTP) - Email notifications
  - Port 123 (NTP) - Time synchronization

Client Rules:
  - Outbound Port 8443 - SafeID Server
  - Outbound Port 443 - Web services
  - Outbound Port 88 - Kerberos
  - Outbound Port 53 - DNS
```

#### DNS Requirements

```yaml
DNS Configuration:

Required DNS Records:
  A Records:
    - safeid.company.com → SafeID server IP
    - safeid-web.company.com → Web server IP
    - safeid-db.company.com → Database server IP
  
  CNAME Records:
    - auth.company.com → safeid.company.com
    - authentication.company.com → safeid.company.com
  
  SRV Records (if using Kerberos):
    - _kerberos._tcp.company.com
    - _kpasswd._tcp.company.com

Certificate Subject Alternative Names:
  - safeid.company.com
  - auth.company.com  
  - authentication.company.com
  - safeid-web.company.com

Internal DNS Resolution:
  ✓ Forward lookup zones configured
  ✓ Reverse lookup zones configured
  ✓ DNS suffix search list includes domain
  ✓ DNS servers are highly available
```

## Access Requirements

### Administrative Access

#### Active Directory Permissions

```yaml
Required Service Account Permissions:

SafeID Service Account (safeid-service):
  Domain Permissions:
    - Log on as a service
    - Log on as a batch job
    - Act as part of operating system
    - Create global objects
    - Generate security audits
    - Impersonate a client after authentication
  
  Active Directory Permissions:
    - Read all user properties
    - Read all group memberships
    - Read password last set
    - Read account expiration
    - Read user account control flags
  
  Specific OU Permissions:
    - Read permissions on Users OU
    - Read permissions on Groups OU
    - Read permissions on Computers OU

Domain Admin Requirements:
  Installation Phase:
    - Create service accounts
    - Configure Service Principal Names (SPNs)  
    - Modify schema (if extending)
    - Create and link Group Policy Objects
    - Delegate permissions to service accounts
  
  Ongoing Operations:
    - Not required for daily operations
    - Required for major configuration changes
    - Required for disaster recovery
```

#### Local Administrator Rights

```yaml
Required Local Admin Access:

SafeID Servers:
  Installation:
    - Full local administrator rights
    - Ability to install Windows services
    - Modify local security policy
    - Install certificates
    - Configure IIS (if used)
  
  Operations:
    - Service management rights
    - Event log access
    - Performance counter access
    - File system access to SafeID directories
    - Registry access to SafeID keys

Client Workstations:
  Initial Setup:
    - Local administrator rights for installation
    - Modify local computer policy
    - Install biometric drivers
    - Configure local certificates
  
  End User Operations:
    - Standard user rights sufficient
    - No administrative access required
    - Biometric enrollment requires user consent
```

### Certificate Authority Access

```yaml
PKI Infrastructure Requirements:

Internal Certificate Authority:
  Required Certificates:
    - SafeID Server SSL certificate
    - Client authentication certificates (optional)
    - Code signing certificates (for scripts)
    - Document signing certificates (for policies)
  
  CA Permissions:
    - Request certificates
    - Auto-enroll certificates (recommended)
    - Manage CA templates
    - Configure certificate revocation
  
Certificate Templates:
  SafeID Server Template:
    - Key usage: Digital signature, Key encipherment
    - Enhanced key usage: Server authentication
    - Subject alternative names: DNS names
    - Validity period: 1-2 years
    - Key size: 2048 bits minimum (RSA) or 256 bits (ECC)
  
  Client Authentication Template (if used):
    - Key usage: Digital signature
    - Enhanced key usage: Client authentication
    - Subject: User principal name
    - Validity period: 1 year
    - Auto-enrollment enabled

Certificate Deployment:
  ✓ Root CA certificate deployed to all systems
  ✓ Intermediate CA certificates deployed
  ✓ Certificate revocation list (CRL) accessible
  ✓ Online Certificate Status Protocol (OCSP) configured
  ✓ Certificate auto-enrollment configured (GPO)
```

## Knowledge Prerequisites

### Technical Skills

#### System Administrator Skills

```yaml
Required Technical Knowledge:

Windows Administration:
  Essential Skills:
    - Windows Server 2019/2022 administration
    - Active Directory Domain Services
    - Group Policy Object management
    - Windows services management
    - Event log analysis and troubleshooting
    - PowerShell scripting (basic to intermediate)
    - Windows security configuration
  
  Recommended Skills:
    - IIS administration
    - Certificate management and PKI
    - Windows clustering and high availability
    - Performance monitoring and tuning
    - Backup and disaster recovery
    - Remote administration tools

Database Administration:
  Essential Skills:
    - SQL Server installation and configuration
    - Database backup and recovery procedures
    - Basic SQL query writing
    - SQL Server security configuration
    - Performance monitoring basics
  
  Recommended Skills:
    - SQL Server high availability (Always On)
    - Database performance tuning
    - SQL Server Reporting Services
    - Database maintenance planning
    - SQL Server Agent job configuration

Network Administration:
  Essential Skills:
    - TCP/IP networking fundamentals
    - DNS configuration and troubleshooting
    - Firewall rule configuration
    - SSL/TLS certificate management
    - Basic network troubleshooting
  
  Recommended Skills:
    - Load balancer configuration
    - Network monitoring and analysis
    - VPN configuration
    - Network security best practices
    - Quality of Service (QoS) configuration
```

#### Security Knowledge

```yaml
Required Security Expertise:

Identity and Access Management:
  - Multi-factor authentication concepts
  - Single sign-on (SSO) implementation
  - Role-based access control (RBAC)
  - Privileged access management (PAM)
  - Identity federation (SAML, OIDC)
  
Biometric Authentication:
  - Biometric technology fundamentals
  - False acceptance/rejection rates
  - Template storage and matching
  - Anti-spoofing and liveness detection
  - Privacy and security considerations

Cryptography:
  - Public key infrastructure (PKI)
  - Symmetric and asymmetric encryption
  - Digital certificates and signatures
  - Key management best practices
  - Cryptographic standards (FIPS 140-2)

Compliance and Governance:
  - GDPR privacy requirements
  - SOX compliance for financial organizations
  - NIST Cybersecurity Framework
  - Common Criteria evaluation
  - Audit and logging requirements
```

### Training Requirements

```yaml
Mandatory Training Programs:

Pre-Implementation Training:
  SafeID Fundamentals (8 hours):
    - SafeID architecture overview
    - Hardware and software components
    - Integration patterns and methods
    - Security model and best practices
  
  Installation and Configuration (16 hours):
    - Hands-on installation procedures
    - Configuration management
    - Active Directory integration
    - Certificate management
    - Policy configuration

Operations Training (12 hours):
  - Daily operations procedures
  - User management and enrollment
  - Monitoring and maintenance
  - Troubleshooting common issues
  - Performance optimization

Advanced Topics (Optional, 8 hours):
  - High availability configuration
  - Disaster recovery procedures
  - API integration and customization
  - Advanced troubleshooting
  - Custom policy development

Certification Requirements:
  - SafeID Administrator Certification (required)
  - Microsoft Certified: Windows Server (recommended)
  - CompTIA Security+ (recommended for security team)
  - Certified Information Systems Security Professional (CISSP) - for senior staff
```

## Environmental Prerequisites

### Physical Environment

```yaml
Data Center Requirements:

Power and Cooling:
  - Uninterruptible Power Supply (UPS)
  - Redundant power feeds
  - Temperature: 64-75°F (18-24°C)
  - Humidity: 45-55% relative humidity
  - Environmental monitoring
  
Physical Security:
  - Controlled access to data center
  - Security cameras and monitoring
  - Fire suppression system
  - Physical security for server rooms
  - Badge access control systems

Space Requirements:
  - Adequate rack space for servers
  - Cable management systems
  - Network connectivity infrastructure
  - Separate storage for backups
  - Work area for maintenance
```

### Organizational Prerequisites

#### Governance and Policy

```yaml
Required Organizational Elements:

Information Security Policy:
  - Acceptable use policy
  - Password/authentication policy  
  - Data classification policy
  - Incident response procedures
  - Business continuity plan

Change Management:
  - Change approval process
  - Testing and validation procedures
  - Rollback procedures
  - Documentation requirements
  - Communication plan

Risk Management:
  - Risk assessment procedures
  - Business impact analysis
  - Vendor risk assessment
  - Third-party security reviews
  - Insurance coverage evaluation

Compliance Framework:
  - Regulatory compliance requirements
  - Internal audit procedures
  - External audit support
  - Documentation retention
  - Reporting mechanisms
```

#### Staffing Requirements

```yaml
Required Team Structure:

Core Implementation Team:
  Project Manager:
    - PMP certification preferred
    - 3+ years IT project experience
    - Strong communication skills
    - Change management experience
  
  System Administrator:
    - 5+ years Windows administration
    - Active Directory expertise
    - PowerShell scripting skills
    - Security knowledge
  
  Network Administrator:
    - 3+ years network administration
    - Firewall management experience
    - Certificate management knowledge
    - Troubleshooting skills
  
  Security Analyst:
    - 3+ years security experience
    - Identity management knowledge
    - Compliance framework understanding
    - Risk assessment skills

Support Team:
  Help Desk Staff (Tier 1):
    - Basic Windows troubleshooting
    - Customer service skills
    - Ticket management experience
    - Training on SafeID basics
  
  Desktop Support (Tier 2):
    - Hardware troubleshooting
    - Driver installation experience
    - Biometric device knowledge
    - Advanced Windows skills
  
  Infrastructure Team (Tier 3):
    - Advanced system administration
    - Database administration
    - Network troubleshooting
    - Security incident response
```

## Pre-Implementation Checklist

### Technical Readiness

```yaml
Infrastructure Readiness Checklist:

Hardware:
  □ Dell devices with ControlVault 3.0+ identified
  □ TPM 2.0 enabled on all target devices
  □ Biometric sensors tested and functional
  □ Server hardware procured and installed
  □ Network infrastructure validated
  □ Storage capacity planned and allocated

Software:
  □ Operating systems updated to required versions
  □ .NET Framework 4.8 installed
  □ SQL Server installed and configured
  □ PowerShell 5.1 or later available
  □ Antivirus exclusions configured
  □ Windows features enabled

Network:
  □ DNS records created and tested
  □ Firewall rules configured
  □ SSL certificates obtained
  □ Network connectivity verified
  □ Bandwidth requirements met
  □ Time synchronization configured

Security:
  □ Service accounts created and configured
  □ Permissions delegated appropriately
  □ Certificate authority prepared
  □ Security policies reviewed and approved
  □ Audit logging configured
  □ Backup procedures established
```

### Organizational Readiness

```yaml
Process Readiness Checklist:

Governance:
  □ Project charter approved
  □ Budget allocated and approved
  □ Stakeholders identified and engaged
  □ Success criteria defined
  □ Risk register created and maintained
  □ Change management process established

Team:
  □ Implementation team assembled
  □ Roles and responsibilities defined
  □ Training plans created
  □ Support procedures documented
  □ Escalation paths established
  □ Communication plan activated

Documentation:
  □ Requirements document finalized
  □ Architecture document completed
  □ Implementation plan approved
  □ Test plan developed
  □ Operations procedures documented
  □ Training materials prepared

Compliance:
  □ Regulatory requirements identified
  □ Privacy impact assessment completed
  □ Security review conducted
  □ Audit requirements documented
  □ Compliance reporting planned
  □ Legal review completed
```

## Validation Procedures

### Prerequisites Validation Script

```powershell
# SafeID Prerequisites Validation Script
function Test-SafeIDPrerequisites {
    [CmdletBinding()]
    param(
        [switch]$GenerateReport,
        [string]$ReportPath = "C:\Temp\SafeID-Prerequisites-Report.html"
    )
    
    Write-Host "SafeID Prerequisites Validation" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    
    $results = @()
    
    # Test 1: Operating System Version
    Write-Host "`nTesting Operating System..." -ForegroundColor Yellow
    $os = Get-WmiObject -Class Win32_OperatingSystem
    $osVersion = [Version]$os.Version
    $minVersion = [Version]"10.0.19044"
    
    $osTest = @{
        Test = "Operating System Version"
        Expected = "Windows 10 21H2+ or Windows 11"
        Actual = "$($os.Caption) (Build $($os.BuildNumber))"
        Status = if ($osVersion -ge $minVersion) { "PASS" } else { "FAIL" }
        Details = "Minimum required: Build 19044"
    }
    $results += $osTest
    
    # Test 2: TPM Status
    Write-Host "Testing TPM..." -ForegroundColor Yellow
    try {
        $tpm = Get-Tpm
        $tpmTest = @{
            Test = "TPM 2.0 Status"
            Expected = "TPM 2.0 Present and Ready"
            Actual = "Present: $($tpm.TpmPresent), Ready: $($tpm.TpmReady), Enabled: $($tpm.TpmEnabled)"
            Status = if ($tpm.TpmPresent -and $tpm.TpmReady -and $tpm.TpmEnabled) { "PASS" } else { "FAIL" }
            Details = "TPM specification version: $($tpm.SpecVersion)"
        }
    }
    catch {
        $tpmTest = @{
            Test = "TPM 2.0 Status"
            Expected = "TPM 2.0 Present and Ready"
            Actual = "TPM not accessible"
            Status = "FAIL"
            Details = "Error: $($_.Exception.Message)"
        }
    }
    $results += $tpmTest
    
    # Test 3: Dell ControlVault
    Write-Host "Testing Dell ControlVault..." -ForegroundColor Yellow
    $controlVault = Get-PnpDevice | Where-Object {$_.HardwareID -like "*VID_413C*" -and $_.Class -eq "SecurityDevices"}
    $cvTest = @{
        Test = "Dell ControlVault"
        Expected = "ControlVault 3.0 or higher"
        Actual = if ($controlVault) { "Detected: $($controlVault.FriendlyName)" } else { "Not detected" }
        Status = if ($controlVault) { "PASS" } else { "FAIL" }
        Details = if ($controlVault) { "Hardware ID: $($controlVault.HardwareID)" } else { "Dell ControlVault hardware not found" }
    }
    $results += $cvTest
    
    # Test 4: Biometric Devices
    Write-Host "Testing Biometric Devices..." -ForegroundColor Yellow
    $biometricDevices = Get-PnpDevice | Where-Object {$_.Class -eq "Biometric" -and $_.Status -eq "OK"}
    $bioTest = @{
        Test = "Biometric Devices"
        Expected = "At least one biometric device"
        Actual = if ($biometricDevices) { "$($biometricDevices.Count) device(s) found" } else { "No devices found" }
        Status = if ($biometricDevices.Count -gt 0) { "PASS" } else { "FAIL" }
        Details = if ($biometricDevices) { ($biometricDevices.FriendlyName -join ", ") } else { "No biometric hardware detected" }
    }
    $results += $bioTest
    
    # Test 5: .NET Framework
    Write-Host "Testing .NET Framework..." -ForegroundColor Yellow
    $dotNetVersion = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction SilentlyContinue).Release
    $dotNetTest = @{
        Test = ".NET Framework Version"
        Expected = ".NET Framework 4.8 or later"
        Actual = if ($dotNetVersion -ge 528040) { ".NET Framework 4.8+" } else { "Older version or not found" }
        Status = if ($dotNetVersion -ge 528040) { "PASS" } else { "FAIL" }
        Details = "Release number: $dotNetVersion"
    }
    $results += $dotNetTest
    
    # Test 6: PowerShell Version
    Write-Host "Testing PowerShell Version..." -ForegroundColor Yellow
    $psVersion = $PSVersionTable.PSVersion
    $psTest = @{
        Test = "PowerShell Version"
        Expected = "PowerShell 5.1 or later"
        Actual = "PowerShell $($psVersion.Major).$($psVersion.Minor)"
        Status = if ($psVersion.Major -gt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -ge 1)) { "PASS" } else { "FAIL" }
        Details = "Full version: $($psVersion.ToString())"
    }
    $results += $psTest
    
    # Test 7: Available Disk Space
    Write-Host "Testing Disk Space..." -ForegroundColor Yellow
    $disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DeviceID -eq "C:"}
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    $diskTest = @{
        Test = "Available Disk Space"
        Expected = "At least 10 GB free space"
        Actual = "$freeSpaceGB GB available"
        Status = if ($freeSpaceGB -ge 10) { "PASS" } else { "FAIL" }
        Details = "Total size: $([math]::Round($disk.Size / 1GB, 2)) GB"
    }
    $results += $diskTest
    
    # Test 8: Network Connectivity
    Write-Host "Testing Network Connectivity..." -ForegroundColor Yellow
    $networkTest = @{
        Test = "Internet Connectivity"
        Expected = "Internet access available"
        Actual = ""
        Status = ""
        Details = ""
    }
    
    try {
        $response = Test-NetConnection -ComputerName "www.microsoft.com" -Port 443 -InformationLevel Quiet
        $networkTest.Actual = if ($response) { "Internet accessible" } else { "No internet access" }
        $networkTest.Status = if ($response) { "PASS" } else { "WARN" }
        $networkTest.Details = "HTTPS connectivity test to Microsoft.com"
    }
    catch {
        $networkTest.Actual = "Network test failed"
        $networkTest.Status = "FAIL"
        $networkTest.Details = "Error: $($_.Exception.Message)"
    }
    $results += $networkTest
    
    # Summary
    Write-Host "`n" + "="*50 -ForegroundColor Cyan
    Write-Host "PREREQUISITES VALIDATION SUMMARY" -ForegroundColor Cyan  
    Write-Host "="*50 -ForegroundColor Cyan
    
    $passCount = ($results | Where-Object {$_.Status -eq "PASS"}).Count
    $failCount = ($results | Where-Object {$_.Status -eq "FAIL"}).Count
    $warnCount = ($results | Where-Object {$_.Status -eq "WARN"}).Count
    
    Write-Host "`nResults:" -ForegroundColor Yellow
    Write-Host "  PASSED: $passCount" -ForegroundColor Green
    Write-Host "  FAILED: $failCount" -ForegroundColor Red
    Write-Host "  WARNINGS: $warnCount" -ForegroundColor Yellow
    
    foreach ($result in $results) {
        $color = switch ($result.Status) {
            "PASS" { "Green" }
            "FAIL" { "Red" }
            "WARN" { "Yellow" }
            default { "White" }
        }
        
        Write-Host "`n$($result.Test):" -ForegroundColor White
        Write-Host "  Status: $($result.Status)" -ForegroundColor $color
        Write-Host "  Expected: $($result.Expected)" -ForegroundColor Gray
        Write-Host "  Actual: $($result.Actual)" -ForegroundColor Gray
        Write-Host "  Details: $($result.Details)" -ForegroundColor Gray
    }
    
    # Generate HTML report if requested
    if ($GenerateReport) {
        $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>SafeID Prerequisites Validation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #0078d4; color: white; padding: 20px; text-align: center; }
        .summary { background-color: #f8f9fa; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .pass { color: green; font-weight: bold; }
        .fail { color: red; font-weight: bold; }
        .warn { color: orange; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>SafeID Prerequisites Validation Report</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Total Tests:</strong> $($results.Count)</p>
        <p class="pass">Passed: $passCount</p>
        <p class="fail">Failed: $failCount</p>
        <p class="warn">Warnings: $warnCount</p>
    </div>
    
    <h2>Detailed Results</h2>
    <table>
        <tr>
            <th>Test</th>
            <th>Status</th>
            <th>Expected</th>
            <th>Actual</th>
            <th>Details</th>
        </tr>
"@
        
        foreach ($result in $results) {
            $statusClass = $result.Status.ToLower()
            $htmlReport += @"
        <tr>
            <td>$($result.Test)</td>
            <td class="$statusClass">$($result.Status)</td>
            <td>$($result.Expected)</td>
            <td>$($result.Actual)</td>
            <td>$($result.Details)</td>
        </tr>
"@
        }
        
        $htmlReport += @"
    </table>
</body>
</html>
"@
        
        $htmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
        Write-Host "`nHTML report generated: $ReportPath" -ForegroundColor Green
    }
    
    return @{
        Results = $results
        Summary = @{
            Total = $results.Count
            Passed = $passCount
            Failed = $failCount
            Warnings = $warnCount
            OverallStatus = if ($failCount -eq 0) { "READY" } else { "NOT READY" }
        }
    }
}

# Example usage:
# $validation = Test-SafeIDPrerequisites -GenerateReport
# if ($validation.Summary.OverallStatus -eq "READY") {
#     Write-Host "System is ready for SafeID installation!" -ForegroundColor Green
# } else {
#     Write-Host "Prerequisites not met. Please address failed items before proceeding." -ForegroundColor Red
# }
```

---

**Prerequisites Version**: 1.0  
**Compatibility**: Dell SafeID v3.0+  
**Last Updated**: November 2024  
**Next Review**: February 2025
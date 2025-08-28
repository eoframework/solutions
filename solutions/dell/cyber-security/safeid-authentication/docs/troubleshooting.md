# Dell SafeID Authentication Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues with Dell SafeID Authentication systems. It includes diagnostic procedures, resolution steps, escalation paths, and preventive measures.

## Troubleshooting Methodology

### Systematic Approach

```
Troubleshooting Workflow
=======================

1. IDENTIFY
   ├── Gather symptoms and error messages
   ├── Determine scope of impact (single user vs. system-wide)
   ├── Check recent changes or updates
   └── Review system and application logs

2. ISOLATE
   ├── Reproduce the issue in controlled environment
   ├── Test with different users/devices
   ├── Verify system dependencies
   └── Check component connectivity

3. ANALYZE
   ├── Compare against known working configuration
   ├── Review diagnostic data and logs
   ├── Identify patterns and correlations
   └── Formulate hypothesis

4. RESOLVE
   ├── Implement targeted solution
   ├── Test resolution thoroughly
   ├── Monitor for recurrence
   └── Document solution

5. PREVENT
   ├── Identify root cause
   ├── Implement preventive measures
   ├── Update procedures and documentation
   └── Share knowledge with team
```

### Diagnostic Tools

```powershell
# SafeID Diagnostic Tools Collection
$SafeIDDiagnosticTools = @{
    "System Health Check" = "C:\Program Files\Dell\SafeID\Tools\HealthCheck.exe"
    "Service Diagnostics" = "C:\Program Files\Dell\SafeID\Tools\ServiceDiag.exe"
    "Hardware Test" = "C:\Program Files\Dell\SafeID\Tools\HardwareTest.exe"
    "Network Connectivity" = "C:\Program Files\Dell\SafeID\Tools\NetTest.exe"
    "Certificate Validator" = "C:\Program Files\Dell\SafeID\Tools\CertTest.exe"
    "Log Analyzer" = "C:\Program Files\Dell\SafeID\Tools\LogAnalyzer.exe"
    "Performance Monitor" = "C:\Program Files\Dell\SafeID\Tools\PerfMon.exe"
    "Configuration Validator" = "C:\Program Files\Dell\SafeID\Tools\ConfigTest.exe"
}

# Quick diagnostic function
function Start-SafeIDDiagnostics {
    Write-Host "Running SafeID Diagnostics..." -ForegroundColor Cyan
    
    # Service status check
    $services = @("DellSafeIDService", "DellSafeIDBiometric", "DellSafeIDWeb", "DellSafeIDSync")
    foreach ($service in $services) {
        $status = (Get-Service $service -ErrorAction SilentlyContinue).Status
        Write-Host "$service : $status" -ForegroundColor $(if($status -eq "Running"){"Green"}else{"Red"})
    }
    
    # Hardware check
    $tpm = Get-Tpm -ErrorAction SilentlyContinue
    Write-Host "TPM Status: $(if($tpm.TpmReady){'Ready'}else{'Not Ready'})" -ForegroundColor $(if($tpm.TpmReady){"Green"}else{"Red"})
    
    # Event log summary
    $recentErrors = Get-EventLog -LogName Application -Source "*SafeID*" -EntryType Error -Newest 5 -ErrorAction SilentlyContinue
    Write-Host "Recent Errors: $($recentErrors.Count)" -ForegroundColor $(if($recentErrors.Count -eq 0){"Green"}else{"Red"})
}
```

## Common Issues and Solutions

### Authentication Failures

#### Issue: User Cannot Authenticate with Biometric

**Symptoms:**
- Fingerprint reader not recognizing enrolled finger
- Face recognition failing consistently
- Error messages: "Authentication failed" or "Try again"
- System falls back to password authentication

**Diagnostic Steps:**

```powershell
# Biometric Authentication Diagnostics
function Diagnose-BiometricAuth {
    param([string]$UserName)
    
    Write-Host "Diagnosing Biometric Authentication for $UserName" -ForegroundColor Cyan
    
    # Check user enrollment status
    $enrollmentPath = "C:\ProgramData\Dell\SafeID\Templates\$UserName"
    if (Test-Path $enrollmentPath) {
        Write-Host "✓ Biometric templates found for user" -ForegroundColor Green
        $templates = Get-ChildItem $enrollmentPath
        Write-Host "  Templates: $($templates.Count)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ No biometric templates found - user needs re-enrollment" -ForegroundColor Red
        return "USER_NOT_ENROLLED"
    }
    
    # Check hardware status
    $biometricDevices = Get-PnpDevice | Where-Object {$_.Class -eq "Biometric" -and $_.Status -eq "OK"}
    if ($biometricDevices.Count -eq 0) {
        Write-Host "✗ No working biometric devices found" -ForegroundColor Red
        return "HARDWARE_ISSUE"
    } else {
        Write-Host "✓ Biometric hardware operational: $($biometricDevices.Count) device(s)" -ForegroundColor Green
    }
    
    # Check service status
    $bioService = Get-Service "DellSafeIDBiometric" -ErrorAction SilentlyContinue
    if ($bioService.Status -ne "Running") {
        Write-Host "✗ Biometric service not running" -ForegroundColor Red
        return "SERVICE_ISSUE"
    } else {
        Write-Host "✓ Biometric service running" -ForegroundColor Green
    }
    
    # Check recent authentication attempts
    $authLogs = Get-EventLog -LogName Application -Source "DellSafeID" | Where-Object {
        $_.Message -like "*$UserName*" -and $_.TimeGenerated -gt (Get-Date).AddHours(-24)
    } | Select-Object -First 10
    
    Write-Host "Recent authentication attempts: $($authLogs.Count)" -ForegroundColor Yellow
    foreach ($log in $authLogs | Select-Object -First 3) {
        Write-Host "  $($log.TimeGenerated): $($log.EntryType) - $($log.Message.Substring(0, [Math]::Min(80, $log.Message.Length)))" -ForegroundColor Gray
    }
    
    return "DIAGNOSIS_COMPLETE"
}
```

**Resolution Steps:**

1. **Hardware Issues:**
   ```powershell
   # Clean biometric sensor
   Write-Host "1. Clean the biometric sensor with a soft, lint-free cloth"
   Write-Host "2. Ensure sensor is dry before use"
   Write-Host "3. Check for physical damage or obstruction"
   
   # Update drivers
   $biometricDevices = Get-PnpDevice | Where-Object {$_.Class -eq "Biometric"}
   foreach ($device in $biometricDevices) {
       if ($device.Status -ne "OK") {
           Write-Host "Updating driver for $($device.FriendlyName)" -ForegroundColor Yellow
           # Pnputil /add-driver command or Windows Update
       }
   }
   ```

2. **Service Issues:**
   ```powershell
   # Restart biometric service
   Restart-Service "DellSafeIDBiometric" -Force
   Start-Sleep -Seconds 5
   
   # Verify service startup
   $service = Get-Service "DellSafeIDBiometric"
   if ($service.Status -eq "Running") {
       Write-Host "✓ Biometric service restarted successfully" -ForegroundColor Green
   } else {
       Write-Host "✗ Service restart failed - check event logs" -ForegroundColor Red
   }
   ```

3. **Template Issues:**
   ```powershell
   # Re-enrollment process
   function Start-UserReenrollment {
       param([string]$UserName)
       
       Write-Host "Starting re-enrollment for $UserName" -ForegroundColor Cyan
       
       # Remove existing templates
       $templatePath = "C:\ProgramData\Dell\SafeID\Templates\$UserName"
       if (Test-Path $templatePath) {
           Remove-Item $templatePath -Recurse -Force
           Write-Host "✓ Existing templates removed" -ForegroundColor Green
       }
       
       # Launch enrollment tool
       $enrollmentTool = "C:\Program Files\Dell\SafeID\Tools\EnrollmentTool.exe"
       if (Test-Path $enrollmentTool) {
           Start-Process $enrollmentTool -ArgumentList "-user $UserName"
           Write-Host "✓ Enrollment tool launched" -ForegroundColor Green
       } else {
           Write-Host "✗ Enrollment tool not found" -ForegroundColor Red
       }
   }
   ```

#### Issue: Authentication Service Unavailable

**Symptoms:**
- Error: "SafeID service is unavailable"
- Connection timeout errors
- Web interface inaccessible
- All authentication methods failing

**Diagnostic Steps:**

```powershell
# Service Availability Diagnostics
function Diagnose-ServiceAvailability {
    Write-Host "Diagnosing SafeID Service Availability" -ForegroundColor Cyan
    
    # Check all SafeID services
    $services = @("DellSafeIDService", "DellSafeIDBiometric", "DellSafeIDWeb", "DellSafeIDSync")
    $serviceStatus = @{}
    
    foreach ($serviceName in $services) {
        $service = Get-Service $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            $serviceStatus[$serviceName] = @{
                Status = $service.Status
                StartType = $service.StartType
                CanStop = $service.CanStop
                CanRestart = $service.CanStop
            }
            
            $color = if ($service.Status -eq "Running") { "Green" } else { "Red" }
            Write-Host "$serviceName : $($service.Status)" -ForegroundColor $color
        } else {
            Write-Host "$serviceName : NOT INSTALLED" -ForegroundColor Red
            $serviceStatus[$serviceName] = "NOT_INSTALLED"
        }
    }
    
    # Check network connectivity
    Write-Host "`nTesting network connectivity..." -ForegroundColor Yellow
    $endpoints = @(
        @{Name="SafeID Service"; Host="localhost"; Port=8443},
        @{Name="Web Interface"; Host="localhost"; Port=443}
    )
    
    foreach ($endpoint in $endpoints) {
        try {
            $connection = Test-NetConnection -ComputerName $endpoint.Host -Port $endpoint.Port -InformationLevel Quiet
            $status = if ($connection) { "ACCESSIBLE" } else { "BLOCKED" }
            $color = if ($connection) { "Green" } else { "Red" }
            Write-Host "$($endpoint.Name) ($($endpoint.Host):$($endpoint.Port)): $status" -ForegroundColor $color
        }
        catch {
            Write-Host "$($endpoint.Name): ERROR - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Check system resources
    Write-Host "`nSystem Resource Check..." -ForegroundColor Yellow
    $cpu = Get-Counter "\Processor(_Total)\% Processor Time" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
    $memory = Get-Counter "\Memory\Available MBytes" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
    $disk = Get-Counter "\LogicalDisk(C:)\% Free Space" | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
    
    Write-Host "CPU Usage: $([math]::Round($cpu, 1))%" -ForegroundColor $(if($cpu -lt 80){"Green"}else{"Red"})
    Write-Host "Available Memory: $([math]::Round($memory, 0)) MB" -ForegroundColor $(if($memory -gt 1000){"Green"}else{"Red"})
    Write-Host "Free Disk Space: $([math]::Round($disk, 1))%" -ForegroundColor $(if($disk -gt 10){"Green"}else{"Red"})
    
    return $serviceStatus
}
```

**Resolution Steps:**

1. **Service Recovery:**
   ```powershell
   # Systematic service restart
   function Restart-SafeIDServices {
       $services = @("DellSafeIDSync", "DellSafeIDWeb", "DellSafeIDBiometric", "DellSafeIDService")
       
       Write-Host "Stopping SafeID services..." -ForegroundColor Yellow
       foreach ($serviceName in $services) {
           try {
               Stop-Service $serviceName -Force -ErrorAction SilentlyContinue
               Write-Host "  Stopped: $serviceName" -ForegroundColor Gray
           }
           catch {
               Write-Host "  Failed to stop: $serviceName - $($_.Exception.Message)" -ForegroundColor Red
           }
       }
       
       Start-Sleep -Seconds 10
       
       Write-Host "Starting SafeID services..." -ForegroundColor Yellow
       [array]::Reverse($services)  # Start in reverse order
       foreach ($serviceName in $services) {
           try {
               Start-Service $serviceName
               Start-Sleep -Seconds 3
               $status = (Get-Service $serviceName).Status
               Write-Host "  Started: $serviceName ($status)" -ForegroundColor $(if($status -eq "Running"){"Green"}else{"Red"})
           }
           catch {
               Write-Host "  Failed to start: $serviceName - $($_.Exception.Message)" -ForegroundColor Red
           }
       }
   }
   ```

2. **Configuration Validation:**
   ```powershell
   # Validate configuration files
   function Test-SafeIDConfiguration {
       $configPath = "C:\Program Files\Dell\SafeID\Config\safeid-config.xml"
       
       if (-not (Test-Path $configPath)) {
           Write-Host "✗ Configuration file missing: $configPath" -ForegroundColor Red
           return $false
       }
       
       try {
           [xml]$config = Get-Content $configPath
           Write-Host "✓ Configuration file is valid XML" -ForegroundColor Green
           
           # Check required settings
           $requiredSettings = @(
               "ServiceSettings/ServicePort",
               "ServiceSettings/SSLEnabled",
               "SecuritySettings/EncryptionProvider"
           )
           
           foreach ($setting in $requiredSettings) {
               $node = $config.SelectSingleNode("/SafeIDConfiguration/$setting")
               if ($node) {
                   Write-Host "✓ $setting : $($node.InnerText)" -ForegroundColor Green
               } else {
                   Write-Host "✗ Missing setting: $setting" -ForegroundColor Red
               }
           }
           
           return $true
       }
       catch {
           Write-Host "✗ Configuration file is invalid: $($_.Exception.Message)" -ForegroundColor Red
           return $false
       }
   }
   ```

### Hardware Issues

#### Issue: TPM Not Available or Not Ready

**Symptoms:**
- Error: "TPM is not available"
- Hardware security features disabled
- ControlVault initialization failures
- Secure boot issues

**Diagnostic Steps:**

```powershell
# TPM Diagnostics
function Diagnose-TPMIssues {
    Write-Host "TPM Diagnostic Report" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    
    try {
        $tpm = Get-Tpm
        
        Write-Host "`nTPM Status:" -ForegroundColor Yellow
        Write-Host "  TPM Present: $($tpm.TpmPresent)" -ForegroundColor $(if($tpm.TmpPresent){"Green"}else{"Red"})
        Write-Host "  TPM Ready: $($tpm.TmpReady)" -ForegroundColor $(if($tpm.TmpReady){"Green"}else{"Red"})
        Write-Host "  TPM Enabled: $($tpm.TmpEnabled)" -ForegroundColor $(if($tpm.TmpEnabled){"Green"}else{"Red"})
        Write-Host "  TPM Activated: $($tpm.TmpActivated)" -ForegroundColor $(if($tpm.TmpActivated){"Green"}else{"Red"})
        Write-Host "  TPM Owned: $($tpm.TmpOwned)" -ForegroundColor $(if($tpm.TmpOwned){"Green"}else{"Red"})
        
        if ($tpm.ManufacturerIdTxt) {
            Write-Host "  Manufacturer: $($tpm.ManufacturerIdTxt)" -ForegroundColor Gray
        }
        
        if ($tpm.ManufacturerVersion) {
            Write-Host "  Version: $($tpm.ManufacturerVersion)" -ForegroundColor Gray
        }
        
        # Check TPM services
        Write-Host "`nTPM Services:" -ForegroundColor Yellow
        $tpmServices = @("TBS", "TPM")  # Trusted Platform Module services
        foreach ($serviceName in $tpmServices) {
            $service = Get-Service $serviceName -ErrorAction SilentlyContinue
            if ($service) {
                Write-Host "  $serviceName : $($service.Status)" -ForegroundColor $(if($service.Status -eq "Running"){"Green"}else{"Red"})
            } else {
                Write-Host "  $serviceName : NOT FOUND" -ForegroundColor Red
            }
        }
        
        # Check BitLocker status (TPM-related)
        Write-Host "`nBitLocker Status:" -ForegroundColor Yellow
        try {
            $bitlocker = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
            if ($bitlocker) {
                Write-Host "  Protection Status: $($bitlocker.ProtectionStatus)" -ForegroundColor Gray
                Write-Host "  Encryption Method: $($bitlocker.EncryptionMethod)" -ForegroundColor Gray
            } else {
                Write-Host "  BitLocker not configured" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  BitLocker status unavailable" -ForegroundColor Gray
        }
        
    }
    catch {
        Write-Host "✗ TPM not accessible: $($_.Exception.Message)" -ForegroundColor Red
        
        # Check if TPM is disabled in BIOS
        Write-Host "`nPossible causes:" -ForegroundColor Yellow
        Write-Host "  • TPM disabled in BIOS/UEFI settings" -ForegroundColor Red
        Write-Host "  • TPM not physically present" -ForegroundColor Red
        Write-Host "  • Driver issues" -ForegroundColor Red
        Write-Host "  • Windows TPM services not running" -ForegroundColor Red
    }
}
```

**Resolution Steps:**

1. **BIOS/UEFI Configuration:**
   ```
   Manual Steps - BIOS/UEFI Configuration:
   
   1. Restart computer and enter BIOS/UEFI setup (usually F2, F12, or Del key)
   2. Navigate to Security settings
   3. Look for TPM settings:
      • Enable TPM/Security Chip
      • Set TPM to "Available" or "Enabled"
      • Enable "TPM Activation"
      • Set TPM Specification to 2.0 (if available)
   4. Navigate to Boot settings:
      • Enable Secure Boot
      • Set Boot Mode to UEFI (not Legacy)
   5. Save changes and exit
   6. Boot to Windows and verify TPM status
   ```

2. **Windows TPM Configuration:**
   ```powershell
   # Initialize TPM in Windows
   function Initialize-TPM {
       Write-Host "Initializing TPM..." -ForegroundColor Cyan
       
       try {
           # Clear TPM if necessary (WARNING: This will clear all TPM data)
           $clearTPM = Read-Host "Clear TPM? This will remove all TPM data (y/N)"
           if ($clearTPM -eq 'y' -or $clearTPM -eq 'Y') {
               Clear-Tpm -Force
               Write-Host "TPM cleared. Restart required." -ForegroundColor Yellow
               return
           }
           
           # Initialize TPM
           Initialize-Tpm
           Write-Host "✓ TPM initialization completed" -ForegroundColor Green
           
           # Verify status
           $tpm = Get-Tpm
           Write-Host "TPM Ready: $($tpm.TmpReady)" -ForegroundColor $(if($tpm.TmpReady){"Green"}else{"Red"})
           
       }
       catch {
           Write-Host "✗ TPM initialization failed: $($_.Exception.Message)" -ForegroundColor Red
           Write-Host "Manual initialization may be required through TPM.msc" -ForegroundColor Yellow
       }
   }
   ```

#### Issue: Dell ControlVault Not Functioning

**Symptoms:**
- ControlVault device not detected
- Biometric operations failing
- Hardware security features unavailable
- Device Manager shows error status

**Diagnostic Steps:**

```powershell
# ControlVault Diagnostics
function Diagnose-ControlVault {
    Write-Host "Dell ControlVault Diagnostic Report" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    
    # Check ControlVault device in Device Manager
    Write-Host "`nControlVault Hardware Detection:" -ForegroundColor Yellow
    $controlVaultDevices = Get-PnpDevice | Where-Object {
        $_.HardwareID -like "*VID_413C*" -or 
        $_.FriendlyName -like "*ControlVault*" -or
        $_.Class -eq "SecurityDevices"
    }
    
    if ($controlVaultDevices) {
        foreach ($device in $controlVaultDevices) {
            $statusColor = switch ($device.Status) {
                "OK" { "Green" }
                "Error" { "Red" }
                "Unknown" { "Yellow" }
                default { "Gray" }
            }
            
            Write-Host "  Device: $($device.FriendlyName)" -ForegroundColor White
            Write-Host "    Status: $($device.Status)" -ForegroundColor $statusColor
            Write-Host "    Hardware ID: $($device.HardwareID)" -ForegroundColor Gray
            Write-Host "    Driver Date: $($device.DriverDate)" -ForegroundColor Gray
            Write-Host "    Driver Version: $($device.DriverVersion)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ✗ No ControlVault devices detected" -ForegroundColor Red
    }
    
    # Check ControlVault services
    Write-Host "`nControlVault Services:" -ForegroundColor Yellow
    $cvServices = Get-Service | Where-Object {$_.Name -like "*ControlVault*" -or $_.DisplayName -like "*ControlVault*"}
    
    if ($cvServices) {
        foreach ($service in $cvServices) {
            Write-Host "  $($service.DisplayName): $($service.Status)" -ForegroundColor $(if($service.Status -eq "Running"){"Green"}else{"Red"})
        }
    } else {
        Write-Host "  No specific ControlVault services found" -ForegroundColor Gray
    }
    
    # Check ControlVault functionality
    Write-Host "`nControlVault Functionality Test:" -ForegroundColor Yellow
    $cvTool = "C:\Program Files\Dell\SafeID\Tools\ControlVault.exe"
    if (Test-Path $cvTool) {
        try {
            $result = & $cvTool -status 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ ControlVault responding to status requests" -ForegroundColor Green
            } else {
                Write-Host "  ✗ ControlVault status check failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
                Write-Host "    Output: $result" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  ✗ Error running ControlVault tool: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ControlVault diagnostic tool not found" -ForegroundColor Yellow
    }
    
    # Check related hardware
    Write-Host "`nRelated Hardware:" -ForegroundColor Yellow
    $relatedDevices = Get-PnpDevice | Where-Object {
        $_.Class -eq "Biometric" -or 
        $_.Class -eq "SmartCardReader" -or
        ($_.FriendlyName -like "*fingerprint*") -or
        ($_.FriendlyName -like "*biometric*")
    }
    
    foreach ($device in $relatedDevices) {
        Write-Host "  $($device.FriendlyName): $($device.Status)" -ForegroundColor $(if($device.Status -eq "OK"){"Green"}else{"Red"})
    }
}
```

**Resolution Steps:**

1. **Driver Update/Reinstall:**
   ```powershell
   # ControlVault Driver Management
   function Update-ControlVaultDrivers {
       Write-Host "Updating ControlVault Drivers..." -ForegroundColor Cyan
       
       # Check for driver updates via Windows Update
       Write-Host "Checking Windows Update for driver updates..." -ForegroundColor Yellow
       try {
           # Install PSWindowsUpdate module if not present
           if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
               Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
           }
           
           Import-Module PSWindowsUpdate
           $driverUpdates = Get-WindowsUpdate -DriverOnly
           
           if ($driverUpdates) {
               Write-Host "Found $($driverUpdates.Count) driver updates" -ForegroundColor Green
               foreach ($update in $driverUpdates | Where-Object {$_.Title -like "*ControlVault*" -or $_.Title -like "*Dell*"}) {
                   Write-Host "  Available: $($update.Title)" -ForegroundColor Yellow
               }
           } else {
               Write-Host "No driver updates available via Windows Update" -ForegroundColor Gray
           }
       }
       catch {
           Write-Host "Windows Update check failed: $($_.Exception.Message)" -ForegroundColor Red
       }
       
       # Manual driver reinstall
       Write-Host "`nTo manually update ControlVault drivers:" -ForegroundColor Yellow
       Write-Host "1. Go to Dell Support website" -ForegroundColor White
       Write-Host "2. Enter your service tag or model number" -ForegroundColor White
       Write-Host "3. Download latest ControlVault drivers" -ForegroundColor White
       Write-Host "4. Run driver installer as Administrator" -ForegroundColor White
       Write-Host "5. Restart computer after installation" -ForegroundColor White
   }
   ```

2. **Hardware Reset:**
   ```powershell
   # ControlVault Reset Procedure
   function Reset-ControlVault {
       Write-Host "Resetting ControlVault Hardware..." -ForegroundColor Cyan
       
       $cvTool = "C:\Program Files\Dell\SafeID\Tools\ControlVault.exe"
       if (Test-Path $cvTool) {
           Write-Host "Attempting hardware reset..." -ForegroundColor Yellow
           
           try {
               & $cvTool -reset
               if ($LASTEXITCODE -eq 0) {
                   Write-Host "✓ ControlVault reset successful" -ForegroundColor Green
                   Write-Host "Please restart the computer to complete the reset" -ForegroundColor Yellow
               } else {
                   Write-Host "✗ ControlVault reset failed (Exit code: $LASTEXITCODE)" -ForegroundColor Red
               }
           }
           catch {
               Write-Host "✗ Error during reset: $($_.Exception.Message)" -ForegroundColor Red
           }
       } else {
           Write-Host "ControlVault tool not found - manual reset required" -ForegroundColor Yellow
           Write-Host "Manual reset steps:" -ForegroundColor White
           Write-Host "1. Power down computer completely" -ForegroundColor White
           Write-Host "2. Remove battery and AC adapter (laptops)" -ForegroundColor White
           Write-Host "3. Hold power button for 15 seconds" -ForegroundColor White
           Write-Host "4. Reconnect power and restart" -ForegroundColor White
       }
   }
   ```

### Network and Connectivity Issues

#### Issue: Certificate Errors

**Symptoms:**
- SSL certificate validation failures
- "Certificate not trusted" errors
- HTTPS connection failures
- Authentication service unreachable

**Diagnostic Steps:**

```powershell
# Certificate Diagnostics
function Diagnose-Certificates {
    Write-Host "Certificate Diagnostic Report" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    
    # Check SafeID certificates
    Write-Host "`nSafeID Certificates:" -ForegroundColor Yellow
    $safeidCerts = Get-ChildItem Cert:\LocalMachine\My | Where-Object {
        $_.Subject -like "*safeid*" -or 
        $_.Subject -like "*authentication*" -or
        $_.FriendlyName -like "*SafeID*"
    }
    
    if ($safeidCerts) {
        foreach ($cert in $safeidCerts) {
            $daysToExpiry = ($cert.NotAfter - (Get-Date)).Days
            $expiryColor = if ($daysToExpiry -gt 90) { "Green" } elseif ($daysToExpiry -gt 30) { "Yellow" } else { "Red" }
            
            Write-Host "  Certificate: $($cert.Subject)" -ForegroundColor White
            Write-Host "    Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
            Write-Host "    Issuer: $($cert.Issuer)" -ForegroundColor Gray
            Write-Host "    Valid From: $($cert.NotBefore)" -ForegroundColor Gray
            Write-Host "    Valid To: $($cert.NotAfter)" -ForegroundColor Gray
            Write-Host "    Days to Expiry: $daysToExpiry" -ForegroundColor $expiryColor
            Write-Host "    Has Private Key: $($cert.HasPrivateKey)" -ForegroundColor $(if($cert.HasPrivateKey){"Green"}else{"Red"})
            
            # Check certificate chain
            try {
                $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
                $chain.Build($cert)
                Write-Host "    Chain Status: Valid" -ForegroundColor Green
            }
            catch {
                Write-Host "    Chain Status: Invalid - $($_.Exception.Message)" -ForegroundColor Red
            }
            
            Write-Host ""
        }
    } else {
        Write-Host "  ✗ No SafeID certificates found in Local Machine store" -ForegroundColor Red
    }
    
    # Test certificate connectivity
    Write-Host "Certificate Connectivity Test:" -ForegroundColor Yellow
    $testUrls = @(
        "https://safeid.company.com:8443",
        "https://localhost:8443",
        "https://127.0.0.1:8443"
    )
    
    foreach ($url in $testUrls) {
        try {
            Write-Host "  Testing $url..." -ForegroundColor Gray
            $request = [System.Net.WebRequest]::Create($url)
            $request.Timeout = 10000
            $response = $request.GetResponse()
            $cert = $request.ServicePoint.Certificate
            
            if ($cert) {
                Write-Host "    ✓ SSL certificate valid" -ForegroundColor Green
                Write-Host "    Subject: $($cert.Subject)" -ForegroundColor Gray
                Write-Host "    Issuer: $($cert.Issuer)" -ForegroundColor Gray
            } else {
                Write-Host "    ✗ No SSL certificate returned" -ForegroundColor Red
            }
            
            $response.Close()
        }
        catch {
            Write-Host "    ✗ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
```

**Resolution Steps:**

1. **Certificate Installation:**
   ```powershell
   # Install SSL Certificate
   function Install-SafeIDCertificate {
       param(
           [string]$CertificatePath,
           [string]$CertificatePassword,
           [string]$StoreLocation = "LocalMachine",
           [string]$StoreName = "My"
       )
       
       Write-Host "Installing SafeID SSL Certificate..." -ForegroundColor Cyan
       
       if (-not (Test-Path $CertificatePath)) {
           Write-Host "✗ Certificate file not found: $CertificatePath" -ForegroundColor Red
           return
       }
       
       try {
           if ($CertificatePath.EndsWith(".pfx")) {
               # PFX certificate with private key
               $securePassword = ConvertTo-SecureString $CertificatePassword -AsPlainText -Force
               $cert = Import-PfxCertificate -FilePath $CertificatePath -CertStoreLocation "Cert:\$StoreLocation\$StoreName" -Password $securePassword
           } else {
               # CER/CRT certificate (public key only)
               $cert = Import-Certificate -FilePath $CertificatePath -CertStoreLocation "Cert:\$StoreLocation\$StoreName"
           }
           
           Write-Host "✓ Certificate installed successfully" -ForegroundColor Green
           Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
           Write-Host "  Subject: $($cert.Subject)" -ForegroundColor Gray
           
           # Update SafeID configuration
           $configPath = "C:\Program Files\Dell\SafeID\Config\safeid-config.xml"
           if (Test-Path $configPath) {
               Write-Host "Updating SafeID configuration..." -ForegroundColor Yellow
               [xml]$config = Get-Content $configPath
               $config.SafeIDConfiguration.ServiceSettings.CertificateThumbprint = $cert.Thumbprint
               $config.Save($configPath)
               Write-Host "✓ Configuration updated with new certificate thumbprint" -ForegroundColor Green
           }
           
       }
       catch {
           Write-Host "✗ Certificate installation failed: $($_.Exception.Message)" -ForegroundColor Red
       }
   }
   ```

2. **Certificate Renewal:**
   ```powershell
   # Certificate Renewal Process
   function Start-CertificateRenewal {
       Write-Host "Certificate Renewal Process" -ForegroundColor Cyan
       Write-Host "==========================" -ForegroundColor Cyan
       
       # Check expiring certificates
       $expiringCerts = Get-ChildItem Cert:\LocalMachine\My | Where-Object {
           ($_.Subject -like "*safeid*" -or $_.FriendlyName -like "*SafeID*") -and
           $_.NotAfter -lt (Get-Date).AddDays(60)
       }
       
       if ($expiringCerts) {
           Write-Host "Certificates expiring within 60 days:" -ForegroundColor Red
           foreach ($cert in $expiringCerts) {
               $daysToExpiry = ($cert.NotAfter - (Get-Date)).Days
               Write-Host "  $($cert.Subject): $daysToExpiry days" -ForegroundColor Yellow
           }
           
           Write-Host "`nRenewal Steps:" -ForegroundColor Yellow
           Write-Host "1. Contact Certificate Authority for renewal" -ForegroundColor White
           Write-Host "2. Generate new certificate request (CSR)" -ForegroundColor White
           Write-Host "3. Install new certificate using Install-SafeIDCertificate" -ForegroundColor White
           Write-Host "4. Update SafeID configuration" -ForegroundColor White
           Write-Host "5. Restart SafeID services" -ForegroundColor White
           Write-Host "6. Test connectivity" -ForegroundColor White
           
       } else {
           Write-Host "✓ No certificates expiring within 60 days" -ForegroundColor Green
       }
   }
   ```

### Database Issues

#### Issue: Database Connection Failures

**Symptoms:**
- "Database connection timeout" errors
- SafeID service fails to start
- User data not syncing
- Authentication history not recorded

**Diagnostic Steps:**

```powershell
# Database Diagnostics
function Diagnose-DatabaseConnectivity {
    Write-Host "Database Connectivity Diagnostic" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    
    # Get database connection string from config
    $configPath = "C:\Program Files\Dell\SafeID\Config\safeid-config.xml"
    if (Test-Path $configPath) {
        try {
            [xml]$config = Get-Content $configPath
            $connectionString = $config.SafeIDConfiguration.DatabaseSettings.ConnectionString
            Write-Host "Connection String: $connectionString" -ForegroundColor Gray
            
            # Parse connection string
            $connectionParts = @{}
            $connectionString.Split(';') | ForEach-Object {
                if ($_ -and $_.Contains('=')) {
                    $key, $value = $_.Split('=', 2)
                    $connectionParts[$key.Trim()] = $value.Trim()
                }
            }
            
            $server = $connectionParts["Server"] -or $connectionParts["Data Source"]
            $database = $connectionParts["Database"] -or $connectionParts["Initial Catalog"]
            
            Write-Host "Database Server: $server" -ForegroundColor Yellow
            Write-Host "Database Name: $database" -ForegroundColor Yellow
            
            # Test SQL Server connectivity
            if ($server -and $database) {
                Write-Host "`nTesting SQL Server connectivity..." -ForegroundColor Yellow
                
                try {
                    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
                    $connection.Open()
                    
                    Write-Host "✓ Database connection successful" -ForegroundColor Green
                    
                    # Test basic query
                    $command = $connection.CreateCommand()
                    $command.CommandText = "SELECT @@VERSION"
                    $version = $command.ExecuteScalar()
                    Write-Host "SQL Server Version: $($version.Split("`n")[0])" -ForegroundColor Gray
                    
                    # Check SafeID tables
                    $command.CommandText = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'SafeID%'"
                    $tableCount = $command.ExecuteScalar()
                    Write-Host "SafeID Tables: $tableCount" -ForegroundColor $(if($tableCount -gt 0){"Green"}else{"Red"})
                    
                    $connection.Close()
                }
                catch {
                    Write-Host "✗ Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
                    
                    # Additional diagnostics
                    Write-Host "`nAdditional Checks:" -ForegroundColor Yellow
                    
                    # Check if SQL Server service is running
                    $sqlServices = Get-Service | Where-Object {$_.DisplayName -like "*SQL Server*"}
                    foreach ($service in $sqlServices) {
                        Write-Host "  $($service.DisplayName): $($service.Status)" -ForegroundColor $(if($service.Status -eq "Running"){"Green"}else{"Red"})
                    }
                    
                    # Test network connectivity to server
                    if ($server -ne "localhost" -and $server -ne "127.0.0.1" -and $server -ne ".") {
                        $pingResult = Test-Connection -ComputerName $server -Count 1 -Quiet
                        Write-Host "  Network connectivity to $server : $(if($pingResult){'OK'}else{'FAILED'})" -ForegroundColor $(if($pingResult){"Green"}else{"Red"})
                        
                        # Test SQL Server port (default 1433)
                        $portTest = Test-NetConnection -ComputerName $server -Port 1433 -InformationLevel Quiet
                        Write-Host "  SQL Server port (1433) accessible: $(if($portTest){'Yes'}else{'No'})" -ForegroundColor $(if($portTest){"Green"}else{"Red"})
                    }
                }
            }
            
        }
        catch {
            Write-Host "✗ Error reading configuration: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ SafeID configuration file not found" -ForegroundColor Red
    }
}
```

**Resolution Steps:**

1. **Database Service Recovery:**
   ```powershell
   # SQL Server Service Recovery
   function Restart-SQLServerServices {
       Write-Host "Restarting SQL Server Services..." -ForegroundColor Cyan
       
       $sqlServices = @(
           "MSSQLSERVER",      # Default SQL Server instance
           "SQLSERVERAGENT",   # SQL Server Agent
           "MSSQLServerOLAPService", # Analysis Services (if installed)
           "SQLBrowser"        # SQL Server Browser
       )
       
       foreach ($serviceName in $sqlServices) {
           $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
           if ($service) {
               Write-Host "Processing service: $($service.DisplayName)" -ForegroundColor Yellow
               
               try {
                   if ($service.Status -eq "Running") {
                       Restart-Service -Name $serviceName -Force
                       Write-Host "  ✓ Service restarted" -ForegroundColor Green
                   } else {
                       Start-Service -Name $serviceName
                       Write-Host "  ✓ Service started" -ForegroundColor Green
                   }
               }
               catch {
                   Write-Host "  ✗ Failed to restart service: $($_.Exception.Message)" -ForegroundColor Red
               }
           } else {
               Write-Host "Service not found: $serviceName" -ForegroundColor Gray
           }
       }
       
       # Wait for services to stabilize
       Start-Sleep -Seconds 10
       
       # Verify service status
       Write-Host "`nService Status Verification:" -ForegroundColor Yellow
       foreach ($serviceName in $sqlServices) {
           $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
           if ($service) {
               Write-Host "  $($service.DisplayName): $($service.Status)" -ForegroundColor $(if($service.Status -eq "Running"){"Green"}else{"Red"})
           }
       }
   }
   ```

2. **Database Maintenance:**
   ```powershell
   # Database Maintenance Operations
   function Start-SafeIDDatabaseMaintenance {
       param([string]$ConnectionString)
       
       Write-Host "SafeID Database Maintenance" -ForegroundColor Cyan
       Write-Host "==========================" -ForegroundColor Cyan
       
       try {
           $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
           $connection.Open()
           
           # Check database integrity
           Write-Host "Checking database integrity..." -ForegroundColor Yellow
           $command = $connection.CreateCommand()
           $command.CommandText = "DBCC CHECKDB WITH NO_INFOMSGS"
           $command.CommandTimeout = 300  # 5 minutes
           $command.ExecuteNonQuery()
           Write-Host "✓ Database integrity check completed" -ForegroundColor Green
           
           # Update statistics
           Write-Host "Updating database statistics..." -ForegroundColor Yellow
           $command.CommandText = "EXEC sp_updatestats"
           $command.ExecuteNonQuery()
           Write-Host "✓ Statistics updated" -ForegroundColor Green
           
           # Rebuild indexes
           Write-Host "Rebuilding indexes..." -ForegroundColor Yellow
           $command.CommandText = @"
               DECLARE @sql NVARCHAR(MAX) = '';
               SELECT @sql = @sql + 'ALTER INDEX ALL ON ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ' REBUILD;' + CHAR(13)
               FROM sys.tables WHERE name LIKE 'SafeID%';
               EXEC sp_executesql @sql;
"@
           $command.ExecuteNonQuery()
           Write-Host "✓ Indexes rebuilt" -ForegroundColor Green
           
           # Clean up old log entries (older than 90 days)
           Write-Host "Cleaning up old log entries..." -ForegroundColor Yellow
           $command.CommandText = "DELETE FROM SafeID_AuthenticationLog WHERE LogDate < DATEADD(DAY, -90, GETDATE())"
           $rowsAffected = $command.ExecuteNonQuery()
           Write-Host "✓ Cleaned up $rowsAffected old log entries" -ForegroundColor Green
           
           $connection.Close()
           Write-Host "Database maintenance completed successfully" -ForegroundColor Green
           
       }
       catch {
           Write-Host "✗ Database maintenance failed: $($_.Exception.Message)" -ForegroundColor Red
       }
   }
   ```

## Performance Issues

### Slow Authentication Response

**Symptoms:**
- Authentication takes longer than 5 seconds
- Biometric matching delays
- System appears unresponsive during authentication

**Diagnostic Steps:**

```powershell
# Performance Diagnostics
function Diagnose-AuthenticationPerformance {
    Write-Host "Authentication Performance Diagnostic" -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    
    # System resource utilization
    Write-Host "`nSystem Resource Utilization:" -ForegroundColor Yellow
    
    # CPU usage
    $cpu = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 5 | 
           Select-Object -ExpandProperty CounterSamples | 
           Measure-Object -Property CookedValue -Average
    Write-Host "  Average CPU Usage: $([math]::Round($cpu.Average, 1))%" -ForegroundColor $(if($cpu.Average -lt 80){"Green"}else{"Red"})
    
    # Memory usage
    $totalMemory = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB
    $availableMemory = (Get-Counter "\Memory\Available MBytes").CounterSamples[0].CookedValue / 1024
    $usedMemory = $totalMemory - $availableMemory
    $memoryPercent = ($usedMemory / $totalMemory) * 100
    
    Write-Host "  Memory Usage: $([math]::Round($memoryPercent, 1))% ($([math]::Round($usedMemory, 1))GB / $([math]::Round($totalMemory, 1))GB)" -ForegroundColor $(if($memoryPercent -lt 80){"Green"}else{"Red"})
    
    # Disk performance
    $diskReads = (Get-Counter "\LogicalDisk(C:)\Disk Reads/sec").CounterSamples[0].CookedValue
    $diskWrites = (Get-Counter "\LogicalDisk(C:)\Disk Writes/sec").CounterSamples[0].CookedValue
    $diskQueue = (Get-Counter "\LogicalDisk(C:)\Current Disk Queue Length").CounterSamples[0].CookedValue
    
    Write-Host "  Disk Activity: $([math]::Round($diskReads, 1)) reads/sec, $([math]::Round($diskWrites, 1)) writes/sec" -ForegroundColor Gray
    Write-Host "  Disk Queue Length: $([math]::Round($diskQueue, 1))" -ForegroundColor $(if($diskQueue -lt 2){"Green"}else{"Red"})
    
    # SafeID service performance
    Write-Host "`nSafeID Service Performance:" -ForegroundColor Yellow
    $safeidProcesses = Get-Process | Where-Object {$_.ProcessName -like "*SafeID*"}
    
    if ($safeidProcesses) {
        foreach ($process in $safeidProcesses) {
            $cpuUsage = $process.CPU
            $memoryUsage = $process.WorkingSet64 / 1MB
            
            Write-Host "  Process: $($process.ProcessName)" -ForegroundColor White
            Write-Host "    CPU Time: $([math]::Round($cpuUsage, 1)) seconds" -ForegroundColor Gray
            Write-Host "    Memory Usage: $([math]::Round($memoryUsage, 1)) MB" -ForegroundColor $(if($memoryUsage -lt 500){"Green"}else{"Yellow"})
            Write-Host "    Threads: $($process.Threads.Count)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No SafeID processes found" -ForegroundColor Red
    }
    
    # Database performance
    Write-Host "`nDatabase Performance Check:" -ForegroundColor Yellow
    $configPath = "C:\Program Files\Dell\SafeID\Config\safeid-config.xml"
    if (Test-Path $configPath) {
        try {
            [xml]$config = Get-Content $configPath
            $connectionString = $config.SafeIDConfiguration.DatabaseSettings.ConnectionString
            
            $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
            $connection.Open()
            
            # Test query performance
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT COUNT(*) FROM SafeID_Users"
            $userCount = $command.ExecuteScalar()
            $stopwatch.Stop()
            
            Write-Host "  User count query: $($stopwatch.ElapsedMilliseconds)ms ($userCount users)" -ForegroundColor $(if($stopwatch.ElapsedMilliseconds -lt 1000){"Green"}else{"Red"})
            
            # Check for blocking processes
            $command.CommandText = "SELECT COUNT(*) FROM sys.dm_exec_requests WHERE blocking_session_id > 0"
            $blockingCount = $command.ExecuteScalar()
            Write-Host "  Blocking processes: $blockingCount" -ForegroundColor $(if($blockingCount -eq 0){"Green"}else{"Red"})
            
            $connection.Close()
        }
        catch {
            Write-Host "  Database performance check failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
```

**Resolution Steps:**

```powershell
# Performance Optimization
function Optimize-SafeIDPerformance {
    Write-Host "SafeID Performance Optimization" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    
    # 1. Service Priority Optimization
    Write-Host "`n1. Optimizing service priorities..." -ForegroundColor Yellow
    $safeidProcesses = Get-Process | Where-Object {$_.ProcessName -like "*SafeID*"}
    foreach ($process in $safeidProcesses) {
        try {
            $process.PriorityClass = "High"
            Write-Host "  ✓ Set $($process.ProcessName) priority to High" -ForegroundColor Green
        }
        catch {
            Write-Host "  ✗ Failed to set priority for $($process.ProcessName)" -ForegroundColor Red
        }
    }
    
    # 2. Memory Optimization
    Write-Host "`n2. Memory optimization..." -ForegroundColor Yellow
    try {
        # Clear standby memory
        $standbyMemory = (Get-Counter "\Memory\Standby Cache Reserve Bytes").CounterSamples[0].CookedValue / 1MB
        Write-Host "  Standby cache: $([math]::Round($standbyMemory, 1)) MB" -ForegroundColor Gray
        
        # Suggest memory optimization
        if ($standbyMemory -gt 1000) {
            Write-Host "  Consider clearing standby memory cache" -ForegroundColor Yellow
        }
        
        Write-Host "  ✓ Memory optimization checks completed" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Memory optimization failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 3. Disk I/O Optimization
    Write-Host "`n3. Disk I/O optimization..." -ForegroundColor Yellow
    try {
        # Check if SafeID data is on SSD
        $safeidPath = "C:\Program Files\Dell\SafeID"
        $volume = Get-Volume -FilePath $safeidPath
        $disk = Get-PhysicalDisk | Where-Object {$_.DeviceId -eq $volume.DriveLetter}
        
        if ($disk.MediaType -eq "SSD") {
            Write-Host "  ✓ SafeID is on SSD - optimal performance" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ SafeID is on HDD - consider moving to SSD" -ForegroundColor Yellow
        }
        
        # Enable TRIM for SSD (if applicable)
        if ($disk.MediaType -eq "SSD") {
            fsutil behavior query DisableDeleteNotify | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✓ TRIM is enabled for SSD" -ForegroundColor Green
            }
        }
        
    }
    catch {
        Write-Host "  ✗ Disk optimization check failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 4. Database Optimization
    Write-Host "`n4. Database optimization..." -ForegroundColor Yellow
    $configPath = "C:\Program Files\Dell\SafeID\Config\safeid-config.xml"
    if (Test-Path $configPath) {
        try {
            [xml]$config = Get-Content $configPath
            $connectionString = $config.SafeIDConfiguration.DatabaseSettings.ConnectionString
            
            $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
            $connection.Open()
            
            # Update statistics for better query performance
            $command = $connection.CreateCommand()
            $command.CommandText = "EXEC sp_updatestats"
            $command.ExecuteNonQuery()
            Write-Host "  ✓ Database statistics updated" -ForegroundColor Green
            
            # Check for index fragmentation
            $command.CommandText = @"
                SELECT 
                    OBJECT_NAME(ips.object_id) AS TableName,
                    si.name AS IndexName,
                    ips.avg_fragmentation_in_percent
                FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
                INNER JOIN sys.indexes si ON ips.object_id = si.object_id AND ips.index_id = si.index_id
                WHERE ips.avg_fragmentation_in_percent > 30 
                AND OBJECT_NAME(ips.object_id) LIKE 'SafeID%'
"@
            
            $reader = $command.ExecuteReader()
            $fragmentedIndexes = @()
            while ($reader.Read()) {
                $fragmentedIndexes += @{
                    Table = $reader["TableName"]
                    Index = $reader["IndexName"] 
                    Fragmentation = $reader["avg_fragmentation_in_percent"]
                }
            }
            $reader.Close()
            
            if ($fragmentedIndexes.Count -gt 0) {
                Write-Host "  ⚠ Found $($fragmentedIndexes.Count) fragmented indexes" -ForegroundColor Yellow
                foreach ($index in $fragmentedIndexes) {
                    Write-Host "    $($index.Table).$($index.Index): $([math]::Round($index.Fragmentation, 1))% fragmented" -ForegroundColor Gray
                }
            } else {
                Write-Host "  ✓ No significant index fragmentation found" -ForegroundColor Green
            }
            
            $connection.Close()
        }
        catch {
            Write-Host "  ✗ Database optimization failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`nPerformance optimization completed!" -ForegroundColor Green
    Write-Host "Restart SafeID services to apply all optimizations." -ForegroundColor Yellow
}
```

## Escalation Procedures

### Escalation Matrix

| Issue Severity | First Response | Escalation Level 1 | Escalation Level 2 | Escalation Level 3 |
|---------------|----------------|-------------------|-------------------|-------------------|
| **Critical** | Help Desk (15 min) | System Admin (1 hour) | SafeID Specialist (2 hours) | Dell Support (4 hours) |
| **High** | Help Desk (1 hour) | System Admin (4 hours) | SafeID Specialist (1 day) | Dell Support (2 days) |
| **Medium** | Help Desk (4 hours) | System Admin (1 day) | SafeID Specialist (3 days) | Dell Support (1 week) |
| **Low** | Help Desk (1 day) | System Admin (3 days) | SafeID Specialist (1 week) | Dell Support (2 weeks) |

### Support Information Collection

```powershell
# Support Information Collector
function Collect-SafeIDSupportInfo {
    param([string]$OutputPath = "C:\Temp\SafeID-Support-Info.zip")
    
    Write-Host "Collecting SafeID Support Information..." -ForegroundColor Cyan
    
    $tempDir = "C:\Temp\SafeID-Support-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # System Information
    Write-Host "  Collecting system information..." -ForegroundColor Yellow
    Get-ComputerInfo | Out-File "$tempDir\system-info.txt"
    Get-Service | Where-Object {$_.Name -like "*SafeID*" -or $_.Name -like "*Dell*"} | Format-Table | Out-File "$tempDir\services.txt"
    Get-Process | Where-Object {$_.ProcessName -like "*SafeID*"} | Format-Table | Out-File "$tempDir\processes.txt"
    
    # Hardware Information
    Write-Host "  Collecting hardware information..." -ForegroundColor Yellow
    Get-PnpDevice | Where-Object {$_.Class -eq "Biometric" -or $_.Class -eq "SecurityDevices"} | Format-Table | Out-File "$tempDir\hardware.txt"
    try { Get-Tpm | Out-File "$tempDir\tpm-status.txt" } catch { "TPM not accessible" | Out-File "$tempDir\tpm-status.txt" }
    
    # Event Logs
    Write-Host "  Collecting event logs..." -ForegroundColor Yellow
    Get-EventLog -LogName Application -Source "*SafeID*" -Newest 100 -ErrorAction SilentlyContinue | Export-Csv "$tempDir\application-events.csv" -NoTypeInformation
    Get-EventLog -LogName System -Newest 100 -ErrorAction SilentlyContinue | Where-Object {$_.Source -like "*SafeID*" -or $_.Source -like "*Dell*"} | Export-Csv "$tempDir\system-events.csv" -NoTypeInformation
    
    # Configuration Files
    Write-Host "  Collecting configuration files..." -ForegroundColor Yellow
    $configPath = "C:\Program Files\Dell\SafeID\Config"
    if (Test-Path $configPath) {
        Copy-Item "$configPath\*" "$tempDir\Config\" -Recurse -Force -ErrorAction SilentlyContinue
        # Remove sensitive information from copied config files
        Get-ChildItem "$tempDir\Config\" -Filter "*.xml" | ForEach-Object {
            $content = Get-Content $_.FullName
            $content = $content -replace "password=[^;]*", "password=***REDACTED***"
            $content = $content -replace "<Password>.*</Password>", "<Password>***REDACTED***</Password>"
            $content | Set-Content $_.FullName
        }
    }
    
    # Log Files
    Write-Host "  Collecting log files..." -ForegroundColor Yellow
    $logPath = "C:\Program Files\Dell\SafeID\Logs"
    if (Test-Path $logPath) {
        Copy-Item "$logPath\*" "$tempDir\Logs\" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Registry Information
    Write-Host "  Collecting registry information..." -ForegroundColor Yellow
    try {
        reg export "HKLM\SOFTWARE\Dell\SafeID" "$tempDir\registry-safeid.reg" 2>$null
        reg export "HKLM\SYSTEM\CurrentControlSet\Services\DellSafeIDService" "$tempDir\registry-service.reg" 2>$null
    } catch {
        "Registry export failed" | Out-File "$tempDir\registry-error.txt"
    }
    
    # Create summary report
    Write-Host "  Creating summary report..." -ForegroundColor Yellow
    $summary = @"
SafeID Support Information Summary
Generated: $(Get-Date)
Computer: $env:COMPUTERNAME
User: $env:USERNAME

System Information:
- OS Version: $((Get-WmiObject Win32_OperatingSystem).Caption)
- PowerShell Version: $($PSVersionTable.PSVersion)
- .NET Version: $((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" -Name Release -ErrorAction SilentlyContinue).Release)

SafeID Services Status:
$((Get-Service | Where-Object {$_.Name -like "*SafeID*"} | ForEach-Object { "- $($_.DisplayName): $($_.Status)" }) -join "`n")

Hardware Status:
- TPM: $(try { (Get-Tpm).TmpReady } catch { "Not accessible" })
- Biometric Devices: $((Get-PnpDevice | Where-Object {$_.Class -eq "Biometric" -and $_.Status -eq "OK"}).Count)

Recent Errors:
$((Get-EventLog -LogName Application -Source "*SafeID*" -EntryType Error -Newest 5 -ErrorAction SilentlyContinue | ForEach-Object { "- $($_.TimeGenerated): $($_.Message.Substring(0, [Math]::Min(100, $_.Message.Length)))" }) -join "`n")
"@
    
    $summary | Out-File "$tempDir\summary.txt"
    
    # Create ZIP file
    Write-Host "  Creating support package..." -ForegroundColor Yellow
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $OutputPath)
        Write-Host "✓ Support information collected: $OutputPath" -ForegroundColor Green
        
        # Clean up temp directory
        Remove-Item $tempDir -Recurse -Force
    }
    catch {
        Write-Host "✗ Failed to create support package: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Support files available in: $tempDir" -ForegroundColor Yellow
    }
}
```

## Preventive Maintenance

### Regular Maintenance Tasks

```powershell
# Preventive Maintenance Schedule
$MaintenanceTasks = @{
    "Daily" = @(
        "Check service status",
        "Monitor system resources",
        "Review error logs",
        "Verify backup completion"
    )
    "Weekly" = @(
        "Update statistics and rebuild indexes",
        "Clean temporary files",
        "Check certificate expiration",
        "Review performance metrics",
        "Test authentication flows"
    )
    "Monthly" = @(
        "Full system backup",
        "Update drivers and firmware",
        "Security patch assessment",
        "Capacity planning review",
        "User access audit"
    )
    "Quarterly" = @(
        "Disaster recovery testing",
        "Security assessment",
        "Performance optimization",
        "Documentation review",
        "Training refresh"
    )
}

# Automated maintenance script
function Start-SafeIDMaintenance {
    param([ValidateSet("Daily","Weekly","Monthly","Quarterly")]$MaintenanceType = "Daily")
    
    Write-Host "SafeID $MaintenanceType Maintenance" -ForegroundColor Cyan
    Write-Host "=" * (20 + $MaintenanceType.Length) -ForegroundColor Cyan
    
    $tasks = $MaintenanceTasks[$MaintenanceType]
    
    foreach ($task in $tasks) {
        Write-Host "`nExecuting: $task" -ForegroundColor Yellow
        
        switch -Wildcard ($task) {
            "*service status*" {
                $services = @("DellSafeIDService", "DellSafeIDBiometric", "DellSafeIDWeb")
                foreach ($service in $services) {
                    $status = (Get-Service $service -ErrorAction SilentlyContinue).Status
                    Write-Host "  $service : $status" -ForegroundColor $(if($status -eq "Running"){"Green"}else{"Red"})
                }
            }
            "*system resources*" {
                $cpu = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples[0].CookedValue
                $memory = (Get-Counter "\Memory\% Committed Bytes In Use").CounterSamples[0].CookedValue
                Write-Host "  CPU: $([math]::Round($cpu, 1))%" -ForegroundColor $(if($cpu -lt 80){"Green"}else{"Red"})
                Write-Host "  Memory: $([math]::Round($memory, 1))%" -ForegroundColor $(if($memory -lt 80){"Green"}else{"Red"})
            }
            "*error logs*" {
                $errors = Get-EventLog -LogName Application -Source "*SafeID*" -EntryType Error -Newest 10 -ErrorAction SilentlyContinue
                Write-Host "  Recent errors: $($errors.Count)" -ForegroundColor $(if($errors.Count -eq 0){"Green"}else{"Red"})
            }
            "*certificate*" {
                $certs = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -like "*safeid*"}
                foreach ($cert in $certs) {
                    $daysToExpiry = ($cert.NotAfter - (Get-Date)).Days
                    Write-Host "  Certificate expires in $daysToExpiry days" -ForegroundColor $(if($daysToExpiry -gt 90){"Green"}elseif($daysToExpiry -gt 30){"Yellow"}else{"Red"})
                }
            }
            default {
                Write-Host "  Manual task - see maintenance procedures" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host "`n$MaintenanceType maintenance completed!" -ForegroundColor Green
}
```

---

**Troubleshooting Guide Version**: 1.0  
**Last Updated**: November 2024  
**Next Review**: February 2025  
**Supported SafeID Versions**: 3.0+  
**Support Contact**: safeid-support@company.com
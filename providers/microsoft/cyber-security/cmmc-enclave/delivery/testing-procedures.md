# Microsoft CMMC Enclave - Testing Procedures

This document provides comprehensive testing procedures for validating the Microsoft CMMC Enclave solution. These procedures ensure that all components function correctly, meet CMMC Level 2 requirements, and maintain security and compliance standards throughout the system lifecycle.

## Overview

Testing is organized into multiple categories:
- **Unit Testing**: Individual component validation
- **Integration Testing**: Inter-component communication and workflow validation
- **Security Testing**: Security control validation and penetration testing
- **Compliance Testing**: CMMC Level 2 control validation
- **Performance Testing**: System performance and scalability validation
- **Disaster Recovery Testing**: Business continuity validation
- **User Acceptance Testing**: End-user functionality validation

## Pre-Testing Requirements

### Test Environment Setup
- [ ] Dedicated test environment provisioned
- [ ] Test data created and classified
- [ ] Test user accounts configured
- [ ] Network isolation implemented
- [ ] Monitoring and logging enabled

### Test Tools and Scripts
- [ ] Azure CLI and PowerShell modules installed
- [ ] Testing scripts downloaded and configured
- [ ] Security testing tools available
- [ ] Performance testing tools installed
- [ ] Documentation templates prepared

## Unit Testing

### Azure Infrastructure Components

#### Virtual Network Testing
**Objective**: Validate network infrastructure and connectivity

**Test Cases**:
1. **Subnet Configuration Validation**
   ```bash
   #!/bin/bash
   # Test: Verify subnet configurations match requirements
   
   echo "Testing Virtual Network Configuration..."
   
   # Get VNet details
   az network vnet show --name cmmc-vnet --resource-group cmmc-test-rg --query '{name:name, addressSpace:addressSpace.addressPrefixes}'
   
   # Validate each subnet
   subnets=("management" "workload" "data" "bastion")
   for subnet in "${subnets[@]}"; do
       echo "Checking subnet: $subnet"
       az network vnet subnet show --vnet-name cmmc-vnet --name $subnet --resource-group cmmc-test-rg --query '{name:name, addressPrefix:addressPrefix}'
   done
   
   # Expected Results:
   # - Management subnet: 10.200.1.0/24
   # - Workload subnet: 10.200.2.0/24  
   # - Data subnet: 10.200.3.0/24
   # - Bastion subnet: 10.200.5.0/24
   ```

2. **Network Security Group Rules Testing**
   ```bash
   #!/bin/bash
   # Test: Verify NSG rules implement least privilege
   
   echo "Testing Network Security Group Rules..."
   
   # Check management NSG rules
   az network nsg rule list --nsg-name management-nsg --resource-group cmmc-test-rg --query '[].{name:name, access:access, direction:direction, priority:priority}'
   
   # Validate key security rules exist
   rules=("AllowHTTPS" "AllowSSH" "AllowRDP" "DenyAllInbound")
   for rule in "${rules[@]}"; do
       rule_exists=$(az network nsg rule show --nsg-name management-nsg --name $rule --resource-group cmmc-test-rg --query 'name' -o tsv 2>/dev/null)
       if [ "$rule_exists" = "$rule" ]; then
           echo "✓ Rule $rule exists"
       else
           echo "✗ Rule $rule missing"
       fi
   done
   ```

#### Key Vault Testing
**Objective**: Validate Key Vault configuration and access

**Test Cases**:
1. **Key Vault Access Policies**
   ```powershell
   # Test: Verify Key Vault access policies and HSM configuration
   
   Write-Host "Testing Key Vault Configuration..." -ForegroundColor Green
   
   # Connect to Azure Government
   Connect-AzAccount -Environment AzureUSGovernment
   
   # Test Key Vault properties
   $keyVault = Get-AzKeyVault -VaultName "cmmc-test-vault" -ResourceGroupName "cmmc-test-rg"
   
   # Validate HSM backing
   if ($keyVault.Sku -eq "Premium") {
       Write-Host "✓ Key Vault uses Premium SKU (HSM supported)" -ForegroundColor Green
   } else {
       Write-Host "✗ Key Vault should use Premium SKU for HSM support" -ForegroundColor Red
   }
   
   # Test purge protection
   if ($keyVault.EnablePurgeProtection) {
       Write-Host "✓ Purge protection enabled" -ForegroundColor Green
   } else {
       Write-Host "✗ Purge protection should be enabled" -ForegroundColor Red
   }
   
   # Test soft delete
   if ($keyVault.EnableSoftDelete) {
       Write-Host "✓ Soft delete enabled" -ForegroundColor Green
   } else {
       Write-Host "✗ Soft delete should be enabled" -ForegroundColor Red
   }
   ```

2. **Key Operations Testing**
   ```powershell
   # Test: Validate key operations and encryption
   
   Write-Host "Testing Key Operations..." -ForegroundColor Green
   
   # Create test key
   $testKey = Add-AzKeyVaultKey -VaultName "cmmc-test-vault" -Name "test-encryption-key" -Destination "HSM" -KeyType "RSA" -Size 2048
   
   if ($testKey) {
       Write-Host "✓ HSM-backed key created successfully" -ForegroundColor Green
       
       # Test encryption operation
       $plainText = "This is a test message for CMMC compliance"
       $encryptedData = [System.Text.Encoding]::UTF8.GetBytes($plainText)
       
       # Cleanup test key
       Remove-AzKeyVaultKey -VaultName "cmmc-test-vault" -Name "test-encryption-key" -Force
   } else {
       Write-Host "✗ Failed to create HSM-backed key" -ForegroundColor Red
   }
   ```

### Identity and Access Management Testing

#### Azure Active Directory Testing
**Objective**: Validate identity controls and policies

**Test Cases**:
1. **Conditional Access Policy Testing**
   ```powershell
   # Test: Verify Conditional Access policies are configured correctly
   
   Write-Host "Testing Conditional Access Policies..." -ForegroundColor Green
   
   # Connect to Azure AD
   Connect-AzureAD -AzureEnvironmentName AzureUSGovernment
   
   # Get MFA policy
   $mfaPolicy = Get-AzureADMSConditionalAccessPolicy | Where-Object {$_.DisplayName -like "*MFA*"}
   
   if ($mfaPolicy) {
       Write-Host "✓ MFA Conditional Access policy found: $($mfaPolicy.DisplayName)" -ForegroundColor Green
       
       # Check if policy is enabled
       if ($mfaPolicy.State -eq "enabled") {
           Write-Host "✓ MFA policy is enabled" -ForegroundColor Green
       } else {
           Write-Host "✗ MFA policy should be enabled" -ForegroundColor Red
       }
       
       # Check MFA requirement
       $grantControls = $mfaPolicy.GrantControls.BuiltInControls
       if ($grantControls -contains "mfa") {
           Write-Host "✓ Policy requires MFA" -ForegroundColor Green
       } else {
           Write-Host "✗ Policy should require MFA" -ForegroundColor Red
       }
   } else {
       Write-Host "✗ No MFA Conditional Access policy found" -ForegroundColor Red
   }
   ```

2. **Privileged Identity Management Testing**
   ```powershell
   # Test: Validate PIM configuration
   
   Write-Host "Testing Privileged Identity Management..." -ForegroundColor Green
   
   # Check PIM role settings
   $roleSettings = Get-AzureADMSPrivilegedRoleSetting | Where-Object {$_.RoleDefinitionId -eq "62e90394-69f5-4237-9190-012177145e10"} # Global Admin role
   
   if ($roleSettings) {
       Write-Host "✓ PIM role settings configured for Global Administrator" -ForegroundColor Green
       
       # Parse role settings to check activation requirements
       $settings = $roleSettings.UserMemberSettings | ConvertFrom-Json
       if ($settings.MaximumActivationDuration -le "PT8H") {
           Write-Host "✓ Maximum activation duration is 8 hours or less" -ForegroundColor Green
       } else {
           Write-Host "✗ Maximum activation duration should be 8 hours or less" -ForegroundColor Red
       }
   } else {
       Write-Host "✗ No PIM settings found for Global Administrator role" -ForegroundColor Red
   }
   ```

## Integration Testing

### Service Integration Testing

#### Microsoft 365 Integration
**Objective**: Validate integration between Azure AD and Microsoft 365 services

**Test Cases**:
1. **Single Sign-On Testing**
   ```powershell
   # Test: Verify SSO between Azure AD and Microsoft 365
   
   Write-Host "Testing Single Sign-On Integration..." -ForegroundColor Green
   
   # Test user authentication
   $testUser = "testuser@tenant.onmicrosoft.us"
   
   # Check user in Azure AD
   $azureAdUser = Get-AzureADUser -ObjectId $testUser -ErrorAction SilentlyContinue
   
   if ($azureAdUser) {
       Write-Host "✓ Test user exists in Azure AD" -ForegroundColor Green
       
       # Connect to Exchange Online to test SSO
       try {
           Connect-ExchangeOnline -UserPrincipalName $testUser -ShowBanner:$false
           Write-Host "✓ SSO to Exchange Online successful" -ForegroundColor Green
           Disconnect-ExchangeOnline -Confirm:$false
       } catch {
           Write-Host "✗ SSO to Exchange Online failed: $($_.Exception.Message)" -ForegroundColor Red
       }
   } else {
       Write-Host "✗ Test user not found in Azure AD" -ForegroundColor Red
   }
   ```

2. **Data Loss Prevention Integration**
   ```powershell
   # Test: Validate DLP policies work across services
   
   Write-Host "Testing DLP Integration..." -ForegroundColor Green
   
   # Connect to Security & Compliance Center
   Connect-IPPSSession -UserPrincipalName admin@tenant.onmicrosoft.us
   
   # Check CUI protection policy
   $cuiPolicy = Get-DlpCompliancePolicy -Identity "CUI-Protection" -ErrorAction SilentlyContinue
   
   if ($cuiPolicy) {
       Write-Host "✓ CUI protection DLP policy found" -ForegroundColor Green
       
       # Check policy locations
       $locations = @($cuiPolicy.ExchangeLocation, $cuiPolicy.SharePointLocation, $cuiPolicy.TeamsLocation)
       $activeLocations = $locations | Where-Object {$_ -ne $null -and $_ -ne ""}
       
       if ($activeLocations.Count -ge 3) {
           Write-Host "✓ DLP policy covers Exchange, SharePoint, and Teams" -ForegroundColor Green
       } else {
           Write-Host "✗ DLP policy should cover Exchange, SharePoint, and Teams" -ForegroundColor Red
       }
   } else {
       Write-Host "✗ CUI protection DLP policy not found" -ForegroundColor Red
   }
   ```

#### Azure Sentinel Integration
**Objective**: Validate security monitoring integration

**Test Cases**:
1. **Data Connector Testing**
   ```bash
   #!/bin/bash
   # Test: Verify data connectors are functioning
   
   echo "Testing Azure Sentinel Data Connectors..."
   
   # Check Sentinel workspace
   workspace_id=$(az monitor log-analytics workspace show --resource-group cmmc-test-rg --workspace-name cmmc-test-sentinel --query customerId -o tsv)
   
   if [ ! -z "$workspace_id" ]; then
       echo "✓ Sentinel workspace found: $workspace_id"
       
       # Test data ingestion for Azure Activity
       query="AzureActivity | where TimeGenerated > ago(1h) | take 5"
       result=$(az monitor log-analytics query --workspace $workspace_id --analytics-query "$query" --query 'tables[0].rows | length(@)')
       
       if [ "$result" -gt 0 ]; then
           echo "✓ Azure Activity data is being ingested"
       else
           echo "✗ No Azure Activity data found in last hour"
       fi
       
       # Test Azure AD data ingestion
       query="SigninLogs | where TimeGenerated > ago(1h) | take 5"
       result=$(az monitor log-analytics query --workspace $workspace_id --analytics-query "$query" --query 'tables[0].rows | length(@)')
       
       if [ "$result" -gt 0 ]; then
           echo "✓ Azure AD signin data is being ingested"
       else
           echo "✗ No Azure AD signin data found in last hour"
       fi
   else
       echo "✗ Sentinel workspace not found"
   fi
   ```

2. **Analytics Rules Testing**
   ```kusto
   // Test: Validate analytics rules are detecting events
   
   // Check if security alerts are being generated
   SecurityAlert
   | where TimeGenerated > ago(24h)
   | summarize count() by AlertName, AlertSeverity
   | order by count_ desc
   
   // Validate incident creation
   SecurityIncident
   | where TimeGenerated > ago(24h)
   | summarize count() by Title, Severity
   | order by count_ desc
   ```

## Security Testing

### Vulnerability Testing

#### Network Security Testing
**Objective**: Validate network security controls

**Test Cases**:
1. **Port Scanning Test**
   ```bash
   #!/bin/bash
   # Test: Verify only required ports are open
   
   echo "Testing Network Port Security..."
   
   # Test management subnet access
   management_ip="10.200.1.10"  # Example management server IP
   
   # Test allowed ports
   echo "Testing allowed port 443 (HTTPS)..."
   timeout 5 bash -c "</dev/tcp/$management_ip/443" && echo "✓ Port 443 accessible" || echo "✗ Port 443 not accessible"
   
   echo "Testing allowed port 3389 (RDP)..."
   timeout 5 bash -c "</dev/tcp/$management_ip/3389" && echo "✓ Port 3389 accessible from management network" || echo "✗ Port 3389 not accessible"
   
   # Test blocked ports
   echo "Testing blocked port 23 (Telnet)..."
   timeout 5 bash -c "</dev/tcp/$management_ip/23" && echo "✗ Port 23 should be blocked" || echo "✓ Port 23 correctly blocked"
   
   echo "Testing blocked port 21 (FTP)..."
   timeout 5 bash -c "</dev/tcp/$management_ip/21" && echo "✗ Port 21 should be blocked" || echo "✓ Port 21 correctly blocked"
   ```

2. **Network Segmentation Testing**
   ```bash
   #!/bin/bash
   # Test: Validate network segmentation between subnets
   
   echo "Testing Network Segmentation..."
   
   # Test access from workload to data subnet
   workload_ip="10.200.2.10"
   data_ip="10.200.3.10"
   
   # Should be allowed on specific ports only
   echo "Testing workload to data subnet communication..."
   
   # Test SQL access (should be allowed)
   timeout 5 bash -c "</dev/tcp/$data_ip/1433" && echo "✓ SQL port 1433 accessible from workload subnet" || echo "✗ SQL port 1433 blocked"
   
   # Test SSH access (should be blocked from workload to data)
   timeout 5 bash -c "</dev/tcp/$data_ip/22" && echo "✗ SSH port 22 should be blocked" || echo "✓ SSH port 22 correctly blocked"
   ```

### Authentication Security Testing

#### Multi-Factor Authentication Testing
**Objective**: Validate MFA enforcement

**Test Cases**:
1. **MFA Bypass Attempt**
   ```powershell
   # Test: Attempt to bypass MFA requirements
   
   Write-Host "Testing MFA Enforcement..." -ForegroundColor Green
   
   # Create test user without MFA
   $testUser = "mfatest@tenant.onmicrosoft.us"
   $password = ConvertTo-SecureString "TempPassword123!" -AsPlainText -Force
   
   try {
       # Attempt to create user and sign in without MFA
       New-AzureADUser -DisplayName "MFA Test User" -UserPrincipalName $testUser -PasswordProfile @{Password="TempPassword123!"; ForceChangePasswordNextLogin=$false} -AccountEnabled $true
       
       # Attempt sign-in (should fail due to MFA requirement)
       $cred = New-Object System.Management.Automation.PSCredential($testUser, $password)
       
       try {
           Connect-AzAccount -Credential $cred -Environment AzureUSGovernment -ErrorAction Stop
           Write-Host "✗ MFA bypass successful - this is a security issue!" -ForegroundColor Red
           Disconnect-AzAccount
       } catch {
           Write-Host "✓ MFA bypass failed - security control working correctly" -ForegroundColor Green
       }
       
       # Cleanup
       Remove-AzureADUser -ObjectId $testUser
   } catch {
       Write-Host "Error in MFA test: $($_.Exception.Message)" -ForegroundColor Yellow
   }
   ```

### Data Protection Testing

#### Encryption Testing
**Objective**: Validate data encryption at rest and in transit

**Test Cases**:
1. **Storage Encryption Testing**
   ```bash
   #!/bin/bash
   # Test: Verify storage account encryption
   
   echo "Testing Storage Account Encryption..."
   
   storage_account="cmmcteststorage"
   
   # Check encryption status
   encryption_status=$(az storage account show --name $storage_account --resource-group cmmc-test-rg --query 'encryption.services.blob.enabled' -o tsv)
   
   if [ "$encryption_status" = "true" ]; then
       echo "✓ Blob encryption enabled"
   else
       echo "✗ Blob encryption not enabled"
   fi
   
   # Check if customer-managed keys are used
   key_source=$(az storage account show --name $storage_account --resource-group cmmc-test-rg --query 'encryption.keySource' -o tsv)
   
   if [ "$key_source" = "Microsoft.Keyvault" ]; then
       echo "✓ Customer-managed keys configured"
   else
       echo "✗ Should use customer-managed keys for CMMC compliance"
   fi
   ```

2. **Database Encryption Testing**
   ```sql
   -- Test: Verify database encryption status
   
   -- Check Transparent Data Encryption status
   SELECT 
       DB_NAME() as DatabaseName,
       encryption_state_desc,
       percent_complete,
       key_algorithm,
       key_length
   FROM sys.dm_database_encryption_keys;
   
   -- Expected result: encryption_state_desc should be 'ENCRYPTED'
   
   -- Test Always Encrypted columns (if configured)
   SELECT 
       c.name AS ColumnName,
       c.encryption_type_desc,
       c.encryption_algorithm_name
   FROM sys.columns c
   WHERE c.encryption_type IS NOT NULL;
   ```

## Compliance Testing

### CMMC Level 2 Control Testing

#### Access Control (AC) Testing
**Objective**: Validate CMMC Access Control practices

**Test Cases**:
1. **AC.1.001 - Limit Information System Access**
   ```powershell
   # Test: Verify system access is limited to authorized users
   
   Write-Host "Testing AC.1.001 - System Access Control..." -ForegroundColor Green
   
   # Check that all users have proper authentication requirements
   $users = Get-AzureADUser -All $true | Where-Object {$_.UserType -eq "Member"}
   $usersWithMFA = 0
   $totalUsers = $users.Count
   
   foreach ($user in $users) {
       $mfaStatus = Get-AzureADUser -ObjectId $user.ObjectId | Select-Object -ExpandProperty StrongAuthenticationRequirements
       if ($mfaStatus.State -eq "Enforced" -or $mfaStatus.State -eq "Enabled") {
           $usersWithMFA++
       }
   }
   
   $mfaPercentage = ($usersWithMFA / $totalUsers) * 100
   
   if ($mfaPercentage -eq 100) {
       Write-Host "✓ AC.1.001 PASSED: All users have MFA enforced" -ForegroundColor Green
   } else {
       Write-Host "✗ AC.1.001 FAILED: $($totalUsers - $usersWithMFA) users without MFA" -ForegroundColor Red
   }
   ```

2. **AC.2.007 - Employ Least Privilege**
   ```powershell
   # Test: Validate least privilege principle
   
   Write-Host "Testing AC.2.007 - Least Privilege..." -ForegroundColor Green
   
   # Check for excessive privileged role assignments
   $privilegedRoles = @(
       "62e90394-69f5-4237-9190-012177145e10", # Global Administrator
       "194ae4cb-b126-40b2-bd5b-6091b380977d", # Security Administrator
       "c4e39bd9-1100-46d3-8c65-fb160da0071f"  # Security Reader
   )
   
   $excessivePrivileges = @()
   
   foreach ($roleId in $privilegedRoles) {
       $roleMembers = Get-AzureADDirectoryRoleMember -ObjectId $roleId
       if ($roleMembers.Count -gt 2) {
           $roleName = (Get-AzureADDirectoryRole -ObjectId $roleId).DisplayName
           $excessivePrivileges += "$roleName has $($roleMembers.Count) members (recommend max 2)"
       }
   }
   
   if ($excessivePrivileges.Count -eq 0) {
       Write-Host "✓ AC.2.007 PASSED: Privileged role assignments follow least privilege" -ForegroundColor Green
   } else {
       Write-Host "✗ AC.2.007 FAILED: Excessive privileged role assignments found:" -ForegroundColor Red
       $excessivePrivileges | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
   }
   ```

#### Audit and Accountability (AU) Testing
**Objective**: Validate CMMC Audit practices

**Test Cases**:
1. **AU.2.042 - Create and Retain Audit Logs**
   ```bash
   #!/bin/bash
   # Test: Verify audit log collection and retention
   
   echo "Testing AU.2.042 - Audit Log Collection..."
   
   # Check Log Analytics workspace retention
   workspace_retention=$(az monitor log-analytics workspace show --resource-group cmmc-test-rg --workspace-name cmmc-test-logs --query 'retentionInDays' -o tsv)
   
   if [ "$workspace_retention" -ge 365 ]; then
       echo "✓ AU.2.042 PASSED: Log retention is $workspace_retention days (>= 365 required)"
   else
       echo "✗ AU.2.042 FAILED: Log retention is only $workspace_retention days (365+ required for CMMC)"
   fi
   
   # Verify audit log collection is active
   activity_logs=$(az monitor activity-log list --max-events 10 --query 'length(@)')
   
   if [ "$activity_logs" -gt 0 ]; then
       echo "✓ AU.2.042 PASSED: Activity logs are being collected"
   else
       echo "✗ AU.2.042 FAILED: No recent activity logs found"
   fi
   ```

### Continuous Compliance Monitoring

#### Automated Compliance Testing
**Objective**: Implement automated compliance validation

**Test Script**:
```powershell
# Automated CMMC Compliance Test Suite
# This script validates multiple CMMC controls automatically

param(
    [Parameter(Mandatory=$true)]
    [string]$TenantId,
    
    [Parameter(Mandatory=$true)]  
    [string]$SubscriptionId,
    
    [string]$OutputPath = ".\compliance-test-results.json"
)

Write-Host "Starting CMMC Level 2 Automated Compliance Test..." -ForegroundColor Green

# Initialize results object
$testResults = @{
    TestDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TenantId = $TenantId
    SubscriptionId = $SubscriptionId
    OverallResult = "PASS"
    ControlResults = @{}
    Summary = @{
        TotalControls = 0
        PassedControls = 0
        FailedControls = 0
    }
}

# Test AC.1.001 - Limit System Access
Write-Host "Testing AC.1.001..." -ForegroundColor Yellow
try {
    $users = Get-AzureADUser -All $true | Where-Object {$_.UserType -eq "Member"}
    $mfaCompliantUsers = $users | Where-Object {
        $mfa = Get-AzureADUser -ObjectId $_.ObjectId | Select-Object -ExpandProperty StrongAuthenticationRequirements
        $mfa.State -eq "Enforced" -or $mfa.State -eq "Enabled"
    }
    
    $complianceRate = ($mfaCompliantUsers.Count / $users.Count) * 100
    
    $testResults.ControlResults["AC.1.001"] = @{
        Name = "Limit information system access to authorized users"
        Result = if ($complianceRate -eq 100) { "PASS" } else { "FAIL" }
        Details = "MFA compliance rate: $($complianceRate)%"
        UsersTotal = $users.Count
        UsersCompliant = $mfaCompliantUsers.Count
    }
    
    if ($complianceRate -lt 100) { $testResults.OverallResult = "FAIL" }
} catch {
    $testResults.ControlResults["AC.1.001"] = @{
        Name = "Limit information system access to authorized users"
        Result = "ERROR"
        Details = $_.Exception.Message
    }
    $testResults.OverallResult = "FAIL"
}

# Test AU.2.042 - Audit Logs
Write-Host "Testing AU.2.042..." -ForegroundColor Yellow
try {
    $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "cmmc-test-rg" -Name "cmmc-test-logs"
    $retention = $workspace.retentionInDays
    
    $testResults.ControlResults["AU.2.042"] = @{
        Name = "Create and retain system audit logs and records"
        Result = if ($retention -ge 365) { "PASS" } else { "FAIL" }
        Details = "Log retention period: $retention days"
        RetentionDays = $retention
        RequiredDays = 365
    }
    
    if ($retention -lt 365) { $testResults.OverallResult = "FAIL" }
} catch {
    $testResults.ControlResults["AU.2.042"] = @{
        Name = "Create and retain system audit logs and records"  
        Result = "ERROR"
        Details = $_.Exception.Message
    }
    $testResults.OverallResult = "FAIL"
}

# Calculate summary
$testResults.Summary.TotalControls = $testResults.ControlResults.Count
$testResults.Summary.PassedControls = ($testResults.ControlResults.Values | Where-Object {$_.Result -eq "PASS"}).Count
$testResults.Summary.FailedControls = $testResults.Summary.TotalControls - $testResults.Summary.PassedControls

# Output results
Write-Host "`nTest Summary:" -ForegroundColor Green
Write-Host "Total Controls Tested: $($testResults.Summary.TotalControls)" -ForegroundColor White
Write-Host "Passed: $($testResults.Summary.PassedControls)" -ForegroundColor Green
Write-Host "Failed: $($testResults.Summary.FailedControls)" -ForegroundColor Red
Write-Host "Overall Result: $($testResults.OverallResult)" -ForegroundColor $(if($testResults.OverallResult -eq "PASS"){"Green"}else{"Red"})

# Save results to file
$testResults | ConvertTo-Json -Depth 4 | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "`nDetailed results saved to: $OutputPath" -ForegroundColor Yellow
```

## Performance Testing

### Load Testing

#### System Load Testing
**Objective**: Validate system performance under load

**Test Cases**:
1. **User Concurrency Testing**
   ```bash
   #!/bin/bash
   # Test: Simulate concurrent user load
   
   echo "Starting User Concurrency Test..."
   
   # Test parameters
   CONCURRENT_USERS=100
   TEST_DURATION=300  # 5 minutes
   TARGET_URL="https://cmmc-test-app.azurewebsites.us"
   
   # Create test script for Apache Bench
   ab -n 1000 -c $CONCURRENT_USERS -t $TEST_DURATION $TARGET_URL/ > load_test_results.txt
   
   # Analyze results
   avg_response_time=$(grep "Time per request" load_test_results.txt | head -1 | awk '{print $4}')
   failed_requests=$(grep "Failed requests" load_test_results.txt | awk '{print $3}')
   
   echo "Average Response Time: $avg_response_time ms"
   echo "Failed Requests: $failed_requests"
   
   # Performance criteria
   if (( $(echo "$avg_response_time < 2000" | bc -l) )); then
       echo "✓ Performance test PASSED: Response time under 2 seconds"
   else
       echo "✗ Performance test FAILED: Response time exceeds 2 seconds"
   fi
   
   if [ "$failed_requests" -eq 0 ]; then
       echo "✓ Reliability test PASSED: No failed requests"
   else
       echo "✗ Reliability test FAILED: $failed_requests failed requests"
   fi
   ```

### Database Performance Testing

#### SQL Database Load Testing
**Objective**: Validate database performance under load

**Test Script**:
```sql
-- Database Performance Test
-- This script tests database performance under simulated load

SET NOCOUNT ON;

-- Create test table
IF OBJECT_ID('PerformanceTest', 'U') IS NOT NULL DROP TABLE PerformanceTest;
CREATE TABLE PerformanceTest (
    ID int IDENTITY(1,1) PRIMARY KEY,
    TestData varchar(255),
    CreatedDate datetime2 DEFAULT GETDATE()
);

-- Performance test variables
DECLARE @StartTime datetime2 = GETDATE();
DECLARE @BatchSize int = 1000;
DECLARE @TotalBatches int = 10;
DECLARE @CurrentBatch int = 1;
DECLARE @InsertCount int = 0;
DECLARE @TotalInserts int = @BatchSize * @TotalBatches;

PRINT 'Starting database performance test...';
PRINT 'Target inserts: ' + CAST(@TotalInserts AS varchar(10));

-- Insert performance test
WHILE @CurrentBatch <= @TotalBatches
BEGIN
    DECLARE @BatchStart datetime2 = GETDATE();
    
    -- Insert batch
    INSERT INTO PerformanceTest (TestData)
    SELECT 'Performance test data batch ' + CAST(@CurrentBatch AS varchar(10)) + ' row ' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS varchar(10))
    FROM sys.objects s1 CROSS JOIN sys.objects s2
    WHERE ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) <= @BatchSize;
    
    SET @InsertCount = @InsertCount + @@ROWCOUNT;
    
    DECLARE @BatchEnd datetime2 = GETDATE();
    DECLARE @BatchDuration int = DATEDIFF(ms, @BatchStart, @BatchEnd);
    
    PRINT 'Batch ' + CAST(@CurrentBatch AS varchar(3)) + ' completed: ' + CAST(@BatchSize AS varchar(10)) + ' inserts in ' + CAST(@BatchDuration AS varchar(10)) + ' ms';
    
    SET @CurrentBatch = @CurrentBatch + 1;
END;

-- Calculate final statistics
DECLARE @EndTime datetime2 = GETDATE();
DECLARE @TotalDuration int = DATEDIFF(ms, @StartTime, @EndTime);
DECLARE @InsertsPerSecond decimal(10,2) = (@InsertCount * 1000.0) / @TotalDuration;

PRINT '';
PRINT 'Performance Test Results:';
PRINT 'Total Duration: ' + CAST(@TotalDuration AS varchar(10)) + ' ms';
PRINT 'Total Inserts: ' + CAST(@InsertCount AS varchar(10));
PRINT 'Inserts per Second: ' + CAST(@InsertsPerSecond AS varchar(20));

-- Performance criteria validation
IF @InsertsPerSecond > 100
    PRINT '✓ Database performance test PASSED: ' + CAST(@InsertsPerSecond AS varchar(20)) + ' inserts/sec (target: >100)';
ELSE
    PRINT '✗ Database performance test FAILED: ' + CAST(@InsertsPerSecond AS varchar(20)) + ' inserts/sec (target: >100)';

-- Query performance test
DECLARE @QueryStart datetime2 = GETDATE();
SELECT COUNT(*) AS TotalRecords FROM PerformanceTest WHERE TestData LIKE '%batch%';
DECLARE @QueryEnd datetime2 = GETDATE();
DECLARE @QueryDuration int = DATEDIFF(ms, @QueryStart, @QueryEnd);

PRINT 'Query Duration: ' + CAST(@QueryDuration AS varchar(10)) + ' ms';

IF @QueryDuration < 1000
    PRINT '✓ Query performance test PASSED: ' + CAST(@QueryDuration AS varchar(10)) + ' ms (target: <1000ms)';
ELSE
    PRINT '✗ Query performance test FAILED: ' + CAST(@QueryDuration AS varchar(10)) + ' ms (target: <1000ms)';

-- Cleanup
DROP TABLE PerformanceTest;
PRINT 'Test cleanup completed.';
```

## Disaster Recovery Testing

### Backup and Recovery Testing

#### VM Recovery Testing
**Objective**: Validate VM backup and recovery procedures

**Test Script**:
```bash
#!/bin/bash
# VM Disaster Recovery Test

echo "Starting VM Disaster Recovery Test..."

# Test parameters
RESOURCE_GROUP="cmmc-test-rg"
VM_NAME="cmmc-test-vm"
RECOVERY_VAULT="cmmc-test-vault"
TEST_RG="cmmc-dr-test-rg"

# Step 1: Verify backup job completion
echo "Step 1: Verifying latest backup..."
latest_backup=$(az backup job list --resource-group $RESOURCE_GROUP --vault-name $RECOVERY_VAULT --query "[0].properties.endTime" -o tsv)

if [ ! -z "$latest_backup" ]; then
    echo "✓ Latest backup completed at: $latest_backup"
else
    echo "✗ No recent backup found"
    exit 1
fi

# Step 2: Create test resource group for recovery
echo "Step 2: Creating test resource group for recovery..."
az group create --name $TEST_RG --location "USGov Virginia"

# Step 3: Initiate VM restore
echo "Step 3: Starting VM restore process..."
recovery_job_id=$(az backup restore restore-disks \
    --resource-group $RESOURCE_GROUP \
    --vault-name $RECOVERY_VAULT \
    --container-name $VM_NAME \
    --item-name $VM_NAME \
    --storage-account $STORAGE_ACCOUNT \
    --target-resource-group $TEST_RG \
    --query 'name' -o tsv)

if [ ! -z "$recovery_job_id" ]; then
    echo "✓ Recovery job started: $recovery_job_id"
    
    # Monitor recovery job
    echo "Monitoring recovery job progress..."
    job_status="InProgress"
    while [ "$job_status" = "InProgress" ]; do
        sleep 30
        job_status=$(az backup job show --ids $recovery_job_id --query 'properties.status' -o tsv)
        echo "Recovery job status: $job_status"
    done
    
    if [ "$job_status" = "Completed" ]; then
        echo "✓ VM recovery completed successfully"
        
        # Step 4: Validate recovered VM
        echo "Step 4: Validating recovered VM..."
        recovered_vm=$(az vm list --resource-group $TEST_RG --query '[0].name' -o tsv)
        
        if [ ! -z "$recovered_vm" ]; then
            echo "✓ Recovered VM found: $recovered_vm"
            
            # Test VM accessibility
            vm_status=$(az vm get-instance-view --resource-group $TEST_RG --name $recovered_vm --query 'instanceView.statuses[1].displayStatus' -o tsv)
            echo "VM Status: $vm_status"
        else
            echo "✗ Recovered VM not found"
        fi
    else
        echo "✗ VM recovery failed with status: $job_status"
    fi
else
    echo "✗ Failed to start recovery job"
fi

# Step 5: Cleanup test resources
echo "Step 5: Cleaning up test resources..."
az group delete --name $TEST_RG --yes --no-wait

echo "VM Disaster Recovery Test completed."
```

## User Acceptance Testing

### End-User Functionality Testing

#### Microsoft 365 User Experience Testing
**Objective**: Validate end-user workflows and functionality

**Test Cases**:
1. **Email Security Testing**
   ```powershell
   # Test: Validate email security features for end users
   
   Write-Host "Testing Email Security Features..." -ForegroundColor Green
   
   # Test Safe Links functionality
   $testEmail = @{
       To = "testuser@tenant.onmicrosoft.us"
       Subject = "Safe Links Test"
       Body = "Please click this test link: http://malicious-test-site.com"
       From = "security@tenant.onmicrosoft.us"
   }
   
   # Send test email (would be intercepted by Safe Links)
   Write-Host "Safe Links test: Email with suspicious link would be blocked/wrapped" -ForegroundColor Green
   
   # Test DLP for CUI content
   $cuiTestEmail = @{
       To = "external@example.com"
       Subject = "CUI Test"  
       Body = "This email contains CUI information for testing"
   }
   
   Write-Host "DLP test: Email with CUI content to external recipient would be blocked" -ForegroundColor Green
   ```

2. **Document Classification Testing**
   ```powershell
   # Test: Validate document auto-classification
   
   Write-Host "Testing Document Auto-Classification..." -ForegroundColor Green
   
   # Create test document with CUI content
   $testContent = @"
   CONTROLLED UNCLASSIFIED INFORMATION
   
   This document contains sensitive information that requires protection
   under NIST SP 800-171 guidelines.
   
   Distribution: Limited to authorized personnel only.
"@
   
   # Save test document
   $testFile = "C:\temp\CUI-Test-Document.docx"
   $testContent | Out-File -FilePath $testFile -Encoding UTF8
   
   Write-Host "Test document created with CUI content" -ForegroundColor Green
   Write-Host "Expected: Document should auto-classify as CUI within 24 hours" -ForegroundColor Yellow
   
   # Cleanup
   Remove-Item $testFile -ErrorAction SilentlyContinue
   ```

## Test Reporting

### Automated Test Reporting

#### Generate Comprehensive Test Report
**Objective**: Create detailed test execution report

**Test Report Script**:
```powershell
# Comprehensive Test Report Generator
param(
    [string]$OutputPath = ".\CMMC-Test-Report.html"
)

# Initialize report data
$reportData = @{
    GeneratedDate = Get-Date
    TestSuite = "Microsoft CMMC Enclave Validation"
    Environment = "Test"
    OverallStatus = "PASS"
    TestCategories = @()
}

# HTML Template
$htmlTemplate = @'
<!DOCTYPE html>
<html>
<head>
    <title>CMMC Level 2 Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #0078d4; color: white; padding: 20px; }
        .summary { background-color: #f8f9fa; padding: 15px; margin: 20px 0; }
        .test-category { margin: 20px 0; }
        .pass { color: green; }
        .fail { color: red; }
        .error { color: orange; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>CMMC Level 2 Compliance Test Report</h1>
        <p>Generated: {GeneratedDate}</p>
        <p>Environment: {Environment}</p>
    </div>
    
    <div class="summary">
        <h2>Executive Summary</h2>
        <p><strong>Overall Status:</strong> <span class="{OverallStatusClass}">{OverallStatus}</span></p>
        <p><strong>Total Test Categories:</strong> {TotalCategories}</p>
        <p><strong>Passed Categories:</strong> {PassedCategories}</p>
        <p><strong>Failed Categories:</strong> {FailedCategories}</p>
    </div>
    
    {TestDetails}
</body>
</html>
'@

# Generate report
$reportHtml = $htmlTemplate -replace "{GeneratedDate}", $reportData.GeneratedDate
$reportHtml = $reportHtml -replace "{Environment}", $reportData.Environment
$reportHtml = $reportHtml -replace "{OverallStatus}", $reportData.OverallStatus
$reportHtml = $reportHtml -replace "{OverallStatusClass}", $(if($reportData.OverallStatus -eq "PASS"){"pass"}else{"fail"})

# Save report
$reportHtml | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "Test report generated: $OutputPath" -ForegroundColor Green
```

## Testing Schedule and Maintenance

### Regular Testing Schedule
- **Daily**: Automated security and compliance monitoring
- **Weekly**: Performance and capacity testing
- **Monthly**: Comprehensive security testing and vulnerability assessment
- **Quarterly**: Full disaster recovery testing and CMMC compliance validation
- **Annually**: Complete penetration testing and third-party assessment preparation

### Test Environment Maintenance
- Keep test environment synchronized with production
- Regular test data refresh and cleanup
- Update testing scripts based on system changes
- Maintain test documentation and procedures

This comprehensive testing framework ensures the Microsoft CMMC Enclave solution meets all security, compliance, and performance requirements while maintaining operational excellence throughout its lifecycle.
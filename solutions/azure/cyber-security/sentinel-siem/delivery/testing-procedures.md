# Azure Sentinel SIEM - Testing Procedures

## Overview

This comprehensive testing guide provides structured methodologies for validating Azure Sentinel SIEM implementations across development, staging, and production environments. The procedures ensure security detection capabilities, system performance, and operational readiness before deployment and during ongoing operations.

**Testing Philosophy**: Defense in depth validation with continuous security assurance  
**Target Audience**: Security engineers, SOC analysts, DevSecOps teams  
**Testing Frequency**: Pre-deployment, post-deployment, and quarterly validation cycles  
**Compliance Framework**: NIST Cybersecurity Framework, MITRE ATT&CK, ISO 27001

## Testing Strategy and Framework

### Testing Pyramid Approach

#### Unit Testing Level - Individual Components
**Analytics Rules Testing**
- Individual detection rule logic validation
- False positive and false negative rate testing
- Performance and resource consumption testing
- Edge case and boundary condition testing

**Data Connector Testing**
- Data ingestion accuracy and completeness
- Schema mapping and field normalization
- Connection reliability and error handling
- Authentication and authorization validation

#### Integration Testing Level - System Components
**End-to-End Detection Workflows**
- Multi-source data correlation testing
- Analytics rule chaining and dependency testing
- Incident creation and assignment workflows
- Automated response and playbook execution

#### System Testing Level - Complete Solution
**Production-like Environment Testing**
- Full-scale security simulation exercises
- Performance testing under production loads
- Disaster recovery and business continuity
- Compliance and audit requirement validation

### Testing Environment Requirements

#### Development Environment
```hcl
# Terraform configuration for testing environment
resource "azurerm_resource_group" "sentinel_test" {
  name     = "rg-sentinel-test-eus2-001"
  location = "East US 2"
  tags = {
    Environment = "Test"
    Purpose     = "Sentinel SIEM Testing"
    CostCenter  = "Security"
  }
}

resource "azurerm_log_analytics_workspace" "test_workspace" {
  name                = "law-sentinel-test-eus2-001"
  location            = azurerm_resource_group.sentinel_test.location
  resource_group_name = azurerm_resource_group.sentinel_test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = {
    Environment = "Test"
    Purpose     = "SIEM Testing Workspace"
  }
}

resource "azurerm_sentinel_workspace" "test_sentinel" {
  name                         = azurerm_log_analytics_workspace.test_workspace.name
  resource_group_name          = azurerm_resource_group.sentinel_test.name
  customer_managed_key_enabled = false
}
```

**Testing Data Sources**
```powershell
# Create test data generators for various security events
$TestEvents = @(
    @{
        EventType = "Successful Login"
        Count = 1000
        TimeRange = "24h"
        Source = "Test-DC-01"
    },
    @{
        EventType = "Failed Login"
        Count = 50
        TimeRange = "24h"
        Source = "Test-DC-01"
    },
    @{
        EventType = "Privilege Escalation"
        Count = 5
        TimeRange = "24h"
        Source = "Test-Server-01"
    }
)

# Generate synthetic security events for testing
foreach ($Event in $TestEvents) {
    New-TestSecurityEvent -EventType $Event.EventType -Count $Event.Count -TimeRange $Event.TimeRange -Source $Event.Source
}
```

## Analytics Rule Testing

### Detection Rule Validation

#### Positive Testing - Known Threat Scenarios
```powershell
# Test Script: Brute Force Attack Detection
param(
    [string]$WorkspaceId = "test-workspace-id",
    [string]$TestUser = "testuser@contoso.com",
    [int]$FailureCount = 15
)

# Generate failed authentication events
for ($i = 1; $i -le $FailureCount; $i++) {
    $Event = @{
        TimeGenerated = (Get-Date).AddMinutes(-$i)
        UserPrincipalName = $TestUser
        IPAddress = "192.168.100.$i"
        ResultType = "50126"  # Invalid username or password
        Location = "Test Environment"
    }
    
    # Send test event to Log Analytics
    Send-LogAnalyticsEvent -WorkspaceId $WorkspaceId -Data $Event -LogType "TestSigninLogs"
    Start-Sleep -Seconds 2
}

# Verify detection rule triggers
Start-Sleep -Seconds 300  # Wait for analytics processing
$Alerts = Get-AzSentinelAlert -WorkspaceName "law-sentinel-test-eus2-001" | 
    Where-Object { $_.AlertName -like "*Brute Force*" -and $_.TimeGenerated -gt (Get-Date).AddHours(-1) }

if ($Alerts.Count -gt 0) {
    Write-Host "✅ Brute Force Detection Test: PASSED" -ForegroundColor Green
    $Alerts | Format-Table TimeGenerated, AlertName, Severity
} else {
    Write-Host "❌ Brute Force Detection Test: FAILED" -ForegroundColor Red
}
```

#### Negative Testing - Benign Activity Validation
```kql
// Test Query: Verify normal activities don't trigger false positives
let TestTimeframe = 1h;
let NormalLoginThreshold = 100;

SigninLogs
| where TimeGenerated >= ago(TestTimeframe)
| where UserPrincipalName startswith "testuser"
| where ResultType == "0"  // Successful logins
| summarize LoginCount = count() by UserPrincipalName
| where LoginCount <= NormalLoginThreshold
| extend TestResult = "Normal Activity - No Alert Expected"
```

#### Edge Case Testing
```powershell
# Test Edge Cases for Analytics Rules
$EdgeCases = @(
    @{ Scenario = "Boundary Threshold"; Description = "Test threshold -1, exact threshold, threshold +1" },
    @{ Scenario = "Time Window Edge"; Description = "Events at start and end of detection window" },
    @{ Scenario = "Data Type Variations"; Description = "Different data formats and encodings" },
    @{ Scenario = "Missing Fields"; Description = "Required fields are null or missing" },
    @{ Scenario = "Special Characters"; Description = "Unicode, escape characters, injection attempts" }
)

foreach ($Case in $EdgeCases) {
    Write-Host "Testing: $($Case.Scenario)" -ForegroundColor Yellow
    
    switch ($Case.Scenario) {
        "Boundary Threshold" {
            # Test with 9, 10, and 11 failed logins (if threshold is 10)
            Test-BruteForceThreshold -FailureCount 9  # Should not alert
            Test-BruteForceThreshold -FailureCount 10 # Should alert
            Test-BruteForceThreshold -FailureCount 11 # Should alert
        }
        
        "Time Window Edge" {
            # Test events at exact window boundaries
            Test-TimeWindowBoundary -WindowStart (Get-Date).AddHours(-1)
            Test-TimeWindowBoundary -WindowEnd (Get-Date)
        }
        
        # Additional edge case implementations...
    }
}
```

### Performance Testing

#### Query Performance Validation
```kql
// Performance Test: Analytics Rule Execution Time
let StartTime = now();
SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID in (4624, 4625)
| summarize LoginAttempts = count() by Account, Computer
| where LoginAttempts > 100
| extend QueryDuration = now() - StartTime
| project Account, Computer, LoginAttempts, QueryDuration
```

```powershell
# Automated Performance Testing Script
param(
    [string[]]$TestQueries = @("BruteForceDetection", "SuspiciousPowerShell", "PrivilegeEscalation"),
    [int]$MaxExecutionTimeSeconds = 30
)

foreach ($Query in $TestQueries) {
    $StartTime = Get-Date
    
    try {
        $Result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query (Get-Content "queries/$Query.kql" -Raw)
        $ExecutionTime = ((Get-Date) - $StartTime).TotalSeconds
        
        if ($ExecutionTime -le $MaxExecutionTimeSeconds) {
            Write-Host "✅ $Query Performance Test: PASSED ($ExecutionTime seconds)" -ForegroundColor Green
        } else {
            Write-Host "⚠️ $Query Performance Test: SLOW ($ExecutionTime seconds)" -ForegroundColor Yellow
        }
        
        # Log performance metrics
        $PerformanceLog = @{
            QueryName = $Query
            ExecutionTime = $ExecutionTime
            RecordCount = $Result.Results.Count
            TestDate = Get-Date
        }
        
        $PerformanceLog | Export-Csv -Path "performance_test_results.csv" -Append -NoTypeInformation
        
    } catch {
        Write-Host "❌ $Query Performance Test: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Data Source Testing

### Data Ingestion Validation

#### Azure Activity Logs Testing
```powershell
# Test Azure Activity Log ingestion
$TestResourceGroup = "rg-test-sentinel-001"

# Generate test activities
New-AzResourceGroup -Name "$TestResourceGroup-temp" -Location "East US 2" -Tag @{Purpose="Testing"}
Remove-AzResourceGroup -Name "$TestResourceGroup-temp" -Force

# Wait for ingestion and verify
Start-Sleep -Seconds 600  # Wait 10 minutes for data ingestion

$Query = @"
AzureActivity
| where TimeGenerated >= ago(15m)
| where ResourceGroup contains "rg-test-sentinel"
| where OperationNameValue in ("Microsoft.Resources/resourceGroups/write", "Microsoft.Resources/resourceGroups/delete")
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, ActivityStatusValue
"@

$Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $Query

if ($Results.Results.Count -ge 2) {
    Write-Host "✅ Azure Activity Log Ingestion: PASSED" -ForegroundColor Green
} else {
    Write-Host "❌ Azure Activity Log Ingestion: FAILED - Expected 2+ events, got $($Results.Results.Count)" -ForegroundColor Red
}
```

#### Office 365 Audit Logs Testing
```powershell
# Test Office 365 audit log ingestion
# Note: Requires Office 365 E3/E5 and appropriate permissions

# Generate test activities via Graph API
$Headers = @{
    'Authorization' = "Bearer $AccessToken"
    'Content-Type' = 'application/json'
}

# Create test SharePoint activity
$SharePointActivity = @{
    activityDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    activityType = "FileAccessed"
    actor = @{
        user = @{
            id = "testuser@contoso.com"
        }
    }
}

Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits" -Method POST -Headers $Headers -Body ($SharePointActivity | ConvertTo-Json)

# Verify ingestion in Sentinel
Start-Sleep -Seconds 900  # Wait 15 minutes for Office 365 data ingestion

$OfficeQuery = @"
OfficeActivity
| where TimeGenerated >= ago(20m)
| where UserId == "testuser@contoso.com"
| where Operation == "FileAccessed"
| project TimeGenerated, UserId, Operation, OfficeWorkload, RecordType
"@

$OfficeResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $OfficeQuery

if ($OfficeResults.Results.Count -gt 0) {
    Write-Host "✅ Office 365 Audit Log Ingestion: PASSED" -ForegroundColor Green
} else {
    Write-Host "❌ Office 365 Audit Log Ingestion: FAILED" -ForegroundColor Red
}
```

#### Custom Log Source Testing
```powershell
# Test custom data connector (Syslog/CEF)
param(
    [string]$SyslogServer = "test-syslog-server.contoso.com",
    [int]$SyslogPort = 514
)

# Send test syslog message
$TestMessage = "<13>$(Get-Date -Format 'MMM dd HH:mm:ss') TestHost TestApp[1234]: CEF:0|TestVendor|TestProduct|1.0|100|Test Security Event|5|src=192.168.1.100 dst=10.0.0.50 spt=12345 dpt=80"

$UdpClient = New-Object System.Net.Sockets.UdpClient
$UdpClient.Connect($SyslogServer, $SyslogPort)
$EncodedMessage = [System.Text.Encoding]::ASCII.GetBytes($TestMessage)
$UdpClient.Send($EncodedMessage, $EncodedMessage.Length)
$UdpClient.Close()

# Verify ingestion
Start-Sleep -Seconds 300

$SyslogQuery = @"
Syslog
| where TimeGenerated >= ago(10m)
| where Computer == "TestHost"
| where ProcessName == "TestApp"
| project TimeGenerated, Computer, ProcessName, SyslogMessage
"@

$SyslogResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $SyslogQuery

if ($SyslogResults.Results.Count -gt 0) {
    Write-Host "✅ Custom Syslog Ingestion: PASSED" -ForegroundColor Green
} else {
    Write-Host "❌ Custom Syslog Ingestion: FAILED" -ForegroundColor Red
}
```

### Data Quality Validation

#### Schema and Field Mapping Tests
```kql
// Validate expected fields are present and correctly typed
SecurityEvent
| where TimeGenerated >= ago(1h)
| extend ValidationResults = pack_all()
| project
    TimeGenerated,
    HasTimeGenerated = isnotempty(TimeGenerated),
    HasEventID = isnotempty(EventID),
    HasComputer = isnotempty(Computer),
    HasAccount = isnotempty(Account),
    EventIDType = gettype(EventID),
    ComputerType = gettype(Computer),
    AccountType = gettype(Account)
| summarize 
    TotalRecords = count(),
    MissingTimeGenerated = countif(HasTimeGenerated == false),
    MissingEventID = countif(HasEventID == false),
    MissingComputer = countif(HasComputer == false),
    MissingAccount = countif(HasAccount == false)
```

#### Data Completeness Testing
```powershell
# Data completeness validation script
$DataQualityTests = @{
    "SecurityEvent" = @{
        ExpectedDailyVolume = 10000
        RequiredFields = @("TimeGenerated", "EventID", "Computer", "Account")
        UniqueComputers = 50
    }
    "SigninLogs" = @{
        ExpectedDailyVolume = 5000
        RequiredFields = @("TimeGenerated", "UserPrincipalName", "IPAddress", "ResultType")
        UniqueUsers = 200
    }
}

foreach ($DataType in $DataQualityTests.Keys) {
    $TestConfig = $DataQualityTests[$DataType]
    
    $Query = @"
    $DataType
    | where TimeGenerated >= ago(24h)
    | summarize 
        RecordCount = count(),
        UniqueComputers = dcount(Computer),
        UniqueUsers = dcount(UserPrincipalName),
        MissingFields = countif(isempty(TimeGenerated) or isempty(EventID))
"@
    
    $Results = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $Query
    $Data = $Results.Results[0]
    
    $VolumeTest = $Data.RecordCount -ge ($TestConfig.ExpectedDailyVolume * 0.8)  # 80% threshold
    $CompletenessTest = $Data.MissingFields -eq 0
    
    Write-Host "Data Quality Test - $DataType" -ForegroundColor Cyan
    Write-Host "  Volume Test: $(if($VolumeTest) {'PASSED'} else {'FAILED'}) ($($Data.RecordCount) records)" -ForegroundColor $(if($VolumeTest) {'Green'} else {'Red'})
    Write-Host "  Completeness Test: $(if($CompletenessTest) {'PASSED'} else {'FAILED'}) ($($Data.MissingFields) missing)" -ForegroundColor $(if($CompletenessTest) {'Green'} else {'Red'})
}
```

## Incident Response Testing

### Automated Playbook Testing

#### Security Orchestration Playbook Validation
```json
{
  "definition": {
    "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "TestIncidentId": {
        "type": "string",
        "defaultValue": "test-incident-001"
      }
    },
    "triggers": {
      "manual": {
        "type": "Request",
        "kind": "Http"
      }
    },
    "actions": {
      "TestIncidentCreation": {
        "type": "ApiConnection",
        "inputs": {
          "host": {
            "connection": {
              "name": "@parameters('$connections')['azuresentinel']['connectionId']"
            }
          },
          "method": "post",
          "path": "/Incidents/subscriptions/@{encodeURIComponent('')}/resourceGroups/@{encodeURIComponent('')}/workspaces/@{encodeURIComponent('')}",
          "body": {
            "properties": {
              "title": "Test Incident - Automated Testing",
              "description": "This is a test incident created for playbook validation",
              "severity": "Medium",
              "status": "New",
              "classification": "Undetermined",
              "owner": {
                "assignedTo": "test-analyst@contoso.com"
              }
            }
          }
        }
      },
      "ValidateIncidentCreation": {
        "type": "Condition",
        "expression": {
          "and": [
            {
              "equals": [
                "@outputs('TestIncidentCreation')['statusCode']",
                200
              ]
            }
          ]
        },
        "actions": {
          "TestPassed": {
            "type": "Compose",
            "inputs": {
              "TestResult": "Incident Creation Test: PASSED",
              "IncidentId": "@body('TestIncidentCreation')['name']",
              "CreatedTime": "@utcNow()"
            }
          }
        },
        "else": {
          "actions": {
            "TestFailed": {
              "type": "Compose",
              "inputs": {
                "TestResult": "Incident Creation Test: FAILED",
                "Error": "@body('TestIncidentCreation')",
                "FailureTime": "@utcNow()"
              }
            }
          }
        }
      }
    }
  }
}
```

#### Automated Response Testing
```powershell
# Test automated user account lockout response
param(
    [string]$TestUser = "testuser@contoso.com",
    [string]$PlaybookName = "Disable-CompromisedUser"
)

# Trigger test incident that should activate automated response
$TestIncident = @{
    Title = "Test - Compromised User Account: $TestUser"
    Description = "Automated test incident to validate user lockout playbook"
    Severity = "High"
    Status = "New"
    Owner = "test-analyst@contoso.com"
    Labels = @("AutomatedTest", "UserCompromise")
}

# Create test incident via API
$IncidentId = New-AzSentinelIncident @TestIncident -WorkspaceName "law-sentinel-test-eus2-001"

# Monitor for automated response execution
$Timeout = (Get-Date).AddMinutes(10)
$PlaybookExecuted = $false

do {
    Start-Sleep -Seconds 30
    
    # Check if playbook was triggered
    $PlaybookRuns = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $PlaybookName |
        Where-Object { $_.StartTime -gt (Get-Date).AddMinutes(-15) }
    
    if ($PlaybookRuns.Count -gt 0) {
        $PlaybookExecuted = $true
        $LastRun = $PlaybookRuns | Sort-Object StartTime -Descending | Select-Object -First 1
        
        if ($LastRun.Status -eq "Succeeded") {
            Write-Host "✅ Automated Response Test: PASSED" -ForegroundColor Green
            Write-Host "  Playbook executed successfully at $($LastRun.StartTime)" -ForegroundColor Green
        } else {
            Write-Host "❌ Automated Response Test: FAILED" -ForegroundColor Red
            Write-Host "  Playbook execution failed: $($LastRun.Status)" -ForegroundColor Red
        }
    }
    
} while ((Get-Date) -lt $Timeout -and -not $PlaybookExecuted)

if (-not $PlaybookExecuted) {
    Write-Host "❌ Automated Response Test: FAILED - Playbook not triggered within timeout" -ForegroundColor Red
}

# Cleanup test incident
Remove-AzSentinelIncident -IncidentId $IncidentId -WorkspaceName "law-sentinel-test-eus2-001"
```

### Manual Incident Response Testing

#### Incident Investigation Workflow Test
```powershell
# Simulate security analyst investigation workflow
param(
    [string]$TestIncidentId = "test-incident-001",
    [string]$SuspiciousIP = "192.168.100.99",
    [string]$SuspiciousUser = "testuser@contoso.com"
)

Write-Host "Starting Manual Incident Response Test..." -ForegroundColor Cyan

# Step 1: Initial incident review
$IncidentDetails = Get-AzSentinelIncident -IncidentId $TestIncidentId -WorkspaceName "law-sentinel-test-eus2-001"
Write-Host "Step 1: Incident Review - COMPLETED" -ForegroundColor Green
Write-Host "  Incident: $($IncidentDetails.Title)" -ForegroundColor White
Write-Host "  Severity: $($IncidentDetails.Severity)" -ForegroundColor White

# Step 2: Evidence gathering
$EvidenceQueries = @{
    "UserActivity" = @"
        SigninLogs
        | where TimeGenerated >= ago(24h)
        | where UserPrincipalName == "$SuspiciousUser"
        | project TimeGenerated, IPAddress, Location, ResultType, AppDisplayName
        | order by TimeGenerated desc
"@
    
    "IPReputation" = @"
        ThreatIntelligenceIndicator
        | where TimeGenerated >= ago(30d)
        | where IndicatorValue == "$SuspiciousIP"
        | project TimeGenerated, ThreatType, Confidence, Description
"@
    
    "RelatedAlerts" = @"
        SecurityAlert
        | where TimeGenerated >= ago(24h)
        | where Entities contains "$SuspiciousUser" or Entities contains "$SuspiciousIP"
        | project TimeGenerated, AlertName, AlertSeverity, Status
"@
}

$EvidenceResults = @{}
foreach ($QueryName in $EvidenceQueries.Keys) {
    try {
        $Result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $EvidenceQueries[$QueryName]
        $EvidenceResults[$QueryName] = $Result.Results
        Write-Host "Step 2: Evidence Gathering - $QueryName: COMPLETED ($($Result.Results.Count) records)" -ForegroundColor Green
    } catch {
        Write-Host "Step 2: Evidence Gathering - $QueryName: FAILED ($($_.Exception.Message))" -ForegroundColor Red
    }
}

# Step 3: Timeline reconstruction
$TimelineQuery = @"
union SecurityEvent, SigninLogs, AuditLogs
| where TimeGenerated >= ago(24h)
| where Account contains "$SuspiciousUser" or UserPrincipalName == "$SuspiciousUser" or InitiatedBy contains "$SuspiciousUser"
| project TimeGenerated, EventType = $table, Activity, Account, IPAddress, Computer
| order by TimeGenerated asc
"@

$TimelineResults = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $TimelineQuery
Write-Host "Step 3: Timeline Reconstruction - COMPLETED ($($TimelineResults.Results.Count) events)" -ForegroundColor Green

# Step 4: Impact assessment
$ImpactQueries = @{
    "AffectedSystems" = @"
        SecurityEvent
        | where TimeGenerated >= ago(24h)
        | where Account == "$SuspiciousUser"
        | summarize Events = count() by Computer
        | order by Events desc
"@
    
    "DataAccess" = @"
        OfficeActivity
        | where TimeGenerated >= ago(24h)
        | where UserId == "$SuspiciousUser"
        | where Operation in ("FileDownloaded", "FileAccessed", "FileCopied")
        | summarize FileCount = count(), Files = make_list(OfficeObjectId)
        | project FileCount, Files
"@
}

foreach ($QueryName in $ImpactQueries.Keys) {
    try {
        $Result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $ImpactQueries[$QueryName]
        Write-Host "Step 4: Impact Assessment - $QueryName: COMPLETED" -ForegroundColor Green
    } catch {
        Write-Host "Step 4: Impact Assessment - $QueryName: FAILED" -ForegroundColor Red
    }
}

# Step 5: Documentation and reporting
$InvestigationReport = @{
    IncidentId = $TestIncidentId
    Analyst = $env:USERNAME
    InvestigationDate = Get-Date
    SuspiciousEntities = @($SuspiciousUser, $SuspiciousIP)
    EvidenceSummary = $EvidenceResults
    TimelineEvents = $TimelineResults.Results.Count
    Status = "Investigation Complete"
}

$InvestigationReport | ConvertTo-Json -Depth 5 | Out-File "investigation_report_$TestIncidentId.json"
Write-Host "Step 5: Documentation - COMPLETED" -ForegroundColor Green

Write-Host "Manual Incident Response Test: COMPLETED SUCCESSFULLY" -ForegroundColor Cyan
```

## Performance and Load Testing

### System Capacity Testing

#### Query Load Testing
```powershell
# Concurrent query load test
param(
    [int]$ConcurrentQueries = 10,
    [int]$TestDurationMinutes = 30,
    [string[]]$TestQueries = @("SecurityEvent | take 1000", "SigninLogs | take 1000", "AuditLogs | take 1000")
)

$Jobs = @()
$StartTime = Get-Date
$EndTime = $StartTime.AddMinutes($TestDurationMinutes)

Write-Host "Starting Query Load Test - $ConcurrentQueries concurrent queries for $TestDurationMinutes minutes" -ForegroundColor Cyan

while ((Get-Date) -lt $EndTime) {
    # Maintain concurrent query load
    $RunningJobs = $Jobs | Where-Object { $_.State -eq "Running" }
    
    while ($RunningJobs.Count -lt $ConcurrentQueries -and (Get-Date) -lt $EndTime) {
        $Query = $TestQueries | Get-Random
        
        $Job = Start-Job -ScriptBlock {
            param($WorkspaceId, $Query, $StartTime)
            
            try {
                $QueryStart = Get-Date
                $Result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $Query
                $QueryEnd = Get-Date
                
                @{
                    StartTime = $QueryStart
                    EndTime = $QueryEnd
                    Duration = ($QueryEnd - $QueryStart).TotalSeconds
                    RecordCount = $Result.Results.Count
                    Success = $true
                    Error = $null
                }
            } catch {
                @{
                    StartTime = $QueryStart
                    EndTime = Get-Date
                    Duration = $null
                    RecordCount = 0
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
        } -ArgumentList $WorkspaceId, $Query, $StartTime
        
        $Jobs += $Job
        $RunningJobs = $Jobs | Where-Object { $_.State -eq "Running" }
        Start-Sleep -Seconds 1
    }
    
    Start-Sleep -Seconds 10
}

# Wait for all jobs to complete and collect results
$Jobs | Wait-Job | Out-Null
$Results = $Jobs | Receive-Job

# Analyze performance results
$SuccessfulQueries = $Results | Where-Object Success
$FailedQueries = $Results | Where-Object { -not $_.Success }

$PerformanceStats = [PSCustomObject]@{
    TotalQueries = $Results.Count
    SuccessfulQueries = $SuccessfulQueries.Count
    FailedQueries = $FailedQueries.Count
    SuccessRate = [math]::Round(($SuccessfulQueries.Count / $Results.Count) * 100, 2)
    AverageQueryTime = [math]::Round(($SuccessfulQueries | Measure-Object Duration -Average).Average, 2)
    MaxQueryTime = ($SuccessfulQueries | Measure-Object Duration -Maximum).Maximum
    MinQueryTime = ($SuccessfulQueries | Measure-Object Duration -Minimum).Minimum
}

Write-Host "Query Load Test Results:" -ForegroundColor Green
$PerformanceStats | Format-List

# Cleanup jobs
$Jobs | Remove-Job
```

#### Data Ingestion Load Testing
```powershell
# Test data ingestion capacity
param(
    [int]$EventsPerSecond = 100,
    [int]$TestDurationMinutes = 10,
    [string]$LogType = "CustomTestLog"
)

$StartTime = Get-Date
$EndTime = $StartTime.AddMinutes($TestDurationMinutes)
$EventCount = 0

Write-Host "Starting Data Ingestion Load Test - $EventsPerSecond events/sec for $TestDurationMinutes minutes" -ForegroundColor Cyan

while ((Get-Date) -lt $EndTime) {
    $BatchStartTime = Get-Date
    
    # Generate batch of events
    $Events = @()
    for ($i = 1; $i -le $EventsPerSecond; $i++) {
        $Event = @{
            TimeGenerated = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            EventId = [Guid]::NewGuid().ToString()
            EventType = "LoadTest"
            SourceIP = "192.168.$(Get-Random -Min 1 -Max 255).$(Get-Random -Min 1 -Max 255)"
            UserName = "testuser$(Get-Random -Min 1 -Max 1000)"
            EventData = "Load test event data with random content $(Get-Random)"
        }
        $Events += $Event
    }
    
    # Send batch to Log Analytics
    try {
        $JsonPayload = $Events | ConvertTo-Json
        $PostUri = "https://$WorkspaceId.ods.opinsights.azure.com/api/logs?api-version=2016-04-01"
        
        $Headers = @{
            "Authorization" = "SharedKey $WorkspaceId`:$SharedKey"
            "Log-Type" = $LogType
            "x-ms-date" = [DateTime]::UtcNow.ToString("r")
            "time-generated-field" = "TimeGenerated"
        }
        
        Invoke-RestMethod -Uri $PostUri -Method Post -ContentType "application/json" -Headers $Headers -Body $JsonPayload
        $EventCount += $EventsPerSecond
        
    } catch {
        Write-Host "Ingestion error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Maintain target rate
    $BatchDuration = ((Get-Date) - $BatchStartTime).TotalSeconds
    $TargetDuration = 1.0  # 1 second per batch
    
    if ($BatchDuration -lt $TargetDuration) {
        Start-Sleep -Seconds ($TargetDuration - $BatchDuration)
    }
    
    # Progress update
    if ($EventCount % ($EventsPerSecond * 10) -eq 0) {
        Write-Host "Ingested $EventCount events..." -ForegroundColor Yellow
    }
}

Write-Host "Data Ingestion Load Test Completed - $EventCount total events ingested" -ForegroundColor Green

# Verify ingestion success
Start-Sleep -Seconds 300  # Wait for ingestion processing

$VerificationQuery = @"
$LogType`_CL
| where TimeGenerated >= datetime('$($StartTime.ToString("yyyy-MM-dd HH:mm:ss"))')
| summarize IngestedCount = count()
"@

$VerificationResult = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $VerificationQuery
$IngestedCount = $VerificationResult.Results[0].IngestedCount

Write-Host "Ingestion Verification:" -ForegroundColor Cyan
Write-Host "  Events Sent: $EventCount" -ForegroundColor White
Write-Host "  Events Ingested: $IngestedCount" -ForegroundColor White
Write-Host "  Success Rate: $([math]::Round(($IngestedCount / $EventCount) * 100, 2))%" -ForegroundColor White
```

## Compliance and Audit Testing

### Regulatory Compliance Validation

#### SOX Compliance Testing
```kql
// Test SOX compliance monitoring capabilities
// Verify privileged access monitoring
AuditLogs
| where TimeGenerated >= ago(24h)
| where OperationName in ("Add user", "Delete user", "Add member to role", "Remove member from role")
| where Result == "success"
| extend InitiatedByUser = tostring(InitiatedBy.user.userPrincipalName)
| extend TargetUser = tostring(TargetResources[0].userPrincipalName)
| extend TargetRole = tostring(TargetResources[0].displayName)
| project TimeGenerated, InitiatedByUser, OperationName, TargetUser, TargetRole
| order by TimeGenerated desc
```

#### GDPR Compliance Testing
```kql
// Test GDPR data subject request monitoring
OfficeActivity
| where TimeGenerated >= ago(24h)
| where Operation in ("SearchQueryPerformed", "ViewedSearchResults", "AccessedEmail")
| where UserId in ("gdpr-test-user@contoso.com")
| extend DataSubjectActivity = pack("User", UserId, "Operation", Operation, "Time", TimeGenerated)
| summarize DataAccess = make_list(DataSubjectActivity) by UserId
```

#### HIPAA Compliance Testing
```kql
// Test healthcare data access monitoring
SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID in (4656, 4663)  // Handle to object events
| where ObjectName contains "healthcare" or ObjectName contains "patient"
| extend SubjectUserName = extract(@"Subject:\s+Security ID:\s+[^\s]+\s+Account Name:\s+([^\s]+)", 1, EventData)
| project TimeGenerated, Computer, SubjectUserName, ObjectName, AccessMask
| where isnotempty(SubjectUserName)
```

### Security Framework Testing

#### MITRE ATT&CK Coverage Validation
```powershell
# Test MITRE ATT&CK technique coverage
$MitreTechniques = @{
    "T1078" = "Valid Accounts"
    "T1055" = "Process Injection"
    "T1059" = "Command and Scripting Interpreter"
    "T1053" = "Scheduled Task/Job"
    "T1003" = "OS Credential Dumping"
    "T1021" = "Remote Services"
    "T1090" = "Proxy"
    "T1071" = "Application Layer Protocol"
}

$CoverageResults = @{}

foreach ($TechniqueId in $MitreTechniques.Keys) {
    $TechniqueName = $MitreTechniques[$TechniqueId]
    
    # Check for analytics rules covering this technique
    $CoverageQuery = @"
    SecurityAlert
    | where TimeGenerated >= ago(30d)
    | extend MitreTechnique = tostring(ExtendedProperties["MITRE ATT&CK Technique"])
    | where MitreTechnique == "$TechniqueId"
    | summarize 
        AlertCount = count(),
        UniqueMachines = dcount(Computer),
        UniqueUsers = dcount(CompromisedEntity)
    | extend TechniqueCovered = AlertCount > 0
"@
    
    try {
        $Result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $CoverageQuery
        
        if ($Result.Results.Count -gt 0 -and $Result.Results[0].TechniqueCovered) {
            $CoverageResults[$TechniqueId] = @{
                Status = "Covered"
                AlertCount = $Result.Results[0].AlertCount
                UniqueMachines = $Result.Results[0].UniqueMachines
                UniqueUsers = $Result.Results[0].UniqueUsers
            }
            Write-Host "✅ $TechniqueId ($TechniqueName): COVERED" -ForegroundColor Green
        } else {
            $CoverageResults[$TechniqueId] = @{
                Status = "Gap"
                AlertCount = 0
                UniqueMachines = 0
                UniqueUsers = 0
            }
            Write-Host "❌ $TechniqueId ($TechniqueName): COVERAGE GAP" -ForegroundColor Red
        }
    } catch {
        Write-Host "⚠️ $TechniqueId ($TechniqueName): TEST ERROR - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Generate coverage report
$CoverageReport = [PSCustomObject]@{
    TestDate = Get-Date
    TotalTechniques = $MitreTechniques.Count
    CoveredTechniques = ($CoverageResults.Values | Where-Object { $_.Status -eq "Covered" }).Count
    CoverageGaps = ($CoverageResults.Values | Where-Object { $_.Status -eq "Gap" }).Count
    CoveragePercentage = [math]::Round((($CoverageResults.Values | Where-Object { $_.Status -eq "Covered" }).Count / $MitreTechniques.Count) * 100, 2)
    DetailedResults = $CoverageResults
}

$CoverageReport | ConvertTo-Json -Depth 4 | Out-File "mitre_coverage_report_$(Get-Date -Format 'yyyy-MM-dd').json"
Write-Host "MITRE ATT&CK Coverage: $($CoverageReport.CoveragePercentage)% ($($CoverageReport.CoveredTechniques)/$($CoverageReport.TotalTechniques) techniques)" -ForegroundColor Cyan
```

## Disaster Recovery Testing

### Backup and Restore Validation

#### Workspace Backup Testing
```powershell
# Test workspace configuration backup
param(
    [string]$BackupStorageAccount = "sentinelbackupstore001",
    [string]$BackupContainer = "workspace-backups"
)

Write-Host "Starting Workspace Backup Test..." -ForegroundColor Cyan

# Export analytics rules
$AnalyticsRules = Get-AzSentinelAlertRule -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName
$RulesBackup = @{
    ExportDate = Get-Date
    WorkspaceName = $WorkspaceName
    Rules = $AnalyticsRules
}

$RulesJson = $RulesBackup | ConvertTo-Json -Depth 10
$BackupFileName = "analytics_rules_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

# Upload to storage account
$StorageContext = New-AzStorageContext -StorageAccountName $BackupStorageAccount -UseConnectedAccount
Set-AzStorageBlobContent -File $BackupFileName -Container $BackupContainer -Context $StorageContext -Blob $BackupFileName

Write-Host "✅ Analytics Rules Backup: COMPLETED" -ForegroundColor Green

# Export workbooks
$Workbooks = Get-AzSentinelWorkbook -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName
$WorkbooksBackup = @{
    ExportDate = Get-Date
    WorkspaceName = $WorkspaceName
    Workbooks = $Workbooks
}

$WorkbooksJson = $WorkbooksBackup | ConvertTo-Json -Depth 10
$WorkbooksFileName = "workbooks_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
Set-AzStorageBlobContent -File $WorkbooksFileName -Container $BackupContainer -Context $StorageContext -Blob $WorkbooksFileName

Write-Host "✅ Workbooks Backup: COMPLETED" -ForegroundColor Green

# Export hunting queries
$HuntingQueries = Get-AzSentinelHuntingRule -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName
$HuntingBackup = @{
    ExportDate = Get-Date
    WorkspaceName = $WorkspaceName
    HuntingQueries = $HuntingQueries
}

$HuntingJson = $HuntingBackup | ConvertTo-Json -Depth 10
$HuntingFileName = "hunting_queries_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
Set-AzStorageBlobContent -File $HuntingFileName -Container $BackupContainer -Context $StorageContext -Blob $HuntingFileName

Write-Host "✅ Hunting Queries Backup: COMPLETED" -ForegroundColor Green
Write-Host "Workspace Backup Test: COMPLETED SUCCESSFULLY" -ForegroundColor Cyan
```

### Multi-Region Failover Testing
```powershell
# Test multi-region deployment failover capabilities
param(
    [string]$PrimaryRegion = "East US 2",
    [string]$SecondaryRegion = "West US 2",
    [string]$FailoverResourceGroup = "rg-sentinel-dr-wus2-001"
)

Write-Host "Starting Multi-Region Failover Test..." -ForegroundColor Cyan

# Verify secondary region workspace
try {
    $SecondaryWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $FailoverResourceGroup -Name "law-sentinel-dr-wus2-001"
    Write-Host "✅ Secondary Workspace Available: $($SecondaryWorkspace.Name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Secondary Workspace Test: FAILED - $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Test data replication status
$ReplicationQuery = @"
Heartbeat
| where TimeGenerated >= ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer, _ResourceId
| extend Region = extract(@"resourceGroups/([^/]+)/", 1, _ResourceId)
| summarize Computers = count() by Region
"@

$ReplicationResult = Invoke-AzOperationalInsightsQuery -WorkspaceId $SecondaryWorkspace.CustomerId -Query $ReplicationQuery

if ($ReplicationResult.Results.Count -gt 0) {
    Write-Host "✅ Data Replication Test: PASSED" -ForegroundColor Green
    $ReplicationResult.Results | Format-Table
} else {
    Write-Host "❌ Data Replication Test: FAILED - No replicated data found" -ForegroundColor Red
}

# Test analytics rule deployment in secondary region
$PrimaryRules = Get-AzSentinelAlertRule -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName
$SecondaryRules = Get-AzSentinelAlertRule -ResourceGroupName $FailoverResourceGroup -WorkspaceName "law-sentinel-dr-wus2-001"

$RuleParity = $PrimaryRules.Count -eq $SecondaryRules.Count

Write-Host "Analytics Rules Parity Test: $(if($RuleParity) {'PASSED'} else {'FAILED'})" -ForegroundColor $(if($RuleParity) {'Green'} else {'Red'})
Write-Host "  Primary Region Rules: $($PrimaryRules.Count)" -ForegroundColor White
Write-Host "  Secondary Region Rules: $($SecondaryRules.Count)" -ForegroundColor White

Write-Host "Multi-Region Failover Test: COMPLETED" -ForegroundColor Cyan
```

## Automated Testing Pipeline

### CI/CD Testing Integration
```yaml
# Azure DevOps Pipeline for Sentinel Testing
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    include:
      - analytics-rules/*
      - workbooks/*
      - hunting-queries/*

variables:
  - group: sentinel-testing-variables
  - name: testWorkspaceRG
    value: 'rg-sentinel-test-eus2-001'
  - name: testWorkspaceName
    value: 'law-sentinel-test-eus2-001'

stages:
- stage: ValidateConfiguration
  displayName: 'Validate Sentinel Configuration'
  jobs:
  - job: AnalyticsRuleValidation
    displayName: 'Validate Analytics Rules'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: AzurePowerShell@5
      displayName: 'Syntax Validation'
      inputs:
        azureSubscription: '$(azureServiceConnection)'
        ScriptType: 'FilePath'
        ScriptPath: 'testing/validate-analytics-rules.ps1'
        ScriptArguments: '-ConfigPath "./analytics-rules" -WorkspaceRG "$(testWorkspaceRG)" -WorkspaceName "$(testWorkspaceName)"'
        azurePowerShellVersion: 'LatestVersion'
    
  - job: SecurityTesting
    displayName: 'Security Tests'
    dependsOn: AnalyticsRuleValidation
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: AzurePowerShell@5
      displayName: 'Run Security Tests'
      inputs:
        azureSubscription: '$(azureServiceConnection)'
        ScriptType: 'FilePath'
        ScriptPath: 'testing/run-security-tests.ps1'
        ScriptArguments: '-TestSuite "Detection,Performance,Integration" -WorkspaceRG "$(testWorkspaceRG)" -WorkspaceName "$(testWorkspaceName)"'
        azurePowerShellVersion: 'LatestVersion'

- stage: DeployToProduction
  displayName: 'Deploy to Production'
  dependsOn: ValidateConfiguration
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: ProductionDeployment
    displayName: 'Deploy to Production Workspace'
    environment: 'sentinel-production'
    pool:
      vmImage: 'ubuntu-latest'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzurePowerShell@5
            displayName: 'Deploy Sentinel Configuration'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              ScriptType: 'FilePath'
              ScriptPath: 'deployment/deploy-sentinel-config.ps1'
              ScriptArguments: '-ConfigPath "./analytics-rules" -WorkspaceRG "$(prodWorkspaceRG)" -WorkspaceName "$(prodWorkspaceName)"'
              azurePowerShellVersion: 'LatestVersion'

          - task: AzurePowerShell@5
            displayName: 'Post-Deployment Validation'
            inputs:
              azureSubscription: '$(azureServiceConnection)'
              ScriptType: 'FilePath'
              ScriptPath: 'testing/validate-production-deployment.ps1'
              ScriptArguments: '-WorkspaceRG "$(prodWorkspaceRG)" -WorkspaceName "$(prodWorkspaceName)"'
              azurePowerShellVersion: 'LatestVersion'
```

### Continuous Security Validation
```powershell
# Automated testing scheduler script
param(
    [string]$TestSchedule = "Daily",  # Daily, Weekly, Monthly
    [string[]]$TestSuites = @("Detection", "Performance", "DataQuality", "Compliance")
)

# Configure test schedule
switch ($TestSchedule) {
    "Daily" {
        $TestInterval = New-TimeSpan -Hours 24
        $LightweightTests = @("Detection", "DataQuality")
        $ScheduledTestSuites = $LightweightTests
    }
    "Weekly" {
        $TestInterval = New-TimeSpan -Days 7
        $ScheduledTestSuites = @("Detection", "Performance", "DataQuality", "Integration")
    }
    "Monthly" {
        $TestInterval = New-TimeSpan -Days 30
        $ScheduledTestSuites = $TestSuites  # All test suites
    }
}

# Create scheduled task for automated testing
$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"$PSScriptRoot\run-sentinel-tests.ps1`" -TestSuites $($ScheduledTestSuites -join ',')"
$TaskTrigger = New-ScheduledTaskTrigger -Daily -At "02:00AM"
$TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "Sentinel_Automated_Testing_$TestSchedule" -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings -Description "Automated Azure Sentinel testing - $TestSchedule schedule"

Write-Host "Scheduled $TestSchedule testing configured for test suites: $($ScheduledTestSuites -join ', ')" -ForegroundColor Green
```

This comprehensive testing procedures document provides structured methodologies for validating Azure Sentinel SIEM implementations across all deployment phases, ensuring security effectiveness, performance optimization, and operational readiness for enterprise security operations.
# Azure Sentinel SIEM - Training Materials

## Overview

This comprehensive training curriculum provides structured learning paths for security teams adopting Azure Sentinel SIEM. The materials cover technical implementation, operational procedures, and advanced security analysis techniques to build effective security operations center (SOC) capabilities.

**Training Philosophy**: Hands-on learning with real-world security scenarios  
**Target Audience**: SOC analysts, security engineers, incident responders, security managers  
**Delivery Methods**: Self-paced learning, instructor-led training, hands-on labs, certification paths  
**Skills Validation**: Practical assessments, scenario-based testing, certification requirements

## Learning Paths and Role-Based Training

### Foundation Track - Security Operations Fundamentals (2-3 weeks)

#### Prerequisites
- Basic understanding of networking concepts (TCP/IP, DNS, firewalls)
- Familiarity with Windows and Linux operating systems
- Basic knowledge of cybersecurity principles and terminology
- Understanding of log analysis and SIEM concepts

#### Module 1: Azure Sentinel Overview and Architecture (4 hours)
**Learning Objectives:**
- Understand Azure Sentinel architecture and core components
- Identify data sources and ingestion methods
- Navigate the Azure Sentinel workspace and interface
- Comprehend the security operations workflow

**Topics Covered:**
- Cloud SIEM evolution and Azure Sentinel positioning
- Azure Sentinel architecture: Log Analytics, data connectors, analytics rules
- Workspace configuration and management
- Integration with Microsoft security ecosystem
- Cost management and optimization strategies

**Hands-on Lab 1: Workspace Setup and Configuration**
```powershell
# Lab Exercise: Create and configure Azure Sentinel workspace
# Prerequisites: Azure subscription with Contributor permissions

# Step 1: Create resource group for Sentinel
New-AzResourceGroup -Name "rg-training-sentinel-001" -Location "East US 2"

# Step 2: Create Log Analytics workspace
$Workspace = New-AzOperationalInsightsWorkspace `
    -ResourceGroupName "rg-training-sentinel-001" `
    -Name "law-training-sentinel-001" `
    -Location "East US 2" `
    -Sku "PerGB2018" `
    -RetentionInDays 90

# Step 3: Enable Azure Sentinel
Enable-AzSentinel -ResourceGroupName "rg-training-sentinel-001" -WorkspaceName "law-training-sentinel-001"

# Step 4: Verify deployment
Get-AzOperationalInsightsWorkspace -ResourceGroupName "rg-training-sentinel-001" | Format-List
```

**Knowledge Check:**
1. What are the core components of Azure Sentinel architecture?
2. How does data flow from sources to analytics in Azure Sentinel?
3. What factors influence Azure Sentinel pricing and cost optimization?

#### Module 2: Data Sources and Connectors (6 hours)
**Learning Objectives:**
- Configure major data connectors (Azure, Microsoft 365, Windows, Syslog)
- Understand data normalization and schema mapping
- Troubleshoot data ingestion issues
- Monitor data connector health and performance

**Topics Covered:**
- Azure service connectors (Activity, Security Center, Azure AD)
- Microsoft 365 connectors (Office 365, Microsoft Defender)
- Windows Security Events and Syslog configuration
- Third-party connectors and custom log ingestion
- Data parsing, transformation, and enrichment
- Connector troubleshooting and optimization

**Hands-on Lab 2: Data Connector Configuration**
```powershell
# Lab Exercise: Configure essential data connectors

# Enable Azure Activity Log connector
$SubscriptionId = (Get-AzContext).Subscription.Id
New-AzSentinelDataConnector -ResourceGroupName "rg-training-sentinel-001" `
    -WorkspaceName "law-training-sentinel-001" `
    -Kind "AzureActivity" `
    -SubscriptionId $SubscriptionId

# Enable Azure Security Center connector
New-AzSentinelDataConnector -ResourceGroupName "rg-training-sentinel-001" `
    -WorkspaceName "law-training-sentinel-001" `
    -Kind "AzureSecurityCenter" `
    -SubscriptionId $SubscriptionId

# Verify data ingestion
Start-Sleep -Seconds 300
$DataCheck = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query @"
union AzureActivity, SecurityAlert
| where TimeGenerated >= ago(24h)
| summarize count() by $table
"@

Write-Host "Data Ingestion Status:" -ForegroundColor Green
$DataCheck.Results | Format-Table
```

**Knowledge Check:**
1. Which data connector would you use for Office 365 email security events?
2. How do you troubleshoot a data connector showing "No data received"?
3. What is the difference between CEF and Syslog data formats?

#### Module 3: KQL (Kusto Query Language) Fundamentals (8 hours)
**Learning Objectives:**
- Master KQL syntax and operators
- Write effective security queries for threat hunting
- Optimize query performance and resource usage
- Create custom functions and saved queries

**Topics Covered:**
- KQL syntax, operators, and data types
- Table operations: where, project, summarize, join, union
- Time series analysis and aggregation functions
- Advanced KQL techniques: regex, parsing, mathematical operations
- Query optimization and performance best practices
- Creating and managing saved queries and functions

**Hands-on Lab 3: KQL Security Queries**
```kql
// Lab Exercise: Essential KQL queries for security analysis

// 1. Failed login attempts analysis
SigninLogs
| where TimeGenerated >= ago(24h)
| where ResultType != "0"  // Failed logins
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress
| where FailedAttempts >= 5
| order by FailedAttempts desc

// 2. Suspicious PowerShell execution
SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID == 4688  // Process creation
| where Process contains "powershell.exe"
| extend CommandLine = tostring(EventData.CommandLine)
| where CommandLine contains "Download" or CommandLine contains "Invoke-" or CommandLine contains "IEX"
| project TimeGenerated, Computer, Account, CommandLine
| order by TimeGenerated desc

// 3. Privilege escalation detection
SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID in (4672, 4673, 4674)  // Privilege use events
| summarize PrivilegeEvents = count() by Account, Computer
| where PrivilegeEvents >= 10
| join kind=inner (
    SecurityEvent
    | where EventID == 4624  // Successful logon
    | where LogonType in (3, 10)  // Network and RDP logons
    | project Account, Computer, LogonTime = TimeGenerated
) on Account, Computer
| project Account, Computer, PrivilegeEvents, LogonTime
| order by PrivilegeEvents desc

// 4. Network anomaly detection
NetworkCommunications
| where TimeGenerated >= ago(24h)
| summarize BytesSent = sum(SentBytes), BytesReceived = sum(ReceivedBytes) by Computer, RemoteIP
| where BytesSent > 1000000 or BytesReceived > 1000000  // > 1MB threshold
| extend TotalTraffic = BytesSent + BytesReceived
| order by TotalTraffic desc
| take 20
```

**Practical Exercise: Build Your First Hunting Query**
```kql
// Student Exercise: Create a query to detect lateral movement
// Requirements:
// 1. Find accounts that logged into multiple computers within 1 hour
// 2. Exclude service accounts and computer accounts
// 3. Focus on interactive logon types (2, 10, 11)
// 4. Show timeline of logon events

// Solution template (students fill in the logic):
SecurityEvent
| where TimeGenerated >= ago(___) // Time range
| where EventID == ____  // Logon event
| where LogonType in (__, __, __) // Interactive logon types
| where not(Account endswith "$" or Account startswith "NT SERVICE") // Exclude service accounts
| extend LogonHour = bin(TimeGenerated, 1h)
| summarize Computers = dcount(Computer), ComputerList = make_set(Computer) by Account, LogonHour
| where Computers >= __ // Multiple computers threshold
| order by LogonHour desc
```

**Knowledge Check:**
1. Write a KQL query to find the top 10 source IPs by failed login attempts
2. How would you optimize a query that's timing out due to large data volume?
3. What's the difference between `summarize count()` and `summarize dcount()`?

#### Module 4: Analytics Rules and Detection Engineering (6 hours)
**Learning Objectives:**
- Understand analytics rule types and use cases
- Create and tune custom detection rules
- Implement MITRE ATT&CK framework mapping
- Manage false positives and rule optimization

**Topics Covered:**
- Analytics rule types: scheduled, near real-time, machine learning
- Detection engineering methodology and best practices
- MITRE ATT&CK framework integration and mapping
- Rule creation workflow: query development, testing, deployment
- False positive analysis and rule tuning strategies
- Rule performance optimization and resource management

**Hands-on Lab 4: Custom Analytics Rule Creation**
```json
// Lab Exercise: Create a brute force detection rule
{
  "displayName": "Brute Force Attack Detection",
  "description": "Detects multiple failed login attempts from a single source IP within a short time frame",
  "severity": "Medium",
  "enabled": true,
  "query": "SigninLogs\n| where TimeGenerated >= ago(1h)\n| where ResultType !in (\"0\", \"50125\", \"50140\")\n| where UserPrincipalName != \"\"\n| summarize FailedAttempts = count(), Users = make_set(UserPrincipalName), Applications = make_set(AppDisplayName) by IPAddress\n| where FailedAttempts >= 10\n| extend ThreatLevel = case(\n    FailedAttempts >= 50, \"High\",\n    FailedAttempts >= 25, \"Medium\",\n    \"Low\"\n)\n| project IPAddress, FailedAttempts, ThreatLevel, Users, Applications",
  "queryFrequency": "PT1H",
  "queryPeriod": "PT1H",
  "triggerOperator": "GreaterThan",
  "triggerThreshold": 0,
  "suppressionDuration": "PT6H",
  "suppressionEnabled": false,
  "tactics": ["CredentialAccess", "InitialAccess"],
  "techniques": ["T1110", "T1078"],
  "entityMappings": [
    {
      "entityType": "IP",
      "fieldMappings": [
        {
          "identifier": "Address",
          "columnName": "IPAddress"
        }
      ]
    }
  ],
  "customDetails": {
    "FailedAttempts": "FailedAttempts",
    "ThreatLevel": "ThreatLevel",
    "AffectedUsers": "Users"
  },
  "alertDetailsOverride": {
    "alertDisplayNameFormat": "Brute Force Attack from {{IPAddress}} - {{FailedAttempts}} failed attempts",
    "alertDescriptionFormat": "Multiple failed login attempts detected from IP {{IPAddress}}. Total failed attempts: {{FailedAttempts}}. Threat Level: {{ThreatLevel}}. Affected users: {{Users}}"
  }
}
```

**Rule Testing and Validation Framework:**
```powershell
# Rule validation script
param(
    [string]$RuleName = "Brute Force Attack Detection",
    [string]$TestDataPath = "test-data/brute-force-scenarios.json"
)

# Load test scenarios
$TestScenarios = Get-Content $TestDataPath | ConvertFrom-Json

foreach ($Scenario in $TestScenarios) {
    Write-Host "Testing scenario: $($Scenario.Name)" -ForegroundColor Yellow
    
    # Inject test data
    $TestEvents = $Scenario.Events
    foreach ($Event in $TestEvents) {
        # Send test event to workspace
        Send-LogAnalyticsEvent -WorkspaceId $WorkspaceId -Data $Event -LogType "TestSigninLogs"
    }
    
    # Wait for rule execution
    Start-Sleep -Seconds 300
    
    # Check for expected alerts
    $Alerts = Get-AzSentinelAlert -WorkspaceName "law-training-sentinel-001" |
        Where-Object { $_.AlertName -eq $RuleName -and $_.TimeGenerated -gt (Get-Date).AddMinutes(-10) }
    
    $ExpectedAlerts = $Scenario.ExpectedAlerts
    if ($Alerts.Count -eq $ExpectedAlerts) {
        Write-Host "✅ Scenario '$($Scenario.Name)': PASSED" -ForegroundColor Green
    } else {
        Write-Host "❌ Scenario '$($Scenario.Name)': FAILED - Expected $ExpectedAlerts alerts, got $($Alerts.Count)" -ForegroundColor Red
    }
}
```

### Analyst Track - SOC Operations and Incident Response (3-4 weeks)

#### Module 5: Incident Response Procedures (8 hours)
**Learning Objectives:**
- Execute incident response workflows in Azure Sentinel
- Perform effective incident investigation and analysis
- Coordinate with stakeholders and escalate appropriately
- Document incidents and lessons learned

**Topics Covered:**
- Incident response lifecycle and Azure Sentinel integration
- Incident triage, classification, and prioritization
- Investigation techniques and forensic analysis
- Stakeholder communication and escalation procedures
- Case management and documentation requirements
- Post-incident analysis and process improvement

**Hands-on Lab 5: Incident Response Simulation**
```powershell
# Lab Exercise: Complete incident response simulation

# Scenario: Suspected data exfiltration incident
$IncidentId = "INC-2024-001-DataExfil"
$SuspiciousUser = "john.doe@contoso.com"
$SuspiciousIP = "198.51.100.99"

Write-Host "=== INCIDENT RESPONSE SIMULATION ===" -ForegroundColor Cyan
Write-Host "Incident: $IncidentId" -ForegroundColor Yellow
Write-Host "Alert: Large file download from external IP" -ForegroundColor Yellow

# Step 1: Initial triage and information gathering
Write-Host "`n1. Initial Triage" -ForegroundColor Green

$UserActivityQuery = @"
SigninLogs
| where TimeGenerated >= ago(24h)
| where UserPrincipalName == "$SuspiciousUser"
| project TimeGenerated, IPAddress, Location, DeviceDetail, AppDisplayName, ResultType
| order by TimeGenerated desc
"@

$UserActivity = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $UserActivityQuery
Write-Host "User activity events found: $($UserActivity.Results.Count)"

# Step 2: Evidence collection
Write-Host "`n2. Evidence Collection" -ForegroundColor Green

$EvidenceQueries = @{
    "FileActivity" = @"
        OfficeActivity
        | where TimeGenerated >= ago(24h)
        | where UserId == "$SuspiciousUser"
        | where Operation in ("FileDownloaded", "FileAccessed", "FileCopied")
        | project TimeGenerated, Operation, OfficeObjectId, ClientIP, UserAgent
"@
    "NetworkTraffic" = @"
        NetworkCommunications
        | where TimeGenerated >= ago(24h)
        | where SourceIP == "$SuspiciousIP" or DestinationIP == "$SuspiciousIP"
        | project TimeGenerated, SourceIP, DestinationIP, DestinationPort, SentBytes, ReceivedBytes
"@
    "SecurityEvents" = @"
        SecurityEvent
        | where TimeGenerated >= ago(24h)
        | where Account == "$SuspiciousUser"
        | where EventID in (4624, 4625, 4648, 4672)
        | project TimeGenerated, EventID, Computer, Account, WorkstationName, IpAddress
"@
}

$Evidence = @{}
foreach ($QueryName in $EvidenceQueries.Keys) {
    $Result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $EvidenceQueries[$QueryName]
    $Evidence[$QueryName] = $Result.Results
    Write-Host "$QueryName events: $($Result.Results.Count)"
}

# Step 3: Timeline reconstruction
Write-Host "`n3. Timeline Reconstruction" -ForegroundColor Green

$TimelineQuery = @"
let StartTime = ago(24h);
let EndTime = now();
let SuspiciousUser = "$SuspiciousUser";
let SuspiciousIP = "$SuspiciousIP";

union 
    (SigninLogs | where UserPrincipalName == SuspiciousUser | project TimeGenerated, EventType = "Authentication", Details = strcat("Login from ", IPAddress)),
    (OfficeActivity | where UserId == SuspiciousUser | project TimeGenerated, EventType = "FileActivity", Details = strcat(Operation, " - ", OfficeObjectId)),
    (SecurityEvent | where Account == SuspiciousUser | project TimeGenerated, EventType = "SecurityEvent", Details = strcat("EventID: ", EventID, " on ", Computer))
| where TimeGenerated between (StartTime .. EndTime)
| order by TimeGenerated asc
"@

$Timeline = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $TimelineQuery
Write-Host "Timeline events reconstructed: $($Timeline.Results.Count)"

# Step 4: Impact assessment
Write-Host "`n4. Impact Assessment" -ForegroundColor Green

$ImpactQuery = @"
OfficeActivity
| where TimeGenerated >= ago(24h)
| where UserId == "$SuspiciousUser"
| where Operation == "FileDownloaded"
| summarize 
    TotalFiles = count(),
    TotalSizeBytes = sum(Size),
    UniqueLocations = dcount(ClientIP),
    FileTypes = make_set(OfficeObjectId)
| extend TotalSizeMB = round(TotalSizeBytes / 1024 / 1024, 2)
"@

$Impact = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $ImpactQuery
if ($Impact.Results.Count -gt 0) {
    $ImpactData = $Impact.Results[0]
    Write-Host "Files downloaded: $($ImpactData.TotalFiles)"
    Write-Host "Total size: $($ImpactData.TotalSizeMB) MB"
    Write-Host "Unique locations: $($ImpactData.UniqueLocations)"
}

# Step 5: Containment recommendations
Write-Host "`n5. Containment Recommendations" -ForegroundColor Green
Write-Host "- Disable user account: $SuspiciousUser"
Write-Host "- Block IP address: $SuspiciousIP"
Write-Host "- Review and restrict file sharing permissions"
Write-Host "- Monitor for additional lateral movement"

# Step 6: Documentation
$IncidentReport = @{
    IncidentId = $IncidentId
    DetectionTime = Get-Date
    Analyst = $env:USERNAME
    SuspiciousEntities = @($SuspiciousUser, $SuspiciousIP)
    Evidence = $Evidence
    Timeline = $Timeline.Results
    Impact = $Impact.Results
    Recommendations = @(
        "Disable user account immediately",
        "Block suspicious IP address",
        "Review file access permissions",
        "Implement additional monitoring"
    )
    Status = "Investigation Complete"
}

$IncidentReport | ConvertTo-Json -Depth 5 | Out-File "incident_report_$IncidentId.json"
Write-Host "`n6. Incident documented: incident_report_$IncidentId.json" -ForegroundColor Green
```

**Incident Response Checklist Template:**
```markdown
# Incident Response Checklist

## Initial Response (0-30 minutes)
- [ ] Incident assigned to analyst
- [ ] Initial scope and severity assessment
- [ ] Stakeholder notification (if P1/P2)
- [ ] Evidence preservation initiated
- [ ] Containment actions considered

## Investigation Phase (30 minutes - 4 hours)
- [ ] Detailed evidence collection
- [ ] Timeline reconstruction
- [ ] Impact assessment
- [ ] Root cause analysis
- [ ] Additional threat indicators identified

## Containment and Eradication (1-8 hours)
- [ ] Immediate threats contained
- [ ] Systems isolated if necessary
- [ ] Malware/threats removed
- [ ] Security controls updated
- [ ] Vulnerability remediation initiated

## Recovery and Lessons Learned (1-7 days)
- [ ] Systems restored and validated
- [ ] Monitoring enhanced
- [ ] Documentation completed
- [ ] Lessons learned session conducted
- [ ] Process improvements implemented
```

#### Module 6: Threat Hunting Techniques (10 hours)
**Learning Objectives:**
- Develop hypothesis-driven threat hunting methodology
- Create and execute advanced hunting queries
- Use threat intelligence to guide hunting activities
- Document and share hunting findings effectively

**Topics Covered:**
- Threat hunting methodology and hypothesis development
- Advanced KQL techniques for security analysis
- Behavioral analysis and anomaly detection
- Threat intelligence integration and IOC hunting
- Hunt documentation and knowledge sharing
- Automated hunting and alerting strategies

**Advanced Hunting Queries Collection:**
```kql
// Hunting Query 1: Detect living-off-the-land techniques
SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID == 4688  // Process creation
| extend ProcessName = tostring(split(NewProcessName, "\\")[-1])
| where ProcessName in ("certutil.exe", "bitsadmin.exe", "wmic.exe", "regsvr32.exe")
| extend CommandLine = tostring(EventData.CommandLine)
| where CommandLine contains "http" or CommandLine contains "download" or CommandLine contains "urlcache"
| project TimeGenerated, Computer, Account, ProcessName, CommandLine
| join kind=inner (
    // Correlate with network connections
    NetworkCommunications
    | where TimeGenerated >= ago(24h)
    | project Computer, TimeGenerated, RemoteIP, RemotePort, ProcessName
) on Computer, ProcessName
| where abs(datetime_diff('second', TimeGenerated, TimeGenerated1)) <= 300  // Within 5 minutes
| project TimeGenerated, Computer, Account, ProcessName, CommandLine, RemoteIP, RemotePort

// Hunting Query 2: Suspicious email forwarding rules
OfficeActivity
| where TimeGenerated >= ago(7d)
| where Operation in ("New-InboxRule", "Set-InboxRule")
| extend RuleActions = tostring(ExtendedProperties.Actions)
| where RuleActions contains "ForwardTo" or RuleActions contains "RedirectTo"
| extend ForwardingAddress = extract(@'ForwardTo":\["([^"]+)"', 1, RuleActions)
| where ForwardingAddress !endswith "@yourdomain.com"  // External forwarding
| project TimeGenerated, UserId, Operation, ForwardingAddress, RuleActions
| join kind=inner (
    // Check for recent suspicious activities
    SigninLogs
    | where TimeGenerated >= ago(7d)
    | where RiskLevelDuringSignIn == "high" or RiskLevelAggregated == "high"
    | project UserPrincipalName, RiskDetection = TimeGenerated
) on $left.UserId == $right.UserPrincipalName
| project TimeGenerated, UserId, Operation, ForwardingAddress, RiskDetection

// Hunting Query 3: Privilege escalation patterns
let PrivilegeEscalationEvents = SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID in (4672, 4673, 4674, 4728, 4732, 4756)  // Privilege use and group membership changes
| extend EventType = case(
    EventID == 4672, "Special privileges assigned",
    EventID == 4673, "Privileged service called",
    EventID == 4674, "Operation attempted on privileged object",
    EventID == 4728, "Member added to global security group",
    EventID == 4732, "Member added to local security group",
    EventID == 4756, "Member added to universal security group",
    "Other"
)
| project TimeGenerated, Computer, Account, EventType, EventID;

let UserLogons = SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID == 4624 and LogonType in (2, 3, 10)  // Interactive, network, RDP
| project LogonTime = TimeGenerated, Computer, Account, LogonType;

PrivilegeEscalationEvents
| join kind=inner UserLogons on Computer, Account
| where datetime_diff('minute', TimeGenerated, LogonTime) between (0 .. 60)  // Within 1 hour of logon
| summarize 
    PrivilegeEvents = count(),
    EventTypes = make_set(EventType),
    FirstEvent = min(TimeGenerated),
    LastEvent = max(TimeGenerated)
by Account, Computer, LogonTime
| where PrivilegeEvents >= 3  // Multiple privilege events
| order by PrivilegeEvents desc

// Hunting Query 4: Data exfiltration indicators
let LargeTransfers = NetworkCommunications
| where TimeGenerated >= ago(24h)
| where SentBytes > 10485760  // > 10MB
| summarize TotalBytes = sum(SentBytes) by Computer, RemoteIP, RemotePort
| where TotalBytes > 104857600  // > 100MB total
| extend TransferSizeMB = round(TotalBytes / 1024 / 1024, 2);

let OffHoursActivity = NetworkCommunications
| where TimeGenerated >= ago(24h)
| extend Hour = datetime_part('hour', TimeGenerated)
| where Hour < 6 or Hour > 22  // Off-hours activity
| summarize OffHoursBytes = sum(SentBytes) by Computer, RemoteIP
| where OffHoursBytes > 52428800;  // > 50MB off-hours

LargeTransfers
| join kind=inner OffHoursActivity on Computer, RemoteIP
| join kind=inner (
    // Correlate with user activity
    SecurityEvent
    | where EventID == 4624
    | project Computer, Account, LogonTime = TimeGenerated
) on Computer
| project Computer, Account, RemoteIP, TransferSizeMB, OffHoursBytes, LogonTime
| order by TransferSizeMB desc
```

**Threat Hunting Methodology Framework:**
```markdown
# Threat Hunting Cycle

## 1. Hypothesis Development
- Based on threat intelligence
- Informed by security incidents
- Focused on specific attack techniques
- Aligned with business risk priorities

## 2. Data Collection and Analysis
- Identify relevant data sources
- Develop hunting queries
- Execute analysis workflows
- Document findings and observations

## 3. Investigation and Validation
- Validate suspicious activities
- Correlate multiple data sources
- Eliminate false positives
- Confirm threat presence

## 4. Response and Improvement
- Escalate confirmed threats
- Update detection rules
- Share intelligence with team
- Improve hunting techniques

## Hunt Documentation Template
- **Hunt Name**: [Descriptive name]
- **Hypothesis**: [What are we looking for?]
- **Data Sources**: [Which logs/data?]
- **Queries**: [KQL queries used]
- **Findings**: [What was discovered?]
- **Actions**: [Next steps taken]
- **Lessons**: [What was learned?]
```

### Advanced Track - Security Engineering and Administration (4-5 weeks)

#### Module 7: Advanced Analytics and Machine Learning (12 hours)
**Learning Objectives:**
- Implement User and Entity Behavior Analytics (UEBA)
- Deploy and tune machine learning models
- Create custom machine learning analytics rules
- Optimize anomaly detection for environment-specific baselines

**Topics Covered:**
- UEBA concepts and implementation in Azure Sentinel
- Machine learning analytics rules and anomaly detection
- Behavioral baselines and threshold tuning
- Custom ML model development and deployment
- Anomaly detection optimization and false positive reduction
- Advanced analytics performance monitoring

**Hands-on Lab 6: UEBA Implementation**
```powershell
# Lab Exercise: Configure UEBA and anomaly detection

# Enable UEBA data sources
$UebaDataSources = @(
    "SecurityEvent",
    "AuditLogs", 
    "SigninLogs",
    "OfficeActivity",
    "AzureActivity"
)

# Configure UEBA settings
$UebaConfig = @{
    ResourceGroupName = "rg-training-sentinel-001"
    WorkspaceName = "law-training-sentinel-001"
    DataSources = $UebaDataSources
    LearningPeriod = 14  # Days for baseline learning
    SensitivityLevel = "Medium"
}

# Enable UEBA (PowerShell example - actual API may vary)
Enable-AzSentinelUeba @UebaConfig

Write-Host "UEBA enabled for data sources: $($UebaDataSources -join ', ')" -ForegroundColor Green
```

**Custom ML Analytics Rule Example:**
```json
{
  "displayName": "Anomalous User Authentication Behavior",
  "description": "Detects unusual authentication patterns using machine learning",
  "severity": "Medium",
  "enabled": true,
  "query": "let LearningPeriod = 30d;\nlet DetectionPeriod = 1d;\nlet Threshold = 3.0; // Standard deviations\n\n// Build user authentication baseline\nlet UserBaseline = SigninLogs\n| where TimeGenerated between ((now() - LearningPeriod) .. (now() - DetectionPeriod))\n| where ResultType == \"0\"\n| summarize \n    AvgLoginsPerDay = avg(todecimal(1)),\n    StdDevLoginsPerDay = stdev(todecimal(1)),\n    TypicalLocations = make_set(LocationDetails.countryOrRegion),\n    TypicalApps = make_set(AppDisplayName)\nby UserPrincipalName\n| extend \n    UpperThreshold = AvgLoginsPerDay + (Threshold * StdDevLoginsPerDay),\n    LowerThreshold = max_of(AvgLoginsPerDay - (Threshold * StdDevLoginsPerDay), 0);\n\n// Detect anomalous current behavior\nlet CurrentBehavior = SigninLogs\n| where TimeGenerated >= ago(DetectionPeriod)\n| where ResultType == \"0\"\n| summarize \n    CurrentLogins = count(),\n    CurrentLocations = make_set(LocationDetails.countryOrRegion),\n    CurrentApps = make_set(AppDisplayName)\nby UserPrincipalName;\n\n// Join and identify anomalies\nUserBaseline\n| join kind=inner CurrentBehavior on UserPrincipalName\n| extend \n    VolumeAnomaly = CurrentLogins > UpperThreshold or CurrentLogins < LowerThreshold,\n    LocationAnomaly = array_length(set_difference(CurrentLocations, TypicalLocations)) > 0,\n    AppAnomaly = array_length(set_difference(CurrentApps, TypicalApps)) > 1\n| where VolumeAnomaly or LocationAnomaly or AppAnomaly\n| project \n    UserPrincipalName,\n    CurrentLogins,\n    AvgLoginsPerDay,\n    VolumeAnomaly,\n    LocationAnomaly,\n    AppAnomaly,\n    NewLocations = set_difference(CurrentLocations, TypicalLocations),\n    NewApps = set_difference(CurrentApps, TypicalApps)",
  "queryFrequency": "P1D",
  "queryPeriod": "P31D",
  "triggerOperator": "GreaterThan",
  "triggerThreshold": 0,
  "tactics": ["CredentialAccess", "InitialAccess"],
  "techniques": ["T1078"]
}
```

#### Module 8: Automation and Orchestration (10 hours)
**Learning Objectives:**
- Design and implement security playbooks using Logic Apps
- Automate incident response workflows
- Integrate with third-party security tools and services
- Monitor and optimize automation performance

**Topics Covered:**
- Azure Logic Apps for security orchestration
- Playbook design patterns and best practices
- Integration with Microsoft Graph, Azure AD, and third-party APIs
- Conditional logic and decision trees in automation
- Error handling and retry mechanisms
- Performance monitoring and optimization

**Hands-on Lab 7: Advanced Security Playbook**
```json
{
  "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "$connections": {
      "defaultValue": {},
      "type": "Object"
    }
  },
  "triggers": {
    "When_Azure_Sentinel_incident_creation_rule_was_triggered": {
      "type": "ApiConnectionWebhook",
      "inputs": {
        "body": {
          "callback_url": "@{listCallbackUrl()}"
        },
        "host": {
          "connection": {
            "name": "@parameters('$connections')['azuresentinel']['connectionId']"
          }
        },
        "path": "/incident-creation"
      }
    }
  },
  "actions": {
    "Initialize_Incident_Variables": {
      "type": "InitializeVariable",
      "inputs": {
        "variables": [
          {
            "name": "IncidentTitle",
            "type": "string",
            "value": "@triggerBody()?['object']?['properties']?['title']"
          },
          {
            "name": "IncidentSeverity", 
            "type": "string",
            "value": "@triggerBody()?['object']?['properties']?['severity']"
          },
          {
            "name": "CompromisedEntities",
            "type": "array",
            "value": "@triggerBody()?['object']?['properties']?['relatedEntities']"
          }
        ]
      }
    },
    "Check_Incident_Severity": {
      "type": "Switch",
      "expression": "@variables('IncidentSeverity')",
      "cases": {
        "High_Severity": {
          "case": "High",
          "actions": {
            "Send_Teams_Notification": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['teams']['connectionId']"
                  }
                },
                "method": "post",
                "path": "/v1.0/teams/@{encodeURIComponent('your-team-id')}/channels/@{encodeURIComponent('your-channel-id')}/messages",
                "body": {
                  "body": {
                    "content": "🚨 **HIGH SEVERITY INCIDENT DETECTED** 🚨\n\n**Title:** @{variables('IncidentTitle')}\n\n**Time:** @{utcNow()}\n\n**Action Required:** Immediate investigation needed\n\n[View Incident in Sentinel](incident-url)"
                  }
                }
              }
            },
            "Disable_Compromised_Users": {
              "type": "Foreach",
              "foreach": "@variables('CompromisedEntities')",
              "actions": {
                "Check_Entity_Type": {
                  "type": "If",
                  "expression": {
                    "and": [
                      {
                        "equals": [
                          "@item()?['kind']",
                          "Account"
                        ]
                      }
                    ]
                  },
                  "actions": {
                    "Disable_User_Account": {
                      "type": "ApiConnection",
                      "inputs": {
                        "host": {
                          "connection": {
                            "name": "@parameters('$connections')['azuread']['connectionId']"
                          }
                        },
                        "method": "patch",
                        "path": "/v1.0/users/@{encodeURIComponent(item()?['properties']?['userPrincipalName'])}",
                        "body": {
                          "accountEnabled": false
                        }
                      }
                    },
                    "Add_Comment_to_Incident": {
                      "type": "ApiConnection",
                      "inputs": {
                        "host": {
                          "connection": {
                            "name": "@parameters('$connections')['azuresentinel']['connectionId']"
                          }
                        },
                        "method": "post",
                        "path": "/Incidents/subscriptions/@{encodeURIComponent('subscription-id')}/resourceGroups/@{encodeURIComponent('resource-group')}/workspaces/@{encodeURIComponent('workspace-name')}/incidents/@{encodeURIComponent(triggerBody()?['object']?['name'])}/comments",
                        "body": {
                          "properties": {
                            "message": "🔒 Automated response: Disabled user account @{item()?['properties']?['userPrincipalName']} due to high severity incident detection."
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          ]
        },
        "Medium_Severity": {
          "case": "Medium", 
          "actions": {
            "Create_ServiceNow_Ticket": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['servicenow']['connectionId']"
                  }
                },
                "method": "post",
                "path": "/api/now/table/incident",
                "body": {
                  "short_description": "Azure Sentinel Incident: @{variables('IncidentTitle')}",
                  "description": "Security incident detected in Azure Sentinel requiring investigation.\n\nIncident Details:\n- Title: @{variables('IncidentTitle')}\n- Severity: @{variables('IncidentSeverity')}\n- Detection Time: @{utcNow()}\n\nPlease investigate and coordinate with security team.",
                  "urgency": "2",
                  "impact": "2",
                  "category": "Security",
                  "subcategory": "Incident Response"
                }
              }
            }
          ]
        }
      },
      "default": {
        "actions": {
          "Log_Low_Priority_Incident": {
            "type": "Compose",
            "inputs": {
              "message": "Low priority incident logged for review",
              "incident": "@variables('IncidentTitle')",
              "time": "@utcNow()"
            }
          }
        }
      }
    }
  }
}
```

#### Module 9: Performance Optimization and Cost Management (8 hours)
**Learning Objectives:**
- Monitor and optimize Azure Sentinel performance
- Implement cost optimization strategies
- Manage data retention and archival policies
- Scale Azure Sentinel for enterprise environments

**Topics Covered:**
- Performance monitoring and query optimization
- Cost management and billing optimization strategies
- Data retention policies and long-term archival
- Workspace scaling and multi-tenant architectures
- Resource management and capacity planning
- Optimization tools and best practices

**Performance Optimization Lab:**
```kql
// Query optimization examples

// Original slow query
SecurityEvent
| where TimeGenerated >= ago(30d)
| where Account contains "admin"
| join kind=inner (
    SigninLogs 
    | where TimeGenerated >= ago(30d)
    | where UserPrincipalName contains "admin"
) on $left.Account == $right.UserPrincipalName

// Optimized version
let AdminAccounts = SecurityEvent
| where TimeGenerated >= ago(30d)
| where Account has_any ("admin", "administrator", "root")  // Use has_any instead of contains
| distinct Account;

let AdminSignins = SigninLogs
| where TimeGenerated >= ago(30d)
| where UserPrincipalName has_any ("admin", "administrator")
| project UserPrincipalName, TimeGenerated, IPAddress, ResultType;

AdminAccounts
| join kind=inner AdminSignins on $left.Account == $right.UserPrincipalName
| project TimeGenerated, Account, IPAddress, ResultType
| order by TimeGenerated desc
```

**Cost Optimization Dashboard:**
```kql
// Daily ingestion costs by data type
Usage
| where TimeGenerated >= ago(30d)
| where IsBillable == true
| summarize BillableDataGB = sum(Quantity) by bin(TimeGenerated, 1d), DataType
| extend DailyCost = BillableDataGB * 2.76  // Approximate cost per GB
| summarize 
    AvgDailyCost = avg(DailyCost),
    MaxDailyCost = max(DailyCost),
    TotalMonthlyCost = sum(DailyCost)
by DataType
| order by TotalMonthlyCost desc
```

## Certification and Assessment

### Practical Skills Assessment Framework

#### Level 1: SOC Analyst Certification
**Assessment Requirements:**
- Complete incident response simulation with 85% accuracy
- Demonstrate proficiency in KQL with complex security queries
- Execute threat hunting exercises and document findings
- Show competency in playbook execution and escalation procedures

**Hands-on Assessment Scenario:**
```markdown
# SOC Analyst Practical Assessment

## Scenario Overview
You are a SOC analyst investigating suspicious activities in the Azure Sentinel environment. Multiple alerts have been generated, and you need to investigate, analyze, and respond appropriately.

## Assessment Tasks (4 hours)

### Task 1: Alert Triage (45 minutes)
- Review and prioritize 10 different security alerts
- Classify each alert as true positive, false positive, or requires investigation
- Provide justification for each classification decision
- Identify the top 3 alerts requiring immediate attention

### Task 2: Incident Investigation (90 minutes)
- Investigate a potential data breach incident
- Use KQL queries to gather evidence from multiple data sources
- Reconstruct timeline of events
- Identify affected systems, users, and potential data exposure
- Document findings in incident report format

### Task 3: Threat Hunting (60 minutes)
- Given a specific threat intelligence indicator, hunt for evidence of compromise
- Develop and execute KQL hunting queries
- Analyze results and identify suspicious activities
- Document hunting methodology and findings

### Task 4: Response Actions (45 minutes)
- Execute appropriate containment actions for identified threats
- Use automation playbooks where applicable
- Escalate incidents according to severity and procedures
- Communicate findings to stakeholders
```

#### Level 2: Senior Analyst/Security Engineer Certification
**Assessment Requirements:**
- Design and implement custom analytics rules with MITRE ATT&CK mapping
- Create advanced threat hunting queries and methodologies  
- Build automation playbooks for incident response
- Demonstrate advanced KQL techniques and performance optimization

#### Level 3: Security Architect/Team Lead Certification
**Assessment Requirements:**
- Design comprehensive Azure Sentinel architecture for enterprise deployment
- Develop security operations program and procedures
- Create training curriculum and mentor junior analysts
- Demonstrate strategic security planning and risk management

### Continuing Education Program

#### Monthly Security Updates (2 hours/month)
- Latest threat intelligence and attack techniques
- New Azure Sentinel features and capabilities
- Industry best practices and lessons learned
- Regulatory and compliance updates

#### Quarterly Deep Dive Sessions (8 hours/quarter)
- Advanced threat hunting techniques
- Emerging security technologies integration
- Case study analysis and peer learning
- Cross-functional collaboration workshops

#### Annual Security Conference Participation
- Industry conferences (RSA, Black Hat, BSides)
- Microsoft security summits and training
- Certification maintenance and renewal
- Knowledge sharing and networking

### Learning Resources and References

#### Essential Documentation
- **Azure Sentinel Documentation**: https://docs.microsoft.com/azure/sentinel/
- **KQL Reference**: https://docs.microsoft.com/azure/data-explorer/kql-quick-reference
- **MITRE ATT&CK Framework**: https://attack.mitre.org/
- **NIST Cybersecurity Framework**: https://www.nist.gov/cyberframework

#### Recommended Training Platforms
- **Microsoft Learn**: Azure Sentinel learning paths
- **Pluralsight**: Security and Azure courses
- **SANS Training**: Incident response and threat hunting
- **Cloud Security Alliance**: Cloud security best practices

#### Community Resources
- **Azure Sentinel GitHub**: Community queries and playbooks
- **Microsoft Tech Community**: Azure Sentinel discussions
- **Security Twitter**: Threat intelligence and updates
- **Local Security Meetups**: Networking and knowledge sharing

### Assessment Rubric and Scoring

#### Knowledge Assessment (40%)
- Technical understanding of Azure Sentinel architecture
- Security concepts and threat landscape awareness
- Incident response procedures and best practices
- Compliance and regulatory requirements knowledge

#### Practical Skills (40%)
- KQL query development and optimization
- Incident investigation and analysis capabilities
- Threat hunting techniques and methodology
- Automation and playbook development

#### Professional Skills (20%)
- Communication and documentation quality
- Collaboration and stakeholder management
- Problem-solving and critical thinking
- Continuous learning and adaptation

**Certification Levels:**
- **Foundation (70-79%)**: Basic SOC analyst capabilities
- **Professional (80-89%)**: Advanced analyst and specialist skills  
- **Expert (90-100%)**: Senior architect and leadership competencies

This comprehensive training curriculum provides structured learning paths for all skill levels, ensuring effective Azure Sentinel adoption and security operations excellence throughout the organization.
# Azure Sentinel SIEM - Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for managing, monitoring, and operating Azure Sentinel SIEM in production environments. The runbook covers daily operations, incident response, maintenance procedures, and escalation protocols to ensure effective security operations center (SOC) capabilities.

**Document Purpose**: Operational procedures and workflows for SOC teams  
**Target Audience**: SOC analysts, security engineers, incident responders  
**Update Frequency**: Quarterly review and updates based on operational experience  
**Version Control**: Maintain version history for procedure changes and improvements

## Daily Operations Procedures

### Morning SOC Handover (Start of Shift)

#### Shift Change Checklist
```powershell
# Connect to Azure Sentinel workspace
Connect-AzAccount
Set-AzContext -SubscriptionId "your-subscription-id"
$WorkspaceResourceGroup = "rg-security-prod-eus2-001"
$WorkspaceName = "law-security-prod-eus2-001"

# Check workspace health and status
Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceResourceGroup -Name $WorkspaceName | Format-Table

# Verify data connector status
Get-AzSentinelDataConnector -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName | 
  Select-Object Name, Kind, State | Format-Table
```

**Daily Operations Tasks:**
1. **Incident Queue Review**: Review open incidents from previous shift
2. **System Health Check**: Verify all data connectors and analytics rules are functioning
3. **Watchlist Updates**: Review and update threat intelligence watchlists
4. **Alert Triage**: Process new high-priority alerts from overnight
5. **Dashboard Review**: Check key security metrics and trends
6. **Communication**: Update incident status and brief day shift team

#### System Health Monitoring
```kql
// Data Ingestion Health Check
Heartbeat
| where TimeGenerated >= ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(10m)
| project Computer, LastHeartbeat, Status = "Missing Heartbeat"
```

```kql
// Analytics Rule Performance
SecurityAlert
| where TimeGenerated >= ago(24h)
| summarize AlertCount = count() by AlertName
| order by AlertCount desc
| take 20
```

### Incident Response Operations

#### High-Priority Incident Response (P1/P2)

**Initial Response (Within 15 minutes)**
1. **Incident Assignment**: Assign incident to appropriate analyst based on expertise
2. **Initial Assessment**: Determine incident scope and potential business impact
3. **Stakeholder Notification**: Alert security manager and business stakeholders
4. **Evidence Preservation**: Secure relevant logs and forensic evidence
5. **Investigation Initiation**: Begin detailed investigation using Sentinel tools

**Investigation Procedures**
```kql
// Incident Timeline Reconstruction
let IncidentTime = datetime('YYYY-MM-DD HH:MM:SS');
let LookbackPeriod = 2h;

union SecurityEvent, SecurityAlert, AuditLogs, SigninLogs
| where TimeGenerated between ((IncidentTime - LookbackPeriod) .. (IncidentTime + LookbackPeriod))
| where AccountName contains "SUSPICIOUS_USER" or IPAddress == "SUSPICIOUS_IP"
| project TimeGenerated, EventType = $table, Activity, AccountName, IPAddress, Computer
| order by TimeGenerated asc
```

**Escalation Matrix**
```
P1 (Critical): 15 minutes → Security Manager → CISO (if business critical)
P2 (High): 30 minutes → Security Manager → IT Director
P3 (Medium): 2 hours → Team Lead → Security Manager (if no resolution)
P4 (Low): 8 hours → Team Lead → Queue management
```

#### Incident Documentation Template
```markdown
# Incident Report: [INC-YYYY-NNNN]

## Executive Summary
- **Incident Type**: [Data Breach/Malware/Phishing/Insider Threat/etc.]
- **Severity**: [P1/P2/P3/P4]
- **Business Impact**: [High/Medium/Low]
- **Detection Time**: [YYYY-MM-DD HH:MM UTC]
- **Resolution Time**: [YYYY-MM-DD HH:MM UTC]

## Technical Details
- **Affected Systems**: [List systems and users]
- **Attack Vector**: [How the incident occurred]
- **Root Cause**: [Technical root cause]
- **Evidence**: [Key forensic evidence and artifacts]

## Response Actions
- **Containment**: [Actions taken to contain the incident]
- **Eradication**: [Steps to remove threats]
- **Recovery**: [System restoration procedures]
- **Lessons Learned**: [Process improvements identified]
```

### Analytics Rule Management

#### Rule Performance Monitoring
```kql
// High False Positive Rate Detection
SecurityAlert
| where TimeGenerated >= ago(7d)
| extend RuleName = tostring(ExtendedProperties["analytic rule name"])
| summarize 
    TotalAlerts = count(),
    TruePositives = countif(Status == "Closed" and Classification == "TruePositive"),
    FalsePositives = countif(Status == "Closed" and Classification == "FalsePositive")
by RuleName
| extend FalsePositiveRate = round(FalsePositives * 100.0 / TotalAlerts, 2)
| where FalsePositiveRate > 80 or TotalAlerts > 100
| order by FalsePositiveRate desc
```

#### Rule Tuning Process
1. **Performance Review**: Weekly review of rule effectiveness and false positive rates
2. **Threshold Adjustment**: Modify detection thresholds based on environment baseline
3. **Exclusion Management**: Implement appropriate exclusions for known false positives
4. **Testing**: Validate rule changes in test environment before production deployment
5. **Documentation**: Update rule documentation and rationale for changes

```powershell
# Update Analytics Rule Threshold
$RuleId = "rule-guid-here"
$NewThreshold = 15

$Rule = Get-AzSentinelAlertRule -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName -RuleId $RuleId
$Rule.QueryFrequency = [TimeSpan]::FromMinutes(60)
$Rule.QueryPeriod = [TimeSpan]::FromHours(6)
$Rule.TriggerThreshold = $NewThreshold

Set-AzSentinelAlertRule -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName -AlertRule $Rule
```

### Threat Hunting Operations

#### Proactive Threat Hunting Schedule
**Daily Hunting (30 minutes)**
- Review latest threat intelligence indicators
- Hunt for IOCs from recent security bulletins
- Investigate anomalous user and entity behavior

**Weekly Hunting (2 hours)**
- Deep dive investigation based on industry threats
- Advanced persistent threat (APT) behavior hunting
- Compliance and regulatory requirement validation

**Monthly Hunting (4 hours)**
- Comprehensive threat landscape assessment
- Custom hunting query development and testing
- Threat hunting technique effectiveness review

#### Threat Hunting Queries

**Anomalous Authentication Patterns**
```kql
// Unusual login locations for users
let UserBaseline = SigninLogs
| where TimeGenerated >= ago(30d)
| where ResultType == 0
| summarize Countries = make_set(LocationDetails.countryOrRegion) by UserPrincipalName;

SigninLogs
| where TimeGenerated >= ago(24h)
| where ResultType == 0
| join kind=inner UserBaseline on UserPrincipalName
| extend NewCountry = LocationDetails.countryOrRegion
| where NewCountry !in (Countries)
| project TimeGenerated, UserPrincipalName, NewCountry, IPAddress, Countries
```

**Suspicious PowerShell Activity**
```kql
// Detect PowerShell execution with suspicious commands
SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID == 4688
| where Process contains "powershell.exe"
| where CommandLine contains "Download" or CommandLine contains "Invoke-" or CommandLine contains "IEX"
| where CommandLine contains "http" or CommandLine contains "bypass" or CommandLine contains "hidden"
| project TimeGenerated, Computer, Account, CommandLine, Process
```

### Watchlist and Threat Intelligence Management

#### Daily Watchlist Updates
```powershell
# Update IP reputation watchlist
$ThreatFeedUrl = "https://your-threat-feed-source.com/ips.json"
$ThreatData = Invoke-RestMethod -Uri $ThreatFeedUrl

# Convert to CSV format for watchlist
$WatchlistData = $ThreatData | ConvertTo-Csv -NoTypeInformation

# Update Azure Sentinel watchlist
New-AzSentinelWatchlist -ResourceGroupName $WorkspaceResourceGroup `
  -WorkspaceName $WorkspaceName `
  -WatchlistAlias "malicious_ips" `
  -DisplayName "Malicious IP Addresses" `
  -Source "External Threat Feed" `
  -RawContent $WatchlistData
```

#### Threat Intelligence Integration
```kql
// Match indicators against security events
let ThreatIPs = ThreatIntelligenceIndicator
| where TimeGenerated >= ago(30d)
| where Active == true
| where ExpirationDateTime > now()
| summarize by IndicatorValue;

SecurityEvent
| where TimeGenerated >= ago(24h)
| where EventID in (4624, 4625, 4648)
| extend IPAddress = extract(@"Source Network Address:\s+([^\s]+)", 1, EventData)
| where IPAddress in (ThreatIPs)
| project TimeGenerated, Computer, Account, EventID, IPAddress, Activity
```

## Maintenance Procedures

### Weekly Maintenance Tasks

#### System Performance Review
```kql
// Workspace performance metrics
Usage
| where TimeGenerated >= ago(7d)
| summarize TotalGB = sum(Quantity) by DataType
| order by TotalGB desc
| take 20
```

```kql
// Query performance analysis
Query
| where TimeGenerated >= ago(7d)
| summarize 
    AvgDuration = avg(Duration),
    MaxDuration = max(Duration),
    QueryCount = count()
by QueryText
| where QueryCount > 10
| order by AvgDuration desc
```

**Weekly Maintenance Checklist:**
- [ ] Review workspace data ingestion and costs
- [ ] Analyze query performance and optimize slow queries
- [ ] Update threat intelligence watchlists
- [ ] Review and tune high false-positive analytics rules
- [ ] Backup custom queries and playbooks
- [ ] Review incident response metrics and trends
- [ ] Update documentation based on operational changes

### Monthly Maintenance Tasks

#### Analytics Rule Performance Review
```powershell
# Generate analytics rule effectiveness report
$StartDate = (Get-Date).AddDays(-30)
$EndDate = Get-Date

$RulePerformance = @()
$Rules = Get-AzSentinelAlertRule -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName

foreach ($Rule in $Rules) {
    $Alerts = Get-AzSentinelAlert -ResourceGroupName $WorkspaceResourceGroup -WorkspaceName $WorkspaceName |
        Where-Object { $_.AlertRule -eq $Rule.Id -and $_.TimeGenerated -ge $StartDate }
    
    $Performance = [PSCustomObject]@{
        RuleName = $Rule.DisplayName
        TotalAlerts = $Alerts.Count
        TruePositives = ($Alerts | Where-Object Classification -eq "TruePositive").Count
        FalsePositives = ($Alerts | Where-Object Classification -eq "FalsePositive").Count
        Unclassified = ($Alerts | Where-Object Classification -eq $null).Count
    }
    $RulePerformance += $Performance
}

$RulePerformance | Export-Csv -Path "RulePerformance_$(Get-Date -Format 'yyyy-MM-dd').csv"
```

#### Data Retention Management
```kql
// Review data retention and archival requirements
Usage
| where TimeGenerated >= ago(90d)
| summarize TotalGB = sum(Quantity), DailyAverage = avg(Quantity) by bin(TimeGenerated, 1d), DataType
| order by TimeGenerated desc
```

**Monthly Maintenance Tasks:**
- [ ] Comprehensive analytics rule performance review
- [ ] Data retention and archival policy review
- [ ] Cost optimization analysis and recommendations
- [ ] Threat hunting technique effectiveness assessment
- [ ] Incident response process improvement review
- [ ] Training needs assessment for SOC team
- [ ] Security control effectiveness validation

### Quarterly Maintenance Tasks

#### Security Framework Compliance Review
```kql
// MITRE ATT&CK framework coverage analysis
SecurityAlert
| where TimeGenerated >= ago(90d)
| extend MitreTechnique = tostring(ExtendedProperties["MITRE ATT&CK Technique"])
| where isnotempty(MitreTechnique)
| summarize AlertCount = count() by MitreTechnique
| join kind=fullouter (
    // Reference table of MITRE techniques (would be populated separately)
    datatable(MitreTechnique:string, TechniqueName:string)
    [
        "T1078", "Valid Accounts",
        "T1055", "Process Injection",
        "T1059", "Command and Scripting Interpreter"
        // Add all relevant MITRE techniques
    ]
) on MitreTechnique
| extend Coverage = iff(AlertCount > 0, "Covered", "Gap")
| order by MitreTechnique
```

**Quarterly Review Activities:**
- [ ] Security framework compliance assessment (NIST, MITRE ATT&CK)
- [ ] Threat landscape analysis and detection gap identification
- [ ] SOC maturity assessment and capability enhancement planning
- [ ] Technology roadmap review and budget planning
- [ ] Disaster recovery and business continuity testing
- [ ] Vendor relationship and contract review
- [ ] Security awareness training effectiveness review

## Escalation Procedures

### Technical Escalation Matrix

#### Level 1 - SOC Analyst
**Responsibilities:**
- Initial alert triage and investigation
- Standard incident response procedures
- Routine maintenance and monitoring tasks
- Basic threat hunting activities

**Escalation Triggers:**
- Complex technical issues beyond current skill level
- High-impact incidents requiring specialized expertise
- System outages or performance degradation
- Regulatory or compliance-related incidents

#### Level 2 - Senior Security Analyst / Team Lead
**Responsibilities:**
- Complex incident investigation and response
- Analytics rule tuning and custom development
- Advanced threat hunting and forensics
- Coordination with external teams and vendors

**Escalation Triggers:**
- Major security breaches or data compromise
- Advanced persistent threat (APT) activity
- System architecture or design changes
- Legal or regulatory investigation support

#### Level 3 - Security Manager / Architect
**Responsibilities:**
- Strategic security decision making
- Executive and business stakeholder communication
- Vendor escalation and support coordination
- Security program and policy development

**Escalation Triggers:**
- Business-critical security incidents
- Regulatory compliance violations
- Major system outages or failures
- Public relations or media attention

### Communication Templates

#### Incident Notification (High/Critical Priority)
```
Subject: [URGENT] Security Incident - [Brief Description] - [INC-YYYY-NNNN]

Team,

A [high/critical] priority security incident has been detected:

Incident ID: INC-YYYY-NNNN
Detection Time: YYYY-MM-DD HH:MM UTC
Priority: [P1/P2]
Affected Systems: [List primary affected systems/users]
Business Impact: [Brief impact description]

Initial Assessment:
[2-3 sentences describing the incident nature and scope]

Immediate Actions Taken:
- [List key containment actions]
- [Investigation steps initiated]

Next Steps:
- [Planned response activities]
- [Expected resolution timeline]

Point of Contact: [Analyst Name] - [Phone] - [Email]

Updates will be provided every [30/60] minutes until resolution.

[Analyst Name]
SOC Team
```

#### Weekly SOC Summary Report
```
Subject: Weekly SOC Summary - Week of [Date]

Executive Summary:
- Total Incidents: XX (XX% change from previous week)
- High Priority Incidents: XX 
- Average Response Time: XX minutes
- Top Threat Types: [List top 3]

Key Metrics:
- Mean Time to Detection (MTTD): XX minutes
- Mean Time to Response (MTTR): XX hours
- False Positive Rate: XX%
- Data Ingestion Volume: XX GB/day

Notable Incidents:
[Brief description of significant incidents and resolutions]

System Health:
- Data Connector Status: XX/XX operational
- Analytics Rules: XX active, XX tuned this week
- Query Performance: Average XX seconds

Recommendations:
- [Key recommendations for improvement]
- [Required actions or approvals]

Next Week Focus:
- [Planned activities and priorities]
```

## Emergency Procedures

### Security Incident Emergency Response

#### Major Breach Response (P1 Incidents)
**Immediate Actions (0-15 minutes):**
1. **Incident Commander Assignment**: Senior analyst takes incident command
2. **Initial Containment**: Isolate affected systems using emergency procedures
3. **Evidence Preservation**: Secure logs and forensic evidence immediately
4. **Executive Notification**: Contact security manager and IT director
5. **Communication Plan**: Activate emergency communication procedures

```bash
# Emergency system isolation commands
# Disable user account
az ad user update --id "compromised-user@domain.com" --account-enabled false

# Block IP at firewall (Azure Firewall)
az network firewall network-rule create \
  --collection-name "EmergencyBlocks" \
  --firewall-name "fw-prod-eus2-001" \
  --name "Block-Malicious-IP" \
  --protocols "TCP" "UDP" \
  --source-addresses "*" \
  --destination-addresses "MALICIOUS_IP" \
  --destination-ports "*" \
  --action "Deny" \
  --priority 100 \
  --resource-group "rg-network-prod-eus2-001"
```

#### System Outage Response
**Sentinel Workspace Unavailable:**
1. **Impact Assessment**: Determine scope of outage and business impact
2. **Backup Procedures**: Activate alternative monitoring and alerting systems
3. **Vendor Escalation**: Open priority support ticket with Microsoft
4. **Stakeholder Communication**: Notify business stakeholders of service impact
5. **Workaround Implementation**: Deploy temporary security monitoring solutions

```powershell
# Check Azure service health
Get-AzServiceHealth | Where-Object {$_.Service -like "*Sentinel*" -or $_.Service -like "*Log Analytics*"}

# Verify workspace connectivity
try {
    $Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceResourceGroup -Name $WorkspaceName
    Write-Output "Workspace Status: $($Workspace.ProvisioningState)"
} catch {
    Write-Error "Workspace connection failed: $_"
    # Activate backup monitoring procedures
}
```

### Contact Information

#### Internal Contacts
```
SOC Team Lead: [Name] - [Phone] - [Email]
Security Manager: [Name] - [Phone] - [Email]
IT Director: [Name] - [Phone] - [Email]
CISO: [Name] - [Phone] - [Email]
Legal Counsel: [Name] - [Phone] - [Email]
PR/Communications: [Name] - [Phone] - [Email]
```

#### External Contacts
```
Microsoft Support: 1-800-MICROSOFT (Priority Support)
Azure Status: https://status.azure.com/
Law Enforcement: [Local cybercrime unit contact]
Cyber Insurance: [Carrier] - [Policy Number] - [Phone]
External Forensics: [Vendor] - [Emergency Contact]
```

### Business Continuity

#### Alternate SOC Procedures
**Primary Sentinel Workspace Unavailable:**
1. Activate backup SIEM or SIEM-as-a-Service solution
2. Implement manual log analysis procedures using Azure Storage
3. Deploy temporary detection scripts and alerting mechanisms
4. Coordinate with managed security service provider (if applicable)
5. Maintain incident response capabilities through alternate channels

**Staff Unavailability (Pandemic/Emergency):**
1. Activate remote work procedures and secure access protocols
2. Scale up managed security services or external SOC support
3. Implement reduced service levels with focus on critical detection
4. Cross-train personnel on essential procedures and tools
5. Maintain 24/7 coverage through flexible scheduling arrangements

This operations runbook provides comprehensive procedures for effective Azure Sentinel SIEM operations, ensuring consistent and professional security operations center capabilities that protect organizational assets and respond effectively to cyber threats.
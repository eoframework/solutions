# Microsoft CMMC Enclave - Operations Runbook

This operations runbook provides comprehensive procedures for the day-to-day management, monitoring, and maintenance of the Microsoft CMMC Enclave solution. These procedures ensure continuous CMMC Level 2 compliance while maintaining optimal system performance and security.

## Overview

The operations runbook is organized into:
- **Daily Operations**: Routine tasks performed daily
- **Weekly Operations**: Regular maintenance and review activities
- **Monthly Operations**: Comprehensive reviews and reporting
- **Quarterly Operations**: Strategic reviews and assessments
- **Emergency Procedures**: Incident response and crisis management

## Daily Operations

### Morning System Health Check (8:00 AM)

#### Overall System Status
**Duration**: 15 minutes
**Responsibility**: Security Operations Center (SOC)

**Tasks**:
1. **Check Service Health Dashboards**
   ```bash
   # Check Azure service health
   az monitor activity-log list --filters eventLevel=Error,Warning --max-events 20 --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ)
   ```

2. **Review Security Alerts**
   ```kusto
   SecurityAlert
   | where TimeGenerated > ago(24h)
   | where AlertSeverity in ("High", "Medium")
   | summarize count() by AlertName, AlertSeverity
   | order by count_ desc
   ```

3. **Validate Backup Status**
   ```powershell
   # Check last 24 hours backup jobs
   Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1) -Status Failed,InProgress | Format-Table
   ```

**Escalation**: If any critical alerts or failed backups, escalate to Security Team immediately.

#### Compliance Status Review
**Duration**: 10 minutes
**Responsibility**: Compliance Officer

**Tasks**:
1. **Policy Compliance Check**
   ```bash
   # Check policy compliance state
   az policy state list --filter "ComplianceState eq 'NonCompliant'" --query "length(@)"
   ```

2. **CMMC Control Status**
   ```kusto
   // Review CMMC control compliance
   SecurityRecommendation
   | where TimeGenerated > ago(24h)
   | where RecommendationState == "Unhealthy"
   | summarize count() by RecommendationDisplayName
   ```

3. **Audit Log Verification**
   ```kusto
   AuditLogs
   | where TimeGenerated > ago(24h)
   | where Result == "failure"
   | summarize count() by ActivityDisplayName
   | order by count_ desc
   | take 10
   ```

**Documentation**: Update daily compliance dashboard

### Security Monitoring (Continuous)

#### Real-Time Alert Monitoring
**Responsibility**: SOC Team (24/7)

**Primary Monitoring Sources**:
- Azure Sentinel security incidents
- Microsoft Defender alerts
- Azure Security Center recommendations
- Microsoft 365 Defender incidents

**Alert Response Procedures**:

1. **High Priority Alerts** (Response Time: 15 minutes)
   ```powershell
   # Check incident details
   Get-AzSentinelIncident -ResourceGroupName "cmmc-security-rg" -WorkspaceName "cmmc-sentinel" | Where-Object {$_.Severity -eq "High"}
   
   # Assign incident
   Update-AzSentinelIncident -ResourceGroupName "cmmc-security-rg" -WorkspaceName "cmmc-sentinel" -IncidentId $incidentId -Owner @{email="security@company.gov"}
   ```

2. **Medium Priority Alerts** (Response Time: 1 hour)
   - Review alert context and investigate
   - Document findings in incident management system
   - Implement containment if necessary

3. **Privileged Account Monitoring**
   ```kusto
   AuditLogs
   | where TimeGenerated > ago(1h)
   | where Category == "RoleManagement"
   | where OperationName contains "Add member to role"
   | project TimeGenerated, UserPrincipalName, TargetResources
   ```

### User Access Review
**Duration**: 20 minutes (twice daily: 9 AM, 5 PM)
**Responsibility**: Identity Administrator

**Tasks**:
1. **Failed Sign-in Attempts**
   ```kusto
   SigninLogs
   | where TimeGenerated > ago(12h)
   | where ResultType != 0
   | summarize count() by UserPrincipalName, ResultDescription
   | where count_ > 5
   | order by count_ desc
   ```

2. **Privileged Role Activations**
   ```kusto
   AuditLogs
   | where TimeGenerated > ago(12h)
   | where OperationName == "Add member to role completed (PIM activation)"
   | project TimeGenerated, UserPrincipalName, TargetResources
   ```

3. **Conditional Access Failures**
   ```kusto
   SigninLogs
   | where TimeGenerated > ago(12h)
   | where ConditionalAccessStatus == "failure"
   | summarize count() by UserPrincipalName, ConditionalAccessPolicies
   ```

**Actions**: Investigation and user communication for suspicious activities

### Data Protection Monitoring
**Duration**: 15 minutes (every 4 hours)
**Responsibility**: Data Protection Officer

**Tasks**:
1. **DLP Policy Matches**
   ```powershell
   # Connect to Security & Compliance Center
   Connect-IPPSSession -UserPrincipalName admin@tenant.onmicrosoft.us
   
   # Check DLP incidents from last 4 hours
   Get-DlpDetailReport -StartDate (Get-Date).AddHours(-4) -EndDate (Get-Date)
   ```

2. **Sensitivity Label Usage**
   ```powershell
   # Review label application statistics
   Get-LabelActivityExplorer -StartTime (Get-Date).AddHours(-4) -EndTime (Get-Date)
   ```

3. **CUI Data Access**
   ```kusto
   OfficeActivity
   | where TimeGenerated > ago(4h)
   | where SensitivityLabelName contains "CUI"
   | summarize count() by UserId, Operation
   | order by count_ desc
   ```

**Documentation**: Log all CUI access activities for compliance reporting

## Weekly Operations

### Monday: Security Review (9:00 AM)

#### Threat Intelligence Update
**Duration**: 45 minutes
**Responsibility**: Security Team Lead

**Tasks**:
1. **Microsoft Threat Intelligence Brief**
   ```powershell
   # Review latest threat intelligence
   Get-AzSentinelThreatIntelligenceIndicator | Where-Object {$_.LastUpdatedTimeUtc -gt (Get-Date).AddDays(-7)}
   ```

2. **Update Security Baselines**
   - Review Microsoft Security Compliance Toolkit updates
   - Update Group Policy objects if needed
   - Test changes in development environment

3. **Vulnerability Assessment Review**
   ```bash
   # Check latest vulnerability assessments
   az security assessment list --query "[?status.code=='Unhealthy']" --output table
   ```

**Deliverables**: Weekly threat briefing report, updated security baselines

#### Access Review Campaign
**Duration**: 30 minutes
**Responsibility**: Identity Administrator

**Tasks**:
1. **Privileged Account Review**
   ```powershell
   # Start access review for privileged roles
   New-AzureADMSAccessReview -DisplayName "Weekly Privileged Access Review" -DescriptionForAdmins "Review privileged role assignments" -DescriptionForReviewers "Review your privileged access"
   ```

2. **Service Account Validation**
   ```powershell
   # Review service account usage
   Get-AzADServicePrincipal | Where-Object {$_.PasswordCredentials -or $_.KeyCredentials} | Select-Object DisplayName, AppId
   ```

3. **Guest Account Cleanup**
   ```powershell
   # Identify inactive guest accounts
   Get-AzureADUser -All $true | Where-Object {$_.UserType -eq "Guest" -and $_.RefreshTokensValidFromDateTime -lt (Get-Date).AddDays(-90)}
   ```

### Tuesday: Performance and Capacity Review

#### Infrastructure Performance Analysis
**Duration**: 60 minutes
**Responsibility**: Infrastructure Team

**Tasks**:
1. **VM Performance Analysis**
   ```kusto
   Perf
   | where TimeGenerated > ago(7d)
   | where ObjectName == "Processor" and CounterName == "% Processor Time"
   | summarize avg(CounterValue) by Computer
   | where avg_CounterValue > 80
   ```

2. **Storage Performance Review**
   ```kusto
   Perf
   | where TimeGenerated > ago(7d)
   | where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
   | summarize min(CounterValue) by Computer, InstanceName
   | where min_CounterValue < 20
   ```

3. **Network Utilization**
   ```bash
   # Check network performance metrics
   az monitor metrics list --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/cmmc-main-rg/providers/Microsoft.Network/virtualNetworks/cmmc-vnet" --metric "BytesInDDoS,BytesOutDDoS"
   ```

**Actions**: Scale resources as needed, implement optimization recommendations

#### Database Performance Tuning
**Duration**: 45 minutes
**Responsibility**: Database Administrator

**Tasks**:
1. **Query Performance Analysis**
   ```sql
   -- Top 10 slowest queries from past week
   SELECT TOP 10 
       qs.execution_count,
       qs.total_elapsed_time/1000 as total_elapsed_time_ms,
       qs.total_worker_time/1000 as total_cpu_time_ms,
       qt.text as query_text
   FROM sys.dm_exec_query_stats qs
   CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
   WHERE qs.last_execution_time > DATEADD(day, -7, GETDATE())
   ORDER BY qs.total_elapsed_time DESC
   ```

2. **Index Optimization**
   ```sql
   -- Identify missing indexes
   SELECT 
       migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS improvement_measure,
       mid.statement,
       migs.*,
       mid.*
   FROM sys.dm_db_missing_index_groups mig
   INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
   INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
   ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC
   ```

### Wednesday: Backup and Recovery Validation

#### Backup Status Verification
**Duration**: 30 minutes
**Responsibility**: Backup Administrator

**Tasks**:
1. **VM Backup Status**
   ```bash
   # Check VM backup status for past week
   az backup job list --resource-group cmmc-main-rg --vault-name cmmc-recovery-vault --status Completed,Failed --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)
   ```

2. **Database Backup Verification**
   ```bash
   # Check SQL Database backup status
   az sql db list-backups --resource-group cmmc-main-rg --server cmmc-sql-server --database cmmc-database --only-latest-per-database
   ```

3. **File Share Backup Review**
   ```powershell
   # Check Azure File Sync backup status
   Get-StorageSyncJob | Where-Object {$_.Type -eq "Backup" -and $_.StartTime -gt (Get-Date).AddDays(-7)}
   ```

#### Recovery Testing (Monthly - First Wednesday)
**Duration**: 2 hours
**Responsibility**: Disaster Recovery Team

**Tasks**:
1. **Test VM Recovery**
   ```bash
   # Create test recovery point
   az backup restore files mount-rp --resource-group cmmc-main-rg --vault-name cmmc-recovery-vault --container-name cmmc-vm --item-name cmmc-vm --rp-name $recoveryPointId
   ```

2. **Database Recovery Test**
   ```bash
   # Test database point-in-time recovery
   az sql db restore --dest-name cmmc-database-test --resource-group cmmc-test-rg --server cmmc-sql-server --source-database cmmc-database --time "2024-01-01T09:00:00"
   ```

**Documentation**: Update recovery test results and RTO/RPO validation

### Thursday: Compliance and Audit Review

#### Policy Compliance Assessment
**Duration**: 45 minutes
**Responsibility**: Compliance Officer

**Tasks**:
1. **Azure Policy Compliance**
   ```bash
   # Generate weekly compliance report
   az policy state summarize --management-group mg-cmmc --filter "policySetDefinitionName eq 'cmmc-level-2-initiative'"
   ```

2. **Security Control Validation**
   ```kusto
   SecurityRecommendation
   | where TimeGenerated > ago(7d)
   | summarize arg_max(TimeGenerated, RecommendationState) by RecommendationName
   | where RecommendationState != "Healthy"
   | project RecommendationName, RecommendationState
   ```

3. **Audit Evidence Collection**
   ```bash
   # Export audit logs for compliance
   az monitor activity-log list --start-time $(date -u -d '7 days ago' +%Y-%m-%d) --end-time $(date -u +%Y-%m-%d) --output json > weekly-audit-log.json
   ```

#### CMMC Control Status Review
**Duration**: 60 minutes
**Responsibility**: CMMC Compliance Team

**Review Areas**:
- Access Control (AC) - 22 practices
- Audit and Accountability (AU) - 9 practices
- Configuration Management (CM) - 7 practices
- All other CMMC domains

**Tasks**:
1. **Automated Control Verification**
   ```powershell
   # Run CMMC compliance check script
   .\scripts\powershell\Check-CMMCCompliance.ps1 -GenerateReport $true -OutputPath "compliance-reports\"
   ```

2. **Manual Control Documentation**
   - Review training records
   - Validate incident response procedures
   - Check physical security documentation
   - Update System Security Plan if needed

### Friday: Reporting and Planning

#### Weekly Metrics and Reporting
**Duration**: 90 minutes
**Responsibility**: Operations Manager

**Tasks**:
1. **Generate Weekly Dashboard**
   ```kusto
   // Security metrics for weekly report
   SecurityIncident
   | where TimeGenerated between (ago(7d) .. now())
   | summarize 
       TotalIncidents = count(),
       HighPriorityIncidents = countif(Severity == "High"),
       AvgTimeToResolution = avg(datetime_diff('minute', ClosedTime, CreatedTime))
   ```

2. **Capacity Planning Review**
   ```bash
   # Review resource utilization trends
   az monitor metrics list --resource-group cmmc-main-rg --metric "Percentage CPU" --interval PT1H --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ)
   ```

3. **Cost Analysis**
   ```bash
   # Generate cost analysis report
   az consumption usage list --start-date $(date -u -d '7 days ago' +%Y-%m-%d) --end-date $(date -u +%Y-%m-%d) --output table
   ```

## Monthly Operations

### First Monday: Security Assessment

#### Comprehensive Security Review
**Duration**: 4 hours
**Responsibility**: CISO and Security Team

**Tasks**:
1. **Vulnerability Assessment**
   ```bash
   # Run comprehensive vulnerability scan
   az security assessment list --query "[?status.code=='Unhealthy']" --output json > monthly-vulnerabilities.json
   ```

2. **Penetration Testing Review**
   - Review external penetration testing results
   - Validate remediation of identified issues
   - Plan next testing cycle

3. **Threat Modeling Update**
   - Review and update threat models
   - Assess new threats and attack vectors
   - Update security controls as needed

### Second Monday: Configuration Management

#### System Configuration Review
**Duration**: 3 hours
**Responsibility**: Configuration Management Team

**Tasks**:
1. **Configuration Baseline Validation**
   ```powershell
   # Compare current configuration with baselines
   .\scripts\powershell\Compare-SecurityBaselines.ps1 -GenerateReport $true
   ```

2. **Change Management Review**
   - Review all changes made in past month
   - Validate change approval process
   - Update configuration documentation

3. **Software Inventory Update**
   ```bash
   # Update software inventory
   az vm run-command invoke --resource-group cmmc-main-rg --name cmmc-vm --command-id RunPowerShellScript --scripts "Get-WmiObject -Class Win32_Product | Select-Object Name, Version"
   ```

### Third Monday: Business Continuity Testing

#### Disaster Recovery Exercise
**Duration**: 6 hours (planned maintenance window)
**Responsibility**: Business Continuity Team

**Tasks**:
1. **Failover Testing**
   ```bash
   # Initiate planned failover to DR region
   az backup restore restore-disks --resource-group cmmc-dr-rg --vault-name cmmc-site-recovery --container-name cmmc-vm --item-name cmmc-vm --rp-name $latestRecoveryPoint --storage-account drStorage --subnet-id $drSubnetId
   ```

2. **RTO/RPO Validation**
   - Measure actual recovery times
   - Compare against RTO/RPO objectives
   - Document results and improvements

3. **Communication Testing**
   - Test emergency notification systems
   - Validate contact information
   - Practice communication procedures

### Fourth Monday: Strategic Review

#### Monthly Business Review
**Duration**: 2 hours
**Responsibility**: Leadership Team

**Review Areas**:
- Security metrics and KPIs
- Compliance status and trends
- Cost optimization opportunities
- Resource capacity planning
- Strategic initiatives progress

## Quarterly Operations

### Security Assessment and Certification Maintenance

#### Quarterly CMMC Assessment Preparation
**Duration**: 1 week
**Responsibility**: CMMC Compliance Team

**Activities**:
1. **Gap Analysis**
   - Comprehensive review of all 110 NIST SP 800-171 practices
   - Documentation review and updates
   - Evidence collection validation

2. **Mock Assessment**
   - Internal assessment simulation
   - Control testing and validation
   - Remediation of any findings

3. **Certification Maintenance**
   - Review certification requirements
   - Update documentation as needed
   - Prepare for annual assessment

#### Risk Assessment Update
**Duration**: 3 days
**Responsibility**: Risk Management Team

**Tasks**:
1. **Threat Landscape Review**
   - Analyze current threat environment
   - Update risk register
   - Assess new vulnerabilities

2. **Business Impact Analysis**
   - Review and update BIA
   - Validate criticality ratings
   - Update recovery priorities

## Emergency Procedures

### Security Incident Response

#### Critical Security Incident (24/7 Response)
**Response Time**: 30 minutes
**Responsibility**: Security Incident Response Team

**Initial Response Steps**:
1. **Incident Triage**
   ```powershell
   # Assess incident severity
   Get-AzSentinelIncident -ResourceGroupName "cmmc-security-rg" -WorkspaceName "cmmc-sentinel" -IncidentId $incidentId
   ```

2. **Containment Actions**
   ```powershell
   # Disable compromised account
   Set-AzureADUser -ObjectId $compromisedUserId -AccountEnabled $false
   
   # Revoke all sessions
   Revoke-AzureADUserAllRefreshToken -ObjectId $compromisedUserId
   ```

3. **Evidence Preservation**
   ```bash
   # Create VM snapshot for forensics
   az snapshot create --resource-group cmmc-security-rg --source-disk /subscriptions/$SUBSCRIPTION_ID/resourceGroups/cmmc-main-rg/providers/Microsoft.Compute/disks/cmmc-vm-disk --name forensic-snapshot-$(date +%Y%m%d)
   ```

#### Data Breach Response
**Response Time**: 1 hour
**Responsibility**: Data Protection Officer

**Required Actions**:
1. **Immediate Assessment**
   - Identify scope of data exposure
   - Classify affected data types
   - Document timeline of events

2. **Regulatory Notifications**
   - Notify DoD Contracting Officer (within 72 hours)
   - Prepare breach notification letters
   - Document all notification activities

3. **Remediation**
   - Implement immediate containment
   - Begin forensic investigation
   - Coordinate with legal counsel

### System Outage Response

#### Critical System Failure
**Response Time**: 15 minutes
**Responsibility**: Operations Team

**Escalation Procedure**:
1. **Level 1**: Operations Team (0-30 minutes)
2. **Level 2**: Senior Technical Team (30-60 minutes)
3. **Level 3**: Microsoft Federal Services (60+ minutes)
4. **Level 4**: Executive Leadership (Major outage)

**Response Actions**:
1. **Status Page Update**
   - Update internal status page
   - Notify affected users
   - Provide regular updates

2. **Workaround Implementation**
   - Activate alternate procedures
   - Redirect users to backup systems
   - Document workaround steps

3. **Recovery Coordination**
   ```bash
   # Initiate disaster recovery if needed
   az backup restore restore-disks --resource-group cmmc-dr-rg --vault-name cmmc-site-recovery --item-name critical-system
   ```

## Performance Metrics and KPIs

### Security Metrics
- **Mean Time to Detection (MTTD)**: < 15 minutes
- **Mean Time to Response (MTTR)**: < 4 hours
- **Security Incident Volume**: Trend analysis
- **Compliance Score**: > 95% for all CMMC controls

### Operational Metrics
- **System Availability**: > 99.9%
- **Backup Success Rate**: > 99%
- **Recovery Time Objective**: < 24 hours
- **Recovery Point Objective**: < 4 hours

### Compliance Metrics
- **Policy Compliance**: > 98%
- **Control Effectiveness**: 100% of critical controls
- **Evidence Collection**: Complete and current
- **Assessment Readiness**: Always assessment-ready

## Contact Information

### Internal Contacts
- **Security Operations Center**: soc@company.gov / +1-555-0100
- **CISO**: ciso@company.gov / +1-555-0101
- **IT Operations**: itops@company.gov / +1-555-0102
- **Compliance Officer**: compliance@company.gov / +1-555-0103

### External Contacts
- **Microsoft Federal Support**: 1-800-642-7676
- **Azure Government Support**: Online portal
- **C3PAO Assessment Org**: [assessment-org@c3pao.com]
- **Legal Counsel**: legal@company.gov / +1-555-0104

## Documentation and Reporting

### Daily Reports
- Security dashboard summary
- Backup status report
- Compliance status update
- Incident summary

### Weekly Reports  
- Security metrics dashboard
- Performance analysis
- Compliance assessment
- Cost optimization report

### Monthly Reports
- Executive security briefing
- Comprehensive compliance report
- Business continuity status
- Strategic metrics review

### Quarterly Reports
- CMMC readiness assessment
- Risk assessment update
- Business impact analysis
- Strategic planning review

This operations runbook should be reviewed and updated monthly to ensure it remains current with evolving requirements, technologies, and threats. All team members should be familiar with these procedures and regularly trained on emergency response protocols.
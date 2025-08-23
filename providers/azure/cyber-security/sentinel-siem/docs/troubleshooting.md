# Troubleshooting Guide - Azure Sentinel SIEM Solution

## Common Issues

### Issue 1: Data Connector Configuration Failures
**Symptoms:**
- Data connectors showing "Not Connected" or "Error" status
- No data appearing in expected tables after connector setup
- Intermittent data ingestion with gaps in timeline

**Causes:**
- Incorrect permissions or authentication credentials
- Network connectivity issues blocking data transmission
- Misconfigured data source settings or filtering rules
- Service principal or managed identity authentication failures

**Solutions:**
1. Verify connector-specific permissions in source system and Azure
2. Test network connectivity to data source endpoints
3. Check Azure AD service principal expiration and credentials
4. Validate data source configuration and log format compatibility
5. Review connector documentation for specific requirements and limitations

### Issue 2: High False Positive Alert Rates
**Symptoms:**
- Overwhelming number of low-priority security alerts
- Security analysts spending excessive time on false positives
- Important security events buried in alert noise

**Causes:**
- Default detection rules not tuned for environment
- Lack of baseline normal behavior establishment
- Overly broad or sensitive rule conditions
- Missing context or environmental factors in rules

**Solutions:**
1. Implement alert tuning using historical data and feedback
2. Create allow-lists for known good activities and entities
3. Adjust detection rule thresholds based on environment baselines
4. Use machine learning insights to improve rule accuracy
5. Implement tiered alerting with different severity levels

### Issue 3: Poor Query Performance and Timeouts
**Symptoms:**
- KQL queries timing out or taking excessive time to complete
- Dashboards and workbooks loading slowly or failing
- Investigation searches returning incomplete results

**Causes:**
- Inefficient KQL query construction with unnecessary data scans
- Large time ranges without proper filtering or summarization
- Missing or poorly configured data partitioning
- Workspace reaching performance limits or quotas

**Solutions:**
1. Optimize KQL queries using best practices (filtering early, summarizing data)
2. Implement time-based partitioning for large datasets
3. Use appropriate data types and avoid unnecessary string operations
4. Configure workspace performance tier based on ingestion volume
5. Create indexed custom fields for frequently queried data

### Issue 4: Playbook Execution Failures
**Symptoms:**
- Automated response playbooks not triggering as expected
- Logic App runs failing with authentication or permission errors
- Incomplete or partial execution of response actions

**Causes:**
- Insufficient permissions for Logic App managed identity
- Network connectivity issues to external systems
- Incorrect API credentials or expired certificates
- Malformed or incompatible data passed between actions

**Solutions:**
1. Verify managed identity permissions for all connected services
2. Test API connectivity and authentication outside of Logic App
3. Implement error handling and retry logic in playbook design
4. Add logging and monitoring to playbook execution steps
5. Use test mode and manual triggers to validate playbook functionality

### Issue 5: Workspace Data Ingestion Limits
**Symptoms:**
- Data ingestion throttling or rejection messages
- Missing log data during peak ingestion periods
- Workspace hitting daily ingestion caps unexpectedly

**Causes:**
- Exceeding workspace ingestion rate limits (6 GB/minute default)
- Reaching daily commitment tier limits
- Burst ingestion patterns overwhelming processing capacity
- Inefficient log forwarding configurations

**Solutions:**
1. Implement data transformation to reduce ingestion volume
2. Distribute ingestion across multiple workspaces if necessary
3. Configure log forwarding to spread ingestion over time
4. Upgrade to higher commitment tier or dedicated clusters
5. Filter unnecessary log data at source before transmission

## Diagnostic Tools

### Built-in Azure Tools
- **Azure Monitor**: Comprehensive monitoring and alerting for Sentinel workspace
- **Log Analytics Health**: Workspace health monitoring and performance metrics
- **Usage and Costs**: Data ingestion monitoring and cost analysis
- **Azure Resource Health**: Service health status and maintenance notifications
- **Logic Apps Monitor**: Playbook execution monitoring and debugging
- **Azure Security Center**: Integration health and security recommendations

### KQL Diagnostic Queries
```kusto
// Check data ingestion rates by table
Usage
| where TimeGenerated > ago(7d)
| summarize DataSizeMB = sum(Quantity) by DataType, bin(TimeGenerated, 1h)
| render timechart

// Monitor query performance
Query_Performance
| where TimeGenerated > ago(1d)
| summarize AvgDuration = avg(Duration), MaxDuration = max(Duration) by QueryText
| order by AvgDuration desc

// Check data connector health
Heartbeat
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(5m)

// Monitor alert rule performance
SecurityAlert
| where TimeGenerated > ago(1d)
| summarize AlertCount = count() by AlertName, AlertSeverity
| order by AlertCount desc

// Check workspace limits and throttling
_LogOperation
| where TimeGenerated > ago(1d)
| where Detail has "throttled" or Detail has "limit"
```

### PowerShell Diagnostic Scripts
```powershell
# Check Sentinel workspace status
Get-AzOperationalInsightsWorkspace -ResourceGroupName "YourResourceGroup"

# Monitor data connector status
Get-AzSentinelDataConnector -ResourceGroupName "YourRG" -WorkspaceName "YourWorkspace"

# Review Logic App run history
Get-AzLogicAppRunHistory -ResourceGroupName "YourRG" -LogicAppName "YourPlaybook"

# Check Azure AD service principal status
Get-AzADServicePrincipal -DisplayName "YourServicePrincipal"

# Monitor resource utilization
Get-AzMetric -ResourceId "/subscriptions/.../workspaces/..." -MetricName "DataSizeGB"
```

### External Tools
- **Microsoft Sentinel GitHub Repository**: Community queries, playbooks, and tools
- **KQL Magic**: Jupyter notebook extension for interactive KQL development
- **Azure REST API**: Direct API access for custom monitoring and automation
- **Power BI**: Advanced analytics and reporting for Sentinel data
- **Grafana**: Custom dashboards and visualization for operational metrics

## Performance Optimization

### Query Optimization Best Practices
```kusto
// Bad: Scanning all data without filtering
SecurityEvent
| where EventID == 4625

// Good: Filter by time first, then by other conditions
SecurityEvent
| where TimeGenerated > ago(1d)
| where EventID == 4625
| where Account != ""

// Use summarize for aggregation
SecurityEvent
| where TimeGenerated > ago(7d)
| where EventID == 4625
| summarize FailedLogins = count() by Account, bin(TimeGenerated, 1h)
```

### Workspace Performance Tuning
- **Data Partitioning**: Configure custom partitioning for large tables
- **Data Transformation**: Use ingestion-time transformation to reduce data volume
- **Index Optimization**: Create custom indexes for frequently queried fields
- **Query Caching**: Leverage query result caching for repeated analyses
- **Resource Scaling**: Upgrade workspace tier based on performance requirements

### Cost Optimization Strategies
- **Data Lifecycle Management**: Implement tiered storage and archival policies
- **Commitment Pricing**: Use capacity reservations for predictable workloads
- **Data Sampling**: Sample high-volume, low-value data sources
- **Retention Optimization**: Set appropriate retention periods for different data types
- **Query Efficiency**: Optimize expensive queries to reduce compute costs

## Incident Response Procedures

### Alert Triage and Classification
1. **Initial Assessment**: Determine alert severity and potential business impact
2. **Context Gathering**: Collect relevant information about affected systems and users
3. **Threat Classification**: Categorize the type of security threat or activity
4. **Impact Analysis**: Assess the scope and potential damage of the incident
5. **Response Planning**: Determine appropriate response actions and resources

### Investigation Workflow
1. **Data Collection**: Gather relevant logs and evidence from multiple sources
2. **Timeline Construction**: Build chronological sequence of events
3. **Threat Actor Analysis**: Identify tactics, techniques, and procedures (TTPs)
4. **Lateral Movement Tracking**: Follow attacker movement through the environment
5. **Impact Assessment**: Determine what data or systems were compromised

### Communication Procedures
- **Internal Notifications**: Alert security team, management, and affected departments
- **External Communications**: Coordinate with law enforcement, customers, or partners
- **Status Updates**: Regular communication on investigation progress and containment
- **Media Relations**: Prepared statements and media handling procedures
- **Regulatory Reporting**: Comply with breach notification requirements

## Advanced Troubleshooting

### Custom Data Source Integration
```kusto
// Test custom log parsing
YourCustomLog_CL
| where TimeGenerated > ago(1h)
| extend ParsedData = parse_json(RawData)
| project TimeGenerated, ParsedData.field1, ParsedData.field2

// Validate data transformation results
YourTable
| where TimeGenerated > ago(1h)
| extend IsTransformed = isnotempty(TransformedField)
| summarize TransformedCount = countif(IsTransformed), TotalCount = count()
```

### Playbook Debugging Techniques
- **Test Mode**: Use test triggers to validate playbook logic
- **Error Handling**: Implement try-catch blocks and error notification
- **Logging**: Add custom logging actions to track execution flow
- **Conditional Logic**: Test different execution paths with sample data
- **Version Control**: Maintain playbook versions for rollback capability

### Complex Query Troubleshooting
```kusto
// Debug join operations
let LeftTable = SecurityEvent | where TimeGenerated > ago(1h);
let RightTable = SigninLogs | where TimeGenerated > ago(1h);
LeftTable
| join kind=inner (RightTable) on $left.Account == $right.UserPrincipalName
| take 10  // Limit results for debugging

// Performance analysis for slow queries
Query_Performance
| where QueryText contains "YourSlowQuery"
| summarize avg(Duration), max(Duration), count() by bin(TimeGenerated, 1h)
```

## Support Escalation

### Level 1 Support (Internal SOC)
- **Knowledge Base**: Internal documentation and known issue repository
- **Peer Support**: Collaboration with other security analysts and engineers
- **Vendor Documentation**: Microsoft Sentinel official documentation and guides
- **Community Forums**: Microsoft Tech Community and Stack Overflow
- **Internal Training**: Recorded training sessions and best practice guides

### Level 2 Support (Microsoft Support)
- **Professional Support**: Business hours support with guaranteed response times
- **Premier Support**: 24/7 support with dedicated technical account manager
- **Azure Security Center**: Integration with Microsoft security experts
- **FastTrack Services**: Architecture review and deployment guidance
- **Product Group**: Direct escalation to Microsoft Sentinel engineering team

### Level 3 Support (Critical Escalation)
- **Severity A Incidents**: Immediate response for business-critical security events
- **War Room Procedures**: Coordinated response with Microsoft engineering
- **Executive Escalation**: Direct access to Microsoft security leadership
- **Emergency Hotline**: 24/7 emergency contact for critical security incidents
- **Customer Success Team**: Dedicated support for strategic accounts

## Monitoring and Health Checks

### Workspace Health Monitoring
```kusto
// Monitor workspace health
Heartbeat
| where TimeGenerated > ago(5m)
| summarize LastHeartbeat = max(TimeGenerated) by Computer
| where LastHeartbeat < ago(5m)
| project Computer, LastHeartbeat, Status = "Offline"

// Check data ingestion health
Usage
| where TimeGenerated > ago(1h)
| summarize IngestedGB = sum(Quantity) / 1000 by bin(TimeGenerated, 5m)
| render timechart
```

### Alert Quality Metrics
- **Alert Volume**: Track daily alert counts and trends
- **False Positive Rate**: Monitor percentage of alerts closed as false positives
- **Mean Time to Detection (MTTD)**: Average time from event to alert
- **Mean Time to Response (MTTR)**: Average time from alert to initial response
- **Investigation Efficiency**: Time spent per investigation and closure rates

### Performance Baselines
- **Query Response Time**: Establish baselines for common query patterns
- **Data Ingestion Rate**: Monitor normal and peak ingestion patterns
- **Workspace Utilization**: Track storage usage and retention compliance
- **Cost Metrics**: Monitor spending against budget and optimization opportunities
- **User Activity**: Track analyst productivity and system usage patterns

## Business Continuity and Disaster Recovery

### Backup and Recovery Procedures
- **Configuration Backup**: Export workbooks, queries, and alert rules
- **Data Replication**: Configure geo-redundant storage for critical data
- **Workspace Recovery**: Procedures for workspace restoration and failover
- **Playbook Backup**: Version control and backup of Logic Apps and playbooks
- **Documentation**: Maintain current documentation and recovery procedures

### Disaster Recovery Testing
- **Quarterly DR Tests**: Regular testing of recovery procedures and capabilities
- **Scenario Planning**: Test various disaster scenarios and response procedures
- **Recovery Time Validation**: Verify RTO and RPO objectives are achievable
- **Communication Testing**: Test emergency communication and escalation procedures
- **Lessons Learned**: Document findings and improve recovery procedures
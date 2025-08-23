# Azure Virtual Desktop Operations Runbook

## Overview
This runbook provides operational procedures and guidelines for managing Azure Virtual Desktop (AVD) environments, including daily operations, monitoring, maintenance, and incident response.

## Daily Operations

### Health Check Procedures
#### System Health Verification
```powershell
# Daily health check script
$resourceGroup = "rg-avd-prod"
$hostPoolName = "hp-avd-prod"

# Check host pool status
Get-AzWvdHostPool -ResourceGroupName $resourceGroup -Name $hostPoolName

# Check session host status
Get-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName | 
Select-Object Name, Status, LastHeartBeat, Sessions, AllowNewSession

# Check user sessions
Get-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName |
Select-Object Name, UserPrincipalName, SessionState, CreateTime
```

#### Performance Metrics Review
- Review CPU and memory utilization across session hosts
- Check storage performance and capacity
- Monitor network connectivity and latency
- Validate user connection success rates

### User Management Tasks
#### New User Provisioning
1. Create user account in Azure AD (if not already exists)
2. Assign user to appropriate groups
3. Grant access to AVD application group
4. Verify user permissions and policies
5. Test user connection and profile loading

#### User Access Review
- Verify active user accounts and permissions
- Remove access for departed employees
- Review group memberships and role assignments
- Audit external user access

### Capacity Management
#### Resource Utilization Monitoring
```kusto
// Monitor session host utilization
Perf
| where TimeGenerated > ago(24h)
| where Computer startswith "vm-avd"
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 1h)
| render timechart
```

#### Scaling Decisions
- Monitor concurrent user counts
- Review auto-scaling trigger points
- Evaluate performance during peak hours
- Plan capacity adjustments based on trends

## Monitoring and Alerting

### Key Performance Indicators
| Metric | Target | Alert Threshold | Action Required |
|--------|--------|----------------|-----------------|
| User Connection Success | >99% | <95% | Investigate connectivity issues |
| Average Login Time | <30s | >45s | Review session host performance |
| Session Host CPU | <80% | >85% | Scale out or optimize resources |
| FSLogix Profile Load Time | <15s | >30s | Check storage performance |

### Alert Response Procedures
#### High CPU Utilization Alert
1. Identify affected session hosts
2. Check for resource-intensive processes
3. Review concurrent user sessions
4. Scale out additional session hosts if needed
5. Investigate and terminate problematic processes

#### Connection Failure Alert
1. Verify AVD service health status
2. Test network connectivity to session hosts
3. Check DNS resolution and routing
4. Validate user authentication and permissions
5. Review firewall and security group rules

### Monitoring Tools Configuration
```json
{
  "logAnalyticsWorkspace": "law-avd-prod",
  "alertRules": [
    {
      "name": "AVD High CPU Usage",
      "query": "Perf | where ObjectName == 'Processor' | summarize avg(CounterValue) by Computer",
      "threshold": 85,
      "frequency": "PT5M"
    },
    {
      "name": "AVD Connection Failures", 
      "query": "WVDConnections | where State == 'Failed' | summarize count() by bin(TimeGenerated, 5m)",
      "threshold": 5,
      "frequency": "PT5M"
    }
  ]
}
```

## Maintenance Procedures

### Regular Maintenance Tasks
#### Weekly Tasks
- [ ] Review and apply Windows updates to session hosts
- [ ] Clean up temporary files and user profiles
- [ ] Verify backup job completion and test restoration
- [ ] Review security logs and audit reports
- [ ] Update custom images with latest applications and patches

#### Monthly Tasks
- [ ] Review and optimize resource utilization
- [ ] Analyze cost reports and optimize spending
- [ ] Update automation scripts and runbooks
- [ ] Conduct security assessment and vulnerability scan
- [ ] Review and update disaster recovery procedures

### Patching and Updates
#### Session Host Patching Process
1. **Schedule Maintenance Window**
   - Communicate maintenance to users
   - Schedule during low-usage periods
   - Plan for 2-4 hour maintenance window

2. **Pre-Patching Verification**
   ```powershell
   # Verify session host health before patching
   $sessionHosts = Get-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName
   foreach ($host in $sessionHosts) {
       if ($host.Status -ne "Available") {
           Write-Warning "Host $($host.Name) is not available for patching"
       }
   }
   ```

3. **Patching Execution**
   - Enable drain mode on session hosts
   - Wait for user sessions to complete
   - Install Windows updates and application patches
   - Reboot session hosts as required

4. **Post-Patching Validation**
   - Verify session host availability
   - Test user connections and applications
   - Monitor for any performance issues
   - Re-enable new sessions on session hosts

### Image Management
#### Golden Image Update Process
1. **Preparation Phase**
   - Create new VM from current golden image
   - Install latest Windows updates
   - Update applications to latest versions
   - Apply security configurations and policies

2. **Testing Phase**
   - Test all critical applications
   - Verify user experience and performance
   - Validate security controls and compliance
   - Conduct user acceptance testing

3. **Deployment Phase**
   - Create new image version
   - Update host pool configuration
   - Deploy new session hosts with updated image
   - Migrate users to new session hosts
   - Decommission old session hosts

## Incident Response

### Incident Classification
| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| Critical | Service unavailable | 15 minutes | Complete service outage |
| High | Major functionality impacted | 1 hour | Authentication failures |
| Medium | Limited functionality affected | 4 hours | Single application issues |
| Low | Minor issues | 24 hours | Performance degradation |

### Incident Response Procedures
#### Service Outage Response
1. **Initial Assessment (0-15 minutes)**
   - Verify outage scope and impact
   - Check Azure Service Health dashboard
   - Notify incident response team
   - Create incident ticket and communication

2. **Investigation Phase (15-60 minutes)**
   - Review monitoring alerts and logs
   - Test connectivity from multiple locations
   - Check recent configuration changes
   - Validate infrastructure components

3. **Resolution Phase**
   - Implement immediate workarounds if available
   - Apply fixes based on root cause analysis
   - Monitor service restoration progress
   - Communicate updates to stakeholders

4. **Recovery Verification**
   - Test user connections and functionality
   - Monitor system performance post-recovery
   - Document resolution steps and lessons learned
   - Conduct post-incident review

### Emergency Contacts
| Role | Name | Phone | Email | Escalation |
|------|------|-------|-------|------------|
| Primary On-Call | [NAME] | [PHONE] | [EMAIL] | Immediate |
| Secondary On-Call | [NAME] | [PHONE] | [EMAIL] | 30 minutes |
| Manager | [NAME] | [PHONE] | [EMAIL] | 1 hour |
| Executive | [NAME] | [PHONE] | [EMAIL] | 2 hours |

## Backup and Recovery

### Backup Procedures
#### FSLogix Profile Backup
```powershell
# Verify backup job status
$backupVault = "rsv-avd-prod"
$resourceGroup = "rg-avd-prod"

Get-AzRecoveryServicesBackupJob -VaultId $vault.ID | 
Where-Object {$_.StartTime -gt (Get-Date).AddDays(-1)} |
Select-Object JobId, Operation, Status, StartTime, EndTime
```

#### Session Host Configuration Backup
- Document session host configurations
- Export registry settings and group policies
- Backup custom applications and settings
- Maintain infrastructure as code templates

### Recovery Procedures
#### Profile Recovery Process
1. **Identify Recovery Requirements**
   - Determine specific user profiles to recover
   - Identify recovery point and time range
   - Validate recovery permissions and access

2. **Execute Recovery Process**
   ```powershell
   # Restore user profile from backup
   $restoreJob = Restore-AzRecoveryServicesBackupItem -Item $profileItem -RecoveryPoint $recoveryPoint
   Wait-AzRecoveryServicesBackupJob -Job $restoreJob
   ```

3. **Post-Recovery Verification**
   - Test user login and profile loading
   - Verify application settings and data
   - Validate file and folder permissions
   - Conduct user acceptance testing

## Security Operations

### Security Monitoring
#### Daily Security Checks
- Review authentication failures and suspicious activities
- Monitor privileged account usage
- Check for unauthorized configuration changes
- Validate compliance with security policies

#### Security Event Response
```kusto
// Monitor for security events
SecurityEvent
| where TimeGenerated > ago(24h)
| where EventID in (4625, 4648, 4672)
| where Computer startswith "vm-avd"
| summarize count() by EventID, Computer
```

### Compliance Management
#### Regular Compliance Tasks
- Review and update security policies
- Conduct access certification reviews
- Validate data protection controls
- Maintain audit logs and documentation

## Performance Optimization

### Performance Tuning Guidelines
#### Session Host Optimization
- Configure Windows performance settings
- Optimize application startup and caching
- Implement FSLogix best practices
- Configure network and storage optimization

#### User Experience Optimization
- Monitor and optimize login times
- Implement application pre-loading
- Configure printer and device redirection
- Optimize image quality and compression settings

### Cost Optimization
#### Cost Management Strategies
- Review and right-size VM instances
- Implement auto-shutdown policies
- Use reserved instances for predictable workloads
- Monitor and optimize storage costs

## Documentation and Knowledge Management

### Runbook Maintenance
- Review and update procedures quarterly
- Incorporate lessons learned from incidents
- Update contact information and escalation paths
- Validate automation scripts and procedures

### Knowledge Sharing
- Conduct regular team training sessions
- Document common issues and resolutions
- Maintain FAQ and troubleshooting guides
- Share best practices across teams

## Automation and Scripting

### Common Administrative Scripts
#### User Session Management
```powershell
# Force logoff idle sessions
$idleThreshold = 120 # minutes
Get-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName |
Where-Object {$_.IdleTime -gt $idleThreshold} |
ForEach-Object {
    Remove-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName -SessionHostName $_.SessionHostName -Id $_.Id -Force
}
```

#### Resource Cleanup
```powershell
# Clean up disconnected sessions
Get-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName |
Where-Object {$_.SessionState -eq "Disconnected"} |
ForEach-Object {
    Remove-AzWvdUserSession -ResourceGroupName $resourceGroup -HostPoolName $hostPoolName -SessionHostName $_.SessionHostName -Id $_.Id
}
```

## Change Management

### Change Control Process
1. **Change Request Submission**
   - Document proposed changes and justification
   - Assess impact and risk level
   - Obtain necessary approvals

2. **Change Implementation**
   - Schedule implementation during maintenance windows
   - Follow documented procedures and rollback plans
   - Monitor implementation progress and results

3. **Change Verification**
   - Test functionality and performance post-change
   - Validate security and compliance requirements
   - Document implementation results and lessons learned

### Emergency Change Procedures
- Fast-track approval process for critical issues
- Implement changes with limited testing if necessary
- Document emergency changes for post-implementation review
- Conduct thorough testing and validation after resolution
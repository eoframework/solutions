# Azure DevOps Enterprise Platform - Operations Runbook

This runbook provides comprehensive guidance for day-to-day operations, monitoring, maintenance, and troubleshooting of the Azure DevOps enterprise platform.

## Table of Contents

- [Daily Operations](#daily-operations)
- [Monitoring and Alerting](#monitoring-and-alerting)
- [Maintenance Procedures](#maintenance-procedures)
- [Backup and Recovery](#backup-and-recovery)
- [Performance Management](#performance-management)
- [Security Operations](#security-operations)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Incident Response](#incident-response)
- [Capacity Planning](#capacity-planning)

## Daily Operations

### Daily Health Checks

#### System Status Verification
```bash
# Daily health check script
#!/bin/bash

echo "=== Azure DevOps Daily Health Check ==="
echo "Date: $(date)"

# Check Azure DevOps Service Status
curl -s "https://status.dev.azure.com/api/v2/status.json" | jq '.status.description'

# Check organization accessibility
az devops configure --defaults organization=https://dev.azure.com/contoso-enterprise-devops
az devops project list --query "[].name" -o table

# Check recent pipeline runs
az pipelines runs list --top 10 --query "[].{Name:definition.name, Status:result, Date:finishTime}" -o table

# Check service connections
az devops service-endpoint list --query "[].{Name:name, Status:isReady}" -o table

# Check agent pools
az pipelines pool list --query "[].{Name:name, Size:size}" -o table

echo "=== Health Check Complete ==="
```

#### Build Pipeline Monitoring
```powershell
# PowerShell script for pipeline monitoring
$orgUrl = "https://dev.azure.com/contoso-enterprise-devops"
$project = "Enterprise-App-Platform"

# Get failed builds from last 24 hours
$failedBuilds = az pipelines runs list --status failed --query-order QueueTimeDesc --top 20 | ConvertFrom-Json

Write-Host "Failed Builds in Last 24 Hours: $($failedBuilds.Count)"

foreach ($build in $failedBuilds) {
    Write-Host "- $($build.definition.name): $($build.result) at $($build.finishTime)"
}

# Check queue length
$queuedBuilds = az pipelines runs list --status inProgress | ConvertFrom-Json
Write-Host "Builds Currently Running: $($queuedBuilds.Count)"
```

### Routine Maintenance Tasks

#### Weekly Tasks (Monday)
- [ ] Review system performance metrics
- [ ] Check storage utilization
- [ ] Review security alerts
- [ ] Update documentation changes
- [ ] Review agent pool capacity

#### Monthly Tasks (1st of month)
- [ ] Review and rotate service principal secrets
- [ ] Update security compliance reports
- [ ] Perform capacity planning review
- [ ] Review and update runbooks
- [ ] Conduct disaster recovery testing

#### Quarterly Tasks
- [ ] Complete security assessment
- [ ] Review and update backup strategies
- [ ] Performance benchmarking
- [ ] Cost optimization review
- [ ] Update emergency procedures

## Monitoring and Alerting

### Key Performance Indicators

#### System Health Metrics
```yaml
# Monitoring configuration
monitoring_metrics:
  availability:
    target: 99.9%
    measurement: "Uptime percentage over 30 days"
    alert_threshold: 99.5%
    
  build_success_rate:
    target: 95%
    measurement: "Successful builds / Total builds"
    alert_threshold: 90%
    
  deployment_frequency:
    target: "10 per day"
    measurement: "Successful deployments per day"
    alert_threshold: "5 per day"
    
  lead_time:
    target: "< 4 hours"
    measurement: "Commit to production time"
    alert_threshold: "8 hours"
    
  mean_time_to_recovery:
    target: "< 1 hour"
    measurement: "Incident detection to resolution"
    alert_threshold: "2 hours"
```

#### Azure Monitor Queries
```kusto
// Build failure rate by project
AzureDevOpsBuilds
| where TimeGenerated > ago(7d)
| summarize 
    TotalBuilds = count(),
    FailedBuilds = countif(Result == "Failed"),
    SuccessRate = round((count() - countif(Result == "Failed")) * 100.0 / count(), 2)
  by ProjectName
| order by SuccessRate asc

// Agent utilization
AzureDevOpsAgentJobs
| where TimeGenerated > ago(1d)
| summarize 
    TotalJobs = count(),
    AvgDuration = avg(DurationSeconds)
  by AgentPoolName, bin(TimeGenerated, 1h)
| render timechart

// Pipeline execution trends
AzureDevOpsPipelines
| where TimeGenerated > ago(30d)
| summarize 
    AvgDuration = avg(DurationMinutes),
    Count = count()
  by bin(TimeGenerated, 1d), PipelineName
| render timechart
```

### Alert Configuration

#### Critical Alerts
```yaml
# Azure Monitor alert rules
alerts:
  build_failures:
    description: "High build failure rate detected"
    query: "AzureDevOpsBuilds | where Result == 'Failed'"
    threshold: "10 failures in 1 hour"
    severity: "Critical"
    action_group: "DevOps-OnCall"
    
  service_unavailable:
    description: "Azure DevOps service unavailable"
    query: "Heartbeat | where Computer contains 'devops'"
    threshold: "No heartbeat for 5 minutes"
    severity: "Critical"
    action_group: "DevOps-OnCall"
    
  agent_pool_capacity:
    description: "Agent pool at capacity"
    query: "AzureDevOpsAgents | where Status == 'busy'"
    threshold: "90% of agents busy for 30 minutes"
    severity: "High"
    action_group: "DevOps-Team"
    
  security_scan_failures:
    description: "Security scans failing"
    query: "AzureDevOpsPipelines | where contains(TaskName, 'Security')"
    threshold: "5 security scan failures in 1 hour"
    severity: "High"
    action_group: "Security-Team"
```

### Dashboard Configuration

#### Operations Dashboard (Azure Workbook)
```json
{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDevOpsBuilds | where TimeGenerated > ago(1d) | summarize count() by Result",
        "size": 0,
        "title": "Build Results (24h)",
        "visualization": "piechart"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDevOpsAgents | summarize count() by Status",
        "size": 0,
        "title": "Agent Status",
        "visualization": "barchart"
      }
    }
  ]
}
```

## Maintenance Procedures

### System Updates

#### Azure DevOps Extensions Updates
```bash
#!/bin/bash
# Extension update script

echo "Checking for extension updates..."

# List installed extensions
extensions=$(az devops extension list --query "[].{id:extensionId, version:version}" -o tsv)

while IFS=$'\t' read -r ext_id version; do
    echo "Checking $ext_id (current: $version)"
    # Check for updates (manual process - Azure CLI doesn't support this yet)
    echo "Manual check required for $ext_id"
done <<< "$extensions"
```

#### Agent Pool Maintenance
```powershell
# Agent pool maintenance script
$pools = az pipelines pool list | ConvertFrom-Json

foreach ($pool in $pools) {
    Write-Host "Checking pool: $($pool.name)"
    
    # Get agents in pool
    $agents = az pipelines agent list --pool-id $pool.id | ConvertFrom-Json
    
    foreach ($agent in $agents) {
        if ($agent.status -eq "offline") {
            Write-Host "WARNING: Agent $($agent.name) is offline"
        }
        
        # Check agent version
        if ($agent.version -lt "2.210.1") {
            Write-Host "WARNING: Agent $($agent.name) needs update"
        }
    }
}
```

### Database Maintenance

#### Repository Cleanup
```bash
# Repository maintenance script
#!/bin/bash

# Clean up old branches (merged branches older than 30 days)
repos=$(az repos list --query "[].id" -o tsv)

for repo in $repos; do
    echo "Cleaning repository: $repo"
    
    # Get merged branches older than 30 days
    old_branches=$(az repos ref list --repository $repo --filter "heads" \
        --query "[?contains(name, 'refs/heads/') && !contains(name, 'main') && !contains(name, 'develop')]" \
        -o tsv)
    
    # Delete old branches (requires manual approval)
    echo "Found $(echo "$old_branches" | wc -l) candidate branches for deletion"
done
```

#### Work Item Maintenance
```sql
-- SQL queries for Azure DevOps database (read-only access)
-- These are example queries - actual implementation depends on reporting APIs

-- Find stale work items
SELECT 
    Id,
    Title,
    State,
    ChangedDate
FROM WorkItems
WHERE State = 'New' 
    AND ChangedDate < DATEADD(day, -90, GETDATE())
    AND WorkItemType != 'Epic'

-- Review cycle time metrics
SELECT 
    WorkItemType,
    AVG(DATEDIFF(day, CreatedDate, ClosedDate)) as AvgCycleTime
FROM WorkItems
WHERE State = 'Closed'
    AND ClosedDate > DATEADD(day, -30, GETDATE())
GROUP BY WorkItemType
```

## Backup and Recovery

### Backup Procedures

#### Repository Backup
```bash
#!/bin/bash
# Repository backup script

backup_dir="/backups/devops/$(date +%Y%m%d)"
mkdir -p "$backup_dir"

# Get all repositories
repos=$(az repos list --query "[].{name:name, id:id}" -o json)

echo "$repos" | jq -r '.[] | "\(.name) \(.id)"' | while read name id; do
    echo "Backing up repository: $name"
    
    # Clone repository
    git clone "https://dev.azure.com/contoso-enterprise-devops/Enterprise-App-Platform/_git/$name" "$backup_dir/$name"
    
    # Create archive
    cd "$backup_dir"
    tar -czf "$name-$(date +%Y%m%d).tar.gz" "$name"
    rm -rf "$name"
done
```

#### Configuration Backup
```powershell
# PowerShell script for configuration backup
$backupDate = Get-Date -Format "yyyyMMdd"
$backupPath = "C:\Backups\DevOps\$backupDate"
New-Item -Path $backupPath -ItemType Directory -Force

# Export project configurations
$projects = az devops project list | ConvertFrom-Json

foreach ($project in $projects.value) {
    Write-Host "Backing up project: $($project.name)"
    
    # Export project settings (manual process - requires custom tooling)
    $projectConfig = @{
        name = $project.name
        description = $project.description
        visibility = $project.visibility
        capabilities = $project.capabilities
    }
    
    $projectConfig | ConvertTo-Json -Depth 10 | Out-File "$backupPath\$($project.name)-config.json"
}

# Backup service connections (metadata only)
$serviceConnections = az devops service-endpoint list | ConvertFrom-Json
$serviceConnections | ConvertTo-Json -Depth 10 | Out-File "$backupPath\service-connections.json"

# Backup variable groups (metadata only)
$variableGroups = az pipelines variable-group list | ConvertFrom-Json
$variableGroups | ConvertTo-Json -Depth 10 | Out-File "$backupPath\variable-groups.json"
```

### Recovery Procedures

#### Repository Recovery
```bash
#!/bin/bash
# Repository recovery script

repository_name="$1"
backup_date="$2"
backup_path="/backups/devops/$backup_date"

if [ -z "$repository_name" ] || [ -z "$backup_date" ]; then
    echo "Usage: $0 <repository_name> <backup_date>"
    exit 1
fi

# Extract backup
cd "$backup_path"
tar -xzf "$repository_name-$backup_date.tar.gz"

# Create new repository
az repos create --name "$repository_name-recovered"

# Push backup to new repository
cd "$repository_name"
git remote set-url origin "https://dev.azure.com/contoso-enterprise-devops/Enterprise-App-Platform/_git/$repository_name-recovered"
git push origin --all
git push origin --tags

echo "Repository recovery complete: $repository_name-recovered"
```

## Performance Management

### Performance Monitoring

#### Build Performance Analysis
```kusto
// Build performance trends
AzureDevOpsBuilds
| where TimeGenerated > ago(30d)
| extend DurationMinutes = DurationSeconds / 60
| summarize 
    AvgDuration = avg(DurationMinutes),
    MaxDuration = max(DurationMinutes),
    BuildCount = count()
  by bin(TimeGenerated, 1d), DefinitionName
| order by TimeGenerated desc

// Slowest build steps
AzureDevOpsBuildSteps
| where TimeGenerated > ago(7d)
| extend DurationMinutes = DurationSeconds / 60
| summarize 
    AvgDuration = avg(DurationMinutes),
    MaxDuration = max(DurationMinutes),
    Count = count()
  by TaskName
| order by AvgDuration desc
| take 20
```

#### Agent Performance Optimization
```bash
#!/bin/bash
# Agent performance monitoring

# Check agent resource usage
echo "=== Agent Performance Check ==="

# Get agent pools
pools=$(az pipelines pool list --query "[].id" -o tsv)

for pool_id in $pools; do
    pool_name=$(az pipelines pool show --pool-id $pool_id --query "name" -o tsv)
    echo "Pool: $pool_name"
    
    # Get agents in pool
    agents=$(az pipelines agent list --pool-id $pool_id --query "[].{name:name, status:status, version:version}" -o json)
    
    echo "$agents" | jq -r '.[] | "  Agent: \(.name) - Status: \(.status) - Version: \(.version)"'
done
```

### Optimization Strategies

#### Pipeline Optimization
```yaml
# Optimized pipeline template
parameters:
  - name: enableParallelJobs
    type: boolean
    default: true
  - name: cacheEnabled
    type: boolean
    default: true

jobs:
- ${{ if eq(parameters.enableParallelJobs, true) }}:
  - job: BuildAndTest
    strategy:
      parallel: 3
    steps:
    - ${{ if eq(parameters.cacheEnabled, true) }}:
      - task: Cache@2
        inputs:
          key: 'nuget | "$(Agent.OS)" | **/packages.lock.json,!**/bin/**'
          path: $(NUGET_PACKAGES)
        displayName: Cache NuGet packages
        
    - task: DotNetCoreCLI@2
      displayName: 'Parallel build'
      inputs:
        command: 'build'
        arguments: '--parallel'
```

## Security Operations

### Security Monitoring

#### Daily Security Checks
```bash
#!/bin/bash
# Daily security check script

echo "=== Daily Security Check ==="

# Check for failed security scans
az pipelines runs list --status failed --query "[?contains(definition.name, 'Security')]" -o table

# Check service principal expiration
# (Requires custom script to check Azure AD)
echo "Checking service principal certificates..."

# Review recent security events
echo "Recent security-related pipeline runs:"
az pipelines runs list --top 20 --query "[?contains(definition.name, 'Security') || contains(definition.name, 'Compliance')]" -o table

# Check for unauthorized access patterns
echo "Reviewing access logs (manual review required)"
```

#### Security Compliance Checks
```powershell
# Security compliance validation
$complianceChecks = @{
    "Two-Factor Authentication" = $true
    "Service Principal Rotation" = $false
    "Secrets in Key Vault" = $true
    "Branch Policies Enabled" = $true
    "Security Scanning Enabled" = $true
}

Write-Host "=== Security Compliance Status ==="
foreach ($check in $complianceChecks.GetEnumerator()) {
    $status = if ($check.Value) { "✓ PASS" } else { "✗ FAIL" }
    Write-Host "$($check.Key): $status"
}
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Build Failures

**Issue: NuGet package restore failures**
```bash
# Solution: Clear NuGet cache
az pipelines run --name "Clear-NuGet-Cache"

# Or manually clear cache on agent
dotnet nuget locals all --clear
```

**Issue: Test failures due to environment**
```yaml
# Solution: Add environment setup to pipeline
- task: PowerShell@2
  displayName: 'Setup test environment'
  inputs:
    script: |
      # Reset test database
      sqlcmd -S $(TestDbServer) -d $(TestDatabase) -Q "EXEC sp_reset_testdb"
      
      # Clear temp files
      Remove-Item -Path $env:TEMP\testdata -Recurse -Force -ErrorAction SilentlyContinue
```

#### Agent Issues

**Issue: Agents going offline**
```bash
# Diagnosis: Check agent logs
az pipelines agent show --pool-id 1 --agent-id 2 --include-last-completed-request

# Solution: Restart agent service
sudo systemctl restart vsts.agent.contoso-enterprise-devops.*
```

**Issue: Agent pool capacity**
```bash
# Solution: Add more agents or optimize builds
# Check current utilization
az pipelines pool list --action list --pool-name "Default"

# Add new agent (manual process)
./config.sh --unattended --url https://dev.azure.com/contoso-enterprise-devops --auth pat --token $PAT --pool Default
```

#### Service Connection Issues

**Issue: Service principal authentication failures**
```bash
# Diagnosis: Test service connection
az devops service-endpoint list --query "[?authorization.scheme=='ServicePrincipal']"

# Solution: Rotate service principal secret
az ad sp credential reset --name $SERVICE_PRINCIPAL_NAME --credential-description "Updated by ops team"
```

### Escalation Procedures

#### Incident Severity Levels

| Severity | Description | Response Time | Escalation |
|----------|-------------|---------------|------------|
| Critical | Production down, data loss | 15 minutes | Immediate |
| High | Significant functionality impacted | 1 hour | 2 hours |
| Medium | Limited functionality impacted | 4 hours | 1 day |
| Low | Minor issues, feature requests | 1 day | 1 week |

#### On-Call Procedures

```yaml
# On-call rotation configuration
on_call:
  primary: "devops-engineer@contoso.com"
  secondary: "platform-engineer@contoso.com"
  escalation: "engineering-manager@contoso.com"
  
  contact_methods:
    - email
    - sms
    - phone
    
  escalation_timeline:
    - 0_minutes: "Primary on-call"
    - 30_minutes: "Secondary on-call"
    - 60_minutes: "Manager escalation"
    - 120_minutes: "Director escalation"
```

## Incident Response

### Incident Classification

#### Production Incidents
```bash
#!/bin/bash
# Incident response script

incident_severity="$1"
incident_description="$2"

case $incident_severity in
    "critical")
        echo "CRITICAL INCIDENT: $incident_description"
        # Notify all stakeholders
        # Start incident bridge
        # Begin documentation
        ;;
    "high")
        echo "HIGH SEVERITY: $incident_description"
        # Notify team leads
        # Document issue
        ;;
esac
```

#### Communication Templates

**Critical Incident Communication**
```
Subject: [CRITICAL] Azure DevOps Production Issue - $TIMESTAMP

Issue: $DESCRIPTION
Impact: $IMPACT_STATEMENT
ETA: $ESTIMATED_RESOLUTION
Next Update: $NEXT_UPDATE_TIME

Actions Taken:
- $ACTION_1
- $ACTION_2

Investigation Status:
$INVESTIGATION_STATUS

Contact: $ON_CALL_ENGINEER
```

## Capacity Planning

### Resource Utilization Monitoring

#### Agent Pool Analysis
```kusto
// Agent utilization analysis
AzureDevOpsAgentJobs
| where TimeGenerated > ago(30d)
| summarize 
    TotalJobs = count(),
    TotalDurationHours = sum(DurationSeconds) / 3600,
    AvgConcurrentJobs = avg(ConcurrentJobs)
  by bin(TimeGenerated, 1d), AgentPoolName
| extend UtilizationPercentage = (TotalDurationHours / 24) * 100
| render timechart
```

#### Storage Growth Monitoring
```bash
#!/bin/bash
# Storage utilization monitoring

# Check artifact storage
az artifacts universal list --organization "https://dev.azure.com/contoso-enterprise-devops" \
    --scope organization --feed "enterprise-packages" \
    --query "length(@)" -o tsv

# Repository size analysis
repos=$(az repos list --query "[].name" -o tsv)

for repo in $repos; do
    size=$(az repos show --repository "$repo" --query "size" -o tsv)
    echo "Repository: $repo - Size: ${size}MB"
done
```

### Scaling Recommendations

#### Horizontal Scaling Triggers
- Agent utilization > 80% for 7 consecutive days
- Build queue time > 10 minutes average
- Failed builds due to timeout > 5% of total builds

#### Vertical Scaling Triggers
- Individual build duration > 2 hours
- Memory utilization > 85% on agents
- CPU utilization > 80% sustained for builds

---

*This operations runbook provides comprehensive guidance for maintaining Azure DevOps enterprise platform. Regular updates ensure accuracy and effectiveness of operational procedures.*
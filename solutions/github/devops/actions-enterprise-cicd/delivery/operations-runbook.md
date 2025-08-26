# Operations Runbook - GitHub Actions Enterprise CI/CD Platform

## Overview

This operations runbook provides comprehensive procedures for managing, monitoring, and troubleshooting the GitHub Actions Enterprise CI/CD Platform in production environments.

## Table of Contents

1. [System Overview](#system-overview)
2. [Monitoring and Alerting](#monitoring-and-alerting)
3. [Daily Operations](#daily-operations)
4. [Incident Management](#incident-management)
5. [Maintenance Procedures](#maintenance-procedures)
6. [Performance Optimization](#performance-optimization)
7. [Security Operations](#security-operations)
8. [Backup and Recovery](#backup-and-recovery)
9. [Troubleshooting Guide](#troubleshooting-guide)
10. [Emergency Procedures](#emergency-procedures)

## System Overview

### Architecture Components
- **GitHub Enterprise Organization**: Central code repository and workflow orchestration
- **Self-Hosted Runners**: AWS Auto Scaling Groups for build and deployment execution
- **GitHub Actions Workflows**: Automated CI/CD pipeline definitions
- **Secrets Management**: Encrypted storage for sensitive configuration data
- **Monitoring Infrastructure**: CloudWatch, Prometheus, and Grafana for observability

### Key Performance Indicators
- **Platform Availability**: >99.9% uptime
- **Workflow Success Rate**: >95% successful completion
- **Mean Time to Deployment**: <30 minutes
- **Runner Utilization**: 60-80% average utilization
- **Queue Wait Time**: <2 minutes average

## Monitoring and Alerting

### Primary Monitoring Dashboards

#### GitHub Actions Dashboard
```bash
# Access GitHub Actions insights
gh api /orgs/{org}/actions/cache/usage
gh api /orgs/{org}/actions/billing/actions
gh api /orgs/{org}/actions/runners
```

#### Infrastructure Monitoring
```bash
# Check runner health
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names github-actions-runners
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization
```

### Critical Alerts

#### High Priority Alerts
1. **Platform Unavailable** (>5 minutes downtime)
2. **Workflow Failure Rate** (>10% failure rate)
3. **Runner Shortage** (<2 available runners)
4. **Security Alert** (Failed authentication attempts)

#### Medium Priority Alerts
1. **High Queue Wait Times** (>5 minutes)
2. **Runner Performance Degradation** (>80% CPU for >15 minutes)
3. **Storage Usage** (>80% disk utilization)
4. **Network Connectivity Issues**

### Alerting Configuration
```yaml
# CloudWatch Alarm Configuration
RunnerAvailabilityAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: GitHub-Actions-Runner-Availability
    AlarmDescription: Monitor available GitHub Actions runners
    MetricName: HealthyHostCount
    Namespace: AWS/ApplicationELB
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 2
    ComparisonOperator: LessThanThreshold
    AlarmActions:
      - !Ref SNSTopic
```

## Daily Operations

### Morning Health Check (9:00 AM)
```bash
#!/bin/bash
# daily-health-check.sh

echo "=== GitHub Actions Platform Health Check ==="
echo "Date: $(date)"
echo

# Check GitHub API status
echo "1. Checking GitHub API status..."
gh api /rate_limit

# Check runner availability
echo "2. Checking runner availability..."
AVAILABLE_RUNNERS=$(gh api /orgs/$GITHUB_ORG/actions/runners | jq '[.runners[] | select(.status == "online")] | length')
echo "Available runners: $AVAILABLE_RUNNERS"

# Check recent workflow runs
echo "3. Checking recent workflow runs..."
FAILED_RUNS=$(gh api /repos/$GITHUB_ORG/.github/actions/runs --jq '[.workflow_runs[] | select(.status == "completed" and .conclusion == "failure" and (now - (.created_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) < 86400))] | length')
echo "Failed runs in last 24h: $FAILED_RUNS"

# Check runner queue
echo "4. Checking runner queue..."
QUEUED_JOBS=$(gh api /repos/$GITHUB_ORG/.github/actions/runs --jq '[.workflow_runs[] | select(.status == "queued")] | length')
echo "Queued jobs: $QUEUED_JOBS"

# Generate summary
echo
echo "=== Health Check Summary ==="
if [ $AVAILABLE_RUNNERS -lt 2 ]; then
    echo "⚠️  WARNING: Low runner availability ($AVAILABLE_RUNNERS)"
fi

if [ $FAILED_RUNS -gt 10 ]; then
    echo "⚠️  WARNING: High failure rate ($FAILED_RUNS failures in 24h)"
fi

if [ $QUEUED_JOBS -gt 5 ]; then
    echo "⚠️  WARNING: High queue depth ($QUEUED_JOBS queued jobs)"
fi

echo "✅ Health check completed"
```

### Weekly Maintenance Tasks

#### Every Monday (10:00 AM)
1. **Runner Maintenance**
   - Check runner software updates
   - Verify runner registration status
   - Clean up orphaned runners

2. **Performance Review**
   - Analyze workflow performance metrics
   - Review runner utilization reports
   - Identify optimization opportunities

3. **Security Audit**
   - Review access logs
   - Check secret rotation status
   - Validate security policies

#### Monthly Tasks
1. **Capacity Planning**
   - Review usage trends and growth
   - Adjust auto-scaling parameters
   - Plan for upcoming workload changes

2. **Cost Optimization**
   - Analyze runner usage patterns
   - Optimize instance types and sizing
   - Review GitHub Actions billing

## Incident Management

### Incident Response Procedures

#### Severity Levels
- **P1 (Critical)**: Platform completely unavailable, security breach
- **P2 (High)**: Significant performance degradation, partial outage
- **P3 (Medium)**: Isolated issues, workarounds available
- **P4 (Low)**: Minor issues, scheduled maintenance

#### P1 Incident Response
```bash
# P1 Incident Response Checklist
1. Acknowledge incident within 15 minutes
2. Assemble incident response team
3. Create incident communication channel
4. Notify stakeholders immediately
5. Begin troubleshooting and recovery procedures
6. Provide hourly status updates
7. Document all actions taken
8. Conduct post-incident review
```

#### Common Incident Scenarios

##### Scenario 1: All Runners Offline
```bash
# Troubleshooting steps
1. Check AWS Auto Scaling Group status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names github-actions-runners

2. Check CloudWatch logs for errors
aws logs filter-log-events --log-group-name /aws/ec2/github-runners

3. Verify network connectivity
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

4. Restart Auto Scaling Group if needed
aws autoscaling update-auto-scaling-group --auto-scaling-group-name github-actions-runners --desired-capacity 3
```

##### Scenario 2: High Workflow Failure Rate
```bash
# Investigation steps
1. Check recent failed workflows
gh run list --status failure --limit 20

2. Analyze common failure patterns
gh run view <run-id> --log

3. Check for infrastructure issues
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name StatusCheckFailed

4. Review recent configuration changes
git log --oneline --since="24 hours ago" .github/workflows/
```

### Escalation Procedures
1. **Level 1**: Operations team attempts resolution (0-30 minutes)
2. **Level 2**: Senior engineer and platform team (30-60 minutes)
3. **Level 3**: Engineering manager and GitHub support (60+ minutes)
4. **Level 4**: Executive escalation for business impact

## Maintenance Procedures

### Scheduled Maintenance Windows
- **Primary Window**: Saturday 2:00 AM - 6:00 AM EST
- **Secondary Window**: Wednesday 10:00 PM - 2:00 AM EST

### Pre-Maintenance Checklist
```bash
# Pre-maintenance checklist
1. Notify stakeholders 48 hours in advance
2. Create maintenance branch for any configuration changes
3. Backup current configuration
4. Prepare rollback procedures
5. Schedule maintenance window in GitHub
6. Coordinate with development teams
```

### Runner Maintenance Procedures

#### Runner Software Updates
```bash
#!/bin/bash
# update-runners.sh

# Create new AMI with updated GitHub Actions runner
aws ec2 create-image --instance-id i-xxxxxxxxx --name "github-runner-$(date +%Y%m%d)"

# Update launch template with new AMI
aws ec2 modify-launch-template --launch-template-id lt-xxxxxxxxx --launch-template-data '{"ImageId":"ami-xxxxxxxxx"}'

# Perform rolling update of Auto Scaling Group
aws autoscaling start-instance-refresh --auto-scaling-group-name github-actions-runners
```

#### Configuration Updates
```bash
# Update GitHub Actions runner configuration
1. Test changes in development environment
2. Create pull request with configuration changes
3. Review and approve changes
4. Deploy during maintenance window
5. Verify all runners register successfully
6. Monitor for 30 minutes post-deployment
```

### GitHub Organization Maintenance
```bash
# Monthly organization maintenance
1. Review and update organization settings
2. Audit team memberships and permissions
3. Clean up unused repositories and branches
4. Update organization secrets and variables
5. Review and update security policies
```

## Performance Optimization

### Performance Monitoring
```bash
# Performance monitoring script
#!/bin/bash
# performance-monitor.sh

# Workflow performance metrics
echo "=== Workflow Performance Metrics ==="
gh api graphql -f query='
query {
  organization(login: "'$GITHUB_ORG'") {
    repositories(first: 20) {
      nodes {
        name
        defaultBranchRef {
          target {
            ... on Commit {
              checkSuites(last: 10) {
                nodes {
                  conclusion
                  createdAt
                  updatedAt
                }
              }
            }
          }
        }
      }
    }
  }
}'

# Runner utilization metrics
echo "=== Runner Utilization Metrics ==="
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=github-actions-runners \
  --start-time $(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%S') \
  --end-time $(date -u '+%Y-%m-%dT%H:%M:%S') \
  --period 3600 \
  --statistics Average,Maximum
```

### Optimization Strategies

#### Workflow Optimization
1. **Parallel Job Execution**: Optimize job dependencies for maximum parallelism
2. **Caching Strategies**: Implement effective build and dependency caching
3. **Resource Right-Sizing**: Match runner specs to workload requirements
4. **Build Optimization**: Minimize build times through optimized configurations

#### Infrastructure Optimization
```bash
# Auto-scaling optimization
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name github-actions-runners \
  --policy-name cpu-scale-up \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration file://scaling-policy.json
```

## Security Operations

### Security Monitoring
```bash
# Security monitoring checklist
1. Monitor failed authentication attempts
2. Review access logs for suspicious activity
3. Validate secret rotation compliance
4. Check for unauthorized repository access
5. Monitor runner security status
```

### Security Incident Response
```bash
# Security incident response
1. Immediately revoke compromised credentials
2. Rotate all potentially affected secrets
3. Review audit logs for breach scope
4. Notify security team and stakeholders
5. Implement additional security controls
6. Conduct security assessment
```

### Access Management
```bash
# Regular access review
1. Audit organization member access
2. Review team permissions and memberships
3. Validate runner access controls
4. Check third-party application access
5. Update access documentation
```

## Backup and Recovery

### Backup Procedures
```bash
# Configuration backup script
#!/bin/bash
# backup-config.sh

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/github-actions/$BACKUP_DATE"

mkdir -p $BACKUP_DIR

# Backup GitHub organization configuration
gh api /orgs/$GITHUB_ORG > $BACKUP_DIR/org-config.json
gh api /orgs/$GITHUB_ORG/actions/permissions > $BACKUP_DIR/actions-permissions.json
gh api /orgs/$GITHUB_ORG/actions/runner-groups > $BACKUP_DIR/runner-groups.json

# Backup repository configurations
for repo in $(gh repo list $GITHUB_ORG --json name -q '.[].name'); do
    mkdir -p $BACKUP_DIR/repos/$repo
    gh api /repos/$GITHUB_ORG/$repo > $BACKUP_DIR/repos/$repo/config.json
    gh api /repos/$GITHUB_ORG/$repo/actions/secrets > $BACKUP_DIR/repos/$repo/secrets.json
done

# Backup Terraform state
aws s3 cp s3://terraform-state-bucket/github-actions.tfstate $BACKUP_DIR/terraform.tfstate

echo "Backup completed: $BACKUP_DIR"
```

### Recovery Procedures
```bash
# Disaster recovery checklist
1. Assess scope of failure and data loss
2. Restore GitHub organization configuration
3. Redeploy infrastructure using Terraform
4. Restore repository configurations and secrets
5. Validate runner connectivity and registration
6. Test workflow execution
7. Notify stakeholders of recovery completion
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: Runners Not Connecting
```bash
# Troubleshooting steps
1. Check runner registration token
gh api -X POST /orgs/$GITHUB_ORG/actions/runners/registration-token

2. Verify network connectivity
curl -I https://github.com

3. Check runner logs
sudo journalctl -u actions.runner.* -f

4. Restart runner service
sudo ./svc.sh stop
sudo ./svc.sh start
```

#### Issue: Slow Workflow Execution
```bash
# Performance troubleshooting
1. Check runner resource utilization
top
iostat -x 1 5

2. Analyze workflow bottlenecks
gh run view <run-id> --log

3. Check network bandwidth
iperf3 -c <target-server>

4. Review caching effectiveness
du -sh ~/.cache/
```

#### Issue: Authentication Failures
```bash
# Authentication troubleshooting
1. Verify GitHub token validity
gh auth status

2. Check secret configuration
gh secret list --org $GITHUB_ORG

3. Validate permissions
gh api /user/permissions/repositories/$GITHUB_ORG

4. Review audit logs
gh api /orgs/$GITHUB_ORG/audit-log
```

### Log Analysis
```bash
# Log analysis commands
# GitHub Actions logs
gh run view <run-id> --log > workflow.log

# Runner system logs
sudo journalctl -u actions.runner.* --since "1 hour ago"

# AWS CloudWatch logs
aws logs filter-log-events --log-group-name /aws/ec2/github-runners --start-time $(date -d '1 hour ago' +%s)000

# Application logs
tail -f /var/log/github-runner/runner.log
```

## Emergency Procedures

### Emergency Contacts
- **Primary On-Call**: [Name] - [Phone] - [Email]
- **Secondary On-Call**: [Name] - [Phone] - [Email]
- **Engineering Manager**: [Name] - [Phone] - [Email]
- **GitHub Support**: Enterprise Support Portal

### Emergency Response Actions

#### Complete Platform Outage
```bash
# Emergency response checklist
1. Acknowledge outage and notify stakeholders (5 minutes)
2. Assemble incident response team (10 minutes)
3. Begin diagnosis and recovery procedures (15 minutes)
4. Implement emergency workarounds if available (30 minutes)
5. Provide hourly status updates to stakeholders
6. Execute recovery procedures
7. Validate platform functionality
8. Document incident and conduct post-mortem
```

#### Security Breach
```bash
# Security breach response
1. Immediately isolate affected systems
2. Revoke all potentially compromised credentials
3. Notify security team and management
4. Preserve evidence for investigation
5. Implement containment measures
6. Begin forensic analysis
7. Communicate with affected parties
8. Implement remediation measures
```

### Rollback Procedures
```bash
# Emergency rollback script
#!/bin/bash
# emergency-rollback.sh

echo "Emergency rollback initiated at $(date)"

# Rollback Terraform infrastructure
cd /terraform/github-actions
terraform apply -target=aws_autoscaling_group.github_runners -var="ami_id=ami-previous"

# Rollback GitHub configuration
gh api -X PUT /orgs/$GITHUB_ORG/actions/permissions --input previous-config.json

# Restart services
aws autoscaling update-auto-scaling-group --auto-scaling-group-name github-actions-runners --desired-capacity 3

echo "Emergency rollback completed at $(date)"
```

## Appendices

### Appendix A: Configuration Files
- GitHub organization settings
- Runner configuration templates
- Terraform variable definitions
- Monitoring configuration

### Appendix B: Contact Information
- Emergency contact list
- Escalation procedures
- Vendor support contacts
- Documentation repositories

### Appendix C: Standard Operating Procedures
- Change management process
- Incident response procedures
- Performance optimization guidelines
- Security compliance requirements
# AWS Cloud Migration - Operations Runbook

## Document Information
**Solution**: AWS On-Premise to Cloud Migration  
**Version**: 1.0  
**Date**: January 2025  
**Audience**: Operations Teams, Support Engineers, Migration Teams  

---

## Overview

This operations runbook provides comprehensive procedures for managing and troubleshooting AWS cloud migration projects and post-migration operations. It includes daily operations, emergency procedures, troubleshooting guides, and maintenance tasks specific to cloud migration scenarios.

---

## Migration Operations

### Daily Migration Activities

#### Morning Migration Health Check

```bash
# Daily migration status check script
cat > daily_migration_check.sh << 'EOF'
#!/bin/bash

echo "=== Daily Migration Health Check - $(date) ==="

# Check AWS Application Migration Service (MGN) status
echo "Checking MGN replication status..."
aws mgn describe-source-servers --query 'items[*].{ServerID:sourceServerID,Hostname:sourceProperties.identificationHints.hostname,Status:dataReplicationInfo.dataReplicationState}' --output table

# Check DMS replication tasks
echo "Checking DMS task status..."
aws dms describe-replication-tasks --query 'ReplicationTasks[*].{TaskID:ReplicationTaskIdentifier,Status:Status,Progress:ReplicationTaskStats.FullLoadProgressPercent}' --output table

# Check recent CloudWatch alarms
echo "Checking recent alarms..."
aws cloudwatch describe-alarms --state-value ALARM --query 'MetricAlarms[*].{AlarmName:AlarmName,StateReason:StateReason}' --output table

# Check migration-related EC2 instances
echo "Checking migration instances..."
aws ec2 describe-instances --filters "Name=tag:Project,Values=cloud-migration" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{InstanceId:InstanceId,Type:InstanceType,State:State.Name,LaunchTime:LaunchTime}' --output table

# Generate summary
echo "Migration health check completed at $(date)"
EOF

chmod +x daily_migration_check.sh
./daily_migration_check.sh
```

#### Replication Monitoring

```python
# Automated replication monitoring
cat > monitor_replication_status.py << 'EOF'
#!/usr/bin/env python3
import boto3
import time
import json
from datetime import datetime, timedelta

class ReplicationMonitor:
    def __init__(self, region='us-east-1'):
        self.mgn = boto3.client('mgn', region_name=region)
        self.dms = boto3.client('dms', region_name=region)
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)
        self.sns = boto3.client('sns', region_name=region)
        
    def check_mgn_replication(self):
        """Monitor MGN replication status"""
        try:
            source_servers = self.mgn.describe_source_servers()['items']
            
            status_summary = {
                'total_servers': len(source_servers),
                'healthy_replications': 0,
                'failed_replications': 0,
                'high_lag_servers': [],
                'ready_for_testing': []
            }
            
            for server in source_servers:
                server_id = server['sourceServerID']
                hostname = server.get('sourceProperties', {}).get('identificationHints', {}).get('hostname', 'Unknown')
                replication_info = server.get('dataReplicationInfo', {})
                replication_state = replication_info.get('dataReplicationState', 'Unknown')
                
                if replication_state == 'CONTINUOUS_REPLICATION':
                    status_summary['healthy_replications'] += 1
                    
                    # Check replication lag
                    lag_info = replication_info.get('lag', {})
                    if lag_info and lag_info.get('duration'):
                        duration = lag_info['duration']
                        # Parse duration (format: PT10M for 10 minutes)
                        if 'PT' in duration:
                            duration_clean = duration.replace('PT', '').replace('M', '').replace('H', '*60+').replace('S', '/60')
                            try:
                                lag_minutes = eval(duration_clean) if '+' in duration_clean else float(duration_clean.replace('/60', ''))
                                if lag_minutes > 60:  # More than 1 hour lag
                                    status_summary['high_lag_servers'].append({
                                        'server_id': server_id,
                                        'hostname': hostname,
                                        'lag_minutes': lag_minutes
                                    })
                            except:
                                pass
                    
                    status_summary['ready_for_testing'].append(server_id)
                    
                elif replication_state in ['FAILED_TO_START_REPLICATION', 'FAILED_TO_CREATE_STAGING_DISKS']:
                    status_summary['failed_replications'] += 1
            
            return status_summary
            
        except Exception as e:
            print(f"Error checking MGN replication: {e}")
            return None
    
    def check_dms_tasks(self):
        """Monitor DMS task status"""
        try:
            tasks = self.dms.describe_replication_tasks()['ReplicationTasks']
            
            task_summary = {
                'total_tasks': len(tasks),
                'running_tasks': 0,
                'failed_tasks': 0,
                'completed_tasks': 0,
                'task_details': []
            }
            
            for task in tasks:
                task_id = task['ReplicationTaskIdentifier']
                status = task['Status']
                
                task_detail = {
                    'task_id': task_id,
                    'status': status,
                    'source_endpoint': task.get('SourceEndpointArn', '').split('/')[-1],
                    'target_endpoint': task.get('TargetEndpointArn', '').split('/')[-1]
                }
                
                if 'ReplicationTaskStats' in task:
                    stats = task['ReplicationTaskStats']
                    task_detail.update({
                        'full_load_progress': stats.get('FullLoadProgressPercent', 0),
                        'tables_loaded': stats.get('TablesLoaded', 0),
                        'tables_loading': stats.get('TablesLoading', 0),
                        'tables_errored': stats.get('TablesErrored', 0)
                    })
                
                if status == 'running':
                    task_summary['running_tasks'] += 1
                elif status == 'failed':
                    task_summary['failed_tasks'] += 1
                elif status == 'stopped' and task_detail.get('full_load_progress', 0) == 100:
                    task_summary['completed_tasks'] += 1
                
                task_summary['task_details'].append(task_detail)
            
            return task_summary
            
        except Exception as e:
            print(f"Error checking DMS tasks: {e}")
            return None
    
    def send_alert(self, topic_arn, subject, message):
        """Send SNS alert"""
        try:
            self.sns.publish(
                TopicArn=topic_arn,
                Subject=subject,
                Message=message
            )
        except Exception as e:
            print(f"Error sending alert: {e}")
    
    def generate_status_report(self):
        """Generate comprehensive status report"""
        report = {
            'timestamp': datetime.now().isoformat(),
            'mgn_status': self.check_mgn_replication(),
            'dms_status': self.check_dms_tasks()
        }
        
        # Check for issues and send alerts
        alerts_sent = []
        
        if report['mgn_status']:
            mgn = report['mgn_status']
            if mgn['failed_replications'] > 0:
                alert_msg = f"MGN Alert: {mgn['failed_replications']} servers have failed replication"
                alerts_sent.append('MGN_FAILED_REPLICATION')
                print(f"ALERT: {alert_msg}")
            
            if mgn['high_lag_servers']:
                lag_details = ', '.join([f"{s['hostname']} ({s['lag_minutes']:.0f}min)" for s in mgn['high_lag_servers']])
                alert_msg = f"MGN Alert: High replication lag detected: {lag_details}"
                alerts_sent.append('MGN_HIGH_LAG')
                print(f"WARNING: {alert_msg}")
        
        if report['dms_status']:
            dms = report['dms_status']
            if dms['failed_tasks'] > 0:
                alert_msg = f"DMS Alert: {dms['failed_tasks']} tasks have failed"
                alerts_sent.append('DMS_FAILED_TASKS')
                print(f"ALERT: {alert_msg}")
        
        report['alerts_sent'] = alerts_sent
        
        # Save report
        filename = f"migration_status_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        return report

if __name__ == "__main__":
    monitor = ReplicationMonitor()
    report = monitor.generate_status_report()
    
    print("\n=== Migration Status Summary ===")
    if report['mgn_status']:
        mgn = report['mgn_status']
        print(f"MGN: {mgn['healthy_replications']}/{mgn['total_servers']} servers replicating normally")
        print(f"     {len(mgn['ready_for_testing'])} servers ready for testing")
        print(f"     {mgn['failed_replications']} failed replications")
    
    if report['dms_status']:
        dms = report['dms_status']
        print(f"DMS: {dms['running_tasks']}/{dms['total_tasks']} tasks running")
        print(f"     {dms['completed_tasks']} tasks completed")
        print(f"     {dms['failed_tasks']} tasks failed")
EOF

python3 monitor_replication_status.py
```

### Migration Wave Management

#### Pre-Wave Validation

```bash
# Pre-wave validation checklist
cat > pre_wave_validation.sh << 'EOF'
#!/bin/bash

WAVE_NAME=$1

if [ -z "$WAVE_NAME" ]; then
    echo "Usage: $0 <wave_name>"
    exit 1
fi

echo "=== Pre-Wave Validation for $WAVE_NAME ==="

# Check prerequisites
echo "1. Checking infrastructure readiness..."
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=cloud-migration" --query 'Vpcs[0].State' --output text

echo "2. Checking security groups..."
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=cloud-migration" --query 'SecurityGroups[*].GroupId' --output text

echo "3. Checking IAM roles..."
aws iam list-roles --query 'Roles[?contains(RoleName, `migration`)].RoleName' --output text

echo "4. Checking replication infrastructure..."
aws mgn describe-replication-configuration-templates --query 'items[0].replicationConfigurationTemplateID' --output text

echo "5. Checking DMS replication instances..."
aws dms describe-replication-instances --query 'ReplicationInstances[*].ReplicationInstanceStatus' --output text

echo "6. Checking network connectivity..."
# Test connectivity to on-premise environment
ping -c 3 10.0.0.1 > /dev/null 2>&1 && echo "On-premise connectivity: OK" || echo "On-premise connectivity: FAILED"

echo "7. Validating backup procedures..."
# Check that backup procedures are in place
aws s3 ls s3://migration-backups-* > /dev/null 2>&1 && echo "Backup bucket accessible: OK" || echo "Backup bucket: NOT FOUND"

echo "Pre-wave validation completed for $WAVE_NAME"
EOF

chmod +x pre_wave_validation.sh
```

#### Wave Execution Monitoring

```python
# Wave execution monitoring script
cat > wave_execution_monitor.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
import time
from datetime import datetime

class WaveExecutionMonitor:
    def __init__(self, region='us-east-1'):
        self.mgn = boto3.client('mgn', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
        
    def start_wave_execution(self, wave_config):
        """Start execution of a migration wave"""
        wave_name = wave_config['wave_name']
        server_ids = wave_config['server_ids']
        
        print(f"Starting execution of {wave_name}")
        print(f"Servers in wave: {len(server_ids)}")
        
        execution_log = {
            'wave_name': wave_name,
            'start_time': datetime.now().isoformat(),
            'server_ids': server_ids,
            'execution_steps': []
        }
        
        # Step 1: Validate all servers are ready
        print("Step 1: Validating server readiness...")
        ready_servers = self._validate_server_readiness(server_ids)
        execution_log['execution_steps'].append({
            'step': 'validation',
            'timestamp': datetime.now().isoformat(),
            'ready_servers': ready_servers,
            'total_servers': len(server_ids)
        })
        
        if len(ready_servers) != len(server_ids):
            print(f"WARNING: Only {len(ready_servers)}/{len(server_ids)} servers are ready")
            return execution_log
        
        # Step 2: Start test instances
        print("Step 2: Starting test instances...")
        test_results = self._start_test_instances(server_ids)
        execution_log['execution_steps'].append({
            'step': 'test_launch',
            'timestamp': datetime.now().isoformat(),
            'test_results': test_results
        })
        
        # Step 3: Monitor test instance launch
        print("Step 3: Monitoring test instance launch...")
        launch_status = self._monitor_test_launch(server_ids)
        execution_log['execution_steps'].append({
            'step': 'test_monitoring',
            'timestamp': datetime.now().isoformat(),
            'launch_status': launch_status
        })
        
        # Step 4: Validate test instances
        print("Step 4: Validating test instances...")
        validation_results = self._validate_test_instances(launch_status)
        execution_log['execution_steps'].append({
            'step': 'test_validation',
            'timestamp': datetime.now().isoformat(),
            'validation_results': validation_results
        })
        
        execution_log['end_time'] = datetime.now().isoformat()
        execution_log['status'] = 'completed' if all(v['status'] == 'success' for v in validation_results.values()) else 'failed'
        
        # Save execution log
        filename = f"wave_execution_{wave_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w') as f:
            json.dump(execution_log, f, indent=2)
        
        return execution_log
    
    def _validate_server_readiness(self, server_ids):
        """Validate that all servers are ready for migration"""
        ready_servers = []
        
        try:
            source_servers = self.mgn.describe_source_servers()['items']
            
            for server in source_servers:
                server_id = server['sourceServerID']
                if server_id in server_ids:
                    replication_state = server.get('dataReplicationInfo', {}).get('dataReplicationState')
                    if replication_state == 'CONTINUOUS_REPLICATION':
                        ready_servers.append(server_id)
                        
        except Exception as e:
            print(f"Error validating server readiness: {e}")
        
        return ready_servers
    
    def _start_test_instances(self, server_ids):
        """Start test instances for specified servers"""
        test_results = {}
        
        for server_id in server_ids:
            try:
                response = self.mgn.start_test(sourceServerIDs=[server_id])
                job_id = response['job']['jobID']
                test_results[server_id] = {
                    'status': 'started',
                    'job_id': job_id
                }
                print(f"Started test for {server_id}, Job ID: {job_id}")
            except Exception as e:
                test_results[server_id] = {
                    'status': 'failed',
                    'error': str(e)
                }
                print(f"Failed to start test for {server_id}: {e}")
        
        return test_results
    
    def _monitor_test_launch(self, server_ids, timeout_minutes=30):
        """Monitor test instance launch progress"""
        start_time = time.time()
        timeout_seconds = timeout_minutes * 60
        
        while time.time() - start_time < timeout_seconds:
            try:
                jobs = self.mgn.describe_jobs()['items']
                launch_status = {}
                
                for job in jobs:
                    if job['type'] == 'LAUNCH':
                        for server in job.get('participatingServers', []):
                            server_id = server['sourceServerID']
                            if server_id in server_ids:
                                launch_status[server_id] = {
                                    'job_status': job['status'],
                                    'job_id': job['jobID'],
                                    'launched_instance': server.get('launchedInstance')
                                }
                
                # Check if all servers have completed
                if len(launch_status) == len(server_ids):
                    all_completed = all(
                        status['job_status'] in ['COMPLETED', 'FAILED'] 
                        for status in launch_status.values()
                    )
                    if all_completed:
                        return launch_status
                
                time.sleep(30)  # Wait 30 seconds before checking again
                
            except Exception as e:
                print(f"Error monitoring test launch: {e}")
                break
        
        print("Timeout reached while monitoring test launch")
        return launch_status if 'launch_status' in locals() else {}
    
    def _validate_test_instances(self, launch_status):
        """Validate launched test instances"""
        validation_results = {}
        
        for server_id, status in launch_status.items():
            validation_results[server_id] = {'status': 'unknown'}
            
            if status['job_status'] == 'COMPLETED' and status.get('launched_instance'):
                instance_id = status['launched_instance'].get('ec2InstanceID')
                
                if instance_id:
                    try:
                        # Check instance status
                        response = self.ec2.describe_instances(InstanceIds=[instance_id])
                        instance = response['Reservations'][0]['Instances'][0]
                        instance_state = instance['State']['Name']
                        
                        if instance_state == 'running':
                            validation_results[server_id] = {
                                'status': 'success',
                                'instance_id': instance_id,
                                'instance_state': instance_state,
                                'private_ip': instance.get('PrivateIpAddress')
                            }
                        else:
                            validation_results[server_id] = {
                                'status': 'failed',
                                'reason': f'Instance state: {instance_state}',
                                'instance_id': instance_id
                            }
                            
                    except Exception as e:
                        validation_results[server_id] = {
                            'status': 'failed',
                            'reason': f'Error checking instance: {str(e)}',
                            'instance_id': instance_id
                        }
                else:
                    validation_results[server_id] = {
                        'status': 'failed',
                        'reason': 'No instance ID found'
                    }
            else:
                validation_results[server_id] = {
                    'status': 'failed',
                    'reason': f"Job status: {status['job_status']}"
                }
        
        return validation_results

# Example wave configuration
if __name__ == "__main__":
    wave_config = {
        'wave_name': 'Wave-1-Foundation',
        'server_ids': ['s-1234567890abcdef0', 's-0987654321fedcba0']  # Replace with actual server IDs
    }
    
    monitor = WaveExecutionMonitor()
    result = monitor.start_wave_execution(wave_config)
    
    print(f"\nWave execution completed with status: {result['status']}")
    print(f"Duration: {result.get('end_time', 'Unknown')}")
EOF
```

### Post-Migration Operations

#### Application Health Monitoring

```python
# Post-migration health monitoring
cat > post_migration_monitor.py << 'EOF'
#!/usr/bin/env python3
import boto3
import requests
import json
import mysql.connector
from datetime import datetime
import concurrent.futures

class PostMigrationMonitor:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.rds = boto3.client('rds', region_name=region)
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)
        
    def check_application_health(self, app_config):
        """Check application health endpoints"""
        health_results = {}
        
        for app_name, config in app_config.items():
            try:
                endpoint = config['health_endpoint']
                timeout = config.get('timeout', 10)
                
                response = requests.get(endpoint, timeout=timeout)
                
                health_results[app_name] = {
                    'status': 'healthy' if response.status_code == 200 else 'unhealthy',
                    'status_code': response.status_code,
                    'response_time': response.elapsed.total_seconds(),
                    'timestamp': datetime.now().isoformat()
                }
                
                if response.status_code == 200:
                    try:
                        health_results[app_name]['response_body'] = response.json()
                    except:
                        health_results[app_name]['response_body'] = response.text[:200]
                        
            except Exception as e:
                health_results[app_name] = {
                    'status': 'error',
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                }
        
        return health_results
    
    def check_database_health(self, db_config):
        """Check database connectivity and performance"""
        db_results = {}
        
        for db_name, config in db_config.items():
            try:
                connection = mysql.connector.connect(
                    host=config['host'],
                    port=config['port'],
                    user=config['username'],
                    password=config['password'],
                    database=config['database'],
                    connection_timeout=10
                )
                
                cursor = connection.cursor()
                
                # Test basic connectivity
                start_time = datetime.now()
                cursor.execute("SELECT 1")
                query_time = (datetime.now() - start_time).total_seconds()
                
                # Get connection count
                cursor.execute("SHOW STATUS LIKE 'Threads_connected'")
                connections = cursor.fetchone()[1]
                
                # Get database size
                cursor.execute(f"SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) AS 'DB Size in MB' FROM information_schema.tables WHERE table_schema='{config['database']}'")
                db_size = cursor.fetchone()[0]
                
                db_results[db_name] = {
                    'status': 'healthy',
                    'connection_time': query_time,
                    'active_connections': int(connections),
                    'database_size_mb': float(db_size) if db_size else 0,
                    'timestamp': datetime.now().isoformat()
                }
                
                cursor.close()
                connection.close()
                
            except Exception as e:
                db_results[db_name] = {
                    'status': 'error',
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                }
        
        return db_results
    
    def check_infrastructure_metrics(self, instance_ids):
        """Check infrastructure performance metrics"""
        metrics_results = {}
        
        for instance_id in instance_ids:
            try:
                # Get latest CloudWatch metrics
                end_time = datetime.now()
                start_time = datetime.now().replace(minute=end_time.minute-15)  # Last 15 minutes
                
                # CPU utilization
                cpu_response = self.cloudwatch.get_metric_statistics(
                    Namespace='AWS/EC2',
                    MetricName='CPUUtilization',
                    Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                    StartTime=start_time,
                    EndTime=end_time,
                    Period=300,
                    Statistics=['Average']
                )
                
                # Memory utilization (if CloudWatch agent is installed)
                memory_response = self.cloudwatch.get_metric_statistics(
                    Namespace='CWAgent',
                    MetricName='mem_used_percent',
                    Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                    StartTime=start_time,
                    EndTime=end_time,
                    Period=300,
                    Statistics=['Average']
                )
                
                cpu_avg = 0
                if cpu_response['Datapoints']:
                    cpu_avg = sum(dp['Average'] for dp in cpu_response['Datapoints']) / len(cpu_response['Datapoints'])
                
                memory_avg = 0
                if memory_response['Datapoints']:
                    memory_avg = sum(dp['Average'] for dp in memory_response['Datapoints']) / len(memory_response['Datapoints'])
                
                metrics_results[instance_id] = {
                    'status': 'healthy',
                    'cpu_utilization_avg': round(cpu_avg, 2),
                    'memory_utilization_avg': round(memory_avg, 2),
                    'cpu_datapoints': len(cpu_response['Datapoints']),
                    'memory_datapoints': len(memory_response['Datapoints']),
                    'timestamp': datetime.now().isoformat()
                }
                
            except Exception as e:
                metrics_results[instance_id] = {
                    'status': 'error',
                    'error': str(e),
                    'timestamp': datetime.now().isoformat()
                }
        
        return metrics_results
    
    def comprehensive_health_check(self, monitoring_config):
        """Perform comprehensive health check"""
        print("Starting comprehensive health check...")
        
        results = {
            'timestamp': datetime.now().isoformat(),
            'overall_status': 'unknown'
        }
        
        # Check applications
        if 'applications' in monitoring_config:
            print("Checking application health...")
            results['applications'] = self.check_application_health(monitoring_config['applications'])
        
        # Check databases
        if 'databases' in monitoring_config:
            print("Checking database health...")
            results['databases'] = self.check_database_health(monitoring_config['databases'])
        
        # Check infrastructure
        if 'instances' in monitoring_config:
            print("Checking infrastructure metrics...")
            results['infrastructure'] = self.check_infrastructure_metrics(monitoring_config['instances'])
        
        # Determine overall status
        all_statuses = []
        
        for category in ['applications', 'databases', 'infrastructure']:
            if category in results:
                for item_status in results[category].values():
                    all_statuses.append(item_status.get('status', 'unknown'))
        
        if all(status == 'healthy' for status in all_statuses):
            results['overall_status'] = 'healthy'
        elif any(status == 'error' for status in all_statuses):
            results['overall_status'] = 'critical'
        else:
            results['overall_status'] = 'degraded'
        
        # Save results
        filename = f"health_check_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w') as f:
            json.dump(results, f, indent=2)
        
        # Print summary
        print(f"\nHealth Check Summary:")
        print(f"Overall Status: {results['overall_status'].upper()}")
        
        for category in ['applications', 'databases', 'infrastructure']:
            if category in results:
                healthy_count = sum(1 for item in results[category].values() if item.get('status') == 'healthy')
                total_count = len(results[category])
                print(f"{category.title()}: {healthy_count}/{total_count} healthy")
        
        return results

# Example monitoring configuration
if __name__ == "__main__":
    monitoring_config = {
        'applications': {
            'web-app': {
                'health_endpoint': 'http://10.0.10.100/health',
                'timeout': 10
            },
            'api-service': {
                'health_endpoint': 'http://10.0.10.101:8080/health',
                'timeout': 10
            }
        },
        'databases': {
            'production-db': {
                'host': 'aurora-cluster.cluster-xyz.us-east-1.rds.amazonaws.com',
                'port': 3306,
                'username': 'admin',
                'password': 'secure_password',
                'database': 'production_db'
            }
        },
        'instances': [
            'i-1234567890abcdef0',
            'i-0987654321fedcba0'
        ]
    }
    
    monitor = PostMigrationMonitor()
    results = monitor.comprehensive_health_check(monitoring_config)
    
    if results['overall_status'] == 'critical':
        print("\n🚨 CRITICAL issues detected! Immediate attention required.")
    elif results['overall_status'] == 'degraded':
        print("\n⚠️ Some issues detected. Investigation recommended.")
    else:
        print("\n✅ All systems healthy!")
EOF
```

---

## Troubleshooting Guide

### Common Migration Issues

#### Issue: MGN Agent Installation Failures

**Symptoms:**
- Agent installation fails on source servers
- Replication not starting
- "Failed to communicate with MGN service" errors

**Diagnosis:**
```bash
# Check agent status on source server
sudo systemctl status aws-replication-agent

# Check agent logs
sudo tail -f /var/log/aws-replication-agent.log

# Verify network connectivity
curl -I https://mgn.us-east-1.amazonaws.com

# Check AWS credentials
aws sts get-caller-identity
```

**Solutions:**

1. **Network Connectivity Issues**
   ```bash
   # Verify outbound HTTPS access
   telnet mgn.us-east-1.amazonaws.com 443
   
   # Check firewall rules
   sudo iptables -L | grep 443
   sudo firewall-cmd --list-all
   
   # Open required ports
   sudo firewall-cmd --permanent --add-port=443/tcp
   sudo firewall-cmd --permanent --add-port=1500/tcp
   sudo firewall-cmd --reload
   ```

2. **Credential Issues**
   ```bash
   # Reconfigure agent with correct credentials
   sudo /opt/aws/mgn/bin/aws-replication-agent-config \
     --region us-east-1 \
     --access-key-id AKIA... \
     --secret-access-key secretkey...
   
   # Restart agent
   sudo systemctl restart aws-replication-agent
   ```

3. **Insufficient Permissions**
   ```bash
   # Verify IAM permissions
   aws iam simulate-principal-policy \
     --policy-source-arn arn:aws:iam::123456789012:user/mgn-user \
     --action-names mgn:* \
     --resource-arns "*"
   ```

#### Issue: High Replication Lag

**Symptoms:**
- Replication lag exceeding acceptable thresholds
- Slow initial sync progress
- Cutover delays due to synchronization time

**Diagnosis:**
```bash
# Check replication lag
aws mgn describe-source-servers \
  --query 'items[*].{ServerID:sourceServerID,Lag:dataReplicationInfo.lag.duration}' \
  --output table

# Check network performance
iperf3 -c target-host -t 60

# Monitor bandwidth usage
ifstat -i eth0 1
```

**Solutions:**

1. **Network Optimization**
   ```bash
   # Increase bandwidth throttling limit
   aws mgn update-replication-configuration \
     --source-server-id s-1234567890abcdef0 \
     --bandwidth-throttling 100
   
   # Use dedicated replication server
   aws mgn update-replication-configuration \
     --source-server-id s-1234567890abcdef0 \
     --use-dedicated-replication-server true \
     --replication-server-instance-type m5.large
   ```

2. **Source Server Optimization**
   ```bash
   # Reduce I/O load during replication
   ionice -c 3 -p $(pgrep aws-replication)
   
   # Schedule replication during low-usage hours
   # Pause replication during business hours
   aws mgn pause-replication --source-server-id s-1234567890abcdef0
   ```

3. **Target Infrastructure Scaling**
   ```bash
   # Use larger replication instance type
   aws mgn update-replication-configuration-template \
     --replication-configuration-template-id rct-1234567890abcdef0 \
     --replication-server-instance-type m5.xlarge
   ```

#### Issue: Database Migration Failures

**Symptoms:**
- DMS tasks failing with errors
- Schema conversion issues
- Data type incompatibilities

**Diagnosis:**
```bash
# Check DMS task status
aws dms describe-replication-tasks \
  --query 'ReplicationTasks[*].{TaskID:ReplicationTaskIdentifier,Status:Status,LastFailureMessage:LastFailureMessage}'

# Review DMS logs
aws logs filter-log-events \
  --log-group-name dms-tasks-replication-task-12345 \
  --start-time $(date -d '1 hour ago' +%s)000

# Test endpoint connectivity
aws dms test-connection \
  --replication-instance-arn arn:aws:dms:us-east-1:123456789012:rep:ABC123 \
  --endpoint-arn arn:aws:dms:us-east-1:123456789012:endpoint:DEF456
```

**Solutions:**

1. **Schema Conversion Issues**
   ```bash
   # Use AWS Schema Conversion Tool
   # Download and run SCT to identify conversion issues
   
   # Manual schema fixes
   mysql -h target-endpoint -u admin -p << EOF
   ALTER TABLE users MODIFY COLUMN user_id INT AUTO_INCREMENT;
   ALTER TABLE orders ADD INDEX idx_customer_id (customer_id);
   EOF
   ```

2. **Connectivity Issues**
   ```bash
   # Update security groups
   aws ec2 authorize-security-group-ingress \
     --group-id sg-12345678 \
     --protocol tcp \
     --port 3306 \
     --source-group sg-87654321
   
   # Test connectivity from DMS subnet
   telnet source-database.company.local 3306
   ```

3. **Performance Optimization**
   ```bash
   # Increase DMS instance size
   aws dms modify-replication-instance \
     --replication-instance-arn arn:aws:dms:us-east-1:123456789012:rep:ABC123 \
     --replication-instance-class dms.c5.xlarge \
     --apply-immediately
   
   # Optimize table mappings
   # Use parallel load for large tables
   ```

#### Issue: Application Connectivity Problems

**Symptoms:**
- Applications cannot connect to migrated databases
- Intermittent connection timeouts
- "Too many connections" errors

**Diagnosis:**
```bash
# Test database connectivity
mysql -h aurora-cluster.cluster-xyz.us-east-1.rds.amazonaws.com -u admin -p

# Check connection counts
mysql -h db-endpoint -u admin -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Review application logs
kubectl logs deployment/web-app | grep -i "connection\|error"

# Check DNS resolution
nslookup aurora-cluster.cluster-xyz.us-east-1.rds.amazonaws.com
```

**Solutions:**

1. **Connection Pool Configuration**
   ```bash
   # Update application connection pool settings
   # Example for Spring Boot application
   cat > application.properties << EOF
   spring.datasource.hikari.maximum-pool-size=20
   spring.datasource.hikari.minimum-idle=5
   spring.datasource.hikari.connection-timeout=30000
   spring.datasource.hikari.idle-timeout=600000
   spring.datasource.hikari.max-lifetime=1800000
   EOF
   ```

2. **Database Parameter Tuning**
   ```bash
   # Increase max_connections
   aws rds modify-db-cluster-parameter-group \
     --db-cluster-parameter-group-name aurora-mysql-params \
     --parameters ParameterName=max_connections,ParameterValue=1000,ApplyMethod=pending-reboot
   
   # Apply changes
   aws rds reboot-db-cluster --db-cluster-identifier aurora-cluster
   ```

3. **Network Security**
   ```bash
   # Verify security group rules
   aws ec2 describe-security-groups \
     --group-ids sg-database123 \
     --query 'SecurityGroups[0].IpPermissions'
   
   # Add application security group to database access
   aws ec2 authorize-security-group-ingress \
     --group-id sg-database123 \
     --protocol tcp \
     --port 3306 \
     --source-group sg-application456
   ```

### Performance Issues

#### Issue: Slow Application Response Times

**Diagnosis:**
```bash
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time $(date -d '1 hour ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 300 \
  --statistics Average,Maximum

# Check instance performance
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time $(date -d '1 hour ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 300 \
  --statistics Average,Maximum
```

**Solutions:**

1. **Instance Right-Sizing**
   ```bash
   # Scale up instance type
   aws ec2 stop-instances --instance-ids i-1234567890abcdef0
   aws ec2 wait instance-stopped --instance-ids i-1234567890abcdef0
   aws ec2 modify-instance-attribute \
     --instance-id i-1234567890abcdef0 \
     --instance-type Value=m5.xlarge
   aws ec2 start-instances --instance-ids i-1234567890abcdef0
   ```

2. **Auto Scaling Adjustment**
   ```bash
   # Increase Auto Scaling Group capacity
   aws autoscaling set-desired-capacity \
     --auto-scaling-group-name web-app-asg \
     --desired-capacity 4
   
   # Lower scaling thresholds
   aws cloudwatch put-metric-alarm \
     --alarm-name cpu-scale-up \
     --alarm-description "Scale up on high CPU" \
     --metric-name CPUUtilization \
     --namespace AWS/EC2 \
     --statistic Average \
     --period 300 \
     --threshold 60 \
     --comparison-operator GreaterThanThreshold
   ```

3. **Database Performance Tuning**
   ```sql
   -- Optimize slow queries
   SHOW FULL PROCESSLIST;
   EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';
   
   -- Add missing indexes
   CREATE INDEX idx_users_email ON users(email);
   CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
   
   -- Update table statistics
   ANALYZE TABLE users, orders, products;
   ```

---

## Operational Procedures

### Daily Operations Checklist

#### Morning Operations (8:00 AM)
```bash
# Daily operations checklist
cat > daily_operations.sh << 'EOF'
#!/bin/bash

echo "=== Daily Operations Checklist - $(date) ==="

# 1. Check overall system health
echo "1. Checking system health..."
aws cloudwatch describe-alarms --state-value ALARM --query 'length(MetricAlarms)'

# 2. Review migration progress
echo "2. Reviewing migration progress..."
./monitor_replication_status.py

# 3. Check backup completion
echo "3. Checking backup completion..."
aws rds describe-db-snapshots \
  --snapshot-type automated \
  --query 'DBSnapshots[?SnapshotCreateTime>=`2025-01-15`].{Snapshot:DBSnapshotIdentifier,Status:Status,Date:SnapshotCreateTime}' \
  --output table

# 4. Monitor costs
echo "4. Monitoring costs..."
aws ce get-cost-and-usage \
  --time-period Start=2025-01-14,End=2025-01-15 \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# 5. Check security alerts
echo "5. Checking security alerts..."
aws guardduty get-findings \
  --detector-id $(aws guardduty list-detectors --query 'DetectorIds[0]' --output text) \
  --finding-criteria '{"severity":{"gte":7.0}}' \
  --query 'length(FindingIds)'

echo "Daily operations check completed at $(date)"
EOF

chmod +x daily_operations.sh
```

#### Evening Operations (6:00 PM)
```bash
# Evening operations checklist
cat > evening_operations.sh << 'EOF'
#!/bin/bash

echo "=== Evening Operations Summary - $(date) ==="

# 1. Generate daily migration report
echo "1. Generating daily migration report..."
python3 monitor_replication_status.py > daily_migration_report.txt

# 2. Backup verification
echo "2. Verifying backup completion..."
aws rds describe-db-snapshots \
  --snapshot-type automated \
  --query 'DBSnapshots[?SnapshotCreateTime>=`$(date -Iseconds -d "1 day ago")`].{Status:Status}' \
  --output table

# 3. Performance summary
echo "3. Performance summary..."
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name RequestCount \
  --start-time $(date -d '24 hours ago' -Iseconds) \
  --end-time $(date -Iseconds) \
  --period 86400 \
  --statistics Sum \
  --query 'Datapoints[0].Sum'

# 4. Update team dashboard
echo "4. Updating team dashboard..."
# Generate dashboard data and update shared location

echo "Evening operations completed at $(date)"
EOF

chmod +x evening_operations.sh
```

### Weekly Maintenance Tasks

#### Weekly Performance Review
```python
# Weekly performance analysis
cat > weekly_performance_review.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
from datetime import datetime, timedelta

class WeeklyPerformanceReview:
    def __init__(self, region='us-east-1'):
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
        self.rds = boto3.client('rds', region_name=region)
        
    def analyze_application_performance(self):
        """Analyze application performance over the past week"""
        end_time = datetime.now()
        start_time = end_time - timedelta(days=7)
        
        # Get ALB metrics
        alb_metrics = self.cloudwatch.get_metric_statistics(
            Namespace='AWS/ApplicationELB',
            MetricName='TargetResponseTime',
            StartTime=start_time,
            EndTime=end_time,
            Period=3600,  # 1 hour periods
            Statistics=['Average', 'Maximum']
        )
        
        # Calculate performance statistics
        if alb_metrics['Datapoints']:
            avg_response_times = [dp['Average'] for dp in alb_metrics['Datapoints']]
            max_response_times = [dp['Maximum'] for dp in alb_metrics['Datapoints']]
            
            performance_summary = {
                'avg_response_time': sum(avg_response_times) / len(avg_response_times),
                'peak_response_time': max(max_response_times),
                'response_time_trend': 'improving' if avg_response_times[-1] < avg_response_times[0] else 'degrading',
                'total_datapoints': len(avg_response_times)
            }
        else:
            performance_summary = {'status': 'no_data'}
        
        return performance_summary
    
    def analyze_infrastructure_utilization(self):
        """Analyze infrastructure utilization"""
        end_time = datetime.now()
        start_time = end_time - timedelta(days=7)
        
        # Get list of instances
        instances = self.ec2.describe_instances(
            Filters=[
                {'Name': 'tag:Project', 'Values': ['cloud-migration']},
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )
        
        utilization_summary = {}
        
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                
                # Get CPU utilization
                cpu_metrics = self.cloudwatch.get_metric_statistics(
                    Namespace='AWS/EC2',
                    MetricName='CPUUtilization',
                    Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                    StartTime=start_time,
                    EndTime=end_time,
                    Period=3600,
                    Statistics=['Average', 'Maximum']
                )
                
                if cpu_metrics['Datapoints']:
                    avg_cpu = sum(dp['Average'] for dp in cpu_metrics['Datapoints']) / len(cpu_metrics['Datapoints'])
                    max_cpu = max(dp['Maximum'] for dp in cpu_metrics['Datapoints'])
                    
                    utilization_summary[instance_id] = {
                        'instance_type': instance['InstanceType'],
                        'avg_cpu_utilization': round(avg_cpu, 2),
                        'peak_cpu_utilization': round(max_cpu, 2),
                        'utilization_category': self._categorize_utilization(avg_cpu)
                    }
        
        return utilization_summary
    
    def _categorize_utilization(self, avg_cpu):
        """Categorize CPU utilization"""
        if avg_cpu < 20:
            return 'underutilized'
        elif avg_cpu < 60:
            return 'optimal'
        elif avg_cpu < 80:
            return 'high'
        else:
            return 'critical'
    
    def analyze_database_performance(self):
        """Analyze database performance"""
        end_time = datetime.now()
        start_time = end_time - timedelta(days=7)
        
        # Get RDS instances
        db_instances = self.rds.describe_db_instances()['DBInstances']
        
        db_performance = {}
        
        for db in db_instances:
            db_id = db['DBInstanceIdentifier']
            
            # Get database connection metrics
            conn_metrics = self.cloudwatch.get_metric_statistics(
                Namespace='AWS/RDS',
                MetricName='DatabaseConnections',
                Dimensions=[{'Name': 'DBInstanceIdentifier', 'Value': db_id}],
                StartTime=start_time,
                EndTime=end_time,
                Period=3600,
                Statistics=['Average', 'Maximum']
            )
            
            # Get CPU metrics
            cpu_metrics = self.cloudwatch.get_metric_statistics(
                Namespace='AWS/RDS',
                MetricName='CPUUtilization',
                Dimensions=[{'Name': 'DBInstanceIdentifier', 'Value': db_id}],
                StartTime=start_time,
                EndTime=end_time,
                Period=3600,
                Statistics=['Average', 'Maximum']
            )
            
            db_perf = {'db_instance_id': db_id, 'engine': db['Engine']}
            
            if conn_metrics['Datapoints']:
                avg_connections = sum(dp['Average'] for dp in conn_metrics['Datapoints']) / len(conn_metrics['Datapoints'])
                max_connections = max(dp['Maximum'] for dp in conn_metrics['Datapoints'])
                db_perf.update({
                    'avg_connections': round(avg_connections, 0),
                    'peak_connections': round(max_connections, 0)
                })
            
            if cpu_metrics['Datapoints']:
                avg_cpu = sum(dp['Average'] for dp in cpu_metrics['Datapoints']) / len(cpu_metrics['Datapoints'])
                max_cpu = max(dp['Maximum'] for dp in cpu_metrics['Datapoints'])
                db_perf.update({
                    'avg_cpu_utilization': round(avg_cpu, 2),
                    'peak_cpu_utilization': round(max_cpu, 2)
                })
            
            db_performance[db_id] = db_perf
        
        return db_performance
    
    def generate_weekly_report(self):
        """Generate comprehensive weekly performance report"""
        print("Generating weekly performance report...")
        
        report = {
            'report_date': datetime.now().isoformat(),
            'report_period': '7 days',
            'application_performance': self.analyze_application_performance(),
            'infrastructure_utilization': self.analyze_infrastructure_utilization(),
            'database_performance': self.analyze_database_performance()
        }
        
        # Generate recommendations
        recommendations = []
        
        # Infrastructure recommendations
        for instance_id, metrics in report['infrastructure_utilization'].items():
            if metrics['utilization_category'] == 'underutilized':
                recommendations.append(f"Consider downsizing {instance_id} ({metrics['instance_type']}) - avg CPU: {metrics['avg_cpu_utilization']}%")
            elif metrics['utilization_category'] == 'critical':
                recommendations.append(f"Consider upsizing {instance_id} ({metrics['instance_type']}) - avg CPU: {metrics['avg_cpu_utilization']}%")
        
        # Application performance recommendations
        app_perf = report['application_performance']
        if app_perf.get('avg_response_time', 0) > 2.0:
            recommendations.append("Application response time exceeds 2 seconds - investigate performance bottlenecks")
        
        if app_perf.get('response_time_trend') == 'degrading':
            recommendations.append("Response time trend is degrading - monitor for performance issues")
        
        # Database recommendations
        for db_id, metrics in report['database_performance'].items():
            if metrics.get('avg_cpu_utilization', 0) > 80:
                recommendations.append(f"Database {db_id} has high CPU utilization - consider optimization")
            if metrics.get('peak_connections', 0) > 80:
                recommendations.append(f"Database {db_id} has high connection usage - monitor connection pool settings")
        
        report['recommendations'] = recommendations
        
        # Save report
        filename = f"weekly_performance_report_{datetime.now().strftime('%Y%m%d')}.json"
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Print summary
        print(f"\nWeekly Performance Report Summary:")
        print(f"Application avg response time: {app_perf.get('avg_response_time', 'N/A'):.2f}s" if app_perf.get('avg_response_time') else "Application metrics: No data")
        print(f"Infrastructure instances analyzed: {len(report['infrastructure_utilization'])}")
        print(f"Database instances analyzed: {len(report['database_performance'])}")
        print(f"Recommendations generated: {len(recommendations)}")
        
        if recommendations:
            print("\nTop Recommendations:")
            for i, rec in enumerate(recommendations[:3], 1):
                print(f"{i}. {rec}")
        
        return report

if __name__ == "__main__":
    reviewer = WeeklyPerformanceReview()
    report = reviewer.generate_weekly_report()
    print(f"\nWeekly report saved as: weekly_performance_report_{datetime.now().strftime('%Y%m%d')}.json")
EOF

python3 weekly_performance_review.py
```

### Emergency Response Procedures

#### Critical System Outage Response

```bash
# Emergency response playbook
cat > emergency_response.sh << 'EOF'
#!/bin/bash

INCIDENT_ID=${1:-"INC-$(date +%Y%m%d-%H%M%S)"}
SEVERITY=${2:-"HIGH"}

echo "=== EMERGENCY RESPONSE ACTIVATED ==="
echo "Incident ID: $INCIDENT_ID"
echo "Severity: $SEVERITY"
echo "Time: $(date)"

# Step 1: Immediate Assessment
echo "STEP 1: Immediate Assessment"
echo "Checking AWS Service Health..."
curl -s https://status.aws.amazon.com/ | grep -i "Service is operating normally" || echo "⚠️ AWS service issues detected"

echo "Checking critical alarms..."
ALARM_COUNT=$(aws cloudwatch describe-alarms --state-value ALARM --query 'length(MetricAlarms)')
echo "Active alarms: $ALARM_COUNT"

if [ "$ALARM_COUNT" -gt 0 ]; then
    aws cloudwatch describe-alarms --state-value ALARM --query 'MetricAlarms[*].{Name:AlarmName,Reason:StateReason}' --output table
fi

# Step 2: Stakeholder Notification
echo "STEP 2: Stakeholder Notification"
NOTIFICATION_TOPIC="arn:aws:sns:us-east-1:123456789012:emergency-alerts"

aws sns publish \
    --topic-arn $NOTIFICATION_TOPIC \
    --subject "🚨 CRITICAL: System Outage - $INCIDENT_ID" \
    --message "Critical system outage detected at $(date). Incident ID: $INCIDENT_ID. Response team activated."

# Step 3: System Status Check
echo "STEP 3: System Status Check"
echo "Checking EC2 instances..."
aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=cloud-migration" "Name=instance-state-name,Values=running,stopped,stopping" \
    --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name,Type:InstanceType}' \
    --output table

echo "Checking RDS instances..."
aws rds describe-db-instances \
    --query 'DBInstances[*].{ID:DBInstanceIdentifier,Status:DBInstanceStatus,Engine:Engine}' \
    --output table

echo "Checking load balancers..."
aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[*].{Name:LoadBalancerName,State:State.Code,Scheme:Scheme}' \
    --output table

# Step 4: Create incident log
echo "STEP 4: Creating incident log"
cat > incident_${INCIDENT_ID}.log << INCIDENT_EOF
Incident ID: $INCIDENT_ID
Start Time: $(date)
Severity: $SEVERITY
Initial Response Team: $(whoami)

Timeline:
$(date): Incident detected and emergency response activated
$(date): Initial assessment completed
$(date): Stakeholders notified

Status Checks:
- AWS Service Health: $(curl -s https://status.aws.amazon.com/ | grep -c "Service is operating normally" || echo "Issues detected")
- Active CloudWatch Alarms: $ALARM_COUNT
- EC2 Instance Status: $(aws ec2 describe-instances --filters "Name=tag:Project,Values=cloud-migration" "Name=instance-state-name,Values=running" --query 'length(Reservations[*].Instances[*])')

Next Steps:
1. Detailed root cause analysis
2. Implement immediate fixes
3. Monitor system recovery
4. Update stakeholders
INCIDENT_EOF

echo "Incident log created: incident_${INCIDENT_ID}.log"

# Step 5: Immediate Actions
echo "STEP 5: Immediate Recovery Actions"
if [ "$SEVERITY" = "CRITICAL" ]; then
    echo "Executing critical recovery procedures..."
    
    # Restart failed instances
    FAILED_INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=cloud-migration" "Name=instance-state-name,Values=stopped" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text)
    
    if [ ! -z "$FAILED_INSTANCES" ]; then
        echo "Restarting failed instances: $FAILED_INSTANCES"
        aws ec2 start-instances --instance-ids $FAILED_INSTANCES
    fi
    
    # Check Auto Scaling Groups
    aws autoscaling describe-auto-scaling-groups \
        --query 'AutoScalingGroups[*].{Name:AutoScalingGroupName,Desired:DesiredCapacity,Current:Instances[?HealthStatus==`Healthy`]|length(@)}' \
        --output table
fi

echo "Emergency response procedures completed."
echo "Continue monitoring and update incident log with progress."
EOF

chmod +x emergency_response.sh
```

---

## Security Operations

### Security Monitoring

#### Daily Security Checks
```bash
# Daily security monitoring
cat > daily_security_check.sh << 'EOF'
#!/bin/bash

echo "=== Daily Security Check - $(date) ==="

# Check GuardDuty findings
echo "1. Checking GuardDuty findings..."
DETECTOR_ID=$(aws guardduty list-detectors --query 'DetectorIds[0]' --output text)

if [ "$DETECTOR_ID" != "None" ]; then
    HIGH_FINDINGS=$(aws guardduty get-findings \
        --detector-id $DETECTOR_ID \
        --finding-criteria '{"severity":{"gte":7.0}}' \
        --query 'length(FindingIds)')
    
    echo "High severity findings: $HIGH_FINDINGS"
    
    if [ "$HIGH_FINDINGS" -gt 0 ]; then
        aws guardduty get-findings \
            --detector-id $DETECTOR_ID \
            --finding-criteria '{"severity":{"gte":7.0}}' \
            --query 'FindingIds' \
            --output text | head -5
    fi
fi

# Check Security Hub findings
echo "2. Checking Security Hub compliance..."
CRITICAL_FINDINGS=$(aws securityhub get-findings \
    --filters '{"SeverityLabel":[{"Value":"CRITICAL","Comparison":"EQUALS"}]}' \
    --query 'length(Findings)')

echo "Critical Security Hub findings: $CRITICAL_FINDINGS"

# Check CloudTrail for suspicious activity
echo "3. Checking CloudTrail for root account usage..."
ROOT_ACTIVITY=$(aws logs filter-log-events \
    --log-group-name CloudTrail/cloud-migration \
    --start-time $(($(date +%s) - 86400))000 \
    --filter-pattern '{ $.userIdentity.type = "Root" }' \
    --query 'length(events)')

echo "Root account activities in last 24h: $ROOT_ACTIVITY"

# Check failed login attempts
echo "4. Checking failed login attempts..."
FAILED_LOGINS=$(aws logs filter-log-events \
    --log-group-name CloudTrail/cloud-migration \
    --start-time $(($(date +%s) - 86400))000 \
    --filter-pattern '{ $.errorCode = "*Failure*" || $.errorCode = "*Failed*" }' \
    --query 'length(events)')

echo "Failed login attempts in last 24h: $FAILED_LOGINS"

# Check security group changes
echo "5. Checking security group changes..."
SG_CHANGES=$(aws logs filter-log-events \
    --log-group-name CloudTrail/cloud-migration \
    --start-time $(($(date +%s) - 86400))000 \
    --filter-pattern '{ $.eventName = "AuthorizeSecurityGroupIngress" || $.eventName = "RevokeSecurityGroupIngress" }' \
    --query 'length(events)')

echo "Security group changes in last 24h: $SG_CHANGES"

echo "Daily security check completed at $(date)"
EOF

chmod +x daily_security_check.sh
./daily_security_check.sh
```

#### Security Incident Response

```bash
# Security incident response playbook
cat > security_incident_response.sh << 'EOF'
#!/bin/bash

INCIDENT_ID=${1:-"SEC-$(date +%Y%m%d-%H%M%S)"}
INCIDENT_TYPE=${2:-"UNKNOWN"}

echo "=== SECURITY INCIDENT RESPONSE ==="
echo "Security Incident ID: $INCIDENT_ID"
echo "Incident Type: $INCIDENT_TYPE"
echo "Response Time: $(date)"

# Step 1: Immediate Containment
echo "STEP 1: Immediate Containment"

# Create isolation security group
ISOLATION_SG=$(aws ec2 create-security-group \
    --group-name isolation-sg-$INCIDENT_ID \
    --description "Isolation security group for incident $INCIDENT_ID" \
    --vpc-id $(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=cloud-migration" --query 'Vpcs[0].VpcId' --output text) \
    --query 'GroupId' \
    --output text)

echo "Created isolation security group: $ISOLATION_SG"

# Function to isolate instance
isolate_instance() {
    local INSTANCE_ID=$1
    echo "Isolating instance: $INSTANCE_ID"
    
    # Modify instance security groups
    aws ec2 modify-instance-attribute \
        --instance-id $INSTANCE_ID \
        --groups $ISOLATION_SG
    
    # Create snapshot for forensics
    VOLUMES=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].BlockDeviceMappings[*].Ebs.VolumeId' \
        --output text)
    
    for VOLUME in $VOLUMES; do
        aws ec2 create-snapshot \
            --volume-id $VOLUME \
            --description "Forensic snapshot for incident $INCIDENT_ID"
    done
}

# Step 2: Investigation
echo "STEP 2: Investigation"

# Collect CloudTrail logs
echo "Collecting CloudTrail logs..."
aws logs create-export-task \
    --log-group-name CloudTrail/cloud-migration \
    --from $(($(date +%s) - 86400))000 \
    --to $(date +%s)000 \
    --destination s3://security-forensics-$INCIDENT_ID

# Collect VPC Flow Logs
echo "Collecting VPC Flow Logs..."
aws logs create-export-task \
    --log-group-name /aws/vpc/flowlogs \
    --from $(($(date +%s) - 86400))000 \
    --to $(date +%s)000 \
    --destination s3://security-forensics-$INCIDENT_ID

# Step 3: Communication
echo "STEP 3: Stakeholder Communication"
aws sns publish \
    --topic-arn arn:aws:sns:us-east-1:123456789012:security-alerts \
    --subject "🔒 SECURITY INCIDENT: $INCIDENT_ID" \
    --message "Security incident $INCIDENT_ID ($INCIDENT_TYPE) detected at $(date). Containment measures activated. Investigation in progress."

# Step 4: Create incident report
cat > security_incident_${INCIDENT_ID}.log << SEC_INCIDENT_EOF
Security Incident Report
========================
Incident ID: $INCIDENT_ID
Incident Type: $INCIDENT_TYPE
Detection Time: $(date)
Response Team: $(whoami)

Immediate Actions Taken:
- Created isolation security group: $ISOLATION_SG
- Initiated log collection and export
- Notified security team via SNS

Investigation Status: IN PROGRESS

Timeline:
$(date): Incident detected
$(date): Containment measures initiated
$(date): Log collection started
$(date): Security team notified

Next Steps:
1. Complete forensic analysis
2. Identify root cause
3. Implement remediation
4. Update security controls
5. Conduct lessons learned session
SEC_INCIDENT_EOF

echo "Security incident response initiated."
echo "Incident report: security_incident_${INCIDENT_ID}.log"
echo "Isolation SG: $ISOLATION_SG"
echo "Continue investigation and update incident log."
EOF

chmod +x security_incident_response.sh
```

---

## Maintenance and Optimization

### Regular Maintenance Tasks

#### Monthly Optimization Review
```python
# Monthly optimization review
cat > monthly_optimization.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
from datetime import datetime, timedelta

class MonthlyOptimization:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.ce = boto3.client('ce', region_name=region)
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)
        
    def analyze_cost_trends(self):
        """Analyze cost trends over the past month"""
        end_date = datetime.now().strftime('%Y-%m-%d')
        start_date = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
        
        try:
            response = self.ce.get_cost_and_usage(
                TimePeriod={'Start': start_date, 'End': end_date},
                Granularity='DAILY',
                Metrics=['BlendedCost'],
                GroupBy=[
                    {'Type': 'DIMENSION', 'Key': 'SERVICE'}
                ]
            )
            
            service_costs = {}
            for result in response['ResultsByTime']:
                for group in result['Groups']:
                    service = group['Keys'][0]
                    cost = float(group['Metrics']['BlendedCost']['Amount'])
                    if service in service_costs:
                        service_costs[service] += cost
                    else:
                        service_costs[service] = cost
            
            # Sort by cost
            sorted_costs = sorted(service_costs.items(), key=lambda x: x[1], reverse=True)
            
            return {
                'analysis_period': f"{start_date} to {end_date}",
                'total_cost': sum(service_costs.values()),
                'top_services': sorted_costs[:10],
                'cost_breakdown': service_costs
            }
            
        except Exception as e:
            return {'error': str(e)}
    
    def identify_unused_resources(self):
        """Identify unused or underutilized resources"""
        unused_resources = {
            'stopped_instances': [],
            'unused_volumes': [],
            'unused_snapshots': [],
            'unused_security_groups': []
        }
        
        # Find stopped instances
        stopped_instances = self.ec2.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}]
        )
        
        for reservation in stopped_instances['Reservations']:
            for instance in reservation['Instances']:
                stopped_time = instance.get('StateTransitionReason', '')
                unused_resources['stopped_instances'].append({
                    'instance_id': instance['InstanceId'],
                    'instance_type': instance['InstanceType'],
                    'stopped_time': stopped_time,
                    'tags': instance.get('Tags', [])
                })
        
        # Find unused EBS volumes
        volumes = self.ec2.describe_volumes(
            Filters=[{'Name': 'status', 'Values': ['available']}]
        )
        
        for volume in volumes['Volumes']:
            unused_resources['unused_volumes'].append({
                'volume_id': volume['VolumeId'],
                'size': volume['Size'],
                'volume_type': volume['VolumeType'],
                'created_time': volume['CreateTime'].isoformat(),
                'tags': volume.get('Tags', [])
            })
        
        # Find old snapshots (older than 30 days)
        snapshots = self.ec2.describe_snapshots(OwnerIds=['self'])
        cutoff_date = datetime.now() - timedelta(days=30)
        
        for snapshot in snapshots['Snapshots']:
            if snapshot['StartTime'].replace(tzinfo=None) < cutoff_date:
                unused_resources['unused_snapshots'].append({
                    'snapshot_id': snapshot['SnapshotId'],
                    'volume_size': snapshot['VolumeSize'],
                    'start_time': snapshot['StartTime'].isoformat(),
                    'description': snapshot['Description'],
                    'tags': snapshot.get('Tags', [])
                })
        
        return unused_resources
    
    def recommend_optimizations(self):
        """Generate optimization recommendations"""
        cost_analysis = self.analyze_cost_trends()
        unused_resources = self.identify_unused_resources()
        
        recommendations = []
        
        # Cost-based recommendations
        if cost_analysis.get('top_services'):
            top_service = cost_analysis['top_services'][0]
            recommendations.append({
                'category': 'cost_optimization',
                'priority': 'high',
                'recommendation': f"Review {top_service[0]} usage - highest cost service (${top_service[1]:.2f})",
                'potential_savings': f"Review for optimization opportunities"
            })
        
        # Resource cleanup recommendations
        if unused_resources['stopped_instances']:
            count = len(unused_resources['stopped_instances'])
            recommendations.append({
                'category': 'resource_cleanup',
                'priority': 'medium',
                'recommendation': f"Terminate or restart {count} stopped instances",
                'potential_savings': f"Eliminate costs for {count} stopped instances"
            })
        
        if unused_resources['unused_volumes']:
            count = len(unused_resources['unused_volumes'])
            total_size = sum(vol['size'] for vol in unused_resources['unused_volumes'])
            recommendations.append({
                'category': 'resource_cleanup',
                'priority': 'medium',
                'recommendation': f"Delete {count} unused EBS volumes ({total_size} GB total)",
                'potential_savings': f"~${total_size * 0.10:.2f}/month"
            })
        
        if unused_resources['unused_snapshots']:
            count = len(unused_resources['unused_snapshots'])
            total_size = sum(snap['volume_size'] for snap in unused_resources['unused_snapshots'])
            recommendations.append({
                'category': 'resource_cleanup',
                'priority': 'low',
                'recommendation': f"Delete {count} old snapshots ({total_size} GB total)",
                'potential_savings': f"~${total_size * 0.05:.2f}/month"
            })
        
        return recommendations
    
    def generate_optimization_report(self):
        """Generate comprehensive monthly optimization report"""
        print("Generating monthly optimization report...")
        
        report = {
            'report_date': datetime.now().isoformat(),
            'report_type': 'monthly_optimization',
            'cost_analysis': self.analyze_cost_trends(),
            'unused_resources': self.identify_unused_resources(),
            'recommendations': self.recommend_optimizations()
        }
        
        # Calculate potential savings
        total_potential_savings = 0
        for rec in report['recommendations']:
            if 'potential_savings' in rec and '$' in rec['potential_savings']:
                try:
                    # Extract numeric value from savings string
                    savings_str = rec['potential_savings'].split('$')[1].split('/')[0]
                    total_potential_savings += float(savings_str)
                except:
                    pass
        
        report['summary'] = {
            'total_recommendations': len(report['recommendations']),
            'high_priority_recommendations': sum(1 for r in report['recommendations'] if r['priority'] == 'high'),
            'potential_monthly_savings': f"${total_potential_savings:.2f}",
            'unused_resources_count': {
                'stopped_instances': len(report['unused_resources']['stopped_instances']),
                'unused_volumes': len(report['unused_resources']['unused_volumes']),
                'old_snapshots': len(report['unused_resources']['unused_snapshots'])
            }
        }
        
        # Save report
        filename = f"monthly_optimization_report_{datetime.now().strftime('%Y%m')}.json"
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        
        # Print summary
        print(f"\nMonthly Optimization Report Summary:")
        print(f"Total Cost (30 days): ${report['cost_analysis'].get('total_cost', 0):.2f}")
        print(f"Recommendations: {report['summary']['total_recommendations']}")
        print(f"High Priority: {report['summary']['high_priority_recommendations']}")
        print(f"Potential Savings: {report['summary']['potential_monthly_savings']}")
        
        print(f"\nResource Cleanup Opportunities:")
        print(f"- Stopped instances: {report['summary']['unused_resources_count']['stopped_instances']}")
        print(f"- Unused volumes: {report['summary']['unused_resources_count']['unused_volumes']}")
        print(f"- Old snapshots: {report['summary']['unused_resources_count']['old_snapshots']}")
        
        print(f"\nTop Recommendations:")
        for i, rec in enumerate(report['recommendations'][:3], 1):
            print(f"{i}. [{rec['priority'].upper()}] {rec['recommendation']}")
        
        return report

if __name__ == "__main__":
    optimizer = MonthlyOptimization()
    report = optimizer.generate_optimization_report()
    print(f"\nOptimization report saved as: monthly_optimization_report_{datetime.now().strftime('%Y%m')}.json")
EOF

python3 monthly_optimization.py
```

---

## Support and Documentation

### Knowledge Base Maintenance

#### Update Documentation
```bash
# Documentation update script
cat > update_documentation.sh << 'EOF'
#!/bin/bash

DOC_DATE=$(date +%Y-%m-%d)

echo "=== Documentation Update - $DOC_DATE ==="

# Create documentation backup
mkdir -p doc_backups/$DOC_DATE
cp -r migration_docs/ doc_backups/$DOC_DATE/

# Update operational procedures
echo "Updating operational procedures..."
cat > migration_docs/operational_procedures_updated.md << DOC_EOF
# Operational Procedures - Updated $DOC_DATE

## Recent Changes
- $(date): Updated monitoring procedures
- $(date): Added new troubleshooting scenarios
- $(date): Enhanced security procedures

## Daily Operations
[Current daily operations content]

## Troubleshooting Updates
[New troubleshooting scenarios]

## Security Updates
[Latest security procedures]
DOC_EOF

# Update contact information
echo "Updating contact information..."
cat > migration_docs/contact_information.md << CONTACT_EOF
# Contact Information - Updated $DOC_DATE

## Primary Contacts
- Operations Team Lead: ops-lead@company.com
- Migration Team Lead: migration-lead@company.com  
- Security Team: security@company.com
- AWS Support: [Case Portal Link]

## Emergency Contacts
- 24/7 Operations: +1-555-0123
- Security Hotline: +1-555-0456
- Management Escalation: +1-555-0789

## Team Responsibilities
- Monitoring: Operations Team
- Incident Response: Operations + Security
- Migration Execution: Migration Team
- Security Issues: Security Team
CONTACT_EOF

echo "Documentation updated successfully."
echo "Backup created in: doc_backups/$DOC_DATE/"
EOF

chmod +x update_documentation.sh
./update_documentation.sh
```

### Training and Knowledge Transfer

#### New Team Member Onboarding
```bash
# Onboarding checklist for new team members
cat > onboarding_checklist.md << 'EOF'
# New Team Member Onboarding Checklist

## Pre-Arrival Setup
- [ ] AWS account access provisioned
- [ ] IAM permissions configured
- [ ] VPN access setup
- [ ] Documentation access granted
- [ ] Training materials prepared

## Week 1: Orientation
- [ ] AWS fundamentals training
- [ ] Migration overview presentation
- [ ] Tool introductions (MGN, DMS, SMS)
- [ ] Architecture review
- [ ] Shadow experienced team member

## Week 2: Hands-On Training
- [ ] Practice migration in test environment
- [ ] Monitoring and alerting training
- [ ] Troubleshooting exercises
- [ ] Security procedures review
- [ ] Emergency response training

## Week 3: Supervised Practice
- [ ] Participate in real migration wave
- [ ] Lead monitoring activities
- [ ] Handle support tickets
- [ ] Documentation updates
- [ ] Process improvement suggestions

## Week 4: Independent Work
- [ ] Lead migration activities
- [ ] Mentor newer team members
- [ ] Contribute to runbook updates
- [ ] Participate in optimization reviews
- [ ] Emergency response readiness

## Ongoing Development
- [ ] AWS certification path
- [ ] Advanced troubleshooting skills
- [ ] Automation development
- [ ] Process improvement initiatives
- [ ] Knowledge sharing sessions
EOF
```

---

## Conclusion

This operations runbook provides comprehensive procedures for managing AWS cloud migration projects and post-migration operations. Key areas covered include:

### Daily Operations
- Migration monitoring and health checks
- Performance analysis and optimization
- Security monitoring and compliance
- Backup verification and maintenance

### Emergency Procedures
- Incident response and escalation
- System outage recovery
- Security incident handling
- Communication protocols

### Maintenance Activities
- Regular optimization reviews
- Cost analysis and recommendations
- Security assessments and updates
- Documentation maintenance

### Support Structure
- Knowledge transfer procedures
- Training and onboarding programs
- Contact information and escalation paths
- Continuous improvement processes

This runbook should be regularly updated based on operational experience, new AWS services, and evolving business requirements.

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: Operations Team
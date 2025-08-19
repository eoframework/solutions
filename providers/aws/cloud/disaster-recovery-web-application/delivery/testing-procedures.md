# Testing Procedures - AWS Disaster Recovery

## Overview

This document outlines comprehensive testing procedures for AWS disaster recovery solutions to ensure reliability, performance, and business continuity readiness.

---

## Pre-Implementation Testing

### 1. Network Connectivity Testing
```bash
# Test VPN connectivity
ping -c 10 10.0.0.1  # On-premise gateway
traceroute vpc-endpoint.us-west-2.amazonaws.com

# Test Direct Connect
aws ec2 describe-vpn-connections --region us-east-1
aws directconnect describe-connections --region us-east-1

# Bandwidth testing
iperf3 -c remote-endpoint -t 60 -b 100M
```

### 2. DNS Resolution Testing
```bash
# Test Route 53 health checks
aws route53 get-health-check --health-check-id Z1234567890ABC
dig app.example.com
nslookup app.example.com @8.8.8.8

# Test failover DNS behavior
dig +short app.example.com
# Should return primary IP initially
```

---

## Database Replication Testing

### 3. RDS Read Replica Validation
```sql
-- On primary database
CREATE TABLE test_replication (
    id INT AUTO_INCREMENT PRIMARY KEY,
    test_data VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO test_replication (test_data) 
VALUES ('Test data for replication validation');

-- Check replication lag
SHOW SLAVE STATUS\G
```

```bash
# Monitor replication lag via CloudWatch
aws cloudwatch get-metric-statistics \
  --region us-west-2 \
  --namespace AWS/RDS \
  --metric-name ReplicaLag \
  --dimensions Name=DBInstanceIdentifier,Value=dr-webapp-replica \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### 4. Data Consistency Validation
```python
import mysql.connector
import hashlib
import time

def validate_data_consistency():
    # Connect to primary
    primary_conn = mysql.connector.connect(
        host='primary-db.cluster-xyz.us-east-1.rds.amazonaws.com',
        user='admin',
        password='password',
        database='webapp'
    )
    
    # Connect to replica
    replica_conn = mysql.connector.connect(
        host='replica-db.cluster-abc.us-west-2.rds.amazonaws.com',
        user='admin',
        password='password',
        database='webapp'
    )
    
    # Compare table checksums
    tables = ['users', 'orders', 'products']
    
    for table in tables:
        primary_cursor = primary_conn.cursor()
        replica_cursor = replica_conn.cursor()
        
        # Get row count and checksum
        primary_cursor.execute(f"SELECT COUNT(*), CHECKSUM TABLE {table}")
        replica_cursor.execute(f"SELECT COUNT(*), CHECKSUM TABLE {table}")
        
        primary_result = primary_cursor.fetchone()
        replica_result = replica_cursor.fetchone()
        
        if primary_result != replica_result:
            print(f"INCONSISTENCY DETECTED in table {table}")
            return False
        else:
            print(f"Table {table}: CONSISTENT")
    
    return True
```

---

## S3 Replication Testing

### 5. Cross-Region Replication Validation
```bash
# Create test file
echo "DR test $(date)" > dr-test-$(date +%s).txt

# Upload to primary bucket
aws s3 cp dr-test-*.txt s3://dr-webapp-primary-123456789012/test/

# Wait for replication
sleep 30

# Check replication to secondary bucket
aws s3 ls s3://dr-webapp-secondary-123456789012/test/

# Verify file content
aws s3 cp s3://dr-webapp-secondary-123456789012/test/dr-test-*.txt - | cat
```

### 6. Replication Metrics Monitoring
```bash
# Check replication metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name ReplicationLatency \
  --dimensions Name=SourceBucket,Value=dr-webapp-primary-123456789012 \
              Name=DestinationBucket,Value=dr-webapp-secondary-123456789012 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum
```

---

## Application Testing

### 7. Health Check Endpoint Testing
```bash
# Test primary application health
curl -f -v http://app.example.com/health
curl -f -v https://app.example.com/health

# Test secondary application health
curl -f -v http://dr-app.us-west-2.elb.amazonaws.com/health

# Load testing with Apache Bench
ab -n 1000 -c 10 http://app.example.com/
```

### 8. Application Functionality Testing
```python
import requests
import json
import time

def test_application_functionality():
    base_url = "https://app.example.com"
    
    # Test authentication
    auth_response = requests.post(f"{base_url}/api/auth/login", 
                                 json={"username": "test", "password": "test"})
    assert auth_response.status_code == 200
    
    token = auth_response.json()['token']
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test API endpoints
    endpoints = [
        "/api/users",
        "/api/orders",
        "/api/products"
    ]
    
    for endpoint in endpoints:
        response = requests.get(f"{base_url}{endpoint}", headers=headers)
        assert response.status_code == 200
        print(f"✓ {endpoint} - OK")
    
    # Test database operations
    test_data = {"name": "Test User", "email": "test@example.com"}
    create_response = requests.post(f"{base_url}/api/users", 
                                   json=test_data, headers=headers)
    assert create_response.status_code == 201
    
    print("Application functionality test: PASSED")
```

---

## Disaster Recovery Testing

### 9. Planned Failover Testing
```bash
#!/bin/bash
# planned-failover-test.sh

echo "Starting planned failover test at $(date)"

# 1. Scale up secondary region
aws autoscaling set-desired-capacity \
  --region us-west-2 \
  --auto-scaling-group-name dr-webapp-secondary-asg \
  --desired-capacity 3

# Wait for instances to be ready
sleep 300

# 2. Promote read replica to primary
aws rds promote-read-replica \
  --region us-west-2 \
  --db-instance-identifier dr-webapp-secondary-db

# Wait for promotion
aws rds wait db-instance-available \
  --region us-west-2 \
  --db-instance-identifier dr-webapp-secondary-db

# 3. Update Route 53 to point to secondary
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://failover-to-secondary.json

# 4. Monitor and validate
echo "Failover initiated. Monitoring..."
sleep 60

# Test application availability
curl -f http://app.example.com/health || echo "FAILOVER FAILED"

echo "Planned failover test completed at $(date)"
```

### 10. Automated Failover Testing
```python
import boto3
import time
import requests

def test_automated_failover():
    """Test automated failover using Lambda function"""
    
    lambda_client = boto3.client('lambda', region_name='us-east-1')
    
    # Trigger failover Lambda
    response = lambda_client.invoke(
        FunctionName='dr-failover-function',
        InvocationType='RequestResponse',
        Payload=json.dumps({
            'trigger': 'test',
            'source': 'planned_test'
        })
    )
    
    # Monitor failover progress
    start_time = time.time()
    max_wait = 900  # 15 minutes
    
    while time.time() - start_time < max_wait:
        try:
            response = requests.get('http://app.example.com/health', timeout=10)
            if response.status_code == 200:
                elapsed = time.time() - start_time
                print(f"Failover completed in {elapsed:.2f} seconds")
                return True
        except:
            pass
        
        time.sleep(30)
    
    print("Failover test FAILED - timeout exceeded")
    return False
```

---

## Performance Testing

### 11. Load Testing
```bash
# Install and configure load testing tools
# Using Artillery.js for load testing

# artillery-config.yml
cat > artillery-config.yml << EOF
config:
  target: 'https://app.example.com'
  phases:
    - duration: 300
      arrivalRate: 10
    - duration: 600
      arrivalRate: 50
    - duration: 300
      arrivalRate: 100
  processor: "./test-functions.js"

scenarios:
  - name: "DR Load Test"
    requests:
      - get:
          url: "/health"
      - get:
          url: "/api/users"
      - post:
          url: "/api/orders"
          json:
            product_id: 123
            quantity: 1
EOF

# Run load test
artillery run artillery-config.yml --output report.json
artillery report report.json
```

### 12. Database Performance Testing
```sql
-- Database performance test queries
DELIMITER //
CREATE PROCEDURE TestDatabasePerformance()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time TIMESTAMP;
    DECLARE end_time TIMESTAMP;
    
    SET start_time = NOW();
    
    -- Insert test data
    WHILE i <= 10000 DO
        INSERT INTO test_performance (data, created_at) 
        VALUES (CONCAT('Test data ', i), NOW());
        SET i = i + 1;
    END WHILE;
    
    -- Test SELECT performance
    SELECT COUNT(*) FROM test_performance WHERE created_at > DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    SET end_time = NOW();
    SELECT TIMESTAMPDIFF(MICROSECOND, start_time, end_time) as execution_time_microseconds;
END//
DELIMITER ;

CALL TestDatabasePerformance();
```

---

## Recovery Time Testing

### 13. RTO (Recovery Time Objective) Testing
```bash
#!/bin/bash
# rto-test.sh

echo "Starting RTO test at $(date)"
START_TIME=$(date +%s)

# Simulate primary failure
echo "Simulating primary region failure..."

# Trigger failover
aws lambda invoke \
  --function-name dr-failover-function \
  --payload '{"test": true}' \
  response.json

# Monitor recovery
while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    # Test application availability
    if curl -f -s http://app.example.com/health > /dev/null; then
        echo "Application recovered in $ELAPSED seconds"
        break
    fi
    
    if [ $ELAPSED -gt 900 ]; then  # 15 minutes timeout
        echo "RTO test FAILED - exceeded 15 minutes"
        exit 1
    fi
    
    sleep 10
done

echo "RTO test completed successfully"
```

### 14. RPO (Recovery Point Objective) Testing
```python
import time
import mysql.connector
from datetime import datetime

def test_rpo():
    """Test Recovery Point Objective"""
    
    # Connect to primary database
    primary_conn = mysql.connector.connect(
        host='primary-db.cluster-xyz.us-east-1.rds.amazonaws.com',
        user='admin',
        password='password',
        database='webapp'
    )
    
    cursor = primary_conn.cursor()
    
    # Insert test data with timestamp
    test_data = f"RPO test data - {datetime.now()}"
    cursor.execute(
        "INSERT INTO rpo_test (data, inserted_at) VALUES (%s, %s)",
        (test_data, datetime.now())
    )
    primary_conn.commit()
    
    # Wait for replication
    time.sleep(60)
    
    # Check if data exists in replica
    replica_conn = mysql.connector.connect(
        host='replica-db.cluster-abc.us-west-2.rds.amazonaws.com',
        user='admin',
        password='password',
        database='webapp'
    )
    
    replica_cursor = replica_conn.cursor()
    replica_cursor.execute(
        "SELECT COUNT(*) FROM rpo_test WHERE data = %s",
        (test_data,)
    )
    
    if replica_cursor.fetchone()[0] > 0:
        print("RPO test PASSED - data replicated successfully")
    else:
        print("RPO test FAILED - data not replicated")
```

---

## Monitoring and Alerting Testing

### 15. CloudWatch Alarms Testing
```bash
# Test CloudWatch alarms by triggering conditions
aws cloudwatch put-metric-data \
  --namespace "Custom/DR/Test" \
  --metric-data MetricName=TestMetric,Value=100,Unit=Count

# Verify alarm notifications
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:123456789012:dr-alerts

# Test alarm actions
aws cloudwatch set-alarm-state \
  --alarm-name "dr-webapp-alb-high-errors" \
  --state-value ALARM \
  --state-reason "Testing alarm functionality"
```

---

## Testing Schedule and Automation

### 16. Automated Testing Pipeline
```yaml
# .github/workflows/dr-testing.yml
name: DR Testing Pipeline

on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM
  workflow_dispatch:

jobs:
  dr-connectivity-test:
    runs-on: ubuntu-latest
    steps:
      - name: Test network connectivity
        run: |
          ping -c 5 primary-endpoint.amazonaws.com
          ping -c 5 secondary-endpoint.amazonaws.com
  
  dr-replication-test:
    runs-on: ubuntu-latest
    steps:
      - name: Test database replication
        run: |
          python test_replication.py
  
  dr-failover-test:
    runs-on: ubuntu-latest
    if: github.event_name == 'workflow_dispatch'
    steps:
      - name: Execute planned failover test
        run: |
          ./planned-failover-test.sh
```

---

## Test Documentation and Reporting

### 17. Test Results Template
```markdown
# DR Test Results Report

**Test Date:** [Date]
**Test Type:** [Planned Failover/Automated/Performance]
**Executed By:** [Name]

## Test Summary
- **RTO Achieved:** [X] minutes (Target: 15 minutes)
- **RPO Achieved:** [X] minutes (Target: 60 minutes)
- **Test Status:** [PASSED/FAILED]

## Detailed Results
| Test Case | Expected Result | Actual Result | Status |
|-----------|----------------|---------------|--------|
| Network Connectivity | < 100ms latency | 85ms | PASS |
| Database Replication | < 60s lag | 45s | PASS |
| Application Health | 200 OK | 200 OK | PASS |

## Issues Identified
- [Issue 1 description]
- [Issue 2 description]

## Recommendations
- [Recommendation 1]
- [Recommendation 2]
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: DR Testing Team
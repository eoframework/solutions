# Testing Procedures - AWS Cloud Migration

## Overview

This document outlines comprehensive testing procedures for AWS cloud migration projects to ensure successful migration, performance validation, and operational readiness.

---

## Pre-Migration Testing

### 1. Application Assessment Testing
```python
#!/usr/bin/env python3
# application_assessment.py

import requests
import subprocess
import json
import sys

def test_application_dependencies():
    """Test application dependencies and external integrations"""
    
    dependencies = [
        {"name": "Database", "host": "db.company.local", "port": 3306},
        {"name": "LDAP", "host": "ldap.company.local", "port": 389},
        {"name": "API Gateway", "host": "api.company.local", "port": 443}
    ]
    
    results = []
    
    for dep in dependencies:
        try:
            # Test connectivity
            result = subprocess.run(
                ["nc", "-zv", dep["host"], str(dep["port"])],
                capture_output=True, text=True, timeout=10
            )
            
            status = "PASS" if result.returncode == 0 else "FAIL"
            results.append({
                "dependency": dep["name"],
                "status": status,
                "details": result.stderr.strip()
            })
            
        except Exception as e:
            results.append({
                "dependency": dep["name"],
                "status": "ERROR",
                "details": str(e)
            })
    
    return results

def test_application_performance():
    """Baseline application performance testing"""
    
    endpoints = [
        "/health",
        "/api/users",
        "/api/orders",
        "/api/products"
    ]
    
    base_url = "http://app.company.local"
    performance_results = []
    
    for endpoint in endpoints:
        try:
            response = requests.get(f"{base_url}{endpoint}", timeout=10)
            performance_results.append({
                "endpoint": endpoint,
                "response_time": response.elapsed.total_seconds(),
                "status_code": response.status_code,
                "status": "PASS" if response.status_code == 200 else "FAIL"
            })
        except Exception as e:
            performance_results.append({
                "endpoint": endpoint,
                "status": "ERROR",
                "error": str(e)
            })
    
    return performance_results

if __name__ == "__main__":
    print("Running Application Assessment Tests...")
    
    dep_results = test_application_dependencies()
    perf_results = test_application_performance()
    
    print("\n=== Dependency Test Results ===")
    for result in dep_results:
        print(f"{result['dependency']}: {result['status']}")
    
    print("\n=== Performance Test Results ===")
    for result in perf_results:
        print(f"{result['endpoint']}: {result.get('response_time', 'N/A')}s - {result['status']}")
```

### 2. Network Connectivity Testing
```bash
#!/bin/bash
# network_connectivity_test.sh

echo "Testing network connectivity for migration..."

# Test AWS connectivity
echo "Testing AWS connectivity:"
curl -I https://ec2.us-east-1.amazonaws.com
curl -I https://s3.amazonaws.com

# Test Direct Connect/VPN
echo "Testing hybrid connectivity:"
ping -c 5 vpc-endpoint.us-east-1.amazonaws.com

# Test bandwidth
echo "Testing bandwidth:"
aws s3 cp /dev/zero s3://test-bucket/speedtest --cli-write-timeout 10 2>&1 | head -5

# Test DNS resolution
echo "Testing DNS resolution:"
nslookup vpc-endpoint.us-east-1.amazonaws.com
nslookup s3.amazonaws.com
```

---

## Migration Testing

### 3. Database Migration Testing
```sql
-- Pre-migration database validation
-- Create validation tables and procedures

CREATE TABLE migration_validation (
    table_name VARCHAR(64),
    row_count_before BIGINT,
    checksum_before VARCHAR(32),
    row_count_after BIGINT,
    checksum_after VARCHAR(32),
    validation_status ENUM('PENDING', 'PASS', 'FAIL'),
    validated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE PROCEDURE ValidateTableMigration(IN table_name_param VARCHAR(64))
BEGIN
    DECLARE row_count BIGINT;
    DECLARE table_checksum VARCHAR(32);
    
    -- Get row count
    SET @sql = CONCAT('SELECT COUNT(*) INTO @row_count FROM ', table_name_param);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Get table checksum
    SET @sql = CONCAT('CHECKSUM TABLE ', table_name_param);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Store validation data
    INSERT INTO migration_validation (table_name, row_count_before, checksum_before, validation_status)
    VALUES (table_name_param, @row_count, @table_checksum, 'PENDING');
END//
DELIMITER ;

-- Execute for all tables
CALL ValidateTableMigration('users');
CALL ValidateTableMigration('orders');
CALL ValidateTableMigration('products');
```

### 4. AWS DMS Testing
```python
import boto3
import time
import json

def monitor_dms_task(task_arn):
    """Monitor DMS replication task progress"""
    
    dms = boto3.client('dms')
    
    while True:
        response = dms.describe_replication_tasks(
            ReplicationTaskArns=[task_arn]
        )
        
        task = response['ReplicationTasks'][0]
        status = task['Status']
        
        if 'ReplicationTaskStats' in task:
            stats = task['ReplicationTaskStats']
            print(f"Task Status: {status}")
            print(f"Full Load Progress: {stats.get('FullLoadProgressPercent', 0)}%")
            print(f"Tables Loaded: {stats.get('TablesLoaded', 0)}")
            print(f"Tables Loading: {stats.get('TablesLoading', 0)}")
            print(f"Tables Errored: {stats.get('TablesErrored', 0)}")
        
        if status in ['stopped', 'failed', 'complete']:
            return status
        
        time.sleep(30)

def validate_dms_migration():
    """Validate DMS migration results"""
    
    # Compare source and target data
    source_conn = mysql.connector.connect(
        host='source.database.local',
        user='admin',
        password='password',
        database='production'
    )
    
    target_conn = mysql.connector.connect(
        host='target.cluster-xyz.us-east-1.rds.amazonaws.com',
        user='admin',
        password='password',
        database='production'
    )
    
    tables = ['users', 'orders', 'products', 'order_items']
    validation_results = []
    
    for table in tables:
        source_cursor = source_conn.cursor()
        target_cursor = target_conn.cursor()
        
        # Compare row counts
        source_cursor.execute(f"SELECT COUNT(*) FROM {table}")
        target_cursor.execute(f"SELECT COUNT(*) FROM {table}")
        
        source_count = source_cursor.fetchone()[0]
        target_count = target_cursor.fetchone()[0]
        
        # Compare checksums
        source_cursor.execute(f"CHECKSUM TABLE {table}")
        target_cursor.execute(f"CHECKSUM TABLE {table}")
        
        source_checksum = source_cursor.fetchone()[1]
        target_checksum = target_cursor.fetchone()[1]
        
        validation_results.append({
            'table': table,
            'source_count': source_count,
            'target_count': target_count,
            'count_match': source_count == target_count,
            'checksum_match': source_checksum == target_checksum,
            'status': 'PASS' if (source_count == target_count and source_checksum == target_checksum) else 'FAIL'
        })
    
    return validation_results
```

### 5. Application Migration Testing (MGN)
```bash
#!/bin/bash
# mgn_migration_test.sh

echo "Testing AWS Application Migration Service (MGN)..."

# Check source server status
aws mgn describe-source-servers --source-server-ids s-1234567890abcdef0

# Monitor replication progress
echo "Monitoring replication progress..."
while true; do
    STATUS=$(aws mgn describe-source-servers \
        --source-server-ids s-1234567890abcdef0 \
        --query 'items[0].dataReplicationInfo.dataReplicationState' \
        --output text)
    
    echo "Replication Status: $STATUS"
    
    if [ "$STATUS" = "CONTINUOUS_REPLICATION" ]; then
        echo "Replication ready for testing"
        break
    elif [ "$STATUS" = "DISCONNECTED" ] || [ "$STATUS" = "FAILED_TO_START_REPLICATION" ]; then
        echo "Replication failed"
        exit 1
    fi
    
    sleep 60
done

# Launch test instance
echo "Launching test instance..."
aws mgn start-test --source-server-ids s-1234567890abcdef0

# Monitor test launch
JOB_ID=$(aws mgn describe-jobs --query 'items[0].jobID' --output text)
echo "Monitoring job: $JOB_ID"

while true; do
    JOB_STATUS=$(aws mgn describe-jobs \
        --job-id $JOB_ID \
        --query 'items[0].status' \
        --output text)
    
    echo "Job Status: $JOB_STATUS"
    
    if [ "$JOB_STATUS" = "COMPLETED" ]; then
        echo "Test instance launched successfully"
        break
    elif [ "$JOB_STATUS" = "FAILED" ]; then
        echo "Test launch failed"
        exit 1
    fi
    
    sleep 30
done
```

---

## Post-Migration Testing

### 6. Application Functionality Testing
```python
import requests
import json
import time
from selenium import webdriver
from selenium.webdriver.common.by import By

class ApplicationFunctionalityTest:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        
    def test_api_endpoints(self):
        """Test all API endpoints"""
        endpoints = [
            {"path": "/health", "method": "GET", "expected_status": 200},
            {"path": "/api/users", "method": "GET", "expected_status": 200},
            {"path": "/api/products", "method": "GET", "expected_status": 200},
        ]
        
        results = []
        
        for endpoint in endpoints:
            try:
                if endpoint["method"] == "GET":
                    response = self.session.get(f"{self.base_url}{endpoint['path']}")
                elif endpoint["method"] == "POST":
                    response = self.session.post(f"{self.base_url}{endpoint['path']}", 
                                               json=endpoint.get("data", {}))
                
                results.append({
                    "endpoint": endpoint["path"],
                    "expected_status": endpoint["expected_status"],
                    "actual_status": response.status_code,
                    "response_time": response.elapsed.total_seconds(),
                    "status": "PASS" if response.status_code == endpoint["expected_status"] else "FAIL"
                })
                
            except Exception as e:
                results.append({
                    "endpoint": endpoint["path"],
                    "status": "ERROR",
                    "error": str(e)
                })
        
        return results
    
    def test_web_interface(self):
        """Test web interface using Selenium"""
        options = webdriver.ChromeOptions()
        options.add_argument('--headless')
        driver = webdriver.Chrome(options=options)
        
        try:
            # Test login page
            driver.get(f"{self.base_url}/login")
            assert "Login" in driver.title
            
            # Test main pages
            pages = ["/dashboard", "/users", "/reports"]
            for page in pages:
                driver.get(f"{self.base_url}{page}")
                time.sleep(2)
                # Add specific page validation here
                
            return {"status": "PASS", "pages_tested": len(pages)}
            
        except Exception as e:
            return {"status": "FAIL", "error": str(e)}
        finally:
            driver.quit()

# Usage
if __name__ == "__main__":
    test = ApplicationFunctionalityTest("https://migrated-app.company.com")
    
    print("Testing API endpoints...")
    api_results = test.test_api_endpoints()
    for result in api_results:
        print(f"{result['endpoint']}: {result['status']}")
    
    print("Testing web interface...")
    web_result = test.test_web_interface()
    print(f"Web interface test: {web_result['status']}")
```

### 7. Performance Comparison Testing
```bash
#!/bin/bash
# performance_comparison_test.sh

echo "Running performance comparison tests..."

# Define test parameters
ORIGINAL_URL="http://app.company.local"
MIGRATED_URL="https://app.migrated.company.com"
TEST_DURATION=300  # 5 minutes
CONCURRENT_USERS=50

# Test original application
echo "Testing original application performance..."
ab -t $TEST_DURATION -c $CONCURRENT_USERS "$ORIGINAL_URL/" > original_results.txt

# Test migrated application
echo "Testing migrated application performance..."
ab -t $TEST_DURATION -c $CONCURRENT_USERS "$MIGRATED_URL/" > migrated_results.txt

# Parse and compare results
echo "Performance Comparison Results:"
echo "================================"

ORIGINAL_RPS=$(grep "Requests per second" original_results.txt | awk '{print $4}')
MIGRATED_RPS=$(grep "Requests per second" migrated_results.txt | awk '{print $4}')

ORIGINAL_TIME=$(grep "Time per request" original_results.txt | head -1 | awk '{print $4}')
MIGRATED_TIME=$(grep "Time per request" migrated_results.txt | head -1 | awk '{print $4}')

echo "Requests per second - Original: $ORIGINAL_RPS, Migrated: $MIGRATED_RPS"
echo "Time per request - Original: $ORIGINAL_TIME ms, Migrated: $MIGRATED_TIME ms"

# Calculate improvement
python3 << EOF
original_rps = float("$ORIGINAL_RPS")
migrated_rps = float("$MIGRATED_RPS")
improvement = ((migrated_rps - original_rps) / original_rps) * 100
print(f"Performance improvement: {improvement:.2f}%")
EOF
```

---

## Load and Stress Testing

### 8. Load Testing with Artillery
```yaml
# artillery-load-test.yml
config:
  target: 'https://migrated-app.company.com'
  phases:
    # Warm-up phase
    - duration: 60
      arrivalRate: 5
      name: "Warm up"
    
    # Ramp-up phase
    - duration: 300
      arrivalRate: 10
      rampTo: 50
      name: "Ramp up load"
    
    # Sustained load phase
    - duration: 600
      arrivalRate: 50
      name: "Sustained load"
    
    # Peak load phase
    - duration: 300
      arrivalRate: 100
      name: "Peak load"

scenarios:
  - name: "User journey"
    weight: 100
    requests:
      - get:
          url: "/health"
          capture:
            - json: "$.status"
              as: "health_status"
      - get:
          url: "/api/users"
          headers:
            Authorization: "Bearer {{ auth_token }}"
      - post:
          url: "/api/orders"
          json:
            product_id: "{{ $randomInt(1, 1000) }}"
            quantity: "{{ $randomInt(1, 5) }}"
          headers:
            Authorization: "Bearer {{ auth_token }}"
```

### 9. Database Performance Testing
```sql
-- Database performance test suite

-- Test 1: Insert performance
SET @start_time = NOW(6);

INSERT INTO performance_test (id, data, created_at)
SELECT 
    seq.id,
    CONCAT('Test data for performance testing - ', seq.id),
    NOW()
FROM (
    SELECT (@row_number:=@row_number + 1) as id
    FROM information_schema.tables t1, 
         information_schema.tables t2,
         (SELECT @row_number:=0) r
    LIMIT 10000
) AS seq;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 as insert_time_ms;

-- Test 2: Select performance with various conditions
SET @start_time = NOW(6);

SELECT COUNT(*) FROM performance_test 
WHERE created_at > DATE_SUB(NOW(), INTERVAL 1 HOUR);

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 as select_time_ms;

-- Test 3: Join performance
SET @start_time = NOW(6);

SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.id
HAVING order_count > 5;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 as join_time_ms;
```

---

## Security Testing

### 10. Security Validation Testing
```python
import ssl
import socket
import subprocess
import requests
from urllib.parse import urljoin

def test_ssl_configuration(hostname):
    """Test SSL/TLS configuration"""
    try:
        context = ssl.create_default_context()
        with socket.create_connection((hostname, 443)) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                cert = ssock.getpeercert()
                return {
                    "ssl_version": ssock.version(),
                    "cipher": ssock.cipher(),
                    "cert_valid": True,
                    "cert_issuer": cert.get('issuer'),
                    "cert_expiry": cert.get('notAfter')
                }
    except Exception as e:
        return {"ssl_valid": False, "error": str(e)}

def test_security_headers(base_url):
    """Test security headers"""
    response = requests.get(base_url)
    headers = response.headers
    
    security_headers = {
        'X-Content-Type-Options': headers.get('X-Content-Type-Options'),
        'X-Frame-Options': headers.get('X-Frame-Options'),
        'X-XSS-Protection': headers.get('X-XSS-Protection'),
        'Strict-Transport-Security': headers.get('Strict-Transport-Security'),
        'Content-Security-Policy': headers.get('Content-Security-Policy')
    }
    
    return security_headers

def test_network_security():
    """Test network security configuration"""
    # Test for open ports that shouldn't be accessible
    forbidden_ports = [22, 3389, 3306, 5432, 6379, 27017]
    results = []
    
    for port in forbidden_ports:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(5)
            result = sock.connect_ex(('app.migrated.company.com', port))
            sock.close()
            
            status = "OPEN" if result == 0 else "CLOSED"
            results.append({"port": port, "status": status})
        except:
            results.append({"port": port, "status": "ERROR"})
    
    return results
```

---

## Automated Testing Pipeline

### 11. CI/CD Integration Testing
```yaml
# .github/workflows/migration-testing.yml
name: Migration Testing Pipeline

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  connectivity-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test AWS connectivity
        run: |
          aws configure set aws_access_key_id ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws configure set aws_secret_access_key ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws sts get-caller-identity

  application-test:
    runs-on: ubuntu-latest
    needs: connectivity-test
    steps:
      - name: Test application functionality
        run: |
          python application_functionality_test.py
          
  performance-test:
    runs-on: ubuntu-latest
    needs: application-test
    steps:
      - name: Run performance tests
        run: |
          npm install -g artillery
          artillery run artillery-load-test.yml

  security-test:
    runs-on: ubuntu-latest
    steps:
      - name: Run security scans
        run: |
          python security_validation_test.py
```

---

## Test Reporting and Documentation

### 12. Test Results Dashboard
```python
import json
import matplotlib.pyplot as plt
from datetime import datetime

def generate_test_report(test_results):
    """Generate comprehensive test report"""
    
    report = {
        "test_date": datetime.now().isoformat(),
        "summary": {
            "total_tests": len(test_results),
            "passed_tests": len([t for t in test_results if t["status"] == "PASS"]),
            "failed_tests": len([t for t in test_results if t["status"] == "FAIL"]),
            "success_rate": 0
        },
        "detailed_results": test_results
    }
    
    if report["summary"]["total_tests"] > 0:
        report["summary"]["success_rate"] = (
            report["summary"]["passed_tests"] / report["summary"]["total_tests"]
        ) * 100
    
    # Generate visualizations
    create_test_charts(report)
    
    # Save report
    with open(f"migration_test_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json", 'w') as f:
        json.dump(report, f, indent=2)
    
    return report

def create_test_charts(report):
    """Create test result visualizations"""
    
    # Test results pie chart
    labels = ['Passed', 'Failed']
    sizes = [report["summary"]["passed_tests"], report["summary"]["failed_tests"]]
    colors = ['green', 'red']
    
    plt.figure(figsize=(8, 6))
    plt.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%')
    plt.title('Migration Test Results')
    plt.savefig('test_results_pie_chart.png')
    plt.close()
    
    # Performance trends
    # This would include performance data over time
    plt.figure(figsize=(10, 6))
    # Add performance trending code here
    plt.title('Performance Trends')
    plt.savefig('performance_trends.png')
    plt.close()
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Migration Testing Team
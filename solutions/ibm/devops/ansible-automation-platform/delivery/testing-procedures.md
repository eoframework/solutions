# IBM Ansible Automation Platform - Testing Procedures

## Document Information
**Solution**: Red Hat Ansible Automation Platform  
**Version**: 2.4  
**Date**: January 2025  
**Audience**: QA Engineers, Platform Engineers, DevOps Teams  

---

## Overview

This document provides comprehensive testing procedures for validating the Red Hat Ansible Automation Platform deployment. The testing framework covers functional, performance, security, and integration testing scenarios to ensure platform reliability and performance.

### Testing Strategy
- **Unit Testing**: Individual component functionality
- **Integration Testing**: Inter-component communication
- **Performance Testing**: Load and stress testing
- **Security Testing**: Vulnerability and compliance testing
- **User Acceptance Testing**: End-user workflow validation
- **Disaster Recovery Testing**: Backup and recovery procedures

---

## Pre-Testing Requirements

### Environment Preparation

#### Test Environment Setup
```bash
# Set environment variables
export CONTROLLER_URL="https://$(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')"
export HUB_URL="https://$(oc get route automation-hub -n ansible-automation-platform -o jsonpath='{.spec.host}')"
export EDA_URL="https://$(oc get route eda-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')"
export API_TOKEN="your-api-token"
export NAMESPACE="ansible-automation-platform"

# Verify platform accessibility
curl -k -s -o /dev/null -w "%{http_code}" ${CONTROLLER_URL}/api/v2/ping/
curl -k -s -o /dev/null -w "%{http_code}" ${HUB_URL}/pulp/api/v3/status/
curl -k -s -o /dev/null -w "%{http_code}" ${EDA_URL}/api/eda/v1/status/
```

#### Test Data Preparation
```bash
# Create test organization
curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Organization", "description": "Organization for testing purposes"}' \
  ${CONTROLLER_URL}/api/v2/organizations/

# Create test project
curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Project",
    "organization": 1,
    "scm_type": "git",
    "scm_url": "https://github.com/ansible/ansible-examples.git",
    "scm_branch": "master"
  }' \
  ${CONTROLLER_URL}/api/v2/projects/

# Create test inventory
curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Inventory",
    "organization": 1,
    "variables": "---\ntest_var: test_value"
  }' \
  ${CONTROLLER_URL}/api/v2/inventories/
```

---

## Functional Testing

### Test Case 1: Platform Component Health

#### TC001: Controller API Functionality
```bash
#!/bin/bash
# test-controller-api.sh

echo "=== Test Case 001: Controller API Functionality ==="

# Test 1.1: API Ping
echo "Test 1.1: API Ping"
RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" ${CONTROLLER_URL}/api/v2/ping/)
if [ $RESPONSE -eq 200 ]; then
    echo "✓ PASS: Controller API is responding"
else
    echo "✗ FAIL: Controller API not responding (HTTP $RESPONSE)"
fi

# Test 1.2: Authentication
echo "Test 1.2: Authentication"
AUTH_RESPONSE=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/me/)
if echo $AUTH_RESPONSE | jq -e '.id' > /dev/null 2>&1; then
    echo "✓ PASS: Authentication successful"
else
    echo "✗ FAIL: Authentication failed"
fi

# Test 1.3: Organizations API
echo "Test 1.3: Organizations API"
ORG_RESPONSE=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/organizations/)
ORG_COUNT=$(echo $ORG_RESPONSE | jq '.count')
if [ $ORG_COUNT -gt 0 ]; then
    echo "✓ PASS: Organizations API functional ($ORG_COUNT organizations found)"
else
    echo "✗ FAIL: Organizations API not returning data"
fi

# Test 1.4: Projects API
echo "Test 1.4: Projects API"
PROJ_RESPONSE=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/projects/)
echo $PROJ_RESPONSE | jq '.results[0].name' > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ PASS: Projects API functional"
else
    echo "✗ FAIL: Projects API not functional"
fi
```

#### TC002: Hub Functionality
```bash
#!/bin/bash
# test-hub-functionality.sh

echo "=== Test Case 002: Hub Functionality ==="

# Test 2.1: Hub API Status
echo "Test 2.1: Hub API Status"
HUB_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" ${HUB_URL}/pulp/api/v3/status/)
if [ $HUB_STATUS -eq 200 ]; then
    echo "✓ PASS: Hub API is responding"
else
    echo "✗ FAIL: Hub API not responding (HTTP $HUB_STATUS)"
fi

# Test 2.2: Collections Endpoint
echo "Test 2.2: Collections Endpoint"
COLLECTIONS_RESPONSE=$(curl -k -s ${HUB_URL}/pulp/api/v3/collections/)
if echo $COLLECTIONS_RESPONSE | jq '.count' > /dev/null 2>&1; then
    echo "✓ PASS: Collections endpoint functional"
else
    echo "✗ FAIL: Collections endpoint not functional"
fi

# Test 2.3: Namespaces Endpoint
echo "Test 2.3: Namespaces Endpoint"
NAMESPACES_RESPONSE=$(curl -k -s ${HUB_URL}/pulp/api/v3/namespaces/)
if echo $NAMESPACES_RESPONSE | jq '.count' > /dev/null 2>&1; then
    echo "✓ PASS: Namespaces endpoint functional"
else
    echo "✗ FAIL: Namespaces endpoint not functional"
fi
```

### Test Case 3: Job Execution

#### TC003: Basic Job Template Execution
```bash
#!/bin/bash
# test-job-execution.sh

echo "=== Test Case 003: Job Template Execution ==="

# Create test playbook
cat > test-playbook.yml << 'EOF'
---
- name: Test Playbook
  hosts: localhost
  gather_facts: yes
  tasks:
    - name: Test task 1
      debug:
        msg: "Hello from Ansible Automation Platform!"
    
    - name: Test task 2
      set_fact:
        test_result: "success"
    
    - name: Test task 3
      debug:
        var: test_result
    
    - name: System information
      debug:
        msg: "Running on {{ ansible_facts['os_family'] }}"
EOF

# Create job template
JOB_TEMPLATE_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Job Template",
    "project": 1,
    "playbook": "test-playbook.yml",
    "inventory": 1,
    "ask_variables_on_launch": false
  }' \
  ${CONTROLLER_URL}/api/v2/job_templates/)

JOB_TEMPLATE_ID=$(echo $JOB_TEMPLATE_RESPONSE | jq '.id')

if [ "$JOB_TEMPLATE_ID" != "null" ]; then
    echo "✓ PASS: Job template created (ID: $JOB_TEMPLATE_ID)"
    
    # Launch job
    echo "Test 3.1: Job Launch"
    JOB_LAUNCH_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      ${CONTROLLER_URL}/api/v2/job_templates/${JOB_TEMPLATE_ID}/launch/)
    
    JOB_ID=$(echo $JOB_LAUNCH_RESPONSE | jq '.id')
    
    if [ "$JOB_ID" != "null" ]; then
        echo "✓ PASS: Job launched successfully (Job ID: $JOB_ID)"
        
        # Monitor job status
        echo "Test 3.2: Job Status Monitoring"
        for i in {1..30}; do
            sleep 10
            JOB_STATUS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
              ${CONTROLLER_URL}/api/v2/jobs/${JOB_ID}/ | jq -r '.status')
            
            echo "Job status: $JOB_STATUS"
            
            if [ "$JOB_STATUS" = "successful" ]; then
                echo "✓ PASS: Job completed successfully"
                break
            elif [ "$JOB_STATUS" = "failed" ]; then
                echo "✗ FAIL: Job execution failed"
                # Get job output for debugging
                curl -k -s -H "Authorization: Bearer $API_TOKEN" \
                  ${CONTROLLER_URL}/api/v2/jobs/${JOB_ID}/stdout/ | jq -r '.content'
                break
            fi
        done
        
        # Get final job details
        JOB_DETAILS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
          ${CONTROLLER_URL}/api/v2/jobs/${JOB_ID}/)
        
        ELAPSED_TIME=$(echo $JOB_DETAILS | jq '.elapsed')
        echo "Job execution time: ${ELAPSED_TIME} seconds"
        
    else
        echo "✗ FAIL: Job launch failed"
    fi
else
    echo "✗ FAIL: Job template creation failed"
fi
```

---

## Integration Testing

### Test Case 4: SCM Integration

#### TC004: Git Repository Sync
```bash
#!/bin/bash
# test-scm-integration.sh

echo "=== Test Case 004: SCM Integration ==="

# Test 4.1: Project Sync
echo "Test 4.1: Project Sync"
PROJECT_ID=1  # Assuming test project exists

# Trigger project sync
SYNC_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/projects/${PROJECT_ID}/update/)

UPDATE_ID=$(echo $SYNC_RESPONSE | jq '.id')

if [ "$UPDATE_ID" != "null" ]; then
    echo "✓ PASS: Project sync initiated (Update ID: $UPDATE_ID)"
    
    # Monitor sync status
    for i in {1..20}; do
        sleep 5
        UPDATE_STATUS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
          ${CONTROLLER_URL}/api/v2/project_updates/${UPDATE_ID}/ | jq -r '.status')
        
        echo "Sync status: $UPDATE_STATUS"
        
        if [ "$UPDATE_STATUS" = "successful" ]; then
            echo "✓ PASS: Project sync completed successfully"
            break
        elif [ "$UPDATE_STATUS" = "failed" ]; then
            echo "✗ FAIL: Project sync failed"
            break
        fi
    done
else
    echo "✗ FAIL: Project sync initiation failed"
fi

# Test 4.2: Playbook Discovery
echo "Test 4.2: Playbook Discovery"
PROJECT_DETAILS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/projects/${PROJECT_ID}/playbooks/)

PLAYBOOK_COUNT=$(echo $PROJECT_DETAILS | jq '. | length')
if [ $PLAYBOOK_COUNT -gt 0 ]; then
    echo "✓ PASS: Playbooks discovered ($PLAYBOOK_COUNT found)"
    echo "Available playbooks:"
    echo $PROJECT_DETAILS | jq -r '.[]'
else
    echo "✗ FAIL: No playbooks discovered"
fi
```

### Test Case 5: Inventory Integration

#### TC005: Dynamic Inventory
```bash
#!/bin/bash
# test-dynamic-inventory.sh

echo "=== Test Case 005: Dynamic Inventory ==="

# Create dynamic inventory source
INVENTORY_SOURCE_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Dynamic Inventory",
    "inventory": 1,
    "source": "scm",
    "source_project": 1,
    "source_path": "inventory/hosts.yml",
    "update_on_launch": true,
    "update_cache_timeout": 0
  }' \
  ${CONTROLLER_URL}/api/v2/inventory_sources/)

INV_SOURCE_ID=$(echo $INVENTORY_SOURCE_RESPONSE | jq '.id')

if [ "$INV_SOURCE_ID" != "null" ]; then
    echo "✓ PASS: Dynamic inventory source created (ID: $INV_SOURCE_ID)"
    
    # Trigger inventory sync
    echo "Test 5.1: Inventory Sync"
    INV_UPDATE_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
      ${CONTROLLER_URL}/api/v2/inventory_sources/${INV_SOURCE_ID}/update/)
    
    INV_UPDATE_ID=$(echo $INV_UPDATE_RESPONSE | jq '.id')
    
    if [ "$INV_UPDATE_ID" != "null" ]; then
        echo "✓ PASS: Inventory sync initiated"
        
        # Monitor inventory sync
        for i in {1..15}; do
            sleep 5
            INV_UPDATE_STATUS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
              ${CONTROLLER_URL}/api/v2/inventory_updates/${INV_UPDATE_ID}/ | jq -r '.status')
            
            echo "Inventory sync status: $INV_UPDATE_STATUS"
            
            if [ "$INV_UPDATE_STATUS" = "successful" ]; then
                echo "✓ PASS: Inventory sync completed"
                break
            elif [ "$INV_UPDATE_STATUS" = "failed" ]; then
                echo "✗ FAIL: Inventory sync failed"
                break
            fi
        done
    else
        echo "✗ FAIL: Inventory sync initiation failed"
    fi
else
    echo "✗ FAIL: Dynamic inventory source creation failed"
fi

# Test 5.2: Host Discovery
echo "Test 5.2: Host Discovery"
HOSTS_RESPONSE=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/inventories/1/hosts/)

HOST_COUNT=$(echo $HOSTS_RESPONSE | jq '.count')
if [ $HOST_COUNT -gt 0 ]; then
    echo "✓ PASS: Hosts discovered in inventory ($HOST_COUNT hosts)"
else
    echo "✗ FAIL: No hosts discovered in inventory"
fi
```

---

## Performance Testing

### Test Case 6: Concurrent Job Execution

#### TC006: Load Testing
```bash
#!/bin/bash
# test-concurrent-jobs.sh

echo "=== Test Case 006: Concurrent Job Execution ==="

CONCURRENT_JOBS=10
JOB_TEMPLATE_ID=1  # Assuming test job template exists

echo "Test 6.1: Launching $CONCURRENT_JOBS concurrent jobs"

# Array to store job IDs
declare -a JOB_IDS

# Launch concurrent jobs
for i in $(seq 1 $CONCURRENT_JOBS); do
    JOB_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      ${CONTROLLER_URL}/api/v2/job_templates/${JOB_TEMPLATE_ID}/launch/)
    
    JOB_ID=$(echo $JOB_RESPONSE | jq '.id')
    if [ "$JOB_ID" != "null" ]; then
        JOB_IDS+=($JOB_ID)
        echo "Job $i launched: ID $JOB_ID"
    else
        echo "✗ FAIL: Job $i launch failed"
    fi
    sleep 1
done

echo "✓ PASS: ${#JOB_IDS[@]} jobs launched successfully"

# Monitor job completion
echo "Test 6.2: Monitoring job completion"
START_TIME=$(date +%s)
COMPLETED_JOBS=0
FAILED_JOBS=0

while [ $COMPLETED_JOBS -lt ${#JOB_IDS[@]} ] && [ $FAILED_JOBS -eq 0 ]; do
    sleep 10
    COMPLETED_JOBS=0
    FAILED_JOBS=0
    
    for JOB_ID in "${JOB_IDS[@]}"; do
        JOB_STATUS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
          ${CONTROLLER_URL}/api/v2/jobs/${JOB_ID}/ | jq -r '.status')
        
        if [ "$JOB_STATUS" = "successful" ]; then
            ((COMPLETED_JOBS++))
        elif [ "$JOB_STATUS" = "failed" ]; then
            ((FAILED_JOBS++))
            echo "✗ FAIL: Job $JOB_ID failed"
        fi
    done
    
    echo "Progress: $COMPLETED_JOBS completed, $FAILED_JOBS failed"
    
    # Timeout after 10 minutes
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - START_TIME)) -gt 600 ]; then
        echo "✗ TIMEOUT: Jobs taking too long to complete"
        break
    fi
done

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))

if [ $FAILED_JOBS -eq 0 ] && [ $COMPLETED_JOBS -eq ${#JOB_IDS[@]} ]; then
    echo "✓ PASS: All $COMPLETED_JOBS jobs completed successfully"
    echo "Total execution time: $TOTAL_TIME seconds"
    echo "Average time per job: $((TOTAL_TIME / COMPLETED_JOBS)) seconds"
else
    echo "✗ FAIL: $FAILED_JOBS jobs failed, $COMPLETED_JOBS completed"
fi
```

### Test Case 7: Resource Utilization

#### TC007: Resource Monitoring During Load
```bash
#!/bin/bash
# test-resource-monitoring.sh

echo "=== Test Case 007: Resource Monitoring ==="

# Monitor resources during testing
echo "Test 7.1: Baseline Resource Usage"
echo "Node resources:"
oc top nodes

echo "Pod resources:"
oc top pods -n $NAMESPACE --sort-by=cpu

echo "Database connections:"
DB_CONNECTIONS=$(oc exec postgresql-0 -n $NAMESPACE -- psql -U controller -d automationcontroller -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';")
echo "Active database connections: $DB_CONNECTIONS"

# Memory usage by component
echo "Test 7.2: Component Memory Usage"
CONTROLLER_MEMORY=$(oc top pods -n $NAMESPACE | grep automation-controller | awk '{sum+=$3} END {print sum}')
HUB_MEMORY=$(oc top pods -n $NAMESPACE | grep automation-hub | awk '{sum+=$3} END {print sum}')
DB_MEMORY=$(oc top pods -n $NAMESPACE | grep postgresql | awk '{print $3}')

echo "Controller pods total memory: ${CONTROLLER_MEMORY}Mi"
echo "Hub pods total memory: ${HUB_MEMORY}Mi"
echo "Database memory: ${DB_MEMORY}"

# Storage usage
echo "Test 7.3: Storage Usage"
echo "Persistent volume usage:"
oc exec postgresql-0 -n $NAMESPACE -- df -h /var/lib/postgresql/data
```

---

## Security Testing

### Test Case 8: Authentication and Authorization

#### TC008: RBAC Testing
```bash
#!/bin/bash
# test-rbac.sh

echo "=== Test Case 008: RBAC Testing ==="

# Create test user with limited permissions
echo "Test 8.1: User Creation and Permission Testing"
TEST_USER_RESPONSE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "TestPassword123!",
    "email": "testuser@company.com",
    "first_name": "Test",
    "last_name": "User"
  }' \
  ${CONTROLLER_URL}/api/v2/users/)

TEST_USER_ID=$(echo $TEST_USER_RESPONSE | jq '.id')

if [ "$TEST_USER_ID" != "null" ]; then
    echo "✓ PASS: Test user created (ID: $TEST_USER_ID)"
    
    # Get token for test user
    TEST_TOKEN_RESPONSE=$(curl -X POST -k \
      -H "Content-Type: application/json" \
      -d '{
        "username": "testuser",
        "password": "TestPassword123!"
      }' \
      ${CONTROLLER_URL}/api/v2/authtoken/)
    
    TEST_TOKEN=$(echo $TEST_TOKEN_RESPONSE | jq -r '.token')
    
    if [ "$TEST_TOKEN" != "null" ]; then
        echo "✓ PASS: Test user authentication successful"
        
        # Test unauthorized access
        echo "Test 8.2: Unauthorized Access Prevention"
        UNAUTHORIZED_RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" \
          -H "Authorization: Bearer $TEST_TOKEN" \
          ${CONTROLLER_URL}/api/v2/organizations/)
        
        if [ $UNAUTHORIZED_RESPONSE -eq 403 ] || [ $UNAUTHORIZED_RESPONSE -eq 401 ]; then
            echo "✓ PASS: Unauthorized access properly denied (HTTP $UNAUTHORIZED_RESPONSE)"
        else
            echo "✗ FAIL: Unauthorized access not properly denied (HTTP $UNAUTHORIZED_RESPONSE)"
        fi
    else
        echo "✗ FAIL: Test user authentication failed"
    fi
    
    # Cleanup test user
    curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
      ${CONTROLLER_URL}/api/v2/users/${TEST_USER_ID}/
else
    echo "✗ FAIL: Test user creation failed"
fi
```

### Test Case 9: TLS and Encryption

#### TC009: TLS Configuration Testing
```bash
#!/bin/bash
# test-tls-security.sh

echo "=== Test Case 009: TLS Security Testing ==="

# Test 9.1: TLS Certificate Validation
echo "Test 9.1: TLS Certificate Validation"
CONTROLLER_HOST=$(echo $CONTROLLER_URL | sed 's|https://||')

# Check certificate details
CERT_INFO=$(echo | openssl s_client -servername $CONTROLLER_HOST -connect $CONTROLLER_HOST:443 2>/dev/null | openssl x509 -noout -text)

# Extract certificate validity
NOT_BEFORE=$(echo "$CERT_INFO" | grep "Not Before" | cut -d: -f2-)
NOT_AFTER=$(echo "$CERT_INFO" | grep "Not After" | cut -d: -f2-)

echo "Certificate valid from: $NOT_BEFORE"
echo "Certificate valid until: $NOT_AFTER"

# Check if certificate is not expired
EXPIRY_DATE=$(echo "$CERT_INFO" | grep "Not After" | cut -d: -f2- | xargs)
CURRENT_DATE=$(date)

if openssl x509 -checkend 86400 <<< "$CERT_INFO" > /dev/null 2>&1; then
    echo "✓ PASS: Certificate is valid and not expiring within 24 hours"
else
    echo "✗ FAIL: Certificate is expired or expiring within 24 hours"
fi

# Test 9.2: TLS Protocol Version
echo "Test 9.2: TLS Protocol Version"
TLS_VERSION=$(echo | openssl s_client -servername $CONTROLLER_HOST -connect $CONTROLLER_HOST:443 2>/dev/null | grep "Protocol" | head -1)
echo "TLS Protocol: $TLS_VERSION"

if echo "$TLS_VERSION" | grep -q "TLSv1\.[23]"; then
    echo "✓ PASS: Secure TLS version in use"
else
    echo "✗ FAIL: Insecure TLS version detected"
fi

# Test 9.3: Cipher Strength
echo "Test 9.3: Cipher Strength"
CIPHER_INFO=$(echo | openssl s_client -servername $CONTROLLER_HOST -connect $CONTROLLER_HOST:443 2>/dev/null | grep "Cipher")
echo "Cipher: $CIPHER_INFO"

if echo "$CIPHER_INFO" | grep -qE "(AES|CHACHA|ECDHE|DHE)"; then
    echo "✓ PASS: Strong cipher in use"
else
    echo "✗ FAIL: Weak cipher detected"
fi
```

---

## Disaster Recovery Testing

### Test Case 10: Backup and Recovery

#### TC010: Database Backup and Restore
```bash
#!/bin/bash
# test-backup-restore.sh

echo "=== Test Case 010: Backup and Restore Testing ==="

BACKUP_DIR="/tmp/ansible-test-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR

# Test 10.1: Database Backup
echo "Test 10.1: Database Backup"
oc exec postgresql-0 -n $NAMESPACE -- pg_dump -U controller automationcontroller > $BACKUP_DIR/controller-backup.sql

if [ $? -eq 0 ] && [ -s $BACKUP_DIR/controller-backup.sql ]; then
    echo "✓ PASS: Database backup completed successfully"
    BACKUP_SIZE=$(du -h $BACKUP_DIR/controller-backup.sql | cut -f1)
    echo "Backup size: $BACKUP_SIZE"
else
    echo "✗ FAIL: Database backup failed"
    exit 1
fi

# Test 10.2: Configuration Backup
echo "Test 10.2: Configuration Backup"
oc get automationcontroller automation-controller -n $NAMESPACE -o yaml > $BACKUP_DIR/controller-config.yaml
oc get secrets -n $NAMESPACE -o yaml > $BACKUP_DIR/secrets-backup.yaml

if [ -s $BACKUP_DIR/controller-config.yaml ] && [ -s $BACKUP_DIR/secrets-backup.yaml ]; then
    echo "✓ PASS: Configuration backup completed successfully"
else
    echo "✗ FAIL: Configuration backup failed"
fi

# Test 10.3: Backup Integrity
echo "Test 10.3: Backup Integrity Verification"
# Verify SQL backup can be parsed
if head -20 $BACKUP_DIR/controller-backup.sql | grep -q "PostgreSQL database dump"; then
    echo "✓ PASS: SQL backup file integrity verified"
else
    echo "✗ FAIL: SQL backup file integrity check failed"
fi

# Verify YAML files are valid
if oc apply --dry-run=client -f $BACKUP_DIR/controller-config.yaml > /dev/null 2>&1; then
    echo "✓ PASS: Configuration backup file integrity verified"
else
    echo "✗ FAIL: Configuration backup file integrity check failed"
fi

echo "Backup test completed. Files stored in: $BACKUP_DIR"
echo "Remember to clean up test backups: rm -rf $BACKUP_DIR"
```

---

## User Acceptance Testing

### Test Case 11: End-User Workflows

#### TC011: Complete User Workflow
```bash
#!/bin/bash
# test-user-workflow.sh

echo "=== Test Case 011: End-User Workflow Testing ==="

# Test 11.1: User Login and Navigation
echo "Test 11.1: User Interface Accessibility"

# Check if web interface is accessible
UI_RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" ${CONTROLLER_URL}/)
if [ $UI_RESPONSE -eq 200 ]; then
    echo "✓ PASS: Web interface is accessible"
else
    echo "✗ FAIL: Web interface not accessible (HTTP $UI_RESPONSE)"
fi

# Test 11.2: Job Template Creation Workflow
echo "Test 11.2: Job Template Creation Workflow"

# Simulate user creating a job template through API
USER_JOB_TEMPLATE=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "User Test Job Template",
    "description": "Created during user acceptance testing",
    "project": 1,
    "playbook": "test-playbook.yml",
    "inventory": 1,
    "verbosity": 0,
    "ask_variables_on_launch": true
  }' \
  ${CONTROLLER_URL}/api/v2/job_templates/)

USER_JT_ID=$(echo $USER_JOB_TEMPLATE | jq '.id')

if [ "$USER_JT_ID" != "null" ]; then
    echo "✓ PASS: User can create job templates"
    
    # Test 11.3: Job Launching Workflow
    echo "Test 11.3: Job Launching with Variables"
    
    USER_JOB_LAUNCH=$(curl -X POST -k -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "extra_vars": {
          "user_test_var": "UAT_Value",
          "environment": "testing"
        }
      }' \
      ${CONTROLLER_URL}/api/v2/job_templates/${USER_JT_ID}/launch/)
    
    USER_JOB_ID=$(echo $USER_JOB_LAUNCH | jq '.id')
    
    if [ "$USER_JOB_ID" != "null" ]; then
        echo "✓ PASS: User can launch jobs with custom variables"
        
        # Monitor job for completion
        for i in {1..20}; do
            sleep 10
            JOB_STATUS=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
              ${CONTROLLER_URL}/api/v2/jobs/${USER_JOB_ID}/ | jq -r '.status')
            
            if [ "$JOB_STATUS" = "successful" ]; then
                echo "✓ PASS: User job completed successfully"
                break
            elif [ "$JOB_STATUS" = "failed" ]; then
                echo "✗ FAIL: User job execution failed"
                break
            fi
        done
        
        # Test 11.4: Job Output Viewing
        echo "Test 11.4: Job Output Accessibility"
        JOB_OUTPUT=$(curl -k -s -H "Authorization: Bearer $API_TOKEN" \
          ${CONTROLLER_URL}/api/v2/jobs/${USER_JOB_ID}/stdout/)
        
        if echo $JOB_OUTPUT | jq -e '.content' > /dev/null 2>&1; then
            echo "✓ PASS: User can access job output"
        else
            echo "✗ FAIL: User cannot access job output"
        fi
        
    else
        echo "✗ FAIL: User cannot launch jobs"
    fi
    
    # Cleanup
    curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
      ${CONTROLLER_URL}/api/v2/job_templates/${USER_JT_ID}/
    
else
    echo "✗ FAIL: User cannot create job templates"
fi
```

---

## Automated Test Execution

### Test Suite Runner

#### Master Test Script
```bash
#!/bin/bash
# run-all-tests.sh

echo "=========================================="
echo "Ansible Automation Platform Test Suite"
echo "Started at: $(date)"
echo "=========================================="

# Set up test environment
export CONTROLLER_URL="https://$(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')"
export HUB_URL="https://$(oc get route automation-hub -n ansible-automation-platform -o jsonpath='{.spec.host}')"
export EDA_URL="https://$(oc get route eda-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')"
export API_TOKEN="your-api-token"
export NAMESPACE="ansible-automation-platform"

# Test execution counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run test and track results
run_test() {
    local test_script=$1
    local test_name=$2
    
    echo "Running $test_name..."
    ((TOTAL_TESTS++))
    
    if ./$test_script; then
        ((PASSED_TESTS++))
        echo "✓ $test_name PASSED"
    else
        ((FAILED_TESTS++))
        echo "✗ $test_name FAILED"
    fi
    
    echo "----------------------------------------"
}

# Execute test suite
echo "Starting test execution..."

# Functional tests
run_test "test-controller-api.sh" "Controller API Functionality"
run_test "test-hub-functionality.sh" "Hub Functionality"
run_test "test-job-execution.sh" "Job Execution"

# Integration tests
run_test "test-scm-integration.sh" "SCM Integration"
run_test "test-dynamic-inventory.sh" "Dynamic Inventory"

# Performance tests
run_test "test-concurrent-jobs.sh" "Concurrent Job Execution"
run_test "test-resource-monitoring.sh" "Resource Monitoring"

# Security tests
run_test "test-rbac.sh" "RBAC Testing"
run_test "test-tls-security.sh" "TLS Security"

# Disaster recovery tests
run_test "test-backup-restore.sh" "Backup and Restore"

# User acceptance tests
run_test "test-user-workflow.sh" "User Workflow"

# Generate test report
echo "=========================================="
echo "TEST EXECUTION SUMMARY"
echo "Completed at: $(date)"
echo "=========================================="
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Success Rate: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%"
echo "=========================================="

# Generate detailed report
cat > test-report.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Ansible Automation Platform Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #f0f0f0; padding: 20px; }
        .passed { color: green; }
        .failed { color: red; }
        .summary { background-color: #e9e9e9; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Ansible Automation Platform Test Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <div class="summary">
        <h2>Test Summary</h2>
        <p>Total Tests: $TOTAL_TESTS</p>
        <p class="passed">Passed: $PASSED_TESTS</p>
        <p class="failed">Failed: $FAILED_TESTS</p>
        <p>Success Rate: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%</p>
    </div>
    
    <h2>Test Categories</h2>
    <ul>
        <li>Functional Tests: Platform component validation</li>
        <li>Integration Tests: Component interaction validation</li>
        <li>Performance Tests: Load and resource testing</li>
        <li>Security Tests: Authentication and authorization</li>
        <li>Disaster Recovery Tests: Backup and restore procedures</li>
        <li>User Acceptance Tests: End-user workflow validation</li>
    </ul>
    
    <h2>Recommendations</h2>
    <p>Review failed tests and address any issues before production deployment.</p>
    <p>Schedule regular testing to ensure continued platform reliability.</p>
</body>
</html>
EOF

echo "Detailed report generated: test-report.html"

# Exit with error code if tests failed
if [ $FAILED_TESTS -gt 0 ]; then
    exit 1
else
    exit 0
fi
```

---

## Test Data Cleanup

### Cleanup Procedures
```bash
#!/bin/bash
# cleanup-test-data.sh

echo "=== Cleaning up test data ==="

# Remove test job templates
curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/job_templates/$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/job_templates/ | jq -r '.results[] | select(.name | startswith("Test")) | .id')/

# Remove test projects
curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/projects/$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/projects/ | jq -r '.results[] | select(.name | startswith("Test")) | .id')/

# Remove test inventories
curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/inventories/$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/inventories/ | jq -r '.results[] | select(.name | startswith("Test")) | .id')/

# Remove test organizations
curl -X DELETE -k -H "Authorization: Bearer $API_TOKEN" \
  ${CONTROLLER_URL}/api/v2/organizations/$(curl -k -s -H "Authorization: Bearer $API_TOKEN" ${CONTROLLER_URL}/api/v2/organizations/ | jq -r '.results[] | select(.name | startswith("Test")) | .id')/

echo "Test data cleanup completed"
```

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: Quality Assurance Team
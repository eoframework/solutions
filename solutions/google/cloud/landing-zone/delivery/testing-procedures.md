# Google Cloud Landing Zone Testing Procedures

## Overview
This document outlines comprehensive testing procedures for Google Cloud Landing Zone implementation, covering infrastructure validation, security testing, performance verification, and disaster recovery testing.

## Pre-Deployment Testing

### Infrastructure Validation Testing

#### Test 1: Organization Structure Validation
**Objective**: Verify folder structure and hierarchy  
**Duration**: 30 minutes  
**Prerequisites**: Organization admin permissions

**Test Steps**:
1. **Folder Creation Verification**
   ```bash
   # List organization folders
   gcloud resource-manager folders list --organization=${ORG_ID}
   
   # Verify folder structure
   gcloud resource-manager folders describe ${FOLDER_ID}
   ```

2. **Project Creation Testing**
   ```bash
   # Create test project in each folder
   gcloud projects create test-security-proj --folder=${SECURITY_FOLDER_ID}
   gcloud projects create test-prod-proj --folder=${PRODUCTION_FOLDER_ID}
   
   # Verify project placement
   gcloud projects describe test-security-proj
   ```

3. **IAM Policy Validation**
   ```bash
   # Check folder-level IAM policies
   gcloud resource-manager folders get-iam-policy ${FOLDER_ID}
   
   # Verify inheritance
   gcloud projects get-iam-policy test-security-proj
   ```

**Expected Results**:
- All required folders created successfully
- Projects can be created in appropriate folders
- IAM policies inherited correctly
- No permission errors or access denials

**Pass Criteria**: All folder operations complete without errors

#### Test 2: Network Infrastructure Validation
**Objective**: Verify VPC networks, subnets, and connectivity  
**Duration**: 45 minutes  
**Prerequisites**: Network admin permissions

**Test Steps**:
1. **VPC Creation Verification**
   ```bash
   # List all VPC networks
   gcloud compute networks list
   
   # Verify network configuration
   gcloud compute networks describe hub-vpc
   gcloud compute networks describe shared-services-vpc
   ```

2. **Subnet Validation**
   ```bash
   # List subnets for each VPC
   gcloud compute networks subnets list --filter="network:hub-vpc"
   
   # Verify subnet configuration
   gcloud compute networks subnets describe hub-central --region=us-central1
   ```

3. **VPC Peering Testing**
   ```bash
   # Check peering status
   gcloud compute networks peerings list --network=hub-vpc
   
   # Verify peering connectivity
   gcloud compute networks peerings list --network=shared-services-vpc
   ```

4. **Routing Validation**
   ```bash
   # Check routing tables
   gcloud compute routes list --filter="network:hub-vpc"
   
   # Verify custom routes
   gcloud compute routes list --filter="nextHopNetwork"
   ```

**Expected Results**:
- All VPC networks created with correct configuration
- Subnets created in specified regions with correct CIDR blocks
- VPC peering established and active
- Custom routes propagated correctly

**Pass Criteria**: Network connectivity established between all VPCs

#### Test 3: Firewall Rules Validation
**Objective**: Verify firewall rules and network security  
**Duration**: 30 minutes

**Test Steps**:
1. **Firewall Rule Configuration**
   ```bash
   # List all firewall rules
   gcloud compute firewall-rules list --sort-by=priority
   
   # Verify specific rules
   gcloud compute firewall-rules describe allow-internal-hub
   gcloud compute firewall-rules describe deny-all-external
   ```

2. **Security Group Testing**
   ```bash
   # Create test instances with different tags
   gcloud compute instances create test-internal \
     --zone=us-central1-a \
     --subnet=hub-central \
     --tags=internal
   
   gcloud compute instances create test-external \
     --zone=us-central1-a \
     --subnet=hub-central \
     --tags=external
   ```

3. **Connectivity Testing**
   ```bash
   # Test internal connectivity (should succeed)
   gcloud compute ssh test-internal \
     --zone=us-central1-a \
     --command="ping -c 3 ${INTERNAL_IP}"
   
   # Test external blocking (should fail)
   gcloud compute ssh test-external \
     --zone=us-central1-a \
     --command="curl -m 10 https://external-service.com"
   ```

**Expected Results**:
- All required firewall rules created
- Internal communication allowed between appropriate resources
- External access properly restricted
- Security policies enforced correctly

### Security Testing

#### Test 4: Identity and Access Management
**Objective**: Validate IAM roles and permissions  
**Duration**: 1 hour

**Test Steps**:
1. **Role Assignment Verification**
   ```bash
   # Check organization-level roles
   gcloud organizations get-iam-policy ${ORG_ID}
   
   # Verify folder-level permissions
   gcloud resource-manager folders get-iam-policy ${FOLDER_ID}
   
   # Test project-level access
   gcloud projects get-iam-policy ${PROJECT_ID}
   ```

2. **Service Account Testing**
   ```bash
   # List service accounts
   gcloud iam service-accounts list
   
   # Test service account permissions
   gcloud auth activate-service-account --key-file=${SA_KEY_FILE}
   gcloud projects list  # Should show accessible projects only
   ```

3. **Custom Role Validation**
   ```bash
   # List custom roles
   gcloud iam roles list --organization=${ORG_ID}
   
   # Test custom role permissions
   gcloud iam roles describe landing_zone_network_admin --organization=${ORG_ID}
   ```

**Expected Results**:
- All required roles assigned correctly
- Service accounts have minimal required permissions
- Custom roles function as expected
- No excessive permissions granted

#### Test 5: Encryption and Key Management
**Objective**: Verify KMS configuration and encryption  
**Duration**: 45 minutes

**Test Steps**:
1. **KMS Key Ring Verification**
   ```bash
   # List key rings
   gcloud kms keyrings list --location=${KMS_LOCATION}
   
   # Verify key ring configuration
   gcloud kms keyrings describe landing-zone-keyring --location=${KMS_LOCATION}
   ```

2. **Crypto Key Testing**
   ```bash
   # List crypto keys
   gcloud kms keys list --keyring=landing-zone-keyring --location=${KMS_LOCATION}
   
   # Test key encryption/decryption
   echo "test data" | gcloud kms encrypt \
     --key=compute-encryption-key \
     --keyring=landing-zone-keyring \
     --location=${KMS_LOCATION} \
     --plaintext-file=- \
     --ciphertext-file=encrypted-test.bin
   
   gcloud kms decrypt \
     --key=compute-encryption-key \
     --keyring=landing-zone-keyring \
     --location=${KMS_LOCATION} \
     --ciphertext-file=encrypted-test.bin \
     --plaintext-file=-
   ```

3. **Disk Encryption Validation**
   ```bash
   # Create encrypted disk
   gcloud compute disks create test-encrypted-disk \
     --size=10GB \
     --kms-key=projects/${PROJECT_ID}/locations/${KMS_LOCATION}/keyRings/landing-zone-keyring/cryptoKeys/compute-encryption-key \
     --zone=us-central1-a
   
   # Verify encryption settings
   gcloud compute disks describe test-encrypted-disk --zone=us-central1-a
   ```

**Expected Results**:
- KMS key rings and keys created successfully
- Encryption/decryption operations work correctly
- Disk encryption configured properly
- Key rotation policies configured

## Post-Deployment Testing

### Connectivity Testing

#### Test 6: End-to-End Connectivity
**Objective**: Verify complete network connectivity  
**Duration**: 1 hour

**Test Steps**:
1. **Multi-VPC Connectivity**
   ```bash
   # Create test instances in each VPC
   gcloud compute instances create hub-test-vm \
     --zone=us-central1-a \
     --subnet=hub-central \
     --tags=test-vm
   
   gcloud compute instances create spoke-test-vm \
     --zone=us-central1-a \
     --subnet=prod-app1-subnet \
     --tags=test-vm
   
   # Test connectivity between VPCs
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="ping -c 5 ${SPOKE_INTERNAL_IP}"
   ```

2. **DNS Resolution Testing**
   ```bash
   # Test internal DNS resolution
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="nslookup internal.company.com"
   
   # Test external DNS resolution
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="nslookup google.com"
   ```

3. **VPN Connectivity Testing** (if applicable)
   ```bash
   # Check VPN tunnel status
   gcloud compute vpn-tunnels list --filter="status=ESTABLISHED"
   
   # Test on-premises connectivity
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="ping -c 3 ${ONPREM_IP_ADDRESS}"
   ```

**Expected Results**:
- Successful connectivity between all VPC networks
- DNS resolution working for internal and external domains
- VPN connectivity to on-premises resources (if configured)
- No packet loss or connectivity timeouts

#### Test 7: Load Balancer Testing
**Objective**: Validate load balancing configuration  
**Duration**: 30 minutes

**Test Steps**:
1. **Load Balancer Health Checks**
   ```bash
   # Check load balancer status
   gcloud compute backend-services list
   
   # Verify health check status
   gcloud compute health-checks list
   gcloud compute backend-services get-health ${BACKEND_SERVICE_NAME} --global
   ```

2. **Traffic Distribution Testing**
   ```bash
   # Test load distribution
   for i in {1..10}; do
     curl -s https://${LOAD_BALANCER_IP} | grep "Server ID"
   done
   ```

3. **Failover Testing**
   ```bash
   # Stop one backend instance
   gcloud compute instances stop ${BACKEND_INSTANCE_1} --zone=us-central1-a
   
   # Verify traffic redirects
   curl -s https://${LOAD_BALANCER_IP}
   
   # Restart instance
   gcloud compute instances start ${BACKEND_INSTANCE_1} --zone=us-central1-a
   ```

**Expected Results**:
- All backend services healthy
- Traffic distributed evenly across backends
- Failover works correctly when backends unavailable

### Performance Testing

#### Test 8: Network Performance
**Objective**: Validate network performance and latency  
**Duration**: 45 minutes

**Test Steps**:
1. **Bandwidth Testing**
   ```bash
   # Install iperf3 on test instances
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="sudo apt-get update && sudo apt-get install -y iperf3"
   
   # Run bandwidth test between regions
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="iperf3 -c ${REMOTE_INSTANCE_IP} -t 30"
   ```

2. **Latency Testing**
   ```bash
   # Measure latency between regions
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="ping -c 100 ${REMOTE_INSTANCE_IP} | tail -1"
   
   # Test latency to Google services
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="ping -c 20 storage.googleapis.com"
   ```

3. **DNS Resolution Performance**
   ```bash
   # Test DNS resolution time
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="dig internal.company.com | grep 'Query time'"
   ```

**Expected Results**:
- Bandwidth meets expected throughput requirements
- Latency within acceptable ranges (<50ms intra-region, <100ms inter-region)
- DNS resolution time under 10ms for internal domains

#### Test 9: Storage Performance
**Objective**: Validate storage performance and operations  
**Duration**: 30 minutes

**Test Steps**:
1. **Disk I/O Performance**
   ```bash
   # Create high-performance disk
   gcloud compute disks create performance-test-disk \
     --size=100GB \
     --type=pd-ssd \
     --zone=us-central1-a
   
   # Attach to test instance and run I/O test
   gcloud compute instances attach-disk hub-test-vm \
     --disk=performance-test-disk \
     --zone=us-central1-a
   
   # Run fio benchmark
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="sudo fio --name=random-write --ioengine=libaio --rw=randwrite --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60"
   ```

2. **Cloud Storage Performance**
   ```bash
   # Test upload/download performance
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="time gsutil -m cp /dev/zero gs://${TEST_BUCKET}/test-file-1gb count=1024 bs=1M"
   
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="time gsutil cp gs://${TEST_BUCKET}/test-file-1gb /tmp/"
   ```

**Expected Results**:
- Disk I/O performance meets specifications (>30,000 IOPS for SSD)
- Cloud Storage upload/download speeds acceptable
- No I/O errors or timeouts

### Security Testing

#### Test 10: Security Controls Validation
**Objective**: Verify security controls and policies  
**Duration**: 1.5 hours

**Test Steps**:
1. **Organization Policy Testing**
   ```bash
   # Test VM external IP restriction
   gcloud compute instances create test-no-external-ip \
     --zone=us-central1-a \
     --subnet=prod-app1-subnet \
     --no-address
   
   # Attempt to create VM with external IP (should fail)
   gcloud compute instances create test-with-external-ip \
     --zone=us-central1-a \
     --subnet=prod-app1-subnet \
     --address=""
   ```

2. **OS Login Enforcement**
   ```bash
   # Verify OS Login is enabled
   gcloud compute project-info describe --format="get(commonInstanceMetadata.items[key=enable-oslogin].value)"
   
   # Test SSH access without OS Login (should fail)
   gcloud compute ssh test-internal --zone=us-central1-a
   ```

3. **Shielded VM Testing**
   ```bash
   # Create instance without Shielded VM features (should fail)
   gcloud compute instances create test-unshielded \
     --zone=us-central1-a \
     --subnet=hub-central \
     --no-shielded-secure-boot
   ```

**Expected Results**:
- Organization policies enforced correctly
- OS Login required for all SSH access
- Shielded VM features mandatory
- Policy violations blocked automatically

#### Test 11: Monitoring and Alerting
**Objective**: Validate monitoring and alerting configuration  
**Duration**: 45 minutes

**Test Steps**:
1. **Metrics Collection Verification**
   ```bash
   # Check if metrics are being collected
   gcloud alpha monitoring metrics list --filter="metric.type:compute.googleapis.com"
   
   # Verify custom metrics
   gcloud alpha monitoring metrics-descriptors list --filter="displayName:landing-zone"
   ```

2. **Alert Policy Testing**
   ```bash
   # List alerting policies
   gcloud alpha monitoring policies list
   
   # Trigger test alert (high CPU)
   gcloud compute ssh hub-test-vm \
     --zone=us-central1-a \
     --command="stress --cpu 4 --timeout 300s" &
   ```

3. **Log Export Verification**
   ```bash
   # Check log sinks
   gcloud logging sinks list
   
   # Verify log export to Cloud Storage
   gsutil ls gs://${SECURITY_LOGS_BUCKET}/
   
   # Test log query
   gcloud logging read 'resource.type="gce_instance" AND severity>=ERROR' --limit=10
   ```

**Expected Results**:
- All required metrics being collected
- Alert policies trigger correctly
- Logs exported to designated destinations
- Monitoring dashboards display data

## Disaster Recovery Testing

#### Test 12: Backup and Recovery
**Objective**: Validate backup and recovery procedures  
**Duration**: 2 hours

**Test Steps**:
1. **Snapshot Creation and Recovery**
   ```bash
   # Create snapshot of critical disk
   gcloud compute disks snapshot ${CRITICAL_DISK} \
     --zone=us-central1-a \
     --snapshot-names=test-recovery-snapshot
   
   # Create new disk from snapshot
   gcloud compute disks create recovered-disk \
     --source-snapshot=test-recovery-snapshot \
     --zone=us-central1-a
   
   # Attach to instance and verify data
   gcloud compute instances attach-disk test-recovery-vm \
     --disk=recovered-disk \
     --zone=us-central1-a
   ```

2. **Database Backup Testing** (if applicable)
   ```bash
   # Create database backup
   gcloud sql backups create --instance=${DB_INSTANCE_NAME}
   
   # Create new instance from backup
   gcloud sql instances clone ${DB_INSTANCE_NAME} test-recovery-db \
     --backup-id=${BACKUP_ID}
   
   # Verify data integrity
   gcloud sql connect test-recovery-db --user=root
   ```

3. **Cross-Region Recovery Testing**
   ```bash
   # Copy snapshot to different region
   gcloud compute snapshots create ${SNAPSHOT_NAME} \
     --source-disk=${DISK_NAME} \
     --zone=us-central1-a \
     --storage-location=us-east1
   
   # Create disk in different region
   gcloud compute disks create dr-test-disk \
     --source-snapshot=${SNAPSHOT_NAME} \
     --zone=us-east1-a
   ```

**Expected Results**:
- Snapshots created successfully
- Data recovered completely and accurately
- Cross-region recovery functional
- Recovery time within RTO requirements

#### Test 13: Failover Testing
**Objective**: Test failover capabilities and procedures  
**Duration**: 3 hours

**Test Steps**:
1. **Regional Failover Simulation**
   ```bash
   # Simulate region failure by stopping instances
   gcloud compute instances stop --zone=us-central1-a $(gcloud compute instances list --zones=us-central1-a --format="value(name)")
   
   # Verify traffic redirects to secondary region
   for i in {1..20}; do
     curl -s https://${LOAD_BALANCER_IP} | grep "Region"
     sleep 5
   done
   ```

2. **Database Failover Testing**
   ```bash
   # Promote read replica to master
   gcloud sql instances promote-replica ${READ_REPLICA_INSTANCE}
   
   # Update application connection strings
   # Test application connectivity
   ```

3. **Network Failover Testing**
   ```bash
   # Simulate VPN failure
   gcloud compute vpn-tunnels delete ${PRIMARY_VPN_TUNNEL} --region=us-central1
   
   # Verify backup connectivity activates
   gcloud compute routes list --filter="nextHopVpnTunnel:${BACKUP_VPN_TUNNEL}"
   ```

**Expected Results**:
- Failover completes within RTO requirements
- No data loss during failover
- Applications function correctly after failover
- Backup connectivity mechanisms activate

## Acceptance Testing

### Test 14: User Acceptance Testing
**Objective**: Validate end-user functionality  
**Duration**: 4 hours

**Test Scenarios**:
1. **Developer Workflow**
   - Create new project in non-production folder
   - Deploy sample application
   - Access application through load balancer
   - Monitor application metrics

2. **Security Admin Workflow**
   - Create new security policies
   - Review security findings
   - Investigate security alerts
   - Generate compliance reports

3. **Operations Team Workflow**
   - Deploy infrastructure changes
   - Monitor system health
   - Respond to alerts
   - Perform maintenance tasks

**Pass Criteria**:
- All user workflows complete successfully
- Performance meets expectations
- Security controls work as designed
- Monitoring provides adequate visibility

## Test Execution Schedule

### Phase 1: Infrastructure Testing (Week 1)
- Tests 1-3: Infrastructure validation
- Tests 4-5: Security testing
- Environment: Non-production

### Phase 2: Integration Testing (Week 2)
- Tests 6-7: Connectivity testing
- Tests 8-9: Performance testing
- Environment: Non-production

### Phase 3: Security & Monitoring Testing (Week 3)
- Tests 10-11: Security and monitoring
- Tests 12-13: Disaster recovery
- Environment: Non-production

### Phase 4: Acceptance Testing (Week 4)
- Test 14: User acceptance testing
- Final validation
- Environment: Production (limited scope)

## Test Documentation

### Test Results Documentation
For each test, document:
- Test execution date and time
- Test executor name
- Test results (Pass/Fail/Partial)
- Issues encountered and resolution
- Performance metrics captured
- Screenshots or logs as evidence

### Issue Tracking
- All issues logged in tracking system
- Severity classification (Critical/High/Medium/Low)
- Resolution timeline and ownership
- Verification of fixes

### Final Test Report
- Executive summary of test results
- Risk assessment and mitigation
- Go/No-go recommendation
- Outstanding issues and acceptance criteria

---
**Testing Procedures Version**: 1.0  
**Last Updated**: [DATE]  
**Document Owner**: Quality Assurance Team  
**Approved by**: [TECHNICAL_DIRECTOR]
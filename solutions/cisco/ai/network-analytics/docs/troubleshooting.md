# Troubleshooting Guide - Cisco AI Network Analytics

## Executive Summary

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues in Cisco AI Network Analytics implementations. The guide covers DNA Center, Catalyst Center, ThousandEyes integration, AI/ML analytics, and network infrastructure problems with step-by-step resolution procedures.

## General Troubleshooting Methodology

### 1. Problem Classification Framework

#### Severity Levels
```
Severity 1 (Critical)    - Complete system failure, no workaround
Severity 2 (High)        - Major functionality impaired, limited workaround
Severity 3 (Medium)      - Minor functionality affected, workaround available
Severity 4 (Low)         - Cosmetic or enhancement requests
```

#### Problem Categories
- **Connectivity Issues**: Network communication failures
- **Authentication Problems**: Access and credential issues
- **Data Collection Issues**: Telemetry and monitoring problems
- **Analytics Failures**: AI/ML processing errors
- **Performance Problems**: System slowdowns and bottlenecks
- **Integration Issues**: Third-party system connectivity

### 2. Systematic Troubleshooting Process

#### Step 1: Problem Identification
1. **Gather Symptoms**
   - Collect error messages and logs
   - Document when the issue started
   - Identify affected components/users
   - Note any recent changes

2. **Initial Assessment**
   - Check system status dashboards
   - Verify basic connectivity
   - Review recent alerts and notifications
   - Assess impact scope

#### Step 2: Data Collection
1. **Log Collection**
   ```bash
   # DNA Center log collection
   sudo tar -czf dna_logs_$(date +%Y%m%d_%H%M).tar.gz /var/log/maglev/
   
   # System logs
   journalctl --since "1 hour ago" > system_logs.txt
   
   # Network connectivity tests
   ping -c 5 <target_ip>
   traceroute <target_ip>
   telnet <target_ip> <port>
   ```

2. **Configuration Backup**
   ```bash
   # Export DNA Center configuration
   backup-config --output /tmp/dna_backup_$(date +%Y%m%d).tar.gz
   
   # Device configuration backup
   show running-config > device_config_backup.txt
   ```

#### Step 3: Root Cause Analysis
1. **Correlation Analysis**
   - Timeline correlation of events
   - Cross-reference multiple data sources
   - Identify patterns and anomalies

2. **Component Isolation**
   - Test individual components
   - Verify dependencies
   - Check integration points

## DNA Center Troubleshooting

### 1. Platform Issues

#### Problem: DNA Center Not Accessible
**Symptoms:**
- Web interface not loading
- API calls timing out
- SSH access failing

**Troubleshooting Steps:**
```bash
# Check DNA Center status
sudo maglev-config status

# Verify network connectivity
ping <dna_center_ip>
nslookup <dna_center_fqdn>

# Check service status
sudo systemctl status maglev-platform
sudo systemctl status maglev-ui

# Review system resources
top
df -h
free -h
```

**Common Solutions:**
1. **Service Restart**
   ```bash
   sudo systemctl restart maglev-platform
   sudo systemctl restart maglev-ui
   ```

2. **Certificate Issues**
   ```bash
   # Check certificate validity
   openssl x509 -in /opt/maglev/certificates/server.crt -text -noout
   
   # Regenerate certificates if expired
   sudo maglev-config certificate regenerate
   ```

3. **Storage Issues**
   ```bash
   # Clean up old logs
   sudo find /var/log/maglev -name "*.log" -mtime +7 -delete
   
   # Check disk space
   df -h /
   ```

#### Problem: Slow Performance
**Symptoms:**
- Web interface loading slowly
- API response times > 30 seconds
- Timeouts during operations

**Troubleshooting Steps:**
```bash
# Check system load
uptime
iostat -x 1 5

# Monitor database performance
sudo -u postgres psql -c "SELECT query, state, query_start FROM pg_stat_activity;"

# Check memory usage
ps aux --sort=-%mem | head -20
```

**Performance Optimization:**
```bash
# Adjust JVM heap size
sudo vi /opt/maglev/config/jvm.options
# Add: -Xmx16g -Xms16g

# Database maintenance
sudo -u postgres vacuumdb --all --analyze --verbose

# Clear browser cache and cookies
# Restart DNA Center services
sudo systemctl restart maglev-platform
```

### 2. Device Management Issues

#### Problem: Device Discovery Failures
**Symptoms:**
- Devices not appearing in inventory
- Discovery jobs failing
- SNMP or SSH timeouts

**Troubleshooting Steps:**
1. **Connectivity Verification**
   ```bash
   # Test SNMP connectivity
   snmpwalk -v2c -c <community> <device_ip> 1.3.6.1.2.1.1.1
   
   # Test SSH connectivity
   ssh <username>@<device_ip>
   
   # Test HTTPS (for RESTCONF)
   curl -k https://<device_ip>/restconf/data/ietf-interfaces:interfaces
   ```

2. **Credential Validation**
   - Verify SNMP community strings
   - Check SSH username/password
   - Validate privilege levels
   - Confirm credential templates

**Common Solutions:**
1. **SNMP Configuration**
   ```cisco
   ! On network device
   snmp-server community <community> RO
   snmp-server location <location>
   snmp-server contact <contact>
   ```

2. **SSH Configuration**
   ```cisco
   ! Enable SSH on device
   ip domain-name <domain>
   crypto key generate rsa modulus 2048
   ip ssh version 2
   line vty 0 15
    transport input ssh
    login local
   ```

#### Problem: Configuration Deployment Failures
**Symptoms:**
- Template deployment errors
- Configuration drift alerts
- Compliance failures

**Troubleshooting Steps:**
```bash
# Check deployment history
# In DNA Center UI: Provision > History

# Validate templates
# In DNA Center UI: Tools > Template Editor

# Check device reachability
ping <device_ip>
ssh <device_ip>
```

**Common Solutions:**
1. **Template Validation**
   - Verify template syntax
   - Check variable bindings
   - Test in lab environment

2. **Device Preparation**
   ```cisco
   ! Ensure device is ready for management
   archive
    log config
     logging enable
     notify syslog
   ```

### 3. Assurance and Analytics Issues

#### Problem: Missing Telemetry Data
**Symptoms:**
- No data in dashboards
- Missing device health metrics
- Empty analytics reports

**Troubleshooting Steps:**
1. **Telemetry Configuration Check**
   ```cisco
   ! Check streaming telemetry configuration
   show telemetry ietf subscription all
   show telemetry internal subscription all
   
   ! Verify collector configuration
   show run | include telemetry
   ```

2. **Data Flow Verification**
   ```bash
   # Check DNA Center telemetry receiver
   sudo netstat -ulnp | grep 57400
   
   # Monitor incoming data
   sudo tcpdump -i any port 57400
   
   # Check telemetry logs
   tail -f /var/log/maglev/telemetry/telemetry.log
   ```

**Common Solutions:**
1. **Enable Streaming Telemetry**
   ```cisco
   ! Configure streaming telemetry
   telemetry ietf subscription 1001
    encoding encode-kvgpb
    filter xpath "/interfaces-ios-xe-oper:interfaces/interface"
    stream yang-push
    update-policy periodic 6000
    receiver ip address <dna_center_ip> 57400 protocol grpc-tcp
   ```

2. **Firewall Configuration**
   ```bash
   # Allow telemetry ports
   sudo firewall-cmd --add-port=57400/tcp --permanent
   sudo firewall-cmd --reload
   ```

## Catalyst Center Troubleshooting

### 1. Cloud Connectivity Issues

#### Problem: Cannot Connect to Catalyst Center
**Symptoms:**
- Login failures to cloud service
- API authentication errors
- Connector registration failures

**Troubleshooting Steps:**
1. **Network Connectivity**
   ```bash
   # Test connectivity to Catalyst Center
   curl -I https://cloud.cisco.com
   nslookup cloud.cisco.com
   
   # Check proxy settings
   echo $http_proxy
   echo $https_proxy
   ```

2. **Authentication Verification**
   ```bash
   # Test API authentication
   curl -X POST "https://cloud.cisco.com/api/v1/auth/token" \
        -H "Content-Type: application/json" \
        -d '{"username":"<user>","password":"<pass>"}'
   ```

**Common Solutions:**
1. **Proxy Configuration**
   ```bash
   # Configure proxy settings
   export http_proxy=http://proxy.company.com:8080
   export https_proxy=https://proxy.company.com:8080
   export no_proxy=localhost,127.0.0.1,.company.com
   ```

2. **Certificate Trust**
   ```bash
   # Add certificates to trust store
   sudo cp company-ca.crt /usr/local/share/ca-certificates/
   sudo update-ca-certificates
   ```

#### Problem: Data Synchronization Issues
**Symptoms:**
- Stale data in dashboards
- Missing recent events
- Synchronization errors

**Troubleshooting Steps:**
```bash
# Check connector status
systemctl status catalyst-connector

# Review synchronization logs
tail -f /var/log/catalyst-connector/sync.log

# Verify data timestamps
cat /var/log/catalyst-connector/data.log | grep timestamp
```

**Common Solutions:**
1. **Restart Connector**
   ```bash
   sudo systemctl restart catalyst-connector
   sudo systemctl enable catalyst-connector
   ```

2. **Force Resynchronization**
   ```bash
   # Clear local cache
   rm -rf /var/cache/catalyst-connector/*
   
   # Restart with full sync
   sudo systemctl restart catalyst-connector
   ```

### 2. Analytics and Insights Issues

#### Problem: AI Insights Not Generated
**Symptoms:**
- Empty AI insights dashboard
- No anomaly detection alerts
- Missing predictive analytics

**Troubleshooting Steps:**
1. **Data Validation**
   - Verify sufficient historical data (minimum 7 days)
   - Check data quality and completeness
   - Validate baseline establishment

2. **Model Status Check**
   ```bash
   # Check AI model status (via API)
   curl -X GET "https://cloud.cisco.com/api/v1/ml/models/status" \
        -H "Authorization: Bearer <token>"
   ```

**Common Solutions:**
1. **Data Collection Improvement**
   - Increase telemetry frequency
   - Enable additional metrics collection
   - Verify device compatibility

2. **Model Retraining**
   - Allow sufficient learning period
   - Ensure diverse data patterns
   - Contact support for model refresh

## ThousandEyes Integration Troubleshooting

### 1. Agent Connectivity Issues

#### Problem: Enterprise Agents Not Reporting
**Symptoms:**
- Agents showing offline status
- Missing test data
- Connectivity alerts

**Troubleshooting Steps:**
1. **Agent Status Check**
   ```bash
   # Check agent service
   sudo systemctl status te-agent
   
   # Review agent logs
   tail -f /var/log/te-agent.log
   
   # Test internet connectivity
   curl https://app.thousandeyes.com/status
   ```

2. **Network Connectivity**
   ```bash
   # Check required ports
   telnet app.thousandeyes.com 443
   telnet app.thousandeyes.com 49153
   
   # DNS resolution test
   nslookup app.thousandeyes.com
   dig @8.8.8.8 app.thousandeyes.com
   ```

**Common Solutions:**
1. **Firewall Rules**
   ```bash
   # Allow required ports
   sudo firewall-cmd --add-port=443/tcp --permanent
   sudo firewall-cmd --add-port=49153/tcp --permanent
   sudo firewall-cmd --reload
   ```

2. **Agent Restart**
   ```bash
   sudo systemctl restart te-agent
   sudo systemctl enable te-agent
   ```

#### Problem: Test Configuration Issues
**Symptoms:**
- Tests not running
- Incomplete test results
- Error messages in test timeline

**Troubleshooting Steps:**
1. **Test Validation**
   - Verify target URLs/IPs are reachable
   - Check test interval settings
   - Validate agent assignments

2. **Manual Testing**
   ```bash
   # Test target reachability
   ping <target_ip>
   curl -I <target_url>
   traceroute <target_ip>
   ```

**Common Solutions:**
1. **Test Reconfiguration**
   - Adjust test parameters
   - Change agent assignments
   - Modify test intervals

2. **Target Validation**
   - Confirm target availability
   - Check firewall rules at target
   - Validate DNS resolution

### 2. Integration with DNA Center

#### Problem: Data Correlation Issues
**Symptoms:**
- Missing correlation between DNA Center and ThousandEyes data
- Inconsistent path trace results
- Integration alerts

**Troubleshooting Steps:**
1. **API Connectivity**
   ```bash
   # Test DNA Center API
   curl -k "https://<dna_center>/dna/intent/api/v1/network-health" \
        -H "Authorization: Bearer <token>"
   
   # Test ThousandEyes API
   curl "https://api.thousandeyes.com/v6/tests" \
        -u "<email>:<token>"
   ```

2. **Data Mapping Validation**
   - Verify device mapping between systems
   - Check timestamp synchronization
   - Validate data schema compatibility

**Common Solutions:**
1. **Reconfigure Integration**
   - Update API credentials
   - Refresh device mappings
   - Restart integration services

2. **Time Synchronization**
   ```bash
   # Ensure NTP synchronization
   sudo chrony sources -v
   sudo systemctl status chronyd
   ```

## AI/ML Analytics Troubleshooting

### 1. Model Performance Issues

#### Problem: Poor Anomaly Detection Accuracy
**Symptoms:**
- High false positive rates
- Missing actual anomalies
- Inconsistent detection results

**Troubleshooting Steps:**
1. **Data Quality Assessment**
   ```python
   # Check data completeness
   import pandas as pd
   df = pd.read_csv('telemetry_data.csv')
   print(df.isnull().sum())
   print(df.describe())
   ```

2. **Model Validation**
   ```python
   # Review model metrics
   from sklearn.metrics import precision_recall_fscore_support
   y_true = [...]  # actual labels
   y_pred = [...]  # predicted labels
   precision, recall, f1, support = precision_recall_fscore_support(y_true, y_pred)
   print(f"Precision: {precision}, Recall: {recall}, F1: {f1}")
   ```

**Common Solutions:**
1. **Data Preprocessing**
   - Clean and normalize data
   - Handle missing values
   - Remove outliers appropriately

2. **Model Retraining**
   - Collect more training data
   - Adjust model parameters
   - Implement ensemble methods

#### Problem: Slow Inference Performance
**Symptoms:**
- Long response times for predictions
- Timeouts during model inference
- High CPU/GPU utilization

**Troubleshooting Steps:**
1. **Resource Monitoring**
   ```bash
   # Monitor system resources
   htop
   nvidia-smi  # for GPU monitoring
   iostat -x 1 5
   ```

2. **Model Optimization**
   ```python
   # Profile model performance
   import cProfile
   import pstats
   
   profiler = cProfile.Profile()
   profiler.enable()
   # Run model inference
   profiler.disable()
   stats = pstats.Stats(profiler)
   stats.sort_stats('cumulative')
   stats.print_stats(10)
   ```

**Common Solutions:**
1. **Resource Scaling**
   - Increase CPU/memory allocation
   - Add GPU resources
   - Implement model caching

2. **Model Optimization**
   - Quantize model weights
   - Implement batch processing
   - Use model serving frameworks

### 2. Data Pipeline Issues

#### Problem: Data Ingestion Failures
**Symptoms:**
- Missing data in analytics pipeline
- Data processing errors
- Pipeline backlog accumulation

**Troubleshooting Steps:**
1. **Pipeline Status Check**
   ```bash
   # Check Kafka consumer lag
   kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
                           --describe --group analytics-group
   
   # Monitor data processing rates
   tail -f /var/log/analytics/pipeline.log | grep "processed"
   ```

2. **Data Validation**
   ```python
   # Validate incoming data format
   import json
   with open('sample_data.json', 'r') as f:
       data = json.load(f)
       # Validate schema
       validate_schema(data, expected_schema)
   ```

**Common Solutions:**
1. **Pipeline Restart**
   ```bash
   # Restart data processing services
   sudo systemctl restart kafka
   sudo systemctl restart analytics-pipeline
   ```

2. **Data Format Correction**
   - Fix data schema issues
   - Implement data validation
   - Add error handling

## Network Infrastructure Troubleshooting

### 1. Device Connectivity Issues

#### Problem: Network Device Not Responding
**Symptoms:**
- SNMP timeouts
- SSH connection failures
- Device appears offline

**Troubleshooting Steps:**
1. **Basic Connectivity**
   ```bash
   # Test Layer 3 connectivity
   ping <device_ip>
   traceroute <device_ip>
   
   # Test specific services
   telnet <device_ip> 22   # SSH
   telnet <device_ip> 161  # SNMP
   ```

2. **Device Status Check**
   ```cisco
   ! On console/local access
   show version
   show interfaces summary
   show ip route
   show ip interface brief
   ```

**Common Solutions:**
1. **Interface Issues**
   ```cisco
   ! Reset interface
   interface <interface>
    shutdown
    no shutdown
   ```

2. **Routing Problems**
   ```cisco
   ! Check routing table
   show ip route <management_network>
   
   ! Add static route if needed
   ip route <mgmt_network> <netmask> <gateway>
   ```

#### Problem: High CPU/Memory Utilization
**Symptoms:**
- Slow device response
- Dropped packets
- Service interruptions

**Troubleshooting Steps:**
```cisco
! Monitor resource utilization
show processes cpu sorted
show processes memory sorted
show memory statistics

! Check for resource-intensive processes
show processes cpu history
show platform hardware throughput level
```

**Common Solutions:**
1. **Process Management**
   ```cisco
   ! Identify and restart problematic processes
   show processes cpu sorted | include <process_name>
   
   ! Adjust process priorities if needed
   process cpu threshold type <type> rising <value> falling <value>
   ```

2. **Configuration Optimization**
   ```cisco
   ! Reduce logging verbosity
   no logging console
   logging buffered 4096 warnings
   
   ! Optimize SNMP polling
   snmp-server enable traps
   ```

### 2. Performance Issues

#### Problem: Network Congestion
**Symptoms:**
- High interface utilization
- Increased latency
- Packet loss

**Troubleshooting Steps:**
```cisco
! Check interface statistics
show interface <interface>
show interface <interface> counters
show interface <interface> counters errors

! Monitor traffic patterns
show ip cache flow
show ip flow top-talkers
```

**Common Solutions:**
1. **QoS Implementation**
   ```cisco
   ! Configure traffic shaping
   policy-map SHAPE-100M
    class class-default
     shape average 100000000
   
   interface <interface>
    service-policy output SHAPE-100M
   ```

2. **Load Balancing**
   ```cisco
   ! Configure ECMP
   ip route <destination> <mask> <nexthop1>
   ip route <destination> <mask> <nexthop2>
   ```

## Integration Troubleshooting

### 1. API Integration Issues

#### Problem: API Authentication Failures
**Symptoms:**
- 401 Unauthorized errors
- Token expiration errors
- Authentication timeouts

**Troubleshooting Steps:**
```bash
# Test API authentication
curl -X POST "https://<api_endpoint>/auth" \
     -H "Content-Type: application/json" \
     -d '{"username":"<user>","password":"<pass>"}' \
     -v

# Check token validity
curl -X GET "https://<api_endpoint>/status" \
     -H "Authorization: Bearer <token>" \
     -v
```

**Common Solutions:**
1. **Credential Refresh**
   - Regenerate API tokens
   - Update stored credentials
   - Verify user permissions

2. **Authentication Flow Fix**
   ```python
   # Implement token refresh logic
   import requests
   
   def refresh_token():
       response = requests.post(auth_url, json=credentials)
       return response.json()['token']
   ```

#### Problem: API Rate Limiting
**Symptoms:**
- 429 Too Many Requests errors
- Delayed responses
- Throttling warnings

**Troubleshooting Steps:**
```bash
# Check rate limit headers
curl -I "https://<api_endpoint>/data" \
     -H "Authorization: Bearer <token>"

# Monitor request patterns
tail -f /var/log/api-client.log | grep "rate-limit"
```

**Common Solutions:**
1. **Request Throttling**
   ```python
   import time
   from requests.adapters import HTTPAdapter
   from urllib3.util.retry import Retry
   
   # Implement backoff strategy
   retry_strategy = Retry(
       total=3,
       backoff_factor=1,
       status_forcelist=[429, 500, 502, 503, 504]
   )
   ```

2. **Batch Processing**
   - Combine multiple requests
   - Implement request queuing
   - Use bulk API endpoints

### 2. Data Integration Issues

#### Problem: Data Synchronization Failures
**Symptoms:**
- Stale data across systems
- Data inconsistencies
- Synchronization errors

**Troubleshooting Steps:**
1. **Data Flow Validation**
   ```bash
   # Check data timestamps
   grep "timestamp" /var/log/integration.log | tail -10
   
   # Verify data volumes
   wc -l /data/exports/*.json
   ```

2. **Schema Validation**
   ```python
   # Validate data schema
   import jsonschema
   
   with open('data_schema.json', 'r') as f:
       schema = json.load(f)
   
   jsonschema.validate(data, schema)
   ```

**Common Solutions:**
1. **Data Mapping Fixes**
   - Update field mappings
   - Handle schema changes
   - Implement data transformation

2. **Synchronization Restart**
   ```bash
   # Reset synchronization state
   rm -f /var/lib/integration/sync_state.json
   sudo systemctl restart integration-service
   ```

## Escalation Procedures

### 1. Internal Escalation

#### Level 1: Network Operations Team
- Initial troubleshooting and triage
- Basic connectivity and configuration checks
- Log collection and preliminary analysis

#### Level 2: Network Engineering Team
- Advanced troubleshooting and root cause analysis
- Configuration changes and optimizations
- Integration with external systems

#### Level 3: Architecture and Vendor Support
- Complex technical issues requiring vendor support
- Architecture design changes
- Software bugs and feature requests

### 2. Vendor Escalation

#### Cisco Technical Assistance Center (TAC)
```bash
# Collect diagnostic information for TAC case
show tech-support > tech_support_$(date +%Y%m%d).txt
show logging > device_logs_$(date +%Y%m%d).txt

# DNA Center diagnostics
sudo maglev-config support-bundle
```

#### Case Information Requirements
- Problem description and symptoms
- Error messages and logs
- Network topology and device information
- Configuration files and recent changes
- Impact assessment and business priority

### 3. Emergency Procedures

#### Critical System Failures
1. **Immediate Actions**
   - Activate incident response team
   - Implement emergency communication procedures
   - Execute emergency rollback if applicable

2. **Escalation Contacts**
   ```
   Role                    Primary Contact         Backup Contact
   Network Operations     NOC Manager             Senior Engineer
   Vendor Support         TAC Priority Queue      Account SE
   Business Stakeholders  IT Director            CIO Office
   ```

## Documentation and Knowledge Base

### 1. Troubleshooting Logs

#### Issue Tracking
- Document all troubleshooting steps
- Record root causes and solutions
- Update knowledge base articles
- Share lessons learned with team

#### Log Management
```bash
# Centralized logging configuration
rsyslog configuration for DNA Center:
*.* @@<log_server>:514

# Log rotation and retention
logrotate configuration:
/var/log/troubleshooting/*.log {
    daily
    rotate 30
    compress
    missingok
    notifempty
}
```

### 2. Knowledge Base Maintenance

#### Regular Updates
- Review and update troubleshooting procedures
- Add new known issues and solutions
- Validate existing procedures
- Archive obsolete information

#### Team Training
- Regular troubleshooting workshops
- New team member onboarding
- Vendor training and certification
- Cross-team knowledge sharing

---

**Version**: 1.0  
**Last Updated**: 2025-01-27  
**Document Owner**: Cisco AI Network Analytics Operations Team  
**Review Cycle**: Monthly  
**Emergency Contact**: NOC Hotline +1-555-NET-HELP
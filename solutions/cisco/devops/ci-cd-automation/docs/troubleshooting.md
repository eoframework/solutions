# Cisco CI/CD Automation Troubleshooting Guide

## Table of Contents

1. [Overview](#overview)
2. [General Troubleshooting Methodology](#general-troubleshooting-methodology)
3. [Platform-Specific Issues](#platform-specific-issues)
4. [Network Connectivity Issues](#network-connectivity-issues)
5. [Authentication and Authorization Problems](#authentication-and-authorization-problems)
6. [Configuration and Deployment Issues](#configuration-and-deployment-issues)
7. [Performance and Scalability Problems](#performance-and-scalability-problems)
8. [Integration and API Issues](#integration-and-api-issues)
9. [Monitoring and Alerting Problems](#monitoring-and-alerting-problems)
10. [Emergency Recovery Procedures](#emergency-recovery-procedures)

## Overview

This troubleshooting guide provides systematic approaches to identify, diagnose, and resolve common issues encountered in the Cisco CI/CD automation solution. It includes step-by-step troubleshooting procedures, diagnostic commands, and recovery solutions.

### Troubleshooting Principles

1. **Systematic Approach**: Follow a structured methodology to isolate issues
2. **Documentation**: Record all symptoms, steps taken, and solutions
3. **Root Cause Analysis**: Identify underlying causes, not just symptoms
4. **Prevention**: Implement measures to prevent issue recurrence
5. **Knowledge Sharing**: Update documentation and share learnings

### Issue Severity Levels

| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| **Critical (P1)** | Complete system outage | 15 minutes | Total automation platform failure |
| **High (P2)** | Major functionality impacted | 1 hour | Multiple devices unreachable |
| **Medium (P3)** | Limited functionality affected | 4 hours | Single device configuration issues |
| **Low (P4)** | Minor issues or cosmetic problems | Next business day | Dashboard display issues |

## General Troubleshooting Methodology

### Step 1: Issue Identification and Scope
1. **Gather Symptoms**: Collect all available error messages and symptoms
2. **Determine Scope**: Identify affected components and users
3. **Check Recent Changes**: Review recent deployments or configuration changes
4. **Verify Monitoring**: Check monitoring dashboards for additional context

### Step 2: Initial Assessment
```bash
# Quick health check script
#!/bin/bash
echo "=== System Health Check ==="

# Check system resources
echo "CPU and Memory Usage:"
top -b -n 1 | head -10

echo -e "\nDisk Usage:"
df -h

echo -e "\nNetwork Connectivity:"
ping -c 3 8.8.8.8

# Check core services
echo -e "\nCore Services Status:"
systemctl status automation-controller
systemctl status postgresql
systemctl status nginx

# Check log files for recent errors
echo -e "\nRecent Errors in Logs:"
journalctl -u automation-controller --since "1 hour ago" | grep -i error | tail -10
```

### Step 3: Systematic Diagnosis
1. **Layer by Layer**: Check from infrastructure up to application layer
2. **Component Isolation**: Test individual components in isolation
3. **Log Analysis**: Examine logs for error patterns and timing
4. **Network Validation**: Verify network connectivity and DNS resolution

### Step 4: Solution Implementation
1. **Test Solutions**: Validate fixes in test environment first
2. **Implement Gradually**: Apply fixes incrementally where possible
3. **Monitor Impact**: Watch for unintended consequences
4. **Document Resolution**: Record the solution for future reference

## Platform-Specific Issues

### Cisco DNA Center Issues

#### Issue: DNA Center Web Interface Unavailable
**Symptoms:**
- Unable to access DNA Center web interface
- HTTP 503 or connection timeout errors
- Login page not loading

**Diagnostic Steps:**
```bash
# Check DNA Center services status
ssh maglev@dnac-server
sudo maglev-config status

# Check system resources
top -b -n 1
free -h
df -h

# Check network connectivity
netstat -tuln | grep :443
ss -tuln | grep :443

# Check firewall status
sudo iptables -L -n
```

**Common Solutions:**
1. **Service Restart:**
   ```bash
   ssh maglev@dnac-server
   sudo maglev-config restart
   ```

2. **Clear Browser Cache:**
   - Clear browser cache and cookies
   - Try incognito/private browsing mode
   - Test with different browser

3. **Certificate Issues:**
   ```bash
   # Check certificate validity
   echo | openssl s_client -connect dnac-server:443 2>/dev/null | openssl x509 -noout -dates
   
   # Regenerate self-signed certificate if needed
   sudo maglev-config certificate regenerate
   ```

#### Issue: Device Discovery Failures
**Symptoms:**
- Devices not appearing in inventory
- Discovery jobs failing or timing out
- "Unreachable" status for known devices

**Diagnostic Steps:**
```bash
# Test basic connectivity
ping device-ip
telnet device-ip 22
telnet device-ip 443

# Check SNMP connectivity
snmpwalk -v2c -c public device-ip 1.3.6.1.2.1.1.1.0

# Verify credentials
ssh username@device-ip "show version"
```

**Common Solutions:**
1. **Credential Verification:**
   - Verify username/password in DNA Center
   - Check SNMP community strings
   - Ensure privilege level 15 access

2. **Network Connectivity:**
   - Verify IP reachability
   - Check firewall rules
   - Validate VLAN configuration

3. **Device Configuration:**
   ```ios
   ! Enable required services on device
   ip http server
   ip http secure-server
   snmp-server community public RO
   ```

### NSO (Network Services Orchestrator) Issues

#### Issue: NSO Service Not Starting
**Symptoms:**
- NSO fails to start or crashes immediately
- "Connection refused" errors when connecting to NSO
- Database corruption errors

**Diagnostic Steps:**
```bash
# Check NSO status
ncs --status

# Check NSO logs
tail -f $NCS_RUN_DIR/logs/ncs.log
tail -f $NCS_RUN_DIR/logs/devel.log

# Check database integrity
ncs --check-cdb

# Verify file permissions
ls -la $NCS_RUN_DIR/
```

**Common Solutions:**
1. **Database Repair:**
   ```bash
   # Stop NSO
   ncs --stop
   
   # Backup current database
   cp -r $NCS_RUN_DIR/cdb $NCS_RUN_DIR/cdb.backup
   
   # Repair database
   ncs --compact-cdb
   
   # Start NSO
   ncs
   ```

2. **Configuration Issues:**
   ```bash
   # Validate NSO configuration
   ncs_conf_tool --check-config
   
   # Reset to default configuration if needed
   ncs-setup --reset
   ```

### Ansible Automation Platform Issues

#### Issue: Job Execution Failures
**Symptoms:**
- Ansible jobs failing with timeout errors
- "Host unreachable" errors
- Jobs stuck in "running" status

**Diagnostic Steps:**
```bash
# Check job status
awx-cli job list --status failed --format json

# View job details
awx-cli job get JOB_ID --format json

# Check execution environment
ansible --version
python3 --version

# Test inventory connectivity
ansible all -m ping -i inventory.yml
```

**Common Solutions:**
1. **Inventory Issues:**
   ```bash
   # Validate inventory syntax
   ansible-inventory --list -i inventory.yml
   
   # Test specific host connectivity
   ansible target_host -m ping -i inventory.yml -vvv
   ```

2. **SSH Connectivity:**
   ```bash
   # Test SSH connection
   ssh -i ~/.ssh/id_rsa username@target_host
   
   # Update SSH known hosts
   ssh-keyscan target_host >> ~/.ssh/known_hosts
   ```

3. **Playbook Debugging:**
   ```bash
   # Run playbook with verbose output
   ansible-playbook -i inventory.yml playbook.yml -vvv
   
   # Syntax check
   ansible-playbook --syntax-check playbook.yml
   ```

#### Issue: High Memory Usage
**Symptoms:**
- System becomes unresponsive
- Out of memory errors in logs
- Job execution becomes slow

**Diagnostic Steps:**
```bash
# Check memory usage
free -h
top -b -n 1 | head -20

# Check Ansible processes
ps aux | grep ansible | head -10

# Check system limits
ulimit -a

# Monitor memory usage over time
watch -n 5 'free -h && echo "---" && ps aux --sort=-%mem | head -10'
```

**Common Solutions:**
1. **Memory Configuration:**
   ```ini
   # /etc/tower/settings.py
   SYSTEM_TASK_ABS_MEM = 2048  # Increase memory allocation
   AWX_TASK_MAX_WORKERS = 10   # Reduce concurrent workers
   ```

2. **Playbook Optimization:**
   ```yaml
   # Reduce memory usage in playbooks
   - name: Example task
     module_name:
       parameter: value
     throttle: 5  # Limit concurrent connections
   ```

## Network Connectivity Issues

### DNS Resolution Problems

#### Issue: Hostname Resolution Failures
**Symptoms:**
- "Name or service not known" errors
- Intermittent connectivity issues
- Slow response times

**Diagnostic Steps:**
```bash
# Test DNS resolution
nslookup hostname
dig hostname
host hostname

# Check DNS configuration
cat /etc/resolv.conf

# Test with different DNS servers
nslookup hostname 8.8.8.8
```

**Common Solutions:**
1. **DNS Configuration:**
   ```bash
   # Update DNS servers
   echo "nameserver 8.8.8.8" >> /etc/resolv.conf
   echo "nameserver 8.8.4.4" >> /etc/resolv.conf
   
   # Restart networking service
   systemctl restart NetworkManager
   ```

2. **Hosts File Entries:**
   ```bash
   # Add temporary entries to /etc/hosts
   echo "192.168.1.10 device01.company.com device01" >> /etc/hosts
   ```

### Firewall and ACL Issues

#### Issue: Connection Timeouts to Network Devices
**Symptoms:**
- SSH connections timing out
- HTTPS/API requests failing
- SNMP queries not responding

**Diagnostic Steps:**
```bash
# Test specific ports
telnet device-ip 22
telnet device-ip 443
telnet device-ip 161

# Check local firewall
sudo iptables -L -n
sudo firewall-cmd --list-all

# Traceroute to identify where packets are dropped
traceroute device-ip
```

**Common Solutions:**
1. **Firewall Rules:**
   ```bash
   # Allow SSH traffic
   sudo firewall-cmd --add-service=ssh --permanent
   
   # Allow HTTPS traffic  
   sudo firewall-cmd --add-service=https --permanent
   
   # Allow custom ports
   sudo firewall-cmd --add-port=830/tcp --permanent  # NETCONF
   sudo firewall-cmd --reload
   ```

2. **Device ACL Configuration:**
   ```ios
   ! Configure ACL on network device
   ip access-list extended MGMT-ACCESS
    permit tcp 10.10.0.0 0.0.0.255 any eq ssh
    permit tcp 10.10.0.0 0.0.0.255 any eq 443
    permit udp 10.10.0.0 0.0.0.255 any eq snmp
   
   interface Management0/0
    ip access-group MGMT-ACCESS in
   ```

## Authentication and Authorization Problems

### SSH Key Authentication Issues

#### Issue: SSH Public Key Authentication Failing
**Symptoms:**
- SSH connections falling back to password authentication
- "Permission denied (publickey)" errors
- Ansible unable to connect to devices

**Diagnostic Steps:**
```bash
# Test SSH connection with verbose output
ssh -vvv username@hostname

# Check SSH key permissions
ls -la ~/.ssh/
stat ~/.ssh/id_rsa
stat ~/.ssh/id_rsa.pub

# Verify key is loaded in SSH agent
ssh-add -l

# Test key format
ssh-keygen -lf ~/.ssh/id_rsa.pub
```

**Common Solutions:**
1. **Fix Key Permissions:**
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   chmod 644 ~/.ssh/authorized_keys
   ```

2. **Deploy Public Key:**
   ```bash
   # Copy public key to remote host
   ssh-copy-id username@hostname
   
   # Or manually append key
   cat ~/.ssh/id_rsa.pub | ssh username@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
   ```

3. **Device Configuration:**
   ```ios
   ! Enable SSH public key authentication on Cisco devices
   ip ssh pubkey-chain
    username automation
     key-string
      [paste public key here]
   ```

### RBAC and Permissions Issues

#### Issue: Access Denied Errors in Automation Platform
**Symptoms:**
- Users unable to access certain features
- API calls returning 403 Forbidden errors
- Job templates not visible to users

**Diagnostic Steps:**
```bash
# Check user permissions
awx-cli user get username --format json

# List user's roles
awx-cli role list --user username

# Check object permissions
awx-cli credential list --user username
```

**Common Solutions:**
1. **Assign Appropriate Roles:**
   ```bash
   # Grant organization admin role
   awx-cli role grant --user username --organization "Default" --role admin
   
   # Grant project admin role
   awx-cli role grant --user username --project "Network Automation" --role admin
   ```

2. **Create Custom Roles:**
   ```python
   # Custom role creation script
   from awx.main.models import Role, User, Organization
   
   org = Organization.objects.get(name='Default')
   user = User.objects.get(username='network_operator')
   
   # Create custom role with specific permissions
   role = Role.objects.create(
       name='Network Operator',
       description='Limited network operations access'
   )
   
   # Assign role to user
   user.roles.add(role)
   ```

## Configuration and Deployment Issues

### Template Rendering Problems

#### Issue: Jinja2 Template Errors
**Symptoms:**
- "TemplateSyntaxError" in job logs
- Variables not rendering correctly
- Missing or incorrect configuration output

**Diagnostic Steps:**
```bash
# Test template rendering manually
python3 -c "
from jinja2 import Template
template = Template(open('template.j2').read())
variables = {'hostname': 'test', 'ip': '192.168.1.1'}
print(template.render(variables))
"

# Check variable definitions
ansible-inventory --host hostname --vars

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('variables.yml'))"
```

**Common Solutions:**
1. **Fix Template Syntax:**
   ```jinja2
   {# Correct variable reference #}
   hostname {{ inventory_hostname }}
   
   {# Handle undefined variables #}
   {% if dns_servers is defined %}
   {% for server in dns_servers %}
   ip name-server {{ server }}
   {% endfor %}
   {% endif %}
   
   {# Default values for variables #}
   ntp server {{ ntp_server | default('pool.ntp.org') }}
   ```

2. **Variable Debugging:**
   ```yaml
   # Add debug task to playbook
   - name: Debug variables
     debug:
       var: hostvars[inventory_hostname]
   ```

### Device Configuration Deployment Issues

#### Issue: Configuration Changes Not Applied
**Symptoms:**
- Ansible reports "changed" but configuration not on device
- Device shows different configuration than intended
- Rollback occurring immediately after deployment

**Diagnostic Steps:**
```bash
# Run playbook in check mode
ansible-playbook -i inventory.yml playbook.yml --check --diff

# Enable Ansible connection debugging
ANSIBLE_DEBUG=1 ansible-playbook -i inventory.yml playbook.yml -vvv

# Check device configuration directly
ssh username@device "show running-config"
```

**Common Solutions:**
1. **Configuration Module Issues:**
   ```yaml
   # Use appropriate configuration module parameters
   - name: Configure interface
     cisco.ios.ios_config:
       lines:
         - description "Configured by Ansible"
         - ip address {{ ip_address }} {{ netmask }}
       parents: interface {{ interface_name }}
       match: exact  # Ensure exact matching
       replace: block  # Replace entire block
       backup: yes
   ```

2. **Configuration Save Issues:**
   ```yaml
   # Ensure configuration is saved
   - name: Save configuration
     cisco.ios.ios_config:
       save_when: modified
   ```

### Rollback and Recovery Problems

#### Issue: Automatic Rollback Not Working
**Symptoms:**
- Failed configurations remain on devices
- Rollback timers not functioning
- Manual intervention required for recovery

**Diagnostic Steps:**
```bash
# Check rollback configuration on device
ssh username@device "show archive"
ssh username@device "show configuration commit list"

# Verify rollback timer settings
ssh username@device "show running-config | include archive"
```

**Common Solutions:**
1. **Configure Archive Settings:**
   ```ios
   ! Configure automatic rollback
   archive
    path bootflash:config-archive
    maximum 10
    time-period 10080
   
   ! Enable rollback timer for configuration changes
   configure replace bootflash:config-archive time 10 force
   ```

2. **Implement Ansible Rollback:**
   ```yaml
   - name: Apply configuration with rollback
     cisco.ios.ios_config:
       lines: "{{ configuration_lines }}"
       replace: config
       backup: yes
     register: config_result
     
   - name: Validate configuration
     cisco.ios.ios_command:
       commands:
         - "ping {{ test_ip }}"
     register: validation
     failed_when: "'Success rate is 0' in validation.stdout[0]"
     
   - name: Rollback on failure
     cisco.ios.ios_config:
       src: "{{ backup_path }}"
       replace: config
     when: validation.failed
   ```

## Performance and Scalability Problems

### High CPU and Memory Usage

#### Issue: System Performance Degradation
**Symptoms:**
- Slow response times for web interface
- Job execution taking longer than usual
- System becoming unresponsive

**Diagnostic Steps:**
```bash
# Monitor system resources
top -b -n 1 | head -20
htop  # If available
iotop  # Monitor disk I/O

# Check specific processes
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

# Monitor over time
sar -u 1 10  # CPU usage
sar -r 1 10  # Memory usage
sar -b 1 10  # I/O usage
```

**Common Solutions:**
1. **Optimize Ansible Configuration:**
   ```ini
   # /etc/ansible/ansible.cfg
   [defaults]
   forks = 25  # Adjust based on system capacity
   gathering = smart
   fact_caching = jsonfile
   fact_caching_connection = /tmp/ansible_fact_cache
   fact_caching_timeout = 86400
   
   [ssh_connection]
   ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s
   pipelining = True
   ```

2. **Database Optimization:**
   ```sql
   -- PostgreSQL optimization
   ALTER SYSTEM SET shared_buffers = '256MB';
   ALTER SYSTEM SET effective_cache_size = '1GB';
   ALTER SYSTEM SET work_mem = '8MB';
   SELECT pg_reload_conf();
   
   -- Clean up old data
   DELETE FROM main_job WHERE created < NOW() - INTERVAL '30 days';
   VACUUM ANALYZE;
   ```

### Database Performance Issues

#### Issue: Slow Database Queries
**Symptoms:**
- Web interface loading slowly
- Job status updates delayed
- Database connection timeouts

**Diagnostic Steps:**
```sql
-- Check active connections
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Check slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- Check database size
SELECT pg_size_pretty(pg_database_size('awx'));

-- Check table sizes
SELECT schemaname,tablename,attname,n_distinct,correlation 
FROM pg_stats 
WHERE schemaname = 'public' 
ORDER BY n_distinct DESC;
```

**Common Solutions:**
1. **Add Database Indexes:**
   ```sql
   -- Common indexes for AWX
   CREATE INDEX CONCURRENTLY idx_main_job_status ON main_job(status);
   CREATE INDEX CONCURRENTLY idx_main_job_created ON main_job(created);
   CREATE INDEX CONCURRENTLY idx_main_jobevent_job ON main_jobevent(job_id);
   ```

2. **Implement Database Maintenance:**
   ```bash
   #!/bin/bash
   # Daily database maintenance script
   sudo -u postgres psql awx << EOF
   VACUUM ANALYZE;
   REINDEX DATABASE awx;
   EOF
   ```

## Integration and API Issues

### API Authentication Problems

#### Issue: API Calls Returning Authentication Errors
**Symptoms:**
- HTTP 401 Unauthorized responses
- "Invalid token" error messages
- API calls working intermittently

**Diagnostic Steps:**
```bash
# Test API authentication
curl -k -H "Authorization: Bearer $TOKEN" https://server/api/v2/ping/

# Check token validity
python3 -c "
import jwt
token = 'your_token_here'
print(jwt.decode(token, options={'verify_signature': False}))
"

# Test with basic authentication
curl -k -u username:password https://server/api/v2/me/
```

**Common Solutions:**
1. **Token Refresh:**
   ```python
   # Python example for token refresh
   import requests
   
   def refresh_token(refresh_token, server_url):
       response = requests.post(
           f"{server_url}/api/v2/tokens/",
           json={'refresh_token': refresh_token}
       )
       if response.status_code == 200:
           return response.json()['access_token']
       else:
           raise Exception(f"Token refresh failed: {response.text}")
   ```

2. **Certificate Issues:**
   ```bash
   # Check API certificate
   echo | openssl s_client -connect server:443 2>/dev/null | openssl x509 -noout -dates
   
   # Add certificate to trusted store
   echo -n | openssl s_client -connect server:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > server.crt
   sudo cp server.crt /etc/ssl/certs/
   sudo update-ca-certificates
   ```

### Webhook and Event Issues

#### Issue: Webhooks Not Triggering Automation
**Symptoms:**
- Expected automation not running after events
- Webhook endpoint returning errors
- Events not appearing in logs

**Diagnostic Steps:**
```bash
# Check webhook configuration
curl -X GET https://automation-server/api/v2/workflow_job_templates/1/webhook_key/

# Test webhook manually
curl -X POST https://automation-server/api/v2/job_templates/1/github/ \
  -H "Content-Type: application/json" \
  -d '{"ref": "refs/heads/main"}'

# Check webhook logs
tail -f /var/log/tower/tower.log | grep webhook
```

**Common Solutions:**
1. **Webhook Configuration:**
   ```python
   # Configure webhook in GitLab/GitHub
   webhook_config = {
       'url': 'https://automation-server/api/v2/job_templates/1/github/',
       'content_type': 'application/json',
       'secret': 'your_webhook_secret',
       'events': ['push', 'pull_request']
   }
   ```

2. **Firewall and Access:**
   ```bash
   # Allow webhook traffic
   sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="github_ip_range" port protocol="tcp" port="443" accept' --permanent
   sudo firewall-cmd --reload
   ```

## Monitoring and Alerting Problems

### Missing Metrics and Dashboards

#### Issue: Monitoring Data Not Displaying
**Symptoms:**
- Grafana dashboards showing "No data"
- Prometheus targets showing as "Down"
- Metrics not being collected

**Diagnostic Steps:**
```bash
# Check Prometheus targets
curl http://prometheus:9090/api/v1/targets

# Test metric collection
curl http://prometheus:9090/api/v1/query?query=up

# Check Prometheus configuration
promtool check config /etc/prometheus/prometheus.yml

# Check exporters
curl http://exporter:9100/metrics
```

**Common Solutions:**
1. **Exporter Configuration:**
   ```yaml
   # prometheus.yml
   scrape_configs:
     - job_name: 'network-devices'
       static_configs:
         - targets: ['device1:9100', 'device2:9100']
       scrape_interval: 30s
       metrics_path: /metrics
   ```

2. **Firewall and Network Access:**
   ```bash
   # Test connectivity to metrics endpoints
   telnet prometheus 9090
   telnet exporter 9100
   
   # Check firewall rules
   sudo netstat -tuln | grep :9100
   ```

### Alert Notification Issues

#### Issue: Alerts Not Being Sent
**Symptoms:**
- Alert conditions met but no notifications received
- AlertManager showing alerts but not firing
- Email/Slack notifications not working

**Diagnostic Steps:**
```bash
# Check AlertManager status
curl http://alertmanager:9093/api/v1/status

# Check alert rules
promtool check rules /etc/prometheus/rules/*.yml

# Test notification channels
curl -X POST http://alertmanager:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{"labels":{"alertname":"test"}}]'
```

**Common Solutions:**
1. **AlertManager Configuration:**
   ```yaml
   # alertmanager.yml
   route:
     group_by: ['alertname']
     group_wait: 10s
     group_interval: 10s
     repeat_interval: 1h
     receiver: 'web.hook'
   
   receivers:
   - name: 'web.hook'
     email_configs:
     - to: 'admin@company.com'
       from: 'alerts@company.com'
       smarthost: 'smtp.company.com:587'
       auth_username: 'alerts@company.com'
       auth_password: 'password'
   ```

2. **SMTP Configuration:**
   ```bash
   # Test SMTP connectivity
   telnet smtp.company.com 587
   
   # Test email sending
   echo "Test message" | mail -s "Test Alert" admin@company.com
   ```

## Emergency Recovery Procedures

### Complete System Recovery

#### Scenario: Total Automation Platform Failure
**Recovery Steps:**

1. **Assess Damage:**
   ```bash
   # Check what services are running
   systemctl list-units --failed
   
   # Check filesystem integrity
   sudo fsck /dev/sda1
   
   # Check available backups
   ls -la /backups/ | tail -10
   ```

2. **Restore from Backup:**
   ```bash
   # Stop all services
   systemctl stop automation-controller
   systemctl stop postgresql
   systemctl stop nginx
   
   # Restore database
   sudo -u postgres pg_restore -d awx /backups/latest/awx_backup.sql
   
   # Restore application files
   tar -xzf /backups/latest/tower_backup.tar.gz -C /
   
   # Start services
   systemctl start postgresql
   systemctl start automation-controller
   systemctl start nginx
   ```

3. **Verify Recovery:**
   ```bash
   # Check service status
   systemctl status automation-controller
   
   # Test API access
   curl -k https://localhost/api/v2/ping/
   
   # Run basic smoke tests
   ansible all -m ping -i /etc/tower/inventory
   ```

### Network Device Recovery

#### Scenario: Mass Device Configuration Failure
**Recovery Steps:**

1. **Identify Affected Devices:**
   ```bash
   # Check device connectivity
   ansible all -m ping --one-line | grep UNREACHABLE
   
   # Generate device status report
   ansible-playbook playbooks/device-status-check.yml
   ```

2. **Restore Device Configurations:**
   ```bash
   # Restore from last known good backup
   ansible-playbook playbooks/restore-from-backup.yml \
     --extra-vars "backup_date=$(date -d '1 day ago' +%Y%m%d)"
   ```

3. **Validate Recovery:**
   ```bash
   # Run validation playbook
   ansible-playbook playbooks/post-recovery-validation.yml
   
   # Generate recovery report
   ansible-playbook playbooks/generate-recovery-report.yml
   ```

### Data Recovery Procedures

#### Database Corruption Recovery
```bash
# 1. Stop all services accessing the database
systemctl stop automation-controller

# 2. Create emergency backup
sudo -u postgres pg_dump awx > /tmp/emergency_backup.sql

# 3. Check database integrity
sudo -u postgres pg_dump --schema-only awx > /tmp/schema_check.sql

# 4. Restore from latest backup
sudo -u postgres dropdb awx
sudo -u postgres createdb awx
sudo -u postgres pg_restore -d awx /backups/latest/awx_backup.sql

# 5. Start services
systemctl start automation-controller

# 6. Verify functionality
curl -k https://localhost/api/v2/ping/
```

### Communication Procedures

#### Emergency Contact List
- **Network Operations Center**: +1-555-NOC-HELP (24/7)
- **System Administrator**: admin@company.com
- **Database Administrator**: dba@company.com  
- **Security Team**: security@company.com
- **Management Escalation**: ops-manager@company.com

#### Status Communication Template
```
INCIDENT: [Brief Description]
START TIME: [Timestamp]
IMPACT: [Affected Services/Users]
STATUS: [In Progress/Resolved/Under Investigation]
ETA: [Expected Resolution Time]
NEXT UPDATE: [When next update will be provided]

CURRENT ACTIONS:
- [Action 1]
- [Action 2]

CONTACT: [Primary Contact for Updates]
```

---

## Troubleshooting Tools and Commands

### Essential Commands
```bash
# System monitoring
top, htop, iotop
free -h
df -h
netstat -tuln
ss -tuln

# Network debugging
ping, traceroute, mtr
nslookup, dig, host
curl, wget
tcpdump, wireshark

# Service management
systemctl status service_name
journalctl -u service_name -f
systemctl restart service_name

# Log analysis
tail -f /var/log/messages
grep -r "error" /var/log/
journalctl --since "1 hour ago" | grep error
```

### Useful Scripts
See the `/scripts/` directory for comprehensive troubleshooting utilities and diagnostic tools.

---

**Document Version:** 1.0  
**Last Updated:** [Date]  
**Review Schedule:** Monthly  
**Emergency Contacts**: Available 24/7 via NOC hotline  
**Owner:** Network Operations Team
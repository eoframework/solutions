# IBM Ansible Automation Platform Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide provides systematic approaches to diagnose and resolve common issues encountered with Red Hat Ansible Automation Platform on IBM infrastructure.

## General Troubleshooting Methodology

### Systematic Problem Resolution

1. **Issue Identification**
   - Document error messages and symptoms
   - Identify affected components (Controller, Hub, Database)
   - Determine scope and timeline of impact
   - Note any recent changes or deployments

2. **Information Collection**
   - Gather relevant logs from all components
   - Check system resource utilization
   - Verify network connectivity
   - Review configuration changes

3. **Analysis and Diagnosis**
   - Correlate symptoms across components
   - Review error patterns in logs
   - Test connectivity and permissions
   - Isolate variables systematically

4. **Resolution and Verification**
   - Apply targeted fixes based on root cause
   - Verify resolution addresses the issue
   - Monitor for recurrence
   - Document solution for future reference

## Installation and Setup Issues

### Platform Installation Problems

**Issue: Installation Fails with Database Connection Error**

*Symptoms:*
- Installation script fails during database setup
- Connection refused errors to PostgreSQL
- Authentication failures to database

*Diagnostic Commands:*
```bash
# Test database connectivity
psql -h <db-host> -U <username> -d <database> -c "SELECT version();"

# Check database service status
systemctl status postgresql

# Verify database configuration
cat /var/lib/pgsql/data/postgresql.conf | grep -E "listen_addresses|port"
cat /var/lib/pgsql/data/pg_hba.conf
```

*Common Causes and Solutions:*
- **Network Connectivity**: Verify security groups allow port 5432
- **Authentication**: Check database credentials and permissions
- **Service Status**: Ensure PostgreSQL service is running
- **Configuration**: Verify postgresql.conf and pg_hba.conf settings

**Issue: Automation Controller Service Won't Start**

*Symptoms:*
- Controller web interface inaccessible
- Service fails to bind to port 443/80
- SSL certificate errors

*Diagnostic Commands:*
```bash
# Check service status
systemctl status automation-controller

# Review service logs
journalctl -u automation-controller -f

# Check port binding
netstat -tlnp | grep :443
ss -tlnp | grep :443

# Verify SSL certificates
openssl x509 -in /etc/tower/tower.cert -text -noout
```

*Resolution Steps:*
1. Check for port conflicts with other services
2. Verify SSL certificate validity and permissions
3. Review automation-controller configuration file
4. Check for adequate disk space and memory
5. Restart service with detailed logging enabled

### Container and Execution Environment Issues

**Issue: Execution Environment Build Failures**

*Symptoms:*
- Custom execution environments fail to build
- Container image pull errors
- Missing dependencies in execution environment

*Diagnostic Commands:*
```bash
# Check container runtime status
podman info
systemctl status podman

# Test image pulls
podman pull registry.redhat.io/ubi8/ubi:latest

# Review build logs
ansible-builder build --tag custom-ee --verbosity 3

# Check registry authentication
podman login registry.redhat.io
```

*Common Solutions:*
- Verify Red Hat registry authentication
- Check network connectivity to container registries
- Review execution environment definition file
- Ensure sufficient disk space for image layers
- Update base image references to latest versions

**Issue: Job Execution Fails with "No Such File or Directory"**

*Symptoms:*
- Playbooks fail to execute in containers
- Module not found errors
- Python path issues in execution environments

*Resolution Steps:*
```bash
# Debug execution environment
podman run -it <execution-environment> /bin/bash

# Check Python path
python3 -c "import sys; print(sys.path)"

# Verify Ansible installation
ansible --version
ansible-galaxy collection list

# Test module availability
python3 -c "from ansible.modules import <module_name>"
```

## Job Execution Problems

### Playbook and Task Failures

**Issue: SSH Connection Failures to Managed Hosts**

*Symptoms:*
- "Connection timed out" errors
- "Permission denied" for SSH authentication
- Host unreachable messages

*Diagnostic Commands:*
```bash
# Test SSH connectivity from controller
ssh -i <private-key> <username>@<host-ip>

# Check SSH agent and key loading
ssh-add -l
eval $(ssh-agent)

# Verify host key verification
ssh-keyscan <host-ip> >> ~/.ssh/known_hosts

# Test with verbose SSH output
ansible <host> -m ping -vvv
```

*Common Causes and Solutions:*
- **Network Connectivity**: Verify security groups and firewalls
- **SSH Keys**: Check key permissions (600 for private keys)
- **Known Hosts**: Add host keys to known_hosts file
- **Credentials**: Verify username and authentication method

**Issue: Playbook Tasks Hang or Timeout**

*Symptoms:*
- Tasks run indefinitely without completion
- Timeout errors after extended periods
- No response from managed hosts

*Diagnostic Steps:*
```bash
# Check for hung processes on managed hosts
ssh <host> "ps aux | grep ansible"

# Monitor network connections
netstat -an | grep <controller-ip>

# Review task module documentation
ansible-doc <module-name>

# Test module execution manually
ansible <host> -m <module> -a "<arguments>" -vvv
```

*Resolution Strategies:*
- Increase task timeout values
- Implement proper error handling
- Use async tasks for long-running operations
- Check for resource constraints on managed hosts

### Inventory and Host Management Issues

**Issue: Dynamic Inventory Script Failures**

*Symptoms:*
- Inventory sync jobs fail
- Hosts not appearing in inventory
- API authentication errors for inventory sources

*Diagnostic Commands:*
```bash
# Test inventory script manually
python3 /path/to/inventory/script.py --list

# Check API credentials
curl -H "Authorization: Bearer <token>" <api-endpoint>

# Verify inventory source configuration
tower-cli inventory_source list
tower-cli inventory_source get <id>

# Review sync job output
tower-cli job_template launch --job-template="<name>" --monitor
```

*Common Solutions:*
- Verify API credentials and permissions
- Check network connectivity to inventory sources
- Review script syntax and error handling
- Update inventory source configuration
- Monitor API rate limits and quotas

**Issue: Host Variables Not Resolving**

*Symptoms:*
- Undefined variable errors in playbooks
- Host-specific configuration not applied
- Variable precedence issues

*Resolution Steps:*
```bash
# Check host variable hierarchy
ansible-inventory -i <inventory> --host <hostname>

# Verify variable sources
tower-cli host list --inventory <inventory-id>
tower-cli host get <host-id>

# Test variable resolution
ansible-playbook --check --diff -i <inventory> <playbook>

# Debug variable precedence
ansible <host> -m debug -a "var=<variable-name>" -vvv
```

## Database and Performance Issues

### Database Connection Problems

**Issue: Database Connection Pool Exhausted**

*Symptoms:*
- Web interface becomes unresponsive
- "Max connections exceeded" errors
- Job execution delays or failures

*Diagnostic Commands:*
```bash
# Check active database connections
psql -h <db-host> -U <username> -c "SELECT count(*) FROM pg_stat_activity;"

# Monitor connection pool usage
psql -h <db-host> -U <username> -c "SELECT state, count(*) FROM pg_stat_activity GROUP BY state;"

# Review database configuration
psql -h <db-host> -U <username> -c "SHOW max_connections;"

# Check for long-running queries
psql -h <db-host> -U <username> -c "SELECT query, state, query_start FROM pg_stat_activity WHERE state = 'active';"
```

*Resolution Steps:*
1. Increase database max_connections setting
2. Implement connection pooling (PgBouncer)
3. Optimize long-running queries
4. Review application connection management
5. Monitor and set connection limits per application

**Issue: Database Performance Degradation**

*Symptoms:*
- Slow query execution times
- High database CPU utilization
- Interface timeouts and delays

*Performance Optimization:*
```sql
-- Check database statistics
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del 
FROM pg_stat_user_tables ORDER BY n_tup_ins DESC;

-- Identify slow queries
SELECT query, mean_time, calls FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan 
FROM pg_stat_user_indexes ORDER BY idx_scan ASC;

-- Database maintenance
VACUUM ANALYZE;
REINDEX DATABASE <database-name>;
```

### Resource Utilization Issues

**Issue: High Memory Usage on Controller Nodes**

*Symptoms:*
- Out of memory (OOM) killer activation
- Slow web interface response
- Job execution failures due to memory

*Diagnostic Commands:*
```bash
# Monitor memory usage
free -h
ps aux --sort=-%mem | head -10

# Check for memory leaks
cat /proc/meminfo
vmstat 5

# Review swap usage
swapon --show
cat /proc/swaps

# Check system limits
ulimit -a
cat /proc/sys/vm/overcommit_memory
```

*Resolution Strategies:*
- Increase system memory allocation
- Optimize job concurrency settings
- Implement resource limits for services
- Monitor and tune garbage collection
- Configure appropriate swap space

## Network and Connectivity Issues

### API and Web Interface Problems

**Issue: Web Interface SSL/TLS Errors**

*Symptoms:*
- Certificate validation failures
- Browser security warnings
- API authentication errors

*Diagnostic Commands:*
```bash
# Test SSL certificate
openssl s_client -connect <controller-fqdn>:443

# Check certificate validity
openssl x509 -in <certificate-file> -text -noout

# Verify certificate chain
openssl verify -CAfile <ca-certificate> <server-certificate>

# Test API endpoint
curl -k -H "Authorization: Bearer <token>" https://<controller>/api/v2/
```

*Resolution Steps:*
1. Install valid SSL certificates from trusted CA
2. Update certificate bundle with intermediate certificates
3. Verify certificate permissions and ownership
4. Configure proper certificate chain
5. Update client trust stores if using internal CA

**Issue: Load Balancer Health Check Failures**

*Symptoms:*
- Intermittent web interface unavailability
- Load balancer marking nodes as unhealthy
- API response inconsistencies

*Troubleshooting Steps:*
```bash
# Check load balancer configuration
# (Commands vary by load balancer type)

# Test health check endpoints
curl -I http://<controller-ip>/api/v2/ping/

# Verify service status on all nodes
systemctl status automation-controller

# Check load balancer logs
# Review IBM Cloud Load Balancer logs

# Test direct node access
curl -k https://<node-ip>/api/v2/config/
```

### Managed Host Connectivity

**Issue: Windows Host WinRM Authentication Failures**

*Symptoms:*
- PowerShell module execution failures
- Authentication errors for Windows hosts
- Connection timeouts to Windows systems

*Diagnostic Commands:*
```bash
# Test WinRM connectivity
ansible windows-host -m win_ping

# Check WinRM configuration on Windows host
# (Run on Windows system)
winrm get winrm/config
winrm enumerate winrm/config/Listener

# Test authentication
ansible windows-host -m win_whoami

# Verify certificate authentication
openssl s_client -connect <windows-host>:5986
```

*Common Solutions:*
- Configure WinRM service on Windows hosts
- Set up proper authentication (basic, certificate, or Kerberos)
- Verify network connectivity on WinRM ports (5985/5986)
- Configure TLS certificates for secure WinRM
- Check firewall rules on Windows hosts

## Integration Issues

### IBM Cloud Service Integration

**Issue: IBM Cloud API Authentication Failures**

*Symptoms:*
- Cloud inventory sync failures
- Resource provisioning errors
- API rate limit exceeded messages

*Diagnostic Commands:*
```bash
# Test IBM Cloud CLI authentication
ibmcloud auth

# Verify API key permissions
ibmcloud iam api-keys

# Test specific service APIs
ibmcloud is instances
ibmcloud cr images

# Check rate limiting
curl -H "Authorization: Bearer <token>" -I <api-endpoint>
```

*Resolution Steps:*
1. Refresh API keys and tokens
2. Verify service permissions and policies
3. Implement proper rate limiting and retry logic
4. Monitor API usage and quotas
5. Use service-specific authentication methods

**Issue: Git Integration Problems**

*Symptoms:*
- Project sync failures
- Git authentication errors
- Repository access denied messages

*Troubleshooting Steps:*
```bash
# Test Git connectivity
git ls-remote <repository-url>

# Check SSH key authentication
ssh -T git@<git-server>

# Verify credentials
git config --list | grep -E "user|credential"

# Test repository access
git clone <repository-url> /tmp/test-repo

# Review sync job logs
tower-cli project get <project-id>
```

## Emergency Procedures

### Service Recovery

**Emergency Service Restart**
```bash
# Stop all services
systemctl stop automation-controller
systemctl stop nginx

# Clear temporary files
rm -rf /tmp/awx_*
rm -rf /var/tmp/tower_*

# Check database connectivity
psql -h <db-host> -U <username> -l

# Start services
systemctl start automation-controller
systemctl start nginx

# Verify functionality
curl -k https://localhost/api/v2/ping/
```

**Database Recovery Procedure**
```bash
# Stop application services
systemctl stop automation-controller

# Create database backup
pg_dump -h <db-host> -U <username> <database> > backup.sql

# Restore from backup if needed
psql -h <db-host> -U <username> <database> < backup.sql

# Verify data integrity
psql -h <db-host> -U <username> -c "SELECT COUNT(*) FROM main_job;"

# Restart services
systemctl start automation-controller
```

### Disaster Recovery

**Backup Verification**
```bash
# Check backup completeness
tar -tzf <backup-file> | grep -E "(settings|projects|inventories)"

# Verify database dump
pg_restore --list <database-backup>

# Test restore procedure
# (Perform in test environment)
```

**Recovery Time Optimization**
- Maintain current backups of all configurations
- Document recovery procedures step by step
- Test recovery processes regularly
- Automate backup and recovery scripts
- Monitor backup success and integrity

## Escalation Procedures

### Red Hat Support Escalation

**When to Escalate:**
- Platform-wide service outages
- Data corruption or loss scenarios
- Security vulnerabilities or breaches
- Performance issues affecting SLA compliance

**Information to Provide:**
- Ansible Automation Platform version and build
- Complete error messages and stack traces
- sosreport output from affected systems
- Recent configuration changes
- Business impact assessment

### IBM Infrastructure Escalation

**Escalation Triggers:**
- IBM Cloud service outages
- Network connectivity issues
- Storage or compute resource problems
- Security group or networking issues

**Required Documentation:**
- IBM Cloud resource IDs and regions
- Network topology diagrams
- Error messages from IBM Cloud services
- Timeline of issues and attempted resolutions
- Performance metrics and monitoring data

## Monitoring and Alerting

### Key Performance Indicators

**System Health Metrics:**
- Service availability and uptime
- Response time for web interface and API
- Database connection pool utilization
- Memory and CPU usage trends
- Job execution success rates

**Application Metrics:**
- Job queue depth and processing time
- Inventory sync success and duration
- Project update frequency and success
- User session count and duration
- API request rates and error rates

### Recommended Alerts

**Critical Alerts:**
- Automation Controller service unavailable
- Database connection failures
- High memory utilization (>90%)
- Job queue backup (>100 pending jobs)
- SSL certificate expiration (<30 days)

**Warning Alerts:**
- High job failure rate (>10%)
- Slow API response times (>5 seconds)
- Database query performance degradation
- Network connectivity issues to managed hosts
- Credential expiration warnings

This comprehensive troubleshooting guide provides systematic approaches to resolving issues with IBM Ansible Automation Platform deployments, from basic connectivity problems to complex performance optimization scenarios.
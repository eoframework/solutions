# NVIDIA Omniverse Enterprise Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues in NVIDIA Omniverse Enterprise deployments. The guide is organized by component and symptom to enable rapid problem resolution.

## General Troubleshooting Methodology

### Systematic Approach

**1. Problem Identification**
- Document exact error messages and symptoms
- Identify affected components (Nucleus, client applications, network)
- Determine scope (single user, multiple users, entire system)
- Note timing and environmental conditions

**2. Information Gathering**
- Collect system logs from all relevant components
- Check system resource utilization (CPU, memory, storage, network)
- Verify configuration settings and recent changes
- Test from multiple client locations if applicable

**3. Root Cause Analysis**
- Compare symptoms against known issue database
- Isolate variables through systematic testing
- Use diagnostic tools and monitoring systems
- Escalate to NVIDIA support when needed

## Nucleus Server Issues

### Nucleus Server Won't Start

**Symptoms:**
- Nucleus service fails to start or stops immediately
- Error messages in nucleus logs about initialization failures
- Web interface inaccessible at configured URL

**Common Causes and Solutions:**

**Database Connection Issues**
```bash
# Check PostgreSQL service status
systemctl status postgresql
sudo systemctl restart postgresql

# Verify database connectivity
sudo -u postgres psql -c "SELECT version();"

# Check Nucleus database configuration
cat /opt/ove/nucleus/config/nucleus-server.yml
```

**Port Conflicts**
```bash
# Check for port usage conflicts
netstat -tlnp | grep :3009
netstat -tlnp | grep :8080

# Kill conflicting processes
sudo lsof -ti:3009 | xargs kill -9
```

**SSL Certificate Issues**
```bash
# Verify certificate validity
openssl x509 -in /path/to/certificate.crt -text -noout
openssl verify -CAfile /path/to/ca.crt /path/to/certificate.crt

# Check certificate permissions
ls -la /opt/ove/nucleus/certs/
chown nucleus:nucleus /opt/ove/nucleus/certs/*
chmod 600 /opt/ove/nucleus/certs/*.key
```

**Resolution Steps:**
1. Check system logs: `journalctl -u nucleus-server -n 50`
2. Verify database connectivity and schema
3. Ensure all required ports are available
4. Validate SSL certificate chain
5. Restart services in proper order: database → nucleus → web server

### Poor Nucleus Performance

**Symptoms:**
- Slow asset loading and synchronization
- High latency in collaborative sessions
- Timeout errors during large asset uploads

**Performance Diagnostics:**

**System Resource Analysis**
```bash
# Monitor CPU and memory usage
top -p $(pgrep nucleus-server)
htop

# Check I/O performance
iostat -x 1 5
iotop -o

# Network bandwidth utilization
iftop -i eth0
nload
```

**Database Performance**
```sql
-- Check PostgreSQL slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;

-- Monitor active connections
SELECT count(*) FROM pg_stat_activity;

-- Check database size and growth
SELECT pg_size_pretty(pg_database_size('nucleus'));
```

**Storage Performance Tests**
```bash
# Test sequential I/O performance
dd if=/dev/zero of=/tmp/testfile bs=1M count=1000 conv=fdatasync

# Test random I/O performance
fio --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k \
    --size=4g --numjobs=1 --iodepth=1 --runtime=60 --time_based
```

**Optimization Solutions:**
- Increase database connection pool size
- Add memory for database buffering
- Implement SSD storage for database and cache
- Configure network bonding for increased bandwidth
- Enable database query optimization and indexing

### Nucleus Clustering Issues

**Symptoms:**
- Inconsistent data between cluster nodes
- Split-brain scenarios with multiple active masters
- Client connections failing to specific nodes

**Cluster Diagnostics:**
```bash
# Check cluster status
nucleus-admin cluster status

# Verify node communication
ping -c 4 <cluster-node-ip>
telnet <cluster-node-ip> 5432

# Check database replication status
sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"
```

**Common Issues and Solutions:**

**Network Partitions**
- Implement proper network redundancy
- Configure cluster heartbeat timeouts appropriately
- Use dedicated cluster communication network

**Database Replication Lag**
- Monitor replication delay: `SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()));`
- Optimize database configuration for replication
- Consider using synchronous replication for critical data

## Client Application Issues

### Connection and Authentication Problems

**Symptoms:**
- Unable to connect to Nucleus server
- Authentication failures despite correct credentials
- Intermittent connection drops during collaboration

**Connection Diagnostics:**
```bash
# Test network connectivity
telnet nucleus-server.domain.com 3009
curl -I https://nucleus-server.domain.com/health

# DNS resolution test
nslookup nucleus-server.domain.com
dig nucleus-server.domain.com

# Certificate verification
openssl s_client -connect nucleus-server.domain.com:443 -servername nucleus-server.domain.com
```

**Authentication Troubleshooting:**
```bash
# Check LDAP connectivity (if using AD integration)
ldapsearch -x -H ldap://domain-controller:389 -D "user@domain.com" -W

# Verify SAML configuration
# Check SAML metadata exchange and certificate trust
```

**Resolution Steps:**
1. Verify network connectivity and DNS resolution
2. Check firewall rules and proxy configurations
3. Validate SSL certificates and trust chains
4. Test authentication backend connectivity
5. Review client application logs for specific errors

### Poor Rendering Performance

**Symptoms:**
- Low frame rates during real-time collaboration
- RTX features not functioning properly
- Rendering artifacts or quality issues

**GPU Diagnostics:**
```bash
# Check NVIDIA driver status
nvidia-smi

# Monitor GPU utilization
nvidia-smi dmon -i 0 -s puc

# Verify RTX capabilities
nvidia-smi -q | grep -A 5 "Ray Tracing"
```

**Performance Analysis:**
```powershell
# Windows GPU monitoring
Get-Counter "\GPU Engine(*)\Utilization Percentage"

# Check VRAM usage
nvidia-ml-py3 # Use Python nvidia-ml-py for detailed stats
```

**Optimization Solutions:**
- Update NVIDIA drivers to latest Studio/Quadro version
- Adjust RTX settings in Omniverse applications
- Optimize scene complexity and polygon count
- Configure appropriate LOD (Level of Detail) settings
- Enable GPU scheduling and hardware acceleration

### Asset Loading and Sync Issues

**Symptoms:**
- Assets fail to load or appear corrupted
- Synchronization conflicts between users
- Version control issues with asset updates

**Asset Diagnostics:**
```bash
# Check asset store connectivity
curl -H "Authorization: Bearer <token>" \
     "https://nucleus-server/api/v1/assets"

# Verify file permissions and accessibility
ls -la /path/to/assets/
stat /path/to/specific/asset.usd

# Test USD file validity
usdcat asset.usd
usdview asset.usd
```

**Sync Troubleshooting:**
- Clear local asset cache: Delete `%USERPROFILE%/.nvidia-omniverse/cache`
- Force asset re-download from Nucleus server
- Check for file locking issues on shared storage
- Verify USD schema compatibility between applications

## Network and Connectivity Issues

### Bandwidth and Latency Problems

**Symptoms:**
- Slow asset streaming and downloads
- Collaboration lag and poor responsiveness
- Timeout errors during large file operations

**Network Performance Testing:**
```bash
# Bandwidth testing between client and server
iperf3 -c nucleus-server.domain.com -p 5001 -t 30

# Latency and packet loss analysis
ping -c 100 nucleus-server.domain.com
mtr --report --report-cycles 100 nucleus-server.domain.com

# HTTP performance testing
curl -w "@curl-format.txt" -o /dev/null -s https://nucleus-server/large-asset.usd
```

**QoS and Traffic Shaping:**
```bash
# Check current QoS settings
tc qdisc show
tc class show

# Monitor network interface statistics
cat /proc/net/dev
ip -s link show
```

**Network Optimization:**
- Implement QoS policies for Omniverse traffic
- Configure traffic shaping and bandwidth allocation
- Use link aggregation (LACP) for increased bandwidth
- Optimize TCP window scaling and buffer sizes

### Firewall and Proxy Issues

**Symptoms:**
- Connection refused errors
- SSL handshake failures
- Partial functionality with some features blocked

**Firewall Diagnostics:**
```bash
# Test specific port accessibility
nmap -p 3009,443,8080 nucleus-server.domain.com

# Check local firewall rules (Linux)
iptables -L -n
ufw status verbose

# Windows firewall check
netsh advfirewall firewall show rule dir=in
```

**Proxy Configuration:**
```bash
# Test proxy connectivity
curl --proxy http://proxy-server:8080 https://nucleus-server.domain.com

# Check proxy bypass settings
echo $no_proxy
cat /etc/environment | grep -i proxy
```

**Resolution Steps:**
1. Configure firewall rules for required Omniverse ports
2. Set up proxy bypass for internal Nucleus servers
3. Verify SSL inspection policies don't interfere
4. Configure WebSocket upgrade support in proxies

## Performance Monitoring and Optimization

### System Performance Metrics

**Key Performance Indicators:**
- Nucleus server response time: <100ms for API calls
- Asset loading time: <30 seconds for typical scenes
- Collaboration latency: <50ms between users
- GPU utilization: >80% during rendering operations

**Monitoring Tools Setup:**
```bash
# Install Prometheus for metrics collection
docker run -d -p 9090:9090 prom/prometheus

# Configure Grafana for visualization
docker run -d -p 3000:3000 grafana/grafana

# Set up NVIDIA DCGM for GPU monitoring
dcgmi discovery -l
dcgmi group -c mygroup
dcgmi policy -i mygroup --set 5,150
```

**Custom Monitoring Scripts:**
```python
#!/usr/bin/env python3
# Nucleus health check script
import requests
import json
import time

def check_nucleus_health():
    try:
        response = requests.get('https://nucleus-server/health', timeout=10)
        if response.status_code == 200:
            print(f"Nucleus OK: {response.json()}")
            return True
    except Exception as e:
        print(f"Nucleus health check failed: {e}")
        return False

# Run continuous monitoring
while True:
    check_nucleus_health()
    time.sleep(60)
```

### Performance Tuning Guidelines

**Nucleus Server Optimization:**
```yaml
# nucleus-server.yml performance settings
server:
  worker_processes: auto
  max_connections: 1024
  keepalive_timeout: 65

database:
  pool_size: 20
  max_overflow: 30
  pool_recycle: 3600

caching:
  redis_enabled: true
  cache_ttl: 3600
  max_cache_size: "2GB"
```

**Client Application Settings:**
- Enable GPU acceleration in application preferences
- Adjust LOD settings for complex scenes
- Configure appropriate cache sizes
- Use local asset staging for frequently accessed content

## Error Code Reference

### Common Nucleus Error Codes

| Error Code | Description | Resolution |
|------------|-------------|------------|
| NUC-001 | Database connection failed | Check database service and credentials |
| NUC-002 | SSL certificate invalid | Renew or reconfigure certificates |
| NUC-003 | Authentication failure | Verify user credentials and authentication backend |
| NUC-004 | Asset not found | Check asset path and permissions |
| NUC-005 | Insufficient storage space | Add storage capacity or clean up old assets |
| NUC-006 | Network timeout | Check network connectivity and bandwidth |
| NUC-007 | Version conflict | Resolve USD version compatibility issues |
| NUC-008 | Permission denied | Verify user access rights and ACLs |
| NUC-009 | Service unavailable | Restart Nucleus services and dependencies |
| NUC-010 | Cluster sync failure | Check cluster node connectivity and replication |

### Client Application Error Codes

| Error Code | Description | Resolution |
|------------|-------------|------------|
| CL-001 | GPU driver outdated | Update NVIDIA drivers to latest version |
| CL-002 | Insufficient VRAM | Reduce scene complexity or upgrade GPU |
| CL-003 | Asset format unsupported | Convert assets to supported USD format |
| CL-004 | Collaboration conflict | Use merge tools to resolve conflicts |
| CL-005 | Render pipeline failure | Check RTX support and driver compatibility |
| CL-006 | Cache corruption | Clear application cache and restart |
| CL-007 | License validation failed | Verify license server connectivity |
| CL-008 | Scene loading timeout | Optimize scene complexity or increase timeout |
| CL-009 | Sync service disconnected | Check network and reconnect to Nucleus |
| CL-010 | Material pipeline error | Verify MDL material compatibility |

## Support Escalation

### When to Contact NVIDIA Support

**Tier 1 - Internal Resolution:**
- Common configuration issues
- User training and workflow questions
- Basic performance optimization
- Known issues with documented solutions

**Tier 2 - NVIDIA Support Required:**
- Persistent system crashes or data corruption
- Performance issues after optimization attempts
- Complex cluster configuration problems
- License or entitlement issues

**Tier 3 - Engineering Escalation:**
- Reproducible software defects
- Advanced integration requirements
- Custom deployment scenarios
- Performance issues requiring code analysis

### Information to Provide to Support

**System Information:**
- Complete hardware specifications
- OS version and patch level
- NVIDIA driver versions
- Omniverse version and build numbers

**Problem Documentation:**
- Detailed error messages and logs
- Steps to reproduce the issue
- Timeline of when issues started
- Impact assessment and business urgency

**Log Collection:**
```bash
# Nucleus server logs
tar -czf nucleus-logs.tar.gz /opt/ove/nucleus/logs/

# System logs
journalctl --since "1 hour ago" > system-logs.txt

# Network diagnostics
tcpdump -i any -w network-capture.pcap host nucleus-server

# GPU diagnostics
nvidia-bug-report.sh
```

This troubleshooting guide provides comprehensive coverage of common issues and systematic approaches to problem resolution in NVIDIA Omniverse Enterprise environments.
# Troubleshooting - Cisco SD-WAN Enterprise

## Common Issues

### Control Connection Problems
**Symptoms**: Devices not registering with controllers
**Causes**: 
- Certificate issues
- Network connectivity
- DNS resolution problems
- Firewall blocking traffic

**Resolution**:
```bash
# Check certificate status
show certificate installed
show certificate validity

# Verify control connections
show control connections
show control local-properties

# Test connectivity
ping vmanage.company.com
nslookup vbond.company.com
```

### Performance Issues
**Symptoms**: Slow application response times
**Causes**:
- Incorrect routing decisions
- QoS misconfiguration
- Circuit capacity issues
- Application policies

**Resolution**:
```bash
# Check application routing
show app-route statistics
show policy app-route

# Monitor bandwidth utilization
show interface statistics
show tunnel statistics

# Verify QoS policies
show policy-map interface
```

### Tunnel Establishment Issues
**Symptoms**: Sites cannot communicate
**Causes**:
- NAT configuration
- Firewall rules
- Routing problems
- Certificate validation

**Resolution**:
```bash
# Check tunnel status
show bfd sessions
show tunnel statistics
show ipsec outbound-connections

# Verify routing
show route
show omp routes
```

## Diagnostic Commands

### System Information
```bash
show version
show hardware
show system status
show clock
```

### Network Diagnostics
```bash
show interface summary
show ip route
show arp
ping <destination>
traceroute <destination>
```

### SD-WAN Specific
```bash
show control connections
show tunnel statistics
show app-route statistics
show policy summary
```

## Log Analysis

### Important Log Files
- `/var/log/vdaemon.log` - Control plane events
- `/var/log/confd.log` - Configuration changes
- `/var/log/netconf.log` - Management communication
- `/var/log/vmanage.log` - vManage specific logs

### Log Monitoring
```bash
# Real-time log monitoring
tail -f /var/log/vdaemon.log

# Search for specific events
grep "ERROR" /var/log/*.log
grep "certificate" /var/log/vdaemon.log
```

## Performance Optimization

### Best Practices
- Use appropriate templates
- Optimize policies
- Monitor bandwidth usage
- Regular health checks
- Keep software updated

### Capacity Planning
- Monitor growth trends
- Plan for peak usage
- Consider redundancy
- Regular performance reviews

---

**Document Version**: 1.0  
**Last Updated**: January 2025
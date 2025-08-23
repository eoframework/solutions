# Operations Runbook - Cisco SD-WAN Enterprise

## Overview

This runbook provides operational procedures for managing Cisco SD-WAN Enterprise infrastructure.

---

## Daily Operations

### Morning Checklist
- [ ] Check vManage dashboard for alerts
- [ ] Review overnight tunnel status
- [ ] Verify control plane connectivity
- [ ] Check application performance metrics
- [ ] Review security event logs

### Health Monitoring
```bash
# Daily health check script
#!/bin/bash
echo "SD-WAN Health Check - $(date)"

# Check controller status
curl -k "https://vmanage/dataservice/device/control/connectivity" | jq '.data[] | {hostname, status}'

# Check tunnel status
curl -k "https://vmanage/dataservice/device/tunnel/statistics" | jq '.data[] | {"src-ip", "dst-ip", state}'

# Generate summary report
echo "Health check completed"
```

---

## Monitoring and Alerting

### Key Performance Indicators
| Metric | Normal Range | Warning | Critical |
|--------|-------------|---------|----------|
| Control Connections | 100% | <95% | <90% |
| Tunnel Availability | >99% | <98% | <95% |
| Application SLA | <100ms | >150ms | >200ms |
| Bandwidth Utilization | <80% | >85% | >90% |

### Alert Response
1. **Control Connection Down**
   - Check device connectivity
   - Verify certificate status
   - Restart control daemon if needed
   - Escalate if multiple sites affected

2. **High Latency Alerts**
   - Check application routing
   - Verify QoS policies
   - Monitor WAN circuit performance
   - Adjust policies if needed

---

## Device Management

### Adding New Devices
1. **Preparation**
   - Generate device certificates
   - Create device templates
   - Plan IP addressing
   - Schedule installation

2. **Onboarding Process**
```bash
# Device onboarding
vmanage# request device add chassis-number 123456789 token ABCD1234
vmanage# config device attach template Branch-Template variables site-id=500
```

### Device Maintenance
- **Software Updates**: Schedule during maintenance windows
- **Configuration Changes**: Use templates for consistency
- **Hardware Replacement**: Follow RMA procedures
- **Decommissioning**: Remove from vManage inventory

---

## Policy Management

### Application Policies
```bash
# Update application routing
policy
 app-route-policy UPDATED_POLICY
  sequence 10
   match app-list CRITICAL_APPS
   action preferred-color mpls
  !
 !
!

# Activate policy
vmanage# policy activate UPDATED_POLICY
```

### Security Policies
- Review policies monthly
- Update threat intelligence feeds
- Monitor security events
- Document policy changes

---

## Incident Response

### Severity Levels
- **P1 Critical**: Complete site outage
- **P2 High**: Degraded performance
- **P3 Medium**: Single circuit failure
- **P4 Low**: Minor configuration issues

### Response Procedures
1. **Initial Assessment**
   - Identify scope of impact
   - Check vManage alarms
   - Verify device status
   - Estimate users affected

2. **Troubleshooting**
   - Follow diagnostic procedures
   - Check recent changes
   - Review logs and metrics
   - Engage vendor support if needed

---

## Backup and Recovery

### Configuration Backup
```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
vmanage_backup.sh --output /backup/vmanage_config_$DATE.tar.gz
vsmart_backup.sh --output /backup/vsmart_config_$DATE.tar.gz
```

### Disaster Recovery
1. **Controller Recovery**
   - Restore from backup
   - Verify certificate validity
   - Re-establish control connections
   - Validate policy distribution

2. **Site Recovery**
   - Replace failed hardware
   - Apply device templates
   - Verify connectivity
   - Test application performance

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Operations Team
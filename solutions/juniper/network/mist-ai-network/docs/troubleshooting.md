# Troubleshooting Guide - Juniper Mist AI Network Platform

## Overview
This comprehensive troubleshooting guide provides step-by-step procedures for diagnosing and resolving common issues with the Juniper Mist AI Network Platform. The guide is organized by problem category and includes both basic and advanced troubleshooting techniques.

---

## Quick Reference - Common Issues

### Critical Issue Quick Fixes
| Symptom | Quick Check | Immediate Action |
|---------|-------------|------------------|
| **Site Offline** | Internet connectivity | Check ISP connection, restart gateway |
| **AP Not Adopting** | Power and network | Verify PoE, check cloud connectivity |
| **Users Can't Connect** | SSID broadcast | Check WLAN configuration, test with known device |
| **Slow Performance** | RF interference | Analyze spectrum, optimize channel/power |
| **Authentication Failing** | RADIUS server | Verify RADIUS connectivity and credentials |

### Emergency Contacts
- **Juniper JTAC:** 1-888-314-JTAC (5822)
- **Emergency Escalation:** [Internal escalation number]
- **Cloud Service Status:** https://status.mist.com
- **Documentation Portal:** https://www.mist.com/documentation

---

## Connectivity Issues

### User Connection Problems

#### Issue: Users Cannot Connect to Wireless Network
**Symptoms:**
- Devices cannot see SSID
- Connection attempts fail
- Authentication errors
- IP address not assigned

**Diagnostic Steps:**
1. **Verify SSID Configuration**
   ```
   Mist Dashboard Navigation:
   1. Login to manage.mist.com
   2. Select Organization > Sites > [Site Name]
   3. Navigate to WLANs section
   4. Verify SSID is enabled and broadcasting
   5. Check authentication method configuration
   ```

2. **Test from Known Good Device**
   ```
   Basic Connectivity Test:
   1. Use company-managed device for testing
   2. Clear saved network profiles
   3. Attempt fresh connection
   4. Document specific error messages
   5. Test from different physical locations
   ```

3. **Check Access Point Status**
   ```
   AP Status Verification:
   1. Navigate to Access Points > [AP Name]
   2. Verify AP is online and connected
   3. Check radio status (2.4GHz and 5GHz)
   4. Verify WLAN assignment to AP
   5. Review recent events and alerts
   ```

**Common Causes and Solutions:**

| Cause | Solution |
|-------|----------|
| **SSID Not Broadcasting** | Enable SSID broadcast in WLAN configuration |
| **Authentication Misconfiguration** | Verify PSK, RADIUS settings, or certificate config |
| **VLAN Assignment Issues** | Check VLAN ID configuration and network routing |
| **AP Radio Disabled** | Enable radio in AP configuration or template |
| **RF Interference** | Analyze spectrum and adjust channel/power settings |

#### Issue: Intermittent Connection Drops
**Symptoms:**
- Frequent disconnections and reconnections
- Session timeouts
- Application interruptions
- Roaming failures

**Advanced Diagnostics:**
1. **Client Session Analysis**
   ```
   Marvis AI Queries:
   "Show me connection issues for [username] in the last 24 hours"
   "Why is [device MAC] disconnecting frequently?"
   "What is causing roaming failures in Building A?"
   ```

2. **RF Environment Analysis**
   ```
   RF Troubleshooting Steps:
   1. Navigate to RF Analytics > Spectrum Analysis
   2. Identify interference sources and patterns
   3. Review channel utilization and overlap
   4. Analyze noise floor and signal quality
   5. Check for rogue APs or unauthorized devices
   ```

3. **Power Management Settings**
   ```
   Client Power Management Check:
   1. Review client device power saving settings
   2. Verify aggressive power management disabled
   3. Check for driver updates and compatibility
   4. Test with power management disabled
   5. Document device-specific behaviors
   ```

**Resolution Strategies:**
- **Optimize RF Settings:** Adjust channel width, power levels, and band steering
- **Update Device Drivers:** Ensure latest wireless drivers installed
- **Configure Roaming Thresholds:** Optimize RSSI thresholds for seamless roaming
- **Review Power Settings:** Disable aggressive power management on client devices

### Access Point Issues

#### Issue: Access Point Not Connecting to Cloud
**Symptoms:**
- AP shows offline in dashboard
- Unable to manage or configure AP
- No telemetry or statistics available
- Local connectivity may still work

**Diagnostic Process:**
1. **Physical Connectivity Check**
   ```
   Hardware Verification:
   1. Verify power LED status (solid green expected)
   2. Check Ethernet cable connection and LED
   3. Test network connectivity from same port
   4. Verify PoE power delivery (802.3at minimum)
   5. Check cable length (<100 meters)
   ```

2. **Network Connectivity Test**
   ```
   Network Path Verification:
   1. Ping gateway from AP network segment
   2. Test DNS resolution to mist.com domains
   3. Verify firewall rules allow HTTPS (443) outbound
   4. Check for proxy or content filtering blocking
   5. Test from different network segment if available
   ```

3. **Cloud Connectivity Validation**
   ```
   Cloud Service Testing:
   1. Test connectivity to manage.mist.com
   2. Verify WebSocket connectivity (443/tcp)
   3. Check certificate validation and trust
   4. Test NTP synchronization (123/udp)
   5. Review cloud service status page
   ```

**Common Root Causes:**

| Cause | Diagnostic Method | Resolution |
|-------|------------------|------------|
| **Power Issues** | Check PoE budget and cable | Upgrade to PoE+ switch or injector |
| **Network Connectivity** | Test layer 1-3 connectivity | Repair cable, configure VLAN/routing |
| **Firewall Blocking** | Test required ports/protocols | Configure firewall rules for Mist |
| **DNS Issues** | Test name resolution | Configure correct DNS servers |
| **Certificate Problems** | Check date/time and cert store | Sync NTP, update certificates |

#### Issue: Access Point Performance Degradation
**Symptoms:**
- Reduced throughput or coverage
- High client count but poor performance
- Frequent client disconnections
- RF interference alerts

**Performance Analysis:**
1. **Throughput Testing**
   ```
   Performance Measurement:
   1. Use built-in throughput testing tools
   2. Test from multiple client positions
   3. Compare against baseline measurements
   4. Identify performance degradation patterns
   5. Document environmental factors
   ```

2. **Capacity Analysis**
   ```
   Client Density Assessment:
   1. Review concurrent client counts
   2. Analyze airtime utilization per radio
   3. Check for bandwidth-intensive applications
   4. Identify client distribution patterns
   5. Assess load balancing effectiveness
   ```

3. **RF Environment Optimization**
   ```
   RF Optimization Process:
   1. Perform spectrum analysis scan
   2. Identify interference sources
   3. Optimize channel assignments
   4. Adjust power levels for coverage
   5. Enable advanced features (band steering, etc.)
   ```

### Network Infrastructure Issues

#### Issue: Switch Connectivity Problems
**Symptoms:**
- Switch appears offline in dashboard
- Port connectivity issues
- PoE delivery problems
- Performance degradation

**Switch Troubleshooting:**
1. **Physical Layer Verification**
   ```
   Hardware Diagnostics:
   1. Check power connections and LED status
   2. Verify console port connectivity
   3. Test individual port functionality
   4. Check cable connections and integrity
   5. Review environmental conditions
   ```

2. **PoE System Analysis**
   ```
   PoE Troubleshooting:
   1. Check total PoE budget vs. consumption
   2. Verify port-level PoE allocation
   3. Test PoE negotiation and classification
   4. Check for PoE faults or overloads
   5. Validate power priority settings
   ```

3. **Network Integration Testing**
   ```
   Layer 2/3 Validation:
   1. Test VLAN configuration and trunking
   2. Verify spanning tree operation
   3. Check routing table and ARP entries
   4. Test inter-VLAN connectivity
   5. Validate QoS configuration
   ```

---

## Performance Issues

### Slow Network Performance

#### Issue: Poor Application Performance
**Symptoms:**
- High latency for applications
- Video conferencing quality issues
- File transfer speeds below expectations
- Web browsing slowness

**Performance Diagnostics:**
1. **Bandwidth Analysis**
   ```
   Marvis AI Performance Queries:
   "Show me bandwidth utilization for [site] in the last week"
   "Which applications are consuming the most bandwidth?"
   "Why is performance slow in Conference Room A?"
   "Compare performance before and after [date]"
   ```

2. **QoS Policy Validation**
   ```
   QoS Troubleshooting Steps:
   1. Review QoS policy configuration
   2. Verify traffic classification accuracy
   3. Check bandwidth allocation per class
   4. Analyze queue utilization and drops
   5. Test voice/video quality metrics
   ```

3. **Client-Side Diagnostics**
   ```
   Client Performance Testing:
   1. Test throughput from multiple devices
   2. Compare wireless vs. wired performance
   3. Check client adapter capabilities
   4. Test from different physical locations
   5. Analyze client roaming behavior
   ```

**Performance Optimization Actions:**
- **Channel Optimization:** Adjust to less congested channels
- **Power Level Tuning:** Optimize for coverage vs. interference
- **Load Balancing:** Enable client steering and load distribution
- **QoS Fine-tuning:** Adjust policies based on application requirements

### RF Performance Issues

#### Issue: Poor RF Coverage or Quality
**Symptoms:**
- Weak signal strength in coverage areas
- High noise levels or interference
- Poor signal-to-noise ratio (SNR)
- Coverage gaps or dead spots

**RF Analysis Procedure:**
1. **Coverage Assessment**
   ```
   RF Survey Process:
   1. Use mobile device with WiFi analyzer app
   2. Walk coverage areas measuring signal strength
   3. Document signal levels and coverage gaps
   4. Test at different times and conditions
   5. Compare against design specifications
   ```

2. **Interference Identification**
   ```
   Interference Analysis:
   1. Use Mist spectrum analysis tools
   2. Identify non-WiFi interference sources
   3. Check for co-channel interference
   4. Analyze adjacent channel interference
   5. Document temporal interference patterns
   ```

3. **Channel and Power Optimization**
   ```
   RF Optimization Steps:
   1. Review current channel assignments
   2. Analyze channel utilization statistics
   3. Identify optimal channel plan
   4. Adjust power levels for proper overlap
   5. Enable automatic RF optimization features
   ```

**RF Problem Resolution:**

| Issue | Diagnostic | Solution |
|-------|------------|----------|
| **Coverage Gaps** | Signal strength mapping | Add APs or adjust power/antennas |
| **Co-channel Interference** | Channel analysis | Change channels, adjust power |
| **Non-WiFi Interference** | Spectrum analysis | Identify and eliminate sources |
| **Noise Floor Issues** | Environmental analysis | Shield sources, change channels |

---

## Authentication and Security Issues

### Authentication Failures

#### Issue: 802.1X Authentication Problems
**Symptoms:**
- EAP authentication timeouts
- Certificate validation errors
- RADIUS server unreachable
- User credential rejections

**Authentication Troubleshooting:**
1. **RADIUS Connectivity Test**
   ```
   RADIUS Diagnostics:
   1. Test RADIUS server reachability (ping/telnet)
   2. Verify shared secret configuration
   3. Check RADIUS server logs for attempts
   4. Test with different user accounts
   5. Validate RADIUS server health and load
   ```

2. **Certificate Validation**
   ```
   Certificate Troubleshooting:
   1. Check certificate expiration dates
   2. Verify certificate chain validity
   3. Test certificate revocation status
   4. Validate certificate trust store
   5. Check for certificate format issues
   ```

3. **Active Directory Integration**
   ```
   AD Integration Verification:
   1. Test domain controller connectivity
   2. Verify service account permissions
   3. Check group membership resolution
   4. Test with different user types
   5. Validate LDAP query responses
   ```

**Common Authentication Issues:**

| Problem | Symptoms | Resolution |
|---------|----------|------------|
| **Expired Certificates** | Cert validation errors | Renew certificates, update CRL |
| **RADIUS Timeout** | Authentication delays | Check network latency, increase timeout |
| **Wrong Shared Secret** | All authentications fail | Verify and correct shared secret |
| **Account Lockouts** | Specific user failures | Unlock accounts, check policy |

#### Issue: Guest Access Portal Problems
**Symptoms:**
- Portal not loading or redirecting
- Registration process failures
- Sponsor approval not working
- Session timeout issues

**Guest Portal Diagnostics:**
1. **Portal Functionality Test**
   ```
   Portal Testing Steps:
   1. Connect device to guest SSID
   2. Test automatic portal redirect
   3. Complete registration process
   4. Verify email/SMS notifications
   5. Test sponsor approval workflow
   ```

2. **Backend Integration Validation**
   ```
   Integration Testing:
   1. Check portal server connectivity
   2. Test email/SMS gateway functionality
   3. Verify database connectivity
   4. Test sponsor notification system
   5. Validate session management
   ```

### Security Alerts and Incidents

#### Issue: Rogue Access Point Detection
**Symptoms:**
- Rogue AP alerts in dashboard
- Unauthorized network broadcasts
- Security policy violations
- Potential security breaches

**Rogue AP Investigation:**
1. **Threat Assessment**
   ```
   Rogue AP Analysis:
   1. Identify rogue AP location using triangulation
   2. Analyze SSID and security configuration
   3. Check for data exfiltration attempts
   4. Assess potential security impact
   5. Document for security team review
   ```

2. **Containment Actions**
   ```
   Immediate Response:
   1. Enable automatic rogue AP containment
   2. Block rogue AP MAC addresses
   3. Coordinate with physical security
   4. Monitor for additional threats
   5. Update security policies as needed
   ```

---

## Advanced Troubleshooting with Marvis AI

### Using Marvis for Complex Issues

#### Natural Language Troubleshooting
**Advanced Marvis Queries:**
```
Network Performance Queries:
"Why is the WiFi slow in Building C?"
"Show me all devices with connectivity issues"
"What's causing high interference on floor 3?"
"Predict when AP-123 might fail"

User Experience Queries:
"Which users are having connection problems?"
"Show me roaming failures in the last hour"
"Why can't John connect to the corporate WiFi?"
"What's the user experience score for this site?"

Infrastructure Queries:
"Show me all offline access points"
"Which switches have PoE issues?"
"What configuration changes were made yesterday?"
"Are there any security violations?"
```

#### AI-Driven Root Cause Analysis
**Correlation Analysis:**
1. **Multi-Factor Analysis**
   - Correlate network events with user complaints
   - Identify patterns in performance degradation
   - Analyze environmental factors and their impact
   - Cross-reference configuration changes with issues

2. **Predictive Insights**
   - Identify potential failures before they occur
   - Predict capacity constraints and plan upgrades
   - Recommend optimization opportunities
   - Suggest proactive maintenance actions

### Packet Capture and Deep Analysis

#### When to Use Packet Captures
**Capture Scenarios:**
- Complex authentication issues
- Application-specific performance problems
- Intermittent connectivity issues
- Security incident investigation

**Capture Configuration:**
```
Packet Capture Setup:
1. Navigate to Access Points > [AP Name] > Utilities
2. Select "Packet Capture" option
3. Configure capture filters:
   - Client MAC address (specific device)
   - SSID (specific network)
   - Duration (typically 5-10 minutes)
4. Start capture and reproduce issue
5. Download capture file for analysis
```

#### Analysis Tools and Techniques
**Wireshark Analysis Focus Areas:**
- Authentication handshake sequences
- DHCP address assignment process
- DNS resolution and response times
- Application layer protocol analysis
- Roaming event timing and success

---

## Escalation Procedures

### When to Escalate Issues

#### Internal Escalation Triggers
- **Critical Infrastructure Down:** Multiple sites or core services offline
- **Security Incidents:** Suspected breaches or malicious activity
- **Widespread Performance:** Issues affecting >25% of users
- **Complex Technical Issues:** Problems requiring vendor expertise

#### Vendor Escalation Process
1. **Information Gathering**
   ```
   Pre-Escalation Checklist:
   - Document problem symptoms and timeline
   - Gather relevant logs and configurations
   - Note troubleshooting steps already attempted
   - Identify business impact and urgency
   - Prepare network topology and device inventory
   ```

2. **Juniper JTAC Engagement**
   ```
   JTAC Case Information Required:
   - Organization ID and site details
   - Device serial numbers and software versions
   - Problem description and business impact
   - Reproduction steps and error messages
   - Supporting documentation and logs
   ```

### Emergency Response Procedures

#### Critical Incident Response
**Immediate Actions (0-15 minutes):**
1. Acknowledge incident and assess scope
2. Notify stakeholders per communication plan
3. Implement immediate containment measures
4. Document all actions and findings
5. Establish incident command if needed

**Short-term Response (15-60 minutes):**
1. Implement workarounds where possible
2. Engage vendor support if needed
3. Provide regular status updates
4. Coordinate with affected business units
5. Document lessons learned

---

## Preventive Maintenance and Monitoring

### Proactive Issue Prevention

#### Regular Health Checks
**Weekly Monitoring Tasks:**
```
Infrastructure Health Review:
1. Review site and device availability statistics
2. Check for firmware update notifications
3. Analyze performance trend reports
4. Review security alerts and incidents
5. Validate backup and monitoring systems
```

**Monthly Optimization Review:**
```
Performance Optimization Tasks:
1. Analyze RF environment changes
2. Review capacity utilization trends
3. Update configuration templates
4. Test disaster recovery procedures
5. Review and update documentation
```

#### Automated Monitoring Setup
**Key Alerts Configuration:**
- Device offline notifications
- Performance degradation alerts
- Security incident notifications
- Capacity threshold warnings
- Authentication failure spikes

**Dashboard Optimization:**
- Customize dashboards for different roles
- Set appropriate refresh intervals
- Configure alert thresholds based on baselines
- Create custom reports for management

### Continuous Improvement Process

#### Feedback Loop Implementation
1. **Issue Tracking and Analysis**
   - Maintain incident database
   - Analyze recurring problems
   - Identify root cause patterns
   - Track resolution effectiveness

2. **Process Optimization**
   - Regular procedure reviews and updates
   - Staff training and skill development
   - Tool and automation improvements
   - Best practice documentation updates

---

## Common Error Messages and Solutions

### Mist Cloud Platform Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Device not found in inventory" | AP not claimed | Claim AP using adoption code |
| "Configuration push failed" | Network connectivity issue | Check internet connectivity |
| "Certificate validation failed" | Time sync or cert issue | Verify NTP sync, update certs |
| "RADIUS server timeout" | RADIUS connectivity | Check RADIUS server and network |
| "Insufficient PoE power" | Power budget exceeded | Upgrade PoE or reduce load |

### Client Connection Error Messages

| Error Message | Platform | Cause | Solution |
|---------------|----------|-------|----------|
| "Can't connect to network" | Windows | Various auth issues | Check credentials and security settings |
| "Network password incorrect" | iOS/Android | Wrong PSK or cert | Verify password and certificates |
| "No internet connection" | All | DHCP or DNS issue | Check DHCP server and DNS settings |
| "Certificate not trusted" | Windows | CA cert missing | Install CA certificate |
| "Connection timeout" | All | Weak signal or congestion | Move closer or optimize RF |

---

## Contact Information and Resources

### Internal Support Contacts
- **Network Operations:** [Phone] / [Email]
- **Security Team:** [Phone] / [Email]  
- **Help Desk:** [Phone] / [Email]
- **Management Escalation:** [Phone] / [Email]

### Vendor Support Resources
- **Juniper JTAC:** 1-888-314-JTAC (5822)
- **Support Portal:** https://support.juniper.net
- **Documentation:** https://www.mist.com/documentation
- **Community Forums:** https://community.juniper.net
- **Service Status:** https://status.mist.com

### Additional Resources
- **Mist Academy Training:** https://www.mist.com/training
- **YouTube Channel:** Juniper Networks Mist
- **Best Practices Guides:** Available in documentation portal
- **API Documentation:** https://api.mist.com/api/v1/docs

---

**Document Control:**
- **Technical Lead:** [Name]
- **Contributors:** Network Operations Team
- **Last Updated:** [Date]
- **Version:** 1.0
- **Next Review:** [Date + 3 months]
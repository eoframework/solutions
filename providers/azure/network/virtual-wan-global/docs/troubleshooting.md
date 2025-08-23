# Troubleshooting Guide - Azure Virtual WAN Global Network

## Common Issues

### Issue 1: ExpressRoute Connectivity Problems
**Symptoms:**
- ExpressRoute circuit showing "Not Provisioned" or "Down" status
- Intermittent connectivity between on-premises and Azure resources
- BGP peering sessions not establishing or flapping
- High latency or packet loss over ExpressRoute connection

**Causes:**
- Service provider circuit not properly provisioned or configured
- BGP configuration mismatch between customer and Microsoft edge routers
- IP address conflicts or overlapping address spaces
- MTU size mismatches causing fragmentation issues
- Physical layer issues with fiber connections or equipment

**Solutions:**
1. Verify circuit provisioning status with ExpressRoute provider
2. Check BGP configuration on customer edge router for correct peer IP and ASN
3. Validate IP address allocation and ensure no overlapping subnets
4. Configure appropriate MTU size (typically 1500 bytes for private peering)
5. Test physical connectivity and check fiber optic connections

### Issue 2: VPN Site Connectivity Issues
**Symptoms:**
- Site-to-site VPN connections failing to establish
- Successful VPN establishment but no traffic flow
- Frequent VPN disconnections or instability
- Authentication failures during VPN connection attempts

**Causes:**
- Incorrect pre-shared key or certificate configuration
- Firewall rules blocking IPsec traffic (UDP 500, 4500, ESP protocol)
- Network address translation (NAT) interference with IPsec
- IKE/IPsec parameter mismatches between endpoints
- Routing configuration preventing traffic flow over VPN

**Solutions:**
1. Verify pre-shared keys and certificate configurations match on both ends
2. Configure firewall to allow IPsec traffic and disable NAT-T if causing issues
3. Check IKE and IPsec parameters for compatibility (encryption, hashing, DH group)
4. Validate routing configuration and ensure traffic is directed over VPN tunnel
5. Use VPN diagnostics tools to identify specific connection issues

### Issue 3: Routing and Connectivity Problems
**Symptoms:**
- Asymmetric routing causing connection issues
- Suboptimal routing paths with poor performance
- Routing loops or black holes preventing connectivity
- Hub-to-hub connectivity not working as expected

**Causes:**
- Incorrect route table configuration or propagation
- Conflicting or overlapping route advertisements
- Missing or incorrect static routes
- BGP route propagation issues or filtering
- Virtual network peering configuration problems

**Solutions:**
1. Review effective routes on virtual network interfaces and route tables
2. Check BGP route advertisements and ensure proper route propagation
3. Verify virtual network peering configuration and gateway transit settings
4. Use Azure Network Watcher to trace packet flow and identify routing issues
5. Implement proper route filtering and summarization to prevent conflicts

### Issue 4: Azure Firewall Performance and Rules
**Symptoms:**
- High latency through Azure Firewall processing
- Legitimate traffic being blocked by firewall rules
- Firewall reaching performance limits or dropping connections
- IDPS alerts generating excessive false positives

**Causes:**
- Incorrect firewall rule ordering or overly restrictive rules
- Insufficient firewall SKU for traffic volume
- IDPS signature conflicts with legitimate traffic
- DNS resolution issues affecting FQDN-based rules
- Application rules conflicting with network rules

**Solutions:**
1. Review and optimize firewall rule ordering for most specific rules first
2. Upgrade Azure Firewall SKU to handle increased traffic volume
3. Tune IDPS signatures and create exemptions for known false positives
4. Verify DNS resolution for FQDN-based rules and configure DNS proxy
5. Analyze firewall logs to identify dropped traffic and adjust rules accordingly

### Issue 5: Point-to-Site VPN Client Issues
**Symptoms:**
- VPN client unable to connect or authenticate
- Slow performance over point-to-site VPN connection
- Intermittent disconnections or connection drops
- Unable to access specific resources after VPN connection

**Causes:**
- Incorrect VPN client configuration or outdated client software
- Certificate authentication issues or expired certificates
- DNS configuration problems preventing name resolution
- Network routing issues on client device
- Bandwidth limitations or QoS issues

**Solutions:**
1. Update VPN client to latest version and reconfigure connection settings
2. Verify certificate installation and validity on client device
3. Configure DNS settings to use appropriate DNS servers for name resolution
4. Check client routing table and ensure traffic is routed through VPN tunnel
5. Test different connection protocols and optimize settings for performance

## Diagnostic Tools

### Built-in Azure Tools
- **Azure Network Watcher**: Comprehensive network monitoring and diagnostic capabilities
- **Virtual WAN Insights**: Built-in monitoring and analytics for Virtual WAN resources
- **ExpressRoute Monitor**: Dedicated monitoring for ExpressRoute circuits and connectivity
- **VPN Diagnostics**: Troubleshooting tools for site-to-site and point-to-site VPN
- **Azure Firewall Workbook**: Analytics and insights for Azure Firewall traffic
- **Connection Troubleshoot**: Step-by-step connectivity troubleshooting tool

### Azure CLI Diagnostic Commands
```bash
# Check Virtual WAN hub status
az network vhub show --resource-group myResourceGroup --name myVirtualHub

# Monitor VPN gateway connectivity
az network vpn-connection show --resource-group myResourceGroup --name myConnection

# Check ExpressRoute circuit status
az network express-route show --resource-group myResourceGroup --name myCircuit

# Validate route table entries
az network route-table route list --resource-group myResourceGroup --route-table-name myRouteTable

# Test network connectivity
az network watcher test-connectivity --source-resource myVM --dest-address 10.0.0.1 --dest-port 80

# Check effective routes
az network nic show-effective-route-table --resource-group myResourceGroup --name myNIC
```

### PowerShell Diagnostic Scripts
```powershell
# Check Virtual WAN configuration
Get-AzVirtualWan -ResourceGroupName "myResourceGroup"
Get-AzVirtualHub -ResourceGroupName "myResourceGroup"

# Monitor ExpressRoute circuit status
Get-AzExpressRouteCircuit -ResourceGroupName "myResourceGroup" -Name "myCircuit"
Get-AzExpressRouteCircuitPeeringConfig -ExpressRouteCircuit $circuit

# Check VPN connections and status
Get-AzVirtualNetworkGatewayConnection -ResourceGroupName "myResourceGroup"
Get-AzVirtualNetworkGatewayConnectionVpnDeviceConfigScript

# Validate routing information
Get-AzEffectiveRouteTable -NetworkInterfaceName "myNIC" -ResourceGroupName "myResourceGroup"
Get-AzEffectiveNetworkSecurityGroup -NetworkInterfaceName "myNIC" -ResourceGroupName "myResourceGroup"

# Monitor Azure Firewall logs
Get-AzOperationalInsightsSearchResult -WorkspaceId "workspaceId" -Query "AzureDiagnostics | where Category == 'AzureFirewallApplicationRule'"
```

### Network Performance Testing
```bash
# Test bandwidth and latency
iperf3 -c target_server_ip -t 60 -i 10

# Test packet loss and RTT
ping -c 100 target_ip
mtr --report --report-cycles 100 target_ip

# Test specific ports and protocols
telnet target_ip port_number
nc -zv target_ip port_range

# DNS resolution testing
nslookup target_fqdn
dig +trace target_fqdn

# Route tracing
traceroute target_ip
pathping target_ip (Windows)
```

### External Monitoring Tools
- **SolarWinds NPM**: Network performance monitoring and alerting
- **PRTG Network Monitor**: Infrastructure monitoring with custom sensors
- **Datadog Network Monitoring**: Cloud-native network performance monitoring
- **ThousandEyes**: Internet and cloud connectivity monitoring
- **Catchpoint**: Digital experience monitoring for network services

## Performance Optimization

### Network Performance Tuning
- **ExpressRoute Optimization**: Use ExpressRoute FastPath for high-performance workloads
- **VPN Performance**: Optimize VPN gateway SKU and enable BGP for better routing
- **Firewall Performance**: Right-size Azure Firewall SKU and optimize rule processing
- **Hub Design**: Deploy multiple hubs for regional optimization and load distribution
- **Route Optimization**: Implement efficient routing policies and avoid unnecessary hops

### Traffic Engineering and QoS
```bash
# Configure traffic engineering policies
az network traffic-analytics workspace configure --resource-group myRG --workspace-name myWorkspace

# Monitor traffic patterns
az network watcher flow-log configure --resource-group myRG --nsg myNSG --storage-account myStorage

# Implement quality of service
# Configure QoS markings and policies on network equipment
# Use Azure Firewall Premium for application-aware traffic management
```

### Bandwidth Optimization
- **Local Breakout**: Configure local internet breakout for Office 365 traffic
- **Content Delivery**: Use Azure CDN for static content delivery
- **Compression**: Enable compression for appropriate traffic types
- **Caching**: Implement caching strategies for frequently accessed content
- **Traffic Shaping**: Configure traffic shaping and rate limiting policies

## Security Troubleshooting

### Firewall Rule Analysis
```kusto
// Azure Firewall logs analysis
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule" or Category == "AzureFirewallNetworkRule"
| where msg_s contains "Deny"
| summarize count() by SourceIP = extract(@"Source: ([0-9\.]+)", 1, msg_s), 
                    DestIP = extract(@"Destination: ([0-9\.]+)", 1, msg_s),
                    Action = extract(@"Action: (\w+)", 1, msg_s)
| order by count_ desc

// Network security group analysis
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| where FlowStatus_s == "D" // Denied flows
| summarize count() by SrcIP_s, DestIP_s, DestPort_d
| order by count_ desc
```

### Certificate and Authentication Issues
- **Certificate Validation**: Verify certificate chain and expiration dates
- **PKI Infrastructure**: Validate certificate authority and revocation lists
- **Authentication Protocols**: Test different authentication methods (PSK, certificates)
- **Identity Integration**: Verify Azure AD integration and conditional access policies
- **Multi-Factor Authentication**: Troubleshoot MFA issues with VPN clients

### Network Segmentation Validation
```bash
# Test network segmentation
nc -zv target_ip port_number

# Validate security group rules
az network nsg rule list --resource-group myRG --nsg-name myNSG

# Check effective security rules
az network nic list-effective-nsg --resource-group myRG --name myNIC

# Audit network access
az monitor activity-log list --resource-group myRG --caller user@domain.com
```

## Advanced Troubleshooting

### Packet Capture and Analysis
```bash
# Configure packet capture using Network Watcher
az network watcher packet-capture create \
  --resource-group myRG \
  --vm myVM \
  --name myPacketCapture \
  --storage-account myStorageAccount \
  --filters protocol=TCP destinationPortRange=80

# Analyze captured packets with Wireshark or tcpdump
tcpdump -r capture.pcap -n host 10.0.0.1
```

### BGP Troubleshooting
```bash
# Check BGP neighbor status
show ip bgp neighbors
show ip bgp summary

# Validate BGP route advertisements
show ip bgp
show ip route bgp

# Debug BGP sessions
debug ip bgp events
debug ip bgp updates

# Check AS path and route propagation
show ip bgp regexp _65000_
show ip bgp community-list 100
```

### Performance Analysis
```kusto
// Network performance metrics
Perf
| where ObjectName == "Network Interface" and CounterName == "Bytes Total/sec"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| render timechart

// ExpressRoute utilization
AzureMetrics
| where ResourceProvider == "MICROSOFT.NETWORK" and Resource contains "EXPRESSROUTECIRCUITS"
| where MetricName == "BitsInPerSecond" or MetricName == "BitsOutPerSecond"
| summarize avg(Average) by Resource, MetricName, bin(TimeGenerated, 15m)
| render timechart
```

## Support Escalation

### Level 1 Support (Internal Team)
- **Network Operations Center**: 24/7 monitoring and basic troubleshooting
- **Internal Documentation**: Network diagrams, configuration guides, and procedures
- **Monitoring Dashboards**: Real-time network health and performance monitoring
- **Automated Alerting**: Proactive alerts for network issues and performance degradation
- **Knowledge Base**: Searchable database of common issues and solutions

### Level 2 Support (Microsoft Support)
- **Azure Support Portal**: Create support tickets with detailed problem description
- **Premier Support**: Dedicated technical account manager and priority support
- **Professional Support**: Business hours technical support with guaranteed response
- **ExpressRoute Support**: Specialized support for ExpressRoute connectivity issues
- **Virtual WAN Support**: Expert assistance with Virtual WAN configuration and optimization

### Level 3 Support (Critical Escalation)
- **Severity A Incidents**: Immediate response for business-critical network outages
- **Product Engineering**: Direct escalation to Azure networking product team
- **War Room Sessions**: Coordinated response with Microsoft engineering teams
- **Emergency Hotline**: 24/7 emergency support for critical infrastructure issues
- **Customer Success Manager**: Executive-level escalation and account management

### Partner Support Channels
- **ExpressRoute Providers**: Circuit-level support and SLA management
- **SD-WAN Vendors**: Integration support and technical assistance
- **System Integrators**: Professional services for complex troubleshooting
- **Managed Service Providers**: Outsourced network operations and support
- **Training Partners**: Technical training and knowledge transfer services

## Monitoring and Health Checks

### Proactive Monitoring Setup
```bash
# Configure network monitoring
az monitor metrics alert create \
  --name "High ExpressRoute Utilization" \
  --resource-group myRG \
  --scopes /subscriptions/{subscriptionId}/resourceGroups/{rgName}/providers/Microsoft.Network/expressRouteCircuits/{circuitName} \
  --condition "avg BitsInPerSecond > 80000000" \
  --description "ExpressRoute circuit utilization above 80%"

# Set up VPN connection monitoring
az monitor metrics alert create \
  --name "VPN Connection Down" \
  --resource-group myRG \
  --scopes /subscriptions/{subscriptionId}/resourceGroups/{rgName}/providers/Microsoft.Network/connections/{connectionName} \
  --condition "avg ConnectionState < 1" \
  --description "Site-to-site VPN connection is down"
```

### Health Check Scripts
```powershell
# Network connectivity health check
function Test-NetworkConnectivity {
    param(
        [string[]]$TargetHosts,
        [int]$Port = 443
    )
    
    foreach ($host in $TargetHosts) {
        $result = Test-NetConnection -ComputerName $host -Port $Port
        Write-Output "Connection to ${host}:${Port} - $($result.TcpTestSucceeded)"
    }
}

# ExpressRoute health check
function Test-ExpressRouteHealth {
    param([string]$ResourceGroupName, [string]$CircuitName)
    
    $circuit = Get-AzExpressRouteCircuit -ResourceGroupName $ResourceGroupName -Name $CircuitName
    Write-Output "Circuit State: $($circuit.ServiceProviderProvisioningState)"
    Write-Output "Circuit Status: $($circuit.CircuitProvisioningState)"
}

# DNS resolution test
function Test-DnsResolution {
    param([string[]]$DomainNames)
    
    foreach ($domain in $DomainNames) {
        try {
            $result = Resolve-DnsName $domain
            Write-Output "DNS resolution for $domain: Success"
        }
        catch {
            Write-Output "DNS resolution for $domain: Failed - $($_.Exception.Message)"
        }
    }
}
```

### Performance Baseline Monitoring
- **Establish Baselines**: Create performance baselines for normal network operation
- **Trend Analysis**: Monitor long-term trends and capacity planning requirements
- **Anomaly Detection**: Implement automated anomaly detection for performance issues
- **Capacity Planning**: Proactive capacity planning based on growth trends
- **SLA Monitoring**: Continuous monitoring of service level agreement compliance

### Custom Dashboards and Reporting
```json
{
  "dashboard": {
    "name": "Virtual WAN Network Health",
    "widgets": [
      {
        "type": "metrics",
        "title": "ExpressRoute Utilization",
        "metrics": ["BitsInPerSecond", "BitsOutPerSecond"],
        "timeRange": "PT24H"
      },
      {
        "type": "logs",
        "title": "VPN Connection Status",
        "query": "AzureDiagnostics | where Category == 'VPNDiagnostics' | summarize count() by ConnectionState_s",
        "timeRange": "PT24H"
      },
      {
        "type": "map",
        "title": "Global Network Topology",
        "data": "Virtual WAN hub locations and connectivity"
      }
    ]
  }
}
```

## Business Continuity and Disaster Recovery

### Network Failover Procedures
- **Automated Failover**: Configure automatic failover for ExpressRoute and VPN connections
- **Manual Failover**: Document procedures for manual failover during maintenance
- **Traffic Rerouting**: Implement intelligent traffic rerouting during outages
- **Service Degradation**: Graceful service degradation procedures for partial outages
- **Recovery Validation**: Procedures for validating network recovery and performance

### Disaster Recovery Testing
- **Quarterly DR Tests**: Regular testing of disaster recovery procedures and capabilities
- **Failover Scenarios**: Test various failure scenarios and recovery procedures
- **Performance Validation**: Verify network performance meets requirements during DR
- **Communication Testing**: Test emergency communication and escalation procedures
- **Documentation Updates**: Keep disaster recovery documentation current and accurate

### Business Impact Assessment
- **Critical Applications**: Identify applications with strict network requirements
- **Recovery Time Objectives**: Define acceptable downtime for different services
- **Recovery Point Objectives**: Define acceptable data loss limits
- **Business Continuity**: Maintain business operations during network disruptions
- **Stakeholder Communication**: Regular communication with business stakeholders
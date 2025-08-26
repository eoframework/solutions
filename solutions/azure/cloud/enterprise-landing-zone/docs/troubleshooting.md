# Troubleshooting Guide - Azure Enterprise Landing Zone

## Common Issues

### Issue 1: Management Group Policy Assignment Failures
**Symptoms:**
- Azure Policy assignments fail at management group level
- Non-compliant resources not being automatically remediated
- Policy evaluation taking longer than expected

**Causes:**
- Insufficient permissions for policy assignment
- Policy definition conflicts or circular dependencies
- Resource provider not registered in target subscriptions
- Management group hierarchy inheritance issues

**Solutions:**
1. Verify "Resource Policy Contributor" role at management group scope
2. Check policy definition syntax and parameter validation
3. Register required resource providers in all target subscriptions
4. Review management group inheritance and exclusion policies
5. Use Azure Policy compliance dashboard to identify specific failures

### Issue 2: Hub-Spoke Connectivity Issues
**Symptoms:**
- Cannot reach resources in spoke networks from hub
- Inter-spoke communication failures despite peering
- DNS resolution not working across networks

**Causes:**
- Virtual network peering not configured correctly
- Route tables blocking traffic flow
- Network security groups denying required traffic
- DNS forwarding not configured properly

**Solutions:**
1. Verify virtual network peering is in "Connected" state
2. Enable "Allow gateway transit" and "Use remote gateways" settings
3. Update route tables to allow hub-spoke and spoke-to-spoke traffic
4. Configure custom DNS servers or Azure DNS private zones
5. Test connectivity using Network Watcher connection troubleshoot

### Issue 3: ExpressRoute Connectivity Problems
**Symptoms:**
- ExpressRoute circuit shows "Not Provisioned" status
- On-premises resources cannot reach Azure services
- Intermittent connectivity or high latency

**Causes:**
- Circuit not properly provisioned by connectivity provider
- BGP peering configuration issues
- Route advertisement problems
- Gateway configuration errors

**Solutions:**
1. Verify circuit provisioning status with connectivity provider
2. Check BGP peering status and route advertisements
3. Validate ExpressRoute gateway configuration and SKU
4. Use ExpressRoute monitor to identify circuit health issues
5. Configure redundant connections for high availability

### Issue 4: Azure AD Integration Authentication Failures
**Symptoms:**
- Users cannot authenticate to Azure resources
- Single sign-on not working for integrated applications
- Conditional access policies blocking legitimate access

**Causes:**
- Azure AD Connect synchronization failures
- Incorrect federation configuration
- Conditional access policy conflicts
- Multi-factor authentication configuration issues

**Solutions:**
1. Check Azure AD Connect health and synchronization status
2. Validate federation configuration and certificate validity
3. Review conditional access policy assignments and conditions
4. Test MFA configuration with test users
5. Use Azure AD sign-in logs for detailed troubleshooting

### Issue 5: Cost Management and Unexpected Charges
**Symptoms:**
- Azure costs exceeding budget expectations
- Difficulty tracking costs across subscriptions
- Unexpected charges for specific services

**Causes:**
- Resources running in expensive SKUs or regions
- Lack of proper tagging for cost allocation
- Auto-scaling triggering during peak usage
- Storage costs for logs and backups

**Solutions:**
1. Use Azure Cost Management to identify top spending resources
2. Implement consistent tagging strategy for cost tracking
3. Configure auto-scaling policies with appropriate limits
4. Set up budget alerts and cost optimization recommendations
5. Review and optimize storage lifecycle policies

## Diagnostic Tools

### Built-in Azure Tools
- **Azure Monitor**: Comprehensive monitoring and alerting for all resources
- **Network Watcher**: Network diagnostics and topology visualization
- **Azure Advisor**: Personalized recommendations for optimization
- **Azure Resource Health**: Service health and resource availability status
- **Cost Management**: Detailed cost analysis and optimization recommendations
- **Azure Policy**: Compliance assessment and governance reporting

### Azure CLI Diagnostic Commands
```bash
# Check management group structure
az account management-group list --recurse

# Verify virtual network peering status
az network vnet peering list --vnet-name <vnet-name> --resource-group <rg-name>

# Test network connectivity
az network watcher test-connectivity --source-resource <vm-resource-id> --dest-address <target-ip>

# Check ExpressRoute circuit status
az network express-route list --resource-group <rg-name>

# Review Azure AD Connect status
az ad connect show

# Analyze cost data
az consumption usage list --billing-period-name <period>
```

### PowerShell Diagnostic Scripts
```powershell
# Check Azure Policy compliance
Get-AzPolicyState -ManagementGroupName <mg-name> | Where-Object {$_.ComplianceState -eq "NonCompliant"}

# Verify network security group rules
Get-AzNetworkSecurityGroup | Get-AzNetworkSecurityRuleConfig

# Check Azure AD synchronization status
Get-ADSyncScheduler

# Review subscription quotas and usage
Get-AzVMUsage -Location <region>

# Analyze resource costs
Get-AzConsumptionUsageDetail -BillingPeriodName <period>
```

### External Tools
- **Azure Storage Explorer**: Visual interface for storage account management
- **Power BI**: Advanced analytics and reporting for Azure consumption data
- **Terraform Plan**: Infrastructure change validation and planning
- **Azure DevOps**: CI/CD pipeline monitoring and deployment tracking
- **Third-party SIEM**: Integration with existing security monitoring tools

## Performance Optimization

### Network Performance
- **ExpressRoute Optimization**: Use ExpressRoute Global Reach for multi-region connectivity
- **Virtual Network Gateway**: Choose appropriate SKU based on throughput requirements
- **Load Balancer**: Implement Azure Load Balancer for high availability and performance
- **CDN**: Use Azure CDN for global content distribution and reduced latency
- **Traffic Manager**: DNS-based traffic routing for optimal performance

### Identity Performance
- **Azure AD Performance**: Use Azure AD Premium features for enhanced performance
- **Conditional Access**: Optimize policies to reduce authentication overhead
- **Single Sign-On**: Implement SSO to reduce user authentication friction
- **Privileged Identity Management**: Optimize just-in-time access workflows
- **Identity Protection**: Implement risk-based authentication policies

### Cost Performance
- **Reserved Instances**: Purchase reserved capacity for predictable workloads
- **Spot Instances**: Use Azure Spot VMs for non-critical batch workloads
- **Auto-shutdown**: Implement automatic shutdown for development resources
- **Right-sizing**: Continuously monitor and optimize resource sizes
- **Storage Optimization**: Use appropriate storage tiers and lifecycle policies

## Monitoring and Alerting

### Key Performance Indicators
- **Network Latency**: Cross-region and on-premises connectivity performance
- **Authentication Success Rate**: Azure AD sign-in success and failure rates
- **Policy Compliance**: Percentage of compliant resources across subscriptions
- **Cost Variance**: Actual vs. budgeted spending across time periods
- **Service Availability**: Uptime and availability of critical services

### Alert Configuration Examples
```json
{
  "alertName": "High Network Latency",
  "condition": "Average latency > 100ms over 15 minutes",
  "action": "Email network team and create incident ticket"
}

{
  "alertName": "Policy Non-Compliance",
  "condition": "Non-compliant resources > 5% of total",
  "action": "Notify security team and trigger compliance review"
}

{
  "alertName": "Cost Budget Exceeded",
  "condition": "Monthly spending > 90% of budget",
  "action": "Alert finance team and request budget review"
}
```

### Dashboard Creation
- **Executive Dashboard**: High-level metrics for business stakeholders
- **Operations Dashboard**: Detailed monitoring for IT operations team
- **Security Dashboard**: Security posture and threat detection metrics
- **Cost Dashboard**: Real-time cost tracking and optimization opportunities
- **Compliance Dashboard**: Policy compliance and governance metrics

## Support Escalation

### Level 1 Support (Internal Team)
- **Documentation**: Internal runbooks and standard operating procedures
- **Knowledge Base**: Searchable repository of known issues and solutions
- **Monitoring Tools**: Real-time dashboards and automated alerting
- **Team Chat**: Immediate communication and collaboration tools
- **Ticket System**: Incident tracking and resolution workflows

### Level 2 Support (Microsoft Support)
- **Professional Direct**: Business hours support with guaranteed response times
- **Premier Support**: 24/7 support with dedicated technical account manager
- **Azure Support Plans**: Tiered support based on business criticality
- **FastTrack Services**: Architecture guidance and best practices consultation
- **Microsoft Field Engineering**: On-site support for critical issues

### Level 3 Support (Emergency Response)
- **Critical Issue Escalation**: Immediate response for business-critical outages
- **War Room Procedures**: Coordinated response with Microsoft engineering teams
- **Executive Escalation**: Direct access to Microsoft executive leadership
- **Emergency Hotline**: 24/7 emergency contact for severity A incidents
- **Priority Support Queue**: Expedited handling for critical business functions

## Business Continuity and Disaster Recovery

### Backup Strategy
- **Multi-Region Backup**: Geo-redundant backup storage for critical data
- **Point-in-Time Recovery**: Database and application state recovery capabilities
- **Configuration Backup**: Infrastructure as Code templates and configurations
- **Cross-Region Replication**: Real-time data replication for high availability

### Disaster Recovery Planning
- **Recovery Time Objective (RTO)**: Target time for service restoration
- **Recovery Point Objective (RPO)**: Maximum acceptable data loss
- **Disaster Recovery Testing**: Regular testing of recovery procedures
- **Failover Automation**: Automated failover for critical applications
- **Communication Plan**: Stakeholder notification and status updates

### Incident Response
1. **Detection**: Automated monitoring and alerting systems
2. **Assessment**: Rapid impact analysis and severity classification
3. **Response**: Execute incident response playbooks and procedures
4. **Recovery**: Restore services and validate functionality
5. **Post-Incident Review**: Root cause analysis and prevention measures

### Service Level Agreements
- **Availability**: 99.9% uptime for production workloads
- **Performance**: Response time targets for critical applications
- **Recovery**: Maximum downtime and data loss objectives
- **Support**: Response time commitments for different severity levels
- **Compliance**: Adherence to regulatory and security requirements

## Governance and Compliance

### Policy Management
- **Policy Lifecycle**: Creation, testing, deployment, and retirement of policies
- **Compliance Monitoring**: Continuous assessment of policy adherence
- **Exception Management**: Controlled process for policy exemptions
- **Audit Trail**: Complete history of policy changes and assignments
- **Remediation**: Automated and manual compliance remediation processes

### Security Governance
- **Security Baselines**: Standardized security configurations across resources
- **Vulnerability Management**: Regular scanning and remediation of security issues
- **Access Reviews**: Periodic review of user access and permissions
- **Threat Detection**: Continuous monitoring for security threats and anomalies
- **Incident Response**: Coordinated response to security incidents and breaches
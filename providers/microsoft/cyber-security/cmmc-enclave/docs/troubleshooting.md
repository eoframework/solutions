# Microsoft CMMC Enclave - Troubleshooting Guide

This comprehensive troubleshooting guide addresses common issues encountered during deployment, configuration, and operation of the Microsoft CMMC Enclave solution. Use this guide to quickly identify and resolve problems while maintaining CMMC Level 2 compliance.

## Quick Reference

### Emergency Contacts
- **Microsoft Federal Support**: 1-800-642-7676
- **Azure Government Support**: Submit ticket through Azure Government portal
- **CMMC Assessment Team**: [Contact C3PAO organization]
- **Internal Security Team**: [Your organization's security contact]

### Critical Service Status
- **Azure Government Status**: https://status.azure.us/
- **Microsoft 365 Government Status**: https://admin.microsoft.us/servicestatus
- **Microsoft Security Response**: https://msrc.microsoft.com/

## Authentication and Identity Issues

### Azure Active Directory Problems

#### Problem: Users Cannot Sign In
**Symptoms:**
- Authentication failures in Azure AD
- "Invalid username or password" errors
- MFA prompts not appearing

**Troubleshooting Steps:**
1. **Verify Account Status**
   ```powershell
   Connect-AzureAD -AzureEnvironmentName AzureUSGovernment
   Get-AzureADUser -ObjectId "user@domain.onmicrosoft.us"
   ```
   - Check if account is enabled
   - Verify account is not locked
   - Confirm license assignment

2. **Check Conditional Access Policies**
   ```powershell
   Get-AzureADMSConditionalAccessPolicy | Where-Object {$_.State -eq "enabled"}
   ```
   - Review policy conditions
   - Verify user/group assignments
   - Check location restrictions

3. **Validate MFA Configuration**
   ```powershell
   Get-MsolUser -UserPrincipalName "user@domain.onmicrosoft.us" | Select-Object StrongAuthenticationRequirements
   ```
   - Confirm MFA is properly configured
   - Check authentication methods
   - Verify phone numbers and authenticator apps

**Resolution:**
- Reset user passwords if needed
- Re-register MFA methods
- Adjust Conditional Access policies
- Contact users to clear cached credentials

#### Problem: Privileged Identity Management (PIM) Activation Failures
**Symptoms:**
- PIM role activation requests fail
- "You do not have permission" errors
- Activation emails not received

**Troubleshooting Steps:**
1. **Check PIM Settings**
   - Navigate to Azure AD → Privileged Identity Management
   - Review role settings and approval requirements
   - Verify activation duration limits

2. **Validate Approval Workflow**
   - Check if role requires approval
   - Verify approver availability
   - Review notification settings

3. **Check User Eligibility**
   ```powershell
   Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" -ResourceId "tenant-id"
   ```

**Resolution:**
- Adjust role activation requirements
- Update approver settings
- Verify notification email addresses
- Clear browser cache and retry

### Hybrid Identity Issues

#### Problem: Azure AD Connect Synchronization Failures
**Symptoms:**
- Users not syncing from on-premises
- Synchronization errors in AAD Connect
- Password hash sync failures

**Troubleshooting Steps:**
1. **Check Service Status**
   ```cmd
   net start ADSync
   ```

2. **Review Synchronization Errors**
   ```powershell
   Start-ADSyncSyncCycle -PolicyType Full
   Get-ADSyncConnectorRunStatus
   ```

3. **Validate Network Connectivity**
   ```powershell
   Test-NetConnection -ComputerName login.microsoftonline.us -Port 443
   ```

**Resolution:**
- Restart Azure AD Connect service
- Review and resolve sync errors
- Update Azure AD Connect to latest version
- Check network connectivity to Azure Government

## Network and Connectivity Issues

### VPN Connectivity Problems

#### Problem: Site-to-Site VPN Connection Fails
**Symptoms:**
- VPN tunnel status shows "Not Connected"
- Unable to reach on-premises resources
- Intermittent connectivity issues

**Troubleshooting Steps:**
1. **Check VPN Gateway Status**
   ```bash
   az network vnet-gateway show --name cmmc-vpn-gateway --resource-group cmmc-rg
   ```

2. **Verify Local Network Gateway Configuration**
   - Confirm public IP address matches on-premises
   - Validate address prefixes
   - Check shared key configuration

3. **Monitor VPN Logs**
   ```bash
   az network vnet-gateway list-bgp-peer-status --name cmmc-vpn-gateway --resource-group cmmc-rg
   ```

**Resolution:**
- Verify pre-shared keys match
- Check firewall rules on both sides
- Restart VPN gateway if needed
- Contact network administrator for on-premises firewall rules

#### Problem: Azure Bastion Connection Issues
**Symptoms:**
- Cannot connect to VMs through Bastion
- "Connection failed" errors
- Slow or unresponsive connections

**Troubleshooting Steps:**
1. **Check Bastion Service Health**
   - Navigate to Azure Bastion resource
   - Review activity logs
   - Check service status

2. **Verify Network Security Group Rules**
   ```bash
   az network nsg rule list --nsg-name bastion-nsg --resource-group cmmc-rg
   ```

3. **Validate VM Network Configuration**
   - Check VM network interface configuration
   - Verify subnet assignments
   - Review route tables

**Resolution:**
- Restart Bastion service
- Update NSG rules if needed
- Check VM agent status
- Clear browser cache and retry

### Network Security Group Issues

#### Problem: Network Traffic Blocked by NSG Rules
**Symptoms:**
- Applications cannot communicate
- Database connection failures
- Web service timeouts

**Troubleshooting Steps:**
1. **Review NSG Flow Logs**
   ```bash
   az network watcher flow-log list --location "USGov Virginia"
   ```

2. **Check Effective Security Rules**
   ```bash
   az network nic list-effective-nsg --name vm-nic --resource-group cmmc-rg
   ```

3. **Analyze Network Traffic**
   ```bash
   az network watcher packet-capture create --name troubleshoot --vm vm-name --resource-group cmmc-rg
   ```

**Resolution:**
- Modify NSG rules to allow required traffic
- Review application security group assignments
- Update subnet route tables if needed
- Implement least privilege network access

## Azure Services Issues

### Key Vault Problems

#### Problem: Key Vault Access Denied
**Symptoms:**
- Applications cannot retrieve secrets
- "Access denied" errors
- Authentication failures

**Troubleshooting Steps:**
1. **Check Access Policies**
   ```powershell
   Get-AzKeyVault -VaultName "cmmc-vault" | Select-Object AccessPolicies
   ```

2. **Verify Service Principal Permissions**
   ```powershell
   Get-AzADServicePrincipal -ApplicationId "app-id" | Get-AzRoleAssignment
   ```

3. **Review Network Access Rules**
   ```powershell
   Get-AzKeyVaultNetworkRuleSet -VaultName "cmmc-vault"
   ```

**Resolution:**
- Update Key Vault access policies
- Add service principal to appropriate roles
- Configure network access rules
- Verify Managed Identity configuration

#### Problem: Key Vault Certificate Issues
**Symptoms:**
- Certificate validation failures
- "Certificate not found" errors
- SSL/TLS connection problems

**Troubleshooting Steps:**
1. **Check Certificate Status**
   ```powershell
   Get-AzKeyVaultCertificate -VaultName "cmmc-vault"
   ```

2. **Verify Certificate Chain**
   ```powershell
   $cert = Get-AzKeyVaultCertificate -VaultName "cmmc-vault" -Name "certificate-name"
   $cert.Certificate.Verify()
   ```

3. **Review Certificate Policies**
   ```powershell
   Get-AzKeyVaultCertificatePolicy -VaultName "cmmc-vault" -Name "certificate-name"
   ```

**Resolution:**
- Renew expired certificates
- Update certificate policies
- Re-import certificate chain
- Verify trusted root certificates

### SQL Database Issues

#### Problem: Database Connection Failures
**Symptoms:**
- Applications cannot connect to database
- Timeout errors
- Authentication failures

**Troubleshooting Steps:**
1. **Check Database Status**
   ```bash
   az sql db show --name cmmc-database --server cmmc-sql-server --resource-group cmmc-rg
   ```

2. **Review Firewall Rules**
   ```bash
   az sql server firewall-rule list --server cmmc-sql-server --resource-group cmmc-rg
   ```

3. **Verify Connection String**
   - Check server FQDN
   - Validate authentication method
   - Confirm database name

**Resolution:**
- Update firewall rules to allow client IP
- Fix connection string parameters
- Verify Azure AD authentication
- Check private endpoint configuration

#### Problem: Database Performance Issues
**Symptoms:**
- Slow query performance
- High CPU utilization
- Connection pool exhaustion

**Troubleshooting Steps:**
1. **Analyze Query Performance**
   ```sql
   SELECT TOP 10 
       qs.execution_count,
       qs.total_elapsed_time/1000 as total_elapsed_time_ms,
       qt.text
   FROM sys.dm_exec_query_stats qs
   CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
   ORDER BY qs.total_elapsed_time DESC
   ```

2. **Check Resource Utilization**
   - Monitor DTU/vCore usage
   - Review memory consumption
   - Analyze I/O patterns

3. **Review Database Configuration**
   - Check service tier and performance level
   - Verify auto-tuning settings
   - Review index recommendations

**Resolution:**
- Scale up database service tier
- Optimize problematic queries
- Implement recommended indexes
- Configure connection pooling

### Storage Account Issues

#### Problem: Storage Access Denied
**Symptoms:**
- Cannot access storage containers
- "403 Forbidden" errors
- Blob operations fail

**Troubleshooting Steps:**
1. **Check Storage Account Configuration**
   ```bash
   az storage account show --name cmmcstorageaccount --resource-group cmmc-rg
   ```

2. **Verify Access Keys and SAS Tokens**
   ```bash
   az storage account keys list --account-name cmmcstorageaccount --resource-group cmmc-rg
   ```

3. **Review Network Access Rules**
   ```bash
   az storage account network-rule list --account-name cmmcstorageaccount --resource-group cmmc-rg
   ```

**Resolution:**
- Regenerate storage account keys
- Update SAS token permissions
- Configure network access rules
- Verify RBAC assignments

## Microsoft 365 Government Issues

### Exchange Online Problems

#### Problem: Email Delivery Failures
**Symptoms:**
- Emails not delivered
- NDR (Non-Delivery Report) messages
- Delays in email delivery

**Troubleshooting Steps:**
1. **Check Message Trace**
   ```powershell
   Connect-ExchangeOnline -ExchangeEnvironmentName O365USGovGCCHigh
   Get-MessageTrace -RecipientAddress "user@domain.onmicrosoft.us" -StartDate (Get-Date).AddDays(-1)
   ```

2. **Review Transport Rules**
   ```powershell
   Get-TransportRule | Where-Object {$_.State -eq "Enabled"}
   ```

3. **Check Anti-Spam Policies**
   ```powershell
   Get-HostedContentFilterPolicy
   Get-HostedOutboundSpamFilterPolicy
   ```

**Resolution:**
- Adjust transport rules
- Update anti-spam settings
- Whitelist trusted senders
- Check DNS and SPF records

#### Problem: Data Loss Prevention (DLP) Blocks
**Symptoms:**
- Emails blocked by DLP policies
- Users cannot send sensitive information
- Excessive false positives

**Troubleshooting Steps:**
1. **Review DLP Policy Matches**
   ```powershell
   Get-DlpPolicyMatch -StartDate (Get-Date).AddDays(-1)
   ```

2. **Analyze DLP Incidents**
   ```powershell
   Get-DlpIncident | Where-Object {$_.CreationDate -gt (Get-Date).AddDays(-7)}
   ```

3. **Check Sensitivity Labels**
   ```powershell
   Get-Label | Select-Object Name, Priority, Conditions
   ```

**Resolution:**
- Fine-tune DLP policy conditions
- Adjust sensitivity levels
- Add policy exceptions for legitimate business needs
- Train users on proper data handling

### SharePoint Online Issues

#### Problem: SharePoint Site Access Denied
**Symptoms:**
- Users cannot access SharePoint sites
- "Access denied" when opening documents
- Sharing restrictions prevent collaboration

**Troubleshooting Steps:**
1. **Check Site Permissions**
   ```powershell
   Connect-SPOService -Url https://tenant-admin.sharepoint.us
   Get-SPOSite -Identity https://tenant.sharepoint.us/sites/sitename | Select-Object SharingCapability
   ```

2. **Review Information Protection Policies**
   ```powershell
   Get-SPOTenantSyncClientRestriction
   ```

3. **Validate User Licenses**
   ```powershell
   Get-SPOUser -Site https://tenant.sharepoint.us/sites/sitename
   ```

**Resolution:**
- Update site permissions
- Adjust sharing policies
- Verify license assignments
- Check Conditional Access policies

### Microsoft Teams Issues

#### Problem: Teams Meeting Issues
**Symptoms:**
- Cannot join meetings
- Audio/video quality problems
- Recording failures

**Troubleshooting Steps:**
1. **Check Teams Service Status**
   - Navigate to Microsoft 365 admin center
   - Review service health dashboard
   - Check Teams-specific issues

2. **Verify Network Connectivity**
   ```bash
   nslookup teams.microsoft.us
   telnet teams.microsoft.us 443
   ```

3. **Review Teams Policies**
   ```powershell
   Connect-MicrosoftTeams -TeamsEnvironmentName TeamsGCCH
   Get-CsTeamsMeetingPolicy
   ```

**Resolution:**
- Update Teams client
- Check network bandwidth
- Adjust meeting policies
- Clear Teams cache

## Microsoft Purview Issues

### Data Classification Problems

#### Problem: Automatic Labeling Not Working
**Symptoms:**
- Documents not automatically classified
- Incorrect labels applied
- Label policies not enforcing

**Troubleshooting Steps:**
1. **Check Label Policy Configuration**
   ```powershell
   Connect-IPPSSession -UserPrincipalName admin@tenant.onmicrosoft.us
   Get-LabelPolicy
   ```

2. **Review Auto-Labeling Rules**
   ```powershell
   Get-AutoSensitivityLabelRule
   ```

3. **Analyze Classification Results**
   ```powershell
   Get-DataClassification | Where-Object {$_.CreationDate -gt (Get-Date).AddDays(-7)}
   ```

**Resolution:**
- Adjust auto-labeling conditions
- Update sensitivity thresholds
- Retrain classification models
- Verify content scanning is enabled

### Data Loss Prevention Issues

#### Problem: DLP Policy False Positives
**Symptoms:**
- Legitimate business documents blocked
- Users complaining about excessive restrictions
- High volume of DLP alerts

**Troubleshooting Steps:**
1. **Analyze DLP Detections**
   ```powershell
   Get-DlpDetailReport -StartDate (Get-Date).AddDays(-7)
   ```

2. **Review Content Matches**
   ```powershell
   Get-DlpSensitiveInformationTypeStatistic
   ```

3. **Check Policy Conditions**
   ```powershell
   Get-DlpCompliancePolicy | Select-Object Name, ExchangeLocation, SharePointLocation
   ```

**Resolution:**
- Refine DLP policy conditions
- Add business justification options
- Implement user education
- Create policy exceptions for legitimate use cases

## Azure Sentinel Issues

### SIEM Configuration Problems

#### Problem: Data Connectors Not Working
**Symptoms:**
- No data appearing in Sentinel
- Connector status shows errors
- Missing log sources

**Troubleshooting Steps:**
1. **Check Connector Status**
   ```bash
   az sentinel data-connector list --resource-group cmmc-rg --workspace-name cmmc-sentinel
   ```

2. **Verify Log Analytics Workspace**
   ```bash
   az monitor log-analytics workspace show --workspace-name cmmc-logs --resource-group cmmc-rg
   ```

3. **Review Data Collection Rules**
   ```bash
   az monitor data-collection rule list --resource-group cmmc-rg
   ```

**Resolution:**
- Reconfigure data connectors
- Check API permissions
- Verify network connectivity
- Update connector configurations

#### Problem: Alert Rules Not Triggering
**Symptoms:**
- Security alerts not generated
- Detection rules not firing
- Missing incident creation

**Troubleshooting Steps:**
1. **Review Analytics Rules**
   ```kusto
   SecurityAlert
   | where TimeGenerated > ago(24h)
   | summarize count() by AlertName
   ```

2. **Check Rule Logic**
   ```kusto
   // Example query to test detection logic
   SigninLogs
   | where TimeGenerated > ago(1h)
   | where RiskLevelDuringSignIn == "high"
   ```

3. **Verify Data Sources**
   ```kusto
   Heartbeat
   | where TimeGenerated > ago(1h)
   | summarize count() by Computer
   ```

**Resolution:**
- Adjust analytics rule thresholds
- Update KQL queries
- Verify data sources are connected
- Test rule logic with sample data

## Performance and Scaling Issues

### Resource Capacity Problems

#### Problem: Virtual Machine Performance Issues
**Symptoms:**
- High CPU utilization
- Memory exhaustion
- Slow application response

**Troubleshooting Steps:**
1. **Monitor Resource Utilization**
   ```bash
   az vm show --name cmmc-vm --resource-group cmmc-rg --show-details
   ```

2. **Check Performance Metrics**
   - CPU utilization over time
   - Memory usage patterns
   - Disk I/O performance
   - Network throughput

3. **Review VM Size and Configuration**
   ```bash
   az vm list-sizes --location "USGov Virginia"
   ```

**Resolution:**
- Scale up VM size
- Optimize application configuration
- Implement auto-scaling
- Add load balancing

### Network Performance Issues

#### Problem: Slow Network Performance
**Symptoms:**
- High latency between services
- Network timeouts
- Poor user experience

**Troubleshooting Steps:**
1. **Network Latency Testing**
   ```bash
   ping -c 10 internal-service.domain.com
   traceroute internal-service.domain.com
   ```

2. **Bandwidth Utilization**
   ```bash
   az network watcher connection-monitor create --name network-test --source-resource vm1 --dest-address vm2
   ```

3. **Route Analysis**
   ```bash
   az network watcher show-next-hop --vm vm-name --source-ip 10.200.1.4 --dest-ip 10.200.2.4
   ```

**Resolution:**
- Optimize network routing
- Implement ExpressRoute for better connectivity
- Use proximity placement groups
- Configure load balancers appropriately

## Compliance and Assessment Issues

### CMMC Assessment Problems

#### Problem: Control Implementation Gaps
**Symptoms:**
- C3PAO identifies control deficiencies
- Automated assessments show non-compliance
- Evidence collection issues

**Troubleshooting Steps:**
1. **Run Compliance Assessment**
   ```bash
   az policy state list --resource-group cmmc-rg --filter "ComplianceState eq 'NonCompliant'"
   ```

2. **Review Security Center Recommendations**
   ```bash
   az security assessment list --query "[?status.code=='Unhealthy']"
   ```

3. **Check Policy Assignments**
   ```bash
   az policy assignment list --scope "/subscriptions/subscription-id"
   ```

**Resolution:**
- Implement missing controls
- Update policy definitions
- Configure automated remediation
- Generate compliance evidence

#### Problem: Evidence Collection Failures
**Symptoms:**
- Missing audit logs
- Incomplete evidence artifacts
- Assessment documentation gaps

**Troubleshooting Steps:**
1. **Verify Log Collection**
   ```kusto
   AzureActivity
   | where TimeGenerated > ago(7d)
   | summarize count() by CategoryValue
   ```

2. **Check Retention Policies**
   ```bash
   az monitor log-analytics workspace show --workspace-name cmmc-logs --resource-group cmmc-rg --query "retentionInDays"
   ```

3. **Review Evidence Repositories**
   - Documentation completeness
   - Policy version control
   - Procedure validation

**Resolution:**
- Configure comprehensive logging
- Implement automated evidence collection
- Establish document management procedures
- Create compliance dashboards

## Emergency Procedures

### Security Incident Response

#### High-Priority Security Alert
1. **Immediate Actions**
   - Isolate affected systems
   - Preserve forensic evidence
   - Activate incident response team
   - Document all actions

2. **Assessment and Containment**
   ```powershell
   # Disable compromised user account
   Set-AzureADUser -ObjectId "user-id" -AccountEnabled $false
   
   # Revoke active sessions
   Revoke-AzureADUserAllRefreshToken -ObjectId "user-id"
   ```

3. **Communication**
   - Notify CISO and security team
   - Contact C3PAO if assessment impact
   - Prepare incident report
   - Update stakeholders

### System Outage Response

#### Critical Service Failure
1. **Initial Response**
   - Check service health dashboards
   - Activate crisis management team
   - Implement workaround procedures
   - Communicate with users

2. **Escalation Procedures**
   - Open high-priority support ticket
   - Engage Microsoft Federal Services
   - Activate disaster recovery if needed
   - Document outage impact

## Preventive Measures

### Monitoring and Alerting
- Implement comprehensive monitoring
- Set up proactive alerting
- Regular health checks
- Automated remediation where possible

### Maintenance Procedures
- Regular system updates
- Performance optimization
- Capacity planning
- Documentation updates

### Training and Documentation
- Keep troubleshooting guides current
- Train team on common issues
- Maintain runbooks
- Document lessons learned

For additional support, contact Microsoft Federal Services or your designated support channels. Always document troubleshooting steps and resolutions for future reference and compliance purposes.
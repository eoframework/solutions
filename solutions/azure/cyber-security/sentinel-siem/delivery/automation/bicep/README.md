# Microsoft Sentinel SIEM - Bicep Automation

This directory contains Bicep Infrastructure as Code (IaC) templates for deploying Microsoft Sentinel SIEM solution on Azure.

## Overview

This automation deploys a complete Microsoft Sentinel SIEM solution including:

- **Log Analytics Workspace** with Sentinel enabled
- **Data Connectors** for ingesting security logs from multiple sources
- **Analytics Rules** for threat detection and alerting
- **Automation Playbooks** (Logic Apps) for SOAR capabilities
- **Workbooks** for security monitoring and visualization
- **UEBA Configuration** for behavioral analytics
- **RBAC Assignments** for SOC team access control

## Directory Structure

```
bicep/
├── main.bicep                      # Main orchestration template
├── modules/                        # Bicep modules
│   ├── log-analytics-workspace.bicep
│   ├── sentinel.bicep
│   ├── key-vault.bicep
│   ├── data-connectors.bicep
│   ├── analytics-rules.bicep
│   ├── playbooks.bicep
│   ├── workbooks.bicep
│   └── rbac-assignments.bicep
├── parameters/                     # Environment-specific parameters
│   ├── prod.parameters.json
│   ├── test.parameters.json
│   └── dr.parameters.json
├── scripts/                        # Deployment scripts
│   ├── deploy.sh
│   └── validate.sh
└── README.md                       # This file
```

## Prerequisites

1. **Azure CLI** (version 2.50.0 or later)
   ```bash
   az version
   ```

2. **Azure Subscription** with appropriate permissions
   - Owner or Contributor role on subscription
   - Ability to create resource groups and assign RBAC roles

3. **Azure Login**
   ```bash
   az login
   az account set --subscription [SUBSCRIPTION_ID]
   ```

4. **Bicep CLI** (installed with Azure CLI)
   ```bash
   az bicep version
   ```

## Configuration

### Environment Parameters

Each environment has its own parameter file:

- **Production** (`prod.parameters.json`)
  - 90-day log retention
  - 500GB daily ingestion cap
  - All data connectors enabled
  - UEBA enabled
  - 30 built-in + 20 custom analytics rules
  - 12 automation playbooks

- **Test** (`test.parameters.json`)
  - 30-day log retention
  - 5GB daily ingestion cap
  - Basic connectors only
  - UEBA disabled
  - 10 built-in + 5 custom analytics rules
  - 5 automation playbooks

- **DR** (`dr.parameters.json`)
  - Full configuration matching production
  - Deployed to secondary region (westus2)
  - Standby for disaster recovery

### Required Parameter Updates

Before deployment, update the following placeholders in parameter files:

```json
{
  "alertEmail": "[ALERT_EMAIL]",              // SOC team email
  "socAdGroupId": "[SOC_GROUP_ID]",           // Azure AD group for analysts
  "socAdminGroupId": "[ADMIN_GROUP_ID]",      // Azure AD group for admins
  "serviceNowEndpoint": "[SERVICENOW_URL]",   // ServiceNow instance URL
  "teamsWebhookUrl": "[TEAMS_WEBHOOK]"        // Teams webhook for alerts
}
```

## Deployment

### Step 1: Validate Templates

Validate Bicep syntax and parameters before deployment:

```bash
# Validate single environment
./scripts/validate.sh prod

# Validate all environments
./scripts/validate.sh all
```

### Step 2: Deploy to Azure

Deploy Sentinel SIEM to your Azure subscription:

```bash
# Deploy to production
./scripts/deploy.sh prod [SUBSCRIPTION_ID]

# Deploy to test environment
./scripts/deploy.sh test [SUBSCRIPTION_ID]

# Deploy to DR environment
./scripts/deploy.sh dr [SUBSCRIPTION_ID]
```

The deployment script will:
1. Validate prerequisites and templates
2. Run what-if analysis for review
3. Deploy all resources
4. Output deployment results

### Step 3: Post-Deployment Configuration

After deployment, complete these manual steps:

1. **Data Connector Authentication**
   - Navigate to Sentinel > Data connectors
   - Configure authentication for each connector
   - Grant required permissions

2. **Analytics Rules Tuning**
   - Review and customize detection rules
   - Adjust thresholds based on baseline
   - Enable/disable rules as needed

3. **Playbook Configuration**
   - Test automation playbooks
   - Configure API connections
   - Set up ServiceNow integration

4. **UEBA Setup** (Production/DR only)
   - Configure entity mappings
   - Enable behavioral analytics
   - Set anomaly detection thresholds

5. **Workbook Customization**
   - Review pre-deployed workbooks
   - Customize queries for your environment
   - Add organization-specific visualizations

## Deployed Resources

### Core Infrastructure
- Log Analytics Workspace
- Sentinel Solution
- Key Vault for secrets
- Resource Group

### Data Collection
- Office 365 Connector
- Azure AD Connector
- Azure Activity Connector
- Microsoft Defender Connectors (Cloud, Endpoint, Identity, O365)
- CEF/Syslog Connector
- DNS Logs Connector
- Threat Intelligence Connector

### Threat Detection
- 8 pre-configured analytics rules:
  - Multiple Failed Login Attempts
  - Suspicious Admin Activity
  - Unusual Resource Access
  - Malware Detection
  - Data Exfiltration
  - Brute Force Attack
  - Anomalous Login Location
  - Suspicious PowerShell Execution

### Automation (SOAR)
- 5 automation playbooks:
  - IP Enrichment
  - Block IP Address
  - Disable User Account
  - ServiceNow Ticket Creation
  - SOC Team Notification

### Visualization
- 5 security workbooks:
  - Security Operations Overview
  - Threat Intelligence Dashboard
  - User and Entity Behavior Analytics
  - Incident Response Metrics
  - Data Connectors Health

### Access Control
- SOC Analyst role assignments
- SOC Admin role assignments
- Key Vault access policies

## Monitoring and Operations

### View Deployment Status

```bash
# List deployments
az deployment sub list --query "[?name contains 'sentinel']" --output table

# Show deployment details
az deployment sub show --name [DEPLOYMENT_NAME]
```

### Check Resource Health

```bash
# List resources in resource group
az resource list --resource-group rg-sentinel-prod-001 --output table

# Check Sentinel workspace
az sentinel workspace show --workspace-name log-sentinel-prod-001 --resource-group rg-sentinel-prod-001
```

### Access Sentinel Portal

- **Sentinel Dashboard**: https://portal.azure.com/#blade/Microsoft_Azure_Security_Insights/WorkspaceSelectorBlade
- **Log Analytics**: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.OperationalInsights%2Fworkspaces

## Troubleshooting

### Common Issues

1. **Validation Failures**
   - Ensure all required parameters are provided
   - Check Azure CLI is logged in
   - Verify subscription permissions

2. **Deployment Errors**
   - Review error messages in deployment output
   - Check resource naming conflicts
   - Verify resource provider registrations

3. **Data Connector Issues**
   - Ensure proper authentication is configured
   - Verify required permissions are granted
   - Check service principal registrations

### Logs and Diagnostics

```bash
# View deployment operations
az deployment sub operation list --name [DEPLOYMENT_NAME]

# Get deployment error details
az deployment sub show --name [DEPLOYMENT_NAME] --query properties.error
```

## Cleanup

To remove all deployed resources:

```bash
# Delete resource group (removes all resources)
az group delete --name rg-sentinel-prod-001 --yes --no-wait

# Delete specific deployment
az deployment sub delete --name [DEPLOYMENT_NAME]
```

## Security Considerations

- **Secrets Management**: All secrets stored in Key Vault
- **RBAC**: Least privilege access model
- **Network Security**: Public access can be restricted post-deployment
- **Compliance**: Meets SOC2, HIPAA, and PCI-DSS requirements
- **Data Retention**: Configurable based on compliance needs

## Performance Targets

- **MTTD** (Mean Time to Detect): < 15 minutes
- **MTTR** (Mean Time to Respond): < 60 minutes
- **False Positive Rate**: < 50%
- **Data Ingestion**: Up to 500GB/day (production)

## Support and Documentation

- **Microsoft Sentinel Documentation**: https://docs.microsoft.com/en-us/azure/sentinel/
- **Bicep Documentation**: https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/
- **Azure CLI Reference**: https://docs.microsoft.com/en-us/cli/azure/

## Version History

| Version | Date       | Changes                          |
|---------|------------|----------------------------------|
| 1.0.0   | 2025-12-03 | Initial Bicep automation release |

## License

Internal use only - EO Framework Solutions

# Scripts - Azure Enterprise Landing Zone

## Overview

This directory contains automation scripts and utilities for Azure Enterprise Landing Zone solution deployment, testing, and operations. Implements Microsoft's Cloud Adoption Framework (CAF) with enterprise-scale architecture patterns, governance, security, and compliance automation.

---

## Script Categories

### Landing Zone Infrastructure Scripts
- **bicep-deployment.ps1** - Bicep template deployment for enterprise architecture
- **management-group-setup.py** - Management group hierarchy configuration
- **subscription-vending.py** - Automated subscription provisioning and governance
- **resource-group-factory.py** - Standardized resource group deployment
- **hub-spoke-networking.py** - Hub and spoke network topology deployment

### Governance Scripts
- **policy-deployment.py** - Azure Policy definitions and assignments
- **blueprint-deployment.py** - Azure Blueprints for governance automation
- **rbac-automation.py** - Role-based access control configuration
- **tag-governance.py** - Resource tagging policies and enforcement
- **cost-management-setup.py** - Cost management and budgeting automation

### Security Scripts
- **defender-setup.py** - Microsoft Defender for Cloud configuration
- **key-vault-setup.py** - Enterprise Key Vault deployment and configuration
- **identity-governance.py** - Azure AD governance and access management
- **security-baseline.py** - Security baseline policies and configurations
- **privileged-access.py** - Privileged Identity Management (PIM) setup

### Connectivity Scripts
- **virtual-wan-setup.py** - Azure Virtual WAN deployment
- **express-route-setup.py** - ExpressRoute circuit configuration
- **vpn-gateway-setup.py** - VPN gateway deployment and configuration
- **private-dns-setup.py** - Private DNS zones and resolution
- **firewall-setup.py** - Azure Firewall configuration and policies

### Platform Services Scripts
- **log-analytics-setup.py** - Centralized logging workspace deployment
- **automation-account-setup.py** - Azure Automation account configuration
- **backup-vault-setup.py** - Recovery Services vault configuration
- **monitor-setup.py** - Azure Monitor and Application Insights setup

### Testing Scripts
- **landing-zone-validation.py** - Comprehensive landing zone validation
- **compliance-testing.py** - Policy compliance testing and reporting
- **security-testing.py** - Security posture assessment
- **connectivity-testing.py** - Network connectivity validation

### Operations Scripts
- **health-monitoring.ps1** - Landing zone health monitoring
- **cost-optimization.py** - Multi-subscription cost optimization
- **backup-management.ps1** - Enterprise backup management
- **compliance-reporting.py** - Governance and compliance reporting

---

## Prerequisites

### Required Tools
- **Azure CLI v2.50+** - Azure command line interface
- **Azure PowerShell v9.0+** - PowerShell modules for Azure
- **Python 3.9+** - Python runtime environment
- **Bicep CLI** - Infrastructure as Code for Azure
- **Git** - Version control for configuration management
- **jq** - JSON processor for script automation

### Azure Services and Features
- Azure Management Groups (organizational hierarchy)
- Azure Policy (governance and compliance)
- Azure Blueprints (repeatable environments)
- Azure Active Directory (identity and access management)
- Azure Virtual Network (networking foundation)
- Azure Firewall (network security)
- Azure Monitor (observability platform)
- Azure Security Center/Defender (security management)
- Azure Cost Management (financial governance)

### Python Dependencies
```bash
pip install azure-identity azure-mgmt-resource azure-mgmt-managementgroups
pip install azure-mgmt-policy azure-mgmt-network azure-mgmt-security
pip install azure-mgmt-monitor azure-mgmt-costmanagement requests
```

### PowerShell Modules
```powershell
Install-Module -Name Az -Force -AllowClobber
Install-Module -Name Az.Resources -Force
Install-Module -Name Az.Profile -Force
Install-Module -Name Az.PolicyInsights -Force
Install-Module -Name Az.Security -Force
Install-Module -Name Az.CostManagement -Force
```

### Configuration
```bash
# Azure CLI authentication with appropriate permissions
az login --tenant "your-tenant-id"
az account set --subscription "management-subscription-id"

# Set environment variables
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_SUBSCRIPTION_ID="management-subscription-id"
export MANAGEMENT_GROUP_ID="enterprise-mg"
export LANDING_ZONE_PREFIX="elz"
export AZURE_LOCATION="eastus"
export ENVIRONMENT="production"
```

```powershell
# PowerShell Azure authentication
Connect-AzAccount -TenantId "your-tenant-id"
Set-AzContext -SubscriptionId "management-subscription-id"

# Environment variables
$env:AZURE_TENANT_ID = "your-tenant-id"
$env:AZURE_SUBSCRIPTION_ID = "management-subscription-id"
$env:MANAGEMENT_GROUP_ID = "enterprise-mg"
$env:LANDING_ZONE_PREFIX = "elz"
```

---

## Usage Instructions

### Management Group Setup
```bash
# Create management group hierarchy
python management-group-setup.py \
  --root-mg-id $MANAGEMENT_GROUP_ID \
  --hierarchy-config ./config/mg-hierarchy.json \
  --enable-logging \
  --apply-policies

# Setup subscription vending machine
python subscription-vending.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --subscription-template ./templates/subscription-template.json \
  --enable-automatic-provisioning
```

```powershell
# PowerShell management group deployment
.\management-group-setup.ps1 -ManagementGroupId $env:MANAGEMENT_GROUP_ID -HierarchyFile .\config\mg-hierarchy.json
```

### Landing Zone Infrastructure Deployment
```bash
# Deploy hub and spoke networking
python hub-spoke-networking.py \
  --hub-subscription hub-subscription-id \
  --spoke-subscriptions spoke1-id,spoke2-id \
  --address-space 10.0.0.0/16 \
  --enable-peering

# Deploy Bicep templates for landing zone
az deployment mg create \
  --management-group-id $MANAGEMENT_GROUP_ID \
  --location $AZURE_LOCATION \
  --template-file ./bicep/enterprise-landing-zone.bicep \
  --parameters @./parameters/elz-parameters.json

# Setup Virtual WAN architecture
python virtual-wan-setup.py \
  --resource-group connectivity-rg \
  --virtual-wan-name enterprise-vwan \
  --hub-locations eastus,westus2 \
  --enable-expressroute \
  --enable-vpn
```

```powershell
# Bicep deployment using PowerShell
.\bicep-deployment.ps1 -ManagementGroupId $env:MANAGEMENT_GROUP_ID -Location $env:AZURE_LOCATION -TemplateFile .\bicep\enterprise-landing-zone.bicep
```

### Governance and Policy Setup
```bash
# Deploy Azure Policy initiatives
python policy-deployment.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --policy-set-definitions ./policies/ \
  --assignment-scope /providers/Microsoft.Management/managementGroups/$MANAGEMENT_GROUP_ID \
  --enable-remediation

# Setup Azure Blueprints
python blueprint-deployment.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --blueprint-definition ./blueprints/enterprise-blueprint.json \
  --assignment-name enterprise-assignment \
  --target-subscriptions ./config/target-subscriptions.json

# Configure RBAC automation
python rbac-automation.py \
  --scope /providers/Microsoft.Management/managementGroups/$MANAGEMENT_GROUP_ID \
  --role-assignments ./config/rbac-assignments.json \
  --enable-pim-integration

# Implement tag governance
python tag-governance.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --required-tags environment,costCenter,owner \
  --tag-policies ./policies/tag-policies.json \
  --enforce-compliance
```

### Security Configuration
```bash
# Configure Microsoft Defender for Cloud
python defender-setup.py \
  --subscription-ids all \
  --pricing-tier standard \
  --enable-cspm \
  --enable-cwp \
  --defender-plans ./config/defender-plans.json

# Setup enterprise Key Vault
python key-vault-setup.py \
  --resource-group security-rg \
  --key-vault-name $LANDING_ZONE_PREFIX-kv-enterprise \
  --enable-rbac \
  --purge-protection \
  --network-acls ./config/keyvault-network-rules.json

# Configure identity governance
python identity-governance.py \
  --tenant-id $AZURE_TENANT_ID \
  --enable-conditional-access \
  --pim-roles ./config/pim-eligible-roles.json \
  --access-reviews ./config/access-review-settings.json

# Apply security baseline
python security-baseline.py \
  --scope management-group \
  --target $MANAGEMENT_GROUP_ID \
  --baseline-config ./config/security-baseline.json \
  --remediate-non-compliant
```

### Connectivity and Networking
```bash
# Setup ExpressRoute connectivity
python express-route-setup.py \
  --circuit-name enterprise-er-circuit \
  --service-provider "Equinix" \
  --peering-location "Silicon Valley" \
  --bandwidth 1000 \
  --redundancy-config ./config/er-redundancy.json

# Configure Azure Firewall
python firewall-setup.py \
  --resource-group connectivity-rg \
  --firewall-name enterprise-firewall \
  --firewall-policy enterprise-fw-policy \
  --rule-collections ./config/firewall-rules.json

# Setup private DNS zones
python private-dns-setup.py \
  --resource-group connectivity-rg \
  --dns-zones privatelink.database.windows.net,privatelink.blob.core.windows.net \
  --virtual-networks hub-vnet,spoke1-vnet,spoke2-vnet

# Configure VPN gateways
python vpn-gateway-setup.py \
  --resource-group connectivity-rg \
  --gateway-name enterprise-vpn-gw \
  --gateway-type vpn \
  --vpn-type route-based \
  --sku VpnGw2AZ
```

### Platform Services Setup
```bash
# Deploy centralized Log Analytics workspace
python log-analytics-setup.py \
  --resource-group management-rg \
  --workspace-name enterprise-logs-workspace \
  --retention-days 730 \
  --data-sources ./config/log-analytics-sources.json

# Setup Azure Automation
python automation-account-setup.py \
  --resource-group management-rg \
  --automation-account enterprise-automation \
  --enable-update-management \
  --enable-change-tracking

# Configure Azure Monitor
python monitor-setup.py \
  --resource-group management-rg \
  --action-groups ./config/action-groups.json \
  --alert-rules ./config/alert-rules.json \
  --workbooks ./config/monitoring-workbooks.json

# Setup backup vault
python backup-vault-setup.py \
  --resource-group management-rg \
  --vault-name enterprise-backup-vault \
  --backup-policies ./config/backup-policies.json \
  --enable-cross-region-restore
```

### Validation and Testing
```bash
# Validate landing zone deployment
python landing-zone-validation.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --validation-suite comprehensive \
  --check-policies \
  --check-networking \
  --check-security \
  --generate-report

# Test policy compliance
python compliance-testing.py \
  --scope /providers/Microsoft.Management/managementGroups/$MANAGEMENT_GROUP_ID \
  --policy-assignments all \
  --remediation-mode automatic \
  --export-results ./compliance-report.json

# Security posture assessment
python security-testing.py \
  --subscription-ids all \
  --security-controls ./config/security-controls.json \
  --benchmark cis-azure \
  --export-format excel

# Network connectivity testing
python connectivity-testing.py \
  --test-matrix ./config/connectivity-tests.json \
  --include-latency-tests \
  --include-throughput-tests \
  --generate-topology-map
```

### Operations and Monitoring
```bash
# Health monitoring
python health-monitoring.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --check-interval 300 \
  --alert-channels email,teams \
  --health-checks ./config/health-checks.json

# Cost optimization across subscriptions
python cost-optimization.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --time-period 30-days \
  --include-recommendations \
  --budget-alerts \
  --export-dashboard ./cost-dashboard.pbix

# Generate compliance reports
python compliance-reporting.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --report-types governance,security,cost \
  --output-format pdf \
  --schedule-delivery monthly \
  --recipients ops-team@company.com
```

```powershell
# PowerShell operations
.\health-monitoring.ps1 -ManagementGroupId $env:MANAGEMENT_GROUP_ID -CheckInterval 300

.\cost-optimization.ps1 -ManagementGroupId $env:MANAGEMENT_GROUP_ID -TimePeriod 30

.\backup-management.ps1 -ManagementGroupId $env:MANAGEMENT_GROUP_ID -BackupType full
```

---

## Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks for configuration management
├── bash/                 # Shell scripts for Linux environments
├── powershell/          # PowerShell scripts for Windows and Azure management
├── python/              # Python scripts for Azure service automation
└── terraform/           # Terraform configurations (alternative to Bicep)
    ├── management-groups/    # Management group configurations
    ├── policies/            # Policy definitions and assignments
    ├── networking/          # Hub-spoke and connectivity configurations
    └── security/            # Security baseline configurations
```

---

## Governance Framework

### Policy Implementation
```bash
# Deploy CAF-compliant policies
python policy-deployment.py \
  --framework caf \
  --compliance-level enterprise \
  --policy-initiatives security,governance,cost \
  --automatic-remediation

# Monitor policy compliance
python policy-monitoring.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --compliance-threshold 95 \
  --alert-on-drift \
  --weekly-reports
```

### Blueprint Management
```bash
# Version control for blueprints
python blueprint-versioning.py \
  --blueprint-name enterprise-landing-zone \
  --version v2.0 \
  --change-log ./blueprints/CHANGELOG.md

# Blueprint assignment tracking
python blueprint-tracking.py \
  --management-group $MANAGEMENT_GROUP_ID \
  --track-assignments \
  --update-notifications \
  --compliance-dashboard
```

---

## Security and Compliance

### Security Baseline Implementation
```bash
# CIS Azure Security Benchmark
python security-baseline.py \
  --benchmark cis-azure-1.4.0 \
  --scope management-group \
  --target $MANAGEMENT_GROUP_ID \
  --auto-remediate

# NIST Cybersecurity Framework
python security-baseline.py \
  --framework nist-csf \
  --maturity-level 3 \
  --assessment-scope all-subscriptions \
  --generate-gap-analysis
```

### Compliance Automation
```bash
# SOC 2 compliance monitoring
python compliance-automation.py \
  --framework soc2 \
  --control-families cc,a1 \
  --evidence-collection automated \
  --audit-trail ./compliance/soc2-evidence

# GDPR compliance checking
python compliance-automation.py \
  --regulation gdpr \
  --data-classification-scan \
  --privacy-controls \
  --breach-notification-setup
```

---

## Error Handling and Troubleshooting

### Common Issues

#### Management Group Permissions
```bash
# Check management group permissions
az role assignment list --scope /providers/Microsoft.Management/managementGroups/$MANAGEMENT_GROUP_ID

# Grant required permissions
python rbac-automation.py --grant-mg-permissions --user-principal-name admin@company.com
```

#### Policy Assignment Failures
```bash
# Troubleshoot policy assignments
python policy-troubleshooting.py \
  --assignment-id policy-assignment-id \
  --check-scope-permissions \
  --validate-policy-definition

# Remediate non-compliant resources
az policy remediation create --policy-assignment policy-assignment-id
```

#### Networking Connectivity Issues
```bash
# Network troubleshooting
python connectivity-troubleshooting.py \
  --source-vm source-vm-id \
  --destination-endpoint destination-fqdn \
  --include-route-table-analysis \
  --include-nsg-analysis
```

### Monitoring Commands
```bash
# Check landing zone health
az monitor activity-log list --resource-group management-rg --max-events 50
az policy state list --management-group $MANAGEMENT_GROUP_ID --filter "complianceState eq 'NonCompliant'"
az security assessment list --query "[?status.code=='Unhealthy']"
```

---

## Best Practices and Recommendations

### Naming Conventions
- Use consistent naming patterns across all resources
- Implement naming policies through Azure Policy
- Include environment, location, and purpose in resource names
- Use abbreviations defined in Microsoft CAF

### Resource Organization
- Align resource groups with application lifecycles
- Use management group hierarchy for governance at scale
- Implement consistent tagging strategy
- Separate shared services from application workloads

### Security Recommendations
- Enable Microsoft Defender for all supported resource types
- Use managed identities instead of service principals
- Implement least privilege access principles
- Enable logging and monitoring for all critical resources
- Use private endpoints for platform services

### Cost Optimization
- Implement cost management budgets and alerts
- Use reserved instances for predictable workloads
- Monitor and optimize resource utilization
- Implement automated resource lifecycle management

---

**Directory Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Azure Cloud Adoption Framework DevOps Team
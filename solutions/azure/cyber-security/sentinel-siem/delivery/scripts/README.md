# Scripts - Azure Sentinel SIEM

## Overview

This directory contains automation scripts and utilities for Azure Sentinel SIEM solution deployment, testing, and operations. Provides comprehensive Security Information and Event Management (SIEM) capabilities using Microsoft Sentinel, Log Analytics, and integrated Azure security services for threat detection, investigation, and response.

---

## Script Categories

### Infrastructure Scripts
- **sentinel-workspace-setup.py** - Log Analytics workspace and Sentinel configuration
- **data-connector-setup.py** - Multi-source data connector configuration
- **watchlist-management.py** - Threat intelligence and watchlist management
- **workspace-configuration.py** - Sentinel workspace settings and features
- **retention-policy-setup.py** - Data retention and archival policies

### Data Collection Scripts
- **azure-activity-connector.py** - Azure Activity Log connector configuration
- **office365-connector.py** - Microsoft 365 security events integration
- **threat-intelligence-connector.py** - Threat intelligence feeds integration
- **custom-log-connector.py** - Custom log source integration
- **cef-syslog-setup.py** - Common Event Format and Syslog configuration

### Analytics Rules Scripts
- **analytics-rules-deployment.py** - Security analytics rules deployment
- **custom-detection-rules.py** - Custom threat detection rule creation
- **scheduled-rules-management.py** - Scheduled analytics rules management
- **fusion-rules-setup.py** - ML-based Fusion correlation rules
- **anomaly-rules-config.py** - User and entity behavior analytics (UEBA) rules

### Automation Scripts
- **playbook-deployment.py** - Security orchestration playbook deployment
- **logic-app-integration.py** - Azure Logic Apps integration for automation
- **incident-response-automation.py** - Automated incident response workflows
- **threat-hunting-automation.py** - Automated threat hunting queries
- **soar-integration.py** - Security Orchestration, Automation, and Response setup

### Investigation Scripts
- **hunting-queries-deployment.py** - Threat hunting query deployment
- **investigation-notebooks.py** - Jupyter notebooks for security investigations
- **entity-behavior-analysis.py** - User and entity behavior analysis
- **timeline-analysis.py** - Security incident timeline reconstruction
- **threat-intelligence-analysis.py** - IOC and threat actor analysis

### Testing Scripts
- **detection-testing.py** - Security rule testing and validation
- **data-ingestion-testing.py** - Data connector validation
- **alert-testing.py** - Alert generation and notification testing
- **playbook-testing.py** - Automated response playbook testing
- **performance-testing.py** - SIEM performance and scalability testing

### Operations Scripts
- **health-monitoring.py** - Sentinel workspace health monitoring
- **cost-optimization.py** - Log Analytics and Sentinel cost optimization
- **compliance-reporting.py** - Security compliance reporting
- **kql-query-optimization.py** - Kusto Query Language optimization
- **backup-management.py** - Configuration backup and disaster recovery

---

## Prerequisites

### Required Tools
- **Azure CLI v2.50+** - Azure command line interface
- **Azure PowerShell v9.0+** - PowerShell modules for Azure
- **Python 3.9+** - Python runtime environment
- **KQL** - Kusto Query Language for log analytics
- **PowerShell Core** - Cross-platform PowerShell
- **Git** - Version control for rule management

### Azure Services Required
- Microsoft Sentinel (SIEM platform)
- Azure Log Analytics (data storage and analytics)
- Azure Logic Apps (automation workflows)
- Azure Key Vault (secrets management)
- Azure Active Directory (identity and access)
- Azure Monitor (monitoring and alerting)
- Azure Storage Account (configuration and artifacts)
- Microsoft Graph (Microsoft 365 integration)

### Python Dependencies
```bash
pip install azure-identity azure-mgmt-securityinsight azure-monitor-query
pip install azure-mgmt-loganalytics azure-mgmt-logic azure-storage-blob
pip install requests pandas numpy jupyter plotly msticpy
```

### PowerShell Modules
```powershell
Install-Module -Name Az -Force -AllowClobber
Install-Module -Name Az.SecurityInsights -Force
Install-Module -Name Az.OperationalInsights -Force
Install-Module -Name Az.LogicApp -Force
Install-Module -Name Microsoft.Graph -Force
```

### Configuration
```bash
# Azure CLI authentication with Security Reader/Contributor permissions
az login --tenant "your-tenant-id"
az account set --subscription "security-subscription-id"

# Set environment variables
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_SUBSCRIPTION_ID="security-subscription-id"
export RESOURCE_GROUP_NAME="sentinel-security-rg"
export WORKSPACE_NAME="sentinel-security-workspace"
export AZURE_LOCATION="eastus"
export ENVIRONMENT="production"
```

```powershell
# PowerShell Azure authentication
Connect-AzAccount -TenantId "your-tenant-id"
Set-AzContext -SubscriptionId "security-subscription-id"

# Environment variables
$env:AZURE_TENANT_ID = "your-tenant-id"
$env:AZURE_SUBSCRIPTION_ID = "security-subscription-id"
$env:RESOURCE_GROUP_NAME = "sentinel-security-rg"
$env:WORKSPACE_NAME = "sentinel-security-workspace"
```

---

## Usage Instructions

### Sentinel Workspace Setup
```bash
# Create Log Analytics workspace and enable Sentinel
python sentinel-workspace-setup.py \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $WORKSPACE_NAME \
  --location $AZURE_LOCATION \
  --pricing-tier PerGB2018 \
  --retention-days 90

# Configure workspace settings
python workspace-configuration.py \
  --workspace-name $WORKSPACE_NAME \
  --enable-ueba \
  --enable-entity-behavior-analytics \
  --enable-anomalies \
  --threat-intelligence-indicators

# Setup data retention policies
python retention-policy-setup.py \
  --workspace-name $WORKSPACE_NAME \
  --default-retention 90 \
  --table-specific-retention ./config/retention-policies.json \
  --enable-archive-policy
```

```powershell
# PowerShell workspace setup
.\sentinel-workspace-setup.ps1 -ResourceGroupName $env:RESOURCE_GROUP_NAME -WorkspaceName $env:WORKSPACE_NAME -Location eastus
```

### Data Connector Configuration
```bash
# Configure Azure Activity Log connector
python azure-activity-connector.py \
  --workspace-name $WORKSPACE_NAME \
  --subscription-ids all \
  --enable-policy-evaluation \
  --enable-administrative-operations

# Setup Microsoft 365 connector
python office365-connector.py \
  --workspace-name $WORKSPACE_NAME \
  --enable-sharepoint \
  --enable-exchange \
  --enable-teams \
  --tenant-id $AZURE_TENANT_ID

# Configure threat intelligence connector
python threat-intelligence-connector.py \
  --workspace-name $WORKSPACE_NAME \
  --threat-feeds microsoft,anomali,recordedfuture \
  --polling-interval 3600 \
  --enable-automatic-indicators

# Setup custom log connectors
python custom-log-connector.py \
  --workspace-name $WORKSPACE_NAME \
  --connector-type syslog \
  --data-source-config ./config/custom-data-sources.json

# Configure CEF and Syslog
python cef-syslog-setup.py \
  --workspace-name $WORKSPACE_NAME \
  --syslog-facilities auth,authpriv,daemon,mail \
  --cef-devices ./config/cef-devices.json \
  --enable-parsing
```

### Analytics Rules Deployment
```bash
# Deploy built-in analytics rules
python analytics-rules-deployment.py \
  --workspace-name $WORKSPACE_NAME \
  --rule-templates ./templates/analytics-rules/ \
  --severity-filter high,medium \
  --enable-all-rules

# Create custom detection rules
python custom-detection-rules.py \
  --workspace-name $WORKSPACE_NAME \
  --rule-definitions ./rules/custom-detections.json \
  --test-rules \
  --validate-kql

# Configure scheduled analytics rules
python scheduled-rules-management.py \
  --workspace-name $WORKSPACE_NAME \
  --schedule-config ./config/rule-schedules.json \
  --enable-suppression \
  --incident-grouping

# Setup Fusion rules
python fusion-rules-setup.py \
  --workspace-name $WORKSPACE_NAME \
  --enable-fusion-detections \
  --scenario-based-detections \
  --advanced-multistage-attacks

# Configure anomaly detection
python anomaly-rules-config.py \
  --workspace-name $WORKSPACE_NAME \
  --enable-ueba \
  --entity-types user,host,ip \
  --threshold-sensitivity medium
```

### Security Automation Setup
```bash
# Deploy security playbooks
python playbook-deployment.py \
  --resource-group $RESOURCE_GROUP_NAME \
  --playbook-templates ./playbooks/ \
  --connector-authentication managed-identity \
  --enable-all-playbooks

# Configure Logic App integration
python logic-app-integration.py \
  --resource-group $RESOURCE_GROUP_NAME \
  --trigger-types sentinel-alert,sentinel-incident \
  --actions email,teams,servicenow \
  --authentication-config ./config/logic-app-auth.json

# Setup incident response automation
python incident-response-automation.py \
  --workspace-name $WORKSPACE_NAME \
  --automation-rules ./automation/incident-rules.json \
  --escalation-matrix ./config/escalation-matrix.json \
  --sla-enforcement

# Configure threat hunting automation
python threat-hunting-automation.py \
  --workspace-name $WORKSPACE_NAME \
  --hunting-schedules ./hunting/scheduled-hunts.json \
  --automated-bookmarks \
  --findings-correlation
```

### Threat Hunting and Investigation
```bash
# Deploy hunting queries
python hunting-queries-deployment.py \
  --workspace-name $WORKSPACE_NAME \
  --query-categories ./hunting-queries/ \
  --mitre-attack-mapping \
  --scheduled-execution

# Setup investigation notebooks
python investigation-notebooks.py \
  --workspace-name $WORKSPACE_NAME \
  --notebook-templates ./notebooks/ \
  --enable-msticpy \
  --threat-intelligence-integration

# Configure entity behavior analysis
python entity-behavior-analysis.py \
  --workspace-name $WORKSPACE_NAME \
  --entity-types user,device,ip,url \
  --baseline-learning-period 14 \
  --anomaly-scoring

# Setup timeline analysis
python timeline-analysis.py \
  --workspace-name $WORKSPACE_NAME \
  --incident-reconstruction \
  --attack-chain-analysis \
  --automated-timeline-generation

# Configure threat intelligence analysis
python threat-intelligence-analysis.py \
  --workspace-name $WORKSPACE_NAME \
  --ioc-matching \
  --threat-actor-mapping \
  --campaign-tracking \
  --diamond-model-analysis
```

### Testing and Validation
```bash
# Test detection rules
python detection-testing.py \
  --workspace-name $WORKSPACE_NAME \
  --test-data ./test-data/attack-simulations.json \
  --rule-validation \
  --false-positive-analysis

# Validate data ingestion
python data-ingestion-testing.py \
  --workspace-name $WORKSPACE_NAME \
  --data-connectors all \
  --ingestion-lag-check \
  --data-quality-validation

# Test alert notifications
python alert-testing.py \
  --workspace-name $WORKSPACE_NAME \
  --notification-channels email,teams,webhook \
  --test-scenarios ./tests/alert-scenarios.json

# Validate playbook execution
python playbook-testing.py \
  --resource-group $RESOURCE_GROUP_NAME \
  --playbooks all \
  --test-triggers \
  --execution-validation \
  --performance-metrics

# Performance testing
python performance-testing.py \
  --workspace-name $WORKSPACE_NAME \
  --query-performance \
  --ingestion-capacity \
  --concurrent-investigations \
  --scalability-limits
```

### Operations and Monitoring
```bash
# Monitor Sentinel health
python health-monitoring.py \
  --workspace-name $WORKSPACE_NAME \
  --check-data-connectors \
  --check-analytics-rules \
  --check-automation-rules \
  --alert-on-issues

# Optimize costs
python cost-optimization.py \
  --workspace-name $WORKSPACE_NAME \
  --analyze-ingestion-volume \
  --table-optimization-recommendations \
  --retention-policy-optimization \
  --pricing-tier-analysis

# Generate compliance reports
python compliance-reporting.py \
  --workspace-name $WORKSPACE_NAME \
  --frameworks nist,iso27001,pci-dss \
  --coverage-analysis \
  --gap-assessment \
  --export-format pdf

# Optimize KQL queries
python kql-query-optimization.py \
  --workspace-name $WORKSPACE_NAME \
  --slow-query-analysis \
  --optimization-recommendations \
  --query-performance-baseline
```

---

## Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks for configuration management
├── bash/                 # Shell scripts for Linux environments  
├── powershell/          # PowerShell scripts for Windows and Azure
├── python/              # Python scripts for Sentinel automation
└── terraform/           # Terraform configurations for infrastructure
    ├── sentinel-workspace/   # Workspace configuration
    ├── data-connectors/     # Connector configurations
    ├── analytics-rules/     # Detection rule definitions
    └── automation/          # Playbook and automation configurations
```

---

## Security Use Cases

### Advanced Persistent Threat (APT) Detection
```bash
# Deploy APT hunting queries
python hunting-queries-deployment.py \
  --category apt-detection \
  --queries lateral-movement,persistence,exfiltration \
  --mitre-techniques T1078,T1055,T1041

# Configure behavioral analytics for APT
python entity-behavior-analysis.py \
  --use-case apt-detection \
  --long-term-baseline \
  --anomaly-correlation
```

### Insider Threat Detection
```bash
# Setup insider threat analytics
python analytics-rules-deployment.py \
  --category insider-threat \
  --rules data-exfiltration,privilege-escalation,anomalous-access \
  --sensitivity high

# Configure UEBA for insider threats
python anomaly-rules-config.py \
  --focus insider-threat \
  --entity-types user \
  --behavioral-baselines
```

### Cloud Security Monitoring
```bash
# Deploy cloud-specific detections
python analytics-rules-deployment.py \
  --category cloud-security \
  --rules azure-privilege-escalation,unusual-sign-ins,resource-manipulation \
  --cloud-workbook-integration

# Configure cloud workload protection
python data-connector-setup.py \
  --connectors azure-security-center,aws-cloudtrail,gcp-cloud-audit \
  --multi-cloud-correlation
```

---

## MITRE ATT&CK Integration

### Technique Mapping
```bash
# Map detections to MITRE ATT&CK
python mitre-attack-mapping.py \
  --workspace-name $WORKSPACE_NAME \
  --update-rule-mappings \
  --coverage-analysis \
  --gap-identification

# Deploy technique-specific hunts
python hunting-queries-deployment.py \
  --mitre-techniques T1566,T1053,T1105 \
  --automated-threat-hunting \
  --technique-coverage-metrics
```

### Navigator Integration
```bash
# Generate MITRE Navigator layers
python mitre-navigator-integration.py \
  --workspace-name $WORKSPACE_NAME \
  --coverage-layer \
  --detection-layer \
  --export-navigator-json
```

---

## Incident Response Integration

### SOAR Platform Integration
```bash
# Integrate with Phantom/Splunk SOAR
python soar-integration.py \
  --platform phantom \
  --sentinel-webhook-url \
  --bidirectional-sync \
  --case-management

# Integrate with Demisto/Cortex XSOAR
python soar-integration.py \
  --platform xsoar \
  --integration-instance \
  --playbook-sync \
  --investigation-mirroring
```

### ServiceNow Integration
```bash
# Configure ServiceNow ITSM integration
python servicenow-integration.py \
  --instance-url your-instance.service-now.com \
  --table-mapping incident,security_incident \
  --field-mapping ./config/servicenow-mapping.json \
  --automated-ticket-creation
```

---

## Error Handling and Troubleshooting

### Common Issues

#### Data Connector Failures
```bash
# Diagnose connector issues
python data-connector-troubleshooting.py \
  --workspace-name $WORKSPACE_NAME \
  --connector-name AzureActivity \
  --check-permissions \
  --validate-configuration

# Fix authentication issues
python connector-authentication-fix.py \
  --connector-type office365 \
  --reset-consent \
  --update-service-principal
```

#### Analytics Rule Performance
```bash
# Optimize slow-running rules
python rule-performance-optimization.py \
  --workspace-name $WORKSPACE_NAME \
  --slow-rules-threshold 60 \
  --optimize-kql \
  --performance-recommendations

# Debug rule failures
python rule-debugging.py \
  --workspace-name $WORKSPACE_NAME \
  --rule-name "Suspicious Login Activity" \
  --execution-logs \
  --error-analysis
```

#### Playbook Execution Issues
```bash
# Troubleshoot playbook failures
python playbook-troubleshooting.py \
  --playbook-name "Block IP Address" \
  --execution-history \
  --permission-check \
  --connector-validation
```

### Monitoring Commands
```bash
# Check Sentinel service health
az monitor activity-log list --resource-group $RESOURCE_GROUP_NAME --max-events 20
az securityinsight data-connector list --resource-group $RESOURCE_GROUP_NAME --workspace-name $WORKSPACE_NAME
az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP_NAME --workspace-name $WORKSPACE_NAME
```

---

## Best Practices and Recommendations

### Detection Engineering
- Follow the detection-as-code principle
- Version control all analytics rules and hunting queries
- Implement rule testing and validation pipelines
- Maintain low false positive rates through tuning
- Map detections to MITRE ATT&CK framework

### Data Management
- Implement tiered data retention policies
- Use table-level retention for cost optimization
- Archive historical data for compliance
- Monitor data ingestion volumes and costs
- Optimize table schemas for query performance

### Automation Guidelines
- Use managed identities for authentication
- Implement error handling and retry logic
- Test playbooks in non-production environments
- Monitor automation execution metrics
- Maintain playbook documentation and runbooks

### Performance Optimization
- Use query summarization and materialized views
- Implement query caching strategies
- Optimize KQL queries for large datasets
- Monitor workspace performance metrics
- Scale workspace resources based on demand

---

## Compliance and Governance

### Regulatory Compliance
- Map security controls to regulatory frameworks
- Implement evidence collection for audits
- Maintain chain of custody for investigations
- Document incident response procedures
- Ensure data residency and sovereignty requirements

### Privacy and Data Protection
- Implement data classification and labeling
- Use data loss prevention (DLP) integration
- Maintain privacy by design principles
- Implement user consent and data subject rights
- Regular privacy impact assessments

---

**Directory Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Azure Security Operations DevOps Team
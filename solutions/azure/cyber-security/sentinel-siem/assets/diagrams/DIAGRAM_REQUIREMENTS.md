# Microsoft Sentinel SIEM - Architecture Diagram Requirements

## Required Components

### 1. Data Ingestion Layer
- **Microsoft Sentinel** - Cloud-native SIEM
- **Log Analytics Workspace** - Data repository
- **Data Connectors** - Azure AD, Office 365, Firewall, Defender for Cloud

### 2. Security Operations
- **Analytics Rules** - Threat detection (KQL queries)
- **Microsoft Defender for Cloud** - Workload protection
- **Automation Rules** - Triage and response

### 3. SOAR & Response
- **Logic Apps** - Automated playbooks for incident response
- **Watchlists** - Known good/bad entities
- **Threat Intelligence** - External threat feeds

### 4. Monitoring
- **Workbooks** - Security dashboards
- **Azure Monitor** - Platform monitoring
- **Incidents & Cases** - Investigation tracking

## Azure Services

| Component | Icon Color |
|-----------|-----------|
| Microsoft Sentinel | Purple |
| Log Analytics | Gray |
| Logic Apps | Blue |
| Defender for Cloud | Red |

## References
- **Sentinel Docs**: https://learn.microsoft.com/en-us/azure/sentinel/

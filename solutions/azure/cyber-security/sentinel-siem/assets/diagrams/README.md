# Microsoft Sentinel SIEM - Architecture Diagram

## Key Components
1. **Data Connectors** - Ingest security logs from Azure, Office 365, firewalls, endpoints
2. **Log Analytics** - Store and query security data
3. **Sentinel Analytics** - Detect threats with KQL rules
4. **Logic Apps (SOAR)** - Automate incident response workflows
5. **Defender for Cloud** - Protect workloads and generate security alerts
6. **Workbooks** - Visualize security posture and incidents

## Flow
```
1. Data connectors ingest logs → Log Analytics Workspace
2. Analytics rules analyze logs → Generate security incidents
3. Automation rules triage → Assign to SOC analysts
4. Logic Apps playbooks → Automated containment and remediation
5. Workbooks display → Security metrics and incident trends
```

# Architecture Diagrams - Azure Sentinel SIEM

## Files in this Directory

- `architecture-diagram.png` - Generated architecture diagram (embedded in presentations/documents)
- `generate_diagram.py` - Python script to generate diagram using diagrams library
- `architecture-diagram.drawio` - Editable Draw.io source with Azure icons
- `DIAGRAM_REQUIREMENTS.md` - Architecture requirements and component details
- `README.md` - This file

## Generating the Diagram

### Using Python Script

```bash
# Install required library
pip install diagrams

# Generate diagram
python3 generate_diagram.py
```

This will create `architecture-diagram.png` showing the complete Azure Sentinel SIEM architecture.

### Using Draw.io

1. Open `architecture-diagram.drawio` in Draw.io (https://app.diagrams.net)
2. The diagram includes Azure-specific icons and proper grouping
3. Modify as needed for your specific requirements
4. Export as PNG: File → Export as → PNG
5. Save as `architecture-diagram.png` in this directory

## Updating the Diagram

When updating the architecture:

1. **For minor changes:** Edit `architecture-diagram.drawio` and export PNG
2. **For major changes:** Update `generate_diagram.py` to reflect new architecture, then regenerate
3. **Always update:** `DIAGRAM_REQUIREMENTS.md` to document architectural changes
4. **Regenerate documents:** After updating PNG, regenerate presentation and SOW documents

## Architecture Overview

The diagram illustrates:

- **Data Ingestion Layer**: Azure Sentinel connectors for Office 365, Azure AD, Defender, firewalls, network, and third-party sources
- **Analytics Engine**: KQL detection rules, ML models, threat intelligence integration, UEBA
- **Incident Management**: Automated incident creation, correlation, investigation workbooks, advanced hunting
- **SOAR Automation**: Logic Apps playbooks for 50+ attack scenarios, auto-remediation, integration
- **Integration Hub**: Ticketing systems (ServiceNow, Jira), communication tools (Teams, Slack), external security tools
- **Compliance & Governance**: RBAC, audit logging, compliance reporting (HIPAA, PCI-DSS, GDPR, SOC 2)
- **Monitoring**: Azure Monitor, health dashboards, operational metrics

## Customization Notes

- Replace placeholder Azure region names with actual deployment region
- Update data source names to reflect actual organization sources
- Adjust connector specifications based on actual volume and velocity
- Add additional integrations as needed (Power BI, SharePoint, etc.)
- Include specific playbook names for organization-specific workflows
- Update retention periods to match compliance requirements
- Reflect actual RBAC groups for organization structure

## Related Documentation

- `DIAGRAM_REQUIREMENTS.md` - Detailed architecture requirements and data flows
- Solution Briefing - Executive-level presentation with high-level architecture overview
- Statement of Work - Detailed implementation approach and deliverables
- Cost Breakdown - Pricing details for Sentinel and Log Analytics services

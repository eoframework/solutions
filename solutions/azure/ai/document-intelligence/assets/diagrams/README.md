# Architecture Diagrams - Azure AI Document Intelligence

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

This will create `architecture-diagram.png` showing the complete Azure AI Document Intelligence architecture.

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
- **Document Ingestion**: Azure Blob Storage with Event Grid triggers
- **AI Processing**: Azure AI Document Intelligence and Cognitive Services
- **Orchestration**: Azure Functions and Logic Apps
- **Data Storage**: Azure Cosmos DB for extracted data
- **Integration**: Azure API Management for external systems
- **Security**: Private endpoints, managed identities, Key Vault
- **Monitoring**: Azure Monitor and Application Insights

## Customization Notes

- Replace placeholder values with actual Azure resource names
- Update subnet CIDR ranges to match client network design
- Adjust Azure service tiers based on actual sizing (e.g., Functions Premium vs. Consumption)
- Add additional integrations as needed (e.g., PowerBI, SharePoint, Dynamics)

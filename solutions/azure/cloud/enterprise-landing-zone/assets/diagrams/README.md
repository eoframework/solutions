# Architecture Diagrams - Azure Enterprise Landing Zone

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

This will create `architecture-diagram.png` showing the complete Azure Enterprise Landing Zone architecture with management groups, hub-spoke networking, and security controls.

### Using Draw.io

1. Open `architecture-diagram.drawio` in Draw.io (https://app.diagrams.net)
2. The diagram includes Azure-specific icons and proper hierarchical grouping
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
- **Management Groups**: Hierarchical structure (Platform, Landing Zones, Sandboxes, Decommissioned) for governance
- **Hub-Spoke Networking**: Azure Virtual WAN with Azure Firewall and ExpressRoute for hybrid connectivity
- **Security Controls**: Azure Sentinel, Microsoft Defender for Cloud, Azure Policy for threat protection
- **Identity & Access**: Azure AD with Conditional Access, PIM, and RBAC for zero-trust security
- **Subscription Vending**: Automated provisioning with pre-configured policies and network integration
- **Monitoring**: Centralized logging with Log Analytics Workspace and Azure Monitor

## Customization Notes

- Replace placeholder CIDR ranges with actual network design (Hub: 10.0.0.0/22, Spokes: 10.1.0.0/16)
- Update management group names to match organizational structure
- Adjust Azure service tiers based on actual sizing (e.g., Firewall Premium vs. Standard)
- Add additional spoke VNets for specific application landing zones
- Include custom Azure Policy assignments for organizational compliance requirements

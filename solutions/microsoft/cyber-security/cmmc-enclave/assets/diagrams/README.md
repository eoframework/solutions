# Architecture Diagram Generation

To generate the PNG file from the Draw.io diagram:

1. Open `architecture-diagram.drawio` in Draw.io (https://app.diagrams.net)
2. Replace generic rectangles with proper Microsoft Azure and Microsoft 365 icons:
   - Click "More Shapes..." → Search "Microsoft Azure" and "Microsoft 365" → Apply
   - Drag icons from sidebar to replace placeholder rectangles
3. Export as PNG: File → Export as → PNG
   - Settings: Transparent background, 300 DPI, Border width: 10
4. Save as `architecture-diagram.png` in this directory

## Diagram Overview

The architecture diagram shows the Microsoft CMMC GCC High Enclave solution including:

- **User Access & Identity**: CAC/PIV smart card authentication, Azure AD GCC High with MFA
- **Microsoft 365 GCC High**: Exchange Online, SharePoint, Teams, OneDrive for CUI data
- **Azure Government Cloud**: Virtual machines, encrypted storage, ExpressRoute connectivity
- **Security & Compliance**: Sentinel SIEM, Defender for Cloud, Microsoft Purview, Compliance Manager
- **Infrastructure Services**: Azure Key Vault (FIPS 140-2), Azure Monitor, Azure Backup

All components operate within the FedRAMP High authorized CMMC Level 2 compliance zone.

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

The architecture diagram shows the Microsoft 365 Enterprise Deployment solution including:

- **On-Premises Infrastructure**: Active Directory, Exchange (hybrid), file servers
- **Identity Integration**: Azure AD Connect sync, Azure AD with SSO, Conditional Access policies
- **Microsoft 365 E5 Services**: Exchange Online, SharePoint, Teams, OneDrive, Teams Phone System
- **Security & Compliance**: Defender for Office 365, Defender for Endpoint, Microsoft Purview, eDiscovery
- **Device Management**: Microsoft Intune MDM, Windows Autopilot provisioning
- **Monitoring & Analytics**: Usage analytics, compliance center, security dashboard

The migration flow shows the progression from on-premises through hybrid coexistence to cloud-only deployment.

# Architecture Diagram Requirements - Azure Virtual Desktop

## Overview
This document specifies the requirements for creating a SIMPLE, clear architecture diagram for the Azure Virtual Desktop solution.

## Diagram Scope: SIMPLE (6-8 Components Maximum)

### Components to Include
1. **Users (External)** - Represented as multiple user icons at the top
2. **Azure AD** - Identity and authentication service (center-left)
3. **AVD Host Pool** - Container showing 20 session host VMs (center)
4. **Azure Files (FSLogix)** - Profile storage (bottom-left)
5. **Azure Monitor** - Monitoring and logging (bottom-right)
6. **Virtual Network** - Optional, network boundary (background)

### Data Flows to Show (4-5 Maximum)
1. **User Authentication**: Users → Azure AD
2. **Session Assignment**: Azure AD → AVD Host Pool
3. **Profile Management**: AVD Host Pool ↔ Azure Files
4. **Monitoring**: AVD Host Pool → Azure Monitor
5. **Data Access**: AVD Host Pool ↔ Applications/Data

## Visual Style Requirements

### Layout
- **Orientation**: Horizontal (left-to-right data flow)
- **Canvas**: Minimum 1200x800 pixels
- **Margins**: 50px on all sides

### Component Design
- **Boxes**: Large, rounded rectangles with clear labels
- **Size**: Minimum 120x80 pixels per component
- **Colors**:
  - Azure services: Light blue (#0078D4) with white text
  - External: Light gray (#F5F5F5) with black text
  - Data flows: Dark blue (#003366) arrows

### Typography
- **Font**: Arial or Segoe UI (sans-serif)
- **Header**: 24pt bold (component titles)
- **Labels**: 12pt regular (descriptions)
- **Flow labels**: 11pt italic (data flow descriptions)

### Data Flow Lines
- **Width**: 2-3px
- **Color**: Dark blue (#003366) or green (#107C10)
- **Direction**: Arrows pointing toward destination
- **Labels**: Above or below line, centered, 11pt italic

## Component Specifications

### Users (Top-Left)
- **Label**: "100 Users (Global)"
- **Description**: "Remote workers worldwide"
- **Icon Style**: Multiple user silhouettes or single user icon

### Azure AD (Top-Center)
- **Label**: "Azure AD"
- **Description**: "Authentication & SSO"
- **Size**: 150x80px

### AVD Host Pool (Center)
- **Label**: "AVD Host Pool"
- **Description**: "20 x D4s_v5 VMs (Windows 11 Multi-Session)"
- **Sub-elements**: Show 3-4 VM boxes inside container to represent servers
- **VM label**: "5 users/VM"

### Azure Files (Bottom-Left)
- **Label**: "Azure Files Premium"
- **Description**: "500GB - FSLogix Profiles"

### Azure Monitor (Bottom-Right)
- **Label**: "Azure Monitor"
- **Description**: "Logging & Performance Metrics"

### Virtual Network (Background - Optional)
- **Style**: Dashed border around main components
- **Label**: "Azure Virtual Network"

## Data Flow Specifications

### Flow 1: Authentication
- **From**: Users → **To**: Azure AD
- **Label**: "Authentication Request"
- **Icon**: Lock symbol (optional)

### Flow 2: Session Assignment
- **From**: Azure AD → **To**: AVD Host Pool
- **Label**: "Session Broker Assignment"

### Flow 3: Profile Access
- **From**: AVD Host Pool ↔ **To**: Azure Files
- **Bidirectional**: Yes
- **Label**: "FSLogix Profile Sync"

### Flow 4: Monitoring
- **From**: AVD Host Pool → **To**: Azure Monitor
- **Label**: "Telemetry & Audit Logs"

### Flow 5: Data Access
- **From**: AVD Host Pool → **To**: External (optional)
- **Label**: "Apps & Data Access"

## Export Requirements

### PNG Export
- **Resolution**: 1920x1200 pixels (300 DPI equivalent)
- **Format**: PNG with transparent background
- **Filename**: `architecture-diagram.png`

### Draw.io Export
- **Format**: XML/Draw.io native format
- **Filename**: `architecture-diagram.drawio`
- **Editable**: Must be fully editable in Draw.io web/desktop

### ASCII Diagram (Fallback)
- **Purpose**: Text-based documentation reference
- **Format**: Plain text in markdown
- **Include**: In README.md for easy viewing

## Complexity Guidelines

### DO:
- Use simple, geometric shapes (rectangles, circles)
- Keep text concise and readable
- Use consistent spacing and alignment
- Show clear directional flow with arrows
- Use standard Azure icons if available
- Include legend/key if needed

### DO NOT:
- Add unnecessary detail or sub-components
- Use complex 3D effects or shadows
- Include infrastructure details (IP addresses, ports)
- Show internal component architecture
- Use more than 8 total components
- Add decorative elements

## Validation Checklist

- [ ] Maximum 8 components total
- [ ] All 5 data flows clearly visible
- [ ] Text is readable (12pt minimum)
- [ ] Components are properly labeled
- [ ] Diagram follows left-to-right flow
- [ ] Colors are consistent and accessible
- [ ] PNG export is high quality (1920x1200+)
- [ ] Draw.io file is editable
- [ ] No sensitive information exposed
- [ ] Diagram matches solution architecture

## File Outputs

1. **architecture-diagram.png** - PNG image file (1920x1200)
2. **architecture-diagram.drawio** - Draw.io editable file
3. **ASCII diagram reference** - Text in README.md

---

*Last Updated: November 2025*

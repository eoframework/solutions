# Google Cloud Landing Zone - Architecture Diagram

## Overview
This diagram illustrates the GCP Landing Zone architecture with Cloud Foundation Toolkit, Shared VPC hub-spoke network, and centralized security controls.

## Required Components

### 1. Organization Foundation
- **GCP Organization**
  - Hierarchical resource management
  - Centralized billing
  - Organization policies

- **Folder Structure**
  - Development folder
  - Staging folder
  - Production folder

### 2. Identity & Access
- **Cloud Identity Premium**
  - SAML SSO integration
  - Directory sync (GCDS)
  - Advanced security features

- **IAM**
  - Organization-level roles
  - Folder-level inheritance
  - Service accounts

### 3. Network Architecture
- **Shared VPC (Hub)**
  - Central networking project
  - Subnets across 3 regions
  - Cloud NAT gateways
  - Cloud Load Balancer

- **Dedicated Interconnect**
  - 10 Gbps on-premises connectivity
  - VLAN attachments
  - Cloud Router for BGP

- **Spoke Projects**
  - Application team projects
  - VPC peering to hub
  - Private Google Access

### 4. Security & Compliance
- **Security Command Center Premium**
  - Continuous threat detection
  - Compliance monitoring
  - Security posture management

- **Chronicle SIEM**
  - Advanced security analytics
  - Threat intelligence
  - Incident response

- **Cloud Armor**
  - DDoS protection
  - WAF rules
  - Rate limiting

- **Cloud IDS**
  - Network intrusion detection
  - VPC traffic inspection

### 5. Governance & Automation
- **Cloud Foundation Toolkit**
  - Terraform modules
  - Project factory
  - Repeatable deployments

- **Organization Policies**
  - Resource location restrictions
  - Service enablement controls
  - Compliance enforcement

### 6. Monitoring & Operations
- **Cloud Logging**
  - Centralized log sinks
  - BigQuery exports
  - Long-term retention

- **Cloud Monitoring**
  - Centralized dashboards
  - SLO monitoring
  - Budget alerts

- **Cloud KMS**
  - Customer-managed encryption keys
  - Key rotation policies

## Diagram Layout

### Hierarchical Layout (Top to Bottom)
1. **Organization Layer** - GCP Organization with folder hierarchy
2. **Identity Layer** - Cloud Identity and IAM
3. **Network Layer** - Shared VPC hub-spoke with Interconnect
4. **Security Layer** - SCC, Chronicle, Cloud Armor, Cloud IDS
5. **Governance Layer** - Organization policies and Terraform automation
6. **Monitoring Layer** - Logging, Monitoring, alerting

### Flow Description
1. **Organization Setup** → Folders created (dev/staging/prod)
2. **Identity Integration** → Cloud Identity synced with on-premises AD
3. **Network Foundation** → Shared VPC deployed with Interconnect
4. **Security Baseline** → SCC Premium and Chronicle configured
5. **Governance Automation** → Terraform modules for project provisioning
6. **Monitoring Setup** → Centralized logging and dashboards

## GCP Icon Guidelines
- Use official Google Cloud Architecture Icons
- Download from: https://cloud.google.com/icons
- Maintain consistent icon sizing
- Group related services in VPC boundaries
- Show organization hierarchy clearly

## Color Scheme (Google Cloud)
- **Compute**: Blue (Compute Engine, GKE, Cloud Run)
- **Storage**: Yellow/Orange (Cloud Storage, Persistent Disks)
- **Networking**: Light Blue (VPC, Load Balancer, Cloud NAT)
- **Security**: Red/Pink (Cloud Armor, KMS, Secret Manager)
- **Data & Analytics**: Green (BigQuery, Dataflow, Pub/Sub)
- **Operations**: Purple (Cloud Logging, Cloud Monitoring)

## Export Requirements
- **Resolution**: 1920x1080 minimum
- **Format**: PNG with transparent background
- **DPI**: 300 for print quality

## Creation Instructions

### Option 1: Draw.io (Recommended)
1. Download Draw.io Desktop: https://github.com/jgraph/drawio-desktop/releases
2. Download GCP icons: https://cloud.google.com/icons
3. Import GCP icon library in Draw.io
4. Build diagram following the layout above
5. Export as PNG (300 DPI, 10px border)

### Option 2: Python diagrams library
```bash
# Install prerequisites
pip3 install diagrams
sudo apt-get install graphviz

# Create generate_diagram.py with GCP components
# Run: python3 generate_diagram.py
```

## Quick References
- **GCP Architecture Center**: https://cloud.google.com/architecture
- **GCP Icons**: https://cloud.google.com/icons
- **Cloud Foundation Toolkit**: https://cloud.google.com/foundation-toolkit
- **Landing Zone Best Practices**: https://cloud.google.com/architecture/landing-zones

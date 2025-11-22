# HashiCorp Multi-Cloud Platform - Architecture Diagram Requirements

## Overview
This document specifies the components and layout for the HashiCorp Multi-Cloud Platform solution architecture diagram.

## Required Components

### 1. HashiCorp Platform Layer
- **Terraform Cloud/Enterprise**
  - Workspace management
  - VCS integration (GitHub/GitLab)
  - Remote state storage
  - Policy enforcement with Sentinel
  - Run execution and planning

- **HashiCorp Vault**
  - Centralized secrets management
  - Dynamic credentials
  - Encryption as a service
  - Multi-cloud authentication

- **HashiCorp Consul**
  - Service mesh across clouds
  - Service discovery
  - KV store for configuration
  - Cross-cloud networking

### 2. Multi-Cloud Infrastructure
- **AWS Environment**
  - VPC and networking
  - EC2 instances
  - EKS clusters
  - RDS databases
  - S3 storage
  - IAM roles

- **Azure Environment**
  - Virtual Networks
  - Virtual Machines
  - AKS clusters
  - Azure SQL databases
  - Blob Storage
  - Azure AD integration

- **GCP Environment**
  - VPC networks
  - Compute Engine instances
  - GKE clusters
  - Cloud SQL databases
  - Cloud Storage
  - IAM policies

### 3. Platform Hosting Infrastructure
- **Kubernetes Cluster (EKS/AKS)**
  - Terraform Enterprise deployment
  - Vault cluster nodes
  - Consul agents
  - High availability configuration

- **Database Layer**
  - PostgreSQL for Terraform state
  - Consul storage backend
  - Backup and replication

### 4. Integration Layer
- **Version Control Systems**
  - GitHub integration
  - GitLab integration
  - Azure DevOps integration
  - Webhook triggers

- **CI/CD Pipelines**
  - GitHub Actions
  - GitLab CI
  - Jenkins integration
  - Automated Terraform runs

- **Monitoring & Observability**
  - Datadog integration
  - CloudWatch/Azure Monitor/Stackdriver
  - Terraform run metrics
  - Vault audit logging
  - Consul telemetry

### 5. Security & Networking
- **Network Connectivity**
  - VPN tunnels between clouds
  - VPC peering (AWS)
  - VNet peering (Azure)
  - Interconnect (GCP)
  - Service mesh connectivity via Consul

- **Security Controls**
  - SSO/SAML authentication
  - RBAC enforcement
  - Secret encryption
  - Network segmentation
  - TLS mutual authentication

### 6. Governance & Policy
- **Sentinel Policies**
  - Security policies
  - Cost policies
  - Compliance policies
  - Naming conventions

- **Cost Management**
  - Cost estimation
  - Budget enforcement
  - Resource tagging policies

## Flow Description

### Infrastructure Provisioning Workflow
1. **Code Commit** → Developer pushes Terraform code to GitHub/GitLab
2. **Webhook Trigger** → VCS notifies Terraform Cloud of changes
3. **Workspace Run** → Terraform Cloud initiates plan operation
4. **Policy Check** → Sentinel evaluates policies against plan
5. **Approval** → Manual or automatic approval based on policies
6. **Secret Retrieval** → Vault provides dynamic cloud credentials
7. **Multi-Cloud Provisioning** → Terraform applies changes across AWS/Azure/GCP
8. **State Storage** → Updated state stored in Terraform Cloud
9. **Service Registration** → Consul registers new services
10. **Monitoring** → Metrics sent to observability platforms

### Secrets Management Flow
1. **Authentication** → Application/user authenticates to Vault
2. **Dynamic Credential Request** → Vault generates cloud credentials
3. **Secret Rotation** → Vault rotates secrets on schedule
4. **Audit Logging** → All secret access logged for compliance

### Service Discovery Flow
1. **Service Registration** → Services register with Consul
2. **Service Mesh** → Consul Connect establishes mTLS connections
3. **Load Balancing** → Consul distributes traffic across instances
4. **Health Checks** → Consul monitors service health

## Diagram Layout Recommendations

### Layout Type: Multi-Layer Architecture with Cross-Cloud Connectivity

### Suggested Layers (Top to Bottom)
1. **Developer/User Layer**: Developers, operators, VCS, CI/CD
2. **HashiCorp Platform Layer**: Terraform Cloud, Vault, Consul (center focus)
3. **Multi-Cloud Layer**: AWS, Azure, GCP environments (side by side)
4. **Network & Security Layer**: VPN, service mesh, encryption
5. **Monitoring & Governance**: Datadog, Sentinel policies, audit logs

### Alternative Layout: Left-to-Right Flow
- **Left**: Developers, VCS, CI/CD triggers
- **Center**: HashiCorp platform components (Terraform/Vault/Consul)
- **Right**: Multi-cloud environments (AWS/Azure/GCP stacked or side-by-side)
- **Bottom**: Monitoring, logging, security

### Color Coding by Provider
- **HashiCorp Products**: Purple/violet (brand colors)
- **AWS Services**: Orange tones (AWS brand)
- **Azure Services**: Blue tones (Azure brand)
- **GCP Services**: Multi-color (GCP brand)
- **Shared Infrastructure**: Gray/neutral
- **Data Flows**: Color-coded by cloud provider

## HashiCorp Icon Guidelines
- Use official HashiCorp product logos
- Download from: https://www.hashicorp.com/brand
- Maintain consistent sizing across HashiCorp products
- Show product names and versions
- Indicate Enterprise vs Open Source editions

## Cloud Provider Icons
- **AWS**: Use official AWS Architecture Icons
- **Azure**: Use official Azure Architecture Icons
- **GCP**: Use official Google Cloud Architecture Icons
- Download icon sets from respective cloud provider sites

## Data Flow Arrows
- **Solid arrows**: Synchronous API calls (Terraform → Cloud APIs)
- **Dashed arrows**: Asynchronous events (VCS webhooks)
- **Dotted arrows**: Secret retrieval (Vault → Applications)
- **Service mesh lines**: Consul Connect mTLS connections
- **VPN tunnels**: Cross-cloud connectivity
- **Bold arrows**: Primary provisioning flow
- **Thin arrows**: Supporting flows (monitoring, logging)

## Key Interactions to Show

### 1. GitOps Workflow
- Developer → VCS → Terraform Cloud → Multi-Cloud Infrastructure
- Show pull request flow and approval gates

### 2. Secrets Management
- Terraform/Applications → Vault → Cloud Provider Credentials
- Show dynamic secret generation and rotation

### 3. Service Mesh
- Services in AWS/Azure/GCP → Consul mesh → Cross-cloud communication
- Show service discovery and load balancing

### 4. Policy Enforcement
- Terraform Plan → Sentinel Policies → Approval/Rejection
- Show different policy types (security, cost, compliance)

### 5. State Management
- Terraform Workspaces → Remote State (PostgreSQL) → State Locking
- Show concurrent run coordination

## Additional Diagram Elements

### Grouping and Boundaries
- **VPC/VNet boundaries**: Dashed rectangles per cloud
- **Kubernetes clusters**: Solid rectangles for platform hosting
- **Security zones**: Color-coded zones (public, private, management)
- **Geographic regions**: Show multi-region deployments

### Labels and Annotations
- Cloud provider names and regions
- Terraform workspace counts
- Secret management scope
- Service mesh coverage
- Network connectivity types (VPN, peering, interconnect)

### Legend/Key
- Arrow types and meanings
- Color coding by cloud provider
- HashiCorp product identification
- Security boundaries and zones

## Export Requirements
- **Source Files**:
  - `architecture-diagram.drawio` (editable)
  - `architecture-diagram.png` (rendered)
- **Resolution**: 1920x1080 minimum (prefer 2560x1440 for detail)
- **Format**: PNG with transparent or white background
- **DPI**: 300 for print quality
- **Aspect Ratio**: 16:9 for presentations

## How to Create in Draw.io

### Step 1: Set Up Icon Libraries
```bash
# Open Draw.io desktop
drawio architecture-diagram.drawio
```

1. Click **"More Shapes..."**
2. Enable icon libraries:
   - **AWS 19** (AWS icons)
   - **Azure** (Azure icons)
   - **GCP** (Google Cloud icons)
   - **Networking** (general networking icons)
3. Click **"Apply"**

### Step 2: Add HashiCorp Product Icons
1. Download HashiCorp product logos from https://www.hashicorp.com/brand
2. Import as images in Draw.io:
   - **File > Import > Image**
   - Select Terraform, Vault, Consul logos
3. Place in center of diagram as focal point

### Step 3: Build Multi-Cloud Infrastructure
1. **Create AWS section** (left or right third):
   - Add AWS VPC boundary
   - Place EC2, EKS, RDS, S3 icons
   - Label region (us-east-1)

2. **Create Azure section** (middle third):
   - Add Azure VNet boundary
   - Place VM, AKS, SQL, Blob icons
   - Label region (eastus)

3. **Create GCP section** (right third):
   - Add GCP VPC boundary
   - Place Compute Engine, GKE, Cloud SQL, Storage icons
   - Label region (us-central1)

### Step 4: Add HashiCorp Platform Layer
1. **Terraform Cloud** (center top):
   - Show workspaces
   - Connect to VCS (GitHub/GitLab)
   - Connect to all cloud providers

2. **Vault** (center middle):
   - Show connections to all clouds
   - Indicate dynamic credential generation
   - Show encryption services

3. **Consul** (center bottom):
   - Show service mesh across clouds
   - Indicate service discovery
   - Show health checking

### Step 5: Add Connectivity
1. **VCS Integration**:
   - GitHub → Terraform Cloud (webhook)
   - Show PR workflow

2. **Multi-Cloud Provisioning**:
   - Terraform → AWS/Azure/GCP
   - Show provider plugins
   - Indicate simultaneous provisioning

3. **Cross-Cloud Networking**:
   - VPN/Peering between cloud VPCs
   - Consul service mesh overlay

4. **Secrets Flow**:
   - Terraform → Vault → Cloud credentials
   - Applications → Vault → Dynamic secrets

### Step 6: Add Policy and Governance
1. Add Sentinel icon/badge
2. Show policy checks in Terraform workflow
3. Indicate cost estimation step
4. Show approval gates

### Step 7: Add Monitoring
1. Place Datadog/CloudWatch icons
2. Show metrics collection from:
   - Terraform runs
   - Vault operations
   - Consul services
   - Cloud infrastructure

### Step 8: Styling and Polish
1. **Align and distribute** components evenly
2. **Group related items** with subtle background rectangles
3. **Add labels** for all components
4. **Use consistent fonts** (Arial or Helvetica, 10-14pt)
5. **Color code arrows** by cloud provider
6. **Add legend** explaining icons and flows

### Step 9: Export
1. **Select all** (Ctrl+A / Cmd+A)
2. **File > Export as > PNG**
3. Settings:
   - Resolution: 300 DPI
   - Transparent or white background
   - Border: 10px
4. Save to: `architecture-diagram.png`

## Component Icon Reference

### HashiCorp Products
| Component | Icon Source | Color | Notes |
|-----------|------------|-------|-------|
| Terraform Cloud | HashiCorp brand | Purple | Show workspace icon |
| HashiCorp Vault | HashiCorp brand | Yellow/Gold | Show vault lock icon |
| HashiCorp Consul | HashiCorp brand | Pink/Red | Show mesh icon |
| Sentinel | HashiCorp brand | Purple | Show shield/policy icon |

### AWS Services
| Component | Icon Name | Category | Color |
|-----------|-----------|----------|-------|
| AWS VPC | Amazon VPC | Networking | Purple |
| Amazon EC2 | Amazon EC2 | Compute | Orange |
| Amazon EKS | Amazon EKS | Containers | Orange |
| Amazon RDS | Amazon RDS | Database | Blue |
| Amazon S3 | Amazon S3 | Storage | Green |

### Azure Services
| Component | Icon Name | Category | Color |
|-----------|-----------|----------|-------|
| Azure VNet | Virtual Network | Networking | Blue |
| Azure VM | Virtual Machines | Compute | Blue |
| Azure AKS | AKS | Containers | Blue |
| Azure SQL | Azure SQL | Database | Blue |
| Azure Blob | Blob Storage | Storage | Blue |

### GCP Services
| Component | Icon Name | Category | Color |
|-----------|-----------|----------|-------|
| GCP VPC | VPC Network | Networking | Blue/Red/Yellow |
| Compute Engine | Compute Engine | Compute | Blue |
| GKE | GKE | Containers | Blue |
| Cloud SQL | Cloud SQL | Database | Blue |
| Cloud Storage | Cloud Storage | Storage | Multi-color |

### Integration & Tools
| Component | Icon Source | Notes |
|-----------|------------|-------|
| GitHub | Simple icons or GitHub logo | VCS integration |
| GitLab | Simple icons or GitLab logo | VCS integration |
| Datadog | Datadog logo | Monitoring |
| Kubernetes | Kubernetes logo | Container orchestration |

## References
- **HashiCorp Brand**: https://www.hashicorp.com/brand
- **HashiCorp Docs**: https://www.terraform.io/docs, https://www.vaultproject.io/docs, https://www.consul.io/docs
- **AWS Architecture Icons**: https://aws.amazon.com/architecture/icons/
- **Azure Architecture Icons**: https://learn.microsoft.com/en-us/azure/architecture/icons/
- **GCP Architecture Icons**: https://cloud.google.com/icons
- **Multi-Cloud Architecture Patterns**: https://www.hashicorp.com/resources/solutions-eng-webinar-multi-cloud-architecture-hashicorp
- **Reference Architectures**: https://www.hashicorp.com/resources?type=reference-architecture

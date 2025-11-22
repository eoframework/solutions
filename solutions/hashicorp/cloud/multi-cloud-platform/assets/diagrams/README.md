# Architecture Diagram Creation Guide

This directory contains instructions for creating the HashiCorp Multi-Cloud Platform architecture diagram.

## 📋 **Overview**

Create a professional architecture diagram showing the HashiCorp multi-cloud platform with Terraform Cloud, Vault, Consul, and multi-cloud infrastructure across AWS, Azure, and GCP.

## 🎯 **Quick Start**

### Recommended Approach: Manual Creation with Draw.io
For HashiCorp multi-cloud solutions, manual diagram creation provides the best results due to the complexity of multi-cloud architecture and HashiCorp product branding.

### Prerequisites
1. **Download Draw.io Desktop**: https://github.com/jgraph/drawio-desktop/releases
2. **Download HashiCorp Logos**: https://www.hashicorp.com/brand
3. **Icon Libraries**: AWS 19, Azure, GCP (available in Draw.io)

## 🚀 **Step-by-Step Creation Process**

### Step 1: Set Up Draw.io Project
```bash
# Open Draw.io
drawio architecture-diagram.drawio

# Or create new file
# File > New > Blank Diagram
# Save as: architecture-diagram.drawio
```

### Step 2: Enable Cloud Provider Icon Libraries
1. Click **"More Shapes..."** in left sidebar
2. Enable these libraries:
   - ✅ **AWS 19** (latest AWS icons)
   - ✅ **Azure** (Azure architecture icons)
   - ✅ **GCP** (Google Cloud icons)
   - ✅ **Networking** (general network icons)
3. Click **"Apply"**

### Step 3: Import HashiCorp Product Logos
1. Download HashiCorp product logos:
   - Terraform logo (purple)
   - Vault logo (yellow/gold)
   - Consul logo (pink/red)
   - Sentinel badge (purple)

2. Import into Draw.io:
   - **File > Import > Image**
   - Select downloaded logos
   - Resize to consistent dimensions (e.g., 80x80px)

### Step 4: Create Canvas Layout
**Recommended Canvas Size**: 1920x1080 or 2560x1440 for detail

**Layout Structure** (Top to Bottom):
1. **Top Layer**: Developer workflow (VCS, CI/CD)
2. **Platform Layer**: HashiCorp products (Terraform, Vault, Consul)
3. **Multi-Cloud Layer**: AWS, Azure, GCP environments
4. **Bottom Layer**: Monitoring, governance, security

### Step 5: Build HashiCorp Platform Layer (Center Focus)

#### Add Terraform Cloud
1. Place Terraform logo at center-top
2. Add label: "Terraform Cloud" or "Terraform Enterprise"
3. Add sub-components:
   - Workspaces (100+)
   - Remote state storage
   - Run execution
   - Sentinel policies

#### Add HashiCorp Vault
1. Place Vault logo at center-middle
2. Add label: "HashiCorp Vault"
3. Add sub-components:
   - Secrets management
   - Dynamic credentials
   - Encryption as a service
   - Multi-cloud auth

#### Add HashiCorp Consul
1. Place Consul logo at center-bottom
2. Add label: "HashiCorp Consul"
3. Add sub-components:
   - Service mesh
   - Service discovery
   - KV store
   - Cross-cloud networking

### Step 6: Build Multi-Cloud Infrastructure Layer

#### Create AWS Section (Left Third)
1. Draw **VPC boundary** (dashed rectangle, orange tint)
2. Label: "AWS (us-east-1, eu-west-1)"
3. Add AWS icons:
   - VPC
   - EC2 instances
   - EKS cluster
   - RDS database
   - S3 buckets
   - IAM roles
4. Group logically (compute, storage, database)

#### Create Azure Section (Middle Third)
1. Draw **VNet boundary** (dashed rectangle, blue tint)
2. Label: "Azure (eastus, westeurope)"
3. Add Azure icons:
   - Virtual Network
   - Virtual Machines
   - AKS cluster
   - Azure SQL
   - Blob Storage
   - Azure AD
4. Match AWS layout for consistency

#### Create GCP Section (Right Third)
1. Draw **VPC boundary** (dashed rectangle, multi-color tint)
2. Label: "GCP (us-central1, europe-west1)"
3. Add GCP icons:
   - VPC Network
   - Compute Engine
   - GKE cluster
   - Cloud SQL
   - Cloud Storage
   - IAM
4. Match AWS/Azure layout

### Step 7: Add Version Control and CI/CD Layer (Top)
1. Add **GitHub** logo (or GitLab/Azure DevOps)
2. Add **CI/CD pipeline** icons (Jenkins, GitHub Actions)
3. Show webhook connection to Terraform Cloud
4. Indicate pull request workflow

### Step 8: Add Data Flows and Connections

#### Primary Infrastructure Provisioning Flow
1. **Developer → VCS**: Code commit (solid arrow)
2. **VCS → Terraform Cloud**: Webhook trigger (dashed arrow)
3. **Terraform → Vault**: Secret retrieval (dotted arrow)
4. **Terraform → AWS/Azure/GCP**: Multi-cloud provisioning (solid arrows, color-coded)
5. **Terraform → State Storage**: State update (solid arrow)

#### Secrets Management Flow
1. **Applications → Vault**: Authentication (solid arrow)
2. **Vault → Cloud Providers**: Dynamic credential generation (dotted arrows)
3. **Vault → Applications**: Secrets delivery (dotted arrows)

#### Service Mesh Flow
1. **Services → Consul**: Service registration (solid arrows)
2. **Consul → Cross-Cloud**: Service mesh connectivity (mesh lines)
3. Show mTLS connections between clouds

#### Policy Enforcement Flow
1. **Terraform Plan → Sentinel**: Policy evaluation (solid arrow)
2. **Sentinel → Approval Gate**: Pass/fail decision (conditional arrow)
3. Show different policy types (security, cost, compliance)

### Step 9: Add Cross-Cloud Networking
1. Draw **VPN tunnels** between AWS/Azure/GCP VPCs
2. Show **VPC peering** (AWS)
3. Show **VNet peering** (Azure)
4. Show **Interconnect** (GCP)
5. Overlay **Consul service mesh** connectivity

### Step 10: Add Monitoring and Governance Layer (Bottom)
1. **Monitoring**: Datadog, CloudWatch, Azure Monitor, Stackdriver icons
2. **Logging**: Centralized logging services
3. **Governance**: Sentinel policies, cost management
4. **Security**: SSO/SAML, RBAC, encryption indicators

### Step 11: Add Labels and Annotations
1. **Component labels**: All icons must have clear text labels
2. **Flow labels**: Annotate arrows with actions (e.g., "Provision infrastructure", "Retrieve secrets")
3. **Region labels**: Show cloud regions clearly
4. **Counts**: Indicate workspace counts, user counts, resource counts

### Step 12: Add Legend
Create a legend box showing:
- Arrow types (solid, dashed, dotted)
- Color coding (AWS=orange, Azure=blue, GCP=multi-color)
- HashiCorp products (purple theme)
- Security boundaries
- Data flow directions

### Step 13: Styling and Polish

#### Consistency
- ✅ Use consistent icon sizes (80x80 or 100x100px)
- ✅ Align items using Draw.io alignment tools
- ✅ Use consistent fonts (Arial or Helvetica, 10-14pt)
- ✅ Match spacing between elements

#### Color Scheme
- **HashiCorp products**: Purple/violet tones
- **AWS**: Orange accents
- **Azure**: Blue accents
- **GCP**: Multi-color accents
- **Backgrounds**: Light gray or white for grouping boxes
- **Borders**: Dashed for cloud boundaries, solid for components

#### Visual Hierarchy
- **Largest/Bold**: HashiCorp platform components (center focus)
- **Medium**: Cloud provider infrastructure
- **Smaller**: Supporting services (monitoring, governance)
- **Arrows**: Bold for primary flow, thin for supporting flows

### Step 14: Export Diagram

#### Export as PNG
1. **Select all** (Ctrl+A / Cmd+A)
2. **File > Export as > PNG**
3. **Settings**:
   - Resolution: **300 DPI** (for print quality)
   - Background: **White** or **Transparent**
   - Border width: **10px**
   - Include: **Entire diagram**
4. **Save as**: `architecture-diagram.png`

#### Keep Editable Source
- Save Draw.io source: `architecture-diagram.drawio`
- Commit both files to version control

## 📊 **Diagram Checklist**

Before finalizing, verify:

### HashiCorp Platform Components
- [ ] Terraform Cloud/Enterprise with workspaces shown
- [ ] HashiCorp Vault with secrets management indicated
- [ ] HashiCorp Consul with service mesh shown
- [ ] Sentinel policies represented

### Multi-Cloud Infrastructure
- [ ] AWS environment with VPC boundary and key services
- [ ] Azure environment with VNet boundary and key services
- [ ] GCP environment with VPC boundary and key services
- [ ] Cross-cloud networking connections (VPN, peering)

### Data Flows
- [ ] GitOps workflow (VCS → Terraform → Clouds)
- [ ] Secrets retrieval (Apps → Vault → Credentials)
- [ ] Service mesh connectivity (Consul across clouds)
- [ ] Policy enforcement (Sentinel evaluation)
- [ ] State management (Terraform workspaces)

### Integration Points
- [ ] VCS integration (GitHub/GitLab)
- [ ] CI/CD pipelines
- [ ] Monitoring tools (Datadog, CloudWatch)
- [ ] SSO/authentication
- [ ] Audit logging

### Visual Quality
- [ ] All icons properly sized and aligned
- [ ] Clear, readable labels on all components
- [ ] Arrow flows logically from left to right or top to bottom
- [ ] Legend explaining symbols and colors
- [ ] Consistent color scheme throughout
- [ ] High-resolution export (300 DPI)

### Documentation
- [ ] Descriptive title at top
- [ ] Cloud regions labeled
- [ ] Counts indicated (workspaces, users, resources)
- [ ] Key interactions highlighted

## 🔄 **Update Workflow**

### When to Update Diagram
- Adding new cloud providers
- Changing platform architecture
- Adding new HashiCorp products
- Updating infrastructure components
- Changing network topology

### Update Process
1. Open `architecture-diagram.drawio`
2. Make changes in Draw.io
3. Export new PNG
4. Commit both files
5. Regenerate Office documents

## 📚 **References and Resources**

### HashiCorp Resources
- **HashiCorp Brand Guidelines**: https://www.hashicorp.com/brand
- **Terraform Documentation**: https://www.terraform.io/docs
- **Vault Documentation**: https://www.vaultproject.io/docs
- **Consul Documentation**: https://www.consul.io/docs
- **Reference Architectures**: https://www.hashicorp.com/resources?type=reference-architecture

### Cloud Provider Icon Libraries
- **AWS Architecture Icons**: https://aws.amazon.com/architecture/icons/
- **Azure Architecture Icons**: https://learn.microsoft.com/en-us/azure/architecture/icons/
- **GCP Architecture Icons**: https://cloud.google.com/icons

### Draw.io Resources
- **Draw.io Desktop**: https://github.com/jgraph/drawio-desktop/releases
- **Draw.io Documentation**: https://www.diagrams.net/doc/
- **Draw.io Tutorials**: https://www.diagrams.net/blog/

### Architecture Patterns
- **Multi-Cloud Architecture**: https://www.hashicorp.com/resources/solutions-eng-webinar-multi-cloud-architecture-hashicorp
- **Infrastructure as Code Best Practices**: https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html
- **Vault Architecture**: https://www.vaultproject.io/docs/internals/architecture
- **Consul Architecture**: https://www.consul.io/docs/architecture

## 🆘 **Troubleshooting**

### Icons Not Appearing
- **Solution**: Click "More Shapes..." → Enable AWS/Azure/GCP libraries → Apply
- **Restart Draw.io** if icons still don't appear

### Export Quality Issues
- **Use 300 DPI** for print quality
- **Export PNG**, not JPEG (better quality)
- **Select entire diagram** before exporting

### Alignment Issues
- Use Draw.io alignment tools: **Arrange > Align**
- Enable grid: **View > Grid** (helps with spacing)
- Use guidelines for precision

### HashiCorp Logos Not Found
- Download from official brand page: https://www.hashicorp.com/brand
- Use PNG format with transparent background
- Resize proportionally (maintain aspect ratio)

## 📁 **Files in This Directory**

After completion, this directory should contain:
- **`README.md`** - This guide
- **`DIAGRAM_REQUIREMENTS.md`** - Detailed component specifications
- **`architecture-diagram.drawio`** - Editable Draw.io source (to be created)
- **`architecture-diagram.png`** - Exported diagram image (to be created)

---

**Next Step**: Create the architecture diagram following this guide, then proceed to generate Office documents using the eof-tools converter.

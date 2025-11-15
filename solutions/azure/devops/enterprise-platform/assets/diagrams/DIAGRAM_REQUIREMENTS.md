# Azure DevOps Enterprise Platform - Diagram Architecture Requirements

## Simple Architecture Diagram Specification

### Overview
The architecture diagram displays a streamlined DevOps Pipeline Factory with **6-8 major Azure services** organized in **3 logical layers**, focusing on the critical components for accelerated software delivery.

### Architecture Layers

#### Layer 1: Source Control & Development
- **Azure DevOps (Repos + Pipelines)**
  - Central hub for Git repositories and CI/CD pipeline orchestration
  - Provides version control and pipeline automation trigger

#### Layer 2: Build, Test & Container Services
- **Azure DevOps (Build Agents)**
  - Compile, test, and security scanning execution
  - Artifact generation for deployment
- **Azure Container Registry (ACR)**
  - Secure container image storage
  - Vulnerability scanning and image management

#### Layer 3: Deployment & Operations
- **Azure Kubernetes Service (AKS)**
  - Container orchestration and application deployment
  - Auto-scaling and multi-environment support (Dev/Test/Staging/Prod)
- **Azure Key Vault**
  - Secrets management and encryption keys
  - Rotation and compliance policies
- **Azure Monitor**
  - Logging, metrics, and alerts
  - Application performance monitoring (APM)

### Visual Characteristics

**Component Boxes:**
- Large, readable text (minimum 14pt font)
- Rectangular boxes with clear labels and icons
- Color coding by layer: Blue (Source), Orange (Build), Green (Operations)

**Data Flow Arrows:**
1. Developer pushes code → Azure DevOps Repos
2. Code commit triggers → Azure DevOps Build Pipeline
3. Build artifact → Azure Container Registry push
4. Registry pull → AKS deployment
5. Secrets managed by → Azure Key Vault
6. Observability → Azure Monitor

**Total Components:** 6 major services (no sub-components displayed separately)

### Design Constraints
- NO complex clustering, nested components, or detailed sub-service breakdowns
- NO business process flows or swimlanes
- NO detailed RBAC, networking, or security policy details
- Focus on the "happy path" main workflow only
- Maximum 4 data flow arrows showing principal interactions

### Use Cases Represented
1. **Source Control:** Teams push code to repositories
2. **Automated Testing:** Pipelines run unit, integration, security tests
3. **Container Build:** Docker images built and scanned
4. **Deployment:** Containers deployed to AKS with auto-scaling
5. **Secrets Management:** Credentials and keys secured in Key Vault
6. **Operations:** Monitoring and alerting on production systems

### File Output
- **Format:** DrawIO format (XML) with embedded SVG for web viewing
- **Export:** PNG (1920x1200px, white background)
- **Dimensions:** 16:9 aspect ratio for presentation slides
- **File Names:**
  - `architecture-diagram.drawio` - DrawIO source
  - `architecture-diagram.png` - Export for presentations

---

## Python Generation Script Requirements

The `generate_diagram.py` script will:
1. Use Python's `diagrams` library or `graphviz`/`drawio-python`
2. Create 6-8 Azure service nodes
3. Connect with 3-4 principal data flows
4. Generate both DrawIO XML and PNG output
5. Use Azure icon set and readable fonts
6. Export at 1920x1200px resolution

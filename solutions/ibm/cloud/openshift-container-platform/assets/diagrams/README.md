# OpenShift Container Platform - Architecture Diagrams

This directory contains the architecture diagrams for the OpenShift Container Platform solution.

## Files

- `architecture-diagram.drawio` - Editable Draw.io diagram source file
- `architecture-diagram.png` - PNG export for use in documents (TO BE GENERATED)

## How to Edit the Diagram

### Option 1: Using draw.io Web App (Recommended)

1. Go to https://app.diagrams.net/
2. Click "Open Existing Diagram"
3. Select `architecture-diagram.drawio` from this directory
4. Follow the instructions in the blue box at the top of the diagram:
   - Click "More Shapes..." in the left sidebar
   - Search for "Kubernetes" or use generic shapes
   - For Red Hat/OpenShift specific icons:
     - Download official icons from https://www.redhat.com/en/about/brand/standards/icons
     - Import via Arrange > Insert > Image
   - Replace the generic rectangles with proper icons
5. After editing, save the file
6. Export as PNG: File > Export as > PNG
   - Name it `architecture-diagram.png`
   - Recommended size: 1600x900 pixels
   - Check "Transparent Background" for better document integration

### Option 2: Using draw.io Desktop App

1. Download draw.io Desktop from https://github.com/jgraph/drawio-desktop/releases
2. Open `architecture-diagram.drawio`
3. Follow the same editing steps as above
4. Save and export as PNG

## Diagram Components

The architecture diagram includes:

### Control Plane Layer
- 3 Control Plane Nodes (HA configuration)
- API Server, etcd, Scheduler components
- High availability clustering

### Worker Nodes Layer
- Multiple worker nodes running containerized applications
- CRI-O container runtime
- RHEL CoreOS operating system

### Storage Layer
- Container Registry (Quay) with vulnerability scanning
- Persistent Storage (OpenShift Data Foundation / ODF)
- Block, file, and object storage capabilities

### Developer & CI/CD Tools
- OpenShift Pipelines (Tekton) for CI/CD workflows
- GitOps with ArgoCD for declarative deployments
- Developer Console with web UI and CLI (oc)

### Networking Layer
- OpenShift Router (HAProxy-based ingress controller)
- OVN-Kubernetes SDN with network policies
- Service Mesh (Istio) for advanced traffic management

### Observability & Security
- Prometheus and Grafana for metrics and dashboards
- EFK Stack (Elasticsearch, Fluentd, Kibana) for centralized logging
- Advanced Cluster Security (ACS) for vulnerability scanning

### External Integration
- LDAP / Active Directory for authentication and SSO
- Developer and end-user access
- Infrastructure layer (VMware vSphere, Bare Metal, AWS, Azure)

## Color Coding

- 🔴 Red = Control Plane components
- 🔵 Blue = Storage and data components
- 🟠 Orange = Compute and container components
- 🟢 Green = Networking and ingress
- 🟣 Purple = Developer tools and CI/CD
- ⚫ Gray = Observability and security

## Usage in Documents

The `architecture-diagram.png` file is referenced in:
- `presales/raw/solution-briefing.md` - Solution Overview slide
- Future technical documentation and presentations

## Customization

Feel free to customize the diagram to match specific deployment scenarios:
- Adjust node counts based on actual cluster sizing
- Add/remove components based on selected features
- Include specific infrastructure providers (AWS ROSA, Azure ARO, VMware, etc.)
- Show multi-cluster deployments with Advanced Cluster Management (ACM)
- Add specific network topology or security zones

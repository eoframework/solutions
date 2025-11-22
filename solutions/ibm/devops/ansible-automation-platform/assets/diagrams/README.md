# Ansible Automation Platform - Architecture Diagrams

This directory contains the architecture diagrams for the Ansible Automation Platform solution.

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
   - Search for automation or use generic shapes
   - For Red Hat/Ansible specific icons:
     - Download official icons from https://ansible.com/brand or https://www.redhat.com/en/about/brand/standards/icons
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

### Automation Controller (High Availability)
- 2 Controller Nodes with web UI, API, and job scheduler
- Load Balancer (HAProxy or cloud ALB) for HA
- PostgreSQL Database for jobs, inventory, and credentials
- Centralized automation orchestration

### Execution Infrastructure
- Execution Nodes for distributed job processing
- Isolated job runners for scalability
- Execution Environments with Python dependencies and Ansible collections
- Container-based execution isolation

### Content & Version Control
- Private Automation Hub for collection repository
- Git Repository integration for playbooks and roles (GitOps)
- 2000+ Certified Collections for servers, network, cloud, and security automation
- Reusable automation content management

### Managed Infrastructure (500 Nodes)
- **Linux Servers (375)**: RHEL, CentOS, Ubuntu managed via SSH
- **Windows Servers (75)**: Windows Server managed via WinRM
- **Network Devices (50)**: Cisco, Juniper, F5, Palo Alto managed via API/SSH
- **Cloud Resources**: AWS, Azure, GCP, VMware managed via cloud APIs
- Dynamic Inventory from CMDB, cloud providers, ServiceNow

### Integration & Security
- ServiceNow Integration for ticket-driven automation
- Event-Driven Automation with monitoring webhooks (Prometheus, Datadog)
- Credential Vault integration (HashiCorp Vault, CyberArk)
- Automated remediation and compliance enforcement

### External Access & Users
- Automation Users: Developers, Operators, Administrators
- LDAP / Active Directory for SSO authentication and RBAC
- REST API / CLI for API integrations and CI/CD pipelines
- Automation Analytics for ROI metrics and job history

## Color Coding

- 🔴 Red = Ansible Automation Platform core
- 🔵 Blue = Infrastructure and storage
- 🟢 Green = Integration and networking
- 🟠 Orange = Execution and processing
- 🟣 Purple = Content management and collections
- ⚫ Gray = Security and monitoring

## Usage in Documents

The `architecture-diagram.png` file is referenced in:
- `presales/raw/solution-briefing.md` - Solution Overview slide
- Future technical documentation and presentations

## Customization

Feel free to customize the diagram to match specific deployment scenarios:
- Adjust managed node counts based on actual inventory
- Add/remove integration points (ITSM, monitoring, CMDB)
- Show specific automation use cases (provisioning, patching, network automation)
- Include event-driven automation trigger sources
- Add specific credential vault providers
- Show multi-region or geographically distributed deployments
- Include specific network device vendors and cloud platforms

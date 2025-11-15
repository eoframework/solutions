# Azure DevOps Enterprise Platform - Architecture Diagrams

## Overview
This directory contains architecture diagrams for the Azure DevOps Enterprise Platform solution, including a simplified 6-8 component diagram showing the core DevOps Pipeline Factory architecture.

## Files

### Architecture Diagram
- **architecture-diagram.drawio** - DrawIO format source file (editable)
- **architecture-diagram.png** - PNG export for presentations and documentation

### Diagram Generation
- **generate_diagram.py** - Python script to generate architecture diagrams from code
- **DIAGRAM_REQUIREMENTS.md** - Detailed specification for diagram design and components

## Architecture Components

The solution uses a simplified 3-layer architecture:

### Layer 1: Source Control
- **Azure DevOps Repos** - Git repositories for source code management

### Layer 2: Build & Container
- **Azure DevOps Pipelines** - CI/CD pipeline orchestration and automation
- **Azure Container Registry** - Secure container image storage and scanning

### Layer 3: Deployment & Operations
- **Azure Kubernetes Service** - Container orchestration and deployment platform
- **Azure Key Vault** - Secrets management and encryption keys
- **Azure Monitor** - Logging, metrics, and observability

## Principal Data Flows

1. **Developer Commits** → Code pushed to Azure DevOps Repos
2. **Automated Pipeline** → CI/CD triggered, tests run, security scanning executed
3. **Container Build** → Docker images built and pushed to Container Registry
4. **Kubernetes Deployment** → Container images pulled and deployed to AKS
5. **Secrets Management** → Application accesses secrets from Key Vault
6. **Production Observability** → Metrics and logs aggregated in Azure Monitor

## Design Principles

- **Simplicity** - Maximum 6-8 components, no excessive detail
- **Clarity** - Large, readable text and component labels
- **Focus** - Shows principal architecture without implementation details
- **Presentation-Ready** - Suitable for executive briefings and solution documents

## Viewing & Editing

### DrawIO Format (.drawio)
- Open in [draw.io](https://draw.io) or [diagrams.net](https://diagrams.net)
- Fully editable XML format
- Can export to multiple formats (PNG, SVG, PDF, etc.)

### PNG Format (.png)
- Pre-rendered for documentation and presentations
- Use in PowerPoint, Markdown, or web pages
- Resolution: 1920x1200px, white background

## Regenerating from Code

To regenerate the diagram from the Python script:

```bash
python3 generate_diagram.py
```

This will:
1. Read the diagram specification from DIAGRAM_REQUIREMENTS.md
2. Generate a new architecture-diagram.drawio file
3. Export architecture-diagram.png at 1920x1200px resolution

## Architecture Details

### Azure DevOps Services
- **Repos** - Git-based source control for all code
- **Pipelines** - YAML-based CI/CD automation with 15+ reusable templates

### Azure Container Registry (Premium)
- Image scanning and vulnerability management
- Geo-replication for multi-region deployments
- Integration with AKS for private pulls

### Azure Kubernetes Service
- Multi-environment support (Dev/Test/Staging/Prod)
- Auto-scaling based on demand
- Network policies and pod security standards

### Azure Key Vault (Standard)
- Centralized secrets management
- Automated rotation policies
- RBAC and audit logging for compliance

### Azure Monitor
- Application Insights for APM
- Log Analytics for centralized logging
- Custom dashboards and alerts

## Size & Scale

**Target Deployment Sizes:**
- **Small:** Single environment, 5-50 developers
- **Medium:** Multiple environments, 50-500 developers
- **Large:** Multi-region, 500+ developers with dedicated ops teams

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-15 | Initial architecture diagram created |

---

**For detailed architecture requirements, see [DIAGRAM_REQUIREMENTS.md](DIAGRAM_REQUIREMENTS.md)**

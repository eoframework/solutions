# Azure DevOps Enterprise Platform - Architecture Diagram Requirements

## Required Components

### 1. Source Control & CI/CD
- **Azure DevOps / GitHub Enterprise** - Git repositories, Boards, Pipelines
- **Azure Repos** - Private Git repositories
- **Azure Pipelines** - CI/CD automation

### 2. Container Platform
- **Azure Kubernetes Service (AKS)** - Container orchestration
- **Azure Container Registry (ACR)** - Container image storage
- **Azure Container Instances (ACI)** - Serverless containers

### 3. Security & Secrets
- **Azure Key Vault** - Secrets, keys, certificates
- **Managed Identities** - Service authentication
- **Defender for Containers** - Container security scanning

### 4. Monitoring & Operations
- **Azure Monitor** - Metrics and logs
- **Application Insights** - APM
- **Container Insights** - AKS monitoring

## Azure Services

| Component | Icon Color |
|-----------|-----------|
| Azure DevOps | Blue |
| AKS | Blue |
| Container Registry | Green |
| Key Vault | Red |

## References
- **AKS Best Practices**: https://learn.microsoft.com/en-us/azure/aks/best-practices

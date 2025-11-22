# Azure DevOps Enterprise Platform - Architecture Diagram

## Key Components
1. **Azure DevOps/GitHub** - Source control, work tracking, CI/CD pipelines
2. **AKS Cluster** - Kubernetes for container orchestration (multiple node pools)
3. **Azure Container Registry** - Private Docker image registry with geo-replication
4. **Key Vault** - Manage secrets, connection strings, certificates
5. **Azure Monitor** - Collect metrics, logs, and application telemetry

## Flow
```
1. Developer commits code → Azure Repos/GitHub
2. Pipeline triggers → Build container image
3. Image pushed → Azure Container Registry
4. Pipeline deploys → AKS cluster
5. AKS pulls secrets → From Key Vault (via Managed Identity)
6. Monitor collects → Logs and metrics from AKS/containers
```

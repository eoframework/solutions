# Azure Document Intelligence - Terraform Automation

Infrastructure as Code for Azure Document Intelligence solution.

## Architecture

This solution implements a serverless document processing platform using Azure AI services:

- **Azure Document Intelligence** - OCR and document extraction
- **Azure Functions** - Serverless processing pipeline
- **Azure Cosmos DB** - Metadata and extraction results storage
- **Azure Blob Storage** - Document ingestion and archival
- **Azure Key Vault** - Secrets management
- **Azure Monitor** - Observability and alerting

## Directory Structure

```
terraform/
├── README.md
├── setup/
│   ├── backend/           # Azure Storage Account state backend
│   └── secrets/           # Key Vault secrets provisioning
├── environments/
│   ├── prod/              # Production environment
│   ├── test/              # Test environment
│   └── dr/                # Disaster recovery environment
└── modules/
    ├── azure/             # Azure-specific resource modules
    │   ├── storage-account/
    │   ├── function-app/
    │   ├── cosmos-db/
    │   ├── key-vault/
    │   ├── document-intelligence/
    │   ├── logic-app/
    │   ├── api-management/
    │   ├── service-bus/
    │   ├── vnet/
    │   ├── monitor/
    │   └── front-door/
    └── solution/          # Solution-specific compositions
        ├── core/          # VNet, Key Vault, base infrastructure
        ├── security/      # Managed identities, RBAC, encryption
        ├── processing/    # Document Intelligence, Functions, Logic Apps
        ├── storage/       # Blob Storage, Cosmos DB
        ├── monitoring/    # Azure Monitor, Application Insights
        ├── best-practices/# Backup, budgets, policies
        └── dr/            # Cross-region replication
```

## Quick Start

### 1. Initialize Backend

```bash
cd setup/backend
./state-backend.sh prod
```

### 2. Deploy Environment

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
./eo-deploy.sh plan
./eo-deploy.sh apply
```

## Environments

| Environment | Purpose | Region |
|-------------|---------|--------|
| prod | Production workloads | East US |
| test | Development and testing | East US |
| dr | Disaster recovery standby | West US 2 |

## Azure Well-Architected Framework

This solution implements Azure Well-Architected Framework best practices:

| Pillar | Implementation |
|--------|----------------|
| Reliability | Zone redundancy, Cosmos DB continuous backup |
| Security | Key Vault, managed identities, private endpoints |
| Cost Optimization | Serverless pricing, lifecycle policies |
| Operational Excellence | Azure Monitor, Application Insights |
| Performance Efficiency | Premium Functions, Cosmos DB autoscale |

## Prerequisites

- Azure CLI installed and authenticated
- Terraform >= 1.6.0
- Azure subscription with required permissions
- Contributor role on target subscription

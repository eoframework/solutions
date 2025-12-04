# Terraform State Backend Setup

This directory contains scripts to set up the Azure Storage Account backend for Terraform state.

## Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Contributor role on the target subscription

## Usage

### Linux/Mac

```bash
./state-backend.sh prod
./state-backend.sh test
./state-backend.sh dr
```

### Windows

```cmd
state-backend.bat prod
state-backend.bat test
state-backend.bat dr
```

## What It Creates

1. Resource Group: `tfstate-{env}-rg`
2. Storage Account: `tfstate{random}` (globally unique)
3. Blob Container: `tfstate`
4. Backend config file: `environments/{env}/backend.tfvars`

## Backend Configuration

The generated `backend.tfvars` contains:

```hcl
resource_group_name  = "tfstate-prod-rg"
storage_account_name = "tfstateabc123"
container_name       = "tfstate"
key                  = "docintel-prod.tfstate"
```

## Initialize Terraform

After running the setup script:

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars
```

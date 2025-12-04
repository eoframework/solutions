# Terraform State Backend Setup

This directory contains the script to set up Azure Storage backend for Terraform state files.

## Prerequisites

- Azure CLI installed and authenticated
- Appropriate permissions to create:
  - Resource Groups
  - Storage Accounts
  - Storage Containers

## Usage

Run the setup script for each environment:

```bash
# Production environment
./state-backend.sh prod

# Test environment
./state-backend.sh test

# DR environment
./state-backend.sh dr
```

## What It Does

The script performs the following actions:

1. Creates a resource group for Terraform state storage
2. Creates a storage account with:
   - Standard LRS redundancy
   - Blob encryption enabled
   - TLS 1.2 minimum version
3. Creates a blob container named `tfstate`
4. Generates a `backend.tfvars` file in the environment directory

## Generated Files

After running the script, you'll find a `backend.tfvars` file in the environment directory:

```
environments/
├── prod/
│   └── backend.tfvars
├── test/
│   └── backend.tfvars
└── dr/
    └── backend.tfvars
```

## Initializing Terraform

After running the setup script, initialize Terraform in the environment directory:

```bash
cd ../../environments/prod
terraform init -backend-config=backend.tfvars
```

## Security Notes

- The `backend.tfvars` files contain sensitive information and should not be committed to version control
- Add `backend.tfvars` to `.gitignore`
- Storage account keys are used for authentication to the backend
- Consider using Azure AD authentication for enhanced security

## Cleanup

To remove the backend infrastructure:

```bash
az group delete --name tfstate-prod-rg --yes --no-wait
az group delete --name tfstate-test-rg --yes --no-wait
az group delete --name tfstate-dr-rg --yes --no-wait
```

**Warning:** Deleting the backend storage will remove all Terraform state files. Only do this if you're certain you want to destroy the infrastructure.

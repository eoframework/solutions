#!/bin/bash
#------------------------------------------------------------------------------
# Azure Terraform State Backend Setup
# Creates: Storage Account, Container, backend.tfvars
#------------------------------------------------------------------------------

set -e

ENV=${1:-prod}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_DIR="$ROOT_DIR/environments/$ENV"

echo "Setting up Terraform backend for environment: $ENV"

# Read project configuration
if [ -f "$ENV_DIR/config/project.tfvars" ]; then
    source <(grep -E '^[a-zA-Z_].*=' "$ENV_DIR/config/project.tfvars" | sed 's/ = /=/g' | tr -d '"')
else
    echo "Error: project.tfvars not found at $ENV_DIR/config/project.tfvars"
    exit 1
fi

# Generate unique names
SUFFIX=$(echo $RANDOM | md5sum | head -c 6)
STORAGE_ACCOUNT_NAME="tfstate${SUFFIX}"
RESOURCE_GROUP_NAME="tfstate-${ENV}-rg"
CONTAINER_NAME="tfstate"
REGION=${azure_region:-eastus}

echo "Creating resource group: $RESOURCE_GROUP_NAME"
az group create --name "$RESOURCE_GROUP_NAME" --location "$REGION" --output none

echo "Creating storage account: $STORAGE_ACCOUNT_NAME"
az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$REGION" \
    --sku Standard_LRS \
    --encryption-services blob \
    --min-tls-version TLS1_2 \
    --output none

echo "Creating blob container: $CONTAINER_NAME"
az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --auth-mode login \
    --output none

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --query '[0].value' -o tsv)

# Generate backend.tfvars
cat > "$ENV_DIR/backend.tfvars" << EOF
resource_group_name  = "$RESOURCE_GROUP_NAME"
storage_account_name = "$STORAGE_ACCOUNT_NAME"
container_name       = "$CONTAINER_NAME"
key                  = "docintel-$ENV.tfstate"
EOF

echo ""
echo "Backend configuration written to: $ENV_DIR/backend.tfvars"
echo ""
echo "Initialize Terraform with:"
echo "  cd $ENV_DIR"
echo "  terraform init -backend-config=backend.tfvars"

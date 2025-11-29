#!/bin/bash

# Initialize Azure Storage Backend for Terraform State Management
# This script creates the necessary Azure infrastructure to store Terraform state files

set -e

# Configuration
PROJECT_NAME="${1:-my-enterprise-project}"
LOCATION="${2:-East US}"
SUBSCRIPTION_ID="${3}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $BLUE "🚀 Initializing Azure Backend for Terraform State Management"
print_message $YELLOW "Project: $PROJECT_NAME"
print_message $YELLOW "Location: $LOCATION"
echo

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_message $RED "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Verify Azure login
print_message $BLUE "🔍 Verifying Azure login..."
if ! az account show > /dev/null 2>&1; then
    print_message $RED "❌ Not logged into Azure. Please run: az login"
    exit 1
fi

# Set subscription if provided
if [ ! -z "$SUBSCRIPTION_ID" ]; then
    az account set --subscription $SUBSCRIPTION_ID
    print_message $GREEN "✅ Subscription set to: $SUBSCRIPTION_ID"
else
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    print_message $YELLOW "Using current subscription: $SUBSCRIPTION_ID"
fi

print_message $GREEN "✅ Azure credentials verified"

# Resource naming
RESOURCE_GROUP_NAME="${PROJECT_NAME}-terraform-rg"
STORAGE_ACCOUNT_NAME=$(echo "${PROJECT_NAME}tfstate" | tr -d '-' | tr '[:upper:]' '[:lower:]' | cut -c1-24)
CONTAINER_NAME="tfstate"

# Create Resource Group
print_message $BLUE "📦 Creating Resource Group: $RESOURCE_GROUP_NAME"
if az group show --name $RESOURCE_GROUP_NAME > /dev/null 2>&1; then
    print_message $YELLOW "⚠️  Resource Group $RESOURCE_GROUP_NAME already exists"
else
    az group create \
        --name $RESOURCE_GROUP_NAME \
        --location "$LOCATION" \
        --tags Project=$PROJECT_NAME Purpose=TerraformState
    print_message $GREEN "✅ Resource Group created"
fi

# Create Storage Account
print_message $BLUE "💾 Creating Storage Account: $STORAGE_ACCOUNT_NAME"
if az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME > /dev/null 2>&1; then
    print_message $YELLOW "⚠️  Storage Account $STORAGE_ACCOUNT_NAME already exists"
else
    az storage account create \
        --name $STORAGE_ACCOUNT_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --encryption-services blob \
        --https-only true \
        --min-tls-version TLS1_2 \
        --tags Project=$PROJECT_NAME Purpose=TerraformState

    print_message $GREEN "✅ Storage Account created"
fi

# Get storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query '[0].value' -o tsv)

# Create Storage Container
print_message $BLUE "📁 Creating Storage Container: $CONTAINER_NAME"
if az storage container show --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY > /dev/null 2>&1; then
    print_message $YELLOW "⚠️  Storage Container $CONTAINER_NAME already exists"
else
    az storage container create \
        --name $CONTAINER_NAME \
        --account-name $STORAGE_ACCOUNT_NAME \
        --account-key $STORAGE_ACCOUNT_KEY \
        --public-access off

    print_message $GREEN "✅ Storage Container created"
fi

# Generate backend configuration files
print_message $BLUE "📄 Generating backend configuration files..."

# Production backend config
cat > ../environments/production/backend.hcl << EOF
resource_group_name  = "$RESOURCE_GROUP_NAME"
storage_account_name = "$STORAGE_ACCOUNT_NAME"
container_name       = "$CONTAINER_NAME"
key                  = "production.terraform.tfstate"
EOF

# Disaster Recovery backend config
cat > ../environments/disaster-recovery/backend.hcl << EOF
resource_group_name  = "$RESOURCE_GROUP_NAME"
storage_account_name = "$STORAGE_ACCOUNT_NAME"
container_name       = "$CONTAINER_NAME"
key                  = "disaster-recovery.terraform.tfstate"
EOF

# Test backend config
cat > ../environments/test/backend.hcl << EOF
resource_group_name  = "$RESOURCE_GROUP_NAME"
storage_account_name = "$STORAGE_ACCOUNT_NAME"
container_name       = "$CONTAINER_NAME"
key                  = "test.terraform.tfstate"
EOF

print_message $GREEN "✅ Backend configuration files generated"

# Create initialization script for each environment
cat > init-production-azure.sh << 'EOF'
#!/bin/bash
cd ../environments/production
terraform init -backend-config=backend.hcl
EOF

cat > init-disaster-recovery-azure.sh << 'EOF'
#!/bin/bash
cd ../environments/disaster-recovery
terraform init -backend-config=backend.hcl
EOF

cat > init-test-azure.sh << 'EOF'
#!/bin/bash
cd ../environments/test
terraform init -backend-config=backend.hcl
EOF

chmod +x init-*-azure.sh

print_message $GREEN "✅ Environment initialization scripts created"

echo
print_message $GREEN "🎉 Azure Backend Setup Complete!"
print_message $BLUE "Next steps:"
echo "1. Set ARM_ACCESS_KEY environment variable: export ARM_ACCESS_KEY=\"$STORAGE_ACCOUNT_KEY\""
echo "2. Run ./init-production-azure.sh to initialize production environment"
echo "3. Run ./init-disaster-recovery-azure.sh to initialize disaster recovery environment"
echo "4. Run ./init-test-azure.sh to initialize test environment"
echo
print_message $YELLOW "Resources created:"
echo "📦 Resource Group: $RESOURCE_GROUP_NAME"
echo "💾 Storage Account: $STORAGE_ACCOUNT_NAME"
echo "📁 Container: $CONTAINER_NAME"
echo "📄 Backend config files in each environment directory"
echo
print_message $RED "⚠️  Important: Store the storage account key securely!"
echo "Storage Account Key: $STORAGE_ACCOUNT_KEY"
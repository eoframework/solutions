#!/bin/bash

# Initialize Google Cloud Storage Backend for Terraform State Management
# This script creates the necessary GCP infrastructure to store Terraform state files

set -e

# Configuration
PROJECT_ID="${1}"
PROJECT_NAME="${2:-my-enterprise-project}"
REGION="${3:-us-central1}"

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

# Check required parameters
if [ -z "$PROJECT_ID" ]; then
    print_message $RED "❌ Usage: $0 <PROJECT_ID> [PROJECT_NAME] [REGION]"
    print_message $YELLOW "Example: $0 my-gcp-project-123 my-enterprise-project us-central1"
    exit 1
fi

print_message $BLUE "🚀 Initializing GCP Backend for Terraform State Management"
print_message $YELLOW "Project ID: $PROJECT_ID"
print_message $YELLOW "Project Name: $PROJECT_NAME"
print_message $YELLOW "Region: $REGION"
echo

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    print_message $RED "❌ Google Cloud CLI is not installed. Please install it first."
    exit 1
fi

# Verify gcloud authentication
print_message $BLUE "🔍 Verifying gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null 2>&1; then
    print_message $RED "❌ Not authenticated with gcloud. Please run: gcloud auth login"
    exit 1
fi

# Set the project
gcloud config set project $PROJECT_ID
print_message $GREEN "✅ gcloud configured for project: $PROJECT_ID"

# Enable required APIs
print_message $BLUE "🔧 Enabling required APIs..."
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
print_message $GREEN "✅ Required APIs enabled"

# Create Storage Bucket for state storage
BUCKET_NAME="${PROJECT_ID}-terraform-state"
print_message $BLUE "📦 Creating Storage Bucket: $BUCKET_NAME"

# Check if bucket already exists
if gsutil ls -b gs://$BUCKET_NAME > /dev/null 2>&1; then
    print_message $YELLOW "⚠️  Bucket gs://$BUCKET_NAME already exists"
else
    # Create bucket
    gsutil mb -p $PROJECT_ID -c STANDARD -l $REGION gs://$BUCKET_NAME

    # Enable versioning
    gsutil versioning set on gs://$BUCKET_NAME

    # Set lifecycle policy to delete old versions after 30 days
    cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "age": 30,
          "isLive": false
        }
      }
    ]
  }
}
EOF

    gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME
    rm lifecycle.json

    # Set bucket permissions
    gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

    # Remove public access
    gsutil iam ch -d allUsers:objectViewer gs://$BUCKET_NAME

    print_message $GREEN "✅ Storage Bucket created and configured"
fi

# Generate backend configuration files
print_message $BLUE "📄 Generating backend configuration files..."

# Production backend config
cat > ../environments/production/backend.hcl << EOF
bucket = "$BUCKET_NAME"
prefix = "production"
EOF

# Disaster Recovery backend config
cat > ../environments/disaster-recovery/backend.hcl << EOF
bucket = "$BUCKET_NAME"
prefix = "disaster-recovery"
EOF

# Test backend config
cat > ../environments/test/backend.hcl << EOF
bucket = "$BUCKET_NAME"
prefix = "test"
EOF

print_message $GREEN "✅ Backend configuration files generated"

# Create initialization script for each environment
cat > init-production-gcp.sh << 'EOF'
#!/bin/bash
cd ../environments/production
terraform init -backend-config=backend.hcl
EOF

cat > init-disaster-recovery-gcp.sh << 'EOF'
#!/bin/bash
cd ../environments/disaster-recovery
terraform init -backend-config=backend.hcl
EOF

cat > init-test-gcp.sh << 'EOF'
#!/bin/bash
cd ../environments/test
terraform init -backend-config=backend.hcl
EOF

chmod +x init-*-gcp.sh

print_message $GREEN "✅ Environment initialization scripts created"

# Create service account for Terraform (optional but recommended)
SERVICE_ACCOUNT_NAME="terraform-sa"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

print_message $BLUE "👤 Creating service account for Terraform..."
if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL > /dev/null 2>&1; then
    print_message $YELLOW "⚠️  Service account $SERVICE_ACCOUNT_EMAIL already exists"
else
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="Terraform Service Account" \
        --description="Service account for Terraform automation"

    # Grant necessary roles
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/editor"

    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="roles/storage.admin"

    print_message $GREEN "✅ Service account created with necessary permissions"
fi

echo
print_message $GREEN "🎉 GCP Backend Setup Complete!"
print_message $BLUE "Next steps:"
echo "1. Optionally create and download service account key:"
echo "   gcloud iam service-accounts keys create terraform-key.json --iam-account=$SERVICE_ACCOUNT_EMAIL"
echo "2. Set GOOGLE_APPLICATION_CREDENTIALS if using service account key"
echo "3. Run ./init-production-gcp.sh to initialize production environment"
echo "4. Run ./init-disaster-recovery-gcp.sh to initialize disaster recovery environment"
echo "5. Run ./init-test-gcp.sh to initialize test environment"
echo
print_message $YELLOW "Resources created:"
echo "📦 Storage Bucket: gs://$BUCKET_NAME"
echo "👤 Service Account: $SERVICE_ACCOUNT_EMAIL"
echo "📄 Backend config files in each environment directory"
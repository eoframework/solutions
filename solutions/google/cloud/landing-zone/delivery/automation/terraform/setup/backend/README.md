# Terraform State Backend Setup

This directory contains scripts to set up the GCS bucket for Terraform state management.

## Prerequisites

- Google Cloud SDK (`gcloud` CLI) installed and configured
- Authenticated with GCP: `gcloud auth login`
- Project ID set: `gcloud config set project <PROJECT_ID>`
- Appropriate permissions:
  - `roles/storage.admin` for bucket creation
  - `roles/iam.serviceAccountUser` if using service account

## Quick Start

```bash
# Set environment variables (optional - will use defaults otherwise)
export GCP_PROJECT_ID="your-project-id"
export TF_STATE_BUCKET="terraform-state-glz"
export TF_STATE_LOCATION="US"

# Run the setup script
./state-backend.sh
```

## What the Script Does

1. **Creates GCS Bucket**: `terraform-state-glz-{project-id}`
   - Multi-region location (default: US)
   - Uniform bucket-level access enabled

2. **Enables Versioning**: Keeps history of state files for recovery

3. **Sets Lifecycle Rules**: Keeps 5 most recent versions of non-current objects

4. **Generates Backend Config**: Creates `backend.tfvars` for each environment

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `GCP_PROJECT_ID` | (from gcloud config) | GCP project for the bucket |
| `TF_STATE_BUCKET` | `terraform-state-glz` | Bucket name prefix |
| `TF_STATE_LOCATION` | `US` | Bucket location |
| `TF_STATE_PREFIX` | `terraform/state` | Object prefix in bucket |

## After Setup

Initialize Terraform in each environment:

```bash
cd environments/prod
terraform init -backend-config=backend.tfvars

# Or use the wrapper script
./eo-deploy.sh init
```

## State Locking

GCS provides [native state locking](https://developer.hashicorp.com/terraform/language/settings/backends/gcs#state-locking) via conditional requests. No additional DynamoDB-style locking is needed.

## Troubleshooting

### Permission Denied
Ensure your account has `roles/storage.admin` on the project:
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:you@example.com" \
  --role="roles/storage.admin"
```

### Bucket Already Exists
The script will skip bucket creation if it already exists. To recreate:
```bash
gsutil rm -r gs://BUCKET_NAME
./state-backend.sh
```

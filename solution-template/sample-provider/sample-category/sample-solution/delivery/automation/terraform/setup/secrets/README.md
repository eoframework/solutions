# Secrets Setup

Pre-provisions secrets in AWS Secrets Manager and SSM Parameter Store before deploying the main infrastructure.

## Overview

This module creates:

| Secret | Storage | Purpose |
|--------|---------|---------|
| Database Password | Secrets Manager | RDS master password |
| Cache Auth Token | SSM Parameter Store | ElastiCache authentication |
| API Key | Secrets Manager | Application API key (optional) |

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.6.0

## Usage

### 1. Initialize Terraform

```bash
cd setup/secrets
terraform init
```

### 2. Create terraform.tfvars

```hcl
# Required
name_prefix = "prod-sample"
aws_region  = "us-east-1"

# Optional
environment           = "prod"
create_kms_key        = true
create_db_secret      = true
create_cache_secret   = true
create_api_key_secret = false
```

### 3. Apply

```bash
terraform apply
```

### 4. Note the Secret Names

After apply, note the secret names in the output:

```
db_password_secret_name = "prod-sample-db-password"
cache_auth_token_param_name = "/prod-sample/cache/auth-token"
```

These names are used in the main infrastructure configuration.

## Secret Naming Convention

Secrets follow this naming pattern:

| Type | Pattern | Example |
|------|---------|---------|
| Secrets Manager | `${name_prefix}-${suffix}` | `prod-sample-db-password` |
| SSM Parameter | `/${name_prefix}/${path}` | `/prod-sample/cache/auth-token` |

## Retrieving Secret Values

### Database Password (Secrets Manager)

```bash
aws secretsmanager get-secret-value \
  --secret-id prod-sample-db-password \
  --query SecretString \
  --output text
```

### Cache Auth Token (SSM Parameter)

```bash
aws ssm get-parameter \
  --name /prod-sample/cache/auth-token \
  --with-decryption \
  --query Parameter.Value \
  --output text
```

## Rotating Secrets

### Manual Rotation

```bash
# Generate new password
NEW_PASSWORD=$(openssl rand -base64 24)

# Update in Secrets Manager
aws secretsmanager put-secret-value \
  --secret-id prod-sample-db-password \
  --secret-string "$NEW_PASSWORD"
```

### Automatic Rotation

For production, configure automatic rotation:

```hcl
resource "aws_secretsmanager_secret_rotation" "db_password" {
  secret_id           = aws_secretsmanager_secret.db_password.id
  rotation_lambda_arn = aws_lambda_function.rotator.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
```

## Integration with Main Infrastructure

The main infrastructure modules reference secrets by name:

```hcl
# In database module
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "${var.name_prefix}-${var.database.password_secret_name}"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

## Security Considerations

1. **State File**: The Terraform state contains secret metadata but NOT the actual values
2. **KMS Encryption**: Secrets are encrypted with a dedicated KMS key
3. **Recovery Window**: Deleted secrets are retained for 7 days (configurable)
4. **IAM Access**: Restrict access using IAM policies on the secrets

## Cleanup

To destroy secrets:

```bash
terraform destroy
```

Note: Secrets have a recovery window. For immediate deletion:

```bash
aws secretsmanager delete-secret \
  --secret-id prod-sample-db-password \
  --force-delete-without-recovery
```

# Secrets Setup

Pre-provisions secrets in AWS Secrets Manager and SSM Parameter Store before deploying main infrastructure.

## Directory Structure

```
setup/secrets/
├── modules/
│   └── secrets/           # Reusable secrets module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── prod/                  # Production secrets
│   └── main.tf
├── test/                  # Test secrets
│   └── main.tf
└── README.md
```

## Secrets Created

| Secret | Type | Naming Pattern | Used By |
|--------|------|----------------|---------|
| Database Password | Secrets Manager | `{name_prefix}-db-password` | RDS Module |
| Cache Auth Token | SSM Parameter | `/{name_prefix}/cache/auth-token` | ElastiCache Module |
| API Key (optional) | Secrets Manager | `{name_prefix}-api-key` | Application |

## Environment Differences

| Setting | Production | Test |
|---------|------------|------|
| Name Prefix | `prod-smp` | `test-smp` |
| KMS Key | Dedicated | AWS Managed |
| Recovery Window | 7 days | Immediate (0) |

## Usage

### Deploy Production Secrets

```bash
cd setup/secrets/prod
terraform init
terraform apply
```

### Deploy Test Secrets

```bash
cd setup/secrets/test
terraform init
terraform apply
```

## Retrieving Secret Values

### Database Password (Secrets Manager)

```bash
# Production
aws secretsmanager get-secret-value \
  --secret-id prod-smp-db-password \
  --query SecretString \
  --output text

# Test
aws secretsmanager get-secret-value \
  --secret-id test-smp-db-password \
  --query SecretString \
  --output text
```

### Cache Auth Token (SSM Parameter)

```bash
# Production
aws ssm get-parameter \
  --name /prod-smp/cache/auth-token \
  --with-decryption \
  --query Parameter.Value \
  --output text

# Test
aws ssm get-parameter \
  --name /test-smp/cache/auth-token \
  --with-decryption \
  --query Parameter.Value \
  --output text
```

## How Main Infrastructure Uses Secrets

The main Terraform modules reference these secrets using data sources:

```hcl
# Database module fetches password from Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "${var.name_prefix}-${var.database.password_secret_name}"
}

# Cache module fetches auth token from SSM
data "aws_ssm_parameter" "auth_token" {
  name = "/${var.name_prefix}/${var.cache.auth_token_param_name}"
}
```

## Rotating Secrets

### Manual Rotation

```bash
# Generate new password
NEW_PASSWORD=$(openssl rand -base64 24)

# Update in Secrets Manager
aws secretsmanager put-secret-value \
  --secret-id prod-smp-db-password \
  --secret-string "$NEW_PASSWORD"
```

### Automatic Rotation (Production)

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

## Security Considerations

1. **State File**: The Terraform state contains secret metadata but NOT the actual values
2. **KMS Encryption**: Production secrets use a dedicated KMS key; test uses AWS managed
3. **Recovery Window**: Production has 7-day retention; test allows immediate deletion
4. **IAM Access**: Restrict access using IAM policies on the secrets

## Cleanup

### Test Environment

```bash
cd setup/secrets/test
terraform destroy
```

### Production Environment

```bash
cd setup/secrets/prod
terraform destroy
```

> **Warning**: Production secrets have a 7-day recovery window. For immediate deletion:
> ```bash
> aws secretsmanager delete-secret \
>   --secret-id prod-smp-db-password \
>   --force-delete-without-recovery
> ```

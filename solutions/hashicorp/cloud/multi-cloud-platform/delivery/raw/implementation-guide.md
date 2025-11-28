# HashiCorp Multi-Cloud Platform - Implementation Guide

## Prerequisites

### Technical Requirements
- AWS account with permissions for EKS, RDS, EC2, S3, KMS, IAM
- Azure subscription with service principal creation permissions
- GCP project with service account creation permissions
- GitHub Enterprise or GitHub.com organization with webhook permissions
- Kubernetes CLI (kubectl) version 1.27+
- Terraform CLI version 1.5+
- Helm version 3.12+
- HashiCorp Vault CLI version 1.14+
- AWS CLI version 2.x configured with appropriate credentials

### Skills and Expertise
- AWS EKS deployment and management experience
- HashiCorp Terraform and HCL proficiency
- HashiCorp Vault administration knowledge
- Kubernetes operations and troubleshooting
- PostgreSQL database administration
- Network security and TLS certificate management

## Implementation Process

### Phase 1: Platform Foundation (Months 1-3)

#### Step 1: AWS Infrastructure Setup

1. Create dedicated VPC for platform:
```hcl
# terraform/aws/vpc.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "tfc-platform-vpc"
  cidr = "10.100.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.100.10.0/24", "10.100.11.0/24", "10.100.12.0/24"]
  public_subnets  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Project     = "multi-cloud-platform"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

2. Deploy EKS cluster for Terraform Cloud:
```hcl
# terraform/aws/eks.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.0"

  cluster_name    = "tfc-platform-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    tfc-workers = {
      min_size     = 3
      max_size     = 6
      desired_size = 3
      instance_types = ["t3.xlarge"]
    }
  }
}
```

3. Create RDS PostgreSQL instance:
```hcl
# terraform/aws/rds.tf
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.0"

  identifier = "tfc-backend-db"

  engine               = "postgres"
  engine_version       = "14.8"
  instance_class       = "db.t3.large"
  allocated_storage    = 100
  storage_encrypted    = true
  kms_key_id          = aws_kms_key.rds.arn

  db_name  = "terraform_cloud"
  username = "tfc_admin"
  port     = 5432

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 30
  skip_final_snapshot     = false
}
```

4. Create KMS keys for encryption:
```hcl
# terraform/aws/kms.tf
resource "aws_kms_key" "vault_unseal" {
  description             = "Vault auto-unseal key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Purpose = "vault-auto-unseal"
  }
}

resource "aws_kms_key" "rds" {
  description             = "RDS encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}
```

#### Step 2: Terraform Cloud Installation

1. Add HashiCorp Helm repository:
```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

2. Create namespace and secrets:
```bash
kubectl create namespace terraform-cloud
kubectl create secret generic tfc-license \
  --namespace terraform-cloud \
  --from-file=license=./license.hclic
kubectl create secret generic tfc-tls \
  --namespace terraform-cloud \
  --from-file=tls.crt=./tfc.crt \
  --from-file=tls.key=./tfc.key
```

3. Install Terraform Cloud on EKS:
```yaml
# values/terraform-cloud.yaml
replicaCount: 3

service:
  type: LoadBalancer
  port: 443

database:
  host: tfc-backend-db.xxxxx.us-east-1.rds.amazonaws.com
  port: 5432
  name: terraform_cloud
  user: tfc_admin
  passwordSecretName: tfc-db-password

storage:
  type: s3
  s3:
    bucket: tfc-state-bucket
    region: us-east-1

tls:
  enabled: true
  secretName: tfc-tls
```

```bash
helm install terraform-cloud hashicorp/terraform-enterprise \
  --namespace terraform-cloud \
  --values values/terraform-cloud.yaml
```

#### Step 3: HashiCorp Vault Deployment

1. Deploy Vault HA cluster on EC2:
```hcl
# terraform/aws/vault.tf
module "vault" {
  source = "./modules/vault-ha"

  cluster_name     = "vault-platform"
  instance_type    = "t3.medium"
  instance_count   = 3
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets

  kms_key_id       = aws_kms_key.vault_unseal.id
  auto_unseal      = true

  storage_backend  = "raft"
}
```

2. Initialize Vault cluster:
```bash
# Initialize primary node
vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -recovery-shares=5 \
  -recovery-threshold=3

# Vault will auto-unseal using KMS
```

3. Configure audit logging:
```bash
vault audit enable file file_path=/vault/logs/audit.log
vault audit enable syslog tag="vault" facility="AUTH"
```

4. Enable secrets engines for dynamic credentials:
```bash
# AWS secrets engine
vault secrets enable aws
vault write aws/config/root \
  access_key=$AWS_ACCESS_KEY_ID \
  secret_key=$AWS_SECRET_ACCESS_KEY \
  region=us-east-1

vault write aws/roles/terraform-dynamic-creds \
  credential_type=iam_user \
  policy_arns=arn:aws:iam::aws:policy/AdministratorAccess \
  default_ttl=3600 \
  max_ttl=86400

# Azure secrets engine
vault secrets enable azure
vault write azure/config \
  subscription_id=$AZURE_SUBSCRIPTION_ID \
  tenant_id=$AZURE_TENANT_ID \
  client_id=$AZURE_CLIENT_ID \
  client_secret=$AZURE_CLIENT_SECRET

vault write azure/roles/terraform-azure-creds \
  azure_roles=- \
  ttl=3600 \
  max_ttl=86400

# GCP secrets engine
vault secrets enable gcp
vault write gcp/config \
  credentials=@gcp-credentials.json

vault write gcp/roleset/terraform-gcp-creds \
  project=$GCP_PROJECT_ID \
  secret_type=service_account_key \
  bindings=- \
  ttl=3600
```

#### Step 4: VCS Integration

1. Configure GitHub OAuth application:
- Navigate to GitHub Organization Settings > Developer Settings > OAuth Apps
- Create new OAuth App with callback URL: `https://tfc.example.com/auth/github/callback`
- Note Client ID and Client Secret

2. Configure VCS provider in Terraform Cloud:
```bash
# Using TFC API
curl \
  --header "Authorization: Bearer $TFC_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data @- \
  https://app.terraform.io/api/v2/organizations/$ORG/oauth-clients <<EOF
{
  "data": {
    "type": "oauth-clients",
    "attributes": {
      "name": "GitHub Enterprise",
      "service-provider": "github",
      "oauth-token-string": "$GITHUB_OAUTH_TOKEN",
      "http-url": "https://github.example.com",
      "api-url": "https://github.example.com/api/v3"
    }
  }
}
EOF
```

#### Step 5: Pilot Workspace Migration

1. Export existing state from S3:
```bash
# For each workspace
terraform state pull > workspace-state.json
```

2. Create workspace in Terraform Cloud:
```hcl
# workspaces/pilot/main.tf
resource "tfe_workspace" "pilot" {
  for_each = toset(var.pilot_workspaces)

  name         = each.value
  organization = var.tfc_organization

  vcs_repo {
    identifier     = "${var.github_org}/${each.value}"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  working_directory = "terraform"
  auto_apply        = false
}
```

3. Migrate state to Terraform Cloud:
```bash
# Update backend configuration
terraform {
  cloud {
    organization = "your-org"
    workspaces {
      name = "workspace-name"
    }
  }
}

# Initialize and migrate
terraform init -migrate-state
```

4. Validate migration:
```bash
# Compare resource counts
terraform state list | wc -l
# Run plan to verify no changes
terraform plan
```

### Phase 2: Governance & Expansion (Months 4-6)

#### Step 6: Sentinel Policy Development

1. Create policy framework structure:
```
sentinel-policies/
├── security/
│   ├── require-encryption.sentinel
│   ├── restrict-public-access.sentinel
│   └── require-mfa.sentinel
├── cost/
│   ├── restrict-instance-sizes.sentinel
│   ├── require-tags.sentinel
│   └── budget-limits.sentinel
└── compliance/
    ├── soc2-controls.sentinel
    └── iso27001-controls.sentinel
```

2. Example security policy - require encryption:
```hcl
# security/require-encryption.sentinel
import "tfplan/v2" as tfplan

# Get all S3 buckets
s3_buckets = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_s3_bucket" and
  (rc.change.actions contains "create" or rc.change.actions contains "update")
}

# Require server-side encryption
require_encryption = rule {
  all s3_buckets as _, bucket {
    bucket.change.after.server_side_encryption_configuration is not null
  }
}

main = rule {
  require_encryption
}
```

3. Example cost policy - require tags:
```hcl
# cost/require-tags.sentinel
import "tfplan/v2" as tfplan

required_tags = ["Environment", "Owner", "CostCenter", "Project"]

# Get all resources that support tags
taggable_resources = filter tfplan.resource_changes as _, rc {
  rc.change.after.tags is not null
}

# Check required tags
require_tags = rule {
  all taggable_resources as _, resource {
    all required_tags as tag {
      resource.change.after.tags contains tag
    }
  }
}

main = rule {
  require_tags
}
```

4. Deploy policy sets:
```hcl
# policy-sets/main.tf
resource "tfe_policy_set" "security" {
  name         = "security-policies"
  description  = "Security policy enforcement"
  organization = var.tfc_organization
  kind         = "sentinel"

  vcs_repo {
    identifier     = "${var.github_org}/sentinel-policies"
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  policy_path = "security"

  workspace_ids = [for ws in tfe_workspace.all : ws.id]
}
```

#### Step 7: Full Workspace Migration

1. Create migration waves:
```hcl
# Wave 2: 50 workspaces
locals {
  wave_2_workspaces = [
    "app-frontend-aws-dev",
    "app-frontend-aws-staging",
    "app-backend-aws-dev",
    # ... additional workspaces
  ]
}
```

2. Execute batch migration:
```bash
#!/bin/bash
# migrate-workspaces.sh

for workspace in "${WORKSPACES[@]}"; do
  echo "Migrating $workspace..."

  # Create workspace
  terraform -chdir=workspaces/$workspace apply -auto-approve

  # Migrate state
  cd repos/$workspace
  terraform init -migrate-state -input=false

  # Validate
  terraform plan -detailed-exitcode
  if [ $? -eq 0 ]; then
    echo "$workspace migrated successfully"
  else
    echo "$workspace has drift - investigate"
  fi
  cd -
done
```

### Phase 3: Advanced Capabilities (Months 7-9)

#### Step 8: Consul Service Mesh

1. Deploy Consul on EKS:
```yaml
# values/consul.yaml
global:
  name: consul
  datacenter: dc1
  tls:
    enabled: true
    enableAutoEncrypt: true
  acls:
    manageSystemACLs: true

server:
  replicas: 3
  storage: 10Gi

connectInject:
  enabled: true
  default: true

controller:
  enabled: true

ingressGateways:
  enabled: true
  defaults:
    replicas: 2
```

```bash
helm install consul hashicorp/consul \
  --namespace consul \
  --values values/consul.yaml
```

2. Configure service mesh intentions:
```bash
consul intention create -allow web api
consul intention create -allow api database
```

#### Step 9: Monitoring and Alerting

1. Deploy CloudWatch dashboards:
```hcl
# monitoring/cloudwatch.tf
resource "aws_cloudwatch_dashboard" "platform" {
  dashboard_name = "tfc-platform-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "EKS CPU Utilization"
          metrics = [
            ["AWS/EKS", "pod_cpu_utilization", "ClusterName", "tfc-platform-cluster"]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "RDS Connections"
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "tfc-backend-db"]
          ]
        }
      }
    ]
  })
}
```

2. Configure Datadog integration:
```yaml
# datadog/values.yaml
datadog:
  apiKey: ${DATADOG_API_KEY}
  appKey: ${DATADOG_APP_KEY}

  logs:
    enabled: true
    containerCollectAll: true

  apm:
    enabled: true
```

## Troubleshooting

### Common Issues

#### Terraform Cloud Run Failures
- **Symptom:** Runs fail with "Error acquiring state lock"
- **Resolution:** Check for zombie runs, clear state lock using TFC API:
```bash
curl -X POST \
  --header "Authorization: Bearer $TFC_TOKEN" \
  "https://app.terraform.io/api/v2/workspaces/$WORKSPACE_ID/actions/force-unlock"
```

#### Vault Credential Generation Failures
- **Symptom:** "Error generating credentials: permission denied"
- **Resolution:** Verify Vault policy attached to role:
```bash
vault policy read terraform-policy
vault read aws/roles/terraform-dynamic-creds
```

#### State Migration Drift
- **Symptom:** Plan shows unexpected changes after migration
- **Resolution:**
1. Compare state files before and after
2. Check for provider version differences
3. Verify state was fully migrated (no partial migration)

### Resolution Procedures

#### EKS Node Recovery
```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Drain and cordon problematic node
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
kubectl delete node <node-name>

# EKS Auto Scaling Group will replace the node
```

#### Vault Standby Node Promotion
```bash
# Check Vault status
vault status

# If leader is unavailable, step-down will trigger election
vault operator step-down

# Verify new leader
vault status
```

## Support and Maintenance

### Ongoing Operations
- Daily health checks via CloudWatch/Datadog dashboards
- Weekly backup verification and restoration testing
- Monthly security patching for EKS nodes
- Quarterly Sentinel policy reviews and updates

### Support Resources
- HashiCorp Terraform Cloud documentation: https://developer.hashicorp.com/terraform/cloud-docs
- HashiCorp Vault documentation: https://developer.hashicorp.com/vault/docs
- HashiCorp Consul documentation: https://developer.hashicorp.com/consul/docs
- AWS EKS documentation: https://docs.aws.amazon.com/eks/
- Internal runbook: /delivery/docs/operations-runbook.md

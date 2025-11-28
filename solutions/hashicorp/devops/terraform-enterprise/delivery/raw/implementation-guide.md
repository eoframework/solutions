# HashiCorp Terraform Enterprise - Implementation Guide

## Prerequisites

### Technical Requirements
- AWS account with permissions for EKS, RDS, S3, KMS, IAM
- GitHub organization with webhook configuration permissions
- Kubernetes CLI (kubectl) version 1.27+
- Terraform CLI version 1.5+
- Helm version 3.12+
- AWS CLI version 2.x configured with appropriate credentials
- HashiCorp Terraform Enterprise license file

### Skills and Expertise
- AWS EKS deployment and management experience
- HashiCorp Terraform and HCL proficiency
- Kubernetes operations and troubleshooting
- PostgreSQL database administration
- Network security and TLS certificate management

## Implementation Process

### Phase 1: Foundation & Migration (Months 1-3)

#### Step 1: AWS Infrastructure Setup

1. Create dedicated VPC for TFE platform:
```hcl
# terraform/aws/vpc.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "tfe-platform-vpc"
  cidr = "10.50.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.50.10.0/24", "10.50.11.0/24"]
  public_subnets  = ["10.50.1.0/24", "10.50.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project     = "terraform-enterprise"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

2. Deploy EKS cluster for Terraform Enterprise:
```hcl
# terraform/aws/eks.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.0"

  cluster_name    = "tfe-platform-cluster"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    tfe-workers = {
      min_size     = 3
      max_size     = 5
      desired_size = 3
      instance_types = ["t3.large"]
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

  identifier = "tfe-state-db"

  engine               = "postgres"
  engine_version       = "14.8"
  instance_class       = "db.t3.medium"
  allocated_storage    = 50
  storage_encrypted    = true
  kms_key_id          = aws_kms_key.rds.arn

  db_name  = "tfe_state"
  username = "tfe_admin"
  port     = 5432

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 7
  skip_final_snapshot     = false
}
```

#### Step 2: Terraform Enterprise Installation

1. Add HashiCorp Helm repository:
```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
```

2. Create namespace and secrets:
```bash
kubectl create namespace terraform-enterprise
kubectl create secret generic tfe-license \
  --namespace terraform-enterprise \
  --from-file=license=./license.hclic
kubectl create secret generic tfe-tls \
  --namespace terraform-enterprise \
  --from-file=tls.crt=./tfe.crt \
  --from-file=tls.key=./tfe.key
```

3. Install Terraform Enterprise on EKS:
```yaml
# values/tfe.yaml
replicaCount: 2

service:
  type: LoadBalancer
  port: 443

database:
  host: tfe-state-db.xxxxx.us-east-1.rds.amazonaws.com
  port: 5432
  name: tfe_state
  user: tfe_admin
  passwordSecretName: tfe-db-password

tls:
  enabled: true
  secretName: tfe-tls
```

```bash
helm install terraform-enterprise hashicorp/terraform-enterprise \
  --namespace terraform-enterprise \
  --values values/tfe.yaml
```

#### Step 3: VCS Integration

1. Configure GitHub OAuth application:
- Navigate to GitHub Organization Settings > Developer Settings > OAuth Apps
- Create new OAuth App with callback URL: `https://tfe.example.com/auth/github/callback`
- Note Client ID and Client Secret

2. Configure VCS provider in Terraform Enterprise:
- Log into TFE as admin
- Navigate to Settings > VCS Providers
- Add GitHub.com or GitHub Enterprise provider
- Enter OAuth credentials and test connection

#### Step 4: Workspace Migration

1. Export existing state from S3/local:
```bash
# For each workspace
terraform state pull > workspace-state.json
```

2. Create workspace in Terraform Enterprise:
```hcl
# workspaces/main.tf
resource "tfe_workspace" "workspaces" {
  for_each = toset(var.workspace_names)

  name         = each.value
  organization = var.tfe_organization

  vcs_repo {
    identifier     = "${var.github_org}/${each.value}"
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  working_directory = "terraform"
  auto_apply        = false
}
```

3. Migrate state to Terraform Enterprise:
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

### Phase 2: Governance & Integration (Months 4-5)

#### Step 5: Sentinel Policy Development

1. Create policy framework structure:
```
sentinel-policies/
├── security/
│   ├── require-encryption.sentinel
│   ├── restrict-public-access.sentinel
│   └── require-iam-policies.sentinel
├── cost/
│   ├── restrict-instance-sizes.sentinel
│   └── require-tags.sentinel
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

3. Deploy policy sets:
```hcl
# policy-sets/main.tf
resource "tfe_policy_set" "security" {
  name         = "security-policies"
  description  = "Security policy enforcement"
  organization = var.tfe_organization
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

#### Step 6: HashiCorp Vault Integration

1. Configure Vault AWS secrets engine:
```bash
# Enable AWS secrets engine
vault secrets enable aws

vault write aws/config/root \
  access_key=$AWS_ACCESS_KEY_ID \
  secret_key=$AWS_SECRET_ACCESS_KEY \
  region=us-east-1

vault write aws/roles/tfe-aws-credentials \
  credential_type=iam_user \
  policy_arns=arn:aws:iam::aws:policy/PowerUserAccess \
  default_ttl=3600 \
  max_ttl=86400
```

2. Configure TFE Vault integration:
- Navigate to TFE Settings > Variable Sets
- Create organization-wide variable set
- Add Vault address and authentication credentials
- Configure workspace variables to use Vault provider

#### Step 7: Private Module Registry

1. Create module repository structure:
```
terraform-aws-vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

2. Publish module to registry:
- Connect GitHub repository to TFE
- TFE automatically discovers modules with proper naming
- Modules published with semantic versioning via Git tags

3. Consume modules in workspaces:
```hcl
module "vpc" {
  source  = "app.terraform.io/your-org/vpc/aws"
  version = "1.0.0"

  cidr_block = "10.0.0.0/16"
}
```

### Phase 3: Optimization & Enablement (Month 6)

#### Step 8: Self-Service Configuration

1. Configure workspace templates:
```hcl
# templates/workspace-template.tf
resource "tfe_workspace" "template" {
  name         = var.workspace_name
  organization = var.tfe_organization

  vcs_repo {
    identifier     = var.repo_identifier
    oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
  }

  # Apply security policy set automatically
  policy_set_ids = [tfe_policy_set.security.id]

  # Standard tags
  tag_names = ["managed", var.environment, var.team]
}
```

2. Configure approval workflows:
- Navigate to Workspace Settings > Run Triggers
- Enable "Require approval" for production workspaces
- Configure notification rules for approval requests

#### Step 9: Monitoring Setup

1. Configure CloudWatch dashboards:
```hcl
# monitoring/cloudwatch.tf
resource "aws_cloudwatch_dashboard" "tfe" {
  dashboard_name = "tfe-platform-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "EKS CPU Utilization"
          metrics = [
            ["AWS/EKS", "pod_cpu_utilization", "ClusterName", "tfe-platform-cluster"]
          ]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "RDS Connections"
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "tfe-state-db"]
          ]
        }
      }
    ]
  })
}
```

2. Configure alerts:
```hcl
resource "aws_cloudwatch_metric_alarm" "tfe_unhealthy" {
  alarm_name          = "tfe-unhealthy-pods"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "TFE pod restarts exceed threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

## Troubleshooting

### Common Issues

#### Workspace Run Failures
- **Symptom:** Runs fail with "Error acquiring state lock"
- **Resolution:** Check for zombie runs, clear state lock via TFE UI

#### VCS Webhook Failures
- **Symptom:** Commits don't trigger runs
- **Resolution:** Verify webhook configuration, check GitHub webhook delivery logs

#### Policy Failures
- **Symptom:** Plans blocked by Sentinel policies
- **Resolution:** Review policy check output, update code to comply or request exception

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

#### State Recovery
```bash
# List state versions in TFE
# Navigate to Workspace > States
# Select previous version and download
# Restore via terraform state push if needed
```

## Support and Maintenance

### Ongoing Operations
- Daily health checks via CloudWatch dashboards
- Weekly backup verification
- Monthly security patching for EKS nodes
- Quarterly Sentinel policy reviews

### Support Resources
- HashiCorp Terraform Enterprise documentation: https://developer.hashicorp.com/terraform/enterprise
- HashiCorp Support Portal: https://support.hashicorp.com
- Internal runbook: /delivery/docs/operations-runbook.md

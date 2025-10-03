# Multi-Cloud Terraform Infrastructure

This repository contains a comprehensive Terraform project designed to manage infrastructure across AWS, Azure, and Google Cloud Platform with proper state management, modular architecture, and best practices.

## 🏗️ Architecture Overview

```
terraform/
├── environments/             # Self-contained environment configurations
│   ├── production/
│   │   ├── terraform.tf      # Terraform version & backend config
│   │   ├── providers.tf      # Cloud provider configurations
│   │   ├── main.tf           # Infrastructure deployment (clean)
│   │   ├── variables.tf      # Environment-specific variables
│   │   ├── outputs.tf        # Environment outputs
│   │   └── config/           # Production environment configs (tfvars)
│   ├── disaster-recovery/
│   │   ├── terraform.tf      # Terraform version & backend config
│   │   ├── providers.tf      # Cloud provider configurations
│   │   ├── main.tf           # Infrastructure deployment (clean)
│   │   ├── variables.tf      # Environment-specific variables
│   │   ├── outputs.tf        # Environment outputs
│   │   └── config/           # DR environment configs (tfvars)
│   └── test/
│       ├── terraform.tf      # Terraform version & backend config
│       ├── providers.tf      # Cloud provider configurations
│       ├── main.tf           # Infrastructure deployment (clean)
│       ├── variables.tf      # Environment-specific variables
│       ├── outputs.tf        # Environment outputs
│       └── config/           # Test environment configs (tfvars)
├── modules/                  # Provider-specific modules
│   ├── aws/                  # AWS-specific resources and submodules
│   │   ├── networking/       # AWS VPC, subnets, routing
│   │   ├── security/         # AWS Security Groups, IAM, KMS
│   │   ├── monitoring/       # AWS CloudWatch, CloudTrail
│   │   └── compute/          # AWS EC2, Auto Scaling, Load Balancers
│   ├── azure/                # Azure-specific resources and submodules
│   │   ├── networking/       # Azure VNet, subnets, routing
│   │   ├── security/         # Azure NSGs, Key Vault, RBAC
│   │   ├── monitoring/       # Azure Monitor, Log Analytics
│   │   └── compute/          # Azure VMs, Scale Sets, Load Balancers
│   └── gcp/                  # GCP-specific resources and submodules
│       ├── networking/       # GCP VPC, subnets, routing
│       ├── security/         # GCP Firewall, IAM, Secret Manager
│       ├── monitoring/       # GCP Cloud Monitoring, Logging
│       └── compute/          # GCP Compute Engine, Instance Groups
├── scripts/                  # Automation scripts
└── docs/                     # Documentation
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform**: Install Terraform >= 1.6.0
   ```bash
   # macOS
   brew install terraform

   # Windows
   choco install terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   ```

2. **Cloud CLIs**: Install and configure cloud provider CLIs
   ```bash
   # AWS CLI
   aws configure --profile production
   aws configure --profile disaster-recovery
   aws configure --profile test

   # Azure CLI
   az login

   # Google Cloud CLI
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

### Initial Setup

1. **Clone and Configure**
   ```bash
   cd terraform/
   cp environments/production/config/project.tfvars.example environments/production/config/project.tfvars
   # Edit the tfvars file with your project settings
   ```

2. **Setup Remote State Backend**

   Choose your preferred cloud provider for state storage:

   **AWS Backend:**
   ```bash
   cd scripts/
   ./init-backend-aws.sh my-project-name us-east-1 production
   ./init-production.sh
   ```

   **Azure Backend:**
   ```bash
   cd scripts/
   ./init-backend-azure.sh my-project-name "East US" subscription-id
   ./init-production-azure.sh
   ```

   **GCP Backend:**
   ```bash
   cd scripts/
   ./init-backend-gcp.sh my-gcp-project-id my-project-name us-central1
   ./init-production-gcp.sh
   ```

3. **Deploy Infrastructure**
   ```bash
   cd environments/production/
   terraform plan -var-file=config/project.tfvars
   terraform apply -var-file=config/project.tfvars
   ```

## 🌍 Multi-Environment Support

### Environment Structure

Each environment is completely self-contained with:
- **terraform.tf**: Terraform version requirements and backend configuration
- **providers.tf**: Cloud provider authentication and settings
- **main.tf**: Clean infrastructure deployment focused on resources
- **variables.tf**: Environment-specific variable definitions
- **outputs.tf**: Environment-specific output definitions
- **config/**: Environment-specific tfvars files
- **State file**: Separate Terraform state for complete isolation

### Environment Differences

| Environment | Purpose | Resource Sizing | Backup Policy | Auto-Shutdown |
|-------------|---------|-----------------|---------------|---------------|
| **Production** | Live workloads | Large instances | Daily backups | Disabled |
| **Disaster Recovery** | Business continuity | Medium instances | Continuous replication | Disabled |
| **Test** | Development/Testing | Small instances | Weekly backups | Enabled |

### Working with Environments

```bash
# Production Environment
cd environments/production/
terraform plan -var-file=config/project.tfvars \\
               -var-file=config/networking.tfvars \\
               -var-file=config/security.tfvars \\
               -var-file=config/compute.tfvars

# Test Environment
cd environments/test/
terraform plan -var-file=config/project.tfvars \\
               -var-file=config/networking.tfvars
```

## 📁 Configuration Management

Configuration is separated by functionality for better management:

### Core Configuration Files

- **`project.tfvars`**: Project identity, cloud providers, regions
- **`networking.tfvars`**: VPC, subnets, DNS configuration
- **`security.tfvars`**: Security groups, firewalls, encryption
- **`compute.tfvars`**: VMs, databases, load balancers, auto-scaling

### Example Configuration

```hcl
# environments/production/config/project.tfvars
project_name = "my-enterprise-project"
enable_aws_resources = true
enable_azure_resources = false
enable_gcp_resources = false

aws_profile = "production"
aws_region = "us-east-1"
```

## 🔧 Modules

### Provider-Specific Module Structure

Each provider has its own complete set of modules:

**AWS Modules:**
- **`modules/aws/networking/`**: VPC, subnets, internet gateways, route tables
- **`modules/aws/security/`**: Security groups, NACLs, IAM roles and policies
- **`modules/aws/monitoring/`**: CloudWatch dashboards, alarms, CloudTrail logging
- **`modules/aws/compute/`**: EC2 instances, Auto Scaling Groups, Load Balancers

**Azure Modules:**
- **`modules/azure/networking/`**: Virtual Networks, subnets, route tables
- **`modules/azure/security/`**: Network Security Groups, Key Vault, RBAC
- **`modules/azure/monitoring/`**: Azure Monitor, Log Analytics, Application Insights
- **`modules/azure/compute/`**: Virtual Machines, Scale Sets, Load Balancers

**GCP Modules:**
- **`modules/gcp/networking/`**: VPC networks, subnets, Cloud Router
- **`modules/gcp/security/`**: Firewall rules, IAM policies, Secret Manager
- **`modules/gcp/monitoring/`**: Cloud Monitoring, Cloud Logging, alerting
- **`modules/gcp/compute/`**: Compute Engine, Managed Instance Groups, Load Balancers

### Module Usage

Each environment has a clean separation of concerns:

**terraform.tf** - Configuration management:
```hcl
terraform {
  backend "s3" {
    # Backend configuration
  }
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
```

**providers.tf** - Authentication setup:
```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags { tags = local.common_tags }
}
```

**main.tf** - Infrastructure deployment:
```hcl
# Clean focus on resource deployment
module "aws_infrastructure" {
  count  = var.enable_aws_resources ? 1 : 0
  source = "../../modules/aws"

  project_name = var.project_name
  environment  = "production"
  name_prefix  = local.name_prefix
  region       = var.aws_region
  tags         = local.common_tags
}

# Each provider module internally calls its submodules:
# - aws/networking for VPC and subnets
# - aws/security for security groups and IAM
# - aws/monitoring for CloudWatch and CloudTrail
# - aws/compute for EC2 and load balancers
```

## 💾 State Management

### Remote State Backends

The project supports multiple backend options:

1. **AWS S3 + DynamoDB**: Versioned state with locking
2. **Azure Storage**: Blob storage with lease-based locking
3. **Google Cloud Storage**: Versioned state storage

### State File Organization

```
# AWS S3 Backend Structure
s3://project-terraform-state-region/
├── production/terraform.tfstate
├── disaster-recovery/terraform.tfstate
└── test/terraform.tfstate

# Each environment isolated with separate state files
```

### State Security

- **Encryption**: All state files encrypted at rest
- **Access Control**: IAM policies restrict state access
- **Versioning**: State file versioning enabled
- **Locking**: Prevents concurrent modifications

## 🔐 Security Best Practices

### Authentication

- **AWS**: Use IAM roles or profiles, avoid hardcoded credentials
- **Azure**: Use Azure CLI authentication or service principals
- **GCP**: Use service accounts or gcloud authentication

### Resource Security

- **Encryption**: All data encrypted at rest and in transit
- **Network Security**: Private subnets, security groups, NACLs
- **Access Control**: Principle of least privilege
- **Monitoring**: Comprehensive logging and alerting

### Secrets Management

```hcl
# Use cloud-native secret management
variable "database_password" {
  description = "Database password from secret manager"
  type        = string
  sensitive   = true
}
```

## 📊 Monitoring and Observability

### Built-in Monitoring

The project includes comprehensive monitoring via the common monitoring module:

- **Dashboards**: Provider-specific dashboards for key metrics
- **Alerts**: Configurable alerting for CPU, memory, disk, and application metrics
- **Logging**: Centralized log aggregation and analysis
- **Cost Monitoring**: Cost tracking and budget alerts

### Monitoring Configuration

```hcl
# Enable monitoring for active providers
module "monitoring" {
  source = "./modules/common/monitoring"

  aws_enabled   = var.enable_aws_resources
  azure_enabled = var.enable_azure_resources
  gcp_enabled   = var.enable_gcp_resources

  alert_notifications = [
    {
      type   = "email"
      target = "ops-team@company.com"
    }
  ]
}
```

## 📖 Terraform Documentation

### Generating Documentation

The project includes terraform-docs configuration for automatic documentation generation:

```bash
# Install terraform-docs
brew install terraform-docs

# Generate module documentation
terraform-docs markdown table modules/aws/ > modules/aws/README.md
terraform-docs markdown table modules/azure/ > modules/azure/README.md
terraform-docs markdown table modules/gcp/ > modules/gcp/README.md

# Generate environment documentation
terraform-docs markdown table environments/production/ > environments/production/README.md
terraform-docs markdown table environments/test/ > environments/test/README.md
terraform-docs markdown table environments/disaster-recovery/ > environments/disaster-recovery/README.md
```

### Viewing Documentation

1. **Module Documentation**: Each module contains auto-generated README.md
2. **Environment Documentation**: Each environment contains its own README.md
3. **This README**: Comprehensive usage guide

### Documentation Generation Automation

Add to your CI/CD pipeline:

```yaml
# .github/workflows/docs.yml
- name: Generate terraform docs
  run: |
    terraform-docs markdown table modules/aws/ > modules/aws/README.md
    terraform-docs markdown table modules/azure/ > modules/azure/README.md
    terraform-docs markdown table modules/gcp/ > modules/gcp/README.md
    terraform-docs markdown table environments/production/ > environments/production/README.md
    terraform-docs markdown table environments/test/ > environments/test/README.md
    terraform-docs markdown table environments/disaster-recovery/ > environments/disaster-recovery/README.md
```

## 🚀 Deployment Workflows

### Manual Deployment

```bash
# 1. Plan changes
terraform plan -var-file=config/project.tfvars \\
               -var-file=config/networking.tfvars \\
               -out=production.tfplan

# 2. Review plan
terraform show production.tfplan

# 3. Apply changes
terraform apply production.tfplan
```

### Automated Deployment (CI/CD)

```yaml
# Example GitHub Actions workflow
name: Terraform Deploy
on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0

      - name: Terraform Plan
        run: |
          cd environments/production
          terraform init -backend-config=backend.hcl
          terraform plan -var-file=config/project.tfvars

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

## 🔄 Disaster Recovery

### Multi-Region Setup

The disaster recovery environment deploys to different regions:

```hcl
# Production: us-east-1
# DR: us-west-2
aws_region = "us-west-2"

# Automated backups and replication
rds_config = {
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  multi_az              = true
}
```

### RTO/RPO Configuration

```hcl
# Disaster Recovery specific variables
recovery_time_objective  = "4h"  # RTO
recovery_point_objective = "1h"  # RPO
```

## 🏷️ Resource Naming Convention

All resources follow a consistent naming pattern:

```
{project-name}-{environment}-{resource-type}-{identifier}

Examples:
- my-project-production-vpc-main
- my-project-test-ec2-web-01
- my-project-dr-rds-primary
```

## 🔍 Troubleshooting

### Common Issues

1. **State Lock Issues**
   ```bash
   # Force unlock (use carefully)
   terraform force-unlock LOCK_ID
   ```

2. **Provider Authentication**
   ```bash
   # AWS
   aws sts get-caller-identity --profile production

   # Azure
   az account show

   # GCP
   gcloud auth list
   ```

3. **Module Source Issues**
   ```bash
   # Clear module cache
   rm -rf .terraform/modules/
   terraform init
   ```

### Debug Mode

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform plan
```

## 📋 Best Practices Checklist

- [ ] Use separate state files per environment
- [ ] Enable state file encryption and versioning
- [ ] Implement proper IAM roles and permissions
- [ ] Use variables for all configurable values
- [ ] Tag all resources consistently
- [ ] Enable monitoring and alerting
- [ ] Implement backup and disaster recovery
- [ ] Use terraform-docs for documentation
- [ ] Validate configurations with terraform validate
- [ ] Use terraform fmt for consistent formatting
- [ ] Implement cost monitoring and budgets
- [ ] Regular security audits and updates

## 🆘 Support

For questions and support:

1. Check the troubleshooting section above
2. Review terraform logs with debug mode enabled
3. Consult cloud provider documentation
4. Open an issue in the project repository

## 🔄 Updates and Maintenance

### Regular Maintenance Tasks

1. **Update Terraform and providers** quarterly
2. **Review and rotate credentials** monthly
3. **Update documentation** with changes
4. **Review resource costs** monthly
5. **Test disaster recovery procedures** quarterly
6. **Security patches and updates** as needed

### Version Upgrades

```bash
# Update Terraform version
terraform version
# Update terraform.tf required_version

# Update provider versions
terraform init -upgrade
```
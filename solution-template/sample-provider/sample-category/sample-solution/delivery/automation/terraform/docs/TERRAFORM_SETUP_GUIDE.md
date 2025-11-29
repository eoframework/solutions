# Terraform Setup Guide

This guide provides step-by-step instructions for setting up and using the multi-cloud Terraform infrastructure.

## 📋 Prerequisites Checklist

Before getting started, ensure you have the following:

### Required Tools

- [ ] **Terraform** >= 1.6.0 ([Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- [ ] **AWS CLI** v2 ([Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- [ ] **Azure CLI** ([Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- [ ] **Google Cloud CLI** ([Installation Guide](https://cloud.google.com/sdk/docs/install))
- [ ] **terraform-docs** ([Installation Guide](https://terraform-docs.io/user-guide/installation/))

### Cloud Provider Accounts

- [ ] **AWS Account** with appropriate IAM permissions
- [ ] **Azure Subscription** with contributor access
- [ ] **Google Cloud Project** with necessary APIs enabled

## 🔐 Authentication Setup

### AWS Authentication

```bash
# Configure AWS profiles for each environment
aws configure --profile production
aws configure --profile disaster-recovery
aws configure --profile test

# Verify authentication
aws sts get-caller-identity --profile production
```

### Azure Authentication

```bash
# Login to Azure
az login

# Set subscription (if multiple)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

### Google Cloud Authentication

```bash
# Login to Google Cloud
gcloud auth login

# Set project
gcloud config set project your-project-id

# Verify authentication
gcloud auth list
```

## 🏗️ Initial Project Setup

### 1. Project Configuration

```bash
# Navigate to terraform directory
cd solution-template/sample-provider/sample-category/sample-solution/delivery/scripts/terraform/

# Copy and customize project configuration
cp environments/production/config/project.tfvars.example environments/production/config/project.tfvars
```

Edit `environments/production/config/project.tfvars`:

```hcl
# Update with your project details
project_name = "your-project-name"

# Enable desired cloud providers
enable_aws_resources   = true
enable_azure_resources = false
enable_gcp_resources   = false

# Configure authentication
aws_profile    = "production"
gcp_project_id = "your-gcp-project-id"

# Set regions
aws_region     = "us-east-1"
azure_location = "East US"
gcp_region     = "us-central1"
```

### 2. Backend Initialization

Choose your preferred backend provider and run the initialization script:

#### AWS S3 Backend (Recommended)

```bash
cd scripts/
./init-backend-aws.sh your-project-name us-east-1 production
```

#### Azure Storage Backend

```bash
cd scripts/
./init-backend-azure.sh your-project-name "East US" your-subscription-id
```

#### Google Cloud Storage Backend

```bash
cd scripts/
./init-backend-gcp.sh your-gcp-project-id your-project-name us-central1
```

### 3. Environment Initialization

After backend setup, initialize each environment:

```bash
# Initialize production environment
cd scripts/
./init-production.sh

# Initialize disaster recovery environment
./init-disaster-recovery.sh

# Initialize test environment
./init-test.sh
```

## 🚀 First Deployment

### 1. Validate Configuration

```bash
# Navigate to production environment
cd environments/production/

# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive
```

### 2. Plan Deployment

```bash
# Create execution plan
terraform plan \\
  -var-file=config/project.tfvars \\
  -var-file=config/networking.tfvars \\
  -var-file=config/security.tfvars \\
  -var-file=config/compute.tfvars \\
  -out=production.tfplan

# Review the plan
terraform show production.tfplan
```

### 3. Apply Changes

```bash
# Apply the planned changes
terraform apply production.tfplan
```

### 4. Verify Deployment

```bash
# Check outputs
terraform output

# Verify resources in cloud console
terraform show
```

## 🔧 Daily Operations

### Working with Different Environments

```bash
# Switch to test environment
cd environments/test/

# Plan with test configuration
terraform plan -var-file=config/project.tfvars

# Apply to test environment
terraform apply -auto-approve -var-file=config/project.tfvars
```

### Configuration Management

```bash
# Update networking configuration
vim environments/production/config/networking.tfvars

# Plan changes
cd environments/production/
terraform plan -var-file=config/networking.tfvars

# Apply changes
terraform apply
```

### State Management

```bash
# View current state
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Remove resource from state (without destroying)
terraform state rm aws_instance.web
```

## 📊 Monitoring and Maintenance

### Generate Documentation

```bash
cd scripts/
./generate-docs.sh
```

### Validate All Configurations

```bash
cd scripts/
./validate-terraform.sh
```

### Cost Monitoring

```bash
# Use terraform cost estimation tools
terraform plan -var-file=config/project.tfvars | \\
  terraform-cost-estimation
```

### Security Scanning

```bash
# Install and run tfsec
brew install tfsec
tfsec .

# Install and run checkov
pip install checkov
checkov -d .
```

## 🔄 Disaster Recovery Testing

### 1. DR Environment Setup

```bash
# Deploy to DR environment
cd environments/disaster-recovery/

terraform plan -var-file=config/project.tfvars
terraform apply -var-file=config/project.tfvars
```

### 2. Data Replication Testing

```bash
# Test database replication
# Test file synchronization
# Test application failover
```

### 3. Recovery Procedures

```bash
# Document recovery steps
# Test recovery time objectives (RTO)
# Test recovery point objectives (RPO)
```

## 🐛 Troubleshooting

### Common Issues and Solutions

#### State Lock Issues

```bash
# Check for existing locks
terraform force-unlock LOCK_ID

# Alternative: wait for lock to expire (usually 15 minutes)
```

#### Provider Authentication Errors

```bash
# AWS
export AWS_PROFILE=production
aws sts get-caller-identity

# Azure
az account show
az login --tenant your-tenant-id

# GCP
gcloud auth application-default login
```

#### Module Not Found Errors

```bash
# Clear module cache and reinitialize
rm -rf .terraform/
terraform init
```

#### Version Conflicts

```bash
# Check Terraform version
terraform version

# Check provider versions
terraform providers

# Upgrade providers
terraform init -upgrade
```

### Debug Mode

```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run terraform command
terraform plan

# Review logs
cat terraform.log
```

### Resource Import Issues

```bash
# Find resource ID from cloud console
# Import with correct resource address
terraform import module.aws_infrastructure.aws_instance.web[0] i-1234567890abcdef0
```

## 📈 Scaling and Optimization

### Performance Optimization

```bash
# Use parallelism for faster operations
terraform apply -parallelism=10

# Use specific resource targeting
terraform apply -target=module.aws_infrastructure.aws_instance.web
```

### Cost Optimization

1. **Right-sizing**: Regularly review instance sizes
2. **Auto-scaling**: Enable auto-scaling groups
3. **Spot instances**: Use spot instances for non-critical workloads
4. **Resource cleanup**: Remove unused resources

### Security Hardening

1. **Least privilege**: Review and minimize IAM permissions
2. **Encryption**: Enable encryption at rest and in transit
3. **Network security**: Use private subnets and security groups
4. **Audit logging**: Enable comprehensive audit logging

## 🔄 Update Procedures

### Terraform Updates

```bash
# Update Terraform binary
# macOS
brew upgrade terraform

# Update providers
terraform init -upgrade

# Update modules
terraform get -update
```

### Configuration Updates

1. **Test changes** in test environment first
2. **Plan changes** before applying
3. **Apply during maintenance windows**
4. **Monitor** post-deployment

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Google Cloud Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

## 📞 Support

For additional support:

1. Review this documentation
2. Check troubleshooting section
3. Consult Terraform and cloud provider documentation
4. Contact your infrastructure team
5. Open an issue in the project repository
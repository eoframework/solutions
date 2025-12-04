# GitHub Actions Enterprise CI/CD - Automation

This directory contains automation for deploying and configuring GitHub Actions Enterprise CI/CD platform according to EO Framework standards.

## Overview

The automation is split into two main components:

1. **Terraform** - Infrastructure as Code for GitHub organization and repository configuration
2. **GitHub Actions Workflows** - Reusable CI/CD workflow templates

## Directory Structure

```
automation/
├── README.md                          # This file
├── terraform/
│   ├── modules/                       # Reusable Terraform modules
│   │   ├── github/                    # GitHub provider modules
│   │   │   ├── organization/          # Organization-level configuration
│   │   │   ├── repository/            # Repository configuration
│   │   │   ├── security/              # Advanced Security features
│   │   │   ├── actions/               # Actions configuration
│   │   │   ├── runners/               # Runner group management
│   │   │   └── environments/          # Environment configuration
│   │   └── solution/                  # Solution-specific compositions
│   └── environments/                  # Environment deployments
│       ├── prod/                      # Production environment
│       ├── test/                      # Test environment
│       └── dr/                        # Disaster recovery environment
├── github-actions/
│   ├── workflows/                     # Reusable workflow templates
│   │   ├── ci.yml                     # CI pipeline
│   │   ├── cd.yml                     # CD pipeline
│   │   └── reusable-build.yml         # Reusable build workflow
│   └── actions/                       # Custom actions
└── config/                            # Configuration files
```

## Prerequisites

### Required Tools

- [Terraform](https://www.terraform.io/downloads) >= 1.6.0
- [GitHub CLI](https://cli.github.com/) (`gh`)
- Git

### Required Permissions

- **GitHub Organization Owner** - Required for organization-level configuration
- **GitHub Personal Access Token** - With the following scopes:
  - `admin:org` - Full control of organizations
  - `repo` - Full control of repositories
  - `workflow` - Update GitHub Actions workflows
  - `read:org` - Read organization data
  - `write:org` - Write organization data

### AWS Credentials (for self-hosted runners)

- AWS account with permissions to:
  - Create VPC, EC2, Auto Scaling Groups
  - Create IAM roles and policies
  - Configure OIDC providers

## Quick Start

### 1. Configure GitHub Authentication

```bash
# Set GitHub token
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Or authenticate with GitHub CLI
gh auth login
```

### 2. Initialize Terraform Backend (First Time Only)

The Terraform state backend must be configured before deployment. This creates an S3 bucket and DynamoDB table for state locking.

```bash
cd terraform/setup/backend
./state-backend.sh prod  # For production
```

### 3. Configure Environment Variables

Copy the example configuration and update with your values:

```bash
cd terraform/environments/prod/config
cp project.tfvars.example project.tfvars

# Edit project.tfvars with your configuration
vi project.tfvars
```

### 4. Deploy GitHub Configuration

```bash
cd terraform/environments/prod

# Initialize Terraform with backend
terraform init -backend-config=backend.tfvars

# Review the plan
terraform plan -var-file=config/project.tfvars

# Apply the configuration
terraform apply -var-file=config/project.tfvars
```

## Configuration

### Terraform Modules

#### Organization Module

Configures organization-level GitHub Actions settings:

- Actions permissions and allowed actions
- Default workflow permissions
- Runner groups
- Organization secrets and variables

**Usage:**

```hcl
module "organization" {
  source = "../../modules/github/organization"

  organization = "my-org"

  allowed_actions      = "selected"
  enabled_repositories = "all"

  runner_groups = {
    production = {
      name                       = "production-runners"
      visibility                 = "selected"
      repository_ids             = [12345]
      allows_public_repositories = false
    }
  }
}
```

#### Repository Module

Configures repository-level settings:

- Repository creation and configuration
- Branch protection rules
- Deployment environments with reviewers
- Repository and environment secrets/variables

**Usage:**

```hcl
module "repository" {
  source = "../../modules/github/repository"

  repository_name   = ".github"
  create_repository = true
  visibility        = "public"

  enable_branch_protection = true
  protected_branch_pattern = "main"

  environments = {
    production = {
      reviewers = {
        teams = [123]
      }
      deployment_branch_policy = {
        protected_branches = true
      }
    }
  }
}
```

#### Security Module

Configures GitHub Advanced Security features:

- Code scanning (CodeQL)
- Secret scanning
- Dependabot alerts
- OIDC customization for AWS/Azure/GCP

**Usage:**

```hcl
module "security" {
  source = "../../modules/github/security"

  repository_name = "my-repo"

  enable_advanced_security                = true
  enable_secret_scanning                  = true
  enable_secret_scanning_push_protection  = true
  enable_oidc_customization               = true
}
```

### GitHub Actions Workflows

#### CI Pipeline (`ci.yml`)

Complete CI pipeline with:

- Code linting and formatting
- Security scanning (CodeQL, dependency check)
- Unit tests with matrix strategy
- Application build
- Container image build
- Slack notifications

**Usage:**

```yaml
name: CI
on: [push, pull_request]
jobs:
  ci:
    uses: ./.github/workflows/ci.yml
```

#### CD Pipeline (`cd.yml`)

Continuous deployment pipeline with:

- AWS OIDC authentication
- ECR image build and push
- EKS deployment with kubectl
- Smoke tests
- Deployment notifications

**Usage:**

```yaml
name: CD
on:
  push:
    branches: [main]
jobs:
  deploy:
    uses: ./.github/workflows/cd.yml
    with:
      environment: production
```

#### Reusable Build Workflow (`reusable-build.yml`)

Reusable workflow for building Node.js applications:

- Configurable Node.js version
- Dependency caching
- Lint, test, and build
- Artifact upload with configurable retention

**Usage:**

```yaml
jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      node-version: '20'
      upload-artifacts: true
      artifact-retention-days: 7
```

## Environment Configuration

### Production Environment

- **Full HA configuration** with multiple runners
- **Branch protection** with required reviewers
- **Environment protection rules** with manual approvals
- **Advanced Security** enabled
- **Complete monitoring** and alerting

### Test Environment

- **Minimal configuration** for cost optimization
- **Single runner** or small auto-scaling group
- **No branch protection** for faster iteration
- **Security scanning** enabled but no approval gates

### DR Environment

- **Standby configuration** in alternate region
- **Minimal active runners** (1-2 instances)
- **Full HA capacity available** via auto-scaling
- **Matches production configuration** but in standby mode

## Deployment Workflow

### Initial Deployment

1. **Backend Setup** - Create Terraform state backend
2. **Organization Config** - Deploy organization-level settings
3. **Repository Setup** - Create/configure .github repository
4. **Security Config** - Enable Advanced Security features
5. **Workflow Templates** - Deploy reusable workflows to .github repo

### Updates

```bash
cd terraform/environments/prod

# Pull latest changes
git pull

# Review changes
terraform plan -var-file=config/project.tfvars

# Apply updates
terraform apply -var-file=config/project.tfvars
```

### Rollback

```bash
# Revert to previous Terraform state
terraform apply -var-file=config/project.tfvars -target=module.organization
```

## Self-Hosted Runners

Self-hosted runners are deployed in AWS using separate Terraform configuration (not included in this GitHub provider automation).

**Runner Infrastructure:**

- AWS VPC with private subnets
- Auto Scaling Groups for Linux and Windows runners
- EC2 instances (c5.2xlarge for production)
- CloudWatch monitoring and auto-scaling policies

**Reference Documentation:**
- See `/mnt/c/projects/wsl/eof-tools/automation/docs/providers/github.md`
- AWS runner infrastructure in separate Terraform module

## Security Best Practices

### Secrets Management

- **Never commit secrets** to Git
- Use **GitHub Secrets** for sensitive values
- Use **OIDC authentication** for cloud providers (no static credentials)
- **Rotate secrets** quarterly
- Use **environment-specific secrets** for prod/test/dr

### Access Control

- **Limit organization owners** to 2-3 administrators
- Use **runner groups** to control repository access
- Implement **environment protection rules** for production
- Require **code reviews** and **signed commits**
- Enable **branch protection** on main/production branches

### Monitoring

- Enable **audit logging** for organization
- Configure **webhook notifications** for security events
- Monitor **runner health** and capacity
- Track **workflow execution metrics**
- Alert on **deployment failures**

## Troubleshooting

### Terraform Errors

**Error:** "Error: Invalid provider configuration"
```bash
# Ensure GitHub token is set
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"

# Re-initialize Terraform
terraform init -reconfigure
```

**Error:** "Error: Repository not found"
```bash
# Verify organization name
gh api /orgs/YOUR_ORG

# Check repository access
gh repo view YOUR_ORG/REPO
```

### GitHub Actions Errors

**Error:** "No runners available"
```bash
# Check runner status
gh api /orgs/YOUR_ORG/actions/runners

# Verify runner group configuration
gh api /orgs/YOUR_ORG/actions/runner-groups
```

**Error:** "OIDC authentication failed"
```bash
# Verify IAM role trust policy
aws iam get-role --role-name github-actions-deploy

# Check OIDC provider configuration
aws iam list-open-id-connect-providers
```

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Terraform Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [EO Framework Standards](/mnt/c/projects/wsl/eof-tools/automation/docs/TERRAFORM_STANDARDS.md)
- [GitHub Provider Guide](/mnt/c/projects/wsl/eof-tools/automation/docs/providers/github.md)

## Support

For issues or questions:

1. Check this README and troubleshooting section
2. Review EO Framework documentation
3. Contact DevOps team

---

**Last Updated:** December 2025
**Solution Version:** 1.0
**Maintained By:** EO Framework GitHub Solutions Team

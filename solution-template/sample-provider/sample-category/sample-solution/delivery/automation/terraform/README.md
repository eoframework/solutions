# Terraform Automation

Infrastructure as Code (IaC) for deploying and managing cloud resources using Terraform.

## Overview

This directory contains environment-specific Terraform configurations that share common modules. Each environment is self-contained with its own state, variables, and deployment script.

```
terraform/
├── README.md                 # This file
├── modules/                  # Reusable Terraform modules
│   └── ...
└── environments/
    ├── test/                 # Test environment
    ├── prod/                 # Production environment
    └── dr/                   # Disaster Recovery environment
```

## Prerequisites

### Required Tools

| Tool | Minimum Version | Purpose |
|------|-----------------|---------|
| Terraform | 1.5+ | Infrastructure provisioning |
| AWS CLI | 2.x | AWS authentication and operations |
| Bash | 4.x | Running eo-deploy.sh (Linux/macOS/WSL) |
| PowerShell | 5.1+ | Running eo-deploy.bat (Windows) |

### AWS Authentication

Configure AWS credentials before running any Terraform commands:

```bash
# Option 1: AWS CLI profile
export AWS_PROFILE=your-profile-name

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"

# Option 3: IAM role (recommended for CI/CD)
# Automatically uses instance/task role
```

## Environment Structure

Each environment follows a consistent structure:

```
environments/<env>/
├── README.md           # Environment-specific documentation
├── eo-deploy.sh        # EO Framework deployment script (Linux/macOS/WSL)
├── eo-deploy.bat       # EO Framework deployment script (Windows)
├── main.tf             # Main Terraform configuration
├── variables.tf        # Variable definitions
├── outputs.tf          # Output definitions
├── providers.tf        # Provider configuration
├── backend.tf          # State backend configuration
└── config/             # Configuration files (tfvars)
    ├── application.tfvars    # Application settings
    ├── best-practices.tfvars # Governance and compliance
    ├── cache.tfvars          # Cache configuration
    └── ...
```

## Configuration Files

Configuration is split into modular `.tfvars` files in the `config/` directory:

| File | Purpose |
|------|---------|
| `application.tfvars` | Application identity, logging, endpoints, security |
| `best-practices.tfvars` | Governance, compliance, cost optimization |
| `cache.tfvars` | ElastiCache/Redis configuration |
| `compute.tfvars` | EC2, ECS, Lambda settings |
| `database.tfvars` | RDS, DynamoDB configuration |
| `network.tfvars` | VPC, subnets, security groups |
| `security.tfvars` | IAM, KMS, secrets management |

Files are loaded alphabetically, so later files can override earlier values.

## Quick Start

1. **Navigate to the target environment:**
   ```bash
   cd environments/test   # or prod, dr
   ```

2. **Initialize Terraform:**
   ```bash
   # Linux/macOS/WSL
   ./eo-deploy.sh init

   # Windows
   eo-deploy.bat init
   ```

3. **Review the execution plan:**
   ```bash
   # Linux/macOS/WSL
   ./eo-deploy.sh plan

   # Windows
   eo-deploy.bat plan
   ```

4. **Apply the configuration:**
   ```bash
   # Linux/macOS/WSL
   ./eo-deploy.sh apply

   # Windows
   eo-deploy.bat apply
   ```

## The eo-deploy Script

`eo-deploy.sh` (Linux/macOS/WSL) and `eo-deploy.bat` (Windows) are EO Framework wrappers around Terraform that:

- Automatically load all `config/*.tfvars` files
- Provide colored output for better visibility
- Show which configuration files are being used
- Pass through all Terraform arguments

### Available Commands

| Command | Description |
|---------|-------------|
| `init` | Initialize Terraform working directory |
| `plan` | Create an execution plan |
| `apply` | Apply the Terraform configuration |
| `destroy` | Destroy all managed infrastructure |
| `validate` | Validate configuration syntax |
| `fmt` | Format configuration files |
| `output` | Show output values |
| `show` | Show current state |
| `state` | Advanced state management |
| `refresh` | Update state to match remote |
| `version` | Show Terraform version |

### Passing Additional Arguments

All arguments after the command are passed to Terraform:

```bash
# Auto-approve apply
./eo-deploy.sh apply -auto-approve

# Target specific resource
./eo-deploy.sh plan -target=aws_instance.web

# Destroy specific resource
./eo-deploy.sh destroy -target=aws_s3_bucket.logs
```

## Environment Comparison

| Aspect | Test | Prod | DR |
|--------|------|------|-----|
| Instance sizes | Minimal | Production-grade | Matches Prod |
| High availability | Disabled | Enabled | Enabled |
| Backups | Minimal | Full retention | Cross-region |
| Monitoring | Basic | Comprehensive | Comprehensive |
| Cost optimization | Maximum | Balanced | Balanced |

## Best Practices

1. **Always run `plan` before `apply`** - Review changes before applying
2. **Use version control** - Commit configuration changes before applying
3. **Environment isolation** - Each environment has separate state
4. **Least privilege** - Use minimal IAM permissions
5. **State locking** - Enable DynamoDB state locking for team environments

## Troubleshooting

### Common Issues

**State lock error:**
```bash
# If a previous run was interrupted
terraform force-unlock <lock-id>
```

**Provider authentication:**
```bash
# Verify AWS credentials
aws sts get-caller-identity
```

**Module not found:**
```bash
# Re-initialize to download modules
./eo-deploy.sh init -upgrade
```

## Related Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Environment-specific READMEs in each environment directory

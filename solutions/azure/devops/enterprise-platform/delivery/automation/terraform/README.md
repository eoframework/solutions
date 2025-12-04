# Azure DevOps Enterprise Platform - Terraform Automation

This directory contains Terraform infrastructure-as-code for deploying the Azure DevOps Enterprise Platform solution across multiple environments (Production, Test, DR).

## Solution Overview

Enterprise DevOps platform with:
- **Azure DevOps**: Organization, projects, repos, pipelines, artifacts
- **Service Connections**: Azure Resource Manager connectivity
- **App Service**: Deployment targets for applications
- **Key Vault**: Secrets management
- **Monitoring**: Application Insights, Log Analytics, alerts
- **Networking**: VNet integration, private endpoints
- **Disaster Recovery**: Cross-region replication

## Directory Structure

```
terraform/
├── configuration.csv              # Master configuration with Prod/Test/DR columns
├── environments/
│   ├── prod/                      # Production environment
│   │   ├── main.tf               # Main infrastructure definition
│   │   ├── variables.tf          # Variable declarations
│   │   ├── providers.tf          # Provider configuration
│   │   ├── outputs.tf            # Output values
│   │   └── config/               # Environment-specific configurations
│   │       ├── project.tfvars
│   │       ├── networking.tfvars
│   │       ├── security.tfvars
│   │       ├── devops.tfvars
│   │       ├── compute.tfvars
│   │       ├── application.tfvars
│   │       ├── monitoring.tfvars
│   │       ├── best-practices.tfvars
│   │       └── dr.tfvars
│   ├── test/                      # Test environment (same structure)
│   └── dr/                        # Disaster Recovery environment (same structure)
├── modules/
│   ├── solution/                  # Solution-level modules
│   │   ├── core/                 # Resource Group, VNet, Key Vault
│   │   ├── devops/               # Azure DevOps project, pipelines
│   │   ├── compute/              # App Service, autoscaling
│   │   ├── monitoring/           # Application Insights, alerts
│   │   ├── security/             # Managed identity, RBAC
│   │   ├── best-practices/       # Backup, budgets, policies
│   │   └── dr/                   # Disaster recovery resources
│   └── azure/                     # Azure resource modules (if needed)
└── setup/
    └── backend/                   # Terraform state backend setup
        ├── README.md
        └── state-backend.sh       # Script to create state storage

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.6.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) >= 2.40.0
- Azure subscription with Contributor role
- Azure DevOps organization
- Service Principal for Azure DevOps service connections

## Environment Setup

### 1. Configure Azure Authentication

```bash
az login
az account set --subscription "[SUBSCRIPTION_ID]"
```

### 2. Set Azure DevOps Personal Access Token

```bash
export AZDO_PERSONAL_ACCESS_TOKEN="your-pat-token"
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/[ORGANIZATION_NAME]"
```

### 3. Update Configuration Files

Edit the configuration files in `environments/[env]/config/`:

- `project.tfvars`: Update subscription ID, tenant ID, ownership
- `devops.tfvars`: Update Azure DevOps organization, service principal
- `security.tfvars`: Update Azure AD group IDs
- Other files: Adjust as needed for your environment

### 4. Create Terraform State Backend

```bash
cd setup/backend
./state-backend.sh prod
./state-backend.sh test
./state-backend.sh dr
```

This creates:
- Storage account for Terraform state
- Backend configuration file: `environments/[env]/backend.tfvars`

## Deployment

### Production Environment

```bash
cd environments/prod

# Initialize Terraform
terraform init -backend-config=backend.tfvars

# Review the plan
terraform plan \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/devops.tfvars \
  -var-file=config/compute.tfvars \
  -var-file=config/application.tfvars \
  -var-file=config/monitoring.tfvars \
  -var-file=config/best-practices.tfvars \
  -var-file=config/dr.tfvars

# Apply the configuration
terraform apply \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  -var-file=config/security.tfvars \
  -var-file=config/devops.tfvars \
  -var-file=config/compute.tfvars \
  -var-file=config/application.tfvars \
  -var-file=config/monitoring.tfvars \
  -var-file=config/best-practices.tfvars \
  -var-file=config/dr.tfvars
```

### Test Environment

```bash
cd environments/test
terraform init -backend-config=backend.tfvars
terraform plan -var-file=config/*.tfvars
terraform apply -var-file=config/*.tfvars
```

### DR Environment

```bash
cd environments/dr
terraform init -backend-config=backend.tfvars
terraform plan -var-file=config/*.tfvars
terraform apply -var-file=config/*.tfvars
```

## Module Dependencies

The deployment follows this dependency order:
1. **Foundation**: Core infrastructure (VNet, Key Vault)
2. **Security**: Managed identities, RBAC
3. **Core Solution**: Azure DevOps, App Service
4. **Operations**: Monitoring, best practices, DR

## Outputs

After deployment, Terraform outputs key information:

```bash
terraform output

# Get specific output
terraform output devops_project_url
terraform output app_service_url
terraform output key_vault_name
```

## Configuration Reference

### Key Configuration Files

| File | Purpose |
|------|---------|
| `project.tfvars` | Solution identity, Azure subscription, ownership |
| `networking.tfvars` | VNet CIDR, subnet configuration |
| `security.tfvars` | Private endpoints, encryption, RBAC groups |
| `devops.tfvars` | Azure DevOps organization, projects, pipelines |
| `compute.tfvars` | App Service SKU, autoscaling settings |
| `application.tfvars` | Runtime configuration, log levels |
| `monitoring.tfvars` | Alerts, log retention, dashboards |
| `best-practices.tfvars` | Backup, budgets, Azure policies |
| `dr.tfvars` | Disaster recovery settings |

## Environment Differences

| Configuration | Production | Test | DR |
|---------------|-----------|------|-----|
| App Service SKU | P1v3 | B1 | P1v3 |
| Autoscale | 2-10 instances | 1-2 instances | 2-10 instances |
| Private Endpoints | Enabled | Disabled | Enabled |
| Monitoring Alerts | Enabled | Disabled | Enabled |
| DR Replication | Enabled | Disabled | N/A |
| Budget | $5,000/month | $1,000/month | $2,500/month |

## Validation

Validate configuration without applying:

```bash
cd environments/prod
terraform init -backend=false
terraform validate
```

## Troubleshooting

### Common Issues

1. **Provider authentication errors**
   - Ensure `az login` is executed
   - Verify service principal credentials
   - Check Azure DevOps PAT token

2. **State backend errors**
   - Run `setup/backend/state-backend.sh [env]` first
   - Verify backend.tfvars exists

3. **Resource naming conflicts**
   - Solution abbreviation must be unique
   - Storage accounts require globally unique names

### Debugging

Enable detailed logging:

```bash
export TF_LOG=DEBUG
terraform plan
```

## Clean Up

To destroy infrastructure:

```bash
cd environments/[env]
terraform destroy \
  -var-file=config/project.tfvars \
  -var-file=config/networking.tfvars \
  # ... (include all var files)
```

**Warning**: This will delete all resources in the environment.

## Security Best Practices

- Store sensitive values in Azure Key Vault
- Use Azure AD groups for RBAC
- Enable private endpoints in production
- Use customer-managed encryption keys
- Regular security policy compliance checks
- Implement network isolation

## Support

For issues or questions:
- Review `configuration.csv` for parameter reference
- Check module README files
- Contact DevOps team: devops-team@company.com

## Version History

- **1.0.0** - Initial Terraform automation structure
  - Production, Test, DR environments
  - Azure DevOps integration
  - App Service deployment
  - Monitoring and DR support

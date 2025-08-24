# Google Cloud Landing Zone Deployment Scripts

This directory contains automation scripts for deploying and managing the Google Cloud Landing Zone infrastructure. Multiple script formats are provided to support different automation preferences and environments.

## Available Scripts

### Terraform Infrastructure
- **`terraform/`** - Infrastructure as Code definitions using Terraform
  - `main.tf` - Main infrastructure resources
  - `variables.tf` - Input variable definitions
  - `outputs.tf` - Output value definitions
  - `terraform.tfvars.example` - Example configuration file

### Deployment Automation
- **`powershell/Deploy-Solution.ps1`** - PowerShell deployment script for Windows environments
- **`python/deploy.py`** - Python deployment script with comprehensive error handling
- **`bash/deploy.sh`** - Bash deployment script for Unix/Linux environments
- **`ansible/playbook.yml`** - Ansible playbook for configuration management

## Prerequisites

### Common Requirements
- Google Cloud SDK (gcloud) installed and configured
- Terraform >= 1.5.0 installed
- Active Google Cloud account with appropriate permissions
- Organization Admin or equivalent roles

### Script-Specific Requirements

#### PowerShell Script
- PowerShell 5.1 or PowerShell Core 6.0+
- Windows PowerShell or PowerShell Core on Linux/macOS

#### Python Script
- Python 3.8 or higher
- Required packages: `pip install -r python/requirements.txt`

#### Bash Script
- Bash 4.0 or higher
- Common Unix utilities (jq, curl, etc.)

#### Ansible Playbook
- Ansible 2.9 or higher
- Google Cloud Ansible collection

## Authentication

All scripts require Google Cloud authentication. Authenticate using:
```bash
gcloud auth login
gcloud auth application-default login
```

## Usage Examples

### PowerShell Deployment
```powershell
.\powershell\Deploy-Solution.ps1 `
    -ProjectId "my-landing-zone" `
    -OrganizationId "123456789012" `
    -BillingAccountId "ABCDEF-012345" `
    -Region "us-central1"
```

### Python Deployment
```bash
python python/deploy.py \
    --project-id "my-landing-zone" \
    --organization-id "123456789012" \
    --billing-account "ABCDEF-012345" \
    --region "us-central1"
```

### Bash Deployment
```bash
./bash/deploy.sh \
    --project-id "my-landing-zone" \
    --organization-id "123456789012" \
    --billing-account "ABCDEF-012345" \
    --region "us-central1"
```

### Ansible Deployment
```bash
ansible-playbook ansible/playbook.yml \
    -e project_id="my-landing-zone" \
    -e organization_id="123456789012" \
    -e billing_account_id="ABCDEF-012345" \
    -e region="us-central1"
```

## Configuration

### Terraform Variables
Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and customize:

```hcl
project_id         = "my-landing-zone-project"
organization_id    = "123456789012"
billing_account_id = "ABCDEF-012345-GHIJKL"
region            = "us-central1"
environment       = "prod"

# Network configuration
internal_ip_range = "10.0.0.0/8"

hub_subnets = {
  hub-central = {
    cidr   = "10.0.1.0/24"
    region = "us-central1"
  }
}
```

### Environment-Specific Configurations
- **Development**: Use smaller instance types and single-region deployment
- **Staging**: Mirror production with reduced capacity
- **Production**: Full redundancy with multi-region deployment

## Deployment Modes

### Plan-Only Mode
Review changes without applying them:
```bash
# Python
python deploy.py --plan-only --project-id "my-project" ...

# Bash
./deploy.sh --plan-only --project-id "my-project" ...

# PowerShell
.\Deploy-Solution.ps1 -PlanOnly -ProjectId "my-project" ...
```

### Auto-Approve Mode
Deploy without interactive confirmation:
```bash
# Python
python deploy.py --auto-approve --project-id "my-project" ...

# Bash
./deploy.sh --auto-approve --project-id "my-project" ...

# PowerShell
.\Deploy-Solution.ps1 -AutoApprove -ProjectId "my-project" ...
```

### Destroy Mode
Remove all infrastructure:
```bash
# Bash
./deploy.sh --destroy --project-id "my-project" ...

# PowerShell
.\Deploy-Solution.ps1 -Destroy -ProjectId "my-project" ...
```

## Logging and Monitoring

All scripts generate detailed logs:
- **PowerShell**: `deployment-YYYYMMDD-HHMMSS.log`
- **Python**: `deployment_YYYYMMDD_HHMMSS.log`
- **Bash**: `deployment_YYYYMMDD_HHMMSS.log`
- **Ansible**: `logs/ansible-deployment-TIMESTAMP.log`

Deployment reports are generated in JSON format with:
- Deployment metadata
- Resource inventory
- Validation results
- Terraform outputs

## Error Handling

### Common Issues

#### Authentication Errors
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login
```

#### Permission Errors
Ensure your account has the following roles:
- `roles/resourcemanager.organizationAdmin`
- `roles/billing.admin`
- `roles/compute.admin`
- `roles/iam.admin`

#### Quota Limitations
Check and request quota increases:
```bash
gcloud compute project-info describe --project=PROJECT_ID
```

#### API Enablement Issues
Some APIs may take time to propagate. Wait 5-10 minutes and retry.

### Troubleshooting Steps

1. **Check Prerequisites**: Verify all tools are installed and accessible
2. **Validate Authentication**: Ensure proper Google Cloud authentication
3. **Review Configuration**: Check terraform.tfvars for syntax and values
4. **Check Logs**: Review detailed logs for specific error messages
5. **Verify Permissions**: Ensure account has required roles and permissions

## Security Considerations

### Sensitive Data
- Store sensitive values in Google Secret Manager
- Use service accounts with minimal required permissions
- Never commit secrets or keys to version control

### Network Security
- Default configurations implement least-privilege access
- Firewall rules follow defense-in-depth principles
- VPC networks use private IP ranges

### Compliance
- Organization policies enforce security standards
- All resources include compliance labeling
- Audit logging captures all administrative actions

## Customization

### Adding Custom Resources
1. Modify `terraform/main.tf` to include additional resources
2. Update `terraform/variables.tf` for new configuration options
3. Adjust deployment scripts if new parameters are needed

### Modifying Network Architecture
1. Update subnet definitions in `terraform.tfvars`
2. Modify VPC peering configurations in `main.tf`
3. Adjust firewall rules for new network segments

### Integrating Additional Services
1. Add new Google Cloud APIs to required_apis lists
2. Include service-specific Terraform resources
3. Update validation scripts to check new services

## Support and Maintenance

### Regular Updates
- Review and update Terraform provider versions quarterly
- Monitor Google Cloud API changes and deprecations
- Update documentation with new features and changes

### Backup and Recovery
- Terraform state is stored in Google Cloud Storage with versioning
- All scripts generate deployment reports for audit trails
- Infrastructure snapshots can be created for disaster recovery

### Performance Optimization
- Monitor resource utilization and right-size instances
- Implement auto-scaling where appropriate
- Review and optimize network routing and peering

---

For additional help and troubleshooting, see the [troubleshooting guide](../docs/troubleshooting.md) and [operations runbook](../operations-runbook.md).
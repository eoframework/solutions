# Microsoft CMMC Enclave - Automation Scripts

This directory contains comprehensive automation scripts for deploying, configuring, and managing the Microsoft CMMC Enclave solution. Scripts are organized by technology and deployment method to support various operational scenarios and preferences.

## Directory Structure

### [Terraform](terraform/)
Infrastructure as Code (IaC) for Azure Government deployment:
- **main.tf**: Complete infrastructure deployment with CMMC compliance integration
- **variables.tf**: Configurable parameters for customization
- **outputs.tf**: Resource references and connection information
- **terraform.tfvars.example**: Sample configuration values
- **cmmc-compliance-framework.yml**: CMMC Level 2 control mappings and deployment configuration

**Configuration Refactoring**: The CMMC compliance framework configuration has been refactored from the unauthorized `configs/` directory into the proper `scripts/terraform/` location. This ensures seamless deployment while maintaining compliance standards.

### [PowerShell](powershell/)
Windows-based automation and configuration scripts:
- Azure Government service configuration
- Microsoft 365 Government setup
- Active Directory integration
- Compliance policy deployment

### [Python](python/)
Data processing and API automation:
- Microsoft Purview configuration
- Data classification automation
- Compliance reporting
- Integration with third-party systems

### [Bash](bash/)
Linux-based deployment and management scripts:
- Container orchestration
- Linux virtual machine configuration
- Network configuration automation
- Backup and monitoring setup

### [Ansible](ansible/)
Configuration management and orchestration:
- Multi-service deployment coordination
- Configuration drift management
- Automated remediation playbooks
- Compliance validation automation

## Deployment Scenarios

### Scenario 1: Greenfield Deployment
**Use Case**: New CMMC environment from scratch
**Primary Tools**: Terraform + PowerShell
**Duration**: 4-6 weeks
**Scripts**:
1. `terraform/main.tf` - Infrastructure foundation
2. `powershell/Deploy-Solution.ps1` - Service configuration
3. `python/configure-purview.py` - Data classification setup
4. `ansible/validate-compliance.yml` - Compliance verification

### Scenario 2: Hybrid Integration
**Use Case**: Extending existing on-premises environment
**Primary Tools**: PowerShell + Python
**Duration**: 6-8 weeks
**Scripts**:
1. `powershell/Connect-OnPremises.ps1` - Hybrid connectivity
2. `terraform/hybrid-networking.tf` - Network integration
3. `python/migrate-data.py` - Data migration automation
4. `bash/configure-monitoring.sh` - Hybrid monitoring setup

### Scenario 3: Migration from Commercial Cloud
**Use Case**: Moving from Azure Commercial to Azure Government
**Primary Tools**: Python + Bash
**Duration**: 8-10 weeks
**Scripts**:
1. `python/assess-migration.py` - Migration assessment
2. `bash/export-configurations.sh` - Configuration backup
3. `terraform/migrate-infrastructure.tf` - Government cloud deployment
4. `powershell/Update-Services.ps1` - Service reconfiguration

## Script Categories

### Infrastructure Deployment
- **Cloud Resources**: Virtual machines, storage, networking
- **Security Services**: Key Vault, Security Center, Sentinel
- **Identity Services**: Azure AD configuration and policies
- **Monitoring**: Log Analytics, Application Insights

### Configuration Management
- **Compliance Policies**: CMMC control implementation
- **Security Baselines**: Hardening and configuration standards
- **Access Controls**: RBAC, Conditional Access, PIM
- **Data Protection**: Encryption, labeling, DLP policies

### Data Operations
- **Classification**: Automated data discovery and labeling
- **Migration**: Secure data transfer procedures
- **Backup**: Comprehensive backup and retention policies
- **Archival**: Long-term data retention and compliance

### Monitoring and Compliance
- **Health Checks**: System status and performance monitoring
- **Compliance Validation**: Automated control verification
- **Reporting**: Compliance dashboards and audit reports
- **Alerting**: Security incident detection and notification

## Prerequisites

### General Requirements
- **Azure Government Subscription**: Active subscription with appropriate quotas
- **Administrative Privileges**: Global Administrator in Azure AD
- **Network Connectivity**: Secure connection to Azure Government regions
- **Development Environment**: Local workstation with required tools

### Tool-Specific Requirements

#### Terraform
- Terraform >= 1.0
- Azure CLI >= 2.30
- Azure Government environment configuration
- Service principal with appropriate permissions

#### PowerShell
- PowerShell 7+ or Windows PowerShell 5.1
- Azure PowerShell module >= 6.0
- Microsoft Graph PowerShell SDK
- Exchange Online Management module

#### Python
- Python >= 3.8
- Azure SDK for Python
- Microsoft Graph SDK
- Required pip packages (see requirements.txt)

#### Bash
- Bash shell (Linux/macOS/WSL)
- Azure CLI >= 2.30
- jq for JSON processing
- curl and wget for API calls

#### Ansible
- Ansible >= 2.10
- Azure collection for Ansible
- Python Azure SDK
- SSH access to target systems

## Security Considerations

### Authentication
All scripts use secure authentication methods:
- **Service Principals**: For automated deployments
- **Managed Identity**: For Azure-hosted automation
- **Certificate-based Auth**: For high-security scenarios
- **Multi-Factor Authentication**: For interactive sessions

### Secrets Management
- **Azure Key Vault**: Centralized secret storage
- **Environment Variables**: Temporary credential storage
- **Credential Files**: Encrypted local storage
- **No Hard-coded Secrets**: Zero secrets in source code

### Audit and Logging
- **Execution Logging**: All script activities logged
- **Change Tracking**: Configuration change documentation
- **Access Auditing**: User and service account monitoring
- **Compliance Reporting**: Automated evidence collection

## Usage Guidelines

### Development Environment Setup

#### Initial Setup
```bash
# Clone repository
git clone <repository-url>
cd microsoft-cmmc-enclave

# Set up Python environment
python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows
pip install -r scripts/python/requirements.txt

# Install PowerShell modules
Install-Module -Name Az -Repository PSGallery -Force
Install-Module -Name Microsoft.Graph -Repository PSGallery -Force

# Initialize Terraform
cd scripts/terraform
terraform init
```

#### Environment Configuration
```bash
# Set Azure Government environment
az cloud set --name AzureUSGovernment
az login

# Configure Terraform for Azure Government
export ARM_ENVIRONMENT="usgovernment"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

### Execution Workflows

#### Standard Deployment Workflow
1. **Pre-deployment Validation**
   ```bash
   # Validate prerequisites
   ./scripts/bash/validate-prerequisites.sh
   
   # Test connectivity
   ./scripts/bash/test-connectivity.sh
   ```

2. **Infrastructure Deployment**
   ```bash
   # Deploy base infrastructure
   cd scripts/terraform
   terraform plan -var-file="production.tfvars"
   terraform apply -var-file="production.tfvars"
   ```

3. **Service Configuration**
   ```powershell
   # Configure Microsoft 365 services
   .\scripts\powershell\Deploy-M365Services.ps1 -Environment Production
   
   # Set up Azure services
   .\scripts\powershell\Deploy-AzureServices.ps1 -ResourceGroup "cmmc-prod-rg"
   ```

4. **Data Protection Setup**
   ```python
   # Configure Microsoft Purview
   python scripts/python/configure-purview.py --environment production
   
   # Set up data classification
   python scripts/python/setup-data-classification.py --config config/production.json
   ```

5. **Compliance Validation**
   ```bash
   # Run compliance checks
   ansible-playbook scripts/ansible/validate-compliance.yml -i inventory/production
   
   # Generate compliance report
   python scripts/python/generate-compliance-report.py --output reports/
   ```

### Error Handling and Troubleshooting

#### Common Issues
1. **Authentication Failures**
   - Verify service principal permissions
   - Check Azure Government environment configuration
   - Validate Multi-Factor Authentication setup

2. **Network Connectivity**
   - Confirm Azure Government region access
   - Validate firewall and proxy configurations
   - Test DNS resolution for Azure Government endpoints

3. **Resource Quotas**
   - Check subscription limits and quotas
   - Request quota increases if needed
   - Optimize resource sizing and distribution

4. **Permission Issues**
   - Verify RBAC assignments
   - Check Azure AD role assignments
   - Validate service principal permissions

#### Troubleshooting Scripts
```bash
# Network diagnostics
./scripts/bash/diagnose-network.sh

# Permission validation
./scripts/bash/check-permissions.sh

# Service health check
python scripts/python/health-check.py --comprehensive
```

## Customization and Extension

### Script Customization
All scripts are designed for customization through:
- **Configuration Files**: JSON/YAML parameter files
- **Environment Variables**: Runtime configuration
- **Command-line Arguments**: Execution-time parameters
- **Template Overlays**: Organization-specific modifications

### Adding Custom Scripts
1. **Follow Naming Conventions**: Use descriptive, consistent names
2. **Include Documentation**: Header comments and README updates
3. **Implement Error Handling**: Comprehensive error management
4. **Add Logging**: Detailed execution logging
5. **Include Validation**: Input and output validation

### Integration Points
Scripts are designed to integrate with:
- **CI/CD Pipelines**: Azure DevOps, GitHub Actions
- **Configuration Management**: Ansible, Chef, Puppet
- **Monitoring Systems**: Azure Monitor, Splunk, Datadog
- **Ticketing Systems**: ServiceNow, Jira, Azure DevOps

## Support and Maintenance

### Version Management
- **Semantic Versioning**: Major.Minor.Patch versioning scheme
- **Change Documentation**: Comprehensive changelog maintenance
- **Backward Compatibility**: Maintained across minor versions
- **Deprecation Notices**: Advanced warning for breaking changes

### Testing and Validation
- **Unit Tests**: Individual script component testing
- **Integration Tests**: End-to-end workflow validation
- **Compliance Tests**: CMMC control verification
- **Performance Tests**: Script execution optimization

### Documentation Updates
- **Script Headers**: Embedded documentation and examples
- **README Files**: Comprehensive usage instructions
- **Change Logs**: Version-specific modification tracking
- **Best Practices**: Operational guidance and recommendations

For detailed implementation instructions, refer to the specific technology directories and the [Implementation Guide](../implementation-guide.md).
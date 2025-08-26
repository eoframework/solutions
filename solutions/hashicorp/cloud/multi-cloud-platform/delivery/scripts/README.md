# HashiCorp Multi-Cloud Platform - Deployment Scripts

This directory contains scripts and automation tools for deploying and managing the HashiCorp Multi-Cloud Infrastructure Management Platform across AWS, Azure, and Google Cloud Platform.

## Directory Structure

```
scripts/
├── README.md                     # This file
├── terraform/                    # Terraform configurations
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   └── terraform.tfvars.example # Example variables file
├── ansible/                     # Ansible playbooks and roles
│   ├── playbook.yml            # Main deployment playbook
│   ├── inventory.yml           # Dynamic inventory configuration
│   ├── group_vars/             # Group variable files
│   └── roles/                  # Custom Ansible roles
├── bash/                       # Shell scripts
│   ├── deploy.sh              # Main deployment script
│   ├── health-check.sh        # Health monitoring script
│   ├── backup.sh              # Backup automation
│   └── cleanup.sh             # Resource cleanup
├── powershell/                 # PowerShell scripts for Windows
│   ├── Deploy-Solution.ps1    # Main deployment script
│   ├── Test-Connectivity.ps1  # Network connectivity tests
│   └── Backup-Data.ps1        # Backup automation
└── python/                     # Python automation scripts
    ├── deploy.py              # Python deployment script
    ├── monitor.py             # Monitoring and alerting
    ├── backup.py              # Backup management
    ├── requirements.txt       # Python dependencies
    └── config/                # Configuration files
```

## Prerequisites

### Required Tools
- **Terraform** >= 1.5.0
- **Ansible** >= 2.12.0
- **Python** >= 3.8
- **kubectl** >= 1.24.0
- **Cloud CLIs**: AWS CLI, Azure CLI, Google Cloud SDK
- **HashiCorp Tools**: Consul CLI, Vault CLI, Nomad CLI, Boundary CLI

### Authentication Setup
Ensure you have proper authentication configured for all cloud providers:

```bash
# AWS Authentication
aws configure
export AWS_PROFILE=your-profile

# Azure Authentication  
az login
az account set --subscription "your-subscription-id"

# Google Cloud Authentication
gcloud auth login
gcloud config set project your-project-id
```

### Licensing
Ensure you have valid HashiCorp Enterprise licenses:
- Terraform Enterprise license
- Consul Enterprise license
- Vault Enterprise license
- Nomad Enterprise license
- Boundary Enterprise license

## Quick Start

### 1. Configuration Setup
```bash
# Copy and customize the Terraform variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit the variables file with your specific configuration
vim terraform/terraform.tfvars
```

### 2. Deploy with Terraform
```bash
# Initialize Terraform
cd terraform
terraform init

# Plan the deployment
terraform plan -var-file="terraform.tfvars"

# Apply the configuration
terraform apply -var-file="terraform.tfvars"
```

### 3. Configure with Ansible
```bash
# Run the Ansible playbook
cd ../ansible
ansible-playbook -i inventory.yml playbook.yml
```

### 4. Verify Deployment
```bash
# Run health checks
cd ../bash
./health-check.sh

# Or use Python script
cd ../python
python monitor.py --check-health
```

## Script Descriptions

### Terraform Scripts

#### main.tf
- Core infrastructure deployment across AWS, Azure, and GCP
- HashiCorp product cluster configurations
- Cross-cloud networking setup
- Security and monitoring components

#### variables.tf
- Comprehensive variable definitions for all components
- Cloud provider specific configurations
- HashiCorp product settings
- Network and security parameters

#### outputs.tf
- Service endpoints and connection information
- Cluster status and health metrics
- Cross-cloud networking details
- Security and compliance outputs

### Ansible Scripts

#### playbook.yml
```yaml
# Main deployment playbook structure
- name: Deploy HashiCorp Multi-Cloud Platform
  hosts: all
  roles:
    - common
    - consul
    - vault
    - nomad
    - boundary
    - monitoring
    - security
```

#### Key Roles
- **consul**: Consul Enterprise cluster setup and federation
- **vault**: Vault Enterprise deployment with auto-unseal
- **nomad**: Nomad Enterprise federation configuration
- **boundary**: Boundary Enterprise multi-cloud setup
- **monitoring**: Prometheus, Grafana, ELK stack deployment
- **security**: Security policies and compliance configuration

### Bash Scripts

#### deploy.sh
Main deployment orchestration script that:
- Validates prerequisites
- Deploys infrastructure with Terraform
- Configures services with Ansible
- Runs health checks and validation
- Generates deployment report

```bash
#!/bin/bash
# Usage: ./deploy.sh [environment] [--dry-run]
./deploy.sh production --dry-run
```

#### health-check.sh
Comprehensive health monitoring that checks:
- HashiCorp service status across all clouds
- Cross-cloud connectivity
- Certificate expiration
- Resource utilization
- Backup verification

#### backup.sh
Automated backup script for:
- Consul snapshots across all datacenters
- Vault snapshots with encryption
- Nomad state backups
- Database backups for Boundary
- Cross-region backup replication

### PowerShell Scripts

#### Deploy-Solution.ps1
PowerShell equivalent of the bash deployment script for Windows environments:
- Azure-focused deployment options
- Active Directory integration
- Windows-specific configurations
- PowerShell DSC support

#### Test-Connectivity.ps1
Network connectivity testing:
- Cross-cloud VPN tunnel status
- Service endpoint accessibility
- DNS resolution testing
- Port connectivity verification

### Python Scripts

#### deploy.py
Advanced Python deployment script with:
- Interactive deployment wizard
- Progress tracking and logging
- Error handling and rollback
- Integration with cloud provider APIs
- Slack/Teams notifications

```python
# Usage examples
python deploy.py --interactive
python deploy.py --config config/production.yaml
python deploy.py --validate-only
```

#### monitor.py
Comprehensive monitoring solution:
- Real-time health monitoring
- Alerting integration
- Performance metrics collection
- Compliance reporting
- Automated remediation

#### backup.py
Advanced backup management:
- Scheduled backup orchestration
- Cross-cloud backup synchronization
- Backup integrity verification
- Retention policy enforcement
- Disaster recovery testing

## Environment Configuration

### Development Environment
```bash
# Deploy minimal setup for development
export ENVIRONMENT=development
export CLUSTER_SIZE=1
./deploy.sh development
```

### Staging Environment
```bash
# Deploy staging environment for testing
export ENVIRONMENT=staging
export ENABLE_MONITORING=true
./deploy.sh staging
```

### Production Environment
```bash
# Deploy full production environment
export ENVIRONMENT=production
export HIGH_AVAILABILITY=true
export CROSS_CLOUD_REPLICATION=true
./deploy.sh production
```

## Configuration Management

### Terraform Variables
Key configuration options in `terraform.tfvars`:

```hcl
# Project Configuration
project_name = "hashicorp-multicloud"
environment  = "production"

# Cloud Provider Configuration
aws_regions = {
  primary   = "us-west-2"
  secondary = "us-east-1"
}
azure_regions = {
  primary   = "West US 2"
  secondary = "East US"
}
gcp_regions = {
  primary   = "us-west1"
  secondary = "us-east1"
}

# HashiCorp Products
enable_consul   = true
enable_vault    = true
enable_nomad    = true
enable_boundary = true

# Network Configuration
enable_cross_cloud_vpn = true
enable_service_mesh    = true

# Security Configuration
enable_audit_logging = true
enable_policy_as_code = true
```

### Ansible Variables
Configuration in `group_vars/all.yml`:

```yaml
# HashiCorp Product Versions
consul_version: "1.17.0"
vault_version: "1.15.0"
nomad_version: "1.7.0"
boundary_version: "0.15.0"

# Cluster Configuration
consul_servers: 5
vault_servers: 3
nomad_servers: 5

# Security Configuration
enable_tls: true
ca_provider: "vault"
```

## Security Considerations

### Secrets Management
- Use Vault for all secret storage
- Never commit secrets to version control
- Use dynamic secrets where possible
- Implement secret rotation policies

### Network Security
- Enable VPC/VNet isolation
- Use private subnets for HashiCorp services
- Implement security group restrictions
- Enable cross-cloud encrypted communication

### Access Control
- Implement least-privilege access
- Use cloud IAM roles for authentication
- Enable multi-factor authentication
- Regular access reviews and audits

## Troubleshooting

### Common Issues

#### Terraform State Conflicts
```bash
# If encountering state lock issues
terraform force-unlock <lock-id>

# If state corruption occurs
terraform state pull > backup.tfstate
terraform import <resource> <id>
```

#### Ansible Connection Issues
```bash
# Test Ansible connectivity
ansible all -i inventory.yml -m ping

# Debug connection issues
ansible-playbook -i inventory.yml playbook.yml -vvv
```

#### Service Health Issues
```bash
# Check service status
./health-check.sh --verbose

# View service logs
kubectl logs -n consul -l app=consul-server
```

### Log Collection
```bash
# Collect deployment logs
./bash/collect-logs.sh

# View specific service logs
python monitor.py --logs --service consul
```

## Maintenance

### Regular Maintenance Tasks
- Weekly health checks and monitoring review
- Monthly security patching and updates
- Quarterly disaster recovery testing
- Annual architecture review and optimization

### Update Procedures
```bash
# Update HashiCorp products
./update-hashicorp-products.sh

# Update infrastructure
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

# Update configuration
ansible-playbook -i inventory.yml update-playbook.yml
```

## Integration

### CI/CD Integration
- GitHub Actions workflows
- GitLab CI/CD pipelines
- Jenkins pipeline scripts
- Azure DevOps integration

### Monitoring Integration
- Prometheus metrics collection
- Grafana dashboard automation
- ELK stack log aggregation
- PagerDuty alerting integration

### Backup Integration
- Automated backup scheduling
- Cross-region backup replication
- Backup integrity verification
- Disaster recovery automation

## Support

### Documentation
- [HashiCorp Learn](https://learn.hashicorp.com/)
- [Terraform Registry](https://registry.terraform.io/)
- [Ansible Galaxy](https://galaxy.ansible.com/)

### Community Support
- HashiCorp Community Forum
- Stack Overflow (with appropriate tags)
- GitHub Issues and Discussions

### Professional Support
- HashiCorp Professional Services
- Partner consulting services
- Enterprise support contracts

---

**Script Version**: 1.0  
**Last Updated**: [Current Date]  
**Maintainer**: Platform Engineering Team
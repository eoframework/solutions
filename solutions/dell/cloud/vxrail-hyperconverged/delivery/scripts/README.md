# VXRail Automation Scripts

## Overview

This directory contains automation scripts for Dell VXRail Hyperconverged Infrastructure deployment, configuration, and management. The scripts are organized by technology stack and use case, providing comprehensive automation capabilities for VXRail environments.

## Directory Structure

```
scripts/
├── ansible/          # Ansible playbooks and roles
├── bash/             # Shell scripts for Linux/ESXi operations
├── powershell/       # PowerShell scripts for Windows/vSphere
├── python/           # Python utilities and API integrations
└── terraform/        # Infrastructure as Code templates
```

## Script Categories

### Deployment and Configuration
- **Cluster Initialization**: Automated VXRail cluster deployment
- **Network Configuration**: VLAN, port group, and distributed switch setup
- **Storage Configuration**: vSAN policies and datastore management
- **Security Configuration**: Certificate management and access controls

### Operations and Maintenance
- **Health Monitoring**: System health checks and reporting
- **Performance Monitoring**: Resource utilization and optimization
- **Backup Management**: Automated backup and validation procedures
- **Update Management**: Firmware and software update automation

### Integration and Migration
- **Cloud Integration**: Hybrid cloud connectivity and management
- **Workload Migration**: VM migration and application deployment
- **API Integration**: CloudIQ, vCenter, and VXRail Manager APIs
- **Monitoring Integration**: Third-party monitoring system integration

## Technology Stack Usage

### Ansible Playbooks
**Location**: `ansible/`  
**Use Cases**: Configuration management, orchestration, compliance
```yaml
# Example usage
ansible-playbook -i inventory/vxrail-cluster deploy-cluster.yml
ansible-playbook -i inventory/vxrail-cluster configure-monitoring.yml
```

### Bash Scripts
**Location**: `bash/`  
**Use Cases**: ESXi administration, Linux utilities, log management
```bash
# Example usage
./health-check.sh --cluster vxrail-prod
./backup-validation.sh --date 2024-01-01
```

### PowerShell Scripts
**Location**: `powershell/`  
**Use Cases**: vSphere management, Windows integration, reporting
```powershell
# Example usage
.\Deploy-VXRailCluster.ps1 -ConfigFile config.json
.\Get-PerformanceReport.ps1 -Cluster "VxRail-Production"
```

### Python Scripts
**Location**: `python/`  
**Use Cases**: API automation, data analysis, custom integrations
```python
# Example usage
python3 cloudiq_integration.py --config cloudiq.conf
python3 performance_analyzer.py --cluster vxrail-prod
```

### Terraform Modules
**Location**: `terraform/`  
**Use Cases**: Infrastructure as Code, environment provisioning
```bash
# Example usage
terraform init
terraform plan -var-file="vxrail-prod.tfvars"
terraform apply -var-file="vxrail-prod.tfvars"
```

## Common Scripts Reference

### Daily Operations
| Script | Technology | Purpose | Usage |
|--------|------------|---------|--------|
| `daily-health-check.sh` | Bash | System health validation | `./daily-health-check.sh` |
| `Get-DailyReport.ps1` | PowerShell | Performance reporting | `.\Get-DailyReport.ps1` |
| `cloudiq-sync.py` | Python | CloudIQ data synchronization | `python3 cloudiq-sync.py` |
| `backup-monitor.yml` | Ansible | Backup job monitoring | `ansible-playbook backup-monitor.yml` |

### Deployment and Configuration
| Script | Technology | Purpose | Usage |
|--------|------------|---------|--------|
| `deploy-cluster.yml` | Ansible | Cluster deployment | `ansible-playbook deploy-cluster.yml` |
| `Deploy-VXRailCluster.ps1` | PowerShell | Cluster initialization | `.\Deploy-VXRailCluster.ps1` |
| `vxrail-config.tf` | Terraform | Infrastructure provisioning | `terraform apply` |
| `cluster-setup.sh` | Bash | Post-deployment configuration | `./cluster-setup.sh` |

### Maintenance and Updates
| Script | Technology | Purpose | Usage |
|--------|------------|---------|--------|
| `update-firmware.yml` | Ansible | Firmware updates | `ansible-playbook update-firmware.yml` |
| `Update-VXRailCluster.ps1` | PowerShell | Software updates | `.\Update-VXRailCluster.ps1` |
| `maintenance-mode.sh` | Bash | Maintenance mode management | `./maintenance-mode.sh enter` |
| `lcm_automation.py` | Python | Lifecycle management | `python3 lcm_automation.py` |

## Prerequisites and Dependencies

### System Requirements
- **Ansible**: Version 4.0+ with VMware collection
- **PowerShell**: Version 7.0+ with VMware PowerCLI
- **Python**: Version 3.8+ with required libraries
- **Terraform**: Version 1.0+ with VMware provider
- **Bash**: Version 4.0+ (Linux/macOS/WSL)

### Required Permissions
- **vCenter Server**: Administrator privileges
- **VXRail Manager**: Administrative access
- **ESXi Hosts**: Root or administrative access
- **CloudIQ**: API access token
- **Network Infrastructure**: Switch management access

### Configuration Files
Each script category includes example configuration files:
- `ansible/inventory/` - Ansible inventory and variables
- `powershell/config/` - PowerShell configuration files
- `python/config/` - Python configuration and credentials
- `terraform/vars/` - Terraform variable files

## Security Considerations

### Credential Management
- Use encrypted credential stores (Ansible Vault, PowerShell SecureString)
- Implement service accounts with minimal required privileges
- Rotate credentials regularly according to security policies
- Never store credentials in plain text within scripts

### Access Controls
- Implement role-based access for script execution
- Use jump hosts or bastion hosts for production access
- Log all script executions with audit trails
- Implement change approval processes for production scripts

### Network Security
- Use encrypted connections (HTTPS, SSH) for all API calls
- Implement network segmentation for management traffic
- Use VPN or private networks for script execution
- Validate SSL certificates and implement certificate pinning

## Best Practices

### Script Development
1. **Error Handling**: Implement comprehensive error handling and rollback procedures
2. **Logging**: Include detailed logging with timestamps and correlation IDs
3. **Idempotency**: Ensure scripts can be run multiple times safely
4. **Documentation**: Include inline comments and usage examples
5. **Testing**: Test scripts in development environments before production use

### Version Control
1. **Repository Structure**: Organize scripts logically by function and technology
2. **Branching Strategy**: Use feature branches for development, main branch for production
3. **Release Management**: Tag releases and maintain changelog
4. **Code Review**: Implement peer review process for all script changes

### Deployment Process
1. **Environment Promotion**: Test in dev → staging → production progression  
2. **Rollback Planning**: Maintain rollback procedures for all automation
3. **Change Management**: Follow organizational change control processes
4. **Monitoring**: Implement monitoring and alerting for automated processes

## Usage Examples

### Cluster Health Check
```bash
# Daily health check with email reporting
./bash/daily-health-check.sh --email ops-team@company.com --cluster prod

# Generate health report in JSON format
python3 python/health_monitor.py --output-format json --cluster prod

# PowerShell health check with detailed reporting
.\powershell\Get-ClusterHealth.ps1 -Cluster "VxRail-Production" -Detailed
```

### Automated Deployment
```bash
# Deploy new cluster using Terraform
cd terraform/vxrail-cluster/
terraform init
terraform plan -var-file="production.tfvars"
terraform apply -var-file="production.tfvars"

# Configure cluster using Ansible
ansible-playbook -i inventory/production ansible/deploy-cluster.yml

# Post-deployment validation
python3 python/deployment_validator.py --cluster-config production.json
```

### Performance Monitoring
```powershell
# Generate weekly performance report
.\powershell\Get-PerformanceReport.ps1 -Cluster "VxRail-Production" -Period "Weekly"

# Automated performance optimization
python3 python/performance_optimizer.py --cluster prod --auto-optimize

# CloudIQ integration and alerting
ansible-playbook ansible/cloudiq-integration.yml --extra-vars "cluster=production"
```

## Troubleshooting Guide

### Common Issues

#### Authentication Failures
```bash
# Verify credentials
ansible-playbook ansible/test-connectivity.yml --check

# Test PowerShell module connectivity
Test-VIServerConnection -Server vcenter.company.com

# Validate Python API access
python3 -c "import requests; print(requests.get('https://api.cloudiq.dell.com/health').status_code)"
```

#### Network Connectivity
```bash
# Test network connectivity
./bash/network-test.sh --target-hosts vxrail-01,vxrail-02,vxrail-03

# Validate API endpoints
curl -k https://vxrail-manager.company.com/rest/vxm/v1/system/cluster-info
```

#### Script Execution Failures
```bash
# Enable verbose logging
export ANSIBLE_VERBOSITY=3
ansible-playbook deploy-cluster.yml -vvv

# PowerShell execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Python dependency issues
pip install -r requirements.txt
```

### Debug Mode
Most scripts support debug mode for troubleshooting:
```bash
# Bash scripts
./script.sh --debug

# Python scripts  
python3 script.py --log-level DEBUG

# PowerShell scripts
.\script.ps1 -Debug

# Ansible playbooks
ansible-playbook playbook.yml -vvv --debug
```

## Support and Contributing

### Getting Help
- **Internal Support**: Contact the DevOps team for script assistance
- **Documentation**: Refer to individual script documentation in each directory
- **Community**: Join the VXRail automation community forums

### Contributing Guidelines
1. **Code Standards**: Follow established coding standards for each language
2. **Testing**: Include unit tests and integration tests where applicable
3. **Documentation**: Update documentation for any new scripts or changes
4. **Pull Requests**: Use descriptive commit messages and include testing results

### Reporting Issues
- **Bug Reports**: Use the issue tracking system with detailed reproduction steps
- **Feature Requests**: Submit enhancement requests through the proper channels
- **Security Issues**: Report security vulnerabilities through secure channels

## Maintenance Schedule

### Regular Updates
- **Weekly**: Review script execution logs and performance metrics
- **Monthly**: Update dependencies and security patches
- **Quarterly**: Review and update script documentation
- **Annually**: Complete security audit and penetration testing

### Script Lifecycle
1. **Development**: Create and test new scripts in development environment
2. **Staging**: Deploy to staging for integration testing
3. **Production**: Deploy to production with change management approval
4. **Maintenance**: Regular updates and security patches
5. **Deprecation**: Planned retirement of outdated scripts

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Owner**: Dell Technologies Professional Services  
**Classification**: Internal Use
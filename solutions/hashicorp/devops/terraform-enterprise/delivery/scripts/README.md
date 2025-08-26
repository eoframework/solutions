# HashiCorp Terraform Enterprise - Deployment Scripts

## Overview
This directory contains comprehensive deployment automation scripts for the HashiCorp Terraform Enterprise platform. The scripts support multiple deployment methods and provide complete automation from infrastructure provisioning to application configuration.

## Script Structure

### Terraform Infrastructure as Code
- **[main.tf](terraform/main.tf)** - Complete AWS infrastructure deployment
- **[variables.tf](terraform/variables.tf)** - Input variable definitions
- **[outputs.tf](terraform/outputs.tf)** - Infrastructure output values
- **[terraform.tfvars.example](terraform/terraform.tfvars.example)** - Example variable values
- **[tfe-values.yaml](terraform/tfe-values.yaml)** - Helm chart values for TFE deployment

### Cross-Platform Automation Scripts
- **[deploy.sh](bash/deploy.sh)** - Unix/Linux deployment automation
- **[Deploy-Solution.ps1](powershell/Deploy-Solution.ps1)** - Windows PowerShell deployment script
- **[deploy.py](python/deploy.py)** - Python-based deployment automation
- **[requirements.txt](python/requirements.txt)** - Python dependencies
- **[playbook.yml](ansible/playbook.yml)** - Ansible configuration management

## Deployment Approach

### Phase 1: Infrastructure Deployment
```bash
# Deploy AWS infrastructure with Terraform
cd terraform/
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Phase 2: Application Deployment
```bash
# Deploy TFE application to Kubernetes
helm repo add hashicorp https://helm.releases.hashicorp.com
helm upgrade --install terraform-enterprise hashicorp/terraform-enterprise \
  --namespace terraform-enterprise \
  --create-namespace \
  --values terraform/tfe-values.yaml
```

### Phase 3: Configuration and Validation
```bash
# Configure TFE and validate deployment
./bash/deploy.sh --validate
# OR
python python/deploy.py --validate-only
# OR
ansible-playbook ansible/playbook.yml --tags validate
```

## Script Usage Guide

### Bash Deployment Script
**Platform**: Linux, macOS, Windows (WSL)  
**Prerequisites**: bash, aws-cli, kubectl, helm, terraform

```bash
# Basic deployment
./bash/deploy.sh --environment prod

# Deployment with custom configuration
./bash/deploy.sh --environment prod --config-file custom-config.yaml

# Validation only (no changes)
./bash/deploy.sh --validate-only

# Full deployment with monitoring
./bash/deploy.sh --environment prod --enable-monitoring --skip-prerequisites
```

**Command Options**:
- `--environment`: Target environment (dev, staging, prod)
- `--config-file`: Custom configuration file path
- `--validate-only`: Perform validation without deployment
- `--skip-prerequisites`: Skip prerequisite validation
- `--enable-monitoring`: Deploy monitoring stack
- `--dry-run`: Show what would be deployed without making changes

### PowerShell Deployment Script
**Platform**: Windows, PowerShell Core (Linux/macOS)  
**Prerequisites**: PowerShell 7+, AWS Tools, kubectl, helm, terraform

```powershell
# Basic deployment
.\powershell\Deploy-Solution.ps1 -Environment "prod"

# Deployment with custom parameters
.\powershell\Deploy-Solution.ps1 -Environment "prod" -ConfigFile "config.json" -SkipPrerequisites

# Validation only
.\powershell\Deploy-Solution.ps1 -Environment "prod" -ValidateOnly

# Full deployment with detailed logging
.\powershell\Deploy-Solution.ps1 -Environment "prod" -Verbose -EnableMonitoring
```

**Parameters**:
- `-Environment`: Target environment (dev, staging, prod)
- `-ConfigFile`: Configuration file path (JSON format)
- `-ValidateOnly`: Validation mode only
- `-SkipPrerequisites`: Skip prerequisite checks
- `-EnableMonitoring`: Deploy monitoring components
- `-Verbose`: Enable detailed logging

### Python Deployment Script
**Platform**: Cross-platform Python 3.8+  
**Prerequisites**: Python 3.8+, pip packages (see requirements.txt)

```bash
# Install dependencies
pip install -r python/requirements.txt

# Basic deployment
python python/deploy.py --environment prod

# Interactive deployment with prompts
python python/deploy.py --interactive

# Deployment with custom configuration
python python/deploy.py --config config.yaml --environment prod

# API-driven deployment with validation
python python/deploy.py --environment prod --validate-only --api-mode
```

**Command Options**:
- `--environment`: Target environment
- `--config`: Configuration file (YAML or JSON)
- `--interactive`: Interactive mode with prompts
- `--validate-only`: Validation mode
- `--api-mode`: Use APIs instead of CLI tools
- `--verbose`: Enable debug logging

### Ansible Deployment Playbook
**Platform**: Cross-platform with Ansible  
**Prerequisites**: Ansible 4.0+, required collections

```bash
# Install Ansible collections
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install amazon.aws

# Basic deployment
ansible-playbook ansible/playbook.yml -i inventory

# Deployment with extra variables
ansible-playbook ansible/playbook.yml -i inventory \
  -e environment=prod \
  -e enable_monitoring=true

# Specific tasks only
ansible-playbook ansible/playbook.yml -i inventory --tags deploy-tfe

# Dry run mode
ansible-playbook ansible/playbook.yml -i inventory --check --diff
```

**Playbook Tags**:
- `prerequisite`: Validate prerequisites
- `infrastructure`: Deploy infrastructure
- `kubernetes`: Configure Kubernetes
- `deploy-tfe`: Deploy TFE application
- `configure`: Post-deployment configuration
- `validate`: Validation and testing

## Configuration Management

### Environment Configuration Files
```
# Development Environment
environments/
├── dev.yaml
├── staging.yaml
└── prod.yaml

# Custom Configuration Templates
templates/
├── tfe-values.yaml.j2
├── terraform.tfvars.j2
└── monitoring-config.yaml.j2
```

### Configuration Structure
```yaml
# Example environment configuration (prod.yaml)
environment: "prod"
project_name: "tfe-production"

aws:
  region: "us-east-1"
  vpc_cidr: "10.0.0.0/16"

kubernetes:
  version: "1.28"
  node_count: 6
  node_instance_type: "m5.xlarge"

terraform_enterprise:
  hostname: "terraform.company.com"
  replica_count: 3
  resources:
    requests:
      cpu: "2000m"
      memory: "4Gi"
    limits:
      cpu: "4000m"
      memory: "8Gi"

database:
  instance_class: "db.r5.xlarge"
  allocated_storage: 500
  multi_az: true

monitoring:
  enabled: true
  retention_days: 30
```

## Advanced Usage Patterns

### Multi-Environment Deployment
```bash
# Deploy to multiple environments in sequence
for env in dev staging prod; do
  echo "Deploying to $env..."
  ./bash/deploy.sh --environment $env --config-file environments/${env}.yaml
  
  # Wait for validation before next environment
  if [ $? -eq 0 ]; then
    echo "✓ $env deployment successful"
  else
    echo "✗ $env deployment failed, stopping pipeline"
    exit 1
  fi
done
```

### Blue-Green Deployment Pattern
```bash
# Deploy to blue environment
./bash/deploy.sh --environment prod-blue --config-file prod-blue.yaml

# Validate blue environment
./bash/deploy.sh --environment prod-blue --validate-only

# Switch traffic to blue (manual DNS/load balancer change)
# Monitor and validate

# Tear down green environment
./bash/deploy.sh --environment prod-green --destroy
```

### Disaster Recovery Deployment
```bash
# Deploy DR environment in secondary region
./bash/deploy.sh --environment dr \
  --config-file dr-config.yaml \
  --enable-cross-region-backup

# Test DR environment
./bash/deploy.sh --environment dr --validate-only --full-test

# Simulate failover scenario
./bash/deploy.sh --environment dr --failover-test
```

## CI/CD Integration

### GitHub Actions Integration
```yaml
# .github/workflows/deploy-tfe.yml
name: Deploy Terraform Enterprise
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Deploy TFE
      run: |
        chmod +x bash/deploy.sh
        ./bash/deploy.sh --environment staging --config-file environments/staging.yaml
      env:
        TFE_TOKEN: ${{ secrets.TFE_TOKEN }}
        KUBE_CONFIG_DATA: ${{ secrets.KUBE_CONFIG_DATA }}
```

### Jenkins Pipeline Integration
```groovy
pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TFE_TOKEN = credentials('tfe-token')
    }
    
    stages {
        stage('Prerequisites') {
            steps {
                sh './bash/deploy.sh --validate-prerequisites'
            }
        }
        
        stage('Deploy Infrastructure') {
            steps {
                sh '''
                    ./bash/deploy.sh --environment ${ENVIRONMENT} \
                                     --config-file environments/${ENVIRONMENT}.yaml \
                                     --infrastructure-only
                '''
            }
        }
        
        stage('Deploy Application') {
            steps {
                sh '''
                    ./bash/deploy.sh --environment ${ENVIRONMENT} \
                                     --config-file environments/${ENVIRONMENT}.yaml \
                                     --application-only
                '''
            }
        }
        
        stage('Validate Deployment') {
            steps {
                sh './bash/deploy.sh --environment ${ENVIRONMENT} --validate-only'
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'logs/**/*', fingerprint: true
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'reports',
                reportFiles: 'deployment-report.html',
                reportName: 'Deployment Report'
            ])
        }
    }
}
```

### Azure DevOps Integration
```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
- group: tfe-deployment-variables

stages:
- stage: Deploy
  jobs:
  - job: DeployTFE
    steps:
    - task: AzureCLI@2
      inputs:
        azureSubscription: 'Azure Connection'
        scriptType: 'bash'
        scriptLocation: 'scriptPath'
        scriptPath: 'bash/deploy.sh'
        arguments: '--environment $(Environment) --config-file environments/$(Environment).yaml'
      env:
        TFE_TOKEN: $(TFE_TOKEN)
        AWS_ACCESS_KEY_ID: $(AWS_ACCESS_KEY_ID)
        AWS_SECRET_ACCESS_KEY: $(AWS_SECRET_ACCESS_KEY)
```

## Monitoring and Observability

### Deployment Metrics Collection
```bash
# Enable metrics collection during deployment
export DEPLOYMENT_METRICS=true
export METRICS_ENDPOINT="https://metrics.company.com/api/v1/metrics"

# Deploy with metrics
./bash/deploy.sh --environment prod --enable-metrics

# View deployment metrics
curl -H "Authorization: Bearer $METRICS_TOKEN" \
  "${METRICS_ENDPOINT}/query?query=deployment_duration{job=\"tfe-deployment\"}"
```

### Health Check Integration
```bash
# Continuous health monitoring
while true; do
  ./bash/deploy.sh --environment prod --health-check
  sleep 300  # Check every 5 minutes
done

# Integration with external monitoring
./bash/deploy.sh --environment prod --health-check --webhook-url "https://monitoring.company.com/webhook"
```

## Security Considerations

### Secret Management
```bash
# Use AWS Secrets Manager for sensitive values
export TFE_DATABASE_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id tfe/database/password --query SecretString --output text)

# Use Kubernetes secrets for runtime configuration
kubectl create secret generic tfe-secrets \
  --from-literal=database-password="$TFE_DATABASE_PASSWORD" \
  --namespace terraform-enterprise
```

### Network Security
```bash
# Deploy with enhanced security
./bash/deploy.sh --environment prod \
  --enable-network-policies \
  --enable-pod-security-policies \
  --restrict-ingress-sources
```

### Compliance and Auditing
```bash
# Enable audit logging
./bash/deploy.sh --environment prod --enable-audit-logging

# Generate compliance report
./bash/deploy.sh --environment prod --compliance-report
```

## Troubleshooting

### Common Issues and Solutions

#### Deployment Fails During Infrastructure Phase
```bash
# Check Terraform state
terraform show
terraform refresh

# Fix state inconsistencies
terraform import aws_vpc.main vpc-12345678
terraform plan
```

#### Kubernetes Deployment Issues
```bash
# Check cluster connectivity
kubectl cluster-info
kubectl get nodes

# Debug pod issues
kubectl describe pod terraform-enterprise-xxx -n terraform-enterprise
kubectl logs terraform-enterprise-xxx -n terraform-enterprise
```

#### Script Execution Errors
```bash
# Enable debug mode
export DEBUG=true
./bash/deploy.sh --environment prod --verbose

# Check prerequisites
./bash/deploy.sh --check-prerequisites-only
```

### Log Collection
```bash
# Collect all deployment logs
./bash/deploy.sh --environment prod --collect-logs

# Upload logs to support
aws s3 cp deployment-logs.tar.gz s3://support-bucket/
```

## Support and Maintenance

### Script Updates
- Monitor HashiCorp product releases for compatibility updates
- Test script changes in development environment first
- Maintain version compatibility matrix
- Update dependencies regularly

### Documentation Updates
- Keep configuration examples current
- Update troubleshooting procedures based on common issues
- Maintain compatibility notes for different versions
- Document customizations and deviations

---
**Script Documentation Version**: 1.0  
**Last Updated**: 2024-01-15  
**Maintained by**: Platform Engineering Team
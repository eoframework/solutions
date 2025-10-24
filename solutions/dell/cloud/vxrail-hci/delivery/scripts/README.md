# DELL Vxrail Hci - Deployment Scripts

## Overview

This directory contains deployment automation scripts for DELL Vxrail Hci solution using Cloud services. The scripts work together in a specific sequence to create a complete cloud solution.

## Script Architecture

### Script Types & Dependencies

**📋 EXECUTION ORDER: Sequential (terraform → python)**

The scripts are **NOT standalone** - they must be executed in the correct order as they have dependencies on each other.

1. **Terraform Scripts** - Infrastructure provisioning and deployment
2. **Python Scripts** - Application logic and service configuration

### Directory Structure

```
scripts/
├── README.md                    # This file
├── python/                   # Application logic and service configuration
│   └── deploy.py               # Primary script
├── terraform/                   # Application logic and service configuration
│   └── main.tf               # Primary script
```

---

## Prerequisites

### Required Tools
- Cloud provider CLI
- Python 3.8+
- Terraform v1.0+
- pip package manager

### DELL Permissions Required
- Administrative access to DELL systems
- API access and authentication credentials
- Network connectivity to target infrastructure

### Environment Setup
```bash
# Configure DELL credentials

# Set solution-specific variables
export PROJECT_NAME="vxrail_hci"
export ENVIRONMENT="production"
```

---

## Deployment Instructions

### ⚠️ IMPORTANT: Scripts Must Run in Sequence

### Step 1: Infrastructure Provisioning And Deployment (REQUIRED FIRST)

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

**What this does:**
- ✅ Provisions cloud infrastructure resources
- ✅ Sets up networking and security configurations
- ✅ Creates resource dependencies and relationships
- ✅ Outputs resource identifiers for next steps

**Duration:** ~10-15 minutes
### Step 2: Application Logic And Service Configuration (REQUIRED NEXT)

```bash
cd python/
python3 deploy.py
```

**What this does:**
- ✅ Deploys application components
- ✅ Configures API integrations
- ✅ Sets up monitoring and alerting
- ✅ Performs end-to-end validation

**Duration:** ~10-15 minutes  
**Dependencies:** Requires resources created by terraform scripts
---

## Usage After Deployment

### Accessing the Solution

The deployed Vxrail Hci solution provides the following capabilities:

#### Service Endpoints
- Primary interface: Available via cloud provider console
- API endpoints: Configured during deployment
- Monitoring dashboards: Integrated with cloud monitoring

#### Management Commands
```bash
# Check deployment status

# Monitor solution health
# (Provider-specific commands available in script output)
```

---

## Troubleshooting

### Common Issues

#### 1. Authentication/Credentials
```bash
Error: Authentication failed or credentials not found
Solution: Ensure cloud provider CLI is configured with appropriate credentials
```

#### 2. Insufficient Permissions  
```bash
Error: Access denied or permission errors
Solution: Verify account has required permissions listed in Prerequisites
```

#### 3. Resource Conflicts
```bash
Error: Resource already exists or naming conflicts
Solution: Choose unique PROJECT_NAME or clean up existing resources
```

#### 4. Deployment Timeout
```bash
Error: Deployment exceeded timeout limits
Solution: Check network connectivity and resource availability in target region
```

### Validation Commands

```bash
# Verify all components are deployed
cd python/
# Run validation commands specific to solution type
# (Detailed commands available in individual scripts)
```

### Cleanup

#### Remove All Resources
```bash
# WARNING: This will delete all created resources
cd terraform/
terraform destroy
```

---

## Support

### Log Locations
- Deployment logs: Available in script output and cloud provider logs
- Application logs: Configured during deployment
- System logs: Available via cloud monitoring services

### Monitoring
Key metrics and monitoring capabilities are configured automatically during deployment. Access monitoring dashboards through your cloud provider console.

### Documentation
- Individual script directories contain detailed usage instructions
- Cloud provider documentation for service-specific guidance
- Solution-specific configuration examples in script files

---

**Last Updated:** August 2025  
**Solution Version:** 1.0  
**Maintained By:** EO Framework™ Dell Solutions Team
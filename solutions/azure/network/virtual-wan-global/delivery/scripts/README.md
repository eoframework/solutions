# AZURE Virtual Wan Global - Deployment Scripts

## Overview

This directory contains deployment automation scripts for AZURE Virtual Wan Global solution using Azure Virtual WAN. The scripts work together in a specific sequence to create a complete network solution.

## Script Architecture

### Script Types & Dependencies

**📋 EXECUTION ORDER: Sequential (ansible → python)**

The scripts are **NOT standalone** - they must be executed in the correct order as they have dependencies on each other.

1. **Ansible Scripts** - Infrastructure orchestration and configuration
2. **Python Scripts** - Service integration and automation

### Directory Structure

```
scripts/
├── README.md                    # This file
├── ansible/                   # Service integration and automation
│   └── playbook.yml               # Primary script
├── python/                   # Service integration and automation
│   └── deploy.py               # Primary script
```

---

## Prerequisites

### Required Tools
- Ansible v2.9+
- Azure CLI v2.50+
- Python 3.8+
- pip package manager

### AZURE Permissions Required
- Contributor role on target subscription
- User Access Administrator (for role assignments)  
- Service-specific admin roles as required

### Environment Setup
```bash
# Configure AZURE credentials
az login
az account set --subscription "your-subscription-id"
export AZURE_SUBSCRIPTION_ID="your-subscription-id"

# Set solution-specific variables
export PROJECT_NAME="virtual_wan_global"
export ENVIRONMENT="production"
```

---

## Deployment Instructions

### ⚠️ IMPORTANT: Scripts Must Run in Sequence

### Step 1: Infrastructure Orchestration And Configuration (REQUIRED FIRST)

```bash
cd ansible/
ansible-playbook -i inventory.yml playbook.yml
```

**What this does:**
- ✅ Configures infrastructure components
- ✅ Installs and configures services
- ✅ Manages multi-system orchestration
- ✅ Ensures idempotent configuration state

**Duration:** ~20-30 minutes
### Step 2: Service Integration And Automation (REQUIRED NEXT)

```bash
cd python/
python3 deploy.py
```

**What this does:**
- ✅ Deploys application components
- ✅ Configures API integrations
- ✅ Sets up monitoring and alerting
- ✅ Performs end-to-end validation

**Duration:** ~20-30 minutes  
**Dependencies:** Requires resources created by ansible scripts
---

## Usage After Deployment

### Accessing the Solution

The deployed Virtual Wan Global solution provides the following capabilities:

#### Service Endpoints
- Primary interface: Available via cloud provider console
- API endpoints: Configured during deployment
- Monitoring dashboards: Integrated with cloud monitoring

#### Management Commands
```bash
# Check deployment status
az group show --name $PROJECT_NAME-rg

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
cd ansible/
# Run validation commands specific to solution type
# (Detailed commands available in individual scripts)
```

### Cleanup

#### Remove All Resources
```bash
# WARNING: This will delete all created resources
az group delete --name $PROJECT_NAME-rg --yes
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
**Maintained By:** EO Framework™ Azure Solutions Team
# GOOGLE Workspace - Deployment Scripts

## Overview

This directory contains deployment automation scripts for GOOGLE Workspace solution using Cloud services. The scripts work together in a specific sequence to create a complete modern-workspace solution.

## Script Architecture

### Script Types & Dependencies

**📋 EXECUTION ORDER: Sequential (powershell → python)**

The scripts are **NOT standalone** - they must be executed in the correct order as they have dependencies on each other.

1. **Powershell Scripts** - Windows service deployment and configuration
2. **Python Scripts** - Cross-platform automation and integration

### Directory Structure

```
scripts/
├── README.md                    # This file
├── powershell/                   # Cross-platform automation and integration
│   └── Deploy-Solution.ps1               # Primary script
├── python/                   # Cross-platform automation and integration
│   └── deploy.py               # Primary script
```

---

## Prerequisites

### Required Tools
- PowerShell Core 7.0+
- Python 3.8+
- gcloud CLI
- pip package manager

### GOOGLE Permissions Required
- Project Editor or custom role with required permissions
- Service account creation and management
- API enablement permissions

### Environment Setup
```bash
# Configure GOOGLE credentials
gcloud auth login
gcloud config set project your-project-id
export GOOGLE_PROJECT_ID="your-project-id"

# Set solution-specific variables
export PROJECT_NAME="workspace"
export ENVIRONMENT="production"
```

---

## Deployment Instructions

### ⚠️ IMPORTANT: Scripts Must Run in Sequence

### Step 1: Windows Service Deployment And Configuration (REQUIRED FIRST)

```bash
cd powershell/
./Deploy-Solution.ps1
```

**What this does:**
- ✅ Configures Windows-based services
- ✅ Manages Active Directory integration
- ✅ Installs and configures applications
- ✅ Sets up monitoring and logging

**Duration:** ~10-15 minutes
### Step 2: Cross-Platform Automation And Integration (REQUIRED NEXT)

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
**Dependencies:** Requires resources created by powershell scripts
---

## Usage After Deployment

### Accessing the Solution

The deployed Workspace solution provides the following capabilities:

#### Service Endpoints
- Primary interface: Available via cloud provider console
- API endpoints: Configured during deployment
- Monitoring dashboards: Integrated with cloud monitoring

#### Management Commands
```bash
# Check deployment status
gcloud deployment-manager deployments describe $PROJECT_NAME

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
cd powershell/
# Run validation commands specific to solution type
# (Detailed commands available in individual scripts)
```

### Cleanup

#### Remove All Resources
```bash
# WARNING: This will delete all created resources
gcloud deployment-manager deployments delete $PROJECT_NAME
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
**Maintained By:** EO Framework™ {provider_name} Solutions Team
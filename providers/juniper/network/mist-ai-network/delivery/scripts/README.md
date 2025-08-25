# Juniper Mist AI Network Deployment Scripts

## Overview

This directory contains automation scripts for deploying and managing Juniper Mist AI Network Platform. Scripts are organized by technology stack and provide comprehensive automation for installation, configuration, and ongoing operations.

## Script Organization

### Technology Stacks
- **[bash/](bash/)** - Shell scripts for system automation and device management
- **[python/](python/)** - Python scripts for Mist API integration and advanced automation
- **[powershell/](powershell/)** - PowerShell scripts for Windows integration
- **[terraform/](terraform/)** - Infrastructure as Code for cloud resources
- **[ansible/](ansible/)** - Configuration management and deployment automation

## Primary Deployment Scripts

### Main Deployment Script
- **[bash/deploy.sh](bash/deploy.sh)** - Primary deployment orchestration
- **[python/deploy.py](python/deploy.py)** - Mist API integration and management
- **[terraform/main.tf](terraform/main.tf)** - Cloud infrastructure provisioning
- **[ansible/playbook.yml](ansible/playbook.yml)** - Configuration automation

## Usage Instructions

### Quick Start
```bash
# Prerequisites check
./bash/deploy.sh --check-prerequisites

# Full deployment
./bash/deploy.sh --org-id "your-org-id" --site-count 5

# Python API management
python3 python/deploy.py --action setup --config config.yaml
```

For detailed usage instructions, see individual script documentation.
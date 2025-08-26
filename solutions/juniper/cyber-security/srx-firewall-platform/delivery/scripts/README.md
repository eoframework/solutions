# Juniper SRX Firewall Platform Deployment Scripts

## Overview

This directory contains automation scripts for deploying and managing Juniper SRX Firewall Platform. Scripts are organized by technology stack and provide comprehensive automation for security installation, configuration, and ongoing operations.

## Script Organization

### Technology Stacks
- **[bash/](bash/)** - Shell scripts for firewall automation and security management
- **[python/](python/)** - Python scripts for SRX API integration and advanced automation
- **[powershell/](powershell/)** - PowerShell scripts for Windows security integration
- **[terraform/](terraform/)** - Infrastructure as Code for security deployments
- **[ansible/](ansible/)** - Configuration management and security automation

## Primary Deployment Scripts

### Main Security Deployment Scripts
- **[bash/deploy.sh](bash/deploy.sh)** - Primary security deployment orchestration
- **[python/deploy.py](python/deploy.py)** - SRX management and policy automation
- **[terraform/main.tf](terraform/main.tf)** - Security infrastructure provisioning
- **[ansible/playbook.yml](ansible/playbook.yml)** - Security configuration automation

## Usage Instructions

### Quick Start
```bash
# Prerequisites check
./bash/deploy.sh --check-prerequisites

# Full security deployment
./bash/deploy.sh --device-ip "192.168.1.1" --security-zones "trust,untrust,dmz"

# Python security management
python3 python/deploy.py --action configure --device 192.168.1.1
```

### Advanced Security Configuration
```bash
# High availability deployment
./bash/deploy.sh --ha-mode active-passive --primary-ip 192.168.1.1 --secondary-ip 192.168.1.2

# Security policy deployment
python3 python/deploy.py --action deploy-policies --config security-policies.yaml
```

For detailed security configuration and deployment instructions, see individual script documentation.
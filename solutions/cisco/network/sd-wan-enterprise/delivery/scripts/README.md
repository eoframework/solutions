# Scripts - Cisco SD-WAN Enterprise

## Overview

This directory contains automation scripts and utilities for Cisco SD-WAN Enterprise deployment and operations.

---

## Script Categories

### Deployment Scripts
- **infrastructure-setup.sh** - Controller deployment automation
- **device-onboarding.py** - Automated device provisioning
- **template-deployment.sh** - Configuration template management

### Operations Scripts
- **health-monitoring.sh** - System health checks and monitoring
- **backup-management.py** - Configuration backup and restore
- **performance-monitoring.sh** - Network performance validation

### Maintenance Scripts
- **software-upgrade.py** - Automated software updates
- **certificate-renewal.sh** - Certificate management automation
- **policy-deployment.py** - Policy configuration automation

---

## Prerequisites

### Required Tools
- Bash shell (Linux/macOS)
- Python 3.7+
- Cisco SD-WAN APIs
- SSH access to devices

### Configuration
```bash
# Set environment variables
export VMANAGE_HOST="192.168.1.1"
export VMANAGE_USER="admin"
export VMANAGE_PASS="password"
```

---

## Usage Examples

### Device Onboarding
```bash
# Onboard new device
./device-onboarding.py --site-id 200 --device-ip 203.0.113.10

# Bulk onboarding
./device-onboarding.py --csv-file sites.csv
```

### Health Monitoring
```bash
# Daily health check
./health-monitoring.sh --verbose

# Automated monitoring
crontab -e
0 8 * * * /scripts/health-monitoring.sh
```

---

**Directory Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: Network Automation Team
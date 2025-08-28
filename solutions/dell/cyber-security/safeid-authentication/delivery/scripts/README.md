# Dell SafeID Authentication Scripts Documentation

## Overview

This directory contains automation scripts, deployment utilities, and management tools for Dell SafeID Authentication implementations. These scripts are designed to streamline installation, configuration, maintenance, and monitoring tasks.

## Script Categories

### Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks and roles
│   ├── playbooks/        # Complete deployment playbooks
│   ├── roles/           # Reusable Ansible roles
│   └── inventory/       # Environment-specific inventories
├── bash/                # Linux/Unix shell scripts
│   ├── installation/    # Installation automation
│   ├── monitoring/      # System monitoring scripts
│   └── maintenance/     # Routine maintenance tasks
├── powershell/          # Windows PowerShell scripts
│   ├── deployment/      # Deployment automation
│   ├── management/      # User and system management
│   ├── monitoring/      # Performance and health monitoring
│   └── troubleshooting/ # Diagnostic and repair scripts
├── python/              # Python automation scripts
│   ├── api/            # API integration scripts
│   ├── reporting/      # Report generation
│   └── utilities/      # General utility scripts
└── terraform/           # Infrastructure as Code
    ├── aws/            # AWS-specific resources
    ├── azure/          # Azure-specific resources
    └── modules/        # Reusable Terraform modules
```

## PowerShell Scripts

### Deployment Scripts

#### 1. Install-SafeIDSystem.ps1
**Purpose**: Automated SafeID system installation and configuration

```powershell
<#
.SYNOPSIS
    Automated Dell SafeID system installation and configuration
    
.DESCRIPTION
    This script performs a complete SafeID installation including:
    - Prerequisites validation
    - Software installation
    - Certificate configuration
    - Active Directory integration
    - Initial user enrollment
    
.PARAMETER InstallPath
    Installation directory (default: C:\Program Files\Dell\SafeID)
    
.PARAMETER ServiceAccount
    Service account for SafeID services (required)
    
.PARAMETER CertificateThumbprint
    SSL certificate thumbprint for HTTPS (required)
    
.PARAMETER DatabaseServer
    Database server name (default: localhost)
    
.PARAMETER Silent
    Run installation without user interaction
    
.EXAMPLE
    .\Install-SafeIDSystem.ps1 -ServiceAccount "company\safeid-service" -CertificateThumbprint "A1B2C3D4..."
    
.EXAMPLE
    .\Install-SafeIDSystem.ps1 -Silent -ServiceAccount "company\safeid-service" -CertificateThumbprint "A1B2C3D4..." -DatabaseServer "db-server01"
#>

param(
    [string]$InstallPath = "C:\Program Files\Dell\SafeID",
    [Parameter(Mandatory)]
    [string]$ServiceAccount,
    [Parameter(Mandatory)]
    [string]$CertificateThumbprint,
    [string]$DatabaseServer = "localhost",
    [switch]$Silent
)

# Script implementation details...
```

**Usage Examples**:
- Standard installation: `.\Install-SafeIDSystem.ps1 -ServiceAccount "domain\safeid-svc" -CertificateThumbprint "ABC123..."`
- Silent installation: `.\Install-SafeIDSystem.ps1 -Silent -ServiceAccount "domain\safeid-svc" -CertificateThumbprint "ABC123..."`

#### 2. Deploy-SafeIDConfiguration.ps1
**Purpose**: Deploy configuration files to multiple SafeID servers

```powershell
<#
.SYNOPSIS
    Deploy SafeID configuration to multiple servers
    
.DESCRIPTION
    Distributes configuration files, certificates, and policies
    to SafeID servers in the environment
    
.PARAMETER ConfigPath
    Path to configuration files
    
.PARAMETER TargetServers
    Array of target server names
    
.PARAMETER RestartServices
    Restart SafeID services after deployment
#>
```

### Management Scripts

#### 1. Manage-SafeIDUsers.ps1
**Purpose**: Bulk user management operations

```powershell
<#
.SYNOPSIS
    Bulk SafeID user management operations
    
.DESCRIPTION
    Perform bulk operations on SafeID users including:
    - Add users to SafeID groups
    - Remove users from SafeID groups
    - Bulk enrollment initiation
    - User status reporting
    
.PARAMETER Operation
    Operation to perform: Add, Remove, Enroll, Report
    
.PARAMETER UserList
    CSV file containing user information
    
.PARAMETER Groups
    SafeID groups to modify
    
.EXAMPLE
    .\Manage-SafeIDUsers.ps1 -Operation Add -UserList "C:\users.csv" -Groups @("SafeID-Users", "SafeID-Biometric-Users")
#>
```

**CSV Format**:
```csv
UserPrincipalName,DisplayName,Department,Location
john.doe@company.com,John Doe,IT,New York
jane.smith@company.com,Jane Smith,Finance,Chicago
```

#### 2. Set-SafeIDPolicy.ps1
**Purpose**: Configure authentication policies

```powershell
<#
.SYNOPSIS
    Configure SafeID authentication policies
    
.DESCRIPTION
    Set and manage SafeID authentication policies including:
    - Biometric requirements
    - Lockout policies  
    - Token lifetime
    - Fallback options
    
.PARAMETER PolicyFile
    JSON file containing policy configuration
    
.PARAMETER ApplyTo
    Apply to: All, Group, OU
    
.PARAMETER Target
    Target group or OU name
#>
```

### Monitoring Scripts

#### 1. Monitor-SafeIDHealth.ps1
**Purpose**: Comprehensive system health monitoring

```powershell
<#
.SYNOPSIS
    Monitor SafeID system health and performance
    
.DESCRIPTION
    Performs comprehensive health checks including:
    - Service status monitoring
    - Performance metrics collection
    - Authentication success rates
    - Hardware status verification
    - Alert generation
    
.PARAMETER GenerateReport
    Generate HTML health report
    
.PARAMETER SendAlerts
    Send email alerts for issues
    
.PARAMETER LogPath
    Path for health check logs
#>
```

**Features**:
- Service status monitoring
- Performance metrics collection
- Hardware health checks
- Authentication rate analysis
- Automated alerting
- HTML report generation

#### 2. Get-SafeIDMetrics.ps1
**Purpose**: Performance and usage metrics collection

```powershell
<#
.SYNOPSIS
    Collect SafeID performance and usage metrics
    
.DESCRIPTION
    Gathers metrics for reporting and analysis:
    - Authentication volume and success rates
    - Response time statistics
    - User adoption metrics
    - System resource utilization
    - Error frequency analysis
    
.PARAMETER TimeRange
    Time range for metrics: Hour, Day, Week, Month
    
.PARAMETER OutputFormat
    Output format: JSON, CSV, XML
    
.PARAMETER IncludeDetails
    Include detailed user-level metrics
#>
```

### Troubleshooting Scripts

#### 1. Diagnose-SafeIDIssues.ps1
**Purpose**: Automated problem diagnosis

```powershell
<#
.SYNOPSIS
    Automated SafeID problem diagnosis
    
.DESCRIPTION
    Performs comprehensive diagnostic checks:
    - Service dependency analysis
    - Configuration validation
    - Hardware functionality tests
    - Network connectivity checks
    - Certificate validation
    - Log analysis
    
.PARAMETER DiagnosticLevel
    Level of diagnostics: Basic, Standard, Comprehensive
    
.PARAMETER SaveResults
    Save diagnostic results to file
    
.PARAMETER AutoFix
    Attempt automatic resolution of common issues
#>
```

#### 2. Repair-SafeIDSystem.ps1
**Purpose**: Automated system repair

```powershell
<#
.SYNOPSIS
    Automated SafeID system repair
    
.DESCRIPTION
    Attempts to resolve common SafeID issues:
    - Service restart and recovery
    - Configuration file repair
    - Certificate renewal
    - Database connectivity fixes
    - Hardware reinitialization
    
.PARAMETER IssueType
    Type of issue to repair: Service, Configuration, Certificate, Database, Hardware
    
.PARAMETER Force
    Force repair actions without confirmation
    
.PARAMETER BackupFirst
    Create backup before attempting repairs
#>
```

## Python Scripts

### API Integration Scripts

#### 1. safeid_api_client.py
**Purpose**: SafeID REST API client library

```python
"""
SafeID REST API Client

Provides programmatic access to SafeID management functions:
- User management
- Policy configuration
- Reporting and analytics
- System monitoring

Usage:
    from safeid_api_client import SafeIDClient
    
    client = SafeIDClient(
        server_url="https://safeid.company.com:8443",
        api_key="your-api-key"
    )
    
    # Get user information
    user = client.get_user("john.doe@company.com")
    
    # Enroll user
    client.enroll_user("jane.smith@company.com", "fingerprint")
"""

class SafeIDClient:
    def __init__(self, server_url, api_key):
        self.server_url = server_url
        self.api_key = api_key
        
    def get_user(self, user_principal_name):
        """Retrieve user information"""
        pass
        
    def enroll_user(self, user_principal_name, auth_type):
        """Initiate user enrollment"""
        pass
        
    def get_metrics(self, time_range="24h"):
        """Get system metrics"""
        pass
```

#### 2. bulk_operations.py
**Purpose**: Bulk user operations

```python
"""
SafeID Bulk Operations

Performs bulk operations on SafeID users:
- Bulk enrollment
- Group membership changes
- Policy updates
- Reporting

Usage:
    python bulk_operations.py --operation enroll --input users.csv --auth-type fingerprint
"""

import argparse
import csv
from safeid_api_client import SafeIDClient

def bulk_enroll_users(csv_file, auth_type):
    """Enroll multiple users from CSV file"""
    client = SafeIDClient(
        server_url=config.SAFEID_SERVER,
        api_key=config.API_KEY
    )
    
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                client.enroll_user(row['UserPrincipalName'], auth_type)
                print(f"✓ Enrolled {row['UserPrincipalName']}")
            except Exception as e:
                print(f"✗ Failed to enroll {row['UserPrincipalName']}: {e}")
```

### Reporting Scripts

#### 1. generate_reports.py
**Purpose**: Automated report generation

```python
"""
SafeID Report Generator

Generates various SafeID reports:
- User adoption reports
- Authentication success rates
- Performance metrics
- Compliance reports

Usage:
    python generate_reports.py --report-type adoption --output adoption_report.html
    python generate_reports.py --report-type performance --format pdf --email admin@company.com
"""

import argparse
from datetime import datetime, timedelta
from safeid_api_client import SafeIDClient
import matplotlib.pyplot as plt
import pandas as pd

class SafeIDReportGenerator:
    def __init__(self):
        self.client = SafeIDClient(
            server_url=config.SAFEID_SERVER,
            api_key=config.API_KEY
        )
    
    def generate_adoption_report(self):
        """Generate user adoption report"""
        pass
        
    def generate_performance_report(self):
        """Generate performance metrics report"""
        pass
        
    def generate_compliance_report(self):
        """Generate compliance report"""
        pass
```

## Ansible Playbooks

### Complete Deployment Playbook

#### safeid-deployment.yml
**Purpose**: Complete SafeID environment deployment

```yaml
---
- name: Deploy Dell SafeID Authentication System
  hosts: safeid_servers
  become: yes
  vars:
    safeid_version: "3.0"
    service_account: "{{ vault_service_account }}"
    service_password: "{{ vault_service_password }}"
    database_server: "{{ groups['database'][0] }}"
    
  pre_tasks:
    - name: Validate prerequisites
      include_tasks: tasks/validate_prerequisites.yml
      
  roles:
    - role: common
      tags: [common]
    - role: certificates
      tags: [certificates]
    - role: safeid_installation
      tags: [installation]
    - role: safeid_configuration
      tags: [configuration]
    - role: active_directory_integration
      tags: [ad_integration]
    - role: monitoring
      tags: [monitoring]
      
  post_tasks:
    - name: Verify installation
      include_tasks: tasks/verify_installation.yml
      
    - name: Generate deployment report
      template:
        src: deployment_report.j2
        dest: /tmp/safeid_deployment_report.html
```

### SafeID Installation Role

#### roles/safeid_installation/tasks/main.yml

```yaml
---
- name: Check if SafeID is already installed
  win_service:
    name: DellSafeIDService
  register: safeid_service
  ignore_errors: yes

- name: Download SafeID installer
  win_get_url:
    url: "{{ safeid_installer_url }}"
    dest: "C:\\temp\\SafeID-{{ safeid_version }}.msi"
  when: safeid_service is failed

- name: Install SafeID
  win_package:
    path: "C:\\temp\\SafeID-{{ safeid_version }}.msi"
    product_id: "{{ safeid_product_id }}"
    arguments:
      - INSTALLDIR="C:\Program Files\Dell\SafeID"
      - SERVICEACCOUNT="{{ service_account }}"
      - SERVICEPASSWORD="{{ service_password }}"
      - /quiet
  when: safeid_service is failed

- name: Start SafeID services
  win_service:
    name: "{{ item }}"
    state: started
    start_mode: auto
  loop:
    - DellSafeIDService
    - DellSafeIDBiometric
    - DellSafeIDWeb
```

## Terraform Modules

### Azure SafeID Infrastructure

#### azure/main.tf
**Purpose**: Deploy SafeID infrastructure on Azure

```hcl
# SafeID Infrastructure on Azure

resource "azurerm_resource_group" "safeid" {
  name     = "${var.environment}-safeid-rg"
  location = var.location
  
  tags = {
    Environment = var.environment
    Application = "SafeID"
    Owner       = var.owner
  }
}

resource "azurerm_virtual_network" "safeid" {
  name                = "${var.environment}-safeid-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.safeid.location
  resource_group_name = azurerm_resource_group.safeid.name
  
  tags = azurerm_resource_group.safeid.tags
}

resource "azurerm_subnet" "safeid_servers" {
  name                 = "safeid-servers"
  resource_group_name  = azurerm_resource_group.safeid.name
  virtual_network_name = azurerm_virtual_network.safeid.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "safeid" {
  name                = "${var.environment}-safeid-nsg"
  location            = azurerm_resource_group.safeid.location
  resource_group_name = azurerm_resource_group.safeid.name
  
  security_rule {
    name                       = "SafeID-HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = var.allowed_source_ips
    destination_address_prefix = "*"
  }
}

module "safeid_vm" {
  source = "./modules/safeid_vm"
  
  count = var.server_count
  
  name                = "${var.environment}-safeid-${count.index + 1}"
  resource_group_name = azurerm_resource_group.safeid.name
  location           = azurerm_resource_group.safeid.location
  subnet_id          = azurerm_subnet.safeid_servers.id
  vm_size            = var.vm_size
  
  tags = azurerm_resource_group.safeid.tags
}
```

## Bash Scripts

### Linux Environment Support

#### install_safeid_linux.sh
**Purpose**: SafeID client installation on Linux

```bash
#!/bin/bash
# SafeID Linux Client Installation Script

set -euo pipefail

# Configuration
SAFEID_VERSION="3.0"
INSTALL_DIR="/opt/dell/safeid"
SERVICE_USER="safeid"
LOG_FILE="/var/log/safeid_install.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log "ERROR: This script must be run as root"
        exit 1
    fi
    
    # Check Linux distribution
    if [[ -f /etc/redhat-release ]]; then
        DISTRO="rhel"
        log "Detected RHEL/CentOS distribution"
    elif [[ -f /etc/debian_version ]]; then
        DISTRO="debian"
        log "Detected Debian/Ubuntu distribution"
    else
        log "ERROR: Unsupported Linux distribution"
        exit 1
    fi
    
    # Check available space
    AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=1048576  # 1GB in KB
    
    if [[ $AVAILABLE_SPACE -lt $REQUIRED_SPACE ]]; then
        log "ERROR: Insufficient disk space. Required: 1GB, Available: $((AVAILABLE_SPACE/1024))MB"
        exit 1
    fi
    
    log "Prerequisites check passed"
}

# Install dependencies
install_dependencies() {
    log "Installing dependencies..."
    
    case $DISTRO in
        "rhel")
            yum update -y
            yum install -y openssl curl wget unzip
            ;;
        "debian")
            apt-get update
            apt-get install -y openssl curl wget unzip
            ;;
    esac
    
    log "Dependencies installed successfully"
}

# Create SafeID user
create_service_user() {
    log "Creating SafeID service user..."
    
    if ! id "$SERVICE_USER" &>/dev/null; then
        useradd -r -s /bin/false -d "$INSTALL_DIR" "$SERVICE_USER"
        log "Created service user: $SERVICE_USER"
    else
        log "Service user already exists: $SERVICE_USER"
    fi
}

# Download and install SafeID
install_safeid() {
    log "Downloading SafeID v$SAFEID_VERSION..."
    
    DOWNLOAD_URL="https://downloads.dell.com/safeid/linux/safeid-client-$SAFEID_VERSION.tar.gz"
    TEMP_DIR="/tmp/safeid_install"
    
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    wget "$DOWNLOAD_URL" -O "safeid-client.tar.gz"
    tar -xzf "safeid-client.tar.gz"
    
    log "Installing SafeID..."
    mkdir -p "$INSTALL_DIR"
    cp -r safeid-client-$SAFEID_VERSION/* "$INSTALL_DIR/"
    chown -R "$SERVICE_USER:$SERVICE_USER" "$INSTALL_DIR"
    chmod +x "$INSTALL_DIR/bin/safeid"
    
    log "SafeID installed to $INSTALL_DIR"
}

# Configure system service
configure_service() {
    log "Configuring SafeID service..."
    
    cat > /etc/systemd/system/safeid.service << EOF
[Unit]
Description=Dell SafeID Authentication Client
After=network.target

[Service]
Type=forking
User=$SERVICE_USER
Group=$SERVICE_USER
ExecStart=$INSTALL_DIR/bin/safeid --daemon
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable safeid
    
    log "SafeID service configured"
}

# Main installation function
main() {
    log "Starting SafeID installation..."
    
    check_prerequisites
    install_dependencies
    create_service_user
    install_safeid
    configure_service
    
    log "SafeID installation completed successfully!"
    log "To start the service, run: systemctl start safeid"
    log "To check status, run: systemctl status safeid"
}

# Run main function
main "$@"
```

### Monitoring Script

#### monitor_safeid.sh
**Purpose**: Linux-based SafeID monitoring

```bash
#!/bin/bash
# SafeID Health Monitoring Script for Linux

# Configuration
CONFIG_FILE="/opt/dell/safeid/config/monitor.conf"
LOG_FILE="/var/log/safeid_monitor.log"
ALERT_EMAIL="admin@company.com"
HEALTH_CHECK_URL="https://safeid.company.com:8443/health"

# Source configuration if it exists
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check service status
check_service() {
    log "Checking SafeID service status..."
    
    if systemctl is-active --quiet safeid; then
        log "✓ SafeID service is running"
        return 0
    else
        log "✗ SafeID service is not running"
        return 1
    fi
}

# Check network connectivity
check_connectivity() {
    log "Checking network connectivity..."
    
    if curl -s --max-time 10 "$HEALTH_CHECK_URL" > /dev/null; then
        log "✓ Network connectivity OK"
        return 0
    else
        log "✗ Network connectivity failed"
        return 1
    fi
}

# Check system resources
check_resources() {
    log "Checking system resources..."
    
    # Check CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
        log "⚠ High CPU usage: ${CPU_USAGE}%"
    else
        log "✓ CPU usage normal: ${CPU_USAGE}%"
    fi
    
    # Check memory usage
    MEMORY_USAGE=$(free | grep '^Mem:' | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
        log "⚠ High memory usage: ${MEMORY_USAGE}%"
    else
        log "✓ Memory usage normal: ${MEMORY_USAGE}%"
    fi
    
    # Check disk space
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $DISK_USAGE -gt 80 ]]; then
        log "⚠ High disk usage: ${DISK_USAGE}%"
    else
        log "✓ Disk usage normal: ${DISK_USAGE}%"
    fi
}

# Send alert email
send_alert() {
    local subject="$1"
    local message="$2"
    
    echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
    log "Alert sent: $subject"
}

# Main monitoring function
main() {
    log "Starting SafeID health check..."
    
    local issues=0
    
    if ! check_service; then
        ((issues++))
        send_alert "SafeID Service Alert" "SafeID service is not running on $(hostname)"
    fi
    
    if ! check_connectivity; then
        ((issues++))
        send_alert "SafeID Connectivity Alert" "SafeID connectivity check failed on $(hostname)"
    fi
    
    check_resources
    
    if [[ $issues -eq 0 ]]; then
        log "Health check completed - no issues detected"
    else
        log "Health check completed - $issues issue(s) detected"
    fi
}

# Run main function
main "$@"
```

## Script Usage Guidelines

### Best Practices

1. **Error Handling**
   - Always include comprehensive error handling
   - Log all operations and outcomes
   - Provide meaningful error messages
   - Implement rollback procedures where applicable

2. **Security Considerations**
   - Store sensitive information securely (encrypted or in secure stores)
   - Use least-privilege principles
   - Validate all inputs
   - Audit script executions

3. **Documentation**
   - Include detailed help documentation
   - Provide usage examples
   - Document all parameters and options
   - Maintain version history

4. **Testing**
   - Test scripts in non-production environments first
   - Include parameter validation
   - Test error conditions and edge cases
   - Verify rollback procedures

### Deployment Checklist

- [ ] Scripts are properly documented
- [ ] Error handling is comprehensive
- [ ] Security requirements are met
- [ ] Testing is complete
- [ ] Version control is implemented
- [ ] Execution logs are configured
- [ ] Rollback procedures are defined
- [ ] Support team is trained

---

**Script Library Version**: 1.0  
**Compatible Systems**: Windows Server 2016+, RHEL/CentOS 7+, Ubuntu 18.04+  
**Required Permissions**: Administrative/root access  
**Support**: Contact safeid-support@company.com for assistance
# Dell PowerSwitch Datacenter Automation Scripts

## Overview

This directory contains automation scripts for Dell PowerSwitch datacenter networking deployments. These scripts enable zero-touch provisioning, configuration management, monitoring, and operational automation across the entire fabric.

## Directory Structure

```
scripts/
├── README.md                    # This file
├── ansible/                     # Ansible playbooks and roles
│   ├── playbooks/              # Main automation playbooks
│   ├── roles/                  # Reusable Ansible roles
│   ├── inventory/              # Environment-specific inventories
│   └── group_vars/             # Variable definitions
├── bash/                       # Shell scripts for operations
│   ├── deployment/             # Deployment automation
│   ├── monitoring/             # Monitoring scripts
│   └── maintenance/            # Maintenance automation
├── powershell/                 # PowerShell scripts (Windows integration)
│   ├── deployment/             # Windows-based deployment
│   └── integration/            # System integration scripts
├── python/                     # Python automation scripts
│   ├── configuration/          # Configuration management
│   ├── monitoring/             # Network monitoring
│   ├── reporting/              # Report generation
│   └── utilities/              # Utility functions
└── terraform/                  # Infrastructure as Code
    ├── modules/                # Terraform modules
    ├── environments/           # Environment-specific configs
    └── providers/              # Provider configurations
```

## Script Categories

### Ansible Automation

#### Core Playbooks

**Deployment Playbooks**
- `deploy-fabric.yml` - Complete fabric deployment automation
- `configure-spine.yml` - Spine switch configuration
- `configure-leaf.yml` - Leaf switch configuration  
- `deploy-evpn.yml` - EVPN overlay deployment
- `deploy-security.yml` - Security policy deployment

**Operational Playbooks**
- `backup-configs.yml` - Configuration backup automation
- `update-firmware.yml` - Firmware update orchestration
- `health-check.yml` - Comprehensive health validation
- `performance-test.yml` - Performance testing automation

**Example Ansible Role Structure:**
```yaml
# roles/dell-powerswitch-leaf/tasks/main.yml
---
- name: Configure base system settings
  dellos10_config:
    lines:
      - hostname {{ inventory_hostname }}
      - feature bgp
      - feature evpn
      - feature vxlan

- name: Configure interfaces
  include_tasks: interfaces.yml

- name: Configure BGP EVPN
  include_tasks: bgp-evpn.yml

- name: Configure VLANs and VXLANs
  include_tasks: vxlan.yml
```

#### Inventory Management

**Production Environment Example:**
```yaml
# inventory/production/hosts.yml
all:
  children:
    dell_switches:
      children:
        spine_switches:
          hosts:
            DC1-SP-01:
              ansible_host: 192.168.100.11
              loopback_ip: 10.255.255.1
              bgp_asn: 65100
            DC1-SP-02:
              ansible_host: 192.168.100.12
              loopback_ip: 10.255.255.2
              bgp_asn: 65100
        leaf_switches:
          hosts:
            DC1-LF-01:
              ansible_host: 192.168.100.101
              loopback_ip: 10.255.254.1
              bgp_asn: 65001
            DC1-LF-02:
              ansible_host: 192.168.100.102
              loopback_ip: 10.255.254.2
              bgp_asn: 65002
```

### Python Scripts

#### Configuration Management

**Zero-Touch Provisioning Script:**
```python
#!/usr/bin/env python3
"""
Dell PowerSwitch Zero-Touch Provisioning
Automatically configures switches based on discovery information
"""

import json
import requests
import subprocess
from typing import Dict, Optional

class ZTPManager:
    def __init__(self, config_server: str):
        self.config_server = config_server
        self.device_info = self.get_device_info()
    
    def get_device_info(self) -> Dict:
        """Retrieve device information from system"""
        # Get serial number, model, etc.
        result = subprocess.run(['dmidecode', '-s', 'system-serial-number'], 
                              capture_output=True, text=True)
        serial = result.stdout.strip()
        
        return {
            'serial_number': serial,
            'model': self.get_model(),
            'mac_address': self.get_management_mac()
        }
    
    def download_configuration(self) -> Optional[str]:
        """Download configuration from central server"""
        url = f"{self.config_server}/api/config/{self.device_info['serial_number']}"
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            return response.text
        except requests.RequestException as e:
            print(f"Failed to download configuration: {e}")
            return None
    
    def apply_configuration(self, config: str) -> bool:
        """Apply configuration to switch"""
        try:
            with open('/mnt/flash/startup-config', 'w') as f:
                f.write(config)
            return True
        except Exception as e:
            print(f"Failed to apply configuration: {e}")
            return False
    
    def register_device(self) -> bool:
        """Register device with management system"""
        registration_data = {
            'serial_number': self.device_info['serial_number'],
            'model': self.device_info['model'],
            'mac_address': self.device_info['mac_address'],
            'ip_address': self.get_management_ip(),
            'status': 'configured'
        }
        
        try:
            response = requests.post(
                f"{self.config_server}/api/register",
                json=registration_data,
                timeout=30
            )
            response.raise_for_status()
            return True
        except requests.RequestException as e:
            print(f"Failed to register device: {e}")
            return False

def main():
    """Main ZTP execution"""
    ztp = ZTPManager('http://192.168.100.50')
    
    print("Starting Zero-Touch Provisioning...")
    print(f"Device Info: {ztp.device_info}")
    
    # Download configuration
    config = ztp.download_configuration()
    if not config:
        print("Failed to download configuration")
        return 1
    
    # Apply configuration
    if not ztp.apply_configuration(config):
        print("Failed to apply configuration")
        return 1
    
    # Register with management system
    if not ztp.register_device():
        print("Failed to register device")
        return 1
    
    print("Zero-Touch Provisioning completed successfully")
    return 0

if __name__ == '__main__':
    exit(main())
```

#### Network Monitoring

**Fabric Health Monitor:**
```python
#!/usr/bin/env python3
"""
Dell PowerSwitch Fabric Health Monitor
Monitors fabric health and generates alerts
"""

import asyncio
import aiohttp
import json
from datetime import datetime
from typing import List, Dict

class FabricMonitor:
    def __init__(self, switches: List[Dict]):
        self.switches = switches
        self.alerts = []
    
    async def check_switch_health(self, session: aiohttp.ClientSession, 
                                 switch: Dict) -> Dict:
        """Check individual switch health"""
        try:
            # Use REST API to get switch status
            url = f"https://{switch['ip']}/restconf/data/system/state"
            
            async with session.get(url, ssl=False, auth=aiohttp.BasicAuth(
                switch['username'], switch['password']
            )) as response:
                if response.status == 200:
                    data = await response.json()
                    return self.parse_health_data(switch, data)
                else:
                    return {'switch': switch['name'], 'status': 'unreachable'}
                    
        except Exception as e:
            return {'switch': switch['name'], 'status': 'error', 'error': str(e)}
    
    async def check_bgp_status(self, session: aiohttp.ClientSession,
                              switch: Dict) -> Dict:
        """Check BGP neighbor status"""
        try:
            url = f"https://{switch['ip']}/restconf/data/routing/bgp/neighbors"
            
            async with session.get(url, ssl=False, auth=aiohttp.BasicAuth(
                switch['username'], switch['password']
            )) as response:
                if response.status == 200:
                    data = await response.json()
                    return self.parse_bgp_data(switch, data)
                
        except Exception as e:
            return {'switch': switch['name'], 'bgp_status': 'error'}
    
    def parse_health_data(self, switch: Dict, data: Dict) -> Dict:
        """Parse system health data"""
        return {
            'switch': switch['name'],
            'status': 'healthy' if data.get('uptime', 0) > 0 else 'down',
            'uptime': data.get('uptime', 0),
            'cpu_usage': data.get('cpu_usage', 0),
            'memory_usage': data.get('memory_usage', 0),
            'timestamp': datetime.now().isoformat()
        }
    
    def generate_alert(self, switch: str, alert_type: str, message: str):
        """Generate monitoring alert"""
        alert = {
            'timestamp': datetime.now().isoformat(),
            'switch': switch,
            'type': alert_type,
            'message': message,
            'severity': self.get_alert_severity(alert_type)
        }
        self.alerts.append(alert)
        self.send_alert(alert)
    
    async def monitor_fabric(self):
        """Main monitoring loop"""
        async with aiohttp.ClientSession() as session:
            while True:
                print(f"Checking fabric health at {datetime.now()}")
                
                # Check all switches concurrently
                tasks = []
                for switch in self.switches:
                    tasks.append(self.check_switch_health(session, switch))
                    tasks.append(self.check_bgp_status(session, switch))
                
                results = await asyncio.gather(*tasks, return_exceptions=True)
                
                # Process results and generate alerts
                for result in results:
                    if isinstance(result, dict):
                        self.process_health_result(result)
                
                # Wait before next check
                await asyncio.sleep(60)  # Check every minute

def main():
    """Main monitoring execution"""
    switches = [
        {'name': 'DC1-SP-01', 'ip': '192.168.100.11', 
         'username': 'admin', 'password': 'password'},
        {'name': 'DC1-SP-02', 'ip': '192.168.100.12',
         'username': 'admin', 'password': 'password'},
        # Add more switches...
    ]
    
    monitor = FabricMonitor(switches)
    asyncio.run(monitor.monitor_fabric())

if __name__ == '__main__':
    main()
```

### Bash Scripts

#### Deployment Automation

**Fabric Deployment Script:**
```bash
#!/bin/bash
# Dell PowerSwitch Fabric Deployment Script
# File: bash/deployment/deploy-fabric.sh

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/../../configs"
LOG_FILE="/var/log/fabric-deployment.log"
BACKUP_DIR="/var/backups/fabric"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Prerequisites check
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Ansible is installed
    if ! command -v ansible-playbook &> /dev/null; then
        error_exit "Ansible is not installed"
    fi
    
    # Check if SSH keys are configured
    if [[ ! -f ~/.ssh/id_rsa ]]; then
        error_exit "SSH key not found. Please configure SSH key authentication."
    fi
    
    # Check if configuration files exist
    if [[ ! -d "$CONFIG_DIR" ]]; then
        error_exit "Configuration directory not found: $CONFIG_DIR"
    fi
    
    log "Prerequisites check completed"
}

# Backup existing configurations
backup_configs() {
    log "Backing up existing configurations..."
    
    mkdir -p "$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"
    
    # Run backup playbook
    ansible-playbook "${SCRIPT_DIR}/../ansible/playbooks/backup-configs.yml" \
        -i "${CONFIG_DIR}/inventory/production/hosts.yml" \
        --extra-vars "backup_dir=${BACKUP_DIR}" \
        || error_exit "Configuration backup failed"
    
    log "Configuration backup completed"
}

# Deploy spine switches
deploy_spines() {
    log "Deploying spine switch configurations..."
    
    ansible-playbook "${SCRIPT_DIR}/../ansible/playbooks/configure-spine.yml" \
        -i "${CONFIG_DIR}/inventory/production/hosts.yml" \
        --limit spine_switches \
        || error_exit "Spine deployment failed"
    
    log "Spine deployment completed"
}

# Deploy leaf switches
deploy_leaves() {
    log "Deploying leaf switch configurations..."
    
    ansible-playbook "${SCRIPT_DIR}/../ansible/playbooks/configure-leaf.yml" \
        -i "${CONFIG_DIR}/inventory/production/hosts.yml" \
        --limit leaf_switches \
        || error_exit "Leaf deployment failed"
    
    log "Leaf deployment completed"
}

# Deploy EVPN overlay
deploy_evpn() {
    log "Deploying EVPN overlay configuration..."
    
    ansible-playbook "${SCRIPT_DIR}/../ansible/playbooks/deploy-evpn.yml" \
        -i "${CONFIG_DIR}/inventory/production/hosts.yml" \
        || error_exit "EVPN deployment failed"
    
    log "EVPN deployment completed"
}

# Validate deployment
validate_deployment() {
    log "Validating fabric deployment..."
    
    ansible-playbook "${SCRIPT_DIR}/../ansible/playbooks/validate-fabric.yml" \
        -i "${CONFIG_DIR}/inventory/production/hosts.yml" \
        || error_exit "Fabric validation failed"
    
    log "Fabric validation completed"
}

# Performance testing
run_performance_tests() {
    log "Running performance tests..."
    
    ansible-playbook "${SCRIPT_DIR}/../ansible/playbooks/performance-test.yml" \
        -i "${CONFIG_DIR}/inventory/production/hosts.yml" \
        || error_exit "Performance testing failed"
    
    log "Performance testing completed"
}

# Health check
health_check() {
    log "Performing health check..."
    
    "${SCRIPT_DIR}/monitoring/fabric-health-check.sh" \
        || error_exit "Health check failed"
    
    log "Health check completed"
}

# Main deployment function
main() {
    local start_time=$(date +%s)
    
    log "Starting Dell PowerSwitch fabric deployment"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
    
    # Execute deployment steps
    check_prerequisites
    
    if [[ "${VALIDATE_ONLY:-false}" == "true" ]]; then
        validate_deployment
        exit 0
    fi
    
    if [[ "${SKIP_BACKUP:-false}" != "true" ]]; then
        backup_configs
    fi
    
    deploy_spines
    deploy_leaves
    deploy_evpn
    validate_deployment
    run_performance_tests
    health_check
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log "Fabric deployment completed successfully in ${duration} seconds"
}

# Help function
show_help() {
    cat << EOF
Dell PowerSwitch Fabric Deployment Script

Usage: $0 [OPTIONS]

Options:
    --skip-backup       Skip configuration backup
    --validate-only     Only validate existing deployment
    --help             Show this help message

Examples:
    $0                          # Full deployment with backup
    $0 --skip-backup           # Deploy without backup
    $0 --validate-only         # Validate only
EOF
}

# Execute main function
main "$@"
```

#### Monitoring Scripts

**Fabric Health Check:**
```bash
#!/bin/bash
# Dell PowerSwitch Fabric Health Check
# File: bash/monitoring/fabric-health-check.sh

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="/var/reports/fabric-health"
ALERT_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Create report directory
mkdir -p "$REPORT_DIR"

# Health check functions
check_switch_connectivity() {
    local switch_ip=$1
    local switch_name=$2
    
    if ping -c 3 -W 2 "$switch_ip" > /dev/null 2>&1; then
        echo "✓ $switch_name ($switch_ip) - Reachable"
        return 0
    else
        echo "✗ $switch_name ($switch_ip) - Unreachable"
        return 1
    fi
}

check_bgp_neighbors() {
    local switch_ip=$1
    local switch_name=$2
    
    # Use SSH to check BGP status
    local bgp_status
    bgp_status=$(ssh -o ConnectTimeout=10 -o BatchMode=yes admin@"$switch_ip" \
        "show bgp summary | grep Established | wc -l" 2>/dev/null || echo "0")
    
    if [[ "$bgp_status" -gt 0 ]]; then
        echo "✓ $switch_name - BGP neighbors: $bgp_status established"
        return 0
    else
        echo "✗ $switch_name - No BGP neighbors established"
        return 1
    fi
}

check_interface_status() {
    local switch_ip=$1
    local switch_name=$2
    
    # Check for down interfaces
    local down_interfaces
    down_interfaces=$(ssh -o ConnectTimeout=10 -o BatchMode=yes admin@"$switch_ip" \
        "show interface brief | grep -c 'down'" 2>/dev/null || echo "unknown")
    
    if [[ "$down_interfaces" != "unknown" && "$down_interfaces" -eq 0 ]]; then
        echo "✓ $switch_name - All interfaces up"
        return 0
    else
        echo "⚠ $switch_name - $down_interfaces interfaces down"
        return 1
    fi
}

check_system_resources() {
    local switch_ip=$1
    local switch_name=$2
    
    # Check CPU and memory usage
    local cpu_usage
    local memory_usage
    
    cpu_usage=$(ssh -o ConnectTimeout=10 -o BatchMode=yes admin@"$switch_ip" \
        "show processes cpu | grep 'CPU utilization' | awk '{print \$6}' | sed 's/%//'" \
        2>/dev/null || echo "unknown")
    
    memory_usage=$(ssh -o ConnectTimeout=10 -o BatchMode=yes admin@"$switch_ip" \
        "show processes memory | grep 'Percent used' | awk '{print \$3}' | sed 's/%//'" \
        2>/dev/null || echo "unknown")
    
    local status="✓"
    local message="$switch_name - CPU: ${cpu_usage}%, Memory: ${memory_usage}%"
    
    if [[ "$cpu_usage" != "unknown" && "$cpu_usage" -gt 80 ]]; then
        status="⚠"
        message="$switch_name - HIGH CPU: ${cpu_usage}%, Memory: ${memory_usage}%"
    fi
    
    if [[ "$memory_usage" != "unknown" && "$memory_usage" -gt 80 ]]; then
        status="⚠"
        message="$switch_name - CPU: ${cpu_usage}%, HIGH Memory: ${memory_usage}%"
    fi
    
    echo "$status $message"
    
    if [[ "$status" == "⚠" ]]; then
        return 1
    else
        return 0
    fi
}

generate_report() {
    local report_file="$REPORT_DIR/health-report-$(date +%Y%m%d_%H%M%S).txt"
    
    cat << EOF > "$report_file"
Dell PowerSwitch Fabric Health Report
Generated: $(date)
========================================

CONNECTIVITY CHECKS:
$connectivity_results

BGP NEIGHBOR CHECKS:
$bgp_results

INTERFACE STATUS CHECKS:
$interface_results

SYSTEM RESOURCE CHECKS:
$resource_results

SUMMARY:
Total Checks: $total_checks
Passed: $passed_checks
Failed: $failed_checks
Success Rate: $(( passed_checks * 100 / total_checks ))%
EOF
    
    echo "Health report saved to: $report_file"
    
    # Send alert if there are failures
    if [[ $failed_checks -gt 0 ]]; then
        send_alert "$failed_checks checks failed. See report: $report_file"
    fi
}

send_alert() {
    local message=$1
    
    if [[ -n "$ALERT_WEBHOOK" ]]; then
        curl -s -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 Fabric Health Alert: $message\"}" \
            "$ALERT_WEBHOOK" > /dev/null || true
    fi
}

main() {
    echo "Starting Dell PowerSwitch fabric health check..."
    echo "Timestamp: $(date)"
    echo "=========================================="
    
    # Define switches to check
    local switches=(
        "192.168.100.11:DC1-SP-01"
        "192.168.100.12:DC1-SP-02"
        "192.168.100.101:DC1-LF-01"
        "192.168.100.102:DC1-LF-02"
        "192.168.100.103:DC1-LF-03"
        "192.168.100.104:DC1-LF-04"
    )
    
    local total_checks=0
    local passed_checks=0
    local failed_checks=0
    
    local connectivity_results=""
    local bgp_results=""
    local interface_results=""
    local resource_results=""
    
    echo "CONNECTIVITY CHECKS:"
    for switch in "${switches[@]}"; do
        IFS=':' read -r ip name <<< "$switch"
        result=$(check_switch_connectivity "$ip" "$name")
        echo "$result"
        connectivity_results="$connectivity_results$result\n"
        
        if [[ $result == ✓* ]]; then
            ((passed_checks++))
        else
            ((failed_checks++))
        fi
        ((total_checks++))
    done
    
    echo ""
    echo "BGP NEIGHBOR CHECKS:"
    for switch in "${switches[@]}"; do
        IFS=':' read -r ip name <<< "$switch"
        if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
            result=$(check_bgp_neighbors "$ip" "$name")
            echo "$result"
            bgp_results="$bgp_results$result\n"
            
            if [[ $result == ✓* ]]; then
                ((passed_checks++))
            else
                ((failed_checks++))
            fi
            ((total_checks++))
        fi
    done
    
    echo ""
    echo "INTERFACE STATUS CHECKS:"
    for switch in "${switches[@]}"; do
        IFS=':' read -r ip name <<< "$switch"
        if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
            result=$(check_interface_status "$ip" "$name")
            echo "$result"
            interface_results="$interface_results$result\n"
            
            if [[ $result == ✓* ]]; then
                ((passed_checks++))
            else
                ((failed_checks++))
            fi
            ((total_checks++))
        fi
    done
    
    echo ""
    echo "SYSTEM RESOURCE CHECKS:"
    for switch in "${switches[@]}"; do
        IFS=':' read -r ip name <<< "$switch"
        if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
            result=$(check_system_resources "$ip" "$name")
            echo "$result"
            resource_results="$resource_results$result\n"
            
            if [[ $result == ✓* ]]; then
                ((passed_checks++))
            else
                ((failed_checks++))
            fi
            ((total_checks++))
        fi
    done
    
    echo ""
    echo "SUMMARY:"
    echo "Total Checks: $total_checks"
    echo "Passed: $passed_checks"
    echo "Failed: $failed_checks"
    echo "Success Rate: $(( passed_checks * 100 / total_checks ))%"
    
    # Generate report
    generate_report
    
    # Exit with error if any checks failed
    if [[ $failed_checks -gt 0 ]]; then
        exit 1
    else
        echo "All health checks passed!"
        exit 0
    fi
}

main "$@"
```

### Terraform Infrastructure

#### Main Terraform Module

**Network Infrastructure Module:**
```hcl
# terraform/modules/dell-powerswitch-fabric/main.tf

terraform {
  required_providers {
    dell = {
      source  = "dell/powerswitch"
      version = "~> 1.0"
    }
  }
}

# Variables
variable "fabric_name" {
  description = "Name of the fabric deployment"
  type        = string
}

variable "spine_switches" {
  description = "List of spine switches"
  type = list(object({
    name        = string
    ip_address  = string
    loopback_ip = string
    bgp_asn     = number
  }))
}

variable "leaf_switches" {
  description = "List of leaf switches"
  type = list(object({
    name        = string
    ip_address  = string
    loopback_ip = string
    bgp_asn     = number
    rack_id     = string
  }))
}

variable "vlans" {
  description = "VLAN configuration"
  type = list(object({
    id   = number
    name = string
    vni  = number
  }))
}

# Spine switch configuration
resource "dell_powerswitch_config" "spine" {
  count = length(var.spine_switches)
  
  hostname   = var.spine_switches[count.index].name
  ip_address = var.spine_switches[count.index].ip_address
  
  # Base configuration
  config = templatefile("${path.module}/templates/spine-config.tftpl", {
    hostname    = var.spine_switches[count.index].name
    loopback_ip = var.spine_switches[count.index].loopback_ip
    bgp_asn     = var.spine_switches[count.index].bgp_asn
    leaf_switches = var.leaf_switches
  })
  
  depends_on = [dell_powerswitch_base.spine]
}

# Leaf switch configuration
resource "dell_powerswitch_config" "leaf" {
  count = length(var.leaf_switches)
  
  hostname   = var.leaf_switches[count.index].name
  ip_address = var.leaf_switches[count.index].ip_address
  
  # Base configuration
  config = templatefile("${path.module}/templates/leaf-config.tftpl", {
    hostname    = var.leaf_switches[count.index].name
    loopback_ip = var.leaf_switches[count.index].loopback_ip
    bgp_asn     = var.leaf_switches[count.index].bgp_asn
    spine_switches = var.spine_switches
    vlans       = var.vlans
  })
  
  depends_on = [dell_powerswitch_base.leaf]
}

# EVPN configuration
resource "dell_powerswitch_evpn" "fabric" {
  fabric_name = var.fabric_name
  
  spine_switches = [for s in dell_powerswitch_config.spine : s.hostname]
  leaf_switches  = [for l in dell_powerswitch_config.leaf : l.hostname]
  
  evpn_config = {
    route_distinguisher_format = "auto"
    route_target_format       = "auto"
    address_family            = "l2vpn evpn"
  }
  
  depends_on = [
    dell_powerswitch_config.spine,
    dell_powerswitch_config.leaf
  ]
}

# Outputs
output "fabric_status" {
  description = "Fabric deployment status"
  value = {
    spine_switches = dell_powerswitch_config.spine[*].hostname
    leaf_switches  = dell_powerswitch_config.leaf[*].hostname
    evpn_enabled   = dell_powerswitch_evpn.fabric.enabled
  }
}
```

## Usage Examples

### Quick Start Deployment

**Complete Fabric Deployment:**
```bash
# 1. Clone the repository
git clone https://github.com/company/dell-powerswitch-automation.git
cd dell-powerswitch-automation

# 2. Configure inventory
cp inventory/production/hosts.yml.example inventory/production/hosts.yml
# Edit hosts.yml with your switch information

# 3. Run full deployment
./scripts/bash/deployment/deploy-fabric.sh

# 4. Validate deployment
./scripts/bash/monitoring/fabric-health-check.sh
```

**Individual Component Deployment:**
```bash
# Deploy only spine switches
ansible-playbook scripts/ansible/playbooks/configure-spine.yml \
  -i inventory/production/hosts.yml --limit spine_switches

# Deploy EVPN overlay
ansible-playbook scripts/ansible/playbooks/deploy-evpn.yml \
  -i inventory/production/hosts.yml

# Run health check
ansible-playbook scripts/ansible/playbooks/health-check.yml \
  -i inventory/production/hosts.yml
```

### Monitoring and Maintenance

**Automated Health Monitoring:**
```bash
# Run continuous monitoring
python3 scripts/python/monitoring/fabric_monitor.py

# Generate performance report
python3 scripts/python/reporting/performance_report.py --output weekly

# Backup all configurations
ansible-playbook scripts/ansible/playbooks/backup-configs.yml \
  -i inventory/production/hosts.yml
```

## Best Practices

### Security Considerations

1. **Credential Management**
   - Use Ansible Vault for sensitive data
   - Implement SSH key-based authentication
   - Rotate passwords regularly
   - Use service accounts for automation

2. **Access Control**
   - Limit script execution permissions
   - Use sudo where necessary
   - Implement audit logging
   - Restrict network access to management interfaces

### Error Handling

1. **Robust Error Handling**
   - Check prerequisites before execution
   - Validate inputs and outputs
   - Implement rollback procedures
   - Log all operations and errors

2. **Monitoring and Alerting**
   - Set up health check automation
   - Configure alert thresholds
   - Implement escalation procedures
   - Monitor script execution

### Version Control

1. **Script Management**
   - Version control all automation scripts
   - Use branching for development and testing
   - Implement code review processes
   - Tag stable releases

2. **Configuration Management**
   - Track configuration changes
   - Maintain environment separation
   - Implement approval workflows
   - Backup before changes

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**
   ```bash
   # Check SSH connectivity
   ssh -vvv admin@192.168.100.11
   
   # Test SSH key authentication
   ssh-add -l
   
   # Verify known_hosts
   ssh-keyscan 192.168.100.11 >> ~/.ssh/known_hosts
   ```

2. **Ansible Execution Errors**
   ```bash
   # Run with verbose output
   ansible-playbook playbook.yml -vvv
   
   # Check inventory
   ansible-inventory --list
   
   # Test connectivity
   ansible all -m ping -i inventory/hosts.yml
   ```

3. **API Access Issues**
   ```bash
   # Test REST API access
   curl -k -u admin:password https://192.168.100.11/restconf/data/system/state
   
   # Check API availability
   curl -k -I https://192.168.100.11/restconf/
   ```

---

**Document Information**
- **Version**: 1.0
- **Last Updated**: Current Date
- **Owner**: Network Automation Team
- **Review Cycle**: Monthly
- **Distribution**: Operations Team, Network Engineers

**Support**
- Internal Wiki: [Link to internal documentation]
- Issue Tracking: [Link to issue tracker]
- Team Contact: network-automation@company.com

*These scripts are provided as examples and should be customized for your specific environment. Always test in a non-production environment before deployment.*
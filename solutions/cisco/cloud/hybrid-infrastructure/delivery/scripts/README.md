# Cisco Hybrid Infrastructure Delivery Scripts

## Overview

This directory contains automation scripts and tools for deploying, configuring, and managing the Cisco Hybrid Cloud Infrastructure solution. These scripts are designed to accelerate deployment, ensure consistency, and reduce manual errors.

## Script Categories

### Deployment Scripts
- **cluster-deployment.sh** - Automated HyperFlex cluster deployment
- **vcenter-integration.py** - VMware vCenter integration automation
- **aci-configuration.py** - ACI fabric initial configuration
- **intersight-setup.py** - Intersight account and target registration

### Configuration Scripts
- **apply-templates.sh** - Apply configuration templates
- **security-hardening.sh** - Security policy implementation
- **network-policies.py** - Network policy deployment
- **backup-configuration.sh** - Configuration backup automation

### Monitoring Scripts
- **health-check.sh** - System health validation
- **performance-monitor.py** - Performance data collection
- **capacity-report.py** - Capacity utilization reporting
- **alert-setup.sh** - Monitoring alert configuration

### Maintenance Scripts
- **update-cluster.sh** - Software update automation
- **backup-restore.sh** - Backup and recovery operations
- **certificate-renewal.sh** - Certificate management
- **cleanup-resources.sh** - Resource cleanup and optimization

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Script Descriptions](#script-descriptions)
4. [Usage Examples](#usage-examples)
5. [Configuration Management](#configuration-management)
6. [Error Handling](#error-handling)
7. [Logging and Auditing](#logging-and-auditing)
8. [Best Practices](#best-practices)

## Prerequisites

### System Requirements
- Linux-based management system (RHEL 8+/Ubuntu 20.04+)
- Python 3.8 or higher
- PowerShell Core 7.0+ (for VMware integration)
- Network connectivity to all infrastructure components

### Required Software
```bash
# Install required packages
sudo yum install -y python3 python3-pip git curl wget jq
# or for Ubuntu:
sudo apt update && sudo apt install -y python3 python3-pip git curl wget jq

# Install Python dependencies
pip3 install -r requirements.txt

# Install PowerShell (for VMware scripts)
curl -sSL https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm | sudo rpm -Uvh
sudo yum install -y powershell
```

### Python Dependencies (requirements.txt)
```
requests==2.28.1
urllib3==1.26.12
paramiko==2.11.0
pyvmomi==8.0.0.1
intersight==1.0.19
netaddr==0.8.0
jinja2==3.1.2
pyyaml==6.0
cryptography==38.0.1
ansible==6.4.0
```

### Authentication Setup
```bash
# Create credentials directory
mkdir -p ~/.cisco-hybrid/{credentials,logs,config}

# Set up authentication files (templates)
cp templates/credentials.yaml ~/.cisco-hybrid/credentials/
cp templates/config.yaml ~/.cisco-hybrid/config/

# Secure credentials directory
chmod 700 ~/.cisco-hybrid
chmod 600 ~/.cisco-hybrid/credentials/*
```

## Installation

### Script Installation
```bash
# Clone or copy scripts to management system
sudo mkdir -p /opt/cisco-hybrid-scripts
sudo cp -r scripts/* /opt/cisco-hybrid-scripts/
sudo chown -R $(whoami):$(whoami) /opt/cisco-hybrid-scripts
chmod +x /opt/cisco-hybrid-scripts/*.sh

# Add to PATH
echo 'export PATH=$PATH:/opt/cisco-hybrid-scripts' >> ~/.bashrc
source ~/.bashrc
```

### Configuration
```bash
# Edit configuration files
vim ~/.cisco-hybrid/config/deployment.yaml
vim ~/.cisco-hybrid/credentials/secrets.yaml

# Validate configuration
python3 /opt/cisco-hybrid-scripts/validate-config.py
```

## Script Descriptions

### Deployment Scripts

#### cluster-deployment.sh
**Purpose**: Automated HyperFlex cluster deployment  
**Usage**: `./cluster-deployment.sh -c cluster-config.yaml`

```bash
#!/bin/bash
# HyperFlex cluster deployment automation

set -euo pipefail

CONFIG_FILE=""
LOG_FILE="/var/log/hx-deployment-$(date +%Y%m%d-%H%M%S).log"

usage() {
    echo "Usage: $0 -c <config-file>"
    echo "  -c: Configuration file path (YAML format)"
    echo "  -h: Display this help message"
}

deploy_cluster() {
    local config_file=$1
    
    echo "Starting HyperFlex cluster deployment..." | tee -a $LOG_FILE
    
    # Validate prerequisites
    echo "Validating prerequisites..." | tee -a $LOG_FILE
    python3 validate-prerequisites.py --config $config_file
    
    # Deploy cluster using HyperFlex Connect
    echo "Initiating cluster deployment..." | tee -a $LOG_FILE
    python3 hx-connect-automation.py --config $config_file --deploy
    
    # Validate deployment
    echo "Validating cluster deployment..." | tee -a $LOG_FILE
    ./health-check.sh --cluster-only
    
    echo "Cluster deployment completed successfully!" | tee -a $LOG_FILE
}

# Main execution
while getopts "c:h" opt; do
    case $opt in
        c) CONFIG_FILE=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$CONFIG_FILE" ]; then
    echo "Error: Configuration file required"
    usage
    exit 1
fi

deploy_cluster $CONFIG_FILE
```

#### vcenter-integration.py
**Purpose**: VMware vCenter integration automation  
**Usage**: `python3 vcenter-integration.py --config vcenter.yaml`

```python
#!/usr/bin/env python3
"""
VMware vCenter integration automation script
"""

import argparse
import yaml
import logging
from pyVim.connect import SmartConnect, Disconnect
from pyVmomi import vim
import ssl

class VCenterIntegrator:
    def __init__(self, config):
        self.config = config
        self.service_instance = None
        self.content = None
        
    def connect(self):
        """Connect to vCenter server"""
        try:
            context = ssl.create_default_context()
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
            
            self.service_instance = SmartConnect(
                host=self.config['vcenter']['hostname'],
                user=self.config['vcenter']['username'],
                pwd=self.config['vcenter']['password'],
                sslContext=context
            )
            
            self.content = self.service_instance.RetrieveContent()
            logging.info("Connected to vCenter successfully")
            
        except Exception as e:
            logging.error(f"vCenter connection failed: {e}")
            raise
    
    def create_datacenter(self, datacenter_name):
        """Create datacenter object"""
        try:
            folder = self.content.rootFolder
            datacenter = folder.CreateDatacenter(name=datacenter_name)
            logging.info(f"Created datacenter: {datacenter_name}")
            return datacenter
            
        except Exception as e:
            logging.error(f"Failed to create datacenter: {e}")
            raise
    
    def create_cluster(self, datacenter, cluster_name):
        """Create compute cluster"""
        try:
            cluster_spec = vim.cluster.ConfigSpecEx()
            cluster_spec.drsConfig = vim.cluster.DrsConfigInfo()
            cluster_spec.drsConfig.enabled = True
            cluster_spec.drsConfig.enableVmBehaviorOverrides = True
            cluster_spec.drsConfig.defaultVmBehavior = vim.cluster.DrsConfigInfo.DrsBehavior.manual
            
            cluster_spec.dasConfig = vim.cluster.DasConfigInfo()
            cluster_spec.dasConfig.enabled = True
            cluster_spec.dasConfig.failoverLevel = 1
            
            cluster = datacenter.hostFolder.CreateClusterEx(
                name=cluster_name,
                spec=cluster_spec
            )
            
            logging.info(f"Created cluster: {cluster_name}")
            return cluster
            
        except Exception as e:
            logging.error(f"Failed to create cluster: {e}")
            raise
    
    def add_hosts_to_cluster(self, cluster, hosts):
        """Add ESXi hosts to cluster"""
        for host_config in hosts:
            try:
                host_connect_spec = vim.host.ConnectSpec()
                host_connect_spec.hostName = host_config['hostname']
                host_connect_spec.userName = host_config['username']
                host_connect_spec.password = host_config['password']
                host_connect_spec.force = False
                
                task = cluster.AddHost_Task(
                    spec=host_connect_spec,
                    asConnected=True
                )
                
                # Wait for task completion
                self._wait_for_task(task)
                logging.info(f"Added host: {host_config['hostname']}")
                
            except Exception as e:
                logging.error(f"Failed to add host {host_config['hostname']}: {e}")
                raise
    
    def create_distributed_switch(self, datacenter, switch_config):
        """Create distributed virtual switch"""
        try:
            switch_spec = vim.DistributedVirtualSwitch.CreateSpec()
            switch_spec.configSpec = vim.DistributedVirtualSwitch.ConfigSpec()
            switch_spec.configSpec.name = switch_config['name']
            
            switch_spec.configSpec.uplinkPortPolicy = vim.DistributedVirtualSwitch.NameArrayUplinkPortPolicy()
            switch_spec.configSpec.uplinkPortPolicy.uplinkPortName = switch_config['uplinks']
            
            task = datacenter.networkFolder.CreateDistributedVirtualSwitch_Task(spec=switch_spec)
            self._wait_for_task(task)
            
            logging.info(f"Created distributed switch: {switch_config['name']}")
            
        except Exception as e:
            logging.error(f"Failed to create distributed switch: {e}")
            raise
    
    def _wait_for_task(self, task):
        """Wait for vCenter task completion"""
        while task.info.state not in [vim.TaskInfo.State.success, vim.TaskInfo.State.error]:
            time.sleep(1)
        
        if task.info.state == vim.TaskInfo.State.error:
            raise Exception(f"Task failed: {task.info.error}")
    
    def disconnect(self):
        """Disconnect from vCenter"""
        if self.service_instance:
            Disconnect(self.service_instance)
            logging.info("Disconnected from vCenter")

def main():
    parser = argparse.ArgumentParser(description='vCenter Integration Automation')
    parser.add_argument('--config', required=True, help='Configuration file path')
    args = parser.parse_args()
    
    # Setup logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('/var/log/vcenter-integration.log'),
            logging.StreamHandler()
        ]
    )
    
    # Load configuration
    with open(args.config, 'r') as f:
        config = yaml.safe_load(f)
    
    # Execute integration
    integrator = VCenterIntegrator(config)
    
    try:
        integrator.connect()
        
        # Create datacenter
        datacenter = integrator.create_datacenter(config['datacenter']['name'])
        
        # Create cluster
        cluster = integrator.create_cluster(datacenter, config['cluster']['name'])
        
        # Add hosts
        integrator.add_hosts_to_cluster(cluster, config['hosts'])
        
        # Create distributed switch
        integrator.create_distributed_switch(datacenter, config['distributed_switch'])
        
        logging.info("vCenter integration completed successfully")
        
    except Exception as e:
        logging.error(f"vCenter integration failed: {e}")
        return 1
    finally:
        integrator.disconnect()
    
    return 0

if __name__ == "__main__":
    exit(main())
```

### Monitoring Scripts

#### health-check.sh
**Purpose**: Comprehensive system health validation  
**Usage**: `./health-check.sh --all` or `./health-check.sh --component hyperflex`

```bash
#!/bin/bash
# Comprehensive system health check script

set -euo pipefail

LOG_FILE="/var/log/health-check-$(date +%Y%m%d-%H%M%S).log"
COMPONENTS=("hyperflex" "vmware" "aci" "network")
CHECK_ALL=false
COMPONENT=""
NAGIOS_OUTPUT=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --all              Check all components"
    echo "  --component NAME   Check specific component (hyperflex|vmware|aci|network)"
    echo "  --nagios           Output in Nagios-compatible format"
    echo "  --help             Show this help message"
}

check_hyperflex() {
    echo "=== HyperFlex Health Check ===" | tee -a $LOG_FILE
    
    local status=0
    local output=""
    
    # Cluster status
    if hxcli cluster info &>/dev/null; then
        local cluster_status=$(hxcli cluster info | grep "Cluster Status" | awk '{print $3}')
        if [ "$cluster_status" = "ONLINE" ]; then
            echo "✓ HyperFlex cluster is ONLINE" | tee -a $LOG_FILE
            output="Cluster ONLINE"
        else
            echo "✗ HyperFlex cluster status: $cluster_status" | tee -a $LOG_FILE
            output="Cluster $cluster_status"
            status=2
        fi
    else
        echo "✗ Cannot connect to HyperFlex cluster" | tee -a $LOG_FILE
        output="Connection failed"
        status=2
    fi
    
    # Node status
    local offline_nodes=$(hxcli node list | grep -c "OFFLINE" || true)
    if [ $offline_nodes -eq 0 ]; then
        echo "✓ All nodes are online" | tee -a $LOG_FILE
    else
        echo "⚠ $offline_nodes nodes are offline" | tee -a $LOG_FILE
        status=1
        output="$output, $offline_nodes nodes offline"
    fi
    
    # Storage capacity
    local storage_usage=$(hxcli datastore list | grep "Space Used" | head -1 | awk '{print $3}' | sed 's/%//')
    if [ -n "$storage_usage" ] && [ $storage_usage -lt 85 ]; then
        echo "✓ Storage usage: ${storage_usage}%" | tee -a $LOG_FILE
    elif [ -n "$storage_usage" ] && [ $storage_usage -lt 95 ]; then
        echo "⚠ High storage usage: ${storage_usage}%" | tee -a $LOG_FILE
        status=1
        output="$output, High storage usage"
    else
        echo "✗ Critical storage usage: ${storage_usage}%" | tee -a $LOG_FILE
        status=2
        output="$output, Critical storage usage"
    fi
    
    if [ "$NAGIOS_OUTPUT" = true ]; then
        case $status in
            0) echo "OK - HyperFlex: $output" ;;
            1) echo "WARNING - HyperFlex: $output" ;;
            2) echo "CRITICAL - HyperFlex: $output" ;;
        esac
    fi
    
    return $status
}

check_vmware() {
    echo "=== VMware Health Check ===" | tee -a $LOG_FILE
    
    local status=0
    local output=""
    
    # vCenter connectivity
    if curl -s -k https://vcenter.company.com/ui/ >/dev/null 2>&1; then
        echo "✓ vCenter is accessible" | tee -a $LOG_FILE
        output="vCenter accessible"
    else
        echo "✗ vCenter is not accessible" | tee -a $LOG_FILE
        output="vCenter not accessible"
        status=2
    fi
    
    # ESXi host connectivity (simplified check)
    local esx_hosts=("esx01.company.com" "esx02.company.com" "esx03.company.com")
    local unreachable_hosts=0
    
    for host in "${esx_hosts[@]}"; do
        if ! ping -c 2 "$host" >/dev/null 2>&1; then
            echo "✗ ESXi host $host is unreachable" | tee -a $LOG_FILE
            ((unreachable_hosts++))
        fi
    done
    
    if [ $unreachable_hosts -eq 0 ]; then
        echo "✓ All ESXi hosts are reachable" | tee -a $LOG_FILE
    else
        echo "⚠ $unreachable_hosts ESXi hosts are unreachable" | tee -a $LOG_FILE
        status=1
        output="$output, $unreachable_hosts hosts unreachable"
    fi
    
    if [ "$NAGIOS_OUTPUT" = true ]; then
        case $status in
            0) echo "OK - VMware: $output" ;;
            1) echo "WARNING - VMware: $output" ;;
            2) echo "CRITICAL - VMware: $output" ;;
        esac
    fi
    
    return $status
}

check_aci() {
    echo "=== ACI Health Check ===" | tee -a $LOG_FILE
    
    local status=0
    local output=""
    
    # APIC connectivity
    if curl -s -k https://apic.company.com/api/node/class/topSystem.json >/dev/null 2>&1; then
        echo "✓ APIC is accessible" | tee -a $LOG_FILE
        output="APIC accessible"
    else
        echo "✗ APIC is not accessible" | tee -a $LOG_FILE
        output="APIC not accessible"
        status=2
    fi
    
    if [ "$NAGIOS_OUTPUT" = true ]; then
        case $status in
            0) echo "OK - ACI: $output" ;;
            1) echo "WARNING - ACI: $output" ;;
            2) echo "CRITICAL - ACI: $output" ;;
        esac
    fi
    
    return $status
}

check_network() {
    echo "=== Network Health Check ===" | tee -a $LOG_FILE
    
    local status=0
    local output=""
    
    # DNS resolution
    local dns_targets=("google.com" "cisco.com" "vmware.com")
    local dns_failures=0
    
    for target in "${dns_targets[@]}"; do
        if ! nslookup "$target" >/dev/null 2>&1; then
            ((dns_failures++))
        fi
    done
    
    if [ $dns_failures -eq 0 ]; then
        echo "✓ DNS resolution is working" | tee -a $LOG_FILE
        output="DNS OK"
    else
        echo "⚠ DNS resolution issues detected" | tee -a $LOG_FILE
        output="DNS issues"
        status=1
    fi
    
    # Internet connectivity
    if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
        echo "✓ Internet connectivity is available" | tee -a $LOG_FILE
    else
        echo "⚠ Internet connectivity issues" | tee -a $LOG_FILE
        output="$output, Internet issues"
        status=1
    fi
    
    if [ "$NAGIOS_OUTPUT" = true ]; then
        case $status in
            0) echo "OK - Network: $output" ;;
            1) echo "WARNING - Network: $output" ;;
            2) echo "CRITICAL - Network: $output" ;;
        esac
    fi
    
    return $status
}

main() {
    local overall_status=0
    
    echo "Starting health check at $(date)" | tee -a $LOG_FILE
    
    if [ "$CHECK_ALL" = true ]; then
        for component in "${COMPONENTS[@]}"; do
            if ! check_$component; then
                overall_status=1
            fi
            echo "" | tee -a $LOG_FILE
        done
    elif [ -n "$COMPONENT" ]; then
        if ! check_$COMPONENT; then
            overall_status=1
        fi
    fi
    
    echo "Health check completed at $(date)" | tee -a $LOG_FILE
    echo "Log file: $LOG_FILE"
    
    return $overall_status
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            CHECK_ALL=true
            shift
            ;;
        --component)
            COMPONENT="$2"
            shift 2
            ;;
        --nagios)
            NAGIOS_OUTPUT=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate arguments
if [ "$CHECK_ALL" = false ] && [ -z "$COMPONENT" ]; then
    echo "Error: Must specify --all or --component"
    usage
    exit 1
fi

if [ -n "$COMPONENT" ] && [[ ! " ${COMPONENTS[@]} " =~ " ${COMPONENT} " ]]; then
    echo "Error: Invalid component '$COMPONENT'"
    echo "Valid components: ${COMPONENTS[*]}"
    exit 1
fi

# Execute main function
main
exit $?
```

### Configuration Management

#### Configuration File Templates

**deployment.yaml**
```yaml
# HyperFlex Deployment Configuration
cluster:
  name: "HX-Cluster-Production"
  management_ip: "192.168.100.10"
  
network:
  management_network: "192.168.100.0/24"
  management_gateway: "192.168.100.1"
  dns_servers:
    - "8.8.8.8"
    - "8.8.4.4"
  ntp_servers:
    - "pool.ntp.org"
  
nodes:
  - ip: "192.168.100.11"
    hostname: "hx-node-01"
    role: "controller"
  - ip: "192.168.100.12"
    hostname: "hx-node-02" 
    role: "controller"
  - ip: "192.168.100.13"
    hostname: "hx-node-03"
    role: "compute"
  - ip: "192.168.100.14"
    hostname: "hx-node-04"
    role: "compute"

storage:
  replication_factor: 3
  compression: true
  deduplication: true
  encryption: true

vmware:
  vcenter_ip: "192.168.100.20"
  datacenter_name: "Production-DC"
  cluster_name: "HX-Compute-Cluster"
```

**credentials.yaml** (encrypted)
```yaml
# Encrypted credentials file
hyperflex:
  admin_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    66386439653...
    
vcenter:
  admin_user: "administrator@vsphere.local"
  admin_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    33663136373...

aci:
  apic_user: "admin"
  apic_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    39393632643...
```

## Usage Examples

### Complete Deployment Workflow
```bash
# 1. Validate prerequisites
./validate-prerequisites.sh --config production.yaml

# 2. Deploy HyperFlex cluster
./cluster-deployment.sh --config production.yaml

# 3. Integrate with vCenter
python3 vcenter-integration.py --config production.yaml

# 4. Configure ACI policies
python3 aci-configuration.py --config production.yaml

# 5. Set up monitoring
./monitoring-setup.sh --config production.yaml

# 6. Run comprehensive health check
./health-check.sh --all

# 7. Generate deployment report
python3 generate-report.py --deployment production
```

### Maintenance Operations
```bash
# Daily health check
./health-check.sh --all --nagios

# Weekly capacity report
python3 capacity-report.py --weekly --email admin@company.com

# Monthly backup validation
./backup-restore.sh --validate --config production.yaml

# Quarterly security audit
./security-audit.sh --comprehensive --report quarterly
```

## Error Handling

### Logging Strategy
All scripts implement comprehensive logging:
- **INFO**: Normal operations and success messages
- **WARNING**: Non-critical issues that need attention
- **ERROR**: Critical failures that require immediate action
- **DEBUG**: Detailed troubleshooting information

### Retry Logic
Scripts include automatic retry mechanisms:
```bash
retry_command() {
    local max_attempts=$1
    local delay=$2
    local command="${@:3}"
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if eval "$command"; then
            return 0
        else
            echo "Attempt $attempt failed. Retrying in $delay seconds..."
            sleep $delay
            ((attempt++))
        fi
    done
    
    echo "Command failed after $max_attempts attempts"
    return 1
}

# Usage example
retry_command 3 5 "hxcli cluster info"
```

### Rollback Procedures
Each deployment script includes rollback capabilities:
```bash
rollback_deployment() {
    local checkpoint=$1
    
    echo "Rolling back to checkpoint: $checkpoint"
    
    case $checkpoint in
        "pre-deployment")
            # Remove cluster configuration
            hxcli cluster destroy --force
            ;;
        "pre-vcenter")
            # Remove vCenter integration
            python3 vcenter-cleanup.py
            ;;
        "pre-aci")
            # Remove ACI configuration
            python3 aci-cleanup.py
            ;;
    esac
}
```

## Best Practices

### Security
- Store credentials securely using vault encryption
- Use least-privilege access principles
- Implement audit logging for all operations
- Regular security policy reviews

### Performance
- Use parallel execution where possible
- Implement connection pooling for API calls
- Cache frequently accessed data
- Monitor script execution times

### Reliability
- Implement comprehensive error handling
- Use idempotent operations where possible
- Create checkpoints for rollback capability
- Validate all inputs and prerequisites

### Maintainability
- Use consistent coding standards
- Document all functions and parameters
- Implement version control for scripts
- Regular testing and validation

---

**Scripts Package Version**: 1.0  
**Last Updated**: [Date]  
**Compatibility**: See individual script headers  
**Support**: automation-team@company.com
# Cisco CI/CD Automation Scripts Documentation

## Overview

This directory contains automation scripts, utilities, and tools for the Cisco CI/CD automation solution. These scripts support implementation, operations, monitoring, and maintenance activities across the entire solution lifecycle.

## Directory Structure

```
scripts/
├── README.md                    # This documentation file
├── installation/               # Installation and setup scripts
│   ├── setup-control-node.sh   # Ansible control node setup
│   ├── install-dependencies.sh # Install required packages
│   ├── configure-ssh-keys.sh   # SSH key management
│   └── validate-environment.sh # Environment validation
├── automation/                 # Network automation scripts
│   ├── device-discovery.py     # Automated device discovery
│   ├── config-backup.py        # Configuration backup utility
│   ├── compliance-check.py     # Compliance validation
│   └── bulk-config-deploy.py   # Bulk configuration deployment
├── monitoring/                 # Monitoring and alerting scripts
│   ├── health-check.py          # System health monitoring
│   ├── performance-monitor.py   # Performance metrics collection
│   ├── alert-handler.py         # Alert processing and routing
│   └── report-generator.py      # Automated report generation
├── maintenance/                # Maintenance and operations scripts
│   ├── backup-system.sh         # System backup procedures
│   ├── rotate-logs.sh           # Log rotation and cleanup
│   ├── update-certificates.sh   # Certificate renewal
│   └── cleanup-temp-files.sh    # Temporary file cleanup
├── testing/                    # Testing and validation scripts
│   ├── run-tests.sh             # Test execution wrapper
│   ├── validate-configs.py      # Configuration validation
│   ├── connectivity-test.py     # Network connectivity testing
│   └── load-test.py             # Performance load testing
├── utilities/                  # General utility scripts
│   ├── inventory-generator.py   # Dynamic inventory generation
│   ├── template-validator.py    # Template validation utility
│   ├── credential-manager.py    # Credential management
│   └── data-migration.py        # Data migration utilities
└── examples/                   # Example scripts and templates
    ├── sample-playbook.yml      # Sample Ansible playbook
    ├── example-pipeline.yml     # Example CI/CD pipeline
    └── demo-scripts/            # Demonstration scripts
```

## Installation Scripts

### setup-control-node.sh
**Purpose**: Configure Ansible control node with all required components

**Usage**:
```bash
./installation/setup-control-node.sh [options]
```

**Options**:
- `--os [centos|ubuntu|rhel]` - Target operating system
- `--python-version [3.8|3.9|3.10]` - Python version to install
- `--ansible-version [latest|specific]` - Ansible version
- `--user [username]` - User account for automation

**Example**:
```bash
# Setup on CentOS with Python 3.9
./installation/setup-control-node.sh --os centos --python-version 3.9 --user automation

# Setup with latest versions
./installation/setup-control-node.sh --os ubuntu --ansible-version latest
```

**Features**:
- Installs Python, Ansible, and required libraries
- Configures SSH keys and known hosts
- Sets up directory structure and permissions
- Configures Git and version control
- Installs additional tools (yamllint, ansible-lint)

### install-dependencies.sh
**Purpose**: Install and configure all solution dependencies

**Usage**:
```bash
./installation/install-dependencies.sh --profile [basic|full|development]
```

**Profiles**:
- **basic**: Core components only
- **full**: All production components
- **development**: Development and testing tools

**Components Installed**:
```bash
# Core Components
- Python 3.8+
- Ansible 2.12+
- Git 2.20+
- Docker 20.10+

# Network Tools
- netmiko
- napalm
- ncclient
- pyeapi

# CI/CD Tools
- gitlab-runner
- terraform
- kubectl

# Monitoring Tools
- prometheus-client
- grafana-client
- elasticsearch-client
```

### configure-ssh-keys.sh
**Purpose**: Configure SSH keys for network device access

**Usage**:
```bash
./installation/configure-ssh-keys.sh --generate --deploy --inventory inventory.yml
```

**Features**:
- Generates SSH key pairs for automation
- Deploys public keys to network devices
- Configures SSH client settings
- Validates SSH connectivity
- Creates backup of existing keys

## Automation Scripts

### device-discovery.py
**Purpose**: Automated discovery and inventory of network devices

**Usage**:
```bash
python3 automation/device-discovery.py --network 192.168.1.0/24 --protocol snmp
```

**Features**:
```python
#!/usr/bin/env python3
"""
Network Device Discovery Script
Automatically discovers and catalogs network devices
"""

import argparse
import ipaddress
import concurrent.futures
import json
import yaml
from datetime import datetime
import logging

class NetworkDiscovery:
    def __init__(self, network_range, protocols=['ping', 'snmp', 'ssh']):
        self.network_range = network_range
        self.protocols = protocols
        self.discovered_devices = []
        
    def discover_devices(self):
        """Discover devices in the specified network range"""
        network = ipaddress.IPv4Network(self.network_range, strict=False)
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
            futures = []
            for ip in network.hosts():
                future = executor.submit(self.probe_device, str(ip))
                futures.append(future)
            
            for future in concurrent.futures.as_completed(futures):
                device_info = future.result()
                if device_info:
                    self.discovered_devices.append(device_info)
        
        return self.discovered_devices
    
    def probe_device(self, ip_address):
        """Probe individual device for availability and information"""
        device_info = {
            'ip_address': ip_address,
            'reachable': False,
            'protocols': {},
            'device_info': {},
            'discovery_time': datetime.now().isoformat()
        }
        
        # Ping test
        if 'ping' in self.protocols:
            device_info['reachable'] = self.test_ping(ip_address)
        
        if device_info['reachable']:
            # SNMP discovery
            if 'snmp' in self.protocols:
                snmp_info = self.discover_via_snmp(ip_address)
                device_info['protocols']['snmp'] = snmp_info
                if snmp_info.get('available'):
                    device_info['device_info'].update(snmp_info.get('device_data', {}))
            
            # SSH discovery
            if 'ssh' in self.protocols:
                ssh_info = self.discover_via_ssh(ip_address)
                device_info['protocols']['ssh'] = ssh_info
        
        return device_info if device_info['reachable'] else None
    
    def test_ping(self, ip_address):
        """Test device reachability via ping"""
        import subprocess
        try:
            result = subprocess.run(
                ['ping', '-c', '1', '-W', '2', ip_address],
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except subprocess.TimeoutExpired:
            return False
    
    def discover_via_snmp(self, ip_address):
        """Discover device information via SNMP"""
        try:
            from pysnmp.hlapi import *
            
            for community in ['public', 'private']:  # Add your communities
                try:
                    for (errorIndication, errorStatus, errorIndex, varBinds) in nextCmd(
                        SnmpEngine(),
                        CommunityData(community),
                        UdpTransportTarget((ip_address, 161)),
                        ContextData(),
                        ObjectType(ObjectIdentity('1.3.6.1.2.1.1.1.0')),  # sysDescr
                        lexicographicMode=False,
                        maxRows=1):
                        
                        if errorIndication:
                            break
                        elif errorStatus:
                            break
                        else:
                            sys_descr = str(varBinds[0][1])
                            return {
                                'available': True,
                                'community': community,
                                'device_data': {
                                    'system_description': sys_descr,
                                    'vendor': self.parse_vendor(sys_descr)
                                }
                            }
                except Exception:
                    continue
            
            return {'available': False}
        except ImportError:
            return {'available': False, 'error': 'pysnmp not installed'}
    
    def discover_via_ssh(self, ip_address):
        """Discover device information via SSH"""
        try:
            import paramiko
            
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            try:
                ssh.connect(
                    ip_address,
                    username='admin',  # Configure as needed
                    password='admin',  # Use proper credentials
                    timeout=10,
                    auth_timeout=10
                )
                
                # Try to determine device type
                stdin, stdout, stderr = ssh.exec_command('show version')
                version_output = stdout.read().decode('utf-8')
                
                return {
                    'available': True,
                    'device_type': self.parse_device_type(version_output),
                    'os_version': self.parse_os_version(version_output)
                }
                
            except Exception as e:
                return {'available': False, 'error': str(e)}
            finally:
                ssh.close()
                
        except ImportError:
            return {'available': False, 'error': 'paramiko not installed'}
    
    def parse_vendor(self, sys_descr):
        """Parse vendor information from system description"""
        if 'cisco' in sys_descr.lower():
            return 'Cisco'
        elif 'juniper' in sys_descr.lower():
            return 'Juniper'
        elif 'arista' in sys_descr.lower():
            return 'Arista'
        else:
            return 'Unknown'
    
    def parse_device_type(self, version_output):
        """Parse device type from version output"""
        output_lower = version_output.lower()
        if 'catalyst' in output_lower:
            return 'switch'
        elif 'isr' in output_lower or 'asr' in output_lower:
            return 'router'
        elif 'asa' in output_lower:
            return 'firewall'
        else:
            return 'unknown'
    
    def parse_os_version(self, version_output):
        """Parse OS version from version output"""
        import re
        
        # Look for version patterns
        version_pattern = r'Version\s+([\d\w\.\(\)]+)'
        match = re.search(version_pattern, version_output, re.IGNORECASE)
        
        if match:
            return match.group(1)
        else:
            return 'Unknown'
    
    def generate_inventory(self, format='yaml'):
        """Generate Ansible inventory from discovered devices"""
        inventory = {
            'all': {
                'children': {
                    'cisco_devices': {
                        'children': {
                            'switches': {'hosts': {}},
                            'routers': {'hosts': {}},
                            'firewalls': {'hosts': {}}
                        }
                    }
                }
            }
        }
        
        for device in self.discovered_devices:
            vendor = device['device_info'].get('vendor', 'Unknown')
            device_type = device['protocols'].get('ssh', {}).get('device_type', 'unknown')
            
            if vendor.lower() == 'cisco':
                group_name = f"{device_type}s"
                if group_name in inventory['all']['children']['cisco_devices']['children']:
                    hostname = f"device_{device['ip_address'].replace('.', '_')}"
                    inventory['all']['children']['cisco_devices']['children'][group_name]['hosts'][hostname] = {
                        'ansible_host': device['ip_address'],
                        'device_type': device_type,
                        'vendor': vendor,
                        'discovery_time': device['discovery_time']
                    }
        
        if format == 'yaml':
            return yaml.dump(inventory, default_flow_style=False)
        else:
            return json.dumps(inventory, indent=2)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Network Device Discovery')
    parser.add_argument('--network', required=True, help='Network range to scan (CIDR)')
    parser.add_argument('--protocols', nargs='+', default=['ping', 'snmp', 'ssh'],
                       help='Discovery protocols to use')
    parser.add_argument('--output', choices=['json', 'yaml'], default='yaml',
                       help='Output format')
    parser.add_argument('--inventory-file', help='Save inventory to file')
    
    args = parser.parse_args()
    
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    
    # Run discovery
    discovery = NetworkDiscovery(args.network, args.protocols)
    devices = discovery.discover_devices()
    
    print(f"Discovered {len(devices)} devices in {args.network}")
    
    # Generate and save inventory
    if args.inventory_file:
        inventory_content = discovery.generate_inventory(args.output)
        with open(args.inventory_file, 'w') as f:
            f.write(inventory_content)
        print(f"Inventory saved to {args.inventory_file}")
    
    # Print summary
    for device in devices:
        print(f"Device: {device['ip_address']} - "
              f"Type: {device['device_info'].get('vendor', 'Unknown')} - "
              f"Protocols: {list(device['protocols'].keys())}")
```

### config-backup.py
**Purpose**: Automated configuration backup for network devices

**Usage**:
```bash
python3 automation/config-backup.py --inventory inventory.yml --backup-dir /backups
```

**Features**:
- Supports multiple device types (Cisco IOS, NX-OS, etc.)
- Concurrent backup operations
- Configuration validation and comparison
- Backup encryption and compression
- Integration with version control systems

### compliance-check.py
**Purpose**: Automated compliance validation against security baselines

**Usage**:
```bash
python3 automation/compliance-check.py --baseline cisco-baseline.yml --report-format html
```

## Monitoring Scripts

### health-check.py
**Purpose**: Comprehensive system health monitoring

**Usage**:
```bash
python3 monitoring/health-check.py --components all --alert-threshold critical
```

**Components Monitored**:
- Ansible Automation Platform status
- Database connectivity and performance
- Network device reachability
- CI/CD pipeline health
- System resource utilization

### performance-monitor.py
**Purpose**: Performance metrics collection and analysis

**Usage**:
```bash
python3 monitoring/performance-monitor.py --interval 60 --metrics cpu,memory,network
```

**Metrics Collected**:
- System performance (CPU, memory, disk, network)
- Application performance (response times, throughput)
- Network device performance (utilization, errors)
- Automation job performance (execution times, success rates)

## Maintenance Scripts

### backup-system.sh
**Purpose**: Complete system backup including configurations, data, and logs

**Usage**:
```bash
./maintenance/backup-system.sh --type full --destination /backup/$(date +%Y%m%d)
```

**Backup Components**:
- Ansible configurations and playbooks
- Database backups (PostgreSQL)
- Network device configurations
- System configurations and certificates
- Log files and audit trails

### rotate-logs.sh
**Purpose**: Log rotation and cleanup to manage disk space

**Usage**:
```bash
./maintenance/rotate-logs.sh --max-size 100M --max-age 30d --compress
```

## Testing Scripts

### run-tests.sh
**Purpose**: Comprehensive test execution wrapper

**Usage**:
```bash
./testing/run-tests.sh --suite all --environment test --parallel
```

**Test Suites**:
- **unit**: Unit tests for individual components
- **integration**: Integration tests for component interactions
- **system**: End-to-end system tests
- **performance**: Load and performance tests
- **security**: Security and compliance tests

### validate-configs.py
**Purpose**: Configuration validation and syntax checking

**Usage**:
```bash
python3 testing/validate-configs.py --config-dir configs/ --device-type cisco_ios
```

## Utility Scripts

### inventory-generator.py
**Purpose**: Dynamic Ansible inventory generation from various sources

**Usage**:
```bash
python3 utilities/inventory-generator.py --source dnac --output inventory.yml
```

**Supported Sources**:
- Cisco DNA Center
- CSV files
- Database queries
- CMDB systems
- Cloud platforms (AWS, Azure, GCP)

### template-validator.py
**Purpose**: Jinja2 template validation and testing

**Usage**:
```bash
python3 utilities/template-validator.py --template-dir templates/ --test-vars test-vars.yml
```

## Configuration and Environment Variables

### Environment Variables
```bash
# Ansible Configuration
export ANSIBLE_CONFIG=./ansible.cfg
export ANSIBLE_INVENTORY=./inventories/production/hosts.yml
export ANSIBLE_VAULT_PASSWORD_FILE=./.vault_pass

# Network Device Credentials
export NETWORK_USERNAME=automation
export NETWORK_PASSWORD_FILE=./.network_pass

# CI/CD Integration
export GITLAB_TOKEN=your_gitlab_token
export JENKINS_URL=https://jenkins.company.com
export JENKINS_USER=automation
export JENKINS_TOKEN=your_jenkins_token

# Monitoring Configuration
export PROMETHEUS_URL=http://prometheus:9090
export GRAFANA_URL=http://grafana:3000
export GRAFANA_API_KEY=your_grafana_api_key

# Backup Configuration
export BACKUP_LOCATION=/var/backups/network-automation
export BACKUP_RETENTION_DAYS=90
export BACKUP_ENCRYPTION_KEY_FILE=./backup.key
```

### Configuration Files
```ini
# scripts.conf - Main configuration file
[DEFAULT]
log_level = INFO
log_file = /var/log/network-automation/scripts.log
temp_dir = /tmp/network-automation

[network]
timeout = 30
retry_count = 3
concurrent_operations = 10

[backup]
location = /var/backups/network-automation
retention_days = 90
compression = gzip
encryption = true

[monitoring]
check_interval = 300
alert_threshold = 5
metrics_retention = 30d
```

## Security Considerations

### Credential Management
- Use Ansible Vault for sensitive data
- Store credentials in secure key management systems
- Implement credential rotation procedures
- Use SSH keys instead of passwords where possible

### Access Control
- Implement role-based access control
- Audit script execution and access
- Use dedicated service accounts
- Implement network segmentation

### Logging and Auditing
- Log all script executions and results
- Implement centralized logging
- Monitor for suspicious activities
- Maintain audit trails

## Best Practices

### Script Development
1. **Error Handling**: Implement comprehensive error handling
2. **Logging**: Include detailed logging for troubleshooting
3. **Documentation**: Document all scripts and functions
4. **Testing**: Include unit tests and integration tests
5. **Modularity**: Create reusable functions and modules

### Execution Guidelines
1. **Testing**: Always test scripts in non-production environments
2. **Validation**: Validate inputs and configurations
3. **Rollback**: Implement rollback procedures for critical operations
4. **Monitoring**: Monitor script execution and results
5. **Version Control**: Track script changes in version control

### Performance Optimization
1. **Concurrency**: Use parallel execution where appropriate
2. **Caching**: Implement caching for frequently accessed data
3. **Resource Usage**: Monitor and optimize resource consumption
4. **Batch Operations**: Group operations for efficiency
5. **Connection Pooling**: Reuse connections where possible

## Troubleshooting

### Common Issues and Solutions

#### Script Execution Failures
```bash
# Check script permissions
ls -la script_name.py
chmod +x script_name.py

# Verify Python environment
python3 --version
pip3 list | grep required_package

# Check log files
tail -f /var/log/network-automation/scripts.log
```

#### Network Connectivity Issues
```bash
# Test device connectivity
ping -c 4 device_ip
telnet device_ip 22
ssh -v user@device_ip

# Check DNS resolution
nslookup device_hostname
dig device_hostname
```

#### Permission and Access Issues
```bash
# Check SSH key permissions
ls -la ~/.ssh/
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Verify sudo access
sudo -l
whoami
```

### Support and Maintenance

#### Regular Maintenance Tasks
- Review and update scripts quarterly
- Monitor script performance and optimization opportunities
- Update dependencies and security patches
- Review and update documentation

#### Support Contacts
- **Technical Support**: network-automation-team@company.com
- **Emergency Support**: +1-555-NETWORK (24/7)
- **Documentation Updates**: docs-team@company.com

---

## Script Development Guidelines

### Code Standards
- Follow PEP 8 style guidelines for Python
- Use meaningful variable and function names
- Include docstrings for all functions and classes
- Implement proper exception handling

### Testing Requirements
- Include unit tests for all functions
- Provide integration test scenarios
- Document test data and expected results
- Implement automated testing in CI/CD pipelines

### Documentation Standards
- Include script purpose and usage examples
- Document all command-line arguments
- Provide configuration examples
- Include troubleshooting guides

---

**Document Version:** 1.0  
**Last Updated:** [Date]  
**Maintainer:** Network Automation Team  
**Next Review:** [Date + 3 months]
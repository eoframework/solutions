# Automation Scripts - Cisco Secure Access

## Overview

This directory contains automation scripts and tools for deploying, managing, and maintaining Cisco Secure Access solutions. These scripts are designed to streamline operations, reduce manual errors, and provide consistent deployment practices.

## Script Categories

### Deployment Scripts
- **Environment Setup**: Initial infrastructure preparation
- **Configuration Deployment**: Automated configuration application
- **Integration Scripts**: Third-party system integration
- **Validation Scripts**: Post-deployment verification

### Operations Scripts
- **Health Monitoring**: System health checks and monitoring
- **Backup and Recovery**: Automated backup procedures
- **User Management**: Bulk user provisioning and management
- **Policy Management**: Dynamic policy updates

### Troubleshooting Scripts
- **Log Collection**: Automated log gathering and analysis
- **Diagnostic Tools**: System diagnostics and performance analysis
- **Network Testing**: Connectivity and performance testing
- **Issue Detection**: Proactive issue identification

## Directory Structure

```
scripts/
├── README.md                    # This file
├── deployment/                  # Deployment automation scripts
│   ├── infrastructure-setup.sh
│   ├── ise-deployment.py
│   ├── network-config-deploy.py
│   └── validation-suite.sh
├── operations/                  # Daily operations scripts
│   ├── health-monitor.py
│   ├── backup-automation.py
│   ├── user-provisioning.py
│   └── policy-updates.py
├── troubleshooting/            # Diagnostic and troubleshooting
│   ├── log-collector.py
│   ├── network-diagnostics.sh
│   ├── performance-analyzer.py
│   └── issue-detector.py
├── utilities/                   # Helper utilities and libraries
│   ├── cisco_api_client.py
│   ├── config_templates.py
│   ├── logging_utils.py
│   └── notification_utils.py
└── examples/                    # Usage examples and templates
    ├── sample_configs/
    ├── api_examples/
    └── integration_examples/
```

## Prerequisites

### Python Environment
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Install required packages
pip install -r requirements.txt
```

### Required Python Packages
```txt
requests>=2.28.0
paramiko>=2.11.0
pyyaml>=6.0
jinja2>=3.1.0
netmiko>=4.1.0
cryptography>=37.0.0
pandas>=1.5.0
matplotlib>=3.5.0
```

### System Requirements
- Python 3.8 or higher
- SSH client (for network device access)
- Network connectivity to managed devices
- Appropriate credentials and permissions

## Authentication and Security

### Credential Management
```python
# Use environment variables for sensitive data
import os

ISE_USERNAME = os.environ.get('ISE_USERNAME')
ISE_PASSWORD = os.environ.get('ISE_PASSWORD')
NETWORK_DEVICE_PASSWORD = os.environ.get('NETWORK_PASSWORD')
```

### Environment Variables Setup
```bash
# Create .env file (never commit to version control)
export ISE_USERNAME="admin"
export ISE_PASSWORD="secure_password"
export ASA_USERNAME="admin"
export ASA_PASSWORD="secure_password"
export NETWORK_PASSWORD="device_password"
export UMBRELLA_API_KEY="api_key_here"
export DUO_INTEGRATION_KEY="integration_key"
export DUO_SECRET_KEY="secret_key"
```

## Deployment Scripts

### infrastructure-setup.sh
**Purpose**: Prepare infrastructure for Cisco Secure Access deployment
**Usage**: `./infrastructure-setup.sh --environment prod --validate-only`
**Features**:
- Network connectivity validation
- DNS resolution testing
- Certificate infrastructure verification
- Time synchronization checks
- Prerequisites validation

### ise-deployment.py
**Purpose**: Automated ISE cluster deployment and configuration
**Usage**: `python ise-deployment.py --config deployment_config.yaml`
**Features**:
- ISE node deployment automation
- Certificate installation and configuration
- Active Directory integration setup
- Initial policy configuration
- Cluster formation and synchronization

### network-config-deploy.py
**Purpose**: Deploy network device configurations for 802.1X and VPN
**Usage**: `python network-config-deploy.py --device-list devices.txt --template-dir templates/`
**Features**:
- Switch 802.1X configuration deployment
- Wireless controller configuration
- ASA/FTD VPN configuration
- Configuration backup before changes
- Rollback capability on failure

### validation-suite.sh
**Purpose**: Comprehensive post-deployment validation
**Usage**: `./validation-suite.sh --full-test --report-format html`
**Features**:
- End-to-end authentication testing
- Policy enforcement validation
- Performance baseline establishment
- Security control verification
- Automated test report generation

## Operations Scripts

### health-monitor.py
**Purpose**: Continuous system health monitoring
**Usage**: `python health-monitor.py --daemon --alert-threshold critical`
**Features**:
- Real-time system health checks
- Performance metrics collection
- Automated alert generation
- Dashboard data feeding
- Trend analysis and reporting

### backup-automation.py
**Purpose**: Automated backup of all system components
**Usage**: `python backup-automation.py --full-backup --compress --encrypt`
**Features**:
- ISE configuration and database backup
- Network device configuration backup
- Certificate backup and archival
- Encrypted storage with rotation
- Backup verification and testing

### user-provisioning.py
**Purpose**: Bulk user and device provisioning
**Usage**: `python user-provisioning.py --csv-file new_users.csv --dry-run`
**Features**:
- CSV-based bulk user import
- Active Directory account creation
- ISE endpoint registration
- Policy assignment automation
- Audit trail and logging

### policy-updates.py
**Purpose**: Dynamic policy updates and management
**Usage**: `python policy-updates.py --policy-file updated_policies.json --validate`
**Features**:
- Policy template management
- Automated policy deployment
- Policy validation and testing
- Rollback capability
- Change tracking and approval

## Troubleshooting Scripts

### log-collector.py
**Purpose**: Automated log collection and analysis
**Usage**: `python log-collector.py --timeframe 24h --issue-type authentication --analyze`
**Features**:
- Multi-source log collection (ISE, switches, ASA, etc.)
- Automated log correlation and analysis
- Issue pattern recognition
- Root cause analysis suggestions
- Formatted report generation

### network-diagnostics.sh
**Purpose**: Comprehensive network diagnostics
**Usage**: `./network-diagnostics.sh --target-device switch01 --full-diagnostics`
**Features**:
- Layer 2/3 connectivity testing
- RADIUS authentication simulation
- Certificate validation testing
- Performance and latency analysis
- Network path analysis

### performance-analyzer.py
**Purpose**: System performance analysis and optimization
**Usage**: `python performance-analyzer.py --collect-metrics --duration 1h --optimize`
**Features**:
- Performance metrics collection
- Bottleneck identification
- Capacity planning analysis
- Optimization recommendations
- Historical trend analysis

### issue-detector.py
**Purpose**: Proactive issue detection and alerting
**Usage**: `python issue-detector.py --monitor-mode --ml-analysis`
**Features**:
- Anomaly detection using machine learning
- Predictive failure analysis
- Automated issue classification
- Escalation workflow integration
- False positive reduction

## Utility Libraries

### cisco_api_client.py
**Purpose**: Unified API client for Cisco products
**Features**:
- ISE REST API wrapper
- ASA/FTD API integration
- Umbrella API client
- Error handling and retry logic
- Authentication management

```python
from utilities.cisco_api_client import ISEClient, ASAClient

# ISE API usage example
ise = ISEClient(host='ise-primary.company.com', username='admin', password='password')
active_sessions = ise.get_active_sessions()
user_details = ise.get_user_details('john.doe')

# ASA API usage example
asa = ASAClient(host='asa-primary.company.com', username='admin', password='password')
vpn_sessions = asa.get_vpn_sessions()
interface_stats = asa.get_interface_statistics()
```

### config_templates.py
**Purpose**: Configuration template management
**Features**:
- Jinja2 template engine integration
- Variable substitution
- Template validation
- Multi-vendor support

```python
from utilities.config_templates import ConfigTemplate

template = ConfigTemplate('switch_802dot1x.j2')
config = template.render({
    'radius_servers': ['192.168.1.50', '192.168.1.51'],
    'shared_secret': 'RadiusSecret123!',
    'vlans': {'data': 200, 'voice': 300, 'guest': 400}
})
```

### logging_utils.py
**Purpose**: Centralized logging functionality
**Features**:
- Structured logging
- Multiple output formats (JSON, syslog, file)
- Log rotation and archival
- Performance logging

### notification_utils.py
**Purpose**: Multi-channel notification system
**Features**:
- Email notifications
- Slack/Teams integration
- SMS alerts
- Webhook support
- Escalation workflows

## Usage Examples

### Quick Health Check
```bash
# Perform quick system health check
python operations/health-monitor.py --quick-check --email-report admin@company.com
```

### Deploy New User Batch
```bash
# Deploy new users from CSV file
python operations/user-provisioning.py \
    --csv-file new_employees_2024.csv \
    --email-notification \
    --audit-log \
    --dry-run
```

### Troubleshoot Authentication Issues
```bash
# Collect and analyze authentication logs
python troubleshooting/log-collector.py \
    --issue-type authentication \
    --user john.doe \
    --timeframe 2h \
    --analyze \
    --generate-report
```

### Backup All Systems
```bash
# Perform comprehensive backup
python operations/backup-automation.py \
    --full-backup \
    --encrypt \
    --compress \
    --verify \
    --retention-days 30
```

## Configuration Files

### deployment_config.yaml
```yaml
# ISE Deployment Configuration
ise_deployment:
  primary_node:
    hostname: "ise-primary.company.com"
    ip_address: "192.168.1.50"
    role: "primary"
  
  secondary_node:
    hostname: "ise-secondary.company.com"
    ip_address: "192.168.1.51"
    role: "secondary"
  
  certificates:
    ca_certificate: "certificates/ca-cert.pem"
    server_certificate: "certificates/ise-server.pem"
    private_key: "certificates/ise-server.key"
  
  active_directory:
    domain: "company.com"
    domain_controllers:
      - "dc01.company.com"
      - "dc02.company.com"
    service_account: "svc-ise-ldap"
```

### monitoring_config.yaml
```yaml
# Health Monitoring Configuration
monitoring:
  check_interval: 300  # seconds
  alert_thresholds:
    cpu_usage: 80
    memory_usage: 85
    disk_usage: 90
    response_time: 5000  # milliseconds
  
  notification_channels:
    email:
      enabled: true
      recipients: ["admin@company.com", "network@company.com"]
    slack:
      enabled: true
      webhook_url: "https://hooks.slack.com/services/..."
      channel: "#network-alerts"
    
  components:
    - name: "ISE Primary"
      type: "ise"
      endpoint: "https://ise-primary.company.com:8443"
    - name: "ISE Secondary"
      type: "ise"
      endpoint: "https://ise-secondary.company.com:8443"
    - name: "VPN Gateway"
      type: "asa"
      endpoint: "https://vpn-primary.company.com"
```

## Best Practices

### Script Development Guidelines
1. **Error Handling**: Implement comprehensive error handling and logging
2. **Idempotency**: Scripts should be safe to run multiple times
3. **Validation**: Always validate input parameters and system state
4. **Logging**: Provide detailed logging for troubleshooting
5. **Documentation**: Include inline comments and usage examples
6. **Testing**: Test scripts in lab environment before production use

### Security Considerations
1. **Credentials**: Never hardcode passwords or API keys
2. **Encryption**: Encrypt sensitive data at rest and in transit
3. **Access Control**: Implement proper access controls for script execution
4. **Audit Trail**: Maintain detailed audit logs of all operations
5. **Least Privilege**: Run scripts with minimum required privileges

### Operational Guidelines
1. **Version Control**: Use Git for script version management
2. **Change Management**: Follow change management processes
3. **Backup**: Always backup configurations before making changes
4. **Rollback**: Ensure rollback procedures are available
5. **Monitoring**: Monitor script execution and results

## Support and Maintenance

### Getting Help
- **Documentation**: Refer to inline comments and docstrings
- **Examples**: Check the examples/ directory for usage patterns
- **Logs**: Review script logs for troubleshooting information
- **Community**: Engage with the Cisco community forums

### Contributing
1. Follow coding standards and style guidelines
2. Include comprehensive testing
3. Update documentation for new features
4. Submit pull requests for review

### Maintenance Schedule
- **Weekly**: Review script execution logs and performance
- **Monthly**: Update dependencies and security patches
- **Quarterly**: Review and optimize script performance
- **Annually**: Major version updates and feature enhancements

## Integration Examples

### ServiceNow Integration
```python
# Automated ticket creation for security incidents
from utilities.servicenow_client import ServiceNowClient

def create_security_incident(incident_data):
    snow = ServiceNowClient()
    ticket = snow.create_incident({
        'short_description': 'Security Access Incident',
        'description': incident_data['description'],
        'urgency': incident_data['severity'],
        'assigned_to': 'security-team'
    })
    return ticket['number']
```

### Splunk Integration
```python
# Send logs to Splunk for analysis
from utilities.splunk_client import SplunkClient

def send_to_splunk(event_data):
    splunk = SplunkClient()
    splunk.send_event(
        index='cisco_secure_access',
        source='automation_scripts',
        event=event_data
    )
```

## Performance Optimization

### Script Performance Tips
1. **Parallel Processing**: Use threading for concurrent operations
2. **Caching**: Cache frequently accessed data
3. **Batch Operations**: Group similar operations together
4. **Resource Management**: Properly manage network connections and file handles
5. **Progress Tracking**: Provide progress indication for long-running operations

### Resource Management
```python
# Example of proper resource management
import contextlib

@contextlib.contextmanager
def ise_connection(host, username, password):
    client = ISEClient(host, username, password)
    try:
        client.connect()
        yield client
    finally:
        client.disconnect()

# Usage
with ise_connection('ise-primary.company.com', 'admin', 'password') as ise:
    users = ise.get_active_users()
    # Connection automatically closed
```

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Review Schedule**: Monthly  
**Document Owner**: Cisco Security Automation Team
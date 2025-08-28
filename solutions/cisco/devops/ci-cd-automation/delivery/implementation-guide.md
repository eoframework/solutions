# Cisco CI/CD Automation Implementation Guide

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Implementation Phases](#implementation-phases)
4. [Phase 1: Infrastructure Setup](#phase-1-infrastructure-setup)
5. [Phase 2: Automation Framework](#phase-2-automation-framework)
6. [Phase 3: CI/CD Integration](#phase-3-cicd-integration)
7. [Phase 4: Production Deployment](#phase-4-production-deployment)
8. [Validation and Testing](#validation-and-testing)
9. [Troubleshooting](#troubleshooting)

## Overview

This guide provides step-by-step procedures for implementing Cisco CI/CD automation solutions. The implementation follows a phased approach to ensure systematic deployment and minimize risk to production environments.

### Implementation Objectives

- Establish automated network configuration management
- Implement Infrastructure as Code practices
- Deploy continuous integration and delivery pipelines
- Enable intent-based network automation
- Integrate DevOps practices with network operations

### Success Criteria

- 95% reduction in manual configuration tasks
- 80% faster service provisioning
- 90% automated compliance validation
- Zero-touch deployment capabilities

## Prerequisites

### Technical Requirements

**Infrastructure Components:**
- Cisco DNA Center (version 2.3+)
- Cisco Network Services Orchestrator (NSO 5.8+)
- GitLab or Jenkins CI/CD platform
- Ansible Automation Platform (AAP 2.4+)
- Terraform Enterprise (1.6+)

**Network Devices:**
- Cisco Catalyst 9000 series switches
- Cisco ISR/ASR routers with IOS XE 16.12+
- Cisco Nexus switches (NX-OS 9.3+)
- NETCONF/RESTCONF enabled on all devices

**Compute Resources:**
- Control server: 8 vCPU, 32GB RAM, 500GB storage
- Development environment: 4 vCPU, 16GB RAM, 200GB storage
- Monitoring system: 4 vCPU, 8GB RAM, 1TB storage

### Access Requirements

**Network Access:**
- Management network connectivity to all devices
- SSH access (port 22) to network devices
- HTTPS access (port 443) for RESTCONF
- NETCONF access (port 830) for configuration management

**Credentials:**
- Administrative access to Cisco DNA Center
- Network device administrative credentials
- GitLab/Jenkins administrative access
- Domain administrator privileges for service accounts

### Knowledge Requirements

**Technical Skills:**
- Cisco network configuration and troubleshooting
- Ansible playbook development
- GitLab CI/Jenkins pipeline configuration
- Python scripting for network automation
- YAML and JSON data formats

## Implementation Phases

### Timeline Overview

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1 | 2-4 weeks | Infrastructure setup and basic connectivity |
| Phase 2 | 3-5 weeks | Automation framework and templates |
| Phase 3 | 4-6 weeks | CI/CD pipeline integration |
| Phase 4 | 2-3 weeks | Production deployment and optimization |

## Phase 1: Infrastructure Setup

### Step 1.1: Cisco DNA Center Deployment

**Objective:** Deploy and configure Cisco DNA Center as the central network controller.

**Prerequisites:**
- VMware vSphere 6.7+ or bare metal server
- Network connectivity to management network
- Valid Cisco DNA Center licenses

**Procedure:**

1. **Deploy DNA Center Virtual Appliance**
   ```bash
   # Download DNA Center OVA from Cisco Software Download
   # Deploy using vSphere Client or CLI
   
   # Verify deployment requirements
   vcpu: 56 cores minimum
   memory: 256GB minimum
   storage: 3TB minimum
   network: Management, Enterprise, and Cluster networks
   ```

2. **Initial Configuration**
   ```bash
   # Access DNA Center console
   ssh maglev@<dna-center-ip>
   
   # Run initial setup wizard
   sudo maglev-config setup
   
   # Configure network settings
   sudo maglev-config network
   ```

3. **License Installation**
   ```bash
   # Navigate to Settings > System Settings > Licensing
   # Upload license files
   # Activate DNA Advantage licenses
   ```

4. **Certificate Configuration**
   ```bash
   # Generate certificate signing request
   openssl req -new -newkey rsa:2048 -nodes \
     -keyout dnac.key -out dnac.csr \
     -subj "/C=US/ST=CA/L=San Jose/O=Company/CN=dnac.company.com"
   
   # Install signed certificates in DNA Center
   ```

### Step 1.2: Network Services Orchestrator (NSO) Setup

**Objective:** Deploy NSO for advanced network service orchestration.

1. **NSO Installation**
   ```bash
   # Install NSO on Linux server
   tar xzf nso-5.8.linux.x86_64.signed.bin
   sh nso-5.8.linux.x86_64.installer.bin $HOME/nso-5.8
   
   # Source NSO environment
   source $HOME/nso-5.8/nsorc
   
   # Create NSO instance
   ncs-setup --dest $HOME/nso-run
   cd $HOME/nso-run
   ncs
   ```

2. **Device NEDs Installation**
   ```bash
   # Install Cisco device NEDs
   tar xzf cisco-ios-cli-6.77.tar.gz -C $NCS_DIR/packages/
   tar xzf cisco-iosxr-cli-7.52.tar.gz -C $NCS_DIR/packages/
   tar xzf cisco-nx-cli-5.23.tar.gz -C $NCS_DIR/packages/
   
   # Reload packages
   echo "packages reload" | ncs_cli -C -u admin
   ```

### Step 1.3: Automation Platform Setup

**Objective:** Deploy Ansible Automation Platform for configuration management.

1. **AAP Installation**
   ```bash
   # Download and extract AAP installer
   tar xzf ansible-automation-platform-setup-2.4.tar.gz
   cd ansible-automation-platform-setup-2.4
   
   # Configure inventory file
   cat > inventory << EOF
   [automationcontroller]
   aap-controller.company.com
   
   [database]
   aap-controller.company.com
   
   [all:vars]
   admin_password='StrongPassword123!'
   pg_password='DBPassword123!'
   rabbitmq_password='RabbitPassword123!'
   EOF
   
   # Run installation
   ./setup.sh
   ```

2. **Initial Configuration**
   ```bash
   # Access AAP web interface
   # https://aap-controller.company.com
   
   # Configure organization, users, and teams
   # Import network device inventory
   # Configure credentials and connection settings
   ```

### Step 1.4: Network Device Preparation

**Objective:** Prepare network devices for automation and API access.

1. **Enable Network APIs**
   ```ios
   ! Enable NETCONF and RESTCONF on IOS XE devices
   netconf-yang
   restconf
   
   ! Configure certificate for HTTPS
   crypto pki trustpoint SLA-TrustPoint
    enrollment url http://www.verisign.com/
    subject-name cn=IOS-Self-Signed-Certificate-123456789
    revocation-check crl
   
   ! Generate RSA keys
   crypto key generate rsa general-keys modulus 1024
   
   ! Enable secure HTTP server
   ip http server
   ip http secure-server
   ip http authentication local
   ```

2. **Create Automation User**
   ```ios
   ! Create dedicated user for automation
   username automation privilege 15 secret AutomationPass123!
   username automation autocommand show version
   
   ! Configure AAA
   aaa new-model
   aaa authentication login default local
   aaa authorization exec default local
   ```

3. **Configure Management Interface**
   ```ios
   ! Configure management interface
   interface GigabitEthernet0/0/0
    description Management Interface
    ip address 10.1.1.100 255.255.255.0
    no shutdown
   
   ! Configure default gateway
   ip route 0.0.0.0 0.0.0.0 10.1.1.1
   ```

## Phase 2: Automation Framework

### Step 2.1: Ansible Configuration

**Objective:** Configure Ansible for Cisco network automation.

1. **Ansible Configuration File**
   ```ini
   # /etc/ansible/ansible.cfg
   [defaults]
   inventory = ./inventory/hosts.yml
   host_key_checking = False
   gathering = explicit
   retry_files_enabled = False
   stdout_callback = yaml
   library = ./library
   module_utils = ./module_utils
   roles_path = ./roles
   collections_paths = ./collections
   
   [inventory]
   enable_plugins = host_list, script, auto, yaml, ini, toml
   
   [ssh_connection]
   ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s
   pipelining = True
   ```

2. **Inventory Structure**
   ```yaml
   # inventory/hosts.yml
   all:
     children:
       cisco_switches:
         hosts:
           sw01.company.com:
             ansible_host: 10.1.1.10
             ansible_network_os: ios
             device_type: catalyst9300
           sw02.company.com:
             ansible_host: 10.1.1.11
             ansible_network_os: ios
             device_type: catalyst9300
             
       cisco_routers:
         hosts:
           rtr01.company.com:
             ansible_host: 10.1.1.20
             ansible_network_os: ios
             device_type: isr4000
             
       cisco_nexus:
         hosts:
           nx01.company.com:
             ansible_host: 10.1.1.30
             ansible_network_os: nxos
             device_type: nexus9000
             
     vars:
       ansible_connection: network_cli
       ansible_user: "{{ vault_username }}"
       ansible_password: "{{ vault_password }}"
       ansible_become: yes
       ansible_become_method: enable
       ansible_become_password: "{{ vault_enable_password }}"
   ```

3. **Ansible Vault Configuration**
   ```bash
   # Create encrypted variables file
   ansible-vault create group_vars/all/vault.yml
   
   # Add credentials
   vault_username: automation
   vault_password: AutomationPass123!
   vault_enable_password: EnablePass123!
   vault_snmp_community: public
   ```

### Step 2.2: Terraform Configuration

**Objective:** Implement Infrastructure as Code using Terraform.

1. **Terraform Provider Configuration**
   ```hcl
   # providers.tf
   terraform {
     required_providers {
       cisco = {
         source  = "cisco-open/cisco"
         version = "~> 0.1"
       }
       dnacenter = {
         source  = "cisco-en-programmability/dnacenter"
         version = "~> 1.1"
       }
     }
   }
   
   provider "dnacenter" {
     base_url = var.dnac_base_url
     username = var.dnac_username
     password = var.dnac_password
   }
   ```

2. **Variable Definitions**
   ```hcl
   # variables.tf
   variable "dnac_base_url" {
     description = "DNA Center base URL"
     type        = string
   }
   
   variable "dnac_username" {
     description = "DNA Center username"
     type        = string
   }
   
   variable "dnac_password" {
     description = "DNA Center password"
     type        = string
     sensitive   = true
   }
   
   variable "site_hierarchy" {
     description = "Site hierarchy configuration"
     type = map(object({
       parent_site = string
       site_type   = string
       area        = optional(string)
       building    = optional(string)
       floor       = optional(string)
     }))
   }
   ```

### Step 2.3: Configuration Templates

**Objective:** Create standardized configuration templates.

1. **Base Configuration Template**
   ```jinja2
   {# templates/base-config.j2 #}
   hostname {{ inventory_hostname }}
   ip domain-name {{ domain_name }}
   
   ! Management interface
   interface {{ mgmt_interface }}
    description Management Interface
    ip address {{ ansible_host }} {{ mgmt_netmask }}
    no shutdown
   
   ! Default route
   ip route 0.0.0.0 0.0.0.0 {{ mgmt_gateway }}
   
   ! DNS servers
   {% for dns_server in dns_servers %}
   ip name-server {{ dns_server }}
   {% endfor %}
   
   ! NTP configuration
   {% for ntp_server in ntp_servers %}
   ntp server {{ ntp_server }}
   {% endfor %}
   
   ! SNMP configuration
   snmp-server community {{ snmp_ro_community }} RO
   snmp-server community {{ snmp_rw_community }} RW
   snmp-server location {{ site_location }}
   snmp-server contact {{ site_contact }}
   
   ! Logging
   logging buffered 16384
   logging console warnings
   logging trap notifications
   {% for syslog_server in syslog_servers %}
   logging host {{ syslog_server }}
   {% endfor %}
   ```

2. **Interface Configuration Template**
   ```jinja2
   {# templates/interface-config.j2 #}
   {% for interface in interfaces %}
   interface {{ interface.name }}
    description {{ interface.description | default('Configured by Automation') }}
    {% if interface.type == 'access' %}
    switchport mode access
    switchport access vlan {{ interface.vlan }}
    {% elif interface.type == 'trunk' %}
    switchport mode trunk
    switchport trunk allowed vlan {{ interface.allowed_vlans | join(',') }}
    {% endif %}
    {% if interface.shutdown is defined and interface.shutdown %}
    shutdown
    {% else %}
    no shutdown
    {% endif %}
   {% endfor %}
   ```

## Phase 3: CI/CD Integration

### Step 3.1: Git Repository Structure

**Objective:** Establish version control and repository structure.

1. **Repository Structure**
   ```
   network-automation/
   ├── .gitlab-ci.yml
   ├── ansible.cfg
   ├── requirements.yml
   ├── inventories/
   │   ├── development/
   │   ├── staging/
   │   └── production/
   ├── group_vars/
   ├── host_vars/
   ├── playbooks/
   ├── roles/
   ├── templates/
   ├── terraform/
   └── tests/
   ```

2. **GitLab CI/CD Pipeline**
   ```yaml
   # .gitlab-ci.yml
   stages:
     - validate
     - test
     - deploy
     - verify
   
   variables:
     ANSIBLE_HOST_KEY_CHECKING: "False"
     ANSIBLE_STDOUT_CALLBACK: "yaml"
   
   .ansible_template: &ansible_template
     image: quay.io/ansible/ansible-runner:latest
     before_script:
       - pip install ansible netaddr jmespath
       - ansible-galaxy install -r requirements.yml
   
   validate_syntax:
     <<: *ansible_template
     stage: validate
     script:
       - ansible-playbook --syntax-check playbooks/site.yml
       - ansible-lint playbooks/
     rules:
       - if: $CI_PIPELINE_SOURCE == "merge_request_event"
   
   test_configurations:
     <<: *ansible_template
     stage: test
     script:
       - ansible-playbook --check --diff -i inventories/test/ playbooks/site.yml
     environment:
       name: test
   
   deploy_staging:
     <<: *ansible_template
     stage: deploy
     script:
       - ansible-playbook -i inventories/staging/ playbooks/site.yml
     environment:
       name: staging
     rules:
       - if: $CI_COMMIT_BRANCH == "develop"
   
   deploy_production:
     <<: *ansible_template
     stage: deploy
     script:
       - ansible-playbook -i inventories/production/ playbooks/site.yml
     environment:
       name: production
     when: manual
     rules:
       - if: $CI_COMMIT_BRANCH == "main"
   ```

### Step 3.2: Automated Testing Framework

**Objective:** Implement automated testing for network configurations.

1. **Validation Playbook**
   ```yaml
   # playbooks/validate-network.yml
   ---
   - name: Network Configuration Validation
     hosts: all
     gather_facts: no
     
     tasks:
       - name: Gather device information
         cisco.ios.ios_facts:
           gather_subset:
             - all
         register: device_facts
         
       - name: Validate interface status
         cisco.ios.ios_command:
           commands:
             - show ip interface brief
         register: interface_status
         
       - name: Check routing table
         cisco.ios.ios_command:
           commands:
             - show ip route summary
         register: routing_summary
         
       - name: Validate VLAN configuration
         cisco.ios.ios_command:
           commands:
             - show vlan brief
         register: vlan_config
         when: device_type == "switch"
         
       - name: Generate validation report
         template:
           src: validation-report.j2
           dest: reports/{{ inventory_hostname }}-validation.html
         delegate_to: localhost
   ```

2. **Pytest Integration**
   ```python
   # tests/test_network_connectivity.py
   import pytest
   import paramiko
   import subprocess
   
   def test_device_ssh_connectivity():
       """Test SSH connectivity to network devices"""
       devices = get_inventory_devices()
       
       for device in devices:
           ssh = paramiko.SSHClient()
           ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
           
           try:
               ssh.connect(
                   device['host'], 
                   username=device['username'],
                   password=device['password'],
                   timeout=10
               )
               stdin, stdout, stderr = ssh.exec_command('show version')
               output = stdout.read().decode()
               assert 'Cisco' in output
           finally:
               ssh.close()
   
   def test_ansible_connectivity():
       """Test Ansible connectivity to all devices"""
       result = subprocess.run([
           'ansible', 'all', '-m', 'cisco.ios.ios_command',
           '-a', 'commands="show version"'
       ], capture_output=True, text=True)
       
       assert result.returncode == 0
       assert 'UNREACHABLE' not in result.stdout
   ```

### Step 3.3: Monitoring Integration

**Objective:** Integrate monitoring and alerting for automation processes.

1. **Prometheus Monitoring**
   ```yaml
   # monitoring/prometheus.yml
   global:
     scrape_interval: 15s
   
   scrape_configs:
     - job_name: 'network-devices'
       static_configs:
         - targets:
           - '10.1.1.10:9100'
           - '10.1.1.11:9100'
       scrape_interval: 30s
       
     - job_name: 'ansible-automation'
       static_configs:
         - targets:
           - 'aap-controller:80'
       metrics_path: /api/v2/metrics
   ```

2. **Grafana Dashboard**
   ```json
   {
     "dashboard": {
       "title": "Network Automation Metrics",
       "panels": [
         {
           "title": "Deployment Success Rate",
           "type": "graph",
           "targets": [
             {
               "expr": "rate(ansible_job_success_total[5m])",
               "legendFormat": "Successful Deployments"
             }
           ]
         }
       ]
     }
   }
   ```

## Phase 4: Production Deployment

### Step 4.1: Production Environment Setup

**Objective:** Deploy automation solution to production environment.

1. **Production Checklist**
   - [ ] All test cases passing
   - [ ] Security review completed
   - [ ] Backup procedures validated
   - [ ] Rollback plan documented
   - [ ] Monitoring configured
   - [ ] Team training completed

2. **Gradual Rollout Strategy**
   ```yaml
   # Production deployment phases
   phase_1:
     - description: "Deploy to pilot devices (10%)"
     - devices: ["sw01", "sw02", "rtr01"]
     - validation_time: "24 hours"
   
   phase_2:
     - description: "Deploy to development sites (30%)"
     - sites: ["dev_site_1", "dev_site_2"]
     - validation_time: "48 hours"
   
   phase_3:
     - description: "Full production deployment (100%)"
     - scope: "all_production_devices"
     - validation_time: "72 hours"
   ```

### Step 4.2: Performance Optimization

**Objective:** Optimize automation performance for production scale.

1. **Ansible Performance Tuning**
   ```ini
   # ansible.cfg optimizations
   [defaults]
   forks = 50
   gather_timeout = 10
   timeout = 30
   
   [ssh_connection]
   ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s
   pipelining = True
   control_path = ~/.ansible/cp/%%C
   ```

2. **Parallel Execution Strategy**
   ```yaml
   # playbooks/site.yml
   - name: Network Configuration Deployment
     hosts: all
     strategy: mitogen_free
     serial: "20%"  # Process 20% of devices at a time
     max_fail_percentage: 5
   ```

## Validation and Testing

### Functional Testing

1. **Configuration Validation**
   ```bash
   # Run syntax validation
   ansible-playbook --syntax-check playbooks/site.yml
   
   # Perform dry run
   ansible-playbook --check --diff playbooks/site.yml
   
   # Validate against test environment
   ansible-playbook -i inventories/test/ playbooks/site.yml
   ```

2. **Integration Testing**
   ```python
   # Run integration tests
   pytest tests/integration/ -v
   
   # Generate test reports
   pytest tests/ --html=reports/test-report.html
   ```

### Performance Testing

1. **Load Testing**
   ```bash
   # Test concurrent device management
   ansible-playbook -f 100 playbooks/load-test.yml
   
   # Monitor resource utilization
   top -p $(pgrep -d',' ansible)
   ```

2. **Scalability Testing**
   ```yaml
   # Scale testing configuration
   test_scenarios:
     - devices: 50
       expected_time: "< 5 minutes"
     - devices: 200
       expected_time: "< 15 minutes"
     - devices: 1000
       expected_time: "< 45 minutes"
   ```

## Troubleshooting

### Common Issues and Solutions

1. **SSH Connection Failures**
   ```bash
   # Issue: SSH connection timeout
   # Solution: Verify connectivity and credentials
   ansible all -m ping -vvv
   
   # Check SSH configuration
   ssh -vvv user@device_ip
   ```

2. **NETCONF/RESTCONF Issues**
   ```ios
   ! Verify NETCONF is enabled
   show netconf-yang status
   
   ! Check RESTCONF status
   show platform software yang-management process
   ```

3. **Performance Issues**
   ```bash
   # Monitor Ansible performance
   ansible-playbook --start-at-task="task_name" playbooks/site.yml
   
   # Profile execution time
   time ansible-playbook playbooks/site.yml
   ```

### Logging and Debugging

1. **Enable Detailed Logging**
   ```ini
   # ansible.cfg
   [defaults]
   log_path = ./logs/ansible.log
   stdout_callback = debug
   ```

2. **Debug Mode Execution**
   ```bash
   # Run with maximum verbosity
   ansible-playbook -vvv playbooks/debug.yml
   
   # Debug specific tasks
   ansible-playbook --step playbooks/site.yml
   ```

### Recovery Procedures

1. **Configuration Rollback**
   ```yaml
   - name: Rollback Configuration
     hosts: affected_devices
     tasks:
       - name: Restore previous configuration
         cisco.ios.ios_config:
           src: "backups/{{ inventory_hostname }}-backup.cfg"
           replace: config
   ```

2. **Emergency Procedures**
   ```bash
   # Stop all automation jobs
   ansible-playbook playbooks/emergency-stop.yml
   
   # Restore from backup
   ansible-playbook playbooks/restore-backup.yml
   ```

---

## Next Steps

After successful implementation:

1. **Knowledge Transfer**
   - Conduct team training sessions
   - Document lessons learned
   - Create troubleshooting guides

2. **Continuous Improvement**
   - Monitor automation metrics
   - Gather feedback from operations team
   - Implement process improvements

3. **Expansion Planning**
   - Identify additional use cases
   - Plan for multi-site deployment
   - Consider advanced features

For detailed operational procedures, refer to the [Operations Runbook](operations-runbook.md).

---

**Document Version:** 1.0  
**Last Updated:** [Date]  
**Author:** Network Automation Team
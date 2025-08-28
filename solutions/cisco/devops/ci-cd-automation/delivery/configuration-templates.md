# Cisco CI/CD Automation Configuration Templates

## Overview

This document provides comprehensive configuration templates for implementing Cisco CI/CD automation solutions. These templates cover network device configurations, automation scripts, and integration patterns for DevOps workflows.

## Table of Contents

- [Network Device Templates](#network-device-templates)
- [Automation Framework Templates](#automation-framework-templates)
- [CI/CD Pipeline Templates](#cicd-pipeline-templates)
- [Infrastructure as Code Templates](#infrastructure-as-code-templates)
- [Monitoring and Alerting Templates](#monitoring-and-alerting-templates)

## Network Device Templates

### Cisco IOS XE Base Configuration

```ios
! Base configuration template for Cisco IOS XE devices
! Template variables: {{hostname}}, {{domain}}, {{mgmt_ip}}, {{mgmt_gateway}}

hostname {{hostname}}
ip domain-name {{domain}}

! Management interface configuration
interface GigabitEthernet0/0/0
 description Management Interface
 ip address {{mgmt_ip}} {{mgmt_mask}}
 no shutdown

ip route 0.0.0.0 0.0.0.0 {{mgmt_gateway}}

! Enable NETCONF and RESTCONF
netconf-yang
restconf

! SSH configuration for automation access
ip ssh version 2
ip ssh rsa keypair-name ssh-key
crypto key generate rsa general-keys label ssh-key modulus 2048

! Local user for automation
username automation privilege 15 secret {{automation_password}}
username automation autocommand show version

! AAA configuration
aaa new-model
aaa authentication login default local
aaa authorization exec default local
```

### DNA Center Integration Template

```yaml
# DNA Center device onboarding template
# File: dnac-device-template.yml

dnac_config:
  device_discovery:
    ip_address_list:
      - "{{device_ip}}"
    discovery_type: "SINGLE"
    protocol_order: "ssh"
    timeout: 5
    retry: 3
    
  device_credentials:
    cli_credential:
      username: "{{cli_username}}"
      password: "{{cli_password}}"
      enable_password: "{{enable_password}}"
    
    snmp_v2_read:
      community: "{{snmp_community}}"
    
    http_read:
      username: "{{http_username}}"
      password: "{{http_password}}"
      port: 443
      secure: true

  device_role: "{{device_role}}"
  site_name: "{{site_name}}"
```

## Automation Framework Templates

### Ansible Playbook Template

```yaml
# Cisco network automation playbook template
# File: cisco-network-automation.yml

---
- name: Cisco Network Configuration Automation
  hosts: cisco_devices
  gather_facts: no
  connection: network_cli
  
  vars:
    ansible_network_os: ios
    ansible_user: "{{ vault_username }}"
    ansible_password: "{{ vault_password }}"
    ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p bastion-host"'
    
  tasks:
    - name: Gather device information
      ios_facts:
        gather_subset:
          - all
      tags: facts
      
    - name: Backup current configuration
      ios_config:
        backup: yes
        backup_options:
          filename: "{{ inventory_hostname }}-{{ ansible_date_time.date }}.cfg"
          dir_path: "./backups/"
      tags: backup
      
    - name: Apply configuration template
      ios_config:
        src: "templates/{{ device_type }}_config.j2"
        backup: yes
        match: line
      register: config_result
      tags: configure
      
    - name: Validate configuration changes
      ios_command:
        commands:
          - show running-config
          - show ip interface brief
          - show version
      register: validation_output
      tags: validate
      
    - name: Save configuration
      ios_config:
        save_when: modified
      when: config_result.changed
      tags: save
```

### Python Automation Script Template

```python
#!/usr/bin/env python3
"""
Cisco Network Automation Script Template
Supports NETCONF, REST API, and SSH operations
"""

import requests
import json
import paramiko
from ncclient import manager
from typing import Dict, List, Any
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class CiscoDeviceManager:
    """
    Template class for Cisco device automation
    """
    
    def __init__(self, host: str, username: str, password: str):
        self.host = host
        self.username = username
        self.password = password
        self.session = requests.Session()
        self.session.auth = (username, password)
        self.session.verify = False
        
    def restconf_get(self, path: str) -> Dict[str, Any]:
        """
        GET operation using RESTCONF
        """
        url = f"https://{self.host}/restconf/data/{path}"
        headers = {
            'Accept': 'application/yang-data+json',
            'Content-Type': 'application/yang-data+json'
        }
        
        try:
            response = self.session.get(url, headers=headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"RESTCONF GET failed: {e}")
            raise
            
    def restconf_post(self, path: str, data: Dict[str, Any]) -> bool:
        """
        POST operation using RESTCONF
        """
        url = f"https://{self.host}/restconf/data/{path}"
        headers = {
            'Accept': 'application/yang-data+json',
            'Content-Type': 'application/yang-data+json'
        }
        
        try:
            response = self.session.post(url, headers=headers, json=data)
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"RESTCONF POST failed: {e}")
            return False
            
    def netconf_get_config(self, source='running') -> str:
        """
        Get configuration using NETCONF
        """
        with manager.connect(
            host=self.host,
            port=830,
            username=self.username,
            password=self.password,
            hostkey_verify=False
        ) as m:
            config = m.get_config(source=source).data_xml
            return config
            
    def ssh_command(self, commands: List[str]) -> List[str]:
        """
        Execute commands via SSH
        """
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        try:
            ssh.connect(self.host, username=self.username, password=self.password)
            results = []
            
            for command in commands:
                stdin, stdout, stderr = ssh.exec_command(command)
                output = stdout.read().decode('utf-8')
                results.append(output)
                
            return results
        except Exception as e:
            logger.error(f"SSH command execution failed: {e}")
            raise
        finally:
            ssh.close()

# Example usage
if __name__ == "__main__":
    device = CiscoDeviceManager("{{device_ip}}", "{{username}}", "{{password}}")
    
    # Get device information
    try:
        interfaces = device.restconf_get("ietf-interfaces:interfaces")
        logger.info(f"Retrieved {len(interfaces)} interfaces")
    except Exception as e:
        logger.error(f"Failed to retrieve interfaces: {e}")
```

## CI/CD Pipeline Templates

### Jenkins Pipeline Template

```groovy
// Cisco Network CI/CD Pipeline Template
// File: Jenkinsfile

pipeline {
    agent any
    
    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        VAULT_PASSWORD_FILE = credentials('ansible-vault-password')
        NETWORK_INVENTORY = 'inventories/production/hosts.yml'
    }
    
    parameters {
        choice(
            name: 'DEPLOYMENT_ENVIRONMENT',
            choices: ['development', 'staging', 'production'],
            description: 'Target deployment environment'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: true,
            description: 'Perform dry run without applying changes'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git submodule update --init --recursive'
            }
        }
        
        stage('Validation') {
            parallel {
                stage('Syntax Check') {
                    steps {
                        sh '''
                            ansible-playbook --syntax-check \\
                                -i ${NETWORK_INVENTORY} \\
                                playbooks/site.yml
                        '''
                    }
                }
                
                stage('Lint Check') {
                    steps {
                        sh '''
                            ansible-lint playbooks/
                            yamllint inventories/
                        '''
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        sh '''
                            ansible-playbook \\
                                --vault-password-file=${VAULT_PASSWORD_FILE} \\
                                --check \\
                                -i ${NETWORK_INVENTORY} \\
                                playbooks/security-audit.yml
                        '''
                    }
                }
            }
        }
        
        stage('Test Environment') {
            when {
                expression { params.DEPLOYMENT_ENVIRONMENT != 'production' }
            }
            steps {
                sh '''
                    ansible-playbook \\
                        --vault-password-file=${VAULT_PASSWORD_FILE} \\
                        --check \\
                        -i inventories/${DEPLOYMENT_ENVIRONMENT}/hosts.yml \\
                        playbooks/site.yml
                '''
            }
        }
        
        stage('Deploy') {
            when {
                expression { !params.DRY_RUN }
            }
            steps {
                script {
                    def deployCommand = """
                        ansible-playbook \\
                            --vault-password-file=${VAULT_PASSWORD_FILE} \\
                            -i inventories/${params.DEPLOYMENT_ENVIRONMENT}/hosts.yml \\
                            playbooks/site.yml
                    """
                    
                    if (params.DEPLOYMENT_ENVIRONMENT == 'production') {
                        input message: 'Deploy to production?', ok: 'Deploy'
                    }
                    
                    sh deployCommand
                }
            }
        }
        
        stage('Validation Tests') {
            steps {
                sh '''
                    ansible-playbook \\
                        --vault-password-file=${VAULT_PASSWORD_FILE} \\
                        -i inventories/${DEPLOYMENT_ENVIRONMENT}/hosts.yml \\
                        playbooks/validation-tests.yml
                '''
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'reports/**/*', allowEmptyArchive: true
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'reports',
                reportFiles: 'index.html',
                reportName: 'Network Automation Report'
            ])
        }
        
        failure {
            emailext (
                subject: "Network Deployment Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    Network deployment failed for environment: ${params.DEPLOYMENT_ENVIRONMENT}
                    
                    Build URL: ${env.BUILD_URL}
                    Console Output: ${env.BUILD_URL}console
                    
                    Please review the failure and take corrective action.
                """,
                to: "${env.CHANGE_AUTHOR_EMAIL}, network-team@company.com"
            )
        }
    }
}
```

### GitLab CI Template

```yaml
# GitLab CI/CD Pipeline for Cisco Network Automation
# File: .gitlab-ci.yml

stages:
  - validate
  - test
  - deploy
  - verify

variables:
  ANSIBLE_HOST_KEY_CHECKING: "False"
  ANSIBLE_STDOUT_CALLBACK: "yaml"
  PYTHON_VERSION: "3.9"

.ansible_template: &ansible_template
  image: quay.io/ansible/ansible-runner:latest
  before_script:
    - pip install ansible netaddr jmespath
    - ansible-galaxy install -r requirements.yml
    - echo "$ANSIBLE_VAULT_PASSWORD" > .vault_pass

validate_syntax:
  <<: *ansible_template
  stage: validate
  script:
    - ansible-playbook --syntax-check -i inventories/all.yml playbooks/site.yml
    - ansible-lint playbooks/
    - yamllint inventories/ group_vars/ host_vars/
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

test_network_config:
  <<: *ansible_template
  stage: test
  script:
    - ansible-playbook 
        --vault-password-file=.vault_pass
        --check --diff
        -i inventories/test/hosts.yml 
        playbooks/site.yml
  environment:
    name: test
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"

deploy_staging:
  <<: *ansible_template
  stage: deploy
  script:
    - ansible-playbook 
        --vault-password-file=.vault_pass
        -i inventories/staging/hosts.yml 
        playbooks/site.yml
  environment:
    name: staging
    url: https://staging-network.company.com
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

deploy_production:
  <<: *ansible_template
  stage: deploy
  script:
    - ansible-playbook 
        --vault-password-file=.vault_pass
        -i inventories/production/hosts.yml 
        playbooks/site.yml
  environment:
    name: production
    url: https://network.company.com
  when: manual
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

verify_deployment:
  <<: *ansible_template
  stage: verify
  script:
    - ansible-playbook 
        --vault-password-file=.vault_pass
        -i inventories/production/hosts.yml 
        playbooks/verification.yml
  environment:
    name: production
  dependencies:
    - deploy_production
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Infrastructure as Code Templates

### Terraform Template for Cisco Cloud

```hcl
# Terraform template for Cisco cloud infrastructure
# File: main.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    cisco = {
      source  = "cisco-open/cisco"
      version = "~> 0.1"
    }
  }
  
  backend "s3" {
    bucket = "terraform-state-cisco-network"
    key    = "network-automation/terraform.tfstate"
    region = "us-west-2"
  }
}

# Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for deployment"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "management" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.environment}-mgmt-subnet-${count.index + 1}"
    Type = "management"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Cisco CSR 1000v instances
resource "aws_instance" "csr1000v" {
  count                  = 2
  ami                    = data.aws_ami.csr1000v.id
  instance_type          = "c5.large"
  key_name              = aws_key_pair.network_automation.key_name
  vpc_security_group_ids = [aws_security_group.csr1000v.id]
  subnet_id             = aws_subnet.management[count.index].id
  
  user_data = templatefile("${path.module}/scripts/csr1000v-bootstrap.sh", {
    hostname     = "${var.environment}-csr-${count.index + 1}"
    domain_name  = "network.local"
    admin_user   = "automation"
    admin_pass   = var.admin_password
  })
  
  tags = {
    Name = "${var.environment}-csr1000v-${count.index + 1}"
    Role = "router"
  }
}

# Security Groups
resource "aws_security_group" "csr1000v" {
  name_prefix = "${var.environment}-csr1000v"
  vpc_id      = aws_vpc.main.id
  
  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
  # NETCONF
  ingress {
    from_port   = 830
    to_port     = 830
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
  # HTTPS for RESTCONF
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.environment}-csr1000v-sg"
  }
}

# Outputs
output "csr1000v_management_ips" {
  value = aws_instance.csr1000v[*].private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
```

## Monitoring and Alerting Templates

### Prometheus Configuration Template

```yaml
# Prometheus configuration for Cisco network monitoring
# File: prometheus.yml

global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'cisco-devices'
    static_configs:
      - targets:
        {{#each network_devices}}
        - '{{management_ip}}:9100'
        {{/each}}
    scrape_interval: 30s
    metrics_path: /metrics
    params:
      module: [cisco_snmp]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: snmp-exporter:9116

  - job_name: 'dna-center'
    static_configs:
      - targets:
        - '{{dnac_host}}:443'
    scrape_interval: 60s
    metrics_path: /api/v1/metrics
    scheme: https
    tls_config:
      insecure_skip_verify: true
    basic_auth:
      username: {{dnac_username}}
      password: {{dnac_password}}

  - job_name: 'ansible-automation'
    static_configs:
      - targets:
        - 'ansible-tower:80'
    metrics_path: /api/v2/metrics
    basic_auth:
      username: {{tower_username}}
      password: {{tower_password}}
```

### Grafana Dashboard Template

```json
{
  "dashboard": {
    "id": null,
    "title": "Cisco Network Automation Dashboard",
    "tags": ["cisco", "network", "automation"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Network Device Status",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"cisco-devices\"}",
            "legendFormat": "{{instance}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
        "fieldConfig": {
          "defaults": {
            "color": {"mode": "thresholds"},
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "green", "value": 1}
              ]
            }
          }
        }
      },
      {
        "id": 2,
        "title": "Interface Utilization",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(ifInOctets[5m]) * 8",
            "legendFormat": "{{instance}} - {{ifDescr}} In"
          },
          {
            "expr": "rate(ifOutOctets[5m]) * 8",
            "legendFormat": "{{instance}} - {{ifDescr}} Out"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
        "yAxes": [
          {
            "label": "bits per second",
            "min": 0
          }
        ]
      },
      {
        "id": 3,
        "title": "Automation Job Success Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(ansible_job_success_total[5m])",
            "legendFormat": "Success"
          },
          {
            "expr": "rate(ansible_job_failure_total[5m])",
            "legendFormat": "Failure"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8}
      }
    ]
  }
}
```

## Template Customization Guidelines

### Variable Substitution

All templates use the following variable formats:
- **Ansible Jinja2**: `{{ variable_name }}`
- **Terraform**: `var.variable_name`
- **Handlebars**: `{{variable_name}}`
- **Environment**: `${VARIABLE_NAME}`

### Security Considerations

1. **Credentials Management**
   - Store sensitive data in encrypted vaults
   - Use environment variables for runtime secrets
   - Implement role-based access controls

2. **Network Security**
   - Configure secure protocols (SSH, HTTPS, SNMPv3)
   - Implement certificate-based authentication
   - Use network segmentation and firewalls

3. **Configuration Validation**
   - Implement syntax checking before deployment
   - Use dry-run modes for testing
   - Maintain configuration backups

### Version Control

All configuration templates should be:
- Stored in version control systems
- Tagged with version numbers
- Documented with change logs
- Reviewed through pull requests

---

**Note**: These templates are provided as starting points and should be customized for your specific environment, security requirements, and organizational policies. Always test thoroughly in a non-production environment before deploying to production systems.
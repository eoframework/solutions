---
document_title: Implementation Guide
solution_name: Cisco CI/CD Automation Implementation
document_version: "1.0"
author: "[ARCHITECT]"
last_updated: "[DATE]"
technology_provider: cisco
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This implementation guide provides step-by-step procedures for deploying the Cisco CI/CD Automation solution, integrating Cisco DNA Center, NSO, GitLab, and Ansible to enable network-aware continuous delivery pipelines for 15 development teams and 200+ network devices.

# Prerequisites

This section defines the technical, network, and access requirements for the implementation.

## Technical Requirements

The following software versions and configurations are required for the CI/CD automation platform.

| Requirement | Specification | Validation |
|-------------|--------------|------------|
| Cisco DNA Center | Version 2.3.x or later | API v2 endpoint accessible |
| Cisco NSO | Version 6.0 or later | RESTCONF enabled |
| GitLab Enterprise | Version 16.x or later | CI/CD runners configured |
| Jenkins | Version 2.400+ with Blue Ocean | Network plugins installed |
| Ansible | Version 2.14+ | Cisco collections installed |
| Terraform | Version 1.5+ | Cisco providers configured |
| HashiCorp Vault | Version 1.14+ | AppRole authentication enabled |

## Network Requirements

The following network connectivity is required between automation components.

| Connectivity | Source | Destination | Ports |
|--------------|--------|-------------|-------|
| API Access | GitLab Runners | DNA Center | 443/TCP |
| RESTCONF | Ansible/Terraform | NSO | 8443/TCP |
| Git Operations | Runners | GitLab | 443/TCP |
| Secrets | Pipeline | Vault | 8200/TCP |
| Monitoring | Prometheus | All targets | 9090/TCP |

## Access Requirements

The following accounts and permissions are required for system integration.

| System | Account Type | Permissions Required |
|--------|-------------|---------------------|
| DNA Center | API Service Account | Network Admin role |
| NSO | RESTCONF User | admin group membership |
| GitLab | Service Account | Maintainer on automation repos |
| Vault | AppRole | Read access to cisco/* paths |
| ServiceNow | Integration User | ITIL role, REST API access |

---

# Environment Setup

This section describes the environment configuration required before beginning the infrastructure deployment.

## Network Environment

The CI/CD automation platform requires dedicated network segments for management traffic and API communications between automation tools and network devices.

## Server Environment

The following servers will host the CI/CD automation platform components.

| Server Role | Hostname | IP Address | OS |
|-------------|----------|------------|-----|
| GitLab Enterprise | gitlab.client.local | 10.100.100.10 | RHEL 8 |
| Jenkins Master | jenkins.client.local | 10.100.100.11 | RHEL 8 |
| NSO Server | nso.client.local | 10.100.100.12 | RHEL 8 |
| Vault Cluster | vault.client.local | 10.100.100.20-22 | RHEL 8 |

---

# Infrastructure Deployment

This section provides the step-by-step procedures for deploying the CI/CD automation platform.

## Deployment Overview

Infrastructure deployment follows a dependency-ordered sequence across four layers.

| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | VLAN config, API gateway, load balancer | Prerequisites complete |
| 2 | Security | Vault, certificates, RBAC | Networking |
| 3 | Compute | GitLab runners, NSO, Jenkins | Security platforms |
| 4 | Monitoring | Prometheus, Grafana, Splunk | All platforms |

## Phase 1: Networking Layer

Configure network infrastructure for CI/CD platform connectivity.

### Networking Components

The networking layer configures the following resources:

- VLAN configuration for automation network
- API gateway endpoints for DNA Center and NSO
- Load balancer for GitLab runners
- Firewall rules for platform connectivity

### 1.1 Network Segmentation for CI/CD

#### Create Automation VLAN

```
! DNA Center Template - Automation Network VLAN
vlan 100
 name CICD-Automation
!
interface Vlan100
 description CI/CD Automation Management Network
 ip address 10.100.100.1 255.255.255.0
 no shutdown
```

#### Configure Management Access

| Device Type | Management VLAN | Access Method |
|-------------|-----------------|---------------|
| DNA Center | VLAN 100 | HTTPS (443) |
| NSO Server | VLAN 100 | RESTCONF (8443) |
| GitLab Runners | VLAN 100 | SSH (22), HTTPS (443) |
| Network Devices | VLAN 100 | NETCONF (830) |

### 1.2 API Gateway Configuration

#### DNA Center API Endpoints

| Endpoint | Purpose | Method |
|----------|---------|--------|
| /dna/intent/api/v2/network-device | Device inventory | GET |
| /dna/intent/api/v2/template-programmer/template | Template management | GET/POST |
| /dna/intent/api/v2/network-device-poller/cli/read-request | CLI execution | POST |
| /dna/intent/api/v1/network-device/config | Configuration backup | GET |

#### NSO RESTCONF Configuration

```yaml
# NSO RESTCONF settings
restconf:
  enabled: true
  port: 8443
  ssl:
    cert: /etc/nso/ssl/server.crt
    key: /etc/nso/ssl/server.key
  authentication:
    method: local
    token-auth: true
```

### 1.3 Load Balancer Configuration

#### GitLab Runner Load Balancing

| Parameter | Value |
|-----------|-------|
| VIP Address | 10.100.100.50 |
| Backend Pool | runner-01, runner-02, runner-03, runner-04, runner-05 |
| Health Check | TCP 8093 every 10s |
| Algorithm | Least Connections |

---

## Phase 2: Security Layer

Configure security infrastructure including secrets management and certificates.

### Security Components

The security layer configures the following resources:

- HashiCorp Vault for secrets management
- TLS certificates for platform communications
- RBAC policies for access control
- Branch protection and code signing

### 2.1 Certificate Management

#### Generate Pipeline Certificates

```bash
# Create CA for CI/CD infrastructure
openssl genrsa -out cicd-ca.key 4096
openssl req -x509 -new -nodes -key cicd-ca.key -sha256 -days 1825 \
  -out cicd-ca.crt -subj "/CN=CICD-CA/O=Client/C=US"

# Generate DNA Center API client certificate
openssl genrsa -out dnac-client.key 2048
openssl req -new -key dnac-client.key -out dnac-client.csr \
  -subj "/CN=cicd-pipeline/O=Client/C=US"
openssl x509 -req -in dnac-client.csr -CA cicd-ca.crt -CAkey cicd-ca.key \
  -CAcreateserial -out dnac-client.crt -days 365 -sha256
```

### 2.2 HashiCorp Vault Configuration

#### Enable AppRole Authentication

```bash
# Enable AppRole auth method
vault auth enable approle

# Create policy for CI/CD pipelines
vault policy write cicd-policy - <<EOF
path "secret/data/cisco/*" {
  capabilities = ["read"]
}
path "secret/data/pipeline/*" {
  capabilities = ["read", "create", "update"]
}
EOF

# Create AppRole for pipelines
vault write auth/approle/role/cicd-role \
  token_policies="cicd-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=24h
```

#### Store Network Credentials

```bash
# Store DNA Center credentials
vault kv put secret/cisco/dnac \
  username="api-user" \
  password="<secure-password>" \
  hostname="dnac.client.local"

# Store NSO credentials
vault kv put secret/cisco/nso \
  username="admin" \
  password="<secure-password>" \
  hostname="nso.client.local"

# Store device credentials
vault kv put secret/cisco/devices \
  username="automation" \
  password="<secure-password>" \
  enable_secret="<enable-password>"
```

### 2.3 GitLab Security Configuration

#### Protected Variables

| Variable | Scope | Protected | Masked |
|----------|-------|-----------|--------|
| VAULT_ROLE_ID | All branches | Yes | No |
| VAULT_SECRET_ID | Protected branches | Yes | Yes |
| DNAC_API_TOKEN | Protected branches | Yes | Yes |
| NSO_AUTH_TOKEN | Protected branches | Yes | Yes |

#### Branch Protection Rules

| Branch | Push Access | Merge Access | Approvals Required |
|--------|-------------|--------------|-------------------|
| main | Maintainers | Maintainers | 2 |
| release/* | Maintainers | Maintainers | 2 |
| develop | Developers | Developers | 1 |
| feature/* | Developers | Developers | 1 |

---

## Phase 3: Compute Layer

Deploy compute infrastructure for CI/CD pipeline execution.

### Compute Components

The compute layer configures the following resources:

- GitLab runners for pipeline execution
- Cisco NSO server for network orchestration
- Jenkins agents for build automation
- Container registry for automation images

### 3.1 GitLab Runner Deployment

#### Runner Configuration

```toml
# /etc/gitlab-runner/config.toml
concurrent = 10
check_interval = 0

[[runners]]
  name = "cisco-automation-runner"
  url = "https://gitlab.client.local"
  token = "<runner-token>"
  executor = "docker"

  [runners.docker]
    tls_verify = false
    image = "cisco-automation:latest"
    privileged = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0

  [runners.cache]
    Type = "s3"
    Shared = true
    [runners.cache.s3]
      ServerAddress = "minio.client.local:9000"
      BucketName = "gitlab-cache"
      Insecure = false
```

#### Custom Docker Image

```dockerfile
# Dockerfile for Cisco automation runner
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl wget unzip openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip \
    && unzip terraform_1.5.7_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_1.5.7_linux_amd64.zip

# Install Ansible with Cisco collections
RUN pip install ansible==2.14.* ansible-lint paramiko netaddr jmespath \
    && ansible-galaxy collection install cisco.ios cisco.nxos cisco.asa cisco.dnac

# Install Python SDK for Cisco
RUN pip install dnacentersdk nso-restconf requests hvac

# Set working directory
WORKDIR /automation
```

### 3.2 Cisco NSO Server Deployment

#### NSO Installation

```bash
# Install NSO (assuming package downloaded)
cd /opt
sh nso-6.0.linux.x86_64.installer.bin --local-install ./nso

# Source NSO environment
source /opt/nso/ncsrc

# Create NSO instance
ncs-setup --dest /opt/nso-instance

# Install NED packages
cd /opt/nso-instance/packages
ln -s /opt/nso/packages/neds/cisco-ios-cli-6.90
ln -s /opt/nso/packages/neds/cisco-nx-cli-5.25
ln -s /opt/nso/packages/neds/cisco-asa-cli-6.18

# Start NSO
cd /opt/nso-instance
ncs
```

#### NSO Device Onboarding

```bash
# Add devices to NSO
ncs_cli -u admin << EOF
configure
devices device core-rtr-01
 address 10.100.1.1
 port 22
 authgroup default
 device-type cli ned-id cisco-ios-cli-6.90
 state admin-state unlocked
!
commit
devices device core-rtr-01 sync-from
EOF
```

### 3.3 Jenkins Agent Configuration

#### Jenkins Agent Setup

```groovy
// Jenkins shared library for Cisco automation
// vars/ciscoNetworkDeploy.groovy

def call(Map config) {
    pipeline {
        agent { label 'cisco-automation' }

        environment {
            VAULT_ADDR = 'https://vault.client.local:8200'
            DNAC_HOST = 'dnac.client.local'
            NSO_HOST = 'nso.client.local'
        }

        stages {
            stage('Get Credentials') {
                steps {
                    script {
                        withVault(
                            vaultSecrets: [
                                [path: 'secret/cisco/dnac', secretValues: [
                                    [envVar: 'DNAC_USER', vaultKey: 'username'],
                                    [envVar: 'DNAC_PASS', vaultKey: 'password']
                                ]]
                            ]
                        ) {
                            // Credentials available as environment variables
                        }
                    }
                }
            }

            stage('Network Validation') {
                steps {
                    sh '''
                        ansible-playbook playbooks/validate-network.yml \
                          -e "target_env=${config.environment}"
                    '''
                }
            }

            stage('Network Provisioning') {
                steps {
                    sh '''
                        terraform -chdir=terraform/environments/${config.environment} init
                        terraform -chdir=terraform/environments/${config.environment} apply -auto-approve
                    '''
                }
            }
        }
    }
}
```

---

## Phase 4: Monitoring Layer

Configure monitoring and observability for the CI/CD platform.

### Monitoring Components

The monitoring layer configures the following resources:

- Prometheus for metrics collection
- Grafana for visualization dashboards
- Alertmanager for notification routing
- Splunk for log aggregation

### 4.1 Prometheus Configuration

#### Pipeline Metrics Collection

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'gitlab-runners'
    static_configs:
      - targets:
        - 'runner-01.client.local:9252'
        - 'runner-02.client.local:9252'
        - 'runner-03.client.local:9252'
        - 'runner-04.client.local:9252'
        - 'runner-05.client.local:9252'

  - job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['jenkins.client.local:8080']

  - job_name: 'vault'
    metrics_path: '/v1/sys/metrics'
    params:
      format: ['prometheus']
    bearer_token_file: /etc/prometheus/vault-token
    static_configs:
      - targets: ['vault.client.local:8200']
```

### 4.2 Grafana Dashboard Setup

#### Pipeline Performance Dashboard

```json
{
  "dashboard": {
    "title": "CI/CD Pipeline Performance",
    "panels": [
      {
        "title": "Pipeline Success Rate",
        "type": "gauge",
        "targets": [
          {
            "expr": "sum(gitlab_ci_pipeline_status{status='success'}) / sum(gitlab_ci_pipeline_status) * 100"
          }
        ]
      },
      {
        "title": "Average Pipeline Duration",
        "type": "stat",
        "targets": [
          {
            "expr": "avg(gitlab_ci_pipeline_duration_seconds)"
          }
        ]
      },
      {
        "title": "Network Provisioning Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(network_provision_duration_seconds_bucket[5m])) by (le))"
          }
        ]
      }
    ]
  }
}
```

### 4.3 Alerting Configuration

#### Alert Rules

```yaml
# alerting-rules.yml
groups:
  - name: cicd-alerts
    rules:
      - alert: PipelineFailureRateHigh
        expr: |
          sum(rate(gitlab_ci_pipeline_status{status='failed'}[1h])) /
          sum(rate(gitlab_ci_pipeline_status[1h])) > 0.1
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Pipeline failure rate exceeds 10%"

      - alert: NetworkProvisioningTimeout
        expr: network_provision_duration_seconds > 600
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Network provisioning taking longer than 10 minutes"

      - alert: RunnerQueueBacklog
        expr: gitlab_runner_jobs_pending > 20
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "GitLab runner job queue backlog exceeds 20"
```

### 4.4 Splunk Integration

#### Log Forwarding Configuration

```yaml
# splunk-forwarder inputs.conf
[monitor:///var/log/gitlab-runner/*.log]
disabled = false
index = cicd
sourcetype = gitlab_runner

[monitor:///var/log/jenkins/*.log]
disabled = false
index = cicd
sourcetype = jenkins

[monitor:///var/log/nso/*.log]
disabled = false
index = network
sourcetype = cisco_nso
```

---

# Application Configuration

This section covers the configuration of automation applications and pipeline templates.

### GitLab CI/CD Configuration

Configure GitLab projects with standardized CI/CD pipeline templates for network automation.

### Ansible Configuration

Deploy Ansible collections and configure inventory management for network device automation.

### Terraform Configuration

Configure Terraform providers, backends, and module structure for infrastructure as code.

---

# Integration Testing

This section describes the integration testing procedures for the CI/CD automation platform.

### API Integration Tests

| Integration | Test Method | Success Criteria |
|-------------|-------------|------------------|
| GitLab to DNA Center | Trigger pipeline | API calls succeed |
| Ansible to NSO | Run playbook | Config changes applied |
| Terraform to Vault | Apply plan | Secrets retrieved |

### End-to-End Pipeline Testing

Execute complete pipeline workflows to validate all components work together.

---

# Security Validation

This section covers security validation procedures for the automation platform.

### Authentication Testing

Verify all authentication mechanisms function correctly across integrated systems.

### Authorization Testing

Validate RBAC policies enforce appropriate access controls.

### Secrets Management Testing

Confirm secrets are properly retrieved, used, and not exposed in logs or artifacts.

---

# Migration & Cutover

This section describes the migration approach for transitioning to automated pipelines.

### Migration Phases

| Phase | Teams | Approach |
|-------|-------|----------|
| Pilot | 2 teams | Full automation |
| Wave 1 | 5 teams | Gradual rollout |
| Wave 2 | 8 teams | Full production |

### Cutover Checklist

- All teams onboarded to GitLab
- Pipelines validated in staging
- Rollback procedures tested
- Support team trained

---

# Operational Handover

This section covers the operational handover to the client operations team.

### Handover Documentation

| Document | Description | Location |
|----------|-------------|----------|
| Architecture Guide | System design | Confluence |
| Runbook Library | Operational procedures | GitLab Wiki |
| API Reference | Integration documentation | GitLab Pages |

### Support Transition

Transfer operational responsibilities with defined escalation paths and SLAs.

---

# Training Program

This section describes the training program for client teams.

### Training Schedule

| Audience | Duration | Topics |
|----------|----------|--------|
| Network Engineers | 40 hours | Ansible, NSO, DNA Center APIs |
| DevOps Engineers | 32 hours | GitLab CI, Terraform, Vault |
| Developers | 16 hours | Pipeline usage, self-service portal |
| Operations | 24 hours | Monitoring, troubleshooting, runbooks |

### Training Materials

- Instructor-led workshops
- Hands-on lab exercises
- Video tutorials
- Quick reference guides

---

# Appendices

## Appendix A: Automation Deployment Procedures

### Terraform Module Deployment

#### VLAN Provisioning Module

```hcl
# modules/cisco_vlan/main.tf
terraform {
  required_providers {
    dnacenter = {
      source  = "cisco-en-programmability/dnacenter"
      version = "~> 1.0"
    }
  }
}

variable "vlan_id" {
  type        = number
  description = "VLAN ID to create"
}

variable "vlan_name" {
  type        = string
  description = "VLAN name"
}

variable "site_id" {
  type        = string
  description = "DNA Center site ID"
}

resource "dnacenter_sda_fabric_vlan" "vlan" {
  payload {
    vlan_id   = var.vlan_id
    vlan_name = var.vlan_name
    site_name_hierarchy = var.site_id
  }
}

output "vlan_status" {
  value = dnacenter_sda_fabric_vlan.vlan.item
}
```

### Ansible Playbook Library

#### Device Configuration Playbook

```yaml
# playbooks/configure-device.yml
---
- name: Configure Cisco Network Device
  hosts: "{{ target_devices }}"
  gather_facts: no
  connection: network_cli

  vars:
    ansible_network_os: cisco.ios.ios

  tasks:
    - name: Backup current configuration
      cisco.ios.ios_config:
        backup: yes
        backup_options:
          dir_path: "{{ backup_dir }}/{{ inventory_hostname }}"

    - name: Apply VLAN configuration
      cisco.ios.ios_vlans:
        config:
          - vlan_id: "{{ vlan_id }}"
            name: "{{ vlan_name }}"
            state: active
        state: merged
      register: vlan_result

    - name: Configure interface for VLAN
      cisco.ios.ios_l2_interfaces:
        config:
          - name: "{{ interface }}"
            mode: access
            access:
              vlan: "{{ vlan_id }}"
        state: merged
      when: interface is defined

    - name: Save configuration
      cisco.ios.ios_config:
        save_when: modified
```

### GitLab CI Pipeline Template

#### Standard Pipeline Configuration

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - build
  - network-provision
  - deploy
  - verify

variables:
  TERRAFORM_VERSION: "1.5.7"
  ANSIBLE_VERSION: "2.14"

.vault-auth: &vault-auth
  before_script:
    - export VAULT_TOKEN=$(vault write -field=token auth/approle/login
        role_id=$VAULT_ROLE_ID secret_id=$VAULT_SECRET_ID)

validate:
  stage: validate
  image: cisco-automation:latest
  script:
    - terraform -chdir=terraform validate
    - ansible-lint playbooks/
    - yamllint .

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

network-provision:
  stage: network-provision
  image: cisco-automation:latest
  <<: *vault-auth
  script:
    - |
      export DNAC_USER=$(vault kv get -field=username secret/cisco/dnac)
      export DNAC_PASS=$(vault kv get -field=password secret/cisco/dnac)
    - terraform -chdir=terraform/environments/$CI_ENVIRONMENT_NAME init
    - terraform -chdir=terraform/environments/$CI_ENVIRONMENT_NAME plan -out=tfplan
    - terraform -chdir=terraform/environments/$CI_ENVIRONMENT_NAME apply tfplan
  environment:
    name: $CI_COMMIT_REF_NAME
  only:
    - develop
    - main

deploy:
  stage: deploy
  image: cisco-automation:latest
  script:
    - ansible-playbook playbooks/deploy-application.yml
        -e "app_version=$CI_COMMIT_SHA"
        -e "environment=$CI_ENVIRONMENT_NAME"
  environment:
    name: $CI_COMMIT_REF_NAME

verify:
  stage: verify
  image: cisco-automation:latest
  script:
    - ansible-playbook playbooks/smoke-tests.yml
    - curl -sf https://$APP_URL/health || exit 1
```

---

## Validation and Testing

### Functional Validation Checklist

| Test | Command/Procedure | Expected Result |
|------|-------------------|-----------------|
| DNA Center API | `curl -k https://dnac/dna/system/api/v1/auth/token` | 200 OK with token |
| NSO RESTCONF | `curl -k https://nso:8443/restconf/data` | 200 OK with data |
| GitLab Pipeline | Trigger test pipeline | All stages pass |
| Terraform Plan | `terraform plan` | No errors |
| Ansible Connectivity | `ansible all -m ping` | SUCCESS on all hosts |
| Vault Access | `vault kv get secret/cisco/dnac` | Credentials returned |

### Performance Benchmarks

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| Pipeline Duration | < 15 minutes | GitLab CI metrics |
| Network Provisioning | < 5 minutes | Terraform apply duration |
| API Response Time | < 500ms p95 | Prometheus metrics |
| Concurrent Pipelines | 10+ simultaneous | Load test with parallel jobs |

---

## Operational Runbooks

### Runbook: Pipeline Failure Recovery

```
INCIDENT: Pipeline Failure
SEVERITY: P2

SYMPTOMS:
- Pipeline stage failed
- Network provisioning incomplete
- Deployment blocked

DIAGNOSIS:
1. Check GitLab CI job logs for error messages
2. Verify Vault connectivity: vault status
3. Check DNA Center API: curl -k https://dnac/dna/system/api/v1/auth/token
4. Verify NSO status: ncs --status

RESOLUTION:
1. If Vault issue: Restart Vault service, verify unseal
2. If DNA Center API: Check API rate limits, verify credentials
3. If NSO issue: Check NCS logs, verify device connectivity
4. Retry failed pipeline job

ESCALATION:
- After 30 min: Escalate to DevOps Lead
- After 1 hour: Engage Cisco TAC if platform issue
```

### Runbook: Rollback Procedure

```
PROCEDURE: Emergency Network Rollback
TRIGGER: Production network issue after deployment

STEPS:
1. Identify last known good state
   - Check Terraform state: terraform state list
   - Review NSO rollback points: ncs_cli -u admin -c "show rollback"

2. Execute rollback
   Option A - Terraform:
   $ terraform -chdir=terraform/environments/prod apply -target=<resource> -var="rollback=true"

   Option B - NSO:
   $ ncs_cli -u admin
   > rollback configuration <number>
   > commit

3. Verify network state
   $ ansible-playbook playbooks/verify-network.yml

4. Notify stakeholders
   - Update incident ticket
   - Send Slack notification to #cicd-alerts

VALIDATION:
- All network devices responding
- Application health checks passing
- No error alerts in monitoring
```

---

### Appendix B: Reference Commands

### DNA Center API Examples

```bash
# Get authentication token
TOKEN=$(curl -s -k -X POST \
  "https://dnac.client.local/dna/system/api/v1/auth/token" \
  -H "Authorization: Basic $(echo -n 'user:pass' | base64)" | jq -r '.Token')

# Get device list
curl -s -k -X GET \
  "https://dnac.client.local/dna/intent/api/v2/network-device" \
  -H "X-Auth-Token: $TOKEN" | jq '.response[]'

# Deploy template
curl -s -k -X POST \
  "https://dnac.client.local/dna/intent/api/v2/template-programmer/template/deploy" \
  -H "X-Auth-Token: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"templateId": "xxx", "targetInfo": [{"type": "MANAGED_DEVICE_UUID", "id": "yyy"}]}'
```

### NSO RESTCONF Examples

```bash
# Get device configuration
curl -s -k -u admin:password \
  "https://nso.client.local:8443/restconf/data/devices/device=core-rtr-01/config" \
  -H "Accept: application/yang-data+json"

# Push configuration change
curl -s -k -u admin:password -X PATCH \
  "https://nso.client.local:8443/restconf/data/devices/device=core-rtr-01/config" \
  -H "Content-Type: application/yang-data+json" \
  -d '{"tailf-ned-cisco-ios:interface": {"Loopback": [{"name": "100", "ip": {"address": {"primary": {"address": "10.0.0.1", "mask": "255.255.255.255"}}}}]}}'
```

# IBM Ansible Automation Platform - Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing IBM Ansible Automation Platform on Red Hat OpenShift, covering pre-deployment planning through post-deployment optimization.

## Prerequisites

### Infrastructure Requirements
- Red Hat OpenShift Container Platform 4.10 or later
- Minimum 3 worker nodes (4 vCPU, 16GB RAM each)
- Persistent storage with RWX support (minimum 200GB)
- Load balancer for external access
- Valid IBM Ansible Automation Platform subscription

### Access Requirements
- OpenShift cluster administrator privileges
- IBM Ansible Automation Platform operator access
- Valid Red Hat subscription credentials
- Network access to OpenShift cluster

### Tools Required
- OpenShift CLI (oc) 4.10+
- Ansible 2.14+
- kubectl
- helm
- curl, jq, git

## Pre-Deployment Planning

### 1. Capacity Planning
```bash
# Calculate required resources
# Controller: 4 vCPU, 16GB RAM per replica (3 replicas = 12 vCPU, 48GB RAM)
# Hub: 2 vCPU, 8GB RAM per replica (2 replicas = 4 vCPU, 16GB RAM)
# EDA: 2 vCPU, 8GB RAM per replica (2 replicas = 4 vCPU, 16GB RAM)
# Database: 2 vCPU, 8GB RAM
# Total: 22 vCPU, 88GB RAM minimum
```

### 2. Network Planning
- Ingress configuration (Routes vs Ingress)
- DNS requirements and domain planning
- Certificate management strategy
- External access and security groups

### 3. Storage Planning
- Storage classes for different workload types
- Database storage requirements (100GB minimum)
- Projects and artifact storage (50GB per component)
- Backup storage planning

## Deployment Procedures

### Step 1: Environment Preparation

```bash
# Set environment variables
export AAP_ADMIN_PASSWORD="your-secure-password"
export OPENSHIFT_TOKEN="your-openshift-token"
export AAP_LICENSE_MANIFEST="base64-encoded-license"
export OPENSHIFT_NAMESPACE="ansible-automation"
export DOMAIN_NAME="automation.company.com"

# Verify cluster access
oc whoami
oc get nodes
```

### Step 2: Deploy Using Automation Scripts

#### Option A: Using Ansible Playbook
```bash
cd delivery/scripts/ansible
ansible-playbook playbook.yml \
  -e "openshift_namespace=$OPENSHIFT_NAMESPACE" \
  -e "domain_name=$DOMAIN_NAME" \
  -v
```

#### Option B: Using Bash Script
```bash
cd delivery/scripts/bash
chmod +x deploy.sh
./deploy.sh --namespace $OPENSHIFT_NAMESPACE --domain $DOMAIN_NAME
```

#### Option C: Using Python Script
```bash
cd delivery/scripts/python
pip install -r requirements.txt
python deploy.py --namespace $OPENSHIFT_NAMESPACE --domain $DOMAIN_NAME
```

### Step 3: Post-Deployment Verification

```bash
# Check pod status
oc get pods -n $OPENSHIFT_NAMESPACE

# Check routes
oc get routes -n $OPENSHIFT_NAMESPACE

# Test API connectivity
curl -k https://controller.$DOMAIN_NAME/api/v2/ping/

# Check operator status
oc get subscription ansible-automation-platform-operator -n ansible-automation-platform-operator
```

## Configuration Management

### Initial Setup

1. **Access the Controller UI**
   ```
   URL: https://controller.$DOMAIN_NAME
   Username: admin
   Password: $AAP_ADMIN_PASSWORD
   ```

2. **Complete Initial Configuration**
   - Configure subscription manifest
   - Set up initial organization
   - Configure user management
   - Set up credential types

### Organization Setup

1. **Create Organizations**
   ```bash
   # Using API
   curl -X POST https://controller.$DOMAIN_NAME/api/v2/organizations/ \
     -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"name": "Production", "description": "Production Organization"}'
   ```

2. **Configure Teams and Users**
   - Create team structure aligned with your organization
   - Assign appropriate roles and permissions
   - Configure RBAC policies

### Credential Management

1. **Machine Credentials**
   ```yaml
   - name: Production SSH Key
     credential_type: Machine
     inputs:
       username: ansible
       ssh_key_data: "{{ ssh_private_key }}"
   ```

2. **Cloud Credentials**
   ```yaml
   - name: AWS Production
     credential_type: Amazon Web Services
     inputs:
       username: "{{ aws_access_key }}"
       password: "{{ aws_secret_key }}"
   ```

### Project Configuration

1. **Source Control Integration**
   ```yaml
   projects:
     - name: Infrastructure Automation
       scm_type: git
       scm_url: https://github.com/company/infrastructure-automation.git
       scm_branch: main
       scm_credential: Git Credential
   ```

2. **Execution Environments**
   ```yaml
   execution_environments:
     - name: Custom EE
       image: registry.company.com/ansible-ee:latest
       pull: always
   ```

## Integration Configuration

### Identity Provider Integration

1. **SAML Configuration**
   ```yaml
   SOCIAL_AUTH_SAML_SP_ENTITY_ID: "https://controller.$DOMAIN_NAME"
   SOCIAL_AUTH_SAML_SP_PUBLIC_CERT: "{{ saml_cert }}"
   SOCIAL_AUTH_SAML_SP_PRIVATE_KEY: "{{ saml_key }}"
   ```

2. **LDAP Integration**
   ```yaml
   AUTH_LDAP_SERVER_URI: "ldap://ldap.company.com"
   AUTH_LDAP_BIND_DN: "cn=ansible,ou=service,dc=company,dc=com"
   AUTH_LDAP_USER_SEARCH: "ou=users,dc=company,dc=com"
   ```

### Monitoring Integration

1. **Prometheus Metrics**
   ```yaml
   apiVersion: monitoring.coreos.com/v1
   kind: ServiceMonitor
   metadata:
     name: ansible-automation-metrics
   spec:
     selector:
       matchLabels:
         app.kubernetes.io/name: automation-controller
   ```

2. **Grafana Dashboards**
   - Job execution metrics
   - Resource utilization
   - Success/failure rates
   - Performance analytics

### External Tool Integration

1. **Git Integration**
   - Configure webhook notifications
   - Set up branch protection rules
   - Enable automatic project synchronization

2. **CI/CD Pipeline Integration**
   ```yaml
   # Jenkins integration example
   - job:
       name: Deploy Application
       project: CI/CD Templates
       playbook: deploy-app.yml
       triggers:
         - webhook:
             name: jenkins-trigger
             auth_type: basic
   ```

## Security Hardening

### TLS Configuration

1. **Custom Certificates**
   ```bash
   # Create TLS secret with custom certificates
   oc create secret tls tfe-tls-certificate \
     --cert=path/to/cert.pem \
     --key=path/to/key.pem \
     -n $OPENSHIFT_NAMESPACE
   ```

2. **Certificate Rotation**
   ```bash
   # Automate certificate renewal
   ansible-playbook cert-renewal.yml \
     --tags certificate-rotation
   ```

### Network Security

1. **Network Policies**
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: ansible-automation-netpol
   spec:
     podSelector:
       matchLabels:
         app.kubernetes.io/part-of: automation-controller
     policyTypes:
     - Ingress
     - Egress
   ```

2. **Security Context Constraints**
   ```yaml
   apiVersion: security.openshift.io/v1
   kind: SecurityContextConstraints
   metadata:
     name: ansible-automation-scc
   allowHostDirVolumePlugin: false
   allowHostIPC: false
   allowHostNetwork: false
   ```

### RBAC Configuration

1. **Custom Roles**
   ```yaml
   - name: Deployment Manager
     permissions:
       - job_template:
           - read
           - execute
       - credential:
           - read
       - project:
           - read
   ```

## Performance Optimization

### Resource Tuning

1. **Controller Optimization**
   ```yaml
   spec:
     replicas: 3
     resources:
       requests:
         cpu: 2
         memory: 8Gi
       limits:
         cpu: 4
         memory: 16Gi
   ```

2. **Database Optimization**
   ```yaml
   postgres_configuration_secret: postgres-config
   postgres_storage_requirements:
     requests:
       storage: 100Gi
   postgres_storage_class: fast-ssd
   ```

### Scaling Configuration

1. **Horizontal Pod Autoscaler**
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: automation-controller-hpa
   spec:
     minReplicas: 3
     maxReplicas: 10
     targetCPUUtilizationPercentage: 70
   ```

## Backup and Recovery

### Database Backup

1. **Automated Backups**
   ```yaml
   apiVersion: batch/v1
   kind: CronJob
   metadata:
     name: postgres-backup
   spec:
     schedule: "0 2 * * *"
     jobTemplate:
       spec:
         template:
           spec:
             containers:
             - name: pg-dump
               image: postgres:14
               command: ["/bin/bash"]
               args:
                 - -c
                 - pg_dump $DATABASE_URL | gzip > /backup/aap-$(date +%Y%m%d).sql.gz
   ```

### Application Data Backup

1. **Projects and Artifacts**
   ```bash
   # Backup automation content
   oc exec -it automation-controller-0 -- tar czf /tmp/projects-backup.tar.gz /var/lib/awx/projects/
   oc cp automation-controller-0:/tmp/projects-backup.tar.gz ./projects-backup-$(date +%Y%m%d).tar.gz
   ```

### Disaster Recovery

1. **Recovery Procedures**
   ```bash
   # Restore from backup
   ./deploy.sh --restore --backup-file projects-backup-20240115.tar.gz
   ```

## Troubleshooting

### Common Issues

1. **Pod Startup Issues**
   ```bash
   # Check pod logs
   oc logs -f deployment/automation-controller -n $OPENSHIFT_NAMESPACE
   
   # Check events
   oc get events -n $OPENSHIFT_NAMESPACE --sort-by='.lastTimestamp'
   ```

2. **Database Connection Issues**
   ```bash
   # Test database connectivity
   oc exec -it postgresql-0 -- psql -h localhost -U awx -d automation_controller -c "SELECT version();"
   ```

3. **Authentication Issues**
   ```bash
   # Reset admin password
   oc exec -it automation-controller-0 -- awx-manage changepassword admin
   ```

### Performance Issues

1. **Resource Constraints**
   ```bash
   # Check resource usage
   oc top pods -n $OPENSHIFT_NAMESPACE
   oc describe node | grep -A 5 "Allocated resources"
   ```

2. **Storage Issues**
   ```bash
   # Check PVC status
   oc get pvc -n $OPENSHIFT_NAMESPACE
   oc describe pvc postgres-data
   ```

## Maintenance Procedures

### Regular Maintenance Tasks

1. **Log Rotation**
   ```bash
   # Configure log rotation
   ansible-playbook maintenance/log-rotation.yml
   ```

2. **Certificate Renewal**
   ```bash
   # Automated certificate renewal
   ansible-playbook maintenance/cert-renewal.yml
   ```

3. **Database Maintenance**
   ```bash
   # Database vacuum and analyze
   oc exec -it postgresql-0 -- vacuumdb -z -d automation_controller
   ```

### Upgrade Procedures

1. **Operator Upgrade**
   ```bash
   # Update subscription channel
   oc patch subscription ansible-automation-platform-operator \
     -n ansible-automation-platform-operator \
     --type merge \
     --patch '{"spec":{"channel":"stable-2.5-cluster-scoped"}}'
   ```

2. **Application Upgrade**
   ```bash
   # Update AutomationController CR
   oc patch automationcontroller automation-controller \
     -n $OPENSHIFT_NAMESPACE \
     --type merge \
     --patch '{"spec":{"image_version":"2.5.0"}}'
   ```

## Appendices

### Appendix A: Environment Variables Reference
```bash
# Required variables
AAP_ADMIN_PASSWORD=         # Admin password for the platform
OPENSHIFT_TOKEN=           # OpenShift authentication token  
AAP_LICENSE_MANIFEST=      # Base64 encoded license manifest

# Optional variables
OPENSHIFT_NAMESPACE=       # Target namespace (default: ansible-automation)
DOMAIN_NAME=              # Base domain for routes
AAP_VERSION=             # Platform version (default: 2.4)
```

### Appendix B: Port and Protocol Reference
| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| Controller UI | 443 | HTTPS | Web interface |
| Controller API | 443 | HTTPS | REST API |
| Hub UI | 443 | HTTPS | Private automation hub |
| EDA UI | 443 | HTTPS | Event-driven ansible |
| PostgreSQL | 5432 | TCP | Database |

### Appendix C: Resource Requirements
| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Controller | 4 vCPU | 16GB | 20GB |
| Hub | 2 vCPU | 8GB | 100GB |
| EDA | 2 vCPU | 8GB | 20GB |
| PostgreSQL | 2 vCPU | 8GB | 100GB |
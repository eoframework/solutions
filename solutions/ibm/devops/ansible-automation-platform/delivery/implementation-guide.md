# IBM Ansible Automation Platform - Implementation Guide

## Document Information
**Solution**: Red Hat Ansible Automation Platform  
**Version**: 2.4  
**Date**: January 2025  
**Audience**: Implementation Teams, DevOps Engineers, Platform Engineers  

---

## Overview

This implementation guide provides comprehensive instructions for deploying Red Hat Ansible Automation Platform in enterprise environments. The platform enables infrastructure automation, configuration management, and application deployment across hybrid cloud environments.

### Implementation Phases
1. **Phase 1**: Platform Planning (requirements, architecture, sizing)
2. **Phase 2**: Infrastructure Setup (OpenShift cluster, storage, networking)
3. **Phase 3**: Ansible Platform Installation (automation controller, hub, mesh)
4. **Phase 4**: Configuration (authentication, projects, inventories, credentials)
5. **Phase 5**: Integration (SCM, monitoring, CI/CD pipelines)
6. **Phase 6**: Testing and Validation (connectivity, workflows, performance)

---

## Prerequisites

Before starting implementation, ensure all prerequisites are met:
- Red Hat OpenShift Container Platform 4.10+ deployed and accessible
- Sufficient compute and storage resources as per sizing guide
- Network connectivity to target infrastructure
- Red Hat subscriptions for Ansible Automation Platform
- Administrative access to OpenShift cluster
- Git repositories prepared for playbook management
- Target system credentials and service accounts

### Resource Requirements

#### Minimum Requirements
- **CPU**: 16 vCPUs total across cluster
- **Memory**: 32 GB RAM total
- **Storage**: 100 GB persistent storage
- **Network**: 1 Gbps connectivity

#### Production Requirements
- **CPU**: 64+ vCPUs across multiple nodes
- **Memory**: 128+ GB RAM distributed
- **Storage**: 500+ GB high-performance storage
- **Network**: 10 Gbps connectivity with redundancy

---

## Phase 1: Platform Planning

### Step 1.1: Architecture Design

#### Review Reference Architecture
```bash
# Download reference architecture diagrams
wget https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.4/html/red_hat_ansible_automation_platform_planning_guide/ref-example-platform-architectures

# Key components to plan:
# - Automation Controller (primary automation interface)
# - Automation Hub (content management)
# - Event-Driven Ansible (automation trigger management)
# - Automation Mesh (distributed execution)
```

#### Define Deployment Model
```yaml
# deployment-model.yaml
deployment_type: high-availability
components:
  automation_controller:
    replicas: 3
    database: external-postgresql
    storage_class: fast-ssd
  automation_hub:
    replicas: 2
    storage_class: standard
  event_driven_ansible:
    replicas: 2
    kafka_integration: true
network_configuration:
  ingress_controller: openshift-default
  load_balancer: internal
  ssl_termination: edge
```

### Step 1.2: Sizing and Capacity Planning

#### Calculate Resource Requirements
```bash
# Use Red Hat sizing calculator
# Factors to consider:
# - Number of managed nodes
# - Concurrent job execution
# - Playbook complexity
# - User count
# - Integration points

# Example calculation for 500 managed nodes:
cat > sizing-calculation.yaml << EOF
managed_nodes: 500
concurrent_jobs: 20
peak_users: 25
estimated_requirements:
  cpu_cores: 32
  memory_gb: 128
  storage_gb: 500
  network_bandwidth: "10 Gbps"
EOF
```

---

## Phase 2: Infrastructure Setup

### Step 2.1: OpenShift Cluster Preparation

#### Verify Cluster Requirements
```bash
# Check OpenShift cluster version
oc version

# Verify cluster nodes and resources
oc get nodes
oc describe node | grep -A 5 Capacity

# Check storage classes
oc get storageclass

# Verify ingress controller
oc get ingresscontroller -n openshift-ingress-operator
```

#### Create Namespace and Project
```bash
# Create dedicated namespace
oc create namespace ansible-automation-platform

# Set project context
oc project ansible-automation-platform

# Label namespace for monitoring
oc label namespace ansible-automation-platform monitoring=enabled
```

### Step 2.2: Storage Configuration

#### Configure Persistent Storage
```yaml
# persistent-storage.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: automation-controller-postgres
  namespace: ansible-automation-platform
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: fast-ssd

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: automation-hub-storage
  namespace: ansible-automation-platform
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
  storageClassName: standard
```

```bash
# Apply storage configuration
oc apply -f persistent-storage.yaml
```

### Step 2.3: Security Configuration

#### Configure Service Accounts
```bash
# Create service account for Ansible operations
oc create serviceaccount ansible-automation-sa -n ansible-automation-platform

# Grant necessary permissions
oc adm policy add-scc-to-user anyuid -z ansible-automation-sa -n ansible-automation-platform
```

#### Configure Network Policies
```yaml
# network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ansible-automation-policy
  namespace: ansible-automation-platform
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: openshift-ingress
    ports:
    - protocol: TCP
      port: 8080
  - from:
    - namespaceSelector:
        matchLabels:
          name: ansible-automation-platform
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
```

---

## Phase 3: Ansible Platform Installation

### Step 3.1: Install Ansible Automation Platform Operator

#### Deploy Operator via OpenShift Console
```bash
# Access OpenShift Console
echo "Access OpenShift Console at: https://$(oc get route console -n openshift-console -o jsonpath='{.spec.host}')"

# Navigate to Operators > OperatorHub
# Search for "Ansible Automation Platform"
# Install the Red Hat Ansible Automation Platform operator
```

#### Verify Operator Installation
```bash
# Check operator deployment
oc get operators -n ansible-automation-platform
oc get csv -n ansible-automation-platform | grep ansible

# Check operator pods
oc get pods -n ansible-automation-platform | grep operator
```

### Step 3.2: Configure Automation Controller

#### Create Automation Controller Instance
```yaml
# automation-controller.yaml
apiVersion: automationcontroller.ansible.com/v1beta1
kind: AutomationController
metadata:
  name: automation-controller
  namespace: ansible-automation-platform
spec:
  admin_user: admin
  admin_email: admin@company.com
  admin_password_secret: controller-admin-password
  postgres_configuration_secret: controller-postgres-configuration
  replicas: 3
  route_tls_termination_mechanism: edge
  hostname: automation-controller.apps.openshift.company.com
  image_pull_policy: Always
  projects_persistence: true
  projects_storage_class: standard
  projects_storage_size: 50Gi
  task_privileged: false
  service_type: ClusterIP
  loadbalancer_protocol: http
  node_selector: |
    node-role.kubernetes.io/worker: ""
  tolerations: |
    - key: node-role.kubernetes.io/infra
      effect: NoSchedule
      operator: Equal
      value: reserved
  ee_images:
    - name: Default execution environment
      image: quay.io/ansible/automation-controller-ee:latest
  ldap_cacert_secret: ldap-ca-cert
  bundle_cacert_secret: bundle-ca-cert
```

#### Create Required Secrets
```bash
# Create admin password secret
oc create secret generic controller-admin-password \
  --from-literal=password='SecurePassword123!' \
  -n ansible-automation-platform

# Create PostgreSQL configuration secret
oc create secret generic controller-postgres-configuration \
  --from-literal=host=postgresql.ansible-automation-platform.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=database=automationcontroller \
  --from-literal=username=controller \
  --from-literal=password='DatabasePassword123!' \
  -n ansible-automation-platform

# Apply automation controller configuration
oc apply -f automation-controller.yaml
```

### Step 3.3: Configure Automation Hub

#### Create Automation Hub Instance
```yaml
# automation-hub.yaml
apiVersion: automationhub.ansible.com/v1beta1
kind: AutomationHub
metadata:
  name: automation-hub
  namespace: ansible-automation-platform
spec:
  admin_password_secret: hub-admin-password
  postgres_configuration_secret: hub-postgres-configuration
  replicas: 2
  route_tls_termination_mechanism: edge
  hostname: automation-hub.apps.openshift.company.com
  storage_type: s3
  object_storage_s3_secret: hub-s3-secret
  pulp_settings:
    galaxy_collection_signing_service: ansible-default
  nginx_proxy_send_timeout: 120s
  nginx_proxy_read_timeout: 120s
  gunicorn_timeout: 90
  gunicorn_workers: 2
```

#### Configure Hub Secrets
```bash
# Create hub admin password
oc create secret generic hub-admin-password \
  --from-literal=password='HubSecurePassword123!' \
  -n ansible-automation-platform

# Create hub database configuration
oc create secret generic hub-postgres-configuration \
  --from-literal=host=postgresql.ansible-automation-platform.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=database=automationhub \
  --from-literal=username=hub \
  --from-literal=password='HubDatabasePassword123!' \
  -n ansible-automation-platform

# Create S3 storage configuration (if using external storage)
oc create secret generic hub-s3-secret \
  --from-literal=s3-access-key-id='YOUR_ACCESS_KEY' \
  --from-literal=s3-secret-access-key='YOUR_SECRET_KEY' \
  --from-literal=s3-bucket-name='ansible-hub-storage' \
  --from-literal=s3-region='us-east-1' \
  -n ansible-automation-platform

# Apply automation hub configuration
oc apply -f automation-hub.yaml
```

### Step 3.4: Deploy Event-Driven Ansible

#### Create EDA Controller
```yaml
# eda-controller.yaml
apiVersion: eda.ansible.com/v1alpha1
kind: EDAController
metadata:
  name: eda-controller
  namespace: ansible-automation-platform
spec:
  admin_password_secret: eda-admin-password
  postgres_configuration_secret: eda-postgres-configuration
  replicas: 2
  route_tls_termination_mechanism: edge
  hostname: eda-controller.apps.openshift.company.com
  automation_server_url: https://automation-controller.apps.openshift.company.com
```

```bash
# Create EDA admin password
oc create secret generic eda-admin-password \
  --from-literal=password='EDASecurePassword123!' \
  -n ansible-automation-platform

# Create EDA database configuration
oc create secret generic eda-postgres-configuration \
  --from-literal=host=postgresql.ansible-automation-platform.svc.cluster.local \
  --from-literal=port=5432 \
  --from-literal=database=eda \
  --from-literal=username=eda \
  --from-literal=password='EDADatabasePassword123!' \
  -n ansible-automation-platform

# Apply EDA configuration
oc apply -f eda-controller.yaml
```

---

## Phase 4: Configuration

### Step 4.1: Initial Platform Configuration

#### Access Automation Controller
```bash
# Get controller URL
CONTROLLER_URL=$(oc get route automation-controller -n ansible-automation-platform -o jsonpath='{.spec.host}')
echo "Automation Controller URL: https://${CONTROLLER_URL}"

# Login credentials
echo "Username: admin"
echo "Password: (from controller-admin-password secret)"
```

#### Configure LDAP Authentication
```yaml
# ldap-config.yaml
LDAP_SERVER_URI: ldap://ldap.company.com:389
LDAP_BIND_DN: CN=ansible-service,CN=Users,DC=company,DC=com
LDAP_START_TLS: false
LDAP_GROUP_SEARCH: DC=company,DC=com
LDAP_GROUP_TYPE: ActiveDirectoryGroupType
LDAP_USER_SEARCH: CN=Users,DC=company,DC=com
LDAP_USER_ATTR_MAP:
  first_name: givenName
  last_name: sn
  email: mail
```

### Step 4.2: Configure Organizations and Teams

#### Create Organizations
```bash
# Using awx-cli or REST API
awx-cli organizations create \
  --name "Engineering" \
  --description "Engineering Teams"

awx-cli organizations create \
  --name "Operations" \
  --description "Operations Teams"
```

#### Configure RBAC
```bash
# Create teams
awx-cli teams create \
  --name "Platform Engineers" \
  --organization "Engineering"

awx-cli teams create \
  --name "Infrastructure Team" \
  --organization "Operations"

# Assign permissions
awx-cli permissions grant \
  --team "Platform Engineers" \
  --role "Admin" \
  --organization "Engineering"
```

### Step 4.3: Configure Projects and Inventories

#### Create SCM Projects
```bash
# Create project linked to Git repository
awx-cli projects create \
  --name "Infrastructure Playbooks" \
  --organization "Engineering" \
  --scm_type git \
  --scm_url https://github.com/company/ansible-playbooks.git \
  --scm_branch main \
  --scm_credential "Git Credential"
```

#### Configure Dynamic Inventories
```yaml
# aws-inventory.yaml
plugin: aws_ec2
regions:
  - us-east-1
  - us-west-2
keyed_groups:
  - key: instance_type
    prefix: type
  - key: placement_region
    prefix: region
compose:
  ansible_host: public_ip_address | default(private_ip_address)
```

---

## Phase 5: Integration

### Step 5.1: CI/CD Pipeline Integration

#### Configure Jenkins Integration
```bash
# Install Jenkins plugin for Ansible
# Configure webhook for job triggers
curl -X POST "https://${CONTROLLER_URL}/api/v2/job_templates/1/launch/" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json"
```

#### GitOps Integration
```yaml
# gitops-workflow.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ansible-automation
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/ansible-automation-config
    targetRevision: main
    path: overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: ansible-automation-platform
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Step 5.2: Monitoring Integration

#### Configure Prometheus Metrics
```yaml
# servicemonitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: automation-controller-metrics
  namespace: ansible-automation-platform
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: automation-controller
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

#### Configure Alerting Rules
```yaml
# ansible-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: ansible-automation-alerts
  namespace: ansible-automation-platform
spec:
  groups:
  - name: ansible.rules
    rules:
    - alert: AnsibleJobFailure
      expr: increase(ansible_job_failures_total[5m]) > 0
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: "Ansible job failure detected"
        description: "Job {{ $labels.job_name }} has failed"
    - alert: AnsibleControllerDown
      expr: up{job="automation-controller"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Automation Controller is down"
```

---

## Phase 6: Testing and Validation

### Step 6.1: Connectivity Testing

#### Test Platform Connectivity
```bash
# Test automation controller API
curl -k https://${CONTROLLER_URL}/api/v2/ping/
curl -k https://${CONTROLLER_URL}/api/v2/config/

# Test automation hub connectivity
HUB_URL=$(oc get route automation-hub -n ansible-automation-platform -o jsonpath='{.spec.host}')
curl -k https://${HUB_URL}/pulp/api/v3/status/

# Test database connectivity
oc exec -it postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "SELECT version();"
```

### Step 6.2: Workflow Testing

#### Create Test Job Template
```bash
# Create simple test playbook
cat > test-playbook.yml << EOF
---
- hosts: localhost
  gather_facts: yes
  tasks:
    - name: Test task
      debug:
        msg: "Hello from Ansible Automation Platform!"
    
    - name: Get system information
      debug:
        var: ansible_facts['os_family']
EOF

# Create job template via API
curl -X POST "https://${CONTROLLER_URL}/api/v2/job_templates/" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Job Template",
    "project": 1,
    "playbook": "test-playbook.yml",
    "inventory": 1
  }'

# Launch test job
curl -X POST "https://${CONTROLLER_URL}/api/v2/job_templates/1/launch/" \
  -H "Authorization: Bearer ${API_TOKEN}"
```

### Step 6.3: Performance Validation

#### Load Testing
```bash
# Create concurrent job execution test
for i in {1..10}; do
  curl -X POST "https://${CONTROLLER_URL}/api/v2/job_templates/1/launch/" \
    -H "Authorization: Bearer ${API_TOKEN}" &
done

# Monitor system resources
oc top nodes
oc top pods -n ansible-automation-platform

# Check job queue and execution times
awx-cli jobs list --status running
awx-cli jobs list --status successful | head -20
```

---

## Post-Implementation Tasks

### Step 7.1: Security Hardening

#### Configure Security Policies
```bash
# Apply security context constraints
oc apply -f - << EOF
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ansible-automation-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
defaultAddCapabilities: []
fsGroup:
  type: RunAsAny
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
users:
- system:serviceaccount:ansible-automation-platform:automation-controller
- system:serviceaccount:ansible-automation-platform:automation-hub
EOF
```

#### Configure Backup Strategy
```bash
# Create backup script
cat > backup-automation-platform.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups/ansible-$(date +%Y%m%d)"
mkdir -p ${BACKUP_DIR}

# Backup PostgreSQL databases
oc exec postgresql-0 -n ansible-automation-platform -- pg_dump -U controller automationcontroller > ${BACKUP_DIR}/controller.sql
oc exec postgresql-0 -n ansible-automation-platform -- pg_dump -U hub automationhub > ${BACKUP_DIR}/hub.sql

# Backup persistent volumes
oc get pvc -n ansible-automation-platform -o yaml > ${BACKUP_DIR}/pvc-backup.yaml

# Backup configurations
oc get automationcontroller -n ansible-automation-platform -o yaml > ${BACKUP_DIR}/controller-config.yaml
oc get automationhub -n ansible-automation-platform -o yaml > ${BACKUP_DIR}/hub-config.yaml

echo "Backup completed: ${BACKUP_DIR}"
EOF

chmod +x backup-automation-platform.sh
```

### Step 7.2: Documentation and Training

#### Create Operational Documentation
```bash
# Document deployment details
cat > deployment-summary.md << EOF
# Ansible Automation Platform Deployment Summary

## Platform Details
- **Controller URL**: https://${CONTROLLER_URL}
- **Hub URL**: https://${HUB_URL}
- **Namespace**: ansible-automation-platform
- **Version**: 2.4

## Access Information
- **Admin User**: admin
- **Organizations**: Engineering, Operations
- **Teams**: Platform Engineers, Infrastructure Team

## Integration Points
- **SCM**: GitHub repositories
- **Authentication**: LDAP/Active Directory
- **Monitoring**: Prometheus/Grafana
- **CI/CD**: Jenkins webhooks

## Maintenance Tasks
- Daily: Monitor job execution and system health
- Weekly: Review security logs and user access
- Monthly: Update playbooks and execution environments
- Quarterly: Platform updates and capacity review
EOF
```

---

## Troubleshooting Common Issues

### Issue 1: Pod Startup Failures
```bash
# Check pod status and logs
oc get pods -n ansible-automation-platform
oc describe pod <pod-name> -n ansible-automation-platform
oc logs <pod-name> -n ansible-automation-platform

# Common fixes:
# - Check resource constraints
# - Verify persistent storage
# - Review security context
```

### Issue 2: Database Connection Issues
```bash
# Test database connectivity
oc exec -it postgresql-0 -n ansible-automation-platform -- psql -U controller -d automationcontroller -c "SELECT 1;"

# Check database secrets
oc get secret controller-postgres-configuration -n ansible-automation-platform -o yaml

# Verify service endpoints
oc get svc postgresql -n ansible-automation-platform
```

### Issue 3: Job Execution Failures
```bash
# Check execution environment images
oc get pods -n ansible-automation-platform | grep ee-

# Review job logs in controller UI
# Check inventory connectivity
ansible-playbook -i inventory test-connectivity.yml --check
```

---

## Next Steps

1. **Content Development**: Create automation playbooks and roles
2. **User Onboarding**: Configure user accounts and permissions
3. **Integration Enhancement**: Connect additional systems and tools
4. **Monitoring Setup**: Implement comprehensive monitoring and alerting
5. **Training Delivery**: Conduct user and administrator training
6. **Production Rollout**: Migrate production workloads to platform

---

**Document Version**: 1.0  
**Last Updated**: January 2025  
**Next Review**: April 2025  
**Maintained By**: Platform Engineering Team
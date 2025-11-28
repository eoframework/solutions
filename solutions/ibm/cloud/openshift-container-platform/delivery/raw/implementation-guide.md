---
document_title: Implementation Guide
solution_name: Red Hat OpenShift Container Platform
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: ibm
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the Red Hat OpenShift Container Platform using the Infrastructure as Code (IaC) automation framework included in this delivery. The guide follows a logical progression from prerequisite validation through production deployment, with each phase directly referencing the scripts and Ansible playbooks in the `delivery/scripts/` folder.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures that directly execute the automation scripts included with this solution. All commands and procedures have been validated against the target VMware vSphere environment.

## Implementation Approach

The implementation follows an infrastructure-as-code methodology using the OpenShift installer (IPI) for cluster provisioning, Ansible for post-installation configuration, and ArgoCD for ongoing GitOps management. The approach ensures repeatable, auditable deployments across all environments.

## Automation Framework Overview

The following automation technologies are included in this delivery and referenced throughout this guide.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| openshift-install | Cluster provisioning | `scripts/openshift/` | Pull secret, SSH key |
| Ansible | Post-install configuration | `scripts/ansible/` | Ansible 2.9+, SSH access |
| oc CLI | Cluster administration | PATH | kubeconfig |
| Helm | Chart deployments | PATH | Helm 3.x |

## Scope Summary

### In Scope

The following components are deployed using the automation framework.

- OpenShift Container Platform 4.14 cluster (6 nodes)
- AD/LDAP authentication integration
- Monitoring stack (Prometheus, Grafana, Alertmanager)
- Logging stack (Elasticsearch, Fluentd, Kibana)
- CI/CD platform (OpenShift Pipelines, ArgoCD)
- Container registry (Quay)
- Service mesh (Istio)

### Out of Scope

The following items are excluded from automated deployment.

- Application development and containerization
- Custom operator development
- Multi-cluster management (Phase 2)
- Bare metal infrastructure provisioning

## Timeline Overview

The implementation follows a phased deployment approach with validation gates at each stage.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & Environment Setup | 1 week | All prerequisites validated |
| 2 | Cluster Installation | 1 week | Cluster operational |
| 3 | Platform Configuration | 3 weeks | All operators deployed |
| 4 | DevTools & Integrations | 2 weeks | CI/CD operational |
| 5 | Application Migration | 4 weeks | 10 apps deployed |
| 6 | Training & Hypercare | 4 weeks | Team certified |

# Prerequisites

This section documents all requirements that must be satisfied before cluster deployment can begin. The prerequisite validation script automates verification of these requirements.

## Tool Installation

The following tools must be installed on the deployment workstation before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **openshift-install** 4.14.x - Cluster installation
- [ ] **oc CLI** 4.14.x - OpenShift command line
- [ ] **Ansible** >= 2.9 - Configuration management
- [ ] **Helm** >= 3.0 - Chart deployments
- [ ] **Git** - Source code management
- [ ] **jq** - JSON processing

### OpenShift CLI Installation

Install the OpenShift CLI tools from the Red Hat mirror.

```bash
# Download OpenShift client tools
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.14.10/openshift-client-linux.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.14.10/openshift-install-linux.tar.gz

# Extract and install
tar -xzf openshift-client-linux.tar.gz
tar -xzf openshift-install-linux.tar.gz
sudo mv oc kubectl openshift-install /usr/local/bin/

# Verify installation
oc version
openshift-install version
```

### Ansible Installation

Install Ansible for post-installation configuration.

```bash
# Install Ansible via pip
pip3 install ansible ansible-core

# Install required collections
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.general

# Verify installation
ansible --version
```

## Infrastructure Requirements

Verify the following infrastructure requirements are met.

### VMware vSphere Requirements

- [ ] vSphere 7.0 Update 3 or later
- [ ] vCenter Server with API access
- [ ] Cluster with DRS enabled
- [ ] Datastore with 2TB+ available storage
- [ ] Distributed switch or port groups configured

### Network Requirements

- [ ] DHCP server for control plane and worker nodes
- [ ] DNS zone delegation for cluster subdomain
- [ ] Load balancer for API (6443) and ingress (443/80)
- [ ] Network connectivity to Red Hat CDN

### DNS Configuration

Configure the following DNS records before installation.

```
api.ocp-prod.example.com     -> Load Balancer VIP (6443)
api-int.ocp-prod.example.com -> Load Balancer VIP (6443)
*.apps.ocp-prod.example.com  -> Load Balancer VIP (443)
```

## Red Hat Subscription

### Pull Secret

Obtain your pull secret from the Red Hat Hybrid Cloud Console.

```bash
# Navigate to Red Hat Hybrid Cloud Console
# https://console.redhat.com/openshift/install/vsphere/installer-provisioned

# Download pull-secret.json and save to deployment directory
cat pull-secret.json | jq . > /path/to/deployment/pull-secret.json
```

### SSH Key

Generate an SSH key pair for cluster node access.

```bash
# Generate SSH key if not exists
ssh-keygen -t ed25519 -f ~/.ssh/ocp-cluster -N ""

# Display public key for install-config.yaml
cat ~/.ssh/ocp-cluster.pub
```

## Prerequisite Validation

Run the prerequisite validation script to verify all requirements.

```bash
# Navigate to scripts directory
cd delivery/scripts/

# Run prerequisite validation
./validate-prerequisites.sh

# Expected output:
# [OK] openshift-install version 4.14.10
# [OK] oc version 4.14.10
# [OK] Ansible version 2.14.x
# [OK] Pull secret valid
# [OK] SSH key exists
# [OK] DNS resolution working
# [OK] vCenter connectivity verified
```

### Validation Checklist

Complete this checklist before proceeding to cluster installation.

- [ ] All CLI tools installed and accessible
- [ ] vCenter credentials available
- [ ] Pull secret downloaded and valid
- [ ] SSH key generated
- [ ] DNS records created
- [ ] Load balancer configured
- [ ] Network connectivity verified

# Environment Setup

This section covers the OpenShift cluster installation using the Installer Provisioned Infrastructure (IPI) method on VMware vSphere.

## Installation Configuration

### Directory Structure

The installation scripts are organized in the following structure.

```
delivery/scripts/openshift/
├── install-config.yaml.template  # Installation configuration template
├── deploy-cluster.sh             # Main deployment script
├── destroy-cluster.sh            # Cluster destruction script
├── manifests/                    # Custom manifests
│   ├── cluster-network.yaml
│   ├── machine-config.yaml
│   └── storage-class.yaml
└── config/
    ├── production.env            # Production environment variables
    └── development.env           # Development environment variables
```

### Install Configuration

Create the installation configuration from the template.

```bash
# Navigate to OpenShift scripts directory
cd delivery/scripts/openshift/

# Copy template and edit for your environment
cp install-config.yaml.template install-config.yaml
vim install-config.yaml
```

Configure the following settings in `install-config.yaml`:

```yaml
apiVersion: v1
baseDomain: example.com
metadata:
  name: ocp-prod
compute:
  - architecture: amd64
    hyperthreading: Enabled
    name: worker
    replicas: 3
    platform:
      vsphere:
        cpus: 16
        coresPerSocket: 4
        memoryMB: 65536
        osDisk:
          diskSizeGB: 120
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  replicas: 3
  platform:
    vsphere:
      cpus: 8
      coresPerSocket: 4
      memoryMB: 32768
      osDisk:
        diskSizeGB: 120
platform:
  vsphere:
    apiVIPs:
      - 10.100.0.10
    ingressVIPs:
      - 10.100.0.11
    vCenter: vcenter.example.com
    username: administrator@vsphere.local
    password: <vcenter-password>
    datacenter: Datacenter
    defaultDatastore: vsanDatastore
    cluster: Cluster
    network: OCP-Network
    folder: /Datacenter/vm/OpenShift
pullSecret: '<pull-secret-json>'
sshKey: '<ssh-public-key>'
```

## Cluster Deployment

### Pre-Deployment Checks

Verify all prerequisites before starting deployment.

```bash
# Navigate to OpenShift scripts directory
cd delivery/scripts/openshift/

# Validate install configuration
openshift-install create manifests --dir=.

# Review generated manifests
ls -la manifests/
ls -la openshift/

# If customizations needed, edit manifests now
# Then proceed to cluster creation
```

### Execute Cluster Installation

Run the cluster deployment script.

```bash
# Navigate to OpenShift scripts directory
cd delivery/scripts/openshift/

# Execute deployment script
./deploy-cluster.sh

# Or run manually with full logging
openshift-install create cluster --dir=. --log-level=debug 2>&1 | tee cluster-install.log

# Monitor installation progress (approximately 45-60 minutes)
# The installer will output progress:
# INFO Waiting up to 20m0s for the Kubernetes API at https://api.ocp-prod.example.com:6443...
# INFO API v1.27.8+4fab27b up
# INFO Waiting up to 30m0s for bootstrapping to complete...
# INFO Destroying the bootstrap resources...
# INFO Waiting up to 40m0s for the cluster at https://api.ocp-prod.example.com:6443 to initialize...
# INFO Install complete!
```

### Post-Installation Verification

Verify cluster installation completed successfully.

```bash
# Export kubeconfig
export KUBECONFIG=/path/to/scripts/openshift/auth/kubeconfig

# Verify cluster operators
oc get clusteroperators
# All operators should show Available=True, Progressing=False, Degraded=False

# Verify nodes
oc get nodes
# Expected: 3 master nodes, 3 worker nodes in Ready state

# Verify cluster version
oc get clusterversion
# Should show version 4.14.x and Available=True

# Get console URL
oc get routes -n openshift-console
# Access console at: https://console-openshift-console.apps.ocp-prod.example.com

# Get kubeadmin credentials
cat auth/kubeadmin-password
```

### Installation Success Criteria

Complete this checklist before proceeding to platform configuration.

- [ ] All cluster operators available and not degraded
- [ ] All 6 nodes in Ready state
- [ ] OpenShift console accessible
- [ ] API server responding
- [ ] kubeadmin authentication working

# Infrastructure Deployment

This section covers post-installation configuration using Ansible playbooks, organized into four deployment phases.

## Phase 1: Networking Layer

### Network Policy Configuration

Deploy network policies for pod-to-pod communication control.

```bash
## navigate to Ansible directory
cd delivery/scripts/ansible/

## run network configuration playbook
ansible-playbook -i inventory/hosts.yml playbooks/00-networking.yml

## verify network policies applied
oc get networkpolicies -A
```

### Ingress Configuration

Configure ingress controller and routes.

```bash
## verify ingress controller
oc get pods -n openshift-ingress

## check default ingress controller configuration
oc get ingresscontroller default -n openshift-ingress-operator -o yaml
```

### Networking Validation

```bash
## test pod-to-pod connectivity
oc run test-pod --image=busybox --restart=Never -- sleep 3600
oc exec test-pod -- ping -c 3 kubernetes.default.svc.cluster.local

## verify DNS resolution
oc exec test-pod -- nslookup kubernetes.default.svc.cluster.local
```

## Phase 2: Security Layer

### AD/LDAP Authentication

Deploy LDAP authentication using the Ansible playbook.

```bash
## navigate to Ansible directory
cd delivery/scripts/ansible/

## review LDAP variables
cat group_vars/ldap.yml
```

```yaml
## group_vars/ldap.yml
ldap_url: "ldaps://ldap.example.com:636"
ldap_bind_dn: "CN=ocp-svc,OU=ServiceAccounts,DC=example,DC=com"
ldap_bind_password: "{{ vault_ldap_bind_password }}"
ldap_user_search_base: "OU=Users,DC=example,DC=com"
ldap_group_search_base: "OU=Groups,DC=example,DC=com"

## group to role mappings
ldap_group_mappings:
  - ldap_group: "OCP-Admins"
    cluster_role: "cluster-admin"
  - ldap_group: "OCP-Developers"
    cluster_role: "edit"
  - ldap_group: "OCP-Viewers"
    cluster_role: "view"
```

```bash
## run LDAP authentication playbook
ansible-playbook -i inventory/hosts.yml playbooks/01-ldap-auth.yml \
  --ask-vault-pass

## verify LDAP authentication
oc login -u <ad-username> -p <ad-password> https://api.ocp-prod.example.com:6443
```

### RBAC Configuration

Configure role-based access control.

```bash
## verify group sync
oc get groups

## check cluster role bindings
oc get clusterrolebindings | grep -E "OCP-Admins|OCP-Developers"
```

### Security Validation

```bash
## check OAuth configuration
oc get oauth cluster -o yaml

## verify identity providers
oc get identity

## list users who have logged in
oc get users
```

## Phase 3: Compute Layer

### Storage Configuration

Deploy OpenShift Data Foundation for persistent storage.

```bash
## verify ODF operator
oc get csv -n openshift-storage

## check storage cluster status
oc get storagecluster -n openshift-storage

## verify storage classes available
oc get storageclass
```

### Container Registry (Quay)

Deploy Quay as the internal container registry.

```bash
## run registry deployment playbook
ansible-playbook -i inventory/hosts.yml playbooks/04-registry.yml

## get Quay route
oc get routes -n quay-enterprise

## test image push
podman login quay.apps.ocp-prod.example.com
podman pull nginx:latest
podman tag nginx:latest quay.apps.ocp-prod.example.com/test/nginx:latest
podman push quay.apps.ocp-prod.example.com/test/nginx:latest
```

### Compute Validation

```bash
## verify worker nodes ready
oc get nodes -l node-role.kubernetes.io/worker

## check node resources
oc adm top nodes

## verify pod scheduling
oc get pods -A -o wide | head -20
```

## Phase 4: Monitoring Layer

### Deploy Prometheus and Grafana

The monitoring stack is deployed via the cluster monitoring operator.

```bash
## run monitoring configuration playbook
ansible-playbook -i inventory/hosts.yml playbooks/02-monitoring.yml

## the playbook configures:
## - PagerDuty alerting integration
## - custom alerting rules
## - Prometheus retention (15 days)
## - Grafana dashboards
```

### Deploy EFK Logging

Deploy Elasticsearch, Fluentd, and Kibana for log aggregation.

```bash
## run logging deployment playbook
ansible-playbook -i inventory/hosts.yml playbooks/03-logging.yml

## the playbook deploys:
## - Elasticsearch cluster (3 nodes)
## - Fluentd log forwarders
## - Kibana interface
## - log retention policies (7 days)
```

### Monitoring Validation

```bash
## check monitoring namespace
oc get pods -n openshift-monitoring

## access Prometheus
oc get routes -n openshift-monitoring prometheus-k8s

## access Grafana
oc get routes -n openshift-monitoring grafana

## check logging namespace
oc get pods -n openshift-logging

## access Kibana
oc get routes -n openshift-logging kibana
```

# Application Configuration

This section covers the deployment of CI/CD tools including OpenShift Pipelines and ArgoCD.

## OpenShift Pipelines

### Deploy Tekton Pipelines

Deploy OpenShift Pipelines via the Ansible playbook.

```bash
# Run CI/CD deployment playbook
ansible-playbook -i inventory/hosts.yml playbooks/05-cicd.yml --tags pipelines

# The playbook deploys:
# - OpenShift Pipelines Operator
# - Cluster tasks for common operations
# - Pipeline templates
# - Webhook configurations
```

### Configure Pipeline Templates

Create pipeline templates for common application types.

```bash
# Navigate to pipeline templates
cd delivery/scripts/ansible/roles/cicd/files/pipelines/

# Templates available:
# - java-spring-boot-pipeline.yaml
# - nodejs-pipeline.yaml
# - python-flask-pipeline.yaml
# - dotnet-pipeline.yaml

# Apply pipeline templates
oc apply -f java-spring-boot-pipeline.yaml -n cicd-templates
oc apply -f nodejs-pipeline.yaml -n cicd-templates
```

### Test Pipeline Execution

Test pipeline execution with a sample application.

```bash
# Create test namespace
oc new-project pipeline-test

# Create pipeline run
cat <<EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: test-pipeline-run
  namespace: pipeline-test
spec:
  pipelineRef:
    name: java-spring-boot-pipeline
  params:
    - name: git-url
      value: https://github.com/sample/app.git
    - name: image-name
      value: quay.apps.ocp-prod.example.com/test/sample-app
  workspaces:
    - name: shared-workspace
      persistentVolumeClaim:
        claimName: pipeline-workspace
EOF

# Monitor pipeline execution
oc get pipelineruns -n pipeline-test -w

# View pipeline logs
tkn pipelinerun logs test-pipeline-run -n pipeline-test
```

## ArgoCD GitOps

### Deploy ArgoCD

Deploy ArgoCD for GitOps continuous delivery.

```bash
# Run ArgoCD deployment via Ansible
ansible-playbook -i inventory/hosts.yml playbooks/05-cicd.yml --tags argocd

# The playbook deploys:
# - OpenShift GitOps Operator
# - ArgoCD instance
# - RBAC configuration
# - Git repository credentials
```

### Configure ArgoCD

Configure ArgoCD for application deployments.

```bash
# Get ArgoCD admin password
oc extract secret/openshift-gitops-cluster -n openshift-gitops --to=-

# Access ArgoCD
oc get routes -n openshift-gitops openshift-gitops-server
# URL: https://openshift-gitops-server-openshift-gitops.apps.ocp-prod.example.com

# Login via CLI
argocd login openshift-gitops-server-openshift-gitops.apps.ocp-prod.example.com \
  --username admin \
  --password <password>

# Add Git repository
argocd repo add https://github.com/company/gitops-config.git \
  --username <git-user> \
  --password <git-token>
```

### Create ArgoCD Application

Create an ArgoCD application for GitOps deployment.

```bash
# Create application via CLI
argocd app create sample-app \
  --repo https://github.com/company/gitops-config.git \
  --path apps/sample-app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace sample-app \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Or via YAML manifest
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: https://github.com/company/gitops-config.git
    targetRevision: HEAD
    path: apps/sample-app
  destination:
    server: https://kubernetes.default.svc
    namespace: sample-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Monitor sync status
argocd app get sample-app
```

## Service Mesh

### Deploy Istio Service Mesh

Deploy Istio for service-to-service communication.

```bash
# Run service mesh deployment playbook
ansible-playbook -i inventory/hosts.yml playbooks/06-service-mesh.yml

# The playbook deploys:
# - Red Hat OpenShift Service Mesh Operator
# - Service Mesh Control Plane
# - Jaeger for distributed tracing
# - Kiali for visualization
```

### Configure Service Mesh

Configure service mesh for application namespaces.

```bash
# Check Service Mesh Control Plane
oc get smcp -n istio-system

# Add namespace to service mesh
oc label namespace sample-app istio-injection=enabled

# Access Kiali dashboard
oc get routes -n istio-system kiali

# Access Jaeger
oc get routes -n istio-system jaeger
```

# Integration Testing

This section covers the validation of platform components, functional testing, and performance verification.

## Platform Integration Tests

### Cluster Health Verification

Validate all cluster components are functioning correctly.

```bash
# Run comprehensive cluster health check
oc get clusteroperators
oc get nodes
oc get pods -A | grep -v Running | grep -v Completed

# Verify all operators are available
oc get co -o json | jq -r '.items[] | select(.status.conditions[] | select(.type=="Available" and .status!="True")) | .metadata.name'

# Test API server responsiveness
time oc get nodes > /dev/null
```

### CI/CD Pipeline Testing

Execute test pipeline runs to validate CI/CD functionality.

```bash
# Create test namespace
oc new-project integration-test

# Run test pipeline
tkn pipeline start java-spring-boot-pipeline \
  --param git-url=https://github.com/sample/app.git \
  --workspace name=shared-workspace,claimName=test-pvc \
  -n integration-test

# Monitor pipeline
tkn pipelinerun logs -f -n integration-test
```

### GitOps Sync Validation

Verify ArgoCD synchronization is working correctly.

```bash
# Test ArgoCD sync
argocd app sync test-app
argocd app wait test-app --health --timeout 300

# Verify application health
argocd app get test-app
```

## Functional Testing

### Authentication Testing

Validate LDAP authentication and RBAC.

```bash
# Test LDAP login
oc login -u test-user -p <password> https://api.ocp-prod.example.com:6443

# Verify group membership
oc get groups

# Test RBAC permissions
oc auth can-i create pods --namespace=test-app
```

### Monitoring Validation

Verify metrics collection and alerting.

```bash
# Query Prometheus
curl -s -k -H "Authorization: Bearer $(oc whoami -t)" \
  "https://prometheus-k8s-openshift-monitoring.apps.ocp-prod.example.com/api/v1/query?query=up"

# Test alert routing
# Trigger test alert via Alertmanager API
```

## Performance Testing

### Load Testing

Execute load tests against the platform.

```bash
# Deploy load testing tools
oc apply -f manifests/load-test-job.yaml

# Monitor resource utilization during load test
oc adm top nodes
oc adm top pods -A
```

### Baseline Metrics

Record baseline performance metrics.

<!-- TABLE_CONFIG: widths=[30, 25, 25, 20] -->
| Metric | Target | Baseline | Status |
|--------|--------|----------|--------|
| API Response Time | < 500ms | 250ms | Pass |
| Pod Startup Time | < 45s | 30s | Pass |
| Pipeline Duration | < 15min | 12min | Pass |
| Image Pull Time | < 30s | 15s | Pass |

# Security Validation

This section covers security testing and compliance verification.

## Security Scanning

### Infrastructure Security Scan

Run security scans against the cluster.

```bash
# Run compliance operator scan
oc apply -f manifests/compliance-scan.yaml

# Check scan results
oc get compliancescans -n openshift-compliance
oc get compliancecheckresults -n openshift-compliance
```

### Container Image Scanning

Verify image scanning is operational in Quay.

```bash
# Check Quay vulnerability scan results
# Navigate to Quay UI -> Repository -> Security Scan

# Verify Clair is operational
oc get pods -n quay-enterprise | grep clair
```

## Compliance Verification

### Pod Security Validation

Verify pod security admission is enforced.

```bash
# Test privileged pod rejection
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: privileged-test
spec:
  containers:
  - name: test
    image: nginx
    securityContext:
      privileged: true
EOF
# Expected: Rejected by admission controller

# Verify PSA labels on namespaces
oc get namespaces -o json | jq '.items[] | select(.metadata.labels["pod-security.kubernetes.io/enforce"] != null) | .metadata.name'
```

### Network Policy Verification

Verify network policies are enforced.

```bash
# Test network isolation between namespaces
# From pod in namespace-a, try to reach pod in namespace-b
oc exec -n namespace-a test-pod -- curl -s http://service.namespace-b.svc.cluster.local

# Expected: Connection refused (if network policy blocks)
```

## Encryption Verification

### Data at Rest Encryption

Verify etcd and storage encryption.

```bash
# Check etcd encryption
oc get apiserver cluster -o jsonpath='{.spec.encryption.type}'

# Verify storage class encryption
oc get storageclass -o yaml | grep encrypted
```

### Data in Transit Encryption

Verify TLS is enforced for all communications.

```bash
# Check ingress TLS configuration
oc get routes -A -o json | jq '.items[] | select(.spec.tls == null) | .metadata.name'
# Expected: Empty (all routes should have TLS)

# Verify service mesh mTLS
oc get peerauthentications -A
```

# Migration & Cutover

This section covers the containerization and deployment of pilot applications.

## Containerization Guidelines

### Application Assessment

Assess applications for containerization readiness.

```bash
# Review containerization checklist:
# - [ ] Application can run in non-root container
# - [ ] Configuration externalized (env vars or configmaps)
# - [ ] No local file dependencies
# - [ ] Health check endpoints available
# - [ ] Logs written to stdout/stderr
```

### Dockerfile Templates

Use standardized Dockerfile templates.

```dockerfile
# Java Spring Boot Template
FROM registry.access.redhat.com/ubi8/openjdk-17:latest
COPY target/*.jar app.jar
EXPOSE 8080
USER 1001
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```dockerfile
# Node.js Template
FROM registry.access.redhat.com/ubi8/nodejs-18:latest
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
USER 1001
CMD ["node", "server.js"]
```

## Deployment Manifests

### Kubernetes Manifest Templates

Use Helm charts or Kustomize for application deployment.

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  labels:
    app.kubernetes.io/name: sample-app
    app.kubernetes.io/component: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
        - name: sample-app
          image: quay.apps.ocp-prod.example.com/apps/sample-app:v1.0.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 5
```

## Migration Workflow

### Step-by-Step Migration

Follow this workflow for each application migration.

```bash
# 1. Create namespace
oc new-project sample-app

# 2. Configure namespace quotas and limits
oc apply -f manifests/resource-quota.yaml -n sample-app
oc apply -f manifests/limit-range.yaml -n sample-app

# 3. Create secrets and configmaps
oc create secret generic sample-app-secrets \
  --from-literal=db-password=<password> \
  -n sample-app

oc create configmap sample-app-config \
  --from-file=application.properties \
  -n sample-app

# 4. Deploy application via ArgoCD
# Add to GitOps repository and sync

# 5. Configure route
oc expose svc/sample-app -n sample-app
oc get route -n sample-app

# 6. Validate deployment
curl -k https://sample-app.apps.ocp-prod.example.com/health
```

# Operational Handover

This section covers the transition from implementation to ongoing operations.

## Monitoring Dashboard Access

### Key Dashboards

Access monitoring dashboards for operational visibility.

```bash
# OpenShift Console
oc get routes -n openshift-console

# Prometheus
oc get routes -n openshift-monitoring prometheus-k8s

# Grafana
oc get routes -n openshift-monitoring grafana

# Kibana (Logging)
oc get routes -n openshift-logging kibana

# ArgoCD
oc get routes -n openshift-gitops openshift-gitops-server

# Kiali (Service Mesh)
oc get routes -n istio-system kiali
```

### Key Metrics to Monitor

The following metrics should be monitored continuously.

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Cluster CPU Utilization | > 80% | Warning | Add worker nodes |
| Cluster Memory | > 85% | Warning | Scale or optimize |
| Node Not Ready | Any node | Critical | Investigate immediately |
| etcd Latency | > 150ms p99 | Warning | Check storage |
| Pod Crash Loop | > 5 restarts | Warning | Check app logs |

## Support Transition

### Support Model

The following support model applies post-implementation.

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Initial triage, known issues | Client IT | 15 minutes |
| L2 | Platform troubleshooting | Platform Ops | 1 hour |
| L3 | Complex issues | Red Hat Support | 4 hours (Premium) |
| L4 | Engineering escalation | Red Hat Engineering | Next business day |

### Escalation Contacts

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Platform Lead | [NAME] | platform@company.com | [PHONE] |
| Project Manager | [NAME] | pm@company.com | [PHONE] |
| Red Hat Support | Support Portal | support.redhat.com | N/A |

# Training Program

## Training Schedule

The following training modules are scheduled for delivery.

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | OpenShift Architecture | Admins | 4 | ILT | None |
| TRN-002 | Cluster Administration | Admins | 8 | Hands-On | TRN-001 |
| TRN-003 | Monitoring & Troubleshooting | Ops | 4 | Hands-On | TRN-002 |
| TRN-004 | GitOps with ArgoCD | DevOps | 4 | Hands-On | TRN-001 |
| TRN-005 | CI/CD Pipelines | Developers | 4 | Hands-On | None |
| TRN-006 | Container Fundamentals | Developers | 4 | VILT | None |

## Training Materials

The following training materials are provided.

- Administrator Guide (PDF)
- Developer Quick Start Guide
- CI/CD Pipeline Templates
- Video tutorials (recorded sessions)
- Runbook for common operations

# Appendices

## Appendix A: Common Commands

### Cluster Administration

```bash
# Node management
oc get nodes
oc describe node <node-name>
oc adm drain <node-name> --ignore-daemonsets --delete-emptydir-data
oc adm uncordon <node-name>

# Cluster operators
oc get clusteroperators
oc describe clusteroperator <operator-name>

# Cluster version
oc get clusterversion
oc adm upgrade
```

### Application Management

```bash
# Deployments
oc get deployments -A
oc rollout status deployment/<name>
oc rollout restart deployment/<name>
oc rollout undo deployment/<name>

# Pods
oc get pods -A
oc logs <pod-name> -c <container>
oc exec -it <pod-name> -- /bin/bash
oc describe pod <pod-name>
```

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Node NotReady | Network or kubelet issue | Check node conditions, restart kubelet |
| ImagePullBackOff | Registry auth or network | Check pull secret, registry connectivity |
| CrashLoopBackOff | Application error | Check pod logs, liveness probe config |
| Pending pods | Insufficient resources | Check resource quotas, node capacity |
| etcd leader election | Storage latency | Check storage performance, etcd logs |

### Diagnostic Commands

```bash
# Check cluster health
oc adm node-logs --role=master -u kubelet | tail -50
oc adm node-logs --role=master -u crio | tail -50

# Check etcd
oc get etcd -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Ready")]}{.status}{"\n"}{end}'

# Check certificates
oc get certificatesigningrequests

# Must-gather for Red Hat support
oc adm must-gather
```

## Appendix C: Backup and Recovery

### etcd Backup Procedure

```bash
# SSH to a master node
ssh -i ~/.ssh/ocp-cluster core@<master-ip>

# Create etcd backup
sudo /usr/local/bin/cluster-backup.sh /home/core/backup

# Copy backup off-node
scp -i ~/.ssh/ocp-cluster core@<master-ip>:/home/core/backup/* ./backups/
```

### etcd Recovery Procedure

```bash
# For single node failure, replace the node
# For full cluster recovery, use etcd restore procedure
# See Red Hat documentation: https://docs.openshift.com/container-platform/4.14/backup_and_restore/
```

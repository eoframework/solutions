# Scripts - IBM OpenShift Container Platform

## Overview

This directory contains automation scripts and utilities for IBM OpenShift Container Platform solution deployment, testing, and operations. Leveraging Red Hat OpenShift, IBM Cloud services, Kubernetes operators, and DevOps automation for comprehensive container orchestration, application deployment, and platform management.

---

## Script Categories

### Infrastructure Scripts
- **cluster-deployment.sh** - OpenShift cluster deployment and configuration
- **node-management.py** - Worker node scaling and management automation
- **storage-setup.py** - Persistent storage and storage class configuration
- **network-policy-setup.py** - Network policies and security configuration
- **infrastructure-scaling.py** - Cluster autoscaling and resource management

### Platform Configuration Scripts
- **operator-deployment.py** - OpenShift operator installation and management
- **registry-setup.py** - Container image registry configuration
- **service-mesh-config.py** - Istio/OpenShift Service Mesh configuration
- **ingress-setup.py** - Route and ingress controller configuration
- **rbac-configuration.py** - Role-based access control setup

### Application Deployment Scripts
- **helm-deployment.py** - Helm chart deployment and management
- **kustomize-deployment.py** - Kustomize-based application deployment
- **operator-sdk-automation.py** - Custom operator development and deployment
- **gitops-setup.py** - ArgoCD/Tekton GitOps pipeline configuration
- **application-lifecycle.py** - Application lifecycle management automation

### CI/CD Pipeline Scripts
- **tekton-pipeline-setup.py** - Tekton Pipelines deployment and configuration
- **jenkins-integration.py** - Jenkins CI/CD integration with OpenShift
- **argocd-setup.py** - ArgoCD GitOps deployment automation
- **buildah-podman-scripts.py** - Container build automation with Buildah/Podman
- **pipeline-automation.py** - Automated pipeline creation and management

### Security Scripts
- **security-scanning.py** - Container and vulnerability scanning automation
- **policy-enforcement.py** - Security policy and compliance enforcement
- **secrets-management.py** - Kubernetes secrets and encryption management
- **image-signing.py** - Container image signing and verification
- **compliance-automation.py** - Security compliance and audit automation

### Monitoring Scripts
- **prometheus-setup.py** - Prometheus monitoring stack deployment
- **grafana-dashboards.py** - Grafana dashboard automation and configuration
- **alertmanager-config.py** - Alert manager setup and notification routing
- **logging-setup.py** - EFK (Elasticsearch, Fluentd, Kibana) logging stack
- **observability-automation.py** - Comprehensive observability platform setup

### Testing Scripts
- **cluster-validation.py** - OpenShift cluster validation and health checks
- **application-testing.py** - Automated application testing in OpenShift
- **performance-testing.py** - Cluster and application performance testing
- **disaster-recovery-testing.py** - DR procedures testing and validation
- **chaos-engineering.py** - Chaos engineering and resilience testing

### Operations Scripts
- **backup-management.py** - Cluster and application backup automation
- **upgrade-automation.py** - OpenShift cluster upgrade automation
- **cost-optimization.py** - Resource optimization and cost management
- **health-monitoring.py** - Platform health monitoring and alerting
- **maintenance-automation.py** - Automated maintenance and patching

---

## Prerequisites

### Required Tools
- **oc CLI** - OpenShift command-line interface
- **kubectl** - Kubernetes command-line tool  
- **Helm 3+** - Kubernetes package manager
- **Python 3.9+** - Python runtime environment
- **Ansible 2.12+** - Automation platform for configuration management
- **Git** - Version control system
- **Docker/Podman** - Container runtime tools

### Platform Requirements
- Red Hat OpenShift Container Platform 4.12+
- IBM Cloud (for IBM Cloud OpenShift Service)
- Red Hat Subscription (for on-premises installations)
- Kubernetes 1.25+ (underlying orchestration)
- Container runtime (CRI-O recommended)
- Persistent storage (block, file, or object storage)

### Python Dependencies
```bash
pip install openshift kubernetes ansible-core pyyaml requests
pip install prometheus-client grafana-api helm-cli jinja2
pip install click typer rich pandas numpy
```

### CLI Tools Installation
```bash
# Install OpenShift CLI
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
tar -xzf openshift-client-linux.tar.gz
sudo mv oc kubectl /usr/local/bin/

# Install Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz | tar -xz
sudo mv linux-amd64/helm /usr/local/bin/

# Install Ansible
pip install ansible-core
ansible-galaxy collection install kubernetes.core community.okd
```

### Configuration
```bash
# Set environment variables
export KUBECONFIG="/path/to/your/kubeconfig"
export OPENSHIFT_CLUSTER_URL="https://api.cluster.example.com:6443"
export OPENSHIFT_TOKEN="your-access-token"
export REGISTRY_URL="image-registry.openshift-image-registry.svc:5000"
export CLUSTER_NAME="production-cluster"
export ENVIRONMENT="production"

# Verify cluster access
oc login --token=$OPENSHIFT_TOKEN --server=$OPENSHIFT_CLUSTER_URL
oc cluster-info
```

---

## Usage Instructions

### Cluster Deployment and Setup
```bash
# Deploy OpenShift cluster (IPI - Installer Provisioned Infrastructure)
./cluster-deployment.sh \
  --platform aws \
  --region us-east-1 \
  --cluster-name $CLUSTER_NAME \
  --base-domain example.com \
  --worker-nodes 3 \
  --master-nodes 3

# Configure worker node scaling
python node-management.py \
  --cluster-name $CLUSTER_NAME \
  --scale-workers 5 \
  --instance-type m5.xlarge \
  --enable-autoscaling \
  --min-nodes 3 \
  --max-nodes 10

# Setup persistent storage
python storage-setup.py \
  --storage-classes gp3,efs,ebs-csi \
  --default-storage-class gp3 \
  --enable-dynamic-provisioning \
  --backup-storage-class gp2

# Configure network policies
python network-policy-setup.py \
  --network-plugin ovn-kubernetes \
  --ingress-policies ./policies/ingress-rules.yaml \
  --egress-policies ./policies/egress-rules.yaml \
  --enable-network-segmentation
```

### Platform Configuration
```bash
# Deploy core operators
python operator-deployment.py \
  --operators elasticsearch,jaeger,kiali,service-mesh \
  --operator-source redhat-operators \
  --automatic-updates enabled \
  --approval-strategy automatic

# Setup container registry
python registry-setup.py \
  --internal-registry \
  --external-registry-integration harbor,quay \
  --image-pruning-policy 30-days \
  --enable-image-scanning

# Configure service mesh
python service-mesh-config.py \
  --service-mesh-version 2.4 \
  --enable-mtls \
  --traffic-policies ./config/traffic-policies.yaml \
  --observability-addons prometheus,grafana,jaeger

# Setup ingress and routing
python ingress-setup.py \
  --ingress-controller haproxy \
  --default-certificate wildcard-cert \
  --load-balancer-type nlb \
  --ssl-termination edge

# Configure RBAC
python rbac-configuration.py \
  --rbac-policies ./config/rbac-policies.yaml \
  --service-accounts ./config/service-accounts.yaml \
  --cluster-roles ./config/cluster-roles.yaml \
  --enable-pod-security-standards
```

### Application Deployment
```bash
# Deploy applications using Helm
python helm-deployment.py \
  --chart-repository bitnami,stable \
  --applications ./deployments/helm-apps.yaml \
  --values-files ./values/ \
  --namespace-creation automatic

# Deploy with Kustomize
python kustomize-deployment.py \
  --kustomization-dirs ./k8s/overlays/production \
  --base-dirs ./k8s/base \
  --apply-manifests \
  --validate-resources

# Custom operator deployment
python operator-sdk-automation.py \
  --operator-definition ./operators/custom-operator \
  --build-operator \
  --deploy-olm \
  --create-subscription

# Setup GitOps with ArgoCD
python gitops-setup.py \
  --argocd-namespace openshift-gitops \
  --git-repository https://github.com/company/k8s-manifests \
  --applications ./gitops/applications.yaml \
  --sync-policy automatic

# Application lifecycle management
python application-lifecycle.py \
  --lifecycle-policies ./config/app-lifecycle.yaml \
  --blue-green-deployments \
  --canary-releases \
  --rollback-strategies
```

### CI/CD Pipeline Configuration
```bash
# Setup Tekton Pipelines
python tekton-pipeline-setup.py \
  --pipeline-definitions ./pipelines/tekton/ \
  --task-definitions ./tasks/ \
  --triggers ./triggers/ \
  --workspace-templates ./workspaces/

# Jenkins integration
python jenkins-integration.py \
  --jenkins-namespace jenkins \
  --openshift-sync-plugin \
  --pipeline-libraries ./jenkins/libraries \
  --slave-images custom-jenkins-slave

# ArgoCD deployment automation
python argocd-setup.py \
  --argocd-version v2.8.4 \
  --high-availability \
  --sso-integration oauth \
  --repository-credentials ./secrets/git-credentials.yaml

# Container build automation
python buildah-podman-scripts.py \
  --build-configs ./builds/ \
  --base-images registry.access.redhat.com/ubi8/ubi \
  --push-registry $REGISTRY_URL \
  --security-scanning enabled

# Pipeline automation
python pipeline-automation.py \
  --pipeline-templates ./templates/pipelines/ \
  --trigger-types webhook,schedule,manual \
  --notification-channels slack,email \
  --quality-gates sonarqube,security-scan
```

### Security Configuration
```bash
# Container security scanning
python security-scanning.py \
  --scanning-tools clair,twistlock,aqua \
  --vulnerability-database oval,cve \
  --scan-policies ./config/scan-policies.yaml \
  --compliance-frameworks cis,nist

# Security policy enforcement
python policy-enforcement.py \
  --pod-security-standards restricted \
  --network-policies default-deny \
  --security-context-constraints custom-scc \
  --admission-controllers ./config/admission-controllers.yaml

# Secrets management
python secrets-management.py \
  --secrets-store external-secrets-operator \
  --vault-integration hashicorp-vault \
  --encryption-at-rest aes256 \
  --secret-rotation-policy 90-days

# Image signing and verification
python image-signing.py \
  --signing-tool cosign \
  --signature-store registry \
  --verification-policies ./config/image-policies.yaml \
  --key-management ./keys/

# Compliance automation
python compliance-automation.py \
  --compliance-frameworks pci-dss,sox,hipaa \
  --audit-policies ./config/audit-policies.yaml \
  --evidence-collection automated \
  --reporting-schedule monthly
```

### Monitoring and Observability
```bash
# Deploy Prometheus monitoring
python prometheus-setup.py \
  --prometheus-namespace openshift-monitoring \
  --retention-period 30-days \
  --storage-class gp3 \
  --alert-rules ./monitoring/alerts/ \
  --service-monitors ./monitoring/service-monitors/

# Configure Grafana dashboards
python grafana-dashboards.py \
  --dashboard-repository ./dashboards/ \
  --datasources prometheus,elasticsearch \
  --dashboard-categories infrastructure,applications,security \
  --enable-alerting

# Setup Alertmanager
python alertmanager-config.py \
  --alertmanager-config ./config/alertmanager.yaml \
  --notification-channels pagerduty,slack,email \
  --routing-rules ./config/alert-routing.yaml \
  --silence-rules ./config/alert-silences.yaml

# Configure logging stack
python logging-setup.py \
  --logging-stack efk \
  --elasticsearch-storage 100Gi \
  --log-retention 14-days \
  --kibana-dashboards ./logging/dashboards/ \
  --log-forwarding ./config/log-forwarding.yaml

# Comprehensive observability
python observability-automation.py \
  --tracing-system jaeger \
  --metrics-collection prometheus \
  --logging-system fluentd \
  --service-mesh-integration istio \
  --custom-metrics ./config/custom-metrics.yaml
```

### Testing and Validation
```bash
# Cluster validation
python cluster-validation.py \
  --validation-suite comprehensive \
  --health-checks nodes,pods,services,ingress \
  --performance-benchmarks \
  --security-checks \
  --generate-report

# Application testing
python application-testing.py \
  --test-suites unit,integration,e2e \
  --test-environments staging,production \
  --load-testing-scenarios ./tests/load-tests.yaml \
  --chaos-testing-experiments ./tests/chaos-experiments.yaml

# Performance testing
python performance-testing.py \
  --benchmark-tools k6,artillery,jmeter \
  --performance-targets ./config/performance-sla.yaml \
  --resource-utilization-tests \
  --scalability-tests \
  --results-reporting

# Disaster recovery testing
python disaster-recovery-testing.py \
  --backup-restore-testing \
  --cross-region-failover \
  --data-consistency-checks \
  --rto-rpo-validation \
  --automated-recovery-procedures

# Chaos engineering
python chaos-engineering.py \
  --chaos-tools chaos-mesh,litmus \
  --chaos-experiments ./chaos/experiments/ \
  --failure-scenarios network,pod,node \
  --resilience-validation \
  --automated-recovery-testing
```

### Operations and Maintenance
```bash
# Backup management
python backup-management.py \
  --backup-tools velero,etcd-backup \
  --backup-schedule daily \
  --backup-retention 30-days \
  --cross-region-backup \
  --backup-validation

# Cluster upgrade automation
python upgrade-automation.py \
  --upgrade-strategy rolling \
  --target-version 4.13.12 \
  --pre-upgrade-checks \
  --rollback-procedures \
  --post-upgrade-validation

# Cost optimization
python cost-optimization.py \
  --resource-rightsizing \
  --unused-resource-cleanup \
  --spot-instance-recommendations \
  --reserved-instance-analysis \
  --cost-allocation-reports

# Health monitoring
python health-monitoring.py \
  --monitoring-interval 60 \
  --health-checks cluster,nodes,applications \
  --alert-thresholds ./config/health-thresholds.yaml \
  --automated-remediation ./scripts/remediation/

# Maintenance automation
python maintenance-automation.py \
  --maintenance-windows ./config/maintenance-schedule.yaml \
  --patch-management automated \
  --certificate-renewal automatic \
  --cleanup-procedures ./scripts/cleanup/
```

---

## Directory Structure

```
scripts/
├── ansible/              # Ansible playbooks for OpenShift automation
├── bash/                 # Shell scripts for cluster operations
├── powershell/          # PowerShell scripts for Windows integration
├── python/              # Python scripts for API automation
└── terraform/           # Infrastructure as Code for cloud resources
    ├── aws/             # AWS-specific infrastructure
    ├── azure/           # Azure-specific infrastructure
    ├── gcp/             # GCP-specific infrastructure
    └── ibm-cloud/       # IBM Cloud-specific infrastructure
```

---

## OpenShift Operators and Custom Resources

### Core Operators Management
```bash
# Install and manage core operators
python operator-deployment.py \
  --core-operators cluster-logging,local-storage,ocs \
  --operator-lifecycle-manager \
  --automatic-updates \
  --operator-health-monitoring

# Custom Resource Definitions
python operator-sdk-automation.py \
  --crd-generation \
  --controller-logic ./controllers/ \
  --webhook-configuration \
  --operator-testing
```

### Application Operators
```bash
# Deploy application-specific operators
python operator-deployment.py \
  --app-operators postgresql,mongodb,kafka,elasticsearch \
  --operator-hub community-operators \
  --custom-catalogs ./catalogs/custom-operators.yaml
```

---

## Container Image Management

### Image Build and Registry
```bash
# Automated image builds
python buildah-podman-scripts.py \
  --multi-stage-builds \
  --security-hardening \
  --vulnerability-scanning \
  --image-optimization \
  --build-cache-management

# Registry management
python registry-setup.py \
  --image-lifecycle-policies \
  --garbage-collection \
  --replication-policies \
  --access-control-policies
```

### Image Security
```bash
# Image signing and verification
python image-signing.py \
  --signing-workflow automated \
  --keyless-signing \
  --policy-enforcement \
  --audit-trail

# Security scanning
python security-scanning.py \
  --continuous-scanning \
  --policy-based-blocking \
  --vulnerability-reporting \
  --remediation-recommendations
```

---

## GitOps and Continuous Deployment

### ArgoCD Configuration
```bash
# Advanced ArgoCD setup
python argocd-setup.py \
  --multi-cluster-deployment \
  --application-sets \
  --progressive-delivery \
  --rbac-integration \
  --webhook-notifications

# ApplicationSet automation
python gitops-setup.py \
  --application-sets ./applicationsets/ \
  --cluster-generators \
  --git-generators \
  --automated-sync-policies
```

### Tekton Pipelines
```bash
# Advanced pipeline configurations
python tekton-pipeline-setup.py \
  --pipeline-as-code \
  --multi-arch-builds \
  --parallel-execution \
  --conditional-tasks \
  --pipeline-metrics
```

---

## Multi-Cluster Management

### Cluster Federation
```bash
# Multi-cluster operations
python cluster-deployment.sh \
  --multi-cluster-deployment \
  --cluster-federation \
  --cross-cluster-networking \
  --workload-distribution

# Advanced Cluster Management (ACM)
python infrastructure-scaling.py \
  --acm-integration \
  --policy-governance \
  --application-lifecycle \
  --observability-across-clusters
```

---

## Error Handling and Troubleshooting

### Common Issues

#### Cluster Access Problems
```bash
# Debug cluster connectivity
oc cluster-info dump --output-directory=/tmp/cluster-dump
oc get nodes -o wide
oc describe node node-name

# Certificate issues
oc get certificates --all-namespaces
python rbac-configuration.py --debug-auth --validate-tokens
```

#### Application Deployment Failures
```bash
# Debug application issues
oc describe pod pod-name -n namespace
oc logs pod-name -c container-name -n namespace --previous
python application-testing.py --debug-mode --verbose-logging
```

#### Storage Issues
```bash
# Storage troubleshooting
oc get pv,pvc --all-namespaces
oc describe storageclass storage-class-name
python storage-setup.py --validate-storage --repair-issues
```

#### Network Connectivity Issues
```bash
# Network debugging
oc get network.operator/cluster -o yaml
oc get clusternetwork
python network-policy-setup.py --validate-connectivity --trace-routes
```

### Monitoring Commands
```bash
# Cluster health checks
oc adm node-logs node-name --tail=50
oc get events --sort-by='.lastTimestamp' --all-namespaces
oc get clusteroperators

# Resource utilization
oc adm top nodes
oc adm top pods --all-namespaces --sort-by=memory
```

---

## Best Practices and Recommendations

### Security Best Practices
- Use Security Context Constraints (SCCs) appropriately
- Implement Pod Security Standards
- Enable image scanning and policy enforcement
- Use service accounts with minimal privileges
- Implement network policies for microsegmentation
- Regular security audits and penetration testing

### Performance Optimization
- Right-size resources based on actual usage
- Use horizontal and vertical pod autoscaling
- Implement proper resource requests and limits
- Optimize container images for size and efficiency
- Use persistent volume claims efficiently
- Monitor and optimize network policies

### Operational Excellence
- Implement comprehensive monitoring and alerting
- Use GitOps for configuration management
- Automate backup and disaster recovery procedures
- Regular cluster upgrades and patching
- Implement proper logging and observability
- Use infrastructure as code for reproducible deployments

### Cost Management
- Implement resource quotas and limits
- Use cluster autoscaling for dynamic workloads
- Monitor and optimize storage usage
- Use spot/preemptible instances where appropriate
- Regular cost analysis and optimization reviews

---

## Integration Ecosystem

### IBM Cloud Services
- IBM Cloud Container Registry
- IBM Cloud Databases
- IBM Cloud Object Storage
- IBM Watson AI services
- IBM Security services

### Red Hat Ecosystem
- Red Hat Quay (container registry)
- Red Hat Advanced Cluster Management
- Red Hat OpenShift Data Foundation
- Red Hat Service Mesh
- Red Hat Build of Tekton

### Third-party Integrations
- HashiCorp Vault (secrets management)
- GitLab/GitHub (source control)
- Slack/Microsoft Teams (notifications)
- PagerDuty (incident management)
- Datadog/New Relic (monitoring)

---

**Directory Version**: 1.0  
**Last Updated**: January 2025  
**Maintained By**: IBM OpenShift Platform DevOps Team
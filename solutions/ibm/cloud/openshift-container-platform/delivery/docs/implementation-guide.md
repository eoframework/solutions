# IBM OpenShift Container Platform Implementation Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Infrastructure Planning](#infrastructure-planning)
4. [Installation Procedures](#installation-procedures)
5. [Post-Installation Configuration](#post-installation-configuration)
6. [Integration Setup](#integration-setup)
7. [Security Configuration](#security-configuration)
8. [Monitoring and Logging](#monitoring-and-logging)
9. [Backup and Recovery](#backup-and-recovery)
10. [Troubleshooting](#troubleshooting)

## Overview

This implementation guide provides step-by-step procedures for deploying Red Hat OpenShift Container Platform on IBM infrastructure. The guide covers both on-premises IBM hardware deployments and IBM Cloud implementations, including hybrid cloud configurations.

### Solution Architecture
- **Platform**: Red Hat OpenShift Container Platform 4.x
- **Infrastructure**: IBM Power Systems, IBM Z, x86_64 on IBM Cloud
- **Storage**: IBM Spectrum Scale, IBM Cloud Object Storage, IBM Block Storage
- **Networking**: IBM Cloud Virtual Private Cloud (VPC), IBM Cloud Direct Link
- **Security**: IBM Security Guardium, IBM Key Protect, Red Hat Advanced Cluster Security

## Prerequisites

### Technical Requirements

#### Hardware Requirements (On-Premises)
- **Master Nodes**: Minimum 3 nodes
  - CPU: 4 cores minimum, 8 cores recommended
  - Memory: 16 GB minimum, 32 GB recommended
  - Storage: 120 GB minimum for OS, 500 GB for etcd
- **Worker Nodes**: Minimum 2 nodes
  - CPU: 2 cores minimum, 8 cores recommended
  - Memory: 8 GB minimum, 32 GB recommended
  - Storage: 120 GB minimum for OS, additional for container images
- **Infrastructure Nodes**: 3 nodes recommended
  - CPU: 4 cores minimum
  - Memory: 16 GB minimum
  - Storage: 120 GB minimum

#### IBM Cloud Requirements
- **IBM Cloud Account** with sufficient credits
- **Resource Groups** configured
- **VPC and Subnets** planned and created
- **Security Groups** configured for OpenShift traffic
- **Load Balancers** for API and ingress traffic

#### Network Requirements
- **DNS**: Wildcard DNS entries for cluster domain
- **Load Balancing**: External load balancer for API and ingress
- **Firewall Rules**: OpenShift required ports open
- **Internet Access**: For image pulls and operator installation

#### Software Prerequisites
- **Red Hat Subscription**: Valid OpenShift subscription
- **IBM Cloud CLI**: Latest version installed
- **OpenShift CLI (oc)**: Version matching cluster
- **Helm**: Version 3.x for application deployment
- **Ansible**: For automation tasks (if using)

### Access Requirements
- **IBM Cloud IAM**: Administrator access to target resource group
- **Red Hat Customer Portal**: Access to container images and operators
- **DNS Management**: Access to configure DNS records
- **Certificate Management**: Access to SSL/TLS certificate authorities

## Infrastructure Planning

### Network Architecture

#### IBM Cloud VPC Configuration
```yaml
VPC Configuration:
  - Region: Select based on compliance/latency requirements
  - Zones: Minimum 3 availability zones for HA
  - CIDR Blocks:
    - VPC: 10.0.0.0/16
    - Master Subnet: 10.0.1.0/24 (per zone)
    - Worker Subnet: 10.0.2.0/24 (per zone)
    - Service Network: 172.30.0.0/16
    - Pod Network: 10.128.0.0/14
```

#### Security Group Rules
```bash
# API Server (Masters)
Port 6443/tcp - Source: Load balancer subnet
Port 22623/tcp - Source: Worker and bootstrap nodes

# etcd (Masters)
Port 2379-2380/tcp - Source: Master nodes

# Kubelet (All nodes)
Port 10250/tcp - Source: Master nodes and other kubelets

# Ingress (Workers)
Port 80/tcp - Source: Internet or specific CIDR
Port 443/tcp - Source: Internet or specific CIDR
Port 30000-32767/tcp - Source: Internal traffic
```

### Storage Planning

#### IBM Cloud Storage Classes
```yaml
# High-performance SSD storage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ibm-vpc-block-10iops-tier
provisioner: vpc.block.csi.ibm.io
parameters:
  profile: 10iops-tier
  csi.storage.k8s.io/fstype: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Delete
```

#### IBM Spectrum Scale Integration
```yaml
# IBM Spectrum Scale StorageClass
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ibm-spectrum-scale
provisioner: spectrumscale.csi.ibm.com
parameters:
  volBackendFs: "gpfs01"
  clusterId: "12345678901234567890123456789012"
allowVolumeExpansion: true
volumeBindingMode: Immediate
```

## Installation Procedures

### Step 1: Environment Preparation

#### 1.1 IBM Cloud Setup
```bash
# Install IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Login to IBM Cloud
ibmcloud login --apikey <your-api-key>

# Target resource group and region
ibmcloud target -g <resource-group> -r <region>

# Install VPC infrastructure plugin
ibmcloud plugin install vpc-infrastructure
```

#### 1.2 DNS Configuration
```bash
# Create DNS zone (if using IBM Cloud DNS)
ibmcloud dns zone-create openshift.example.com

# Add A records for API
ibmcloud dns resource-record-create <zone-id> \
  --type A \
  --name api \
  --rdata <load-balancer-ip> \
  --ttl 300

# Add wildcard record for applications
ibmcloud dns resource-record-create <zone-id> \
  --type A \
  --name "*.apps" \
  --rdata <ingress-load-balancer-ip> \
  --ttl 300
```

### Step 2: OpenShift Installation

#### 2.1 IPI (Installer-Provisioned Infrastructure) on IBM Cloud
```bash
# Download OpenShift installer
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz
tar -xzf openshift-install-linux.tar.gz

# Create installation directory
mkdir openshift-cluster
cd openshift-cluster

# Generate install-config.yaml
./openshift-install create install-config --dir=.
```

#### 2.2 Install Configuration Template
```yaml
# install-config.yaml for IBM Cloud
apiVersion: v1
baseDomain: example.com
metadata:
  name: openshift-cluster
compute:
- hyperthreading: Enabled
  name: worker
  platform:
    ibmcloud:
      type: bx2-4x16
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  platform:
    ibmcloud:
      type: bx2-4x16
  replicas: 3
platform:
  ibmcloud:
    region: us-south
    subnets:
    - openshift-cluster-subnet-1
    - openshift-cluster-subnet-2
    - openshift-cluster-subnet-3
    resourceGroupName: openshift-rg
pullSecret: '<your-pull-secret>'
sshKey: '<your-ssh-public-key>'
```

#### 2.3 Cluster Installation
```bash
# Create cluster
./openshift-install create cluster --dir=. --log-level=info

# Monitor installation progress
export KUBECONFIG=./auth/kubeconfig
oc get nodes
oc get clusteroperators
```

### Step 3: UPI (User-Provisioned Infrastructure) Installation

#### 3.1 Infrastructure Components
```bash
# Create VPC infrastructure
ibmcloud is vpc-create openshift-vpc --resource-group-name openshift-rg

# Create subnets in multiple zones
for zone in 1 2 3; do
  ibmcloud is subnet-create openshift-subnet-${zone} \
    openshift-vpc \
    --zone us-south-${zone} \
    --ipv4-address-count 256 \
    --resource-group-name openshift-rg
done

# Create security groups
ibmcloud is security-group-create openshift-master-sg openshift-vpc
ibmcloud is security-group-create openshift-worker-sg openshift-vpc
```

#### 3.2 Load Balancer Configuration
```bash
# Create application load balancer for API
ibmcloud is load-balancer-create openshift-api-lb \
  --subnet openshift-subnet-1 \
  --subnet openshift-subnet-2 \
  --subnet openshift-subnet-3 \
  --type application \
  --resource-group-name openshift-rg

# Configure backend pools and listeners
ibmcloud is load-balancer-pool-create api-pool openshift-api-lb \
  --algorithm round_robin \
  --protocol tcp \
  --health-monitor-type tcp \
  --health-monitor-port 6443

# Create listener for API traffic
ibmcloud is load-balancer-listener-create openshift-api-lb \
  --protocol tcp \
  --port 6443 \
  --default-pool api-pool
```

## Post-Installation Configuration

### Step 4: IBM Cloud Integration

#### 4.1 Cloud Controller Manager Configuration
```yaml
# IBM Cloud Controller Manager
apiVersion: v1
kind: ConfigMap
metadata:
  name: ibm-cloud-config
  namespace: kube-system
data:
  config.ini: |
    [global]
    version = 1.1.0
    [kubernetes]
    config-file = ""
    [provider]
    cluster-default-provider = g2
    accountID = <your-account-id>
    clusterID = <your-cluster-id>
    region = us-south
    g2Credentials = <base64-encoded-credentials>
    g2ResourceGroupName = openshift-rg
    g2VpcName = openshift-vpc
```

#### 4.2 IBM Cloud Storage Configuration
```bash
# Install IBM VPC Block CSI Driver
oc apply -f https://raw.githubusercontent.com/kubernetes-sigs/ibm-vpc-block-csi-driver/master/deploy/kubernetes/driver/kubernetes/manifests/csi-driver.yaml

# Configure default storage class
oc patch storageclass ibm-vpc-block-10iops-tier -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### Step 5: Authentication and Authorization

#### 5.1 IBM Cloud IAM Integration
```yaml
# OAuth configuration for IBM Cloud IAM
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: IBM_Cloud_IAM
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: <client-id>
      clientSecret:
        name: ibm-cloud-iam-secret
      issuer: https://iam.cloud.ibm.com/identity
      claims:
        preferredUsername:
        - preferred_username
        name:
        - name
        email:
        - email
        groups:
        - groups
```

#### 5.2 RBAC Configuration
```yaml
# Cluster admin role binding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ibm-cloud-admins
subjects:
- kind: Group
  name: IBMid-94497d0d-2ac3-41bf-a993-a49d1b14627c
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

## Integration Setup

### Step 6: IBM Security Integration

#### 6.1 IBM Key Protect Integration
```bash
# Install IBM Key Protect operator
oc create -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ibm-key-protect-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: ibm-key-protect-operator
  source: certified-operators
  sourceNamespace: openshift-marketplace
EOF
```

#### 6.2 Advanced Cluster Security Integration
```bash
# Install Red Hat Advanced Cluster Security
oc create namespace stackrox
oc create -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhacs-operator
  namespace: stackrox
spec:
  channel: stable
  installPlanApproval: Automatic
  name: rhacs-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### Step 7: Monitoring and Observability

#### 7.1 IBM Cloud Monitoring Integration
```yaml
# LogDNA configuration
apiVersion: v1
kind: Secret
metadata:
  name: logdna-agent-key
  namespace: ibm-observe
type: Opaque
data:
  logdna-agent-key: <base64-encoded-ingestion-key>
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logdna-agent
  namespace: ibm-observe
spec:
  selector:
    matchLabels:
      app: logdna-agent
  template:
    metadata:
      labels:
        app: logdna-agent
    spec:
      containers:
      - name: logdna-agent
        image: logdna/logdna-agent:latest
        env:
        - name: LOGDNA_AGENT_KEY
          valueFrom:
            secretKeyRef:
              name: logdna-agent-key
              key: logdna-agent-key
        - name: LDLOGHOST
          value: logs.us-south.logging.cloud.ibm.com
        - name: LDLOGPATH
          value: /var/log
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

## Security Configuration

### Step 8: Security Hardening

#### 8.1 Security Context Constraints
```yaml
# Custom SCC for applications
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-restricted-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: []
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1000
  - max: 65535
readOnlyRootFilesystem: true
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1000
  - max: 65535
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

#### 8.2 Network Policies
```yaml
# Default deny network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
# Allow ingress from router
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-openshift-ingress
  namespace: production
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: openshift-ingress
  policyTypes:
  - Ingress
```

## Monitoring and Logging

### Step 9: Observability Setup

#### 9.1 Cluster Monitoring Configuration
```yaml
# Cluster monitoring config
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    prometheusK8s:
      retention: 15d
      volumeClaimTemplate:
        spec:
          storageClassName: ibm-vpc-block-5iops-tier
          resources:
            requests:
              storage: 100Gi
    alertmanagerMain:
      volumeClaimTemplate:
        spec:
          storageClassName: ibm-vpc-block-5iops-tier
          resources:
            requests:
              storage: 10Gi
```

#### 9.2 Application Monitoring
```yaml
# ServiceMonitor for custom applications
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: app-monitor
  namespace: production
spec:
  selector:
    matchLabels:
      app: my-application
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

## Backup and Recovery

### Step 10: Backup Configuration

#### 10.1 etcd Backup
```bash
#!/bin/bash
# Automated etcd backup script
BACKUP_DIR="/var/lib/etcd-backup/$(date +%Y%m%d)"
mkdir -p ${BACKUP_DIR}

# Create etcd snapshot
oc debug node/<master-node> -- chroot /host \
  /usr/local/bin/cluster-backup.sh ${BACKUP_DIR}

# Upload to IBM Cloud Object Storage
ibmcloud cos object-put \
  --bucket etcd-backup-bucket \
  --key "$(date +%Y%m%d)/backup.tar.gz" \
  --body "${BACKUP_DIR}/backup.tar.gz"
```

#### 10.2 Application Data Backup
```yaml
# Velero backup configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: velero-config
  namespace: velero
data:
  config: |
    {
      "region": "us-south",
      "bucket": "openshift-backup-bucket",
      "credentialsFile": "/tmp/credentials/credentials-velero"
    }
```

## Troubleshooting

### Common Issues and Resolutions

#### Issue 1: Node Not Ready
```bash
# Check node status
oc get nodes -o wide

# Check node conditions
oc describe node <node-name>

# Check kubelet logs
oc debug node/<node-name> -- journalctl -u kubelet
```

#### Issue 2: Pod CrashLoopBackOff
```bash
# Check pod logs
oc logs <pod-name> -c <container-name>

# Check pod events
oc describe pod <pod-name>

# Check resource constraints
oc top pod <pod-name>
```

#### Issue 3: Storage Issues
```bash
# Check PV status
oc get pv

# Check storage classes
oc get storageclass

# Check CSI driver pods
oc get pods -n kube-system | grep csi
```

### Support Contacts
- **Red Hat Support**: Access through Red Hat Customer Portal
- **IBM Cloud Support**: Create case through IBM Cloud console
- **Community Support**: OpenShift Commons, IBM Developer Community

### Additional Resources
- [Red Hat OpenShift Documentation](https://docs.openshift.com)
- [IBM Cloud Kubernetes Service Documentation](https://cloud.ibm.com/docs/containers)
- [OpenShift on IBM Power Documentation](https://www.ibm.com/support/knowledgecenter/power)
- [IBM Storage for Containers](https://www.ibm.com/cloud/storage)
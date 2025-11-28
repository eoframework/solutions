---
document_title: Implementation Guide
solution_name: NVIDIA GPU Compute Cluster with Kubernetes
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: nvidia
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides deployment procedures for the NVIDIA GPU Compute Cluster with Kubernetes. It covers server installation, Kubernetes deployment, NVIDIA GPU Operator configuration, and MLOps platform setup.

## Document Purpose

Technical reference for deploying 8 Dell R750xa servers with 32 A100 GPUs, Kubernetes, GPU Operator, Kubeflow, MLflow, and Triton.

## Implementation Approach

Phased deployment with Ansible automation, Helm charts for Kubernetes applications, and validation at each stage.

## Automation Framework Overview

The deployment leverages infrastructure-as-code and GitOps practices to ensure consistent, repeatable installations across all cluster nodes.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| Ansible | Server configuration | `scripts/ansible/` | Ansible 2.14+ |
| Helm | K8s app deployment | `scripts/helm/` | Helm 3.12+ |
| kubectl | Cluster management | CLI | Kubernetes access |

## Scope Summary

### In Scope

- 8x Dell R750xa with 32 A100 GPUs
- Kubernetes 1.28 with GPU Operator
- Kubeflow, MLflow, Triton deployment
- Monitoring with Prometheus/Grafana

### Out of Scope

- Custom model development
- Ongoing operations

## Timeline Overview

The implementation follows a phased approach with validation gates at each milestone to ensure quality and readiness before proceeding.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites | 1 week | Environment ready |
| 2 | Infrastructure | 3 weeks | Servers operational |
| 3 | Kubernetes | 2 weeks | Cluster ready |
| 4 | MLOps Stack | 2 weeks | Apps deployed |
| 5 | Testing | 1 week | Validation complete |

# Prerequisites

## Tool Installation

### Required Tools Checklist

- [ ] **kubectl** >= 1.28 - Kubernetes CLI
- [ ] **Helm** >= 3.12 - Package manager
- [ ] **Ansible** >= 2.14 - Configuration management

### Ansible Installation

```bash
# Install Ansible
pip install ansible

# Verify installation
ansible --version
```

### Helm Installation

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

## Prerequisite Validation

```bash
#!/bin/bash
# Check prerequisites
echo "Checking kubectl..."
kubectl version --client

echo "Checking Helm..."
helm version

echo "Checking Ansible..."
ansible --version
```

### Validation Checklist

- [ ] Network connectivity to all servers
- [ ] SSH access configured
- [ ] LDAP connectivity verified

# Environment Setup

## Ansible Inventory

```yaml
# inventory/hosts.yml
all:
  children:
    gpu_nodes:
      hosts:
        gpu-node-01:
          ansible_host: 10.100.0.101
        gpu-node-02:
          ansible_host: 10.100.0.102
        gpu-node-03:
          ansible_host: 10.100.0.103
        gpu-node-04:
          ansible_host: 10.100.0.104
        gpu-node-05:
          ansible_host: 10.100.0.105
        gpu-node-06:
          ansible_host: 10.100.0.106
        gpu-node-07:
          ansible_host: 10.100.0.107
        gpu-node-08:
          ansible_host: 10.100.0.108
    k8s_control:
      hosts:
        k8s-cp-01:
          ansible_host: 10.100.0.50
```

## SSH Configuration

```bash
# Generate SSH keys
ssh-keygen -t ed25519 -f ~/.ssh/gpu_cluster

# Copy to all nodes
for i in {1..8}; do
    ssh-copy-id -i ~/.ssh/gpu_cluster.pub admin@10.100.0.10${i}
done
```

# Infrastructure Deployment

## Deployment Overview

The infrastructure deployment follows a layered approach with dependencies between phases to ensure proper build order.

<!-- TABLE_CONFIG: widths=[15, 25, 35, 25] -->
| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | VLANs, RoCE config | None |
| 2 | Security | SSH, firewall | Networking |
| 3 | Compute | GPU servers, drivers | Security |
| 4 | Monitoring | Prometheus, DCGM | Compute |

## Phase 1: Networking Layer

### Network Configuration

```bash
# Configure RoCE on network switches
# Enable jumbo frames MTU 9000
# Configure VLAN for GPU traffic

# Verify network connectivity
ping -c 3 10.100.0.101
```

### Network Validation

```bash
# Test bandwidth between nodes
iperf3 -c gpu-node-02 -t 10

# Expected: >90 Gbps throughput
```

## Phase 2: Security Layer

### SSH Hardening

```bash
# Disable password authentication
ansible gpu_nodes -m lineinfile -a \
  "path=/etc/ssh/sshd_config regexp='^PasswordAuthentication' line='PasswordAuthentication no'"

# Restart SSH
ansible gpu_nodes -m service -a "name=sshd state=restarted"
```

### Firewall Configuration

```bash
# Allow Kubernetes ports
ufw allow 6443/tcp  # API server
ufw allow 10250/tcp # Kubelet
```

## Phase 3: Compute Layer

### GPU Driver Installation

```bash
# Install NVIDIA drivers
ansible-playbook playbooks/install-nvidia-drivers.yml

# Verify GPU detection
nvidia-smi
```

### GPU Validation

```bash
# Verify all 4 GPUs per node
nvidia-smi --query-gpu=name,memory.total --format=csv

# Expected output:
# NVIDIA A100-PCIE-40GB, 40960 MiB
# NVIDIA A100-PCIE-40GB, 40960 MiB
# NVIDIA A100-PCIE-40GB, 40960 MiB
# NVIDIA A100-PCIE-40GB, 40960 MiB
```

## Phase 4: Monitoring Layer

### Prometheus Installation

```bash
# Install Prometheus via Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus -n monitoring

# Verify installation
kubectl get pods -n monitoring
```

### DCGM Exporter

```bash
# Install DCGM exporter for GPU metrics
helm install dcgm-exporter nvidia/dcgm-exporter -n monitoring

# Verify GPU metrics
curl http://localhost:9400/metrics | grep DCGM
```

# Application Configuration

## Kubernetes Cluster Deployment

```bash
# Initialize Kubernetes cluster
kubeadm init --pod-network-cidr=10.244.0.0/16

# Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Join worker nodes
kubeadm join k8s-cp-01:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

## GPU Operator Installation

```bash
# Add NVIDIA Helm repo
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia

# Install GPU Operator
helm install gpu-operator nvidia/gpu-operator \
  --namespace gpu-operator \
  --create-namespace \
  --set driver.enabled=false  # Using pre-installed drivers

# Verify GPU resources
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPUs:.status.allocatable.'nvidia\.com/gpu'
```

## Kubeflow Installation

```bash
# Install Kubeflow
kustomize build kubeflow-manifests | kubectl apply -f -

# Verify Kubeflow pods
kubectl get pods -n kubeflow
```

## MLflow Deployment

```bash
# Deploy MLflow with Helm
helm install mlflow community/mlflow \
  --namespace mlflow \
  --set persistence.enabled=true

# Verify MLflow
kubectl get pods -n mlflow
```

## Triton Inference Server

```bash
# Deploy Triton
kubectl apply -f triton-deployment.yaml

# Verify Triton
kubectl get pods -n inference
```

# Integration Testing

## GPU Scheduling Test

```bash
# Create test pod requesting GPU
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  containers:
  - name: gpu-test
    image: nvidia/cuda:12.0-base
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1
EOF

# Check pod logs
kubectl logs gpu-test
```

## Distributed Training Test

```bash
# Run multi-GPU training test
kubectl apply -f distributed-training-job.yaml

# Monitor training
kubectl logs -f training-job-0
```

# Security Validation

## RBAC Validation

```bash
# Test user access
kubectl auth can-i create pods --as=data-scientist -n ds-namespace
# Expected: yes

kubectl auth can-i create pods --as=data-scientist -n admin-namespace
# Expected: no
```

## Network Policy Test

```bash
# Verify namespace isolation
kubectl exec -it test-pod -- curl other-namespace-svc
# Expected: Connection refused
```

# Migration & Cutover

## User Migration

```bash
# Create user namespaces
for team in nlp cv ml; do
  kubectl create namespace ${team}-team
  kubectl label namespace ${team}-team team=${team}
done

# Apply resource quotas
kubectl apply -f resource-quotas/
```

## Cutover Checklist

```bash
#!/bin/bash
# Go-live checklist
echo "Checking GPU availability..."
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPUs:.status.allocatable.'nvidia\.com/gpu'

echo "Checking Kubeflow..."
kubectl get pods -n kubeflow | grep Running

echo "Checking MLflow..."
kubectl get pods -n mlflow | grep Running
```

# Operational Handover

## Runbook Procedures

```bash
# Daily health check
kubectl get nodes
kubectl top nodes
kubectl get pods --all-namespaces | grep -v Running

# GPU health check
kubectl exec -it gpu-node-01 -- nvidia-smi
```

## Monitoring Dashboards

- Kubernetes: Grafana dashboard 3119
- GPU Metrics: DCGM dashboard
- MLflow: Built-in experiment UI

# Training Program

## Administrator Training

### Module 1: Kubernetes Administration

```bash
# Kubernetes basics
kubectl get nodes
kubectl get pods --all-namespaces
kubectl describe node gpu-node-01
```

### Module 2: GPU Operator

```bash
# GPU Operator management
kubectl get pods -n gpu-operator
kubectl describe pod -n gpu-operator
```

### Module 3: Troubleshooting

```bash
# Common troubleshooting commands
kubectl logs <pod-name>
kubectl describe pod <pod-name>
nvidia-smi
```

## Data Scientist Training

### Module 4: JupyterHub Access

```bash
# Access JupyterHub
# Navigate to https://jupyterhub.internal
# Login with LDAP credentials
# Select GPU-enabled server profile
```

### Module 5: Job Submission

```bash
# Submit training job
kubectl apply -f training-job.yaml
kubectl logs -f job/training
```

### Module 6: MLflow Usage

```python
# MLflow experiment tracking
import mlflow
mlflow.set_tracking_uri("http://mlflow:5000")
mlflow.log_param("learning_rate", 0.01)
mlflow.log_metric("accuracy", 0.95)
```

# Appendices

## Troubleshooting Guide

```bash
# GPU not visible
kubectl describe node gpu-node-01 | grep nvidia
# Check GPU Operator pods
kubectl get pods -n gpu-operator

# Pod pending
kubectl describe pod <pod-name>
# Check resource availability
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPUs:.status.allocatable.'nvidia\.com/gpu'
```

## Reference Commands

```bash
# Kubernetes
kubectl get nodes
kubectl get pods -A
kubectl top nodes

# NVIDIA
nvidia-smi
nvidia-smi -L

# Helm
helm list -A
helm status <release>
```

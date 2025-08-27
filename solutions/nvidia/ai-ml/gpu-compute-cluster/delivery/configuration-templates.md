# NVIDIA GPU Compute Cluster Configuration Templates

## Overview

This document provides standardized configuration templates for deploying and managing NVIDIA GPU compute clusters.

## Kubernetes Configurations

### GPU Operator Configuration

```yaml
# gpu-operator-values.yaml
operator:
  defaultRuntime: containerd
  runtimeClass: nvidia

driver:
  enabled: false  # Use pre-installed drivers
  
toolkit:
  enabled: true
  version: v1.13.5

devicePlugin:
  enabled: true
  version: v0.14.1
  config:
    name: time-slicing-config
    data:
      tesla-v100: |
        version: v1
        sharing:
          timeSlicing:
            resources:
            - name: nvidia.com/gpu
              replicas: 4
```

### Namespace Configuration

```yaml
# ai-workloads-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ai-workloads
  labels:
    name: ai-workloads
    gpu.nvidia.com/enabled: "true"
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: gpu-quota
  namespace: ai-workloads
spec:
  hard:
    requests.nvidia.com/gpu: "16"
    limits.nvidia.com/gpu: "16"
    requests.memory: "512Gi"
    limits.memory: "512Gi"
```

### Storage Class Configuration

```yaml
# high-performance-storage.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nvme-ssd
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: nvme
  fsType: ext4
```

## Container Runtime Configurations

### Docker Daemon Configuration

```json
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

### Containerd Configuration

```toml
# /etc/containerd/config.toml
version = 2

[plugins."io.containerd.grpc.v1.cri"]
  [plugins."io.containerd.grpc.v1.cri".containerd]
    default_runtime_name = "nvidia"
    
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
      runtime_type = "io.containerd.runc.v2"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
        BinaryName = "/usr/bin/nvidia-container-runtime"
```

## Monitoring Configurations

### DCGM Exporter Configuration

```yaml
# dcgm-exporter-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dcgm-exporter-config
  namespace: monitoring
data:
  default-counters.csv: |
    # GPU Utilization
    DCGM_FI_DEV_GPU_UTIL, gauge, GPU utilization (in %).
    # GPU Memory
    DCGM_FI_DEV_MEM_COPY_UTIL, gauge, Memory utilization (in %).
    DCGM_FI_DEV_FB_USED, gauge, Framebuffer memory used (in MiB).
    DCGM_FI_DEV_FB_FREE, gauge, Framebuffer memory free (in MiB).
    # GPU Temperature
    DCGM_FI_DEV_GPU_TEMP, gauge, GPU temperature (in C).
    # GPU Power
    DCGM_FI_DEV_POWER_USAGE, gauge, Power draw (in W).
```

### Prometheus GPU Monitoring Rules

```yaml
# gpu-monitoring-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: gpu-monitoring-rules
  namespace: monitoring
spec:
  groups:
  - name: gpu.rules
    rules:
    - alert: GPUHighUtilization
      expr: DCGM_FI_DEV_GPU_UTIL > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "GPU utilization is above 90%"
        
    - alert: GPUMemoryHigh
      expr: (DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE)) > 0.9
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "GPU memory usage is above 90%"
```

## Network Configurations

### InfiniBand Configuration

```bash
# /etc/modprobe.d/mlx5.conf
options mlx5_core probe_vf=0
options mlx5_ib mr_cache_limit=1024

# Configure IPoIB interface
echo 'connected' > /sys/class/net/ib0/mode
ip link set ib0 mtu 65520
```

### Network Policies

```yaml
# gpu-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gpu-workloads-policy
  namespace: ai-workloads
spec:
  podSelector:
    matchLabels:
      gpu.nvidia.com/enabled: "true"
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 9400
  egress:
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: UDP
      port: 53
```

## Security Configurations

### Pod Security Standards

```yaml
# gpu-pod-security.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ai-workloads
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### RBAC Configuration

```yaml
# gpu-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ai-workloads
  name: gpu-user
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "delete"]
```

## Environment-Specific Customizations

### Development Environment
- Lower resource quotas
- Relaxed security policies
- Extended logging and debugging

### Production Environment
- Strict resource quotas
- Enhanced security policies
- Optimized performance settings
- Comprehensive monitoring

### Testing Environment
- Isolated networking
- Automated testing pipelines
- Performance benchmarking tools

## Configuration Management

### GitOps Integration
```yaml
# argocd-gpu-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: gpu-cluster
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/company/gpu-cluster-config
    targetRevision: HEAD
    path: manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: gpu-operator
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Troubleshooting Configurations

### Debug Pod Template
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-debug
  namespace: ai-workloads
spec:
  containers:
  - name: debug
    image: nvidia/cuda:11.8-devel-ubuntu20.04
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
    resources:
      limits:
        nvidia.com/gpu: 1
    securityContext:
      privileged: true
```

These configuration templates provide a solid foundation for deploying and managing NVIDIA GPU compute clusters. Customize the values according to your specific environment and requirements.
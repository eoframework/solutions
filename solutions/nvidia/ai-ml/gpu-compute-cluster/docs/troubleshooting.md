# NVIDIA GPU Compute Cluster Troubleshooting Guide

## Overview

This guide provides systematic troubleshooting approaches for common issues encountered in NVIDIA GPU compute clusters. It includes diagnostic procedures, root cause analysis, and resolution steps for various failure scenarios.

## Troubleshooting Methodology

### Systematic Approach
1. **Identify Symptoms**: Gather detailed error messages and behaviors
2. **Collect Information**: System logs, metrics, and configuration data
3. **Isolate the Problem**: Narrow down to specific components or layers
4. **Analyze Root Cause**: Determine underlying cause of the issue
5. **Implement Solution**: Apply appropriate fixes or workarounds
6. **Verify Resolution**: Confirm the problem is resolved
7. **Document**: Record the issue and solution for future reference

### Information Gathering Commands
```bash
# System information
uname -a
cat /etc/os-release
uptime
df -h

# GPU information
nvidia-smi
nvidia-smi -q
nvidia-ml-py --query-gpu=all
lspci | grep -i nvidia

# Kubernetes information
kubectl get nodes -o wide
kubectl get pods -A
kubectl describe nodes
kubectl get events --sort-by=.metadata.creationTimestamp

# Container runtime
docker version
docker info
containerd --version

# Logs
journalctl -u kubelet -f
dmesg | grep -i nvidia
tail -f /var/log/syslog
```

## GPU Hardware Issues

### GPU Not Detected

#### Symptoms
- `nvidia-smi` returns "No devices were found"
- Kernel module loading failures
- PCIe enumeration issues

#### Diagnostic Steps
```bash
# Check PCIe devices
lspci | grep -i nvidia
# Expected: NVIDIA GPU entries

# Check kernel modules
lsmod | grep nvidia
# Expected: nvidia, nvidia_uvm, nvidia_drm modules loaded

# Check dmesg for errors
dmesg | grep -i nvidia | grep -i error

# Verify BIOS settings
dmidecode -t bios | grep -i version
```

#### Common Causes and Solutions

**1. Driver Installation Issues**
```bash
# Remove existing drivers
sudo apt purge 'nvidia-*' -y
sudo apt autoremove -y

# Reinstall drivers
sudo apt update
sudo apt install nvidia-driver-530 -y
sudo reboot

# Verify installation
nvidia-smi
```

**2. Secure Boot Enabled**
```bash
# Check Secure Boot status
mokutil --sb-state

# If enabled, either disable in BIOS or sign driver
sudo mokutil --import nvidia-driver.der
```

**3. BIOS Configuration Issues**
- Enable Above 4G Decoding
- Enable Resizable BAR (if supported)
- Set PCIe to Gen3/Gen4
- Disable CSM (Compatibility Support Module)

#### Resolution Template
```bash
#!/bin/bash
# GPU detection resolution script

echo "=== GPU Detection Troubleshooting ==="

# Step 1: Check hardware visibility
echo "Checking PCIe devices..."
lspci | grep -i nvidia || echo "ERROR: No NVIDIA devices found in PCIe"

# Step 2: Check driver status
echo "Checking NVIDIA drivers..."
nvidia-smi > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Drivers operational"
else
    echo "Driver issues detected, attempting reinstall..."
    sudo apt update
    sudo apt install --reinstall nvidia-driver-530 -y
fi

# Step 3: Verify modules
echo "Checking kernel modules..."
for module in nvidia nvidia_uvm nvidia_drm; do
    lsmod | grep -q $module || echo "WARNING: Module $module not loaded"
done
```

### GPU Performance Issues

#### Symptoms
- Lower than expected GPU utilization
- Thermal throttling warnings
- Memory errors or crashes

#### Diagnostic Commands
```bash
# Performance monitoring
nvidia-smi -l 1  # Continuous monitoring
nvidia-smi --query-gpu=utilization.gpu,utilization.memory,temperature.gpu,power.draw --format=csv -l 1

# Memory error checking
nvidia-smi -q -d ecc
nvidia-smi --query-gpu=ecc.errors.corrected.total,ecc.errors.uncorrected.total --format=csv

# Thermal analysis
nvidia-smi --query-gpu=temperature.gpu,temperature.memory,power.draw,power.limit --format=csv -l 5

# Clock speeds
nvidia-smi --query-gpu=clocks.gr,clocks.mem,clocks.sm --format=csv
```

#### Performance Optimization
```bash
# Set persistence mode
sudo nvidia-smi -pm 1

# Set power limit (if needed)
sudo nvidia-smi -pl 400  # 400W limit

# Set application clocks
sudo nvidia-smi -ac 1215,1410  # memory,graphics clocks

# Reset to defaults
sudo nvidia-smi -rac
```

#### Thermal Management
```bash
# Check thermal status
nvidia-smi --query-gpu=temperature.gpu,temperature.memory --format=csv

# Set temperature limit (if supported)
sudo nvidia-smi --gom=0  # Enable all GPU operation modes

# Monitor thermal throttling
nvidia-smi --query-gpu=temperature.gpu,clocks_throttle_reasons.active --format=csv -l 1
```

## Container Runtime Issues

### GPU Not Available in Containers

#### Symptoms
- Containers cannot access GPUs
- `nvidia-smi` works on host but not in container
- CUDA runtime initialization failures

#### Diagnostic Steps
```bash
# Test GPU access in container
docker run --rm --gpus all nvidia/cuda:11.8-base nvidia-smi

# Check container runtime configuration
cat /etc/docker/daemon.json
sudo systemctl status docker

# Verify NVIDIA container toolkit
nvidia-container-cli info
nvidia-container-runtime --version
```

#### Common Issues and Solutions

**1. Missing NVIDIA Container Toolkit**
```bash
# Install NVIDIA container toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt update
sudo apt install nvidia-container-toolkit -y

# Configure Docker
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**2. Runtime Configuration Issues**
```bash
# Check Docker daemon configuration
cat /etc/docker/daemon.json
# Should contain:
# {
#   "runtimes": {
#     "nvidia": {
#       "path": "nvidia-container-runtime",
#       "runtimeArgs": []
#     }
#   },
#   "default-runtime": "nvidia"
# }

# Restart Docker with new configuration
sudo systemctl restart docker
```

**3. SELinux/AppArmor Conflicts**
```bash
# Check SELinux status
getenforce
# If enforcing, try:
sudo setsebool -P container_use_devices 1

# For AppArmor:
sudo apparmor_parser -R /etc/apparmor.d/docker
```

### Container Memory Issues

#### Symptoms
- Out of memory (OOM) kills
- Container allocation failures
- GPU memory leaks

#### Memory Diagnostics
```bash
# Monitor GPU memory usage
nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv -l 1

# Check container memory limits
docker stats --no-stream

# Kubernetes resource monitoring
kubectl top nodes
kubectl top pods -A --sort-by=memory
```

#### Memory Optimization
```python
# GPU memory management in applications
import torch

# Enable memory fraction
torch.cuda.set_per_process_memory_fraction(0.8)

# Clear cache
torch.cuda.empty_cache()

# Monitor memory usage
print(f"Allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
print(f"Cached: {torch.cuda.memory_reserved() / 1024**3:.2f} GB")
```

## Kubernetes Integration Issues

### GPU Device Plugin Problems

#### Symptoms
- Pods stuck in pending state
- No GPU resources advertised on nodes
- Device plugin pods in CrashLoopBackOff

#### Diagnostic Commands
```bash
# Check GPU Operator status
kubectl get pods -n gpu-operator
kubectl describe pods -n gpu-operator

# Check device plugin logs
kubectl logs -n gpu-operator -l app=nvidia-device-plugin-daemonset

# Verify GPU resources on nodes
kubectl describe nodes | grep nvidia.com/gpu

# Check for tainted nodes
kubectl describe nodes | grep -A 5 Taints
```

#### Common Device Plugin Issues

**1. GPU Operator Installation Problems**
```bash
# Check GPU Operator installation
helm list -n gpu-operator

# Reinstall if necessary
helm uninstall gpu-operator -n gpu-operator
kubectl delete namespace gpu-operator

# Clean install
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm install gpu-operator nvidia/gpu-operator \
  --namespace gpu-operator \
  --create-namespace \
  --set driver.enabled=false  # If drivers pre-installed
```

**2. Node Feature Discovery Issues**
```bash
# Check NFD status
kubectl get nodes -o json | jq '.items[].metadata.labels' | grep nvidia

# Restart NFD if needed
kubectl delete pods -n gpu-operator -l app=node-feature-discovery
```

**3. Driver Container Failures**
```bash
# Check driver installation logs
kubectl logs -n gpu-operator -l app=nvidia-driver-daemonset

# Common fixes
kubectl patch clusterpolicy/cluster-policy \
  --type='merge' \
  -p='{"spec":{"driver":{"version":"530.30.02"}}}'
```

### Pod Scheduling Issues

#### Symptoms
- Pods remain in pending state
- Insufficient GPU resources
- Node affinity conflicts

#### Scheduling Diagnostics
```bash
# Check pending pods
kubectl get pods -A --field-selector=status.phase=Pending

# Describe pending pods for events
kubectl describe pod <pod-name>

# Check resource availability
kubectl describe nodes | grep -A 5 "Allocated resources"

# Check scheduler logs
kubectl logs -n kube-system -l component=kube-scheduler
```

#### Scheduling Solutions

**1. Resource Quotas and Limits**
```yaml
# Check resource quotas
kubectl get resourcequota -A

# Example fix for quota issues
apiVersion: v1
kind: ResourceQuota
metadata:
  name: gpu-quota
spec:
  hard:
    requests.nvidia.com/gpu: "16"
    limits.nvidia.com/gpu: "16"
```

**2. Node Selector Issues**
```yaml
# Pod with node selector
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  nodeSelector:
    nvidia.com/gpu.product: "Tesla-V100-SXM2-16GB"
  containers:
  - name: cuda-container
    image: nvidia/cuda:11.8-base
    resources:
      limits:
        nvidia.com/gpu: 1
```

**3. Taints and Tolerations**
```bash
# Check node taints
kubectl describe nodes | grep -A 3 Taints

# Add toleration to pods
kubectl patch deployment gpu-workload -p='
{
  "spec": {
    "template": {
      "spec": {
        "tolerations": [
          {
            "key": "nvidia.com/gpu",
            "operator": "Exists",
            "effect": "NoSchedule"
          }
        ]
      }
    }
  }
}'
```

## Network Communication Issues

### Multi-Node Training Failures

#### Symptoms
- Distributed training jobs hanging
- NCCL initialization failures
- High communication latency

#### Network Diagnostics
```bash
# Test inter-node connectivity
ping -c 10 <other-node-ip>

# Bandwidth testing
iperf3 -c <target-node> -t 60 -P 4

# NCCL diagnostics
export NCCL_DEBUG=INFO
mpirun -np 4 -H node1:2,node2:2 python distributed_training.py

# InfiniBand status (if applicable)
ibstat
ibv_devinfo
```

#### NCCL Configuration
```bash
# Optimal NCCL settings
export NCCL_ALGO=Ring
export NCCL_MIN_NCHANNELS=4
export NCCL_MAX_NCHANNELS=16
export NCCL_TREE_THRESHOLD=0
export NCCL_IB_DISABLE=0
export NCCL_SOCKET_IFNAME=ib0
export NCCL_DEBUG=INFO
```

#### Network Optimization
```bash
# Network interface tuning
sudo ethtool -G eth0 rx 4096 tx 4096
sudo ethtool -K eth0 gro on
sudo ethtool -K eth0 lro on

# TCP buffer tuning
echo 'net.core.rmem_max = 268435456' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 268435456' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 87380 268435456' >> /etc/sysctl.conf
sudo sysctl -p
```

### Firewall and Security Issues

#### Symptoms
- Connection timeouts
- Authentication failures
- Certificate errors

#### Security Diagnostics
```bash
# Check firewall status
sudo ufw status
sudo firewall-cmd --list-all

# Test port connectivity
telnet <target-host> <port>
nc -zv <target-host> <port>

# Certificate verification
openssl s_client -connect <host>:<port> -verify_return_error
```

#### Common Firewall Rules
```bash
# Allow Kubernetes API
sudo ufw allow 6443/tcp

# Allow kubelet API
sudo ufw allow 10250/tcp

# Allow NCCL communication
sudo ufw allow 20000:30000/tcp

# Allow InfiniBand (if applicable)
sudo ufw allow 4791/tcp
sudo ufw allow 4791/udp
```

## Storage Performance Issues

### Slow Data Loading

#### Symptoms
- Long data loading times
- GPU underutilization during training
- I/O bottlenecks

#### Storage Diagnostics
```bash
# Disk I/O monitoring
iostat -x 1 5
iotop -a

# Test sequential read performance
dd if=/dev/sda of=/dev/null bs=1M count=1000 iflag=direct

# Test random read performance
fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread \
    --bs=4k --size=4G --numjobs=4 --runtime=60 --group_reporting

# Network storage testing
dd if=/dev/zero of=/nfs/testfile bs=1M count=1000 oflag=direct
```

#### Storage Optimization
```bash
# Mount options for NFS
mount -t nfs -o rsize=1048576,wsize=1048576,hard,intr \
    nfs-server:/path /local/mount

# Local SSD optimization
echo noop > /sys/block/nvme0n1/queue/scheduler
echo 4096 > /sys/block/nvme0n1/queue/nr_requests
```

### Data Pipeline Optimization
```python
# Optimized data loading
import torch
from torch.utils.data import DataLoader

# Multi-process data loading
dataloader = DataLoader(
    dataset,
    batch_size=64,
    num_workers=8,  # Multiple workers
    pin_memory=True,  # Faster GPU transfer
    persistent_workers=True  # Keep workers alive
)

# Prefetching
for batch in dataloader:
    batch = batch.cuda(non_blocking=True)
```

## Monitoring and Alerting Issues

### Missing Metrics

#### Symptoms
- Empty Grafana dashboards
- No GPU metrics in Prometheus
- DCGM exporter failures

#### Monitoring Diagnostics
```bash
# Check DCGM exporter status
kubectl get pods -n gpu-operator -l app=dcgm-exporter
kubectl logs -n gpu-operator -l app=dcgm-exporter

# Test metrics endpoint
curl http://<node-ip>:9400/metrics

# Check Prometheus targets
kubectl port-forward -n monitoring service/prometheus 9090:9090
# Visit http://localhost:9090/targets
```

#### DCGM Configuration
```yaml
# DCGM exporter configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: dcgm-exporter-config
data:
  default-counters.csv: |
    DCGM_FI_DEV_GPU_UTIL, gauge, GPU utilization (in %).
    DCGM_FI_DEV_MEM_COPY_UTIL, gauge, Memory utilization (in %).
    DCGM_FI_DEV_GPU_TEMP, gauge, GPU temperature (in C).
    DCGM_FI_DEV_POWER_USAGE, gauge, Power draw (in W).
    DCGM_FI_DEV_TOTAL_ENERGY_CONSUMPTION, counter, Total energy consumption since boot (in mJ).
    DCGM_FI_DEV_PCIE_REPLAY_COUNTER, counter, Total number of PCIe retries.
```

### Alert Configuration
```yaml
# Prometheus alerting rules
groups:
- name: gpu-alerts
  rules:
  - alert: GPUDown
    expr: up{job="dcgm-exporter"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "GPU node is down"
      description: "GPU node {{ $labels.instance }} has been down for more than 5 minutes."

  - alert: GPUHighTemperature
    expr: DCGM_FI_DEV_GPU_TEMP > 85
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "GPU temperature high"
      description: "GPU {{ $labels.gpu }} temperature is {{ $value }}°C"
```

## Application-Specific Issues

### CUDA Runtime Errors

#### Common CUDA Errors
```bash
# CUDA out of memory
# Solution: Reduce batch size or enable gradient checkpointing
export CUDA_LAUNCH_BLOCKING=1  # For debugging

# CUDA initialization failed
# Check driver compatibility
nvidia-smi
cat /usr/local/cuda/version.txt
```

#### CUDA Debugging
```python
import torch
import os

# Enable CUDA debugging
os.environ['CUDA_LAUNCH_BLOCKING'] = '1'

# Check CUDA availability
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda}")
print(f"GPU count: {torch.cuda.device_count()}")

# Memory debugging
def print_gpu_utilization():
    if torch.cuda.is_available():
        print(f"GPU memory allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
        print(f"GPU memory cached: {torch.cuda.memory_reserved() / 1024**3:.2f} GB")
```

### Framework-Specific Issues

#### TensorFlow GPU Issues
```python
import tensorflow as tf

# Check GPU availability
print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))

# Enable memory growth
gpus = tf.config.experimental.list_physical_devices('GPU')
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
    except RuntimeError as e:
        print(e)

# Set memory limit
tf.config.experimental.set_memory_limit(gpus[0], 1024)  # 1GB limit
```

#### PyTorch GPU Issues
```python
import torch

# Check GPU status
print(f"PyTorch version: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA version: {torch.version.cuda}")
print(f"cuDNN version: {torch.backends.cudnn.version()}")

# Set device
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

# Memory management
torch.cuda.empty_cache()  # Clear GPU cache
torch.backends.cudnn.benchmark = True  # Optimize for consistent input sizes
```

## Emergency Recovery Procedures

### Node Recovery

#### Unresponsive GPU Node
```bash
# Step 1: Try graceful restart
sudo systemctl restart nvidia-persistenced
sudo systemctl restart docker
sudo systemctl restart kubelet

# Step 2: Force driver reset (if safe)
sudo nvidia-smi -r  # Reset GPU state

# Step 3: Hard reboot (last resort)
sudo reboot
```

#### Cluster Recovery
```bash
# Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Remove failed node
kubectl delete node <node-name>

# Re-add node after fixing
kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

### Data Recovery

#### Container Data Recovery
```bash
# List stopped containers
docker ps -a

# Extract data from stopped container
docker cp <container-id>:/path/to/data /host/backup/path

# Mount container filesystem
docker run --rm -v <volume-name>:/volume alpine tar -czf - -C /volume . > backup.tar.gz
```

#### Persistent Volume Recovery
```bash
# List persistent volumes
kubectl get pv

# Backup PV data
kubectl exec -it <pod-with-pv> -- tar -czf - /data > pv-backup.tar.gz

# Restore PV data
kubectl exec -it <new-pod> -- tar -xzf - -C /data < pv-backup.tar.gz
```

## Escalation Procedures

### Support Contacts

#### Internal Escalation
1. **L1 Support**: Basic troubleshooting and known issues
2. **L2 Support**: Advanced diagnostics and complex issues
3. **L3 Support**: Expert-level analysis and development issues

#### Vendor Support
1. **NVIDIA Support**: GPU hardware and driver issues
2. **Kubernetes Support**: Platform-specific issues
3. **Cloud Provider**: Infrastructure and networking issues

### Information Collection for Support

#### Support Bundle Script
```bash
#!/bin/bash
# GPU cluster support bundle collection

BUNDLE_DIR="/tmp/gpu-cluster-support-$(date +%Y%m%d-%H%M%S)"
mkdir -p $BUNDLE_DIR

echo "Collecting GPU cluster support information..."

# System information
uname -a > $BUNDLE_DIR/system-info.txt
cat /etc/os-release >> $BUNDLE_DIR/system-info.txt
uptime >> $BUNDLE_DIR/system-info.txt

# GPU information
nvidia-smi > $BUNDLE_DIR/nvidia-smi.txt
nvidia-smi -q > $BUNDLE_DIR/nvidia-smi-detailed.txt
lspci | grep -i nvidia > $BUNDLE_DIR/pci-devices.txt

# Kubernetes information
kubectl get nodes -o yaml > $BUNDLE_DIR/nodes.yaml
kubectl get pods -A -o yaml > $BUNDLE_DIR/pods.yaml
kubectl get events --sort-by=.metadata.creationTimestamp > $BUNDLE_DIR/events.txt

# Logs
journalctl -u kubelet --since "24 hours ago" > $BUNDLE_DIR/kubelet.log
dmesg > $BUNDLE_DIR/dmesg.log

# Container runtime
docker info > $BUNDLE_DIR/docker-info.txt
docker ps -a > $BUNDLE_DIR/docker-ps.txt

# Create archive
tar -czf gpu-cluster-support.tar.gz -C /tmp $(basename $BUNDLE_DIR)
echo "Support bundle created: gpu-cluster-support.tar.gz"
```

#### Critical Issue Template
```
Subject: [CRITICAL] GPU Cluster Issue - <Brief Description>

Environment:
- Cluster size: X nodes, Y GPUs
- GPU models: <List GPU models>
- Kubernetes version: <Version>
- NVIDIA driver version: <Version>
- CUDA version: <Version>

Issue Description:
<Detailed description of the problem>

Impact:
<Business impact and affected users>

Timeline:
<When did the issue start>

Steps Taken:
<Troubleshooting steps already attempted>

Logs and Diagnostics:
<Attach relevant logs and diagnostic output>

Contact Information:
<Primary and secondary contact details>
```

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues in NVIDIA GPU compute clusters, enabling rapid problem resolution and minimal downtime.
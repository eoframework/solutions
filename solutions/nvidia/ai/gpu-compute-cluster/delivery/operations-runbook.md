# NVIDIA GPU Compute Cluster Operations Runbook

## Overview

This runbook provides day-to-day operational procedures for managing NVIDIA GPU compute clusters, including monitoring, troubleshooting, and maintenance activities.

## Daily Operations

### Morning Health Checks

1. **Cluster Status Verification**
   ```bash
   # Check cluster nodes status
   kubectl get nodes -o wide
   
   # Verify GPU operator pods
   kubectl get pods -n gpu-operator
   
   # Check GPU resource availability
   kubectl describe nodes | grep nvidia.com/gpu
   ```

2. **GPU Health Assessment**
   ```bash
   # Check GPU status on each node
   nvidia-smi
   
   # Verify GPU temperature and power consumption
   nvidia-smi -q -d temperature,power
   
   # Check for GPU errors
   nvidia-smi -q -d ecc
   ```

3. **Workload Status Review**
   ```bash
   # List running GPU workloads
   kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.metadata.name}{"\t"}{.spec.containers[*].resources.limits.nvidia\.com/gpu}{"\n"}{end}'
   
   # Check pending pods waiting for GPU resources
   kubectl get pods --field-selector=status.phase=Pending -A
   ```

## Monitoring and Alerting

### Key Metrics to Monitor

| Metric | Threshold | Action |
|--------|-----------|--------|
| GPU Utilization | >95% for 10min | Investigate workload efficiency |
| GPU Memory | >90% | Check for memory leaks |
| GPU Temperature | >85°C | Verify cooling systems |
| GPU Power Draw | >Max TDP | Check power infrastructure |
| Node CPU/Memory | >90% | Scale or rebalance workloads |

### Monitoring Commands

```bash
# Real-time GPU monitoring
watch -n 2 nvidia-smi

# DCGM metrics collection
dcgmi dmon -e 1001,1002,1003,1004,1005 -c 10

# Prometheus metrics query examples
curl -s 'http://prometheus:9090/api/v1/query?query=DCGM_FI_DEV_GPU_UTIL'
```

### Alert Response Procedures

#### High GPU Temperature Alert
1. Identify affected node: `kubectl get nodes --show-labels | grep gpu-temp-high`
2. Check cooling system status
3. Reduce workload if necessary: `kubectl drain <node> --ignore-daemonsets`
4. Contact facilities team if cooling issue persists

#### GPU Memory Exhaustion
1. Identify memory-intensive pods
2. Check for memory leaks in applications
3. Scale down non-critical workloads
4. Consider GPU memory optimization techniques

#### Node Unreachable
1. Verify network connectivity
2. Check node system logs: `journalctl -u kubelet`
3. Restart kubelet service if needed
4. Escalate to infrastructure team for hardware issues

## Maintenance Procedures

### Weekly Maintenance Tasks

1. **Driver and Software Updates**
   ```bash
   # Check NVIDIA driver version
   nvidia-smi --query-gpu=driver_version --format=csv,noheader
   
   # Update GPU operator if newer version available
   helm repo update nvidia
   helm upgrade gpu-operator nvidia/gpu-operator -n gpu-operator
   ```

2. **Storage Cleanup**
   ```bash
   # Clean container images
   docker system prune -f
   
   # Clean unused Kubernetes resources
   kubectl delete pods --field-selector=status.phase=Succeeded -A
   ```

3. **Performance Analysis**
   ```bash
   # Generate GPU utilization report
   dcgmi stats -g 0 -s
   
   # Analyze workload performance patterns
   kubectl top pods --containers -A --sort-by=cpu
   ```

### Monthly Maintenance Tasks

1. **Capacity Planning Review**
   - Analyze GPU utilization trends
   - Review pending pod metrics
   - Plan for capacity expansion

2. **Security Updates**
   - Update Kubernetes cluster
   - Apply OS security patches
   - Review access controls and permissions

3. **Backup and Recovery Testing**
   - Test cluster configuration backups
   - Verify disaster recovery procedures
   - Update recovery documentation

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: Pod stuck in ContainerCreating
**Symptoms:**
```
NAME    READY   STATUS              RESTARTS   AGE
app-1   0/1     ContainerCreating   0          5m
```

**Diagnosis:**
```bash
kubectl describe pod app-1
kubectl logs -n gpu-operator nvidia-device-plugin-xxx
```

**Resolution:**
1. Check GPU operator status
2. Verify node has available GPU resources
3. Restart device plugin if necessary

#### Issue: CUDA out of memory errors
**Symptoms:**
- Application logs show CUDA OOM errors
- GPU memory appears fully utilized

**Diagnosis:**
```bash
# Check GPU memory usage
nvidia-smi --query-gpu=memory.used,memory.total --format=csv

# Check for memory fragmentation
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv
```

**Resolution:**
1. Implement batch size optimization
2. Enable GPU memory clearing between jobs
3. Consider multi-GPU distribution

#### Issue: Poor GPU utilization
**Symptoms:**
- Low GPU utilization despite running workloads
- High CPU wait times

**Diagnosis:**
```bash
# Profile GPU utilization
nvidia-smi dmon -s um -c 60

# Check I/O bottlenecks
iostat -x 5
```

**Resolution:**
1. Optimize data loading pipelines
2. Implement GPU memory prefetching
3. Use faster storage for training data

### Emergency Procedures

#### GPU Node Failure
1. **Immediate Response**
   ```bash
   # Drain the node
   kubectl drain <node-name> --ignore-daemonsets --force
   
   # Reschedule critical workloads
   kubectl get pods -o wide | grep <node-name>
   ```

2. **Recovery Steps**
   - Contact hardware support
   - Prepare replacement node if available
   - Update capacity planning documentation

#### Cluster-Wide GPU Failure
1. **Assessment**
   - Identify scope of failure
   - Check infrastructure dependencies
   - Notify stakeholders

2. **Mitigation**
   - Fail over to backup cluster if available
   - Implement CPU-only fallback for critical workloads
   - Coordinate with infrastructure teams

## Performance Optimization

### GPU Resource Optimization

1. **Multi-Instance GPU (MIG) Configuration**
   ```bash
   # Enable MIG mode on A100 GPUs
   sudo nvidia-smi -mig 1
   
   # Create GPU instances
   sudo nvidia-smi mig -cgi 1g.5gb,2g.10gb
   ```

2. **Time-Slicing Configuration**
   ```yaml
   # Enable GPU sharing for development workloads
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: time-slicing-config
   data:
     a100-40gb: |
       version: v1
       sharing:
         timeSlicing:
           resources:
           - name: nvidia.com/gpu
             replicas: 4
   ```

### Workload Optimization

1. **Resource Requests and Limits**
   - Set appropriate GPU resource requests
   - Configure memory and CPU limits
   - Use node selectors for GPU types

2. **Scheduling Optimization**
   - Implement pod affinity rules
   - Use topology spread constraints
   - Configure priority classes

## Documentation and Reporting

### Daily Reports
- GPU utilization summary
- Failed jobs and error analysis
- Resource consumption trends

### Weekly Reports
- Cluster health assessment
- Performance metrics analysis
- Capacity planning updates

### Incident Documentation
- Root cause analysis
- Resolution steps taken
- Lessons learned and improvements

## Contact Information

### Escalation Matrix

| Issue Type | Primary Contact | Secondary Contact | Escalation |
|------------|----------------|------------------|------------|
| Hardware Failure | Infrastructure Team | Vendor Support | Management |
| Software Issues | Platform Team | Application Teams | Architecture |
| Network Problems | Network Operations | Cloud Provider | Infrastructure |
| Security Incidents | Security Team | CISO | Executive |

### Support Resources
- NVIDIA Enterprise Support Portal
- Kubernetes community forums
- Internal knowledge base
- Vendor technical documentation

For immediate assistance during critical incidents, use the established escalation procedures and contact information provided in your organization's incident response plan.
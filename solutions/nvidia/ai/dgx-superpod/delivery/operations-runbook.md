# NVIDIA DGX SuperPOD Operations Runbook

## Overview

This operations runbook provides comprehensive procedures for day-to-day management, monitoring, and troubleshooting of the NVIDIA DGX SuperPOD AI infrastructure. This document is designed for system administrators, DevOps engineers, and support personnel.

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Weekly Maintenance](#weekly-maintenance)
3. [Monthly Tasks](#monthly-tasks)
4. [Monitoring and Alerting](#monitoring-and-alerting)
5. [Troubleshooting Guide](#troubleshooting-guide)
6. [Emergency Procedures](#emergency-procedures)
7. [Performance Optimization](#performance-optimization)
8. [Security Operations](#security-operations)
9. [Backup and Recovery](#backup-and-recovery)
10. [Contact Information](#contact-information)

---

## Daily Operations

### System Health Checks

**Morning Health Check Routine (15 minutes)**

```bash
#!/bin/bash
# Daily health check script

echo "=== DGX SuperPOD Daily Health Check ==="
echo "Date: $(date)"
echo "Performed by: $(whoami)"
echo ""

# Check overall cluster status
echo "1. Cluster Status:"
kubectl get nodes -o wide | head -20

# Check SLURM status
echo -e "\n2. SLURM Status:"
sinfo -o "%.10P %.5a %.10l %.6D %.6t %.35N"
squeue -o "%.8i %.9P %.8j %.8u %.2t %.10M %.6D %R" | head -10

# Check GPU status across cluster
echo -e "\n3. GPU Status Summary:"
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
    echo "Node: $node"
    ssh $node "nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits" 2>/dev/null | head -8
    echo ""
done

# Check storage health
echo "4. Storage Status:"
df -h | grep -E "(datasets|models|results|scratch)"

# Check InfiniBand status
echo -e "\n5. InfiniBand Status:"
ibstat | grep -E "(State|Rate)" | head -10

# Check for critical alerts
echo -e "\n6. Active Alerts:"
curl -s 'http://prometheus:9090/api/v1/query?query=ALERTS{alertstate="firing",severity="critical"}' | jq -r '.data.result[].metric.alertname' 2>/dev/null || echo "Prometheus unavailable"

echo -e "\n=== Health Check Complete ==="
```

**Daily Checklist:**
- [ ] Review overnight job completions and failures
- [ ] Check system resource utilization (GPU, CPU, Memory, Storage)
- [ ] Verify InfiniBand network health
- [ ] Review monitoring dashboards for anomalies
- [ ] Check backup job status
- [ ] Review security alerts and access logs

### Job Queue Management

**SLURM Queue Management:**

```bash
# Check queue status
squeue -o "%.8i %.9P %.20j %.8u %.8T %.10M %.9l %.6D %R"

# View partition information
sinfo -Nel

# Check job priorities
sprio -o "%.8i %.8u %.10Y %.10A %.10F %.10J %.10P %.10Q %.8T"

# Cancel stuck jobs
scancel <job_id>

# Hold/release jobs
scontrol hold <job_id>
scontrol release <job_id>

# Drain problematic nodes
scontrol update NodeName=dgx-001 State=DRAIN Reason="Maintenance"

# Return nodes to service
scontrol update NodeName=dgx-001 State=RESUME
```

### Resource Monitoring

**GPU Utilization Monitoring:**

```bash
# Check GPU utilization across cluster
pdsh -w dgx-[001-020] "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits" | sort

# Monitor GPU memory usage
pdsh -w dgx-[001-020] "nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits" | sort

# Check for GPU errors
pdsh -w dgx-[001-020] "nvidia-smi --query-gpu=ecc.errors.corrected.total,ecc.errors.uncorrected.total --format=csv,noheader,nounits" | grep -v "0, 0"
```

---

## Weekly Maintenance

### System Updates and Patches

**Weekly Maintenance Window (Sundays 2:00 AM - 6:00 AM)**

```bash
#!/bin/bash
# Weekly maintenance script

# 1. Drain compute nodes gracefully
for node in $(sinfo -N -h -o "%N"); do
    scontrol update NodeName=$node State=DRAIN Reason="Weekly maintenance"
done

# Wait for running jobs to complete (max 2 hours)
timeout 7200 bash -c 'while squeue -h | grep -q "RUNNING"; do sleep 60; done'

# 2. Update system packages (on management node first)
apt update && apt upgrade -y

# 3. Update NVIDIA drivers if needed
# nvidia-driver-update.sh

# 4. Check and update container images
docker system prune -f
docker image prune -f

# Pull latest AI framework containers
docker pull nvcr.io/nvidia/tensorflow:23.08-tf2-py3
docker pull nvcr.io/nvidia/pytorch:23.08-py3
docker pull nvcr.io/nvidia/rapids:23.08

# 5. Restart services if needed
# systemctl restart slurmd
# systemctl restart kubelet

# 6. Return nodes to service
for node in $(sinfo -N -h -o "%N"); do
    scontrol update NodeName=$node State=RESUME
done
```

**Weekly Checklist:**
- [ ] Apply security updates to all nodes
- [ ] Update container images and AI frameworks
- [ ] Review and rotate log files
- [ ] Check storage capacity and clean up old data
- [ ] Review user accounts and permissions
- [ ] Validate backup integrity
- [ ] Update documentation and runbooks

### Performance Review

```bash
# Weekly performance report
#!/bin/bash

echo "=== Weekly Performance Report ==="
echo "Week ending: $(date)"

# GPU utilization summary
echo "Average GPU Utilization (last 7 days):"
prometheus-query "avg_over_time(nvidia_gpu_utilization[7d])"

# Job completion statistics
echo "Job Statistics:"
sacct --starttime=$(date -d '7 days ago' '+%Y-%m-%d') --format=JobID,JobName,State,ExitCode,CPUTime,MaxRSS | grep -c "COMPLETED"
sacct --starttime=$(date -d '7 days ago' '+%Y-%m-%d') --format=JobID,JobName,State,ExitCode,CPUTime,MaxRSS | grep -c "FAILED"

# Storage utilization
echo "Storage Utilization:"
df -h | grep -E "(datasets|models|results)"

# Network performance
echo "Network Performance:"
ib_traffic_check.sh
```

---

## Monthly Tasks

### Capacity Planning

**Monthly Capacity Review:**

```bash
#!/bin/bash
# Monthly capacity planning report

echo "=== Monthly Capacity Planning Report ==="

# Compute utilization trends
echo "Compute Utilization Trends (30 days):"
prometheus-query "avg_over_time(nvidia_gpu_utilization[30d])"
prometheus-query "avg_over_time(cpu_utilization[30d])"

# Storage growth analysis
echo "Storage Growth Analysis:"
du -sh /mnt/datasets /mnt/models /mnt/results /mnt/scratch

# User activity analysis
echo "User Activity (Top 10):"
sacct --starttime=$(date -d '30 days ago' '+%Y-%m-%d') --format=User,JobID --parsable2 | tail -n +2 | cut -d'|' -f1 | sort | uniq -c | sort -nr | head -10

# Queue time analysis
echo "Average Queue Times by Partition:"
squeue --format="%.10P %.10M" --noheader | awk '{queue_times[$1] += $2; counts[$1]++} END {for (p in queue_times) print p, queue_times[p]/counts[p]}'
```

### Hardware Health Assessment

```bash
# Monthly hardware health check
#!/bin/bash

echo "=== Monthly Hardware Health Assessment ==="

# GPU health check
echo "GPU Health Status:"
pdsh -w dgx-[001-020] "nvidia-smi --query-gpu=temperature.gpu,power.draw,fan.speed --format=csv"

# Memory health check
echo "Memory Health Status:"
pdsh -w dgx-[001-020] "memtester 1G 1" > /tmp/memtest_results.txt

# Storage health check
echo "Storage Health Status:"
pure-storage-health-check.sh

# InfiniBand fabric health
echo "InfiniBand Fabric Health:"
ibdiagnet --output_dir /tmp/ib_diagnostics/$(date +%Y%m%d)

# Generate health report
python3 /opt/dgx/scripts/generate_health_report.py --output /var/log/dgx-health-$(date +%Y%m%d).html
```

---

## Monitoring and Alerting

### Key Metrics to Monitor

**System Performance Metrics:**
- GPU utilization percentage
- GPU temperature and power consumption
- CPU utilization and load average
- Memory usage and swap utilization
- Network bandwidth and packet loss
- Storage I/O performance and capacity

**Application Metrics:**
- Job queue length and wait times
- Job completion rates and failure rates
- Container startup times
- AI training throughput metrics

### Alert Thresholds

```yaml
# Alert configuration thresholds
alerts:
  critical:
    gpu_temperature: "> 85°C"
    gpu_memory: "> 95%"
    node_down: "== 0 (up status)"
    storage_full: "> 95%"
    infiniband_down: "== 0 (link status)"
  
  warning:
    gpu_utilization: "< 60% for 30min"
    memory_usage: "> 90%"
    storage_space: "> 85%"
    job_queue_length: "> 100 jobs"
    temperature_trend: "increasing > 5°C/hour"
```

### Dashboard Access

**Primary Monitoring Dashboards:**
- **Grafana Main Dashboard**: http://monitoring.dgx.local:3000
  - Username: admin
  - Dashboard: "DGX SuperPOD Overview"
  
- **SLURM Monitoring**: http://monitoring.dgx.local:3000/d/slurm
- **GPU Performance**: http://monitoring.dgx.local:3000/d/gpu
- **Storage Analytics**: http://monitoring.dgx.local:3000/d/storage

---

## Troubleshooting Guide

### Common Issues and Solutions

#### GPU Issues

**Problem**: GPU not detected by system
```bash
# Diagnosis
lspci | grep -i nvidia
nvidia-smi
dmesg | grep -i nvidia

# Solutions
1. Check physical GPU seating
2. Reinstall NVIDIA driver
3. Check power connections
4. Update system BIOS
```

**Problem**: GPU performance degradation
```bash
# Diagnosis
nvidia-smi -q -d PERFORMANCE
nvidia-smi --query-gpu=clocks.current.graphics,clocks.current.memory --format=csv

# Solutions
1. Reset GPU clocks: nvidia-smi -rac
2. Check temperature and cooling
3. Update GPU firmware
4. Check for memory errors
```

#### Network Issues

**Problem**: InfiniBand link down
```bash
# Diagnosis
ibstat
ibstatus
ibdiagnet

# Solutions
1. Check cable connections
2. Restart OpenSM: systemctl restart opensm
3. Reset InfiniBand interface: ibportstate -G <guid> reset
4. Check switch configuration
```

**Problem**: Poor network performance
```bash
# Diagnosis
ib_send_bw
ib_read_bw
iperf3 testing between nodes

# Solutions
1. Check MTU settings
2. Verify NCCL configuration
3. Update InfiniBand drivers
4. Check for congestion
```

#### Storage Issues

**Problem**: Storage performance degradation
```bash
# Diagnosis
iostat -x 1
iotop
df -i (check inode usage)

# Solutions
1. Check storage array health
2. Optimize mount options
3. Clear cache: echo 3 > /proc/sys/vm/drop_caches
4. Check for fragmentation
```

#### SLURM Issues

**Problem**: Jobs stuck in queue
```bash
# Diagnosis
squeue -u <username>
scontrol show job <jobid>
sinfo -R (check node reasons)

# Solutions
1. Check resource availability
2. Verify job requirements
3. Check node states
4. Review partition limits
```

### Escalation Procedures

**Level 1**: Local team resolution (0-4 hours)
- System administrators
- Local troubleshooting procedures
- Known issue resolution

**Level 2**: Vendor support engagement (4-24 hours)
- NVIDIA technical support
- Hardware vendor support
- Advanced diagnostics

**Level 3**: Critical system failure (immediate)
- Emergency contact procedures
- Disaster recovery activation
- Business continuity measures

---

## Emergency Procedures

### System-Wide Outage

**Immediate Actions (First 15 minutes):**
1. Assess scope of outage
2. Notify stakeholders
3. Document start time and symptoms
4. Begin diagnostic procedures

**Emergency Contact List:**
- Primary Administrator: [phone], [email]
- Secondary Administrator: [phone], [email]
- NVIDIA Support: 1-800-NVIDIA1
- Facilities Management: [phone], [emergency contact]

### Data Recovery Procedures

**In case of storage failure:**
1. Do not attempt to restart failed systems
2. Contact storage vendor immediately
3. Assess backup integrity
4. Initiate recovery procedures from last known good backup
5. Document all actions taken

### Security Incident Response

**Security breach detection:**
1. Isolate affected systems immediately
2. Preserve evidence (do not shutdown systems)
3. Contact security team
4. Document timeline of events
5. Follow incident response playbook

---

## Performance Optimization

### Ongoing Performance Tuning

**Monthly Performance Review:**
1. Analyze GPU utilization patterns
2. Review job completion times
3. Assess storage I/O patterns
4. Network performance analysis
5. User workload optimization recommendations

**Performance Optimization Scripts:**

```bash
# GPU optimization
#!/bin/bash
optimize_gpu_performance() {
    nvidia-smi -pm 1  # Persistence mode
    nvidia-smi -pl 700  # Max power limit
    nvidia-smi -ac 1593,2619  # Memory and graphics clocks
}

# System optimization
optimize_system_performance() {
    # CPU governor
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    
    # Memory optimization
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo 1 > /proc/sys/vm/drop_caches
    
    # Network optimization
    ethtool -G ib0 rx 8192 tx 8192
}
```

---

## Security Operations

### Daily Security Tasks

```bash
# Security monitoring script
#!/bin/bash

echo "=== Daily Security Check ==="

# Check for unauthorized access attempts
echo "Failed SSH attempts:"
grep "Failed password" /var/log/auth.log | tail -20

# Check for privilege escalation
echo "Sudo usage:"
grep "sudo:" /var/log/auth.log | grep "$(date '+%b %d')" | tail -10

# Check system integrity
echo "File system integrity:"
aide --check | head -20

# Check for unauthorized processes
echo "Unusual processes:"
ps aux | awk '$3 > 80 || $4 > 80' | head -10
```

### Weekly Security Tasks

- Review user access logs
- Update security patches
- Rotate service account passwords
- Review firewall logs
- Check for security vulnerabilities
- Update antivirus signatures

---

## Backup and Recovery

### Backup Verification

**Daily Backup Checks:**
```bash
# Verify backup completion
backup_status=$(grep "$(date '+%Y-%m-%d')" /var/log/backup.log | grep "SUCCESS")
if [[ -z "$backup_status" ]]; then
    echo "ALERT: Backup may have failed on $(date '+%Y-%m-%d')"
    # Send alert
fi

# Test backup integrity
restore_test_sample=/tmp/restore_test_$(date +%Y%m%d)
mkdir -p $restore_test_sample
# Restore small sample and verify
```

**Recovery Testing:**
- Monthly restore tests of critical data
- Quarterly full system recovery drills
- Annual disaster recovery exercises

---

## Contact Information

### Internal Contacts

**Primary Team:**
- Lead Administrator: [Name], [phone], [email]
- Secondary Administrator: [Name], [phone], [email]
- Network Specialist: [Name], [phone], [email]
- Storage Specialist: [Name], [phone], [email]

### Vendor Support

**NVIDIA Support:**
- Technical Support: 1-800-NVIDIA1
- Enterprise Support Portal: https://enterprise-support.nvidia.com
- Account Manager: [Name], [phone], [email]

**Infrastructure Vendors:**
- Pure Storage Support: [phone], [email]
- Mellanox/NVIDIA Networking: [phone], [email]
- Facility Management: [phone], [email]

### Emergency Contacts

**24/7 Emergency Line:** [phone]
**Escalation Manager:** [Name], [phone], [email]
**Business Continuity:** [Name], [phone], [email]

---

## Documentation Updates

**Last Updated**: 2024-08-24
**Version**: 1.0
**Next Review Date**: 2024-11-24

**Change Log:**
- v1.0: Initial operations runbook creation
- Document any changes, updates, and lessons learned
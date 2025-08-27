# NVIDIA GPU Compute Cluster Automation Scripts

## Overview

This directory contains automation scripts for deploying, managing, and maintaining NVIDIA GPU compute clusters. These scripts streamline operations and ensure consistent, repeatable deployments across environments.

## Directory Structure

```
scripts/
├── deployment/          # Infrastructure deployment scripts
├── configuration/       # Configuration management scripts  
├── monitoring/         # Monitoring and alerting setup
├── maintenance/        # Routine maintenance automation
├── testing/           # Automated testing and validation
├── utilities/         # Helper scripts and tools
└── examples/          # Example configurations and workflows
```

## Prerequisites

### System Requirements
- Linux environment (Ubuntu 20.04+ or RHEL 8+)
- Bash 4.0 or later
- Python 3.8 or later
- Administrative access to target systems

### Tool Dependencies
- `kubectl` - Kubernetes command-line tool
- `helm` - Kubernetes package manager
- `docker` or `containerd` - Container runtime
- `terraform` - Infrastructure as Code (optional)
- `ansible` - Configuration management (optional)
- `jq` - JSON processing utility
- `curl` - Data transfer utility

### Access Requirements
- Kubernetes cluster admin access
- Container registry authentication
- NVIDIA NGC API key
- SSH access to cluster nodes

## Quick Start

### 1. Environment Setup
```bash
# Clone the repository and navigate to scripts directory
cd delivery/scripts

# Set executable permissions
chmod +x setup-environment.sh
./setup-environment.sh

# Source environment variables
source ./config/environment.conf
```

### 2. Validate Prerequisites
```bash
./utilities/validate-prerequisites.sh
```

### 3. Deploy Basic Cluster
```bash
# Deploy NVIDIA GPU Operator
./deployment/deploy-gpu-operator.sh

# Configure monitoring
./monitoring/setup-monitoring.sh

# Validate deployment
./testing/validate-cluster.sh
```

## Script Categories

### Deployment Scripts

#### `deployment/deploy-gpu-operator.sh`
Deploys and configures NVIDIA GPU Operator on Kubernetes cluster.

**Usage:**
```bash
./deployment/deploy-gpu-operator.sh [OPTIONS]

Options:
  -n, --namespace     Target namespace (default: gpu-operator)
  -v, --version      GPU Operator version (default: latest)
  -c, --config       Custom configuration file
  -d, --driver       NVIDIA driver version
  --time-slicing     Enable GPU time-slicing
  --mig             Enable Multi-Instance GPU support
  --dry-run         Preview changes without applying

Examples:
  # Basic deployment
  ./deployment/deploy-gpu-operator.sh
  
  # Deploy with custom driver version
  ./deployment/deploy-gpu-operator.sh --driver 530.30.02
  
  # Enable time-slicing for resource sharing
  ./deployment/deploy-gpu-operator.sh --time-slicing
```

**Configuration:**
```yaml
# config/gpu-operator-config.yaml
gpu_operator:
  version: "v23.6.1"
  namespace: "gpu-operator"
  driver:
    version: "530.30.02"
    enabled: true
  toolkit:
    enabled: true
    version: "1.13.5"
  device_plugin:
    enabled: true
    config:
      sharing:
        time_slicing:
          rename_by_default: false
          fail_request_greater_than_one: false
          resources:
            - name: nvidia.com/gpu
              replicas: 4
  dcgm:
    enabled: true
  node_status_exporter:
    enabled: true
  gfd:
    enabled: true
  mig:
    strategy: single
```

#### `deployment/setup-ingress.sh`
Configures ingress controllers and load balancers for GPU cluster services.

**Usage:**
```bash
./deployment/setup-ingress.sh [OPTIONS]

Options:
  -p, --provider     Ingress provider (nginx, traefik, istio)
  -s, --ssl         Enable SSL/TLS termination
  -c, --cert-manager Install cert-manager for SSL
  --external-dns    Configure external DNS integration

Examples:
  # Deploy NGINX ingress with SSL
  ./deployment/setup-ingress.sh -p nginx -s -c
```

#### `deployment/provision-storage.sh`
Provisions high-performance storage for AI/ML workloads.

**Usage:**
```bash
./deployment/provision-storage.sh [OPTIONS]

Options:
  -t, --type         Storage type (local-ssd, nfs, ceph)
  -s, --size         Storage size (default: 1TB)
  -p, --performance  Performance tier (standard, high, ultra)
  --backup          Enable automated backups

Examples:
  # Provision local NVMe storage
  ./deployment/provision-storage.sh -t local-ssd -s 2TB -p ultra
```

### Configuration Scripts

#### `configuration/configure-gpu-sharing.sh`
Configures GPU sharing strategies (time-slicing, MPS, vGPU).

**Usage:**
```bash
./configuration/configure-gpu-sharing.sh [OPTIONS]

Options:
  -m, --mode         Sharing mode (time-slice, mps, vgpu)
  -r, --replicas     Number of replicas per GPU (time-slice)
  -p, --profile      MPS profile configuration
  --nodes           Target specific nodes

Examples:
  # Configure 4-way GPU time-slicing
  ./configuration/configure-gpu-sharing.sh -m time-slice -r 4
  
  # Enable MPS on specific nodes
  ./configuration/configure-gpu-sharing.sh -m mps --nodes node1,node2
```

#### `configuration/setup-networking.sh`
Optimizes network configuration for GPU cluster communication.

**Usage:**
```bash
./configuration/setup-networking.sh [OPTIONS]

Options:
  -f, --fabric       Network fabric (ethernet, infiniband)
  -m, --mtu         Maximum transmission unit
  --rdma            Enable RDMA support
  --sriov           Configure SR-IOV

Examples:
  # Configure InfiniBand with RDMA
  ./configuration/setup-networking.sh -f infiniband --rdma
```

#### `configuration/tune-performance.sh`
Applies performance optimizations for GPU workloads.

**Usage:**
```bash
./configuration/tune-performance.sh [OPTIONS]

Options:
  -w, --workload     Workload type (training, inference, hpc)
  -g, --gpu-type     GPU model (v100, a100, h100)
  --cpu-affinity     Configure CPU affinity
  --memory-tuning    Apply memory optimizations

Examples:
  # Optimize for A100 training workloads
  ./configuration/tune-performance.sh -w training -g a100 --cpu-affinity
```

### Monitoring Scripts

#### `monitoring/setup-monitoring.sh`
Deploys comprehensive monitoring stack for GPU clusters.

**Components:**
- Prometheus for metrics collection
- Grafana for visualization  
- DCGM Exporter for GPU metrics
- Node Exporter for system metrics
- AlertManager for notifications

**Usage:**
```bash
./monitoring/setup-monitoring.sh [OPTIONS]

Options:
  -s, --storage      Persistent storage size (default: 100Gi)
  -r, --retention    Metrics retention period (default: 30d)
  -a, --alerts       Enable alerting rules
  --external-access  Expose services externally

Examples:
  # Full monitoring stack with alerting
  ./monitoring/setup-monitoring.sh -s 200Gi -r 60d -a --external-access
```

**Dashboards Included:**
- GPU utilization and temperature
- Memory usage and bandwidth
- Power consumption tracking
- Workload performance metrics
- Cluster resource allocation
- Network throughput analysis

#### `monitoring/configure-alerts.sh`
Sets up alerting rules and notification channels.

**Alert Categories:**
- Hardware failures and thermal issues
- Resource exhaustion and bottlenecks
- Performance degradation
- Security events and access violations
- Workload failures and timeouts

**Usage:**
```bash
./monitoring/configure-alerts.sh [OPTIONS]

Options:
  -c, --channel      Notification channel (slack, email, webhook)
  -s, --severity     Alert severity levels (critical, warning, info)
  -r, --rules        Custom alert rules file

Examples:
  # Configure Slack notifications for critical alerts
  ./monitoring/configure-alerts.sh -c slack -s critical
```

### Maintenance Scripts

#### `maintenance/cluster-health-check.sh`
Comprehensive cluster health validation and reporting.

**Health Checks:**
- Node status and resource availability
- GPU hardware status and errors
- Pod and service functionality  
- Network connectivity and performance
- Storage availability and performance
- Security compliance validation

**Usage:**
```bash
./maintenance/cluster-health-check.sh [OPTIONS]

Options:
  -r, --report       Generate detailed report
  -f, --format       Output format (text, json, html)
  --email           Email report to administrators
  --remediate       Attempt automatic remediation

Examples:
  # Generate comprehensive health report
  ./maintenance/cluster-health-check.sh -r -f html --email
  
  # Run with auto-remediation
  ./maintenance/cluster-health-check.sh --remediate
```

#### `maintenance/backup-cluster.sh`
Automated backup of cluster configuration and data.

**Backup Components:**
- Kubernetes manifests and configurations
- GPU Operator settings and policies
- Monitoring configurations and data
- Application data and models
- Certificate and security credentials

**Usage:**
```bash
./maintenance/backup-cluster.sh [OPTIONS]

Options:
  -d, --destination  Backup destination (s3, nfs, local)
  -c, --compression  Compression level (none, gzip, lz4)
  -e, --encryption   Enable backup encryption
  --retention       Backup retention policy
  --schedule        Cron schedule for automated backups

Examples:
  # Backup to S3 with encryption
  ./maintenance/backup-cluster.sh -d s3://backup-bucket -e --retention 30d
  
  # Schedule daily automated backups
  ./maintenance/backup-cluster.sh --schedule "0 2 * * *" -d /backup/location
```

#### `maintenance/update-cluster.sh`
Manages cluster component updates and patches.

**Update Components:**
- NVIDIA drivers and CUDA runtime
- GPU Operator versions
- Kubernetes components
- Container images and applications
- Security patches and fixes

**Usage:**
```bash
./maintenance/update-cluster.sh [OPTIONS]

Options:
  -c, --component    Component to update (driver, operator, k8s)
  -v, --version      Target version
  --dry-run         Preview updates without applying
  --rolling          Perform rolling updates
  --validation      Run validation tests after update

Examples:
  # Update GPU Operator with rolling deployment
  ./maintenance/update-cluster.sh -c operator -v v23.9.0 --rolling --validation
  
  # Preview driver update
  ./maintenance/update-cluster.sh -c driver -v 535.54.03 --dry-run
```

### Testing Scripts

#### `testing/validate-cluster.sh`
Comprehensive cluster validation and functionality testing.

**Test Categories:**
- Hardware functionality and performance
- Software installation and configuration
- Network connectivity and bandwidth
- Storage I/O and performance
- GPU workload execution
- Security controls and access

**Usage:**
```bash
./testing/validate-cluster.sh [OPTIONS]

Options:
  -t, --test-suite   Test suite to run (hardware, software, performance)
  -p, --parallel     Run tests in parallel
  -r, --report       Generate test report
  --benchmark       Include performance benchmarks

Examples:
  # Run full validation suite
  ./testing/validate-cluster.sh -r --benchmark
  
  # Run specific test category
  ./testing/validate-cluster.sh -t performance -p
```

#### `testing/benchmark-performance.sh`
Executes standardized performance benchmarks.

**Benchmark Suite:**
- GPU compute performance (CUDA kernels)
- Memory bandwidth (device and host)
- Network throughput (intra-cluster)
- Storage I/O performance
- ML training benchmarks (ResNet, BERT)
- Multi-GPU scaling tests

**Usage:**
```bash
./testing/benchmark-performance.sh [OPTIONS]

Options:
  -b, --benchmark    Specific benchmark (compute, memory, network, storage, ml)
  -d, --duration     Test duration (default: 300s)
  -i, --iterations   Number of test iterations
  --baseline        Compare against baseline results

Examples:
  # Run ML training benchmarks
  ./testing/benchmark-performance.sh -b ml -d 600s --baseline
  
  # Quick compute performance test  
  ./testing/benchmark-performance.sh -b compute -i 5
```

### Utility Scripts

#### `utilities/node-management.sh`
Node lifecycle management operations.

**Operations:**
- Add/remove nodes from cluster
- Drain and cordon nodes for maintenance
- Label and annotate nodes
- Configure node-specific settings
- Monitor node health and status

**Usage:**
```bash
./utilities/node-management.sh [OPTIONS] <operation> <node>

Operations:
  add         Add node to cluster
  remove      Remove node from cluster  
  drain       Drain node for maintenance
  cordon      Prevent scheduling on node
  uncordon    Allow scheduling on node
  label       Add labels to node
  status      Show node status

Examples:
  # Drain node for maintenance
  ./utilities/node-management.sh drain node-gpu-01
  
  # Add GPU type label
  ./utilities/node-management.sh label node-gpu-01 gpu-type=a100
```

#### `utilities/resource-calculator.sh`
Calculate optimal resource allocations and sizing.

**Calculations:**
- GPU memory requirements per workload
- CPU and system memory needs
- Network bandwidth requirements
- Storage capacity and performance
- Power and cooling estimates
- Cost projections and optimization

**Usage:**
```bash
./utilities/resource-calculator.sh [OPTIONS]

Options:
  -w, --workload     Workload specification file
  -n, --nodes        Number of cluster nodes
  -g, --gpu-type     GPU model for calculations
  -u, --utilization  Target utilization percentage
  --cost-model       Pricing model for calculations

Examples:
  # Calculate resources for training workload
  ./utilities/resource-calculator.sh -w training-workload.yaml -g a100 -u 85
```

#### `utilities/log-analyzer.sh`
Analyze and correlate cluster logs for troubleshooting.

**Analysis Features:**
- Error pattern detection
- Performance anomaly identification
- Resource utilization correlation
- Security event analysis
- Automated recommendations

**Usage:**
```bash
./utilities/log-analyzer.sh [OPTIONS]

Options:
  -t, --timeframe    Analysis timeframe (1h, 24h, 7d)
  -s, --severity     Log severity levels
  -c, --component    Specific component logs
  -o, --output       Output format (text, json, html)
  --anomaly-detection Enable ML-based anomaly detection

Examples:
  # Analyze last 24 hours for errors
  ./utilities/log-analyzer.sh -t 24h -s error,warning -o html
```

## Configuration Management

### Environment Configuration
```bash
# config/environment.conf
export CLUSTER_NAME="gpu-cluster-prod"
export NAMESPACE="gpu-operator"
export REGISTRY="nvcr.io"
export NGC_API_KEY="your-ngc-api-key"
export KUBECONFIG="/path/to/kubeconfig"
export MONITORING_STORAGE_CLASS="fast-ssd"
export BACKUP_LOCATION="s3://cluster-backups"
```

### Global Settings
```yaml
# config/cluster-config.yaml
cluster:
  name: "gpu-cluster-prod"
  region: "us-west-2"
  environment: "production"

gpu:
  operator_version: "v23.9.0"
  driver_version: "535.54.03"
  cuda_version: "12.2"
  sharing:
    enabled: true
    strategy: "time-slicing"
    replicas_per_gpu: 4

monitoring:
  prometheus:
    retention: "30d"
    storage: "100Gi"
  grafana:
    admin_password: "secure-password"
  alerting:
    enabled: true
    channels:
      - type: "slack"
        webhook: "https://hooks.slack.com/webhook-url"

networking:
  fabric: "ethernet"
  mtu: 9000
  rdma: false

security:
  rbac: true
  pod_security_policy: true
  network_policies: true
```

## Best Practices

### Script Development
1. **Error Handling**: Use proper exit codes and error messages
2. **Logging**: Implement structured logging with timestamps
3. **Validation**: Validate inputs and prerequisites
4. **Idempotency**: Scripts should be safe to run multiple times
5. **Documentation**: Include usage examples and parameter descriptions

### Security Considerations
1. **Secrets Management**: Use Kubernetes secrets or external vaults
2. **Access Control**: Implement proper RBAC and service accounts
3. **Network Security**: Configure network policies and firewalls
4. **Audit Logging**: Enable comprehensive audit trails
5. **Container Security**: Scan images and enforce security policies

### Performance Optimization
1. **Resource Limits**: Set appropriate CPU/memory limits
2. **GPU Scheduling**: Optimize GPU allocation strategies
3. **Network Tuning**: Configure optimal network parameters
4. **Storage Performance**: Use high-performance storage classes
5. **Monitoring**: Implement comprehensive performance monitoring

## Troubleshooting

### Common Issues

#### Script Permission Errors
```bash
# Solution: Fix script permissions
chmod +x script-name.sh
```

#### Missing Dependencies
```bash
# Solution: Install required tools
./utilities/install-dependencies.sh
```

#### Configuration Errors
```bash
# Solution: Validate configuration
./utilities/validate-config.sh
```

#### Network Connectivity Issues
```bash
# Solution: Test network connectivity
./testing/test-connectivity.sh
```

### Debug Mode
Most scripts support debug mode for troubleshooting:
```bash
export DEBUG=true
./script-name.sh --verbose
```

### Log Locations
- Script execution logs: `/var/log/gpu-cluster/`
- Application logs: `/var/log/containers/`
- System logs: `/var/log/syslog`

## Contributing

### Adding New Scripts
1. Follow the established directory structure
2. Include proper documentation and usage examples
3. Implement error handling and validation
4. Add appropriate test cases
5. Update this README with new script documentation

### Testing Changes
```bash
# Run script validation
./testing/validate-scripts.sh

# Test in development environment
export CLUSTER_ENV=development
./deployment/deploy-gpu-operator.sh --dry-run
```

### Version Control
- Use semantic versioning for script releases
- Tag releases with appropriate version numbers
- Maintain changelog for significant changes
- Document breaking changes and migration paths

## Support

For issues or questions regarding these automation scripts:

1. Check the troubleshooting section above
2. Review script logs for error details
3. Consult the NVIDIA GPU Operator documentation
4. Contact the solution maintainers listed in metadata.yml

## License

These scripts are provided under the same license terms as the NVIDIA GPU Compute Cluster solution. Please review the license file in the root directory for complete terms and conditions.
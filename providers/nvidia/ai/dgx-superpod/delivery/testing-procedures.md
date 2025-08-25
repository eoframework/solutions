# NVIDIA DGX SuperPOD Testing Procedures

## Overview

This document outlines comprehensive testing procedures for validating the deployment, performance, and operational readiness of the NVIDIA DGX SuperPOD AI infrastructure. These procedures ensure system reliability, performance benchmarks are met, and all components function correctly before production use.

## Table of Contents

1. [Pre-Deployment Testing](#pre-deployment-testing)
2. [Infrastructure Validation](#infrastructure-validation)
3. [Performance Benchmarking](#performance-benchmarking)
4. [Integration Testing](#integration-testing)
5. [Security Testing](#security-testing)
6. [Disaster Recovery Testing](#disaster-recovery-testing)
7. [User Acceptance Testing](#user-acceptance-testing)
8. [Production Readiness Checklist](#production-readiness-checklist)

---

## Pre-Deployment Testing

### Hardware Acceptance Testing

**Physical Infrastructure Validation**

```bash
#!/bin/bash
# Hardware acceptance test script

echo "=== Hardware Acceptance Testing ==="
echo "Test Date: $(date)"
echo "Performed by: $(whoami)"

# Test 1: Power and Environmental
test_power_environmental() {
    echo "1. Power and Environmental Tests"
    
    # Check power consumption
    for node in dgx-{001..020}; do
        echo "Node $node power draw:"
        ssh $node "nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits" 2>/dev/null | awk '{sum+=$1} END {print "Total GPU Power: " sum " watts"}'
    done
    
    # Check cooling systems
    echo "Cooling system status:"
    for node in dgx-{001..020}; do
        ssh $node "nvidia-smi --query-gpu=temperature.gpu,fan.speed --format=csv,noheader" 2>/dev/null | head -1
    done
    
    echo "✓ Power and environmental test completed"
}

# Test 2: Hardware Component Validation
test_hardware_components() {
    echo "2. Hardware Component Validation"
    
    for node in dgx-{001..020}; do
        echo "Testing node: $node"
        
        # GPU detection
        gpu_count=$(ssh $node "nvidia-smi -L | wc -l" 2>/dev/null)
        if [ "$gpu_count" -eq 8 ]; then
            echo "  ✓ GPU count: $gpu_count/8"
        else
            echo "  ✗ GPU count mismatch: $gpu_count/8"
        fi
        
        # Memory validation
        total_mem=$(ssh $node "free -g | awk '/^Mem:/{print \$2}'" 2>/dev/null)
        if [ "$total_mem" -gt 1900 ]; then
            echo "  ✓ System memory: ${total_mem}GB"
        else
            echo "  ✗ Memory insufficient: ${total_mem}GB"
        fi
        
        # Storage validation
        nvme_count=$(ssh $node "lsblk | grep nvme | wc -l" 2>/dev/null)
        echo "  ✓ NVMe drives detected: $nvme_count"
        
        # Network interfaces
        ib_count=$(ssh $node "ibstat | grep 'State: Active' | wc -l" 2>/dev/null)
        echo "  ✓ InfiniBand ports active: $ib_count"
        
        echo ""
    done
    
    echo "✓ Hardware component validation completed"
}

# Execute tests
test_power_environmental
test_hardware_components
```

### Network Infrastructure Testing

**InfiniBand Fabric Validation**

```bash
#!/bin/bash
# Network infrastructure test script

echo "=== Network Infrastructure Testing ==="

# Test 1: InfiniBand Topology Discovery
test_ib_topology() {
    echo "1. InfiniBand Topology Discovery"
    
    # Discover fabric topology
    ibnetdiscover > /tmp/fabric_topology.txt
    
    # Validate expected node count
    node_count=$(grep "DGX" /tmp/fabric_topology.txt | wc -l)
    echo "Discovered DGX nodes: $node_count"
    
    # Check for missing links
    ibdiagnet --output_dir /tmp/ib_diagnostics
    
    echo "✓ Topology discovery completed"
}

# Test 2: Link Quality Testing
test_link_quality() {
    echo "2. InfiniBand Link Quality Testing"
    
    # Test bandwidth between all node pairs
    for i in {1..5}; do  # Test first 5 nodes as sample
        for j in {1..5}; do
            if [ $i -ne $j ]; then
                node1="dgx-$(printf '%03d' $i)"
                node2="dgx-$(printf '%03d' $j)"
                
                echo "Testing bandwidth: $node1 -> $node2"
                ssh $node1 "ib_send_bw -D 10 $node2" 2>/dev/null | grep "BW average" || echo "  Test failed"
            fi
        done
    done
    
    echo "✓ Link quality testing completed"
}

# Test 3: Network Latency Testing
test_network_latency() {
    echo "3. Network Latency Testing"
    
    for node in dgx-{001..005}; do  # Sample nodes
        echo "Latency to $node:"
        ssh dgx-001 "ib_send_lat $node -D 10" 2>/dev/null | grep "typical" || echo "  Test failed"
    done
    
    echo "✓ Network latency testing completed"
}

# Execute network tests
test_ib_topology
test_link_quality
test_network_latency
```

---

## Infrastructure Validation

### Storage System Testing

**Storage Performance and Reliability**

```python
#!/usr/bin/env python3
"""
Storage system validation tests
"""
import subprocess
import time
import statistics
import json
from concurrent.futures import ThreadPoolExecutor
import os

class StorageValidator:
    def __init__(self):
        self.test_results = {}
        self.mount_points = ['/mnt/datasets', '/mnt/models', '/mnt/results', '/mnt/scratch']
    
    def test_mount_accessibility(self):
        """Test if all storage mounts are accessible"""
        print("=== Storage Mount Accessibility Test ===")
        
        results = {}
        for mount in self.mount_points:
            try:
                # Test read access
                test_file = f"{mount}/.storage_test_{int(time.time())}"
                with open(test_file, 'w') as f:
                    f.write("storage test")
                
                # Test write access
                with open(test_file, 'r') as f:
                    content = f.read()
                
                os.remove(test_file)
                results[mount] = "✓ Accessible"
                
            except Exception as e:
                results[mount] = f"✗ Error: {str(e)}"
        
        self.test_results['mount_accessibility'] = results
        for mount, status in results.items():
            print(f"  {mount}: {status}")
        
        return results
    
    def test_storage_performance(self):
        """Test storage I/O performance"""
        print("\n=== Storage Performance Test ===")
        
        def run_fio_test(mount_point):
            """Run FIO performance test on mount point"""
            fio_config = f"""
[global]
ioengine=libaio
direct=1
size=10G
runtime=60
group_reporting
filename={mount_point}/fio_test_file

[seq_read]
rw=read
bs=1M
numjobs=8

[seq_write]
rw=write
bs=1M
numjobs=8
"""
            
            config_file = f"/tmp/fio_config_{mount_point.replace('/', '_')}.ini"
            with open(config_file, 'w') as f:
                f.write(fio_config)
            
            try:
                cmd = f"fio {config_file} --output-format=json"
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=300)
                
                if result.returncode == 0:
                    data = json.loads(result.stdout)
                    read_bw = data['jobs'][0]['read']['bw_mean'] / 1024  # Convert to MB/s
                    write_bw = data['jobs'][1]['write']['bw_mean'] / 1024  # Convert to MB/s
                    
                    return {
                        'mount': mount_point,
                        'read_bandwidth_mbs': round(read_bw, 2),
                        'write_bandwidth_mbs': round(write_bw, 2)
                    }
                else:
                    return {'mount': mount_point, 'error': result.stderr}
                    
            except Exception as e:
                return {'mount': mount_point, 'error': str(e)}
            
            finally:
                # Cleanup
                if os.path.exists(config_file):
                    os.remove(config_file)
                test_file = f"{mount_point}/fio_test_file"
                if os.path.exists(test_file):
                    os.remove(test_file)
        
        # Run performance tests in parallel
        with ThreadPoolExecutor(max_workers=4) as executor:
            future_to_mount = {executor.submit(run_fio_test, mount): mount 
                             for mount in self.mount_points}
            
            results = {}
            for future in future_to_mount:
                mount = future_to_mount[future]
                try:
                    result = future.result()
                    results[mount] = result
                    
                    if 'error' not in result:
                        print(f"  {result['mount']}: Read: {result['read_bandwidth_mbs']} MB/s, "
                              f"Write: {result['write_bandwidth_mbs']} MB/s")
                    else:
                        print(f"  {result['mount']}: Error - {result['error']}")
                        
                except Exception as exc:
                    results[mount] = {'error': str(exc)}
                    print(f"  {mount}: Exception - {exc}")
        
        self.test_results['storage_performance'] = results
        return results
    
    def test_concurrent_access(self):
        """Test concurrent access from multiple nodes"""
        print("\n=== Concurrent Access Test ===")
        
        def concurrent_io_test(node, mount_point):
            """Run concurrent I/O test from specific node"""
            test_file = f"{mount_point}/concurrent_test_{node}_{int(time.time())}"
            
            try:
                # Create test file
                cmd = f'ssh {node} "dd if=/dev/zero of={test_file} bs=1M count=1000"'
                result = subprocess.run(cmd, shell=True, capture_output=True, timeout=120)
                
                if result.returncode == 0:
                    # Read test file
                    cmd = f'ssh {node} "dd if={test_file} of=/dev/null bs=1M"'
                    read_result = subprocess.run(cmd, shell=True, capture_output=True, timeout=120)
                    
                    # Cleanup
                    subprocess.run(f'ssh {node} "rm -f {test_file}"', shell=True)
                    
                    return {'node': node, 'mount': mount_point, 'status': 'success'}
                else:
                    return {'node': node, 'mount': mount_point, 'status': 'failed', 'error': result.stderr.decode()}
                    
            except Exception as e:
                return {'node': node, 'mount': mount_point, 'status': 'error', 'error': str(e)}
        
        # Test concurrent access from first 4 nodes to each mount
        test_nodes = ['dgx-001', 'dgx-002', 'dgx-003', 'dgx-004']
        
        with ThreadPoolExecutor(max_workers=8) as executor:
            futures = []
            for mount in self.mount_points[:2]:  # Test first 2 mounts to save time
                for node in test_nodes:
                    futures.append(executor.submit(concurrent_io_test, node, mount))
            
            results = []
            for future in futures:
                result = future.result()
                results.append(result)
                status_symbol = "✓" if result['status'] == 'success' else "✗"
                print(f"  {status_symbol} {result['node']} -> {result['mount']}: {result['status']}")
        
        self.test_results['concurrent_access'] = results
        return results
    
    def generate_report(self):
        """Generate comprehensive storage test report"""
        print("\n=== Storage Validation Report ===")
        
        # Summary
        total_tests = 0
        passed_tests = 0
        
        for test_name, results in self.test_results.items():
            if isinstance(results, dict):
                for key, value in results.items():
                    total_tests += 1
                    if isinstance(value, str) and "✓" in value:
                        passed_tests += 1
                    elif isinstance(value, dict) and value.get('status') == 'success':
                        passed_tests += 1
            elif isinstance(results, list):
                for result in results:
                    total_tests += 1
                    if result.get('status') == 'success':
                        passed_tests += 1
        
        print(f"Overall Results: {passed_tests}/{total_tests} tests passed")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        # Save detailed report
        with open('/tmp/storage_validation_report.json', 'w') as f:
            json.dump(self.test_results, f, indent=2)
        
        print("Detailed report saved to: /tmp/storage_validation_report.json")
        return self.test_results

if __name__ == "__main__":
    validator = StorageValidator()
    
    # Run all storage tests
    validator.test_mount_accessibility()
    validator.test_storage_performance()
    validator.test_concurrent_access()
    
    # Generate final report
    validator.generate_report()
```

### Cluster Management Testing

**Kubernetes and SLURM Validation**

```bash
#!/bin/bash
# Cluster management validation tests

echo "=== Cluster Management Testing ==="

# Test 1: Kubernetes Cluster Health
test_kubernetes() {
    echo "1. Kubernetes Cluster Validation"
    
    # Check cluster status
    echo "Cluster nodes status:"
    kubectl get nodes -o wide
    
    # Check system pods
    echo -e "\nSystem pods status:"
    kubectl get pods -n kube-system --field-selector=status.phase!=Running
    
    # Test pod scheduling
    echo -e "\nTesting pod scheduling:"
    cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-scheduling
spec:
  containers:
  - name: test
    image: nvidia/cuda:12.0-base-ubuntu20.04
    command: ["sleep", "60"]
    resources:
      limits:
        nvidia.com/gpu: 1
EOF
    
    # Wait and check pod status
    sleep 10
    pod_status=$(kubectl get pod test-scheduling -o jsonpath='{.status.phase}')
    echo "Test pod status: $pod_status"
    
    # Cleanup
    kubectl delete pod test-scheduling
    
    echo "✓ Kubernetes validation completed"
}

# Test 2: SLURM Cluster Health
test_slurm() {
    echo "2. SLURM Cluster Validation"
    
    # Check SLURM cluster status
    echo "SLURM cluster status:"
    sinfo -Nel
    
    # Check SLURM services
    echo -e "\nSLURM services status:"
    systemctl is-active slurmctld
    systemctl is-active slurmd
    
    # Submit test job
    echo -e "\nSubmitting test job:"
    cat << EOF > /tmp/slurm_test.sh
#!/bin/bash
#SBATCH --job-name=validation_test
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1
#SBATCH --time=00:05:00

echo "SLURM test job started at \$(date)"
nvidia-smi
echo "SLURM test job completed at \$(date)"
EOF
    
    chmod +x /tmp/slurm_test.sh
    job_id=$(sbatch /tmp/slurm_test.sh | awk '{print $4}')
    
    echo "Submitted job ID: $job_id"
    
    # Wait for job completion
    while squeue -j $job_id 2>/dev/null | grep -q $job_id; do
        sleep 5
    done
    
    # Check job result
    job_state=$(sacct -j $job_id --format=State --noheader | tr -d ' ')
    echo "Job final state: $job_state"
    
    rm -f /tmp/slurm_test.sh
    echo "✓ SLURM validation completed"
}

# Test 3: GPU Resource Management
test_gpu_resources() {
    echo "3. GPU Resource Management Testing"
    
    # Check GPU detection in Kubernetes
    echo "GPU resources in Kubernetes:"
    kubectl describe nodes | grep -A 5 "Allocatable:" | grep nvidia.com/gpu
    
    # Check GPU detection in SLURM
    echo -e "\nGPU resources in SLURM:"
    scontrol show nodes | grep -i gpu | head -5
    
    echo "✓ GPU resource management validation completed"
}

# Execute cluster tests
test_kubernetes
echo ""
test_slurm
echo ""
test_gpu_resources
```

---

## Performance Benchmarking

### GPU Performance Benchmarks

**NCCL Communication Testing**

```python
#!/usr/bin/env python3
"""
GPU performance benchmarking suite
"""
import subprocess
import json
import time
import statistics
from concurrent.futures import ThreadPoolExecutor

class GPUBenchmark:
    def __init__(self):
        self.results = {}
    
    def test_nccl_allreduce(self):
        """Test NCCL AllReduce performance across cluster"""
        print("=== NCCL AllReduce Benchmark ===")
        
        # Test configurations
        configs = [
            {"nodes": 2, "gpus": 16, "size": "8M"},
            {"nodes": 4, "gpus": 32, "size": "128M"},
            {"nodes": 8, "gpus": 64, "size": "512M"}
        ]
        
        results = []
        
        for config in configs:
            print(f"Testing {config['nodes']} nodes, {config['gpus']} GPUs, {config['size']} data size")
            
            # Create NCCL test command
            node_list = ",".join([f"dgx-{i:03d}" for i in range(1, config['nodes'] + 1)])
            
            cmd = f"""
mpirun -np {config['gpus']} \
    --hostfile <(echo "{node_list}") \
    --allow-run-as-root \
    --bind-to none \
    /usr/local/nccl/build/test/all_reduce_perf \
    -b {config['size']} -e {config['size']} -f 2 -g 1
"""
            
            try:
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=300)
                
                if result.returncode == 0:
                    # Parse bandwidth from output
                    lines = result.stdout.split('\n')
                    for line in lines:
                        if 'Avg bus bandwidth' in line:
                            bandwidth = line.split(':')[1].strip()
                            results.append({
                                'config': config,
                                'bandwidth': bandwidth,
                                'status': 'success'
                            })
                            print(f"  Result: {bandwidth}")
                            break
                else:
                    results.append({
                        'config': config,
                        'error': result.stderr,
                        'status': 'failed'
                    })
                    print(f"  Failed: {result.stderr[:100]}")
                    
            except subprocess.TimeoutExpired:
                results.append({
                    'config': config,
                    'error': 'timeout',
                    'status': 'timeout'
                })
                print(f"  Timeout after 300s")
        
        self.results['nccl_allreduce'] = results
        return results
    
    def test_gpu_compute_performance(self):
        """Test individual GPU compute performance"""
        print("\n=== GPU Compute Performance Benchmark ===")
        
        # GPU compute test using CUDA samples
        def test_node_gpus(node):
            """Test GPU performance on a specific node"""
            try:
                # Run GPU compute benchmark
                cmd = f'ssh {node} "cd /usr/local/cuda/samples/1_Utilities/deviceQuery && ./deviceQuery"'
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60)
                
                if result.returncode == 0:
                    # Extract GPU information
                    gpu_info = []
                    lines = result.stdout.split('\n')
                    current_gpu = {}
                    
                    for line in lines:
                        if 'Device' in line and 'GeForce' in line or 'Tesla' in line or 'H100' in line:
                            if current_gpu:
                                gpu_info.append(current_gpu)
                            current_gpu = {'name': line.strip()}
                        elif 'Memory Clock rate' in line:
                            current_gpu['memory_clock'] = line.split(':')[1].strip()
                        elif 'GPU Max Clock rate' in line:
                            current_gpu['gpu_clock'] = line.split(':')[1].strip()
                    
                    if current_gpu:
                        gpu_info.append(current_gpu)
                    
                    return {'node': node, 'gpus': gpu_info, 'status': 'success'}
                else:
                    return {'node': node, 'error': result.stderr, 'status': 'failed'}
                    
            except Exception as e:
                return {'node': node, 'error': str(e), 'status': 'error'}
        
        # Test first 4 nodes
        test_nodes = [f'dgx-{i:03d}' for i in range(1, 5)]
        
        with ThreadPoolExecutor(max_workers=4) as executor:
            future_to_node = {executor.submit(test_node_gpus, node): node for node in test_nodes}
            
            results = []
            for future in future_to_node:
                result = future.result()
                results.append(result)
                
                if result['status'] == 'success':
                    print(f"  ✓ {result['node']}: {len(result['gpus'])} GPUs detected")
                else:
                    print(f"  ✗ {result['node']}: {result.get('error', 'Unknown error')}")
        
        self.results['gpu_compute'] = results
        return results
    
    def test_memory_bandwidth(self):
        """Test GPU memory bandwidth"""
        print("\n=== GPU Memory Bandwidth Test ===")
        
        def test_node_memory(node):
            """Test memory bandwidth on a node"""
            try:
                # Use bandwidthTest from CUDA samples
                cmd = f'ssh {node} "cd /usr/local/cuda/samples/1_Utilities/bandwidthTest && ./bandwidthTest"'
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=120)
                
                if result.returncode == 0:
                    # Parse bandwidth results
                    lines = result.stdout.split('\n')
                    bandwidth_results = {}
                    
                    for line in lines:
                        if 'Host to Device Bandwidth' in line:
                            bandwidth_results['h2d'] = line.split()[-2] + ' ' + line.split()[-1]
                        elif 'Device to Host Bandwidth' in line:
                            bandwidth_results['d2h'] = line.split()[-2] + ' ' + line.split()[-1]
                        elif 'Device to Device Bandwidth' in line:
                            bandwidth_results['d2d'] = line.split()[-2] + ' ' + line.split()[-1]
                    
                    return {'node': node, 'bandwidth': bandwidth_results, 'status': 'success'}
                else:
                    return {'node': node, 'error': result.stderr, 'status': 'failed'}
                    
            except Exception as e:
                return {'node': node, 'error': str(e), 'status': 'error'}
        
        # Test memory bandwidth on sample nodes
        test_nodes = [f'dgx-{i:03d}' for i in range(1, 4)]
        
        with ThreadPoolExecutor(max_workers=3) as executor:
            results = list(executor.map(test_node_memory, test_nodes))
        
        for result in results:
            if result['status'] == 'success':
                bw = result['bandwidth']
                print(f"  ✓ {result['node']}:")
                print(f"    H2D: {bw.get('h2d', 'N/A')}")
                print(f"    D2H: {bw.get('d2h', 'N/A')}")
                print(f"    D2D: {bw.get('d2d', 'N/A')}")
            else:
                print(f"  ✗ {result['node']}: {result.get('error', 'Failed')}")
        
        self.results['memory_bandwidth'] = results
        return results
    
    def generate_benchmark_report(self):
        """Generate comprehensive benchmark report"""
        print("\n=== Performance Benchmark Report ===")
        
        report = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'results': self.results,
            'summary': {}
        }
        
        # Calculate summary statistics
        total_tests = 0
        passed_tests = 0
        
        for test_type, results in self.results.items():
            test_total = len(results) if isinstance(results, list) else 1
            test_passed = 0
            
            if isinstance(results, list):
                test_passed = sum(1 for r in results if r.get('status') == 'success')
            
            total_tests += test_total
            passed_tests += test_passed
            
            report['summary'][test_type] = {
                'total': test_total,
                'passed': test_passed,
                'success_rate': (test_passed / test_total * 100) if test_total > 0 else 0
            }
        
        report['summary']['overall'] = {
            'total_tests': total_tests,
            'passed_tests': passed_tests,
            'overall_success_rate': (passed_tests / total_tests * 100) if total_tests > 0 else 0
        }
        
        # Save report
        with open('/tmp/gpu_benchmark_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Overall Performance: {passed_tests}/{total_tests} tests passed")
        print(f"Success Rate: {report['summary']['overall']['overall_success_rate']:.1f}%")
        print("Detailed report saved to: /tmp/gpu_benchmark_report.json")
        
        return report

if __name__ == "__main__":
    benchmark = GPUBenchmark()
    
    # Run all benchmarks
    benchmark.test_nccl_allreduce()
    benchmark.test_gpu_compute_performance()
    benchmark.test_memory_bandwidth()
    
    # Generate final report
    benchmark.generate_benchmark_report()
```

---

## Integration Testing

### AI Framework Integration Testing

**TensorFlow and PyTorch Distributed Training Test**

```python
#!/usr/bin/env python3
"""
AI Framework integration testing
"""
import subprocess
import tempfile
import time
import os

class AIFrameworkTesting:
    def __init__(self):
        self.test_results = {}
    
    def test_tensorflow_distributed(self):
        """Test TensorFlow distributed training"""
        print("=== TensorFlow Distributed Training Test ===")
        
        # Create TensorFlow distributed training test script
        tf_script = '''
import tensorflow as tf
import time
import json

# Configure distributed strategy
strategy = tf.distribute.MultiWorkerMirrorStrategy()

print(f"Number of replicas: {strategy.num_replicas_in_sync}")

# Create simple model
with strategy.scope():
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(128, activation='relu', input_shape=(784,)),
        tf.keras.layers.Dense(10, activation='softmax')
    ])
    
    model.compile(optimizer='adam',
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])

# Generate dummy data
(x_train, y_train) = tf.keras.utils.to_categorical(
    tf.random.uniform((1000, 784)), 10), tf.random.uniform((1000,), maxval=10, dtype=tf.int32)

# Training
print("Starting distributed training...")
start_time = time.time()

history = model.fit(x_train, y_train, epochs=5, batch_size=32, verbose=1)

end_time = time.time()
training_time = end_time - start_time

print(f"Training completed in {training_time:.2f} seconds")
print("Test completed successfully")
'''
        
        try:
            # Create test script file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
                f.write(tf_script)
                tf_script_path = f.name
            
            # Run distributed TensorFlow test
            cmd = f'''
export TF_CONFIG='{{"cluster": {{"worker": ["dgx-001:12345", "dgx-002:12345"]}}, "task": {{"type": "worker", "index": 0}}}}'
mpirun -np 2 --hostfile <(echo "dgx-001\ndgx-002") python {tf_script_path}
'''
            
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
            
            if result.returncode == 0 and "Test completed successfully" in result.stdout:
                print("  ✓ TensorFlow distributed training: SUCCESS")
                self.test_results['tensorflow'] = {'status': 'success', 'output': result.stdout}
            else:
                print("  ✗ TensorFlow distributed training: FAILED")
                self.test_results['tensorflow'] = {'status': 'failed', 'error': result.stderr}
                
        except Exception as e:
            print(f"  ✗ TensorFlow test error: {str(e)}")
            self.test_results['tensorflow'] = {'status': 'error', 'error': str(e)}
            
        finally:
            # Cleanup
            if 'tf_script_path' in locals():
                os.unlink(tf_script_path)
    
    def test_pytorch_distributed(self):
        """Test PyTorch distributed training"""
        print("\n=== PyTorch Distributed Training Test ===")
        
        # Create PyTorch distributed training test script
        torch_script = '''
import torch
import torch.nn as nn
import torch.distributed as dist
import torch.multiprocessing as mp
from torch.nn.parallel import DistributedDataParallel as DDP
import time
import os

def setup(rank, world_size):
    os.environ['MASTER_ADDR'] = 'dgx-001'
    os.environ['MASTER_PORT'] = '12355'
    dist.init_process_group("nccl", rank=rank, world_size=world_size)

def cleanup():
    dist.destroy_process_group()

class SimpleModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = nn.Linear(784, 10)
    
    def forward(self, x):
        return self.linear(x)

def train(rank, world_size):
    setup(rank, world_size)
    
    # Create model and move to GPU
    model = SimpleModel().to(rank)
    ddp_model = DDP(model, device_ids=[rank])
    
    # Create dummy data
    data = torch.randn(100, 784).to(rank)
    labels = torch.randint(0, 10, (100,)).to(rank)
    
    optimizer = torch.optim.SGD(ddp_model.parameters(), lr=0.01)
    criterion = nn.CrossEntropyLoss()
    
    print(f"Rank {rank}: Starting training...")
    start_time = time.time()
    
    for epoch in range(5):
        optimizer.zero_grad()
        outputs = ddp_model(data)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        
        if rank == 0:
            print(f"Epoch {epoch}, Loss: {loss.item():.4f}")
    
    end_time = time.time()
    print(f"Rank {rank}: Training completed in {end_time - start_time:.2f} seconds")
    
    cleanup()
    print("PyTorch test completed successfully")

if __name__ == "__main__":
    world_size = 2
    mp.spawn(train, args=(world_size,), nprocs=world_size, join=True)
'''
        
        try:
            # Create test script file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
                f.write(torch_script)
                torch_script_path = f.name
            
            # Run distributed PyTorch test
            cmd = f'mpirun -np 2 --hostfile <(echo "dgx-001\ndgx-002") python {torch_script_path}'
            
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=600)
            
            if result.returncode == 0 and "PyTorch test completed successfully" in result.stdout:
                print("  ✓ PyTorch distributed training: SUCCESS")
                self.test_results['pytorch'] = {'status': 'success', 'output': result.stdout}
            else:
                print("  ✗ PyTorch distributed training: FAILED")
                self.test_results['pytorch'] = {'status': 'failed', 'error': result.stderr}
                
        except Exception as e:
            print(f"  ✗ PyTorch test error: {str(e)}")
            self.test_results['pytorch'] = {'status': 'error', 'error': str(e)}
            
        finally:
            # Cleanup
            if 'torch_script_path' in locals():
                os.unlink(torch_script_path)

if __name__ == "__main__":
    tester = AIFrameworkTesting()
    tester.test_tensorflow_distributed()
    tester.test_pytorch_distributed()
    
    print("\n=== Integration Test Summary ===")
    for framework, result in tester.test_results.items():
        status_symbol = "✓" if result['status'] == 'success' else "✗"
        print(f"{status_symbol} {framework.capitalize()}: {result['status'].upper()}")
```

---

## Security Testing

### Security Validation Tests

```bash
#!/bin/bash
# Security validation test suite

echo "=== Security Validation Testing ==="

# Test 1: Authentication and Authorization
test_authentication() {
    echo "1. Authentication and Authorization Test"
    
    # Test LDAP/AD integration
    echo "Testing LDAP authentication:"
    ldapsearch -x -H ldap://your-ldap-server -D "cn=testuser,dc=company,dc=local" -W -b "dc=company,dc=local" "(cn=testuser)" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "  ✓ LDAP authentication working"
    else
        echo "  ✗ LDAP authentication failed"
    fi
    
    # Test SSH key authentication
    echo "Testing SSH key authentication:"
    for node in dgx-{001..003}; do
        ssh -o BatchMode=yes -o ConnectTimeout=5 $node "echo 'SSH test successful'" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  ✓ SSH to $node successful"
        else
            echo "  ✗ SSH to $node failed"
        fi
    done
    
    echo "✓ Authentication testing completed"
}

# Test 2: Network Security
test_network_security() {
    echo "2. Network Security Test"
    
    # Test firewall rules
    echo "Testing firewall configuration:"
    iptables -L | grep -q "DROP"
    if [ $? -eq 0 ]; then
        echo "  ✓ Firewall rules active"
    else
        echo "  ⚠ No DROP rules found in firewall"
    fi
    
    # Test port accessibility
    echo "Testing restricted port access:"
    for port in 22 80 443 6443; do
        nc -z -w3 dgx-001 $port 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  ✓ Port $port accessible"
        else
            echo "  ⚠ Port $port not accessible"
        fi
    done
    
    # Test for unauthorized open ports
    echo "Checking for unexpected open ports:"
    nmap -sT localhost | grep open | grep -v "22\|80\|443\|6443\|9090\|3000"
    
    echo "✓ Network security testing completed"
}

# Test 3: Data Protection
test_data_protection() {
    echo "3. Data Protection Test"
    
    # Test file permissions
    echo "Testing critical file permissions:"
    
    critical_files=("/etc/passwd" "/etc/shadow" "/etc/ssh/sshd_config" "/etc/kubernetes/admin.conf")
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            perms=$(ls -l "$file" | awk '{print $1}')
            echo "  $file: $perms"
        fi
    done
    
    # Test encryption
    echo "Testing data encryption:"
    mount | grep -q "encryption"
    if [ $? -eq 0 ]; then
        echo "  ✓ Encrypted filesystems detected"
    else
        echo "  ⚠ No encrypted filesystems found"
    fi
    
    echo "✓ Data protection testing completed"
}

# Test 4: Security Monitoring
test_security_monitoring() {
    echo "4. Security Monitoring Test"
    
    # Test log collection
    echo "Testing security log collection:"
    
    log_files=("/var/log/auth.log" "/var/log/syslog" "/var/log/audit/audit.log")
    for log_file in "${log_files[@]}"; do
        if [ -f "$log_file" ] && [ -s "$log_file" ]; then
            echo "  ✓ $log_file exists and has content"
        else
            echo "  ⚠ $log_file missing or empty"
        fi
    done
    
    # Test alerting system
    echo "Testing security alerting:"
    curl -s http://prometheus:9090/api/v1/query?query=up 2>/dev/null | grep -q "success"
    if [ $? -eq 0 ]; then
        echo "  ✓ Monitoring system accessible"
    else
        echo "  ✗ Monitoring system not accessible"
    fi
    
    echo "✓ Security monitoring testing completed"
}

# Execute security tests
test_authentication
echo ""
test_network_security
echo ""
test_data_protection
echo ""
test_security_monitoring

echo ""
echo "=== Security Testing Summary ==="
echo "Review all test results above for any security concerns."
echo "Address any failed tests before proceeding to production."
```

---

## Production Readiness Checklist

### Final Validation Checklist

```bash
#!/bin/bash
# Production readiness checklist

echo "=== DGX SuperPOD Production Readiness Checklist ==="
echo "Date: $(date)"
echo "Validator: $(whoami)"
echo ""

# Initialize counters
total_checks=0
passed_checks=0

check_item() {
    local description="$1"
    local command="$2"
    local expected_result="$3"
    
    total_checks=$((total_checks + 1))
    echo -n "[$total_checks] $description: "
    
    if eval "$command" > /dev/null 2>&1; then
        if [ -z "$expected_result" ] || eval "$command" | grep -q "$expected_result"; then
            echo "✓ PASS"
            passed_checks=$((passed_checks + 1))
        else
            echo "✗ FAIL"
        fi
    else
        echo "✗ FAIL"
    fi
}

echo "=== Infrastructure Checks ==="
check_item "All DGX nodes are accessible via SSH" "ssh dgx-001 'echo test' && ssh dgx-020 'echo test'"
check_item "All GPUs are detected and functional" "pdsh -w dgx-[001-020] 'nvidia-smi -L | wc -l' | grep -q '8'"
check_item "InfiniBand fabric is operational" "ibstat | grep -q 'State: Active'"
check_item "Storage mounts are accessible" "df /mnt/datasets /mnt/models /mnt/results /mnt/scratch"
check_item "Network performance meets baseline" "ib_send_bw dgx-002" "BW average"

echo ""
echo "=== Software Stack Checks ==="
check_item "Kubernetes cluster is healthy" "kubectl get nodes | grep -c 'Ready'" 
check_item "SLURM cluster is operational" "sinfo | grep -q 'idle'"
check_item "Container runtime is functioning" "docker run --rm hello-world" "Hello from Docker"
check_item "AI frameworks are accessible" "docker run --rm nvcr.io/nvidia/tensorflow:latest python -c 'import tensorflow as tf; print(tf.__version__)'"
check_item "NGC registry access is working" "docker pull nvcr.io/nvidia/cuda:latest"

echo ""
echo "=== Security Checks ==="
check_item "Firewall is configured and active" "iptables -L | grep -q 'Chain'"
check_item "SSH key authentication is working" "ssh -o BatchMode=yes dgx-001 'echo test'"
check_item "User authentication is configured" "getent passwd | grep -c ':'"
check_item "System logs are being generated" "test -s /var/log/auth.log"
check_item "Security monitoring is active" "curl -s http://prometheus:9090/api/v1/query?query=up"

echo ""
echo "=== Performance Checks ==="
check_item "GPU utilization monitoring is working" "nvidia-smi --query-gpu=utilization.gpu --format=csv"
check_item "Storage performance meets requirements" "dd if=/dev/zero of=/mnt/scratch/test_file bs=1M count=1000" 
check_item "Network latency is within acceptable range" "ping -c 5 dgx-002" "5 packets transmitted, 5 received"
check_item "Memory usage is optimal" "free | awk 'NR==2{printf \"%.1f\", \$3/\$2*100}' | awk '{print (\$1 < 80)}'" 

echo ""
echo "=== Operational Checks ==="
check_item "Monitoring dashboards are accessible" "curl -s http://monitoring:3000"
check_item "Backup system is configured" "test -f /etc/cron.d/dgx-backup"
check_item "Log rotation is configured" "test -f /etc/logrotate.d/dgx-superpod"
check_item "Documentation is up to date" "test -f /opt/dgx/README.md"
check_item "Emergency procedures are documented" "test -f /opt/dgx/emergency-procedures.md"

echo ""
echo "=== Final Results ==="
echo "Total Checks: $total_checks"
echo "Passed Checks: $passed_checks"
echo "Success Rate: $(echo "scale=1; $passed_checks * 100 / $total_checks" | bc -l)%"

if [ $passed_checks -eq $total_checks ]; then
    echo ""
    echo "🎉 PRODUCTION READY: All checks passed!"
    echo "The DGX SuperPOD is ready for production workloads."
else
    echo ""
    echo "⚠️  PRODUCTION NOT READY: $(($total_checks - $passed_checks)) checks failed."
    echo "Please resolve failed checks before proceeding to production."
fi

echo ""
echo "Detailed test reports available in:"
echo "  - /tmp/gpu_benchmark_report.json"
echo "  - /tmp/storage_validation_report.json"
echo "  - /var/log/dgx-superpod/validation_$(date +%Y%m%d).log"
```

---

## Test Execution Schedule

### Recommended Testing Timeline

**Week 1-2: Infrastructure Testing**
- Hardware acceptance testing
- Network fabric validation
- Storage system testing
- Basic connectivity verification

**Week 3-4: Performance Benchmarking**
- GPU performance benchmarks
- Network performance testing
- Storage I/O performance validation
- End-to-end performance testing

**Week 5: Integration and Security Testing**
- AI framework integration testing
- Security validation
- Backup and recovery testing
- Monitoring system validation

**Week 6: Production Readiness**
- Final validation checklist
- User acceptance testing
- Documentation review
- Go-live preparation

### Acceptance Criteria

**Performance Requirements:**
- GPU utilization >90% during compute-intensive workloads
- NCCL AllReduce bandwidth >300 GB/s for 8-GPU configurations
- Storage throughput >75 GB/s aggregate
- Network latency <2 microseconds node-to-node

**Reliability Requirements:**
- System availability >99.9% during testing period
- Zero critical hardware failures
- All backup and recovery procedures validated
- Monitoring and alerting fully functional

**Security Requirements:**
- All security policies implemented and validated
- Access controls functioning correctly
- Audit logging active and complete
- No high-severity security vulnerabilities

**Operational Requirements:**
- All documentation complete and reviewed
- Staff training completed
- Emergency procedures tested
- Support escalation procedures validated

---

This comprehensive testing document ensures that every aspect of the DGX SuperPOD deployment is thoroughly validated before production use.
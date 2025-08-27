# Cisco Hybrid Infrastructure Testing Procedures

## Overview

This document outlines comprehensive testing procedures for validating the Cisco Hybrid Cloud Infrastructure solution. These procedures ensure the solution meets performance, security, and functionality requirements before production deployment.

## Table of Contents

1. [Testing Framework](#testing-framework)
2. [Pre-Deployment Testing](#pre-deployment-testing)
3. [Infrastructure Testing](#infrastructure-testing)
4. [Application Testing](#application-testing)
5. [Performance Testing](#performance-testing)
6. [Security Testing](#security-testing)
7. [Disaster Recovery Testing](#disaster-recovery-testing)
8. [User Acceptance Testing](#user-acceptance-testing)
9. [Automated Testing](#automated-testing)
10. [Test Documentation](#test-documentation)

## Testing Framework

### 1.1 Testing Methodology

**Testing Phases:**
1. **Unit Testing** - Individual component validation
2. **Integration Testing** - Component interaction validation
3. **System Testing** - End-to-end solution validation
4. **Performance Testing** - Load and stress testing
5. **Security Testing** - Vulnerability and compliance testing
6. **User Acceptance Testing** - Business requirement validation

**Testing Environment:**
- **Development** - Initial testing and validation
- **Staging** - Production-like testing environment
- **Production** - Final validation and acceptance

### 1.2 Test Planning

**Test Plan Template:**

```yaml
test_plan:
  name: "Cisco Hybrid Infrastructure Validation"
  version: "1.0"
  date: "YYYY-MM-DD"
  
  scope:
    - HyperFlex cluster functionality
    - VMware integration
    - ACI network fabric
    - Intersight management
    - Security compliance
    - Performance benchmarks
    
  objectives:
    - Validate technical requirements
    - Verify performance benchmarks
    - Confirm security compliance
    - Validate disaster recovery capabilities
    - Ensure operational readiness
    
  success_criteria:
    - All critical test cases pass (100%)
    - Performance meets or exceeds baselines
    - Security compliance verified
    - No Severity 1 defects
    - Customer acceptance obtained
```

## Pre-Deployment Testing

### 2.1 Infrastructure Readiness

**Network Connectivity Test:**

```bash
#!/bin/bash
# Network connectivity validation script

echo "=== Network Connectivity Testing ==="

# Test basic connectivity
TARGETS=("8.8.8.8" "vcenter.company.com" "apic.company.com" "intersight.com")
for target in "${TARGETS[@]}"; do
    if ping -c 3 $target > /dev/null 2>&1; then
        echo "✓ $target is reachable"
    else
        echo "✗ $target is unreachable"
    fi
done

# Test DNS resolution
echo -e "\n=== DNS Resolution Testing ==="
DNS_NAMES=("vcenter.company.com" "apic.company.com" "hhx-controller.company.com")
for name in "${DNS_NAMES[@]}"; do
    if nslookup $name > /dev/null 2>&1; then
        echo "✓ $name resolves correctly"
    else
        echo "✗ $name DNS resolution failed"
    fi
done

# Test port connectivity
echo -e "\n=== Port Connectivity Testing ==="
declare -A PORT_TESTS=(
    ["vcenter.company.com"]="443"
    ["apic.company.com"]="443"
    ["hx-controller.company.com"]="443"
)

for host in "${!PORT_TESTS[@]}"; do
    port=${PORT_TESTS[$host]}
    if nc -z $host $port 2>/dev/null; then
        echo "✓ $host:$port is accessible"
    else
        echo "✗ $host:$port is not accessible"
    fi
done
```

**Power and Cooling Validation:**

```bash
#!/bin/bash
# Environmental validation script

echo "=== Environmental Validation ==="

# Check UPS status
echo "UPS Status:"
if command -v apcaccess &> /dev/null; then
    apcaccess status
else
    echo "SNMP UPS check required - manual verification needed"
fi

# Check rack PDU status via SNMP
echo -e "\nPDU Status:"
PDU_IPS=("192.168.1.100" "192.168.1.101")
for pdu in "${PDU_IPS[@]}"; do
    if snmpwalk -v2c -c public $pdu 1.3.6.1.4.1.318.1.1.12.2.3.1.1.2 > /dev/null 2>&1; then
        echo "✓ PDU $pdu is responding"
    else
        echo "✗ PDU $pdu is not responding"
    fi
done

# Temperature monitoring
echo -e "\nRack Temperature Check:"
for sensor in /sys/class/hwmon/hwmon*/temp*_input; do
    if [[ -r $sensor ]]; then
        temp=$(( $(cat $sensor) / 1000 ))
        echo "Temperature sensor: ${temp}°C"
        if (( temp > 30 )); then
            echo "⚠ High temperature detected: ${temp}°C"
        fi
    fi
done
```

### 2.2 Hardware Validation

**Server Hardware Test:**

```bash
#!/bin/bash
# Hardware validation script

echo "=== Hardware Validation ==="

# CPU information
echo "CPU Information:"
lscpu | grep -E "(Model name|CPU\(s\)|Thread|Socket)"

# Memory information
echo -e "\nMemory Information:"
dmidecode -t 17 | grep -E "(Size|Speed|Manufacturer)" | grep -v "No Module"

# Storage information
echo -e "\nStorage Information:"
lsblk -d -o NAME,SIZE,MODEL,SERIAL

# Network interfaces
echo -e "\nNetwork Interfaces:"
ip link show | grep -E "(state UP|state DOWN)"

# Hardware health check via IPMI
echo -e "\nIPMI Hardware Status:"
if command -v ipmitool &> /dev/null; then
    ipmitool sdr list | grep -E "(CPU|Memory|Fan|Power|Voltage)" | head -10
else
    echo "IPMI tools not available - use BMC interface for hardware status"
fi
```

## Infrastructure Testing

### 3.1 HyperFlex Cluster Testing

**Cluster Functionality Test:**

```bash
#!/bin/bash
# HyperFlex cluster validation script

echo "=== HyperFlex Cluster Testing ==="

# Cluster status
echo "1. Cluster Status:"
hxcli cluster info | grep -E "(Cluster Status|Health|Version)"

# Node status
echo -e "\n2. Node Status:"
hxcli node list

# Datastore status
echo -e "\n3. Datastore Status:"
hxcli datastore list | grep -E "(Name|Status|Space)"

# Network test between nodes
echo -e "\n4. Network Test:"
hxcli cluster network-test

# Storage performance baseline
echo -e "\n5. Storage Performance:"
hxcli datastore iostat

# Cluster services
echo -e "\n6. Cluster Services:"
hxcli cluster service-status
```

**Storage Test Scripts:**

```python
#!/usr/bin/env python3
# Storage performance validation script

import subprocess
import json
import time
import statistics

def run_fio_test(test_name, block_size, io_pattern, duration=60):
    """Run FIO storage test"""
    
    fio_cmd = [
        'fio',
        f'--name={test_name}',
        '--ioengine=libaio',
        f'--rw={io_pattern}',
        f'--bs={block_size}',
        '--size=10G',
        '--numjobs=4',
        '--iodepth=32',
        f'--runtime={duration}',
        '--group_reporting',
        '--output-format=json'
    ]
    
    try:
        result = subprocess.run(fio_cmd, capture_output=True, text=True)
        data = json.loads(result.stdout)
        
        job = data['jobs'][0]
        
        if io_pattern in ['read', 'randread']:
            iops = job['read']['iops']
            bw_mbps = job['read']['bw'] / 1024  # Convert to MB/s
            lat_us = job['read']['lat_ns']['mean'] / 1000  # Convert to microseconds
        else:
            iops = job['write']['iops']
            bw_mbps = job['write']['bw'] / 1024
            lat_us = job['write']['lat_ns']['mean'] / 1000
        
        return {
            'test_name': test_name,
            'iops': round(iops, 2),
            'bandwidth_mbps': round(bw_mbps, 2),
            'latency_us': round(lat_us, 2)
        }
        
    except Exception as e:
        print(f"Error running FIO test {test_name}: {e}")
        return None

def validate_performance_baseline():
    """Validate storage performance against baseline"""
    
    tests = [
        ('random_read_4k', '4k', 'randread'),
        ('random_write_4k', '4k', 'randwrite'),
        ('sequential_read_1m', '1M', 'read'),
        ('sequential_write_1m', '1M', 'write')
    ]
    
    results = []
    
    print("=== Storage Performance Testing ===")
    
    for test_name, block_size, io_pattern in tests:
        print(f"\nRunning test: {test_name}")
        result = run_fio_test(test_name, block_size, io_pattern)
        if result:
            results.append(result)
            print(f"  IOPS: {result['iops']}")
            print(f"  Bandwidth: {result['bandwidth_mbps']} MB/s")
            print(f"  Latency: {result['latency_us']} μs")
    
    # Generate performance report
    print("\n=== Performance Summary ===")
    for result in results:
        print(f"{result['test_name']}:")
        print(f"  IOPS: {result['iops']}")
        print(f"  Bandwidth: {result['bandwidth_mbps']} MB/s")
        print(f"  Latency: {result['latency_us']} μs")
    
    return results

if __name__ == "__main__":
    performance_results = validate_performance_baseline()
    
    # Save results to JSON file
    with open('performance_baseline.json', 'w') as f:
        json.dump(performance_results, f, indent=2)
    
    print("\nPerformance baseline testing completed")
```

### 3.2 Network Testing

**ACI Fabric Validation:**

```python
#!/usr/bin/env python3
# ACI fabric validation script

import requests
import json
from requests.packages.urllib3.exceptions import InsecureRequestWarning

# Disable SSL warnings
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

class ACITester:
    def __init__(self, apic_ip, username, password):
        self.base_url = f"https://{apic_ip}/api"
        self.session = requests.Session()
        self.session.verify = False
        self.token = self.authenticate(username, password)
    
    def authenticate(self, username, password):
        """Authenticate to APIC"""
        auth_data = {
            "aaaUser": {
                "attributes": {
                    "name": username,
                    "pwd": password
                }
            }
        }
        
        response = self.session.post(
            f"{self.base_url}/aaaLogin.json",
            json=auth_data
        )
        
        if response.status_code == 200:
            return response.json()['imdata'][0]['aaaLogin']['attributes']['token']
        else:
            raise Exception(f"Authentication failed: {response.status_code}")
    
    def get_fabric_health(self):
        """Check fabric health"""
        response = self.session.get(f"{self.base_url}/node/class/fabricHealthTotal.json")
        
        if response.status_code == 200:
            health_data = response.json()['imdata']
            for item in health_data:
                health = item['fabricHealthTotal']['attributes']
                print(f"Fabric Health Score: {health['cur']}/100")
                return int(health['cur'])
        return 0
    
    def check_node_status(self):
        """Check all fabric node status"""
        response = self.session.get(f"{self.base_url}/node/class/fabricNode.json")
        
        if response.status_code == 200:
            nodes = response.json()['imdata']
            print("\nFabric Node Status:")
            for node in nodes:
                attrs = node['fabricNode']['attributes']
                print(f"  Node {attrs['id']} ({attrs['name']}): {attrs['fabricSt']}")
                
    def validate_endpoint_learning(self):
        """Validate endpoint learning"""
        response = self.session.get(f"{self.base_url}/node/class/fvCEp.json")
        
        if response.status_code == 200:
            endpoints = response.json()['imdata']
            print(f"\nLearned Endpoints: {len(endpoints)}")
            
            # Sample endpoint details
            for i, ep in enumerate(endpoints[:5]):  # Show first 5
                attrs = ep['fvCEp']['attributes']
                print(f"  EP {i+1}: {attrs['mac']} -> {attrs['ip']}")

def run_aci_tests():
    """Run ACI fabric tests"""
    try:
        # Configure these values
        APIC_IP = "apic.company.com"
        USERNAME = "admin"
        PASSWORD = "admin_password"
        
        tester = ACITester(APIC_IP, USERNAME, PASSWORD)
        
        print("=== ACI Fabric Testing ===")
        
        health_score = tester.get_fabric_health()
        tester.check_node_status()
        tester.validate_endpoint_learning()
        
        # Validate health score
        if health_score >= 90:
            print(f"\n✓ Fabric health is excellent: {health_score}/100")
        elif health_score >= 75:
            print(f"\n⚠ Fabric health is acceptable: {health_score}/100")
        else:
            print(f"\n✗ Fabric health needs attention: {health_score}/100")
            
    except Exception as e:
        print(f"ACI testing failed: {e}")

if __name__ == "__main__":
    run_aci_tests()
```

**Network Performance Testing:**

```bash
#!/bin/bash
# Network performance testing script

echo "=== Network Performance Testing ==="

# Network bandwidth test between nodes
NODE_IPS=("192.168.1.10" "192.168.1.11" "192.168.1.12" "192.168.1.13")

echo "1. Network Bandwidth Testing:"
for ((i=0; i<${#NODE_IPS[@]}; i++)); do
    for ((j=i+1; j<${#NODE_IPS[@]}; j++)); do
        source_ip=${NODE_IPS[i]}
        target_ip=${NODE_IPS[j]}
        
        echo "Testing bandwidth: $source_ip -> $target_ip"
        
        # Start iperf3 server on target (background process)
        ssh root@$target_ip "iperf3 -s -D"
        sleep 2
        
        # Run bandwidth test
        bandwidth=$(ssh root@$source_ip "iperf3 -c $target_ip -t 10 -f M" | grep "sender" | awk '{print $(NF-1)}')
        echo "  Bandwidth: $bandwidth Mbits/sec"
        
        # Stop iperf3 server
        ssh root@$target_ip "pkill iperf3"
        
        sleep 1
    done
done

# Latency testing
echo -e "\n2. Network Latency Testing:"
for ip in "${NODE_IPS[@]}"; do
    echo "Testing latency to $ip:"
    ping -c 10 $ip | tail -1 | awk -F '/' '{print "  Average: " $5 " ms"}'
done

# MTU size validation
echo -e "\n3. MTU Size Validation:"
for ip in "${NODE_IPS[@]}"; do
    echo "Testing MTU to $ip:"
    if ping -c 3 -M do -s 8972 $ip > /dev/null 2>&1; then
        echo "  ✓ Jumbo frames (9000 MTU) supported"
    else
        echo "  ✗ Jumbo frames not supported"
    fi
done

# VLAN connectivity test
echo -e "\n4. VLAN Connectivity Testing:"
VLAN_IDS=(100 101 102 200 201 202)
for vlan in "${VLAN_IDS[@]}"; do
    # Test if VLAN interface exists and is up
    if ip link show | grep -q "vlan$vlan"; then
        echo "  ✓ VLAN $vlan interface exists"
    else
        echo "  ✗ VLAN $vlan interface not found"
    fi
done
```

### 3.3 VMware Integration Testing

**vCenter Integration Validation:**

```powershell
# PowerCLI script for VMware integration testing

# Connect to vCenter
try {
    Connect-VIServer -Server vcenter.company.com -User administrator@vsphere.local -Password "password"
    Write-Host "✓ vCenter connection successful"
} catch {
    Write-Host "✗ vCenter connection failed: $($_.Exception.Message)"
    exit 1
}

Write-Host "`n=== VMware Integration Testing ==="

# 1. Cluster validation
Write-Host "`n1. Cluster Status:"
$Clusters = Get-Cluster
foreach ($Cluster in $Clusters) {
    Write-Host "  Cluster: $($Cluster.Name)"
    Write-Host "    DRS Enabled: $($Cluster.DrsEnabled)"
    Write-Host "    HA Enabled: $($Cluster.HAEnabled)"
    Write-Host "    Host Count: $($Cluster.ExtensionData.Summary.NumHosts)"
}

# 2. Host validation
Write-Host "`n2. ESXi Host Status:"
$Hosts = Get-VMHost
foreach ($Host in $Hosts) {
    $HostInfo = @{
        Name = $Host.Name
        ConnectionState = $Host.ConnectionState
        PowerState = $Host.PowerState
        Version = $Host.Version
        CPUUsage = [math]::Round($Host.CpuUsageMhz / $Host.CpuTotalMhz * 100, 2)
        MemoryUsage = [math]::Round($Host.MemoryUsageGB / $Host.MemoryTotalGB * 100, 2)
    }
    
    Write-Host "  Host: $($HostInfo.Name)"
    Write-Host "    Connection: $($HostInfo.ConnectionState)"
    Write-Host "    Power: $($HostInfo.PowerState)"
    Write-Host "    Version: $($HostInfo.Version)"
    Write-Host "    CPU Usage: $($HostInfo.CPUUsage)%"
    Write-Host "    Memory Usage: $($HostInfo.MemoryUsage)%"
}

# 3. Datastore validation
Write-Host "`n3. Datastore Status:"
$Datastores = Get-Datastore
foreach ($Datastore in $Datastores) {
    $FreeSpacePct = [math]::Round($Datastore.FreeSpaceGB / $Datastore.CapacityGB * 100, 2)
    Write-Host "  Datastore: $($Datastore.Name)"
    Write-Host "    Capacity: $([math]::Round($Datastore.CapacityGB, 2)) GB"
    Write-Host "    Free Space: $([math]::Round($Datastore.FreeSpaceGB, 2)) GB ($FreeSpacePct%)"
    Write-Host "    Type: $($Datastore.Type)"
}

# 4. Network validation
Write-Host "`n4. Virtual Switch Status:"
$VirtualSwitches = Get-VirtualSwitch
foreach ($vSwitch in $VirtualSwitches) {
    Write-Host "  vSwitch: $($vSwitch.Name)"
    Write-Host "    Type: $($vSwitch.GetType().Name)"
    Write-Host "    Host: $($vSwitch.VMHost.Name)"
    
    $PortGroups = Get-VirtualPortGroup -VirtualSwitch $vSwitch
    foreach ($PG in $PortGroups) {
        Write-Host "    Port Group: $($PG.Name) (VLAN: $($PG.VLanId))"
    }
}

# 5. VM template validation
Write-Host "`n5. VM Template Status:"
$Templates = Get-Template
foreach ($Template in $Templates) {
    Write-Host "  Template: $($Template.Name)"
    Write-Host "    OS: $($Template.ExtensionData.Summary.Config.GuestFullName)"
    Write-Host "    Memory: $($Template.MemoryGB) GB"
    Write-Host "    CPU: $($Template.NumCpu) vCPU"
}

# Disconnect from vCenter
Disconnect-VIServer -Confirm:$false
Write-Host "`nVMware integration testing completed"
```

## Performance Testing

### 4.1 Load Testing

**VM Workload Simulation:**

```python
#!/usr/bin/env python3
# VM workload simulation and load testing

import subprocess
import threading
import time
import json
import random
from concurrent.futures import ThreadPoolExecutor

class VMLoadTester:
    def __init__(self):
        self.results = {
            'vm_operations': [],
            'performance_metrics': [],
            'errors': []
        }
    
    def create_test_vm(self, vm_name, template_name, datastore):
        """Create a test VM from template"""
        try:
            start_time = time.time()
            
            # PowerCLI command to create VM
            powercli_cmd = f'''
            Connect-VIServer -Server vcenter.company.com -User admin -Password password
            New-VM -Name "{vm_name}" -Template "{template_name}" -Datastore "{datastore}"
            Disconnect-VIServer -Confirm:$false
            '''
            
            result = subprocess.run(
                ['powershell', '-Command', powercli_cmd],
                capture_output=True, text=True
            )
            
            end_time = time.time()
            duration = end_time - start_time
            
            if result.returncode == 0:
                self.results['vm_operations'].append({
                    'operation': 'create_vm',
                    'vm_name': vm_name,
                    'duration_seconds': duration,
                    'status': 'success'
                })
                return True
            else:
                self.results['errors'].append({
                    'operation': 'create_vm',
                    'vm_name': vm_name,
                    'error': result.stderr
                })
                return False
                
        except Exception as e:
            self.results['errors'].append({
                'operation': 'create_vm',
                'vm_name': vm_name,
                'error': str(e)
            })
            return False
    
    def power_on_vm(self, vm_name):
        """Power on a VM"""
        try:
            start_time = time.time()
            
            powercli_cmd = f'''
            Connect-VIServer -Server vcenter.company.com -User admin -Password password
            Start-VM -VM "{vm_name}"
            Disconnect-VIServer -Confirm:$false
            '''
            
            result = subprocess.run(
                ['powershell', '-Command', powercli_cmd],
                capture_output=True, text=True
            )
            
            end_time = time.time()
            duration = end_time - start_time
            
            if result.returncode == 0:
                self.results['vm_operations'].append({
                    'operation': 'power_on',
                    'vm_name': vm_name,
                    'duration_seconds': duration,
                    'status': 'success'
                })
                return True
            else:
                self.results['errors'].append({
                    'operation': 'power_on',
                    'vm_name': vm_name,
                    'error': result.stderr
                })
                return False
                
        except Exception as e:
            self.results['errors'].append({
                'operation': 'power_on',
                'vm_name': vm_name,
                'error': str(e)
            })
            return False
    
    def simulate_storage_load(self, duration_minutes=10):
        """Simulate storage I/O load"""
        try:
            # Run FIO test to simulate storage load
            fio_cmd = [
                'fio',
                '--name=load_test',
                '--ioengine=libaio',
                '--rw=randwrite',
                '--bs=4k',
                '--size=5G',
                '--numjobs=8',
                '--iodepth=32',
                f'--runtime={duration_minutes * 60}',
                '--group_reporting',
                '--output-format=json'
            ]
            
            result = subprocess.run(fio_cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                data = json.loads(result.stdout)
                job = data['jobs'][0]
                
                self.results['performance_metrics'].append({
                    'test_type': 'storage_load',
                    'write_iops': job['write']['iops'],
                    'write_bandwidth_kbps': job['write']['bw'],
                    'avg_latency_us': job['write']['lat_ns']['mean'] / 1000,
                    'duration_minutes': duration_minutes
                })
                
        except Exception as e:
            self.results['errors'].append({
                'operation': 'storage_load_test',
                'error': str(e)
            })
    
    def run_concurrent_vm_creation(self, vm_count=50):
        """Create multiple VMs concurrently"""
        template_name = "Windows-2019-Template"
        datastore = "HX-Datastore-01"
        
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = []
            
            for i in range(vm_count):
                vm_name = f"LoadTest-VM-{i:03d}"
                future = executor.submit(self.create_test_vm, vm_name, template_name, datastore)
                futures.append(future)
            
            # Wait for all VMs to be created
            success_count = sum(1 for future in futures if future.result())
            
            print(f"Successfully created {success_count}/{vm_count} VMs")
            
            # Power on VMs
            power_on_futures = []
            for i in range(success_count):
                vm_name = f"LoadTest-VM-{i:03d}"
                future = executor.submit(self.power_on_vm, vm_name)
                power_on_futures.append(future)
            
            powered_on = sum(1 for future in power_on_futures if future.result())
            print(f"Successfully powered on {powered_on}/{success_count} VMs")
    
    def generate_load_test_report(self):
        """Generate comprehensive load test report"""
        report = {
            'test_summary': {
                'total_operations': len(self.results['vm_operations']),
                'successful_operations': len([op for op in self.results['vm_operations'] if op['status'] == 'success']),
                'failed_operations': len(self.results['errors']),
                'performance_tests': len(self.results['performance_metrics'])
            },
            'detailed_results': self.results
        }
        
        with open('load_test_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        print("Load test report saved to load_test_report.json")
        return report

def run_load_tests():
    """Main load testing execution"""
    tester = VMLoadTester()
    
    print("=== VM Load Testing ===")
    print("Starting concurrent VM creation test...")
    tester.run_concurrent_vm_creation(vm_count=20)
    
    print("\nStarting storage load simulation...")
    tester.simulate_storage_load(duration_minutes=5)
    
    print("\nGenerating load test report...")
    report = tester.generate_load_test_report()
    
    # Print summary
    summary = report['test_summary']
    print(f"\nTest Summary:")
    print(f"  Total operations: {summary['total_operations']}")
    print(f"  Successful operations: {summary['successful_operations']}")
    print(f"  Failed operations: {summary['failed_operations']}")
    print(f"  Performance tests: {summary['performance_tests']}")

if __name__ == "__main__":
    run_load_tests()
```

### 4.2 Stress Testing

**System Stress Testing:**

```bash
#!/bin/bash
# System stress testing script

echo "=== System Stress Testing ==="

# CPU stress test
echo "1. CPU Stress Test (5 minutes)..."
stress-ng --cpu 0 --timeout 300s --metrics-brief &
CPU_PID=$!

# Memory stress test
echo "2. Memory Stress Test (5 minutes)..."
TOTAL_MEM=$(free -g | awk '/^Mem:/{print int($2 * 0.8)}')  # Use 80% of available memory
stress-ng --vm 4 --vm-bytes ${TOTAL_MEM}G --timeout 300s --metrics-brief &
MEM_PID=$!

# Storage I/O stress test
echo "3. Storage I/O Stress Test (5 minutes)..."
stress-ng --io 8 --hdd 4 --timeout 300s --metrics-brief &
IO_PID=$!

# Network stress test
echo "4. Network Stress Test..."
# Generate network traffic between nodes
NODE_IPS=("192.168.1.10" "192.168.1.11" "192.168.1.12")
for ip in "${NODE_IPS[@]}"; do
    iperf3 -c $ip -t 300 -P 4 > /dev/null 2>&1 &
done

# Monitor system during stress test
echo "5. Monitoring system performance during stress test..."
for i in {1..30}; do
    echo "Minute $i:"
    
    # CPU utilization
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
    echo "  CPU Usage: ${cpu_usage}%"
    
    # Memory utilization
    mem_usage=$(free | awk '/Mem/{printf("%.2f"), $3/$2*100}')
    echo "  Memory Usage: ${mem_usage}%"
    
    # Load average
    load_avg=$(uptime | awk -F'load average:' '{print $2}')
    echo "  Load Average:${load_avg}"
    
    # I/O wait
    io_wait=$(top -bn1 | grep "Cpu(s)" | awk '{print $5}' | sed 's/%wa,//')
    echo "  I/O Wait: ${io_wait}%"
    
    sleep 60
done

# Clean up stress processes
kill $CPU_PID $MEM_PID $IO_PID 2>/dev/null
pkill iperf3

echo "Stress testing completed"
```

## Security Testing

### 5.1 Security Validation

**Security Configuration Audit:**

```bash
#!/bin/bash
# Security configuration audit script

echo "=== Security Configuration Audit ==="

# 1. SSL/TLS certificate validation
echo "1. SSL Certificate Validation:"
SERVICES=("vcenter.company.com:443" "apic.company.com:443" "hx-controller:443")
for service in "${SERVICES[@]}"; do
    echo "Checking $service..."
    openssl s_client -connect $service -servername $(echo $service | cut -d: -f1) </dev/null 2>/dev/null | openssl x509 -noout -dates
done

# 2. Password policy compliance
echo -e "\n2. Password Policy Compliance:"
# Check HyperFlex password policy
hxcli auth password-policy show

# 3. User account audit
echo -e "\n3. User Account Audit:"
hxcli user list
echo "Last login times:"
lastlog | head -10

# 4. Network security
echo -e "\n4. Network Security Scan:"
# Basic port scan
nmap -sS -O localhost | grep -E "(open|filtered)"

# 5. File permissions audit
echo -e "\n5. Critical File Permissions:"
CRITICAL_FILES=(
    "/etc/shadow"
    "/etc/passwd" 
    "/etc/ssh/sshd_config"
    "/etc/ssl/private/"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [[ -e $file ]]; then
        ls -la $file
    fi
done

# 6. Service configuration review
echo -e "\n6. Service Configuration Review:"
echo "SSH Configuration:"
grep -E "(PermitRootLogin|PasswordAuthentication|Protocol)" /etc/ssh/sshd_config

echo -e "\nFirewall Status:"
if command -v ufw &> /dev/null; then
    ufw status
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --list-all
else
    iptables -L -n
fi
```

**Vulnerability Scanning:**

```python
#!/usr/bin/env python3
# Basic vulnerability scanning script

import subprocess
import json
import socket
import ssl
import datetime

class SecurityScanner:
    def __init__(self):
        self.results = {
            'timestamp': datetime.datetime.now().isoformat(),
            'vulnerabilities': [],
            'security_checks': [],
            'recommendations': []
        }
    
    def check_ssl_configuration(self, hostname, port=443):
        """Check SSL/TLS configuration"""
        try:
            context = ssl.create_default_context()
            
            with socket.create_connection((hostname, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()
                    cipher = ssock.cipher()
                    
                    # Check certificate expiration
                    not_after = datetime.datetime.strptime(cert['notAfter'], '%b %d %H:%M:%S %Y %Z')
                    days_until_expiry = (not_after - datetime.datetime.now()).days
                    
                    check_result = {
                        'service': f'{hostname}:{port}',
                        'certificate_subject': dict(x[0] for x in cert['subject']),
                        'certificate_issuer': dict(x[0] for x in cert['issuer']),
                        'expires_in_days': days_until_expiry,
                        'cipher_suite': cipher[0],
                        'tls_version': cipher[1]
                    }
                    
                    self.results['security_checks'].append(check_result)
                    
                    if days_until_expiry < 30:
                        self.results['vulnerabilities'].append({
                            'type': 'certificate_expiration',
                            'service': f'{hostname}:{port}',
                            'severity': 'medium',
                            'description': f'Certificate expires in {days_until_expiry} days'
                        })
                    
                    if cipher[1] < 'TLSv1.2':
                        self.results['vulnerabilities'].append({
                            'type': 'weak_tls_version',
                            'service': f'{hostname}:{port}',
                            'severity': 'high',
                            'description': f'Using {cipher[1]}, upgrade to TLS 1.2 or higher'
                        })
                    
        except Exception as e:
            self.results['vulnerabilities'].append({
                'type': 'ssl_check_failed',
                'service': f'{hostname}:{port}',
                'severity': 'medium',
                'description': f'SSL check failed: {str(e)}'
            })
    
    def check_open_ports(self, hostname):
        """Check for open ports"""
        common_ports = [22, 23, 25, 53, 80, 110, 143, 443, 993, 995, 3389, 5432, 3306]
        open_ports = []
        
        for port in common_ports:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)
            
            result = sock.connect_ex((hostname, port))
            if result == 0:
                open_ports.append(port)
            
            sock.close()
        
        self.results['security_checks'].append({
            'check_type': 'port_scan',
            'hostname': hostname,
            'open_ports': open_ports
        })
        
        # Check for potentially risky open ports
        risky_ports = {23: 'Telnet', 21: 'FTP', 25: 'SMTP', 110: 'POP3', 143: 'IMAP'}
        for port in open_ports:
            if port in risky_ports:
                self.results['vulnerabilities'].append({
                    'type': 'risky_service',
                    'service': f'{hostname}:{port}',
                    'severity': 'medium',
                    'description': f'{risky_ports[port]} service detected - consider securing or disabling'
                })
    
    def generate_security_report(self):
        """Generate comprehensive security report"""
        # Add general recommendations
        if len(self.results['vulnerabilities']) == 0:
            self.results['recommendations'].append("No critical vulnerabilities found")
        else:
            self.results['recommendations'].append("Address identified vulnerabilities promptly")
            
        self.results['recommendations'].extend([
            "Regularly update system patches",
            "Review user access permissions quarterly",
            "Implement network segmentation where possible",
            "Enable audit logging for all critical systems",
            "Conduct regular security assessments"
        ])
        
        # Save report
        with open('security_scan_report.json', 'w') as f:
            json.dump(self.results, f, indent=2)
        
        # Print summary
        print(f"Security scan completed at {self.results['timestamp']}")
        print(f"Vulnerabilities found: {len(self.results['vulnerabilities'])}")
        print(f"Security checks performed: {len(self.results['security_checks'])}")
        
        if self.results['vulnerabilities']:
            print("\nVulnerabilities:")
            for vuln in self.results['vulnerabilities']:
                print(f"  - {vuln['type']} ({vuln['severity']}): {vuln['description']}")
        
        return self.results

def run_security_tests():
    """Run security testing suite"""
    scanner = SecurityScanner()
    
    print("=== Security Testing ===")
    
    # Test SSL configurations
    services = [
        "vcenter.company.com",
        "apic.company.com", 
        "hx-controller.company.com"
    ]
    
    for service in services:
        print(f"Checking SSL configuration for {service}...")
        scanner.check_ssl_configuration(service)
    
    # Port scanning
    for service in services:
        print(f"Scanning ports for {service}...")
        scanner.check_open_ports(service)
    
    # Generate report
    print("Generating security report...")
    scanner.generate_security_report()

if __name__ == "__main__":
    run_security_tests()
```

## Automated Testing

### 6.1 Continuous Testing Framework

**Automated Test Suite:**

```python
#!/usr/bin/env python3
# Automated testing framework for Cisco Hybrid Infrastructure

import unittest
import subprocess
import json
import time
import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

class HyperFlexTests(unittest.TestCase):
    """HyperFlex cluster tests"""
    
    def setUp(self):
        self.cluster_ip = "hx-controller.company.com"
    
    def test_cluster_status(self):
        """Test HyperFlex cluster is online and healthy"""
        result = subprocess.run(['hxcli', 'cluster', 'info'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, "HyperFlex CLI command failed")
        self.assertIn("ONLINE", result.stdout, "Cluster is not online")
        self.assertIn("HEALTHY", result.stdout, "Cluster is not healthy")
    
    def test_node_status(self):
        """Test all nodes are online"""
        result = subprocess.run(['hxcli', 'node', 'list'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, "Failed to get node list")
        
        # Check that no nodes are offline
        self.assertNotIn("OFFLINE", result.stdout, "One or more nodes are offline")
    
    def test_datastore_capacity(self):
        """Test datastore capacity is within acceptable limits"""
        result = subprocess.run(['hxcli', 'datastore', 'list'], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, "Failed to get datastore info")
        
        # Parse output and check capacity (simplified check)
        lines = result.stdout.split('\n')
        for line in lines:
            if 'Space Used' in line and '%' in line:
                usage_str = line.split('%')[0].split()[-1]
                usage_pct = int(usage_str)
                self.assertLess(usage_pct, 90, f"Datastore usage too high: {usage_pct}%")

class VMwareTests(unittest.TestCase):
    """VMware integration tests"""
    
    def setUp(self):
        self.vcenter_ip = "vcenter.company.com"
    
    def test_vcenter_accessibility(self):
        """Test vCenter is accessible"""
        try:
            response = requests.get(f"https://{self.vcenter_ip}/ui/", 
                                   verify=False, timeout=10)
            self.assertEqual(response.status_code, 200, "vCenter UI not accessible")
        except requests.exceptions.RequestException as e:
            self.fail(f"vCenter connection failed: {e}")
    
    def test_esxi_host_status(self):
        """Test ESXi hosts are connected"""
        # This would require PowerCLI integration
        # Simplified test using ping
        hosts = ["esx01.company.com", "esx02.company.com", "esx03.company.com"]
        
        for host in hosts:
            result = subprocess.run(['ping', '-c', '3', host], 
                                   capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, f"ESXi host {host} not reachable")

class ACITests(unittest.TestCase):
    """ACI fabric tests"""
    
    def setUp(self):
        self.apic_ip = "apic.company.com"
        self.username = "admin"
        self.password = "admin_password"
    
    def test_apic_accessibility(self):
        """Test APIC is accessible"""
        try:
            response = requests.get(f"https://{self.apic_ip}/api/node/class/topSystem.json", 
                                   verify=False, timeout=10)
            self.assertEqual(response.status_code, 200, "APIC API not accessible")
        except requests.exceptions.RequestException as e:
            self.fail(f"APIC connection failed: {e}")
    
    def test_fabric_health(self):
        """Test fabric health is acceptable"""
        try:
            # Authenticate to APIC
            auth_data = {
                "aaaUser": {
                    "attributes": {
                        "name": self.username,
                        "pwd": self.password
                    }
                }
            }
            
            session = requests.Session()
            session.verify = False
            
            auth_response = session.post(
                f"https://{self.apic_ip}/api/aaaLogin.json",
                json=auth_data
            )
            self.assertEqual(auth_response.status_code, 200, "APIC authentication failed")
            
            # Get fabric health
            health_response = session.get(
                f"https://{self.apic_ip}/api/node/class/fabricHealthTotal.json"
            )
            self.assertEqual(health_response.status_code, 200, "Failed to get fabric health")
            
            health_data = health_response.json()['imdata']
            if health_data:
                health_score = int(health_data[0]['fabricHealthTotal']['attributes']['cur'])
                self.assertGreaterEqual(health_score, 75, f"Fabric health too low: {health_score}")
            
        except requests.exceptions.RequestException as e:
            self.fail(f"Fabric health check failed: {e}")

class NetworkTests(unittest.TestCase):
    """Network connectivity tests"""
    
    def test_dns_resolution(self):
        """Test DNS resolution for critical services"""
        services = [
            "vcenter.company.com",
            "apic.company.com",
            "hx-controller.company.com"
        ]
        
        for service in services:
            result = subprocess.run(['nslookup', service], 
                                   capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, f"DNS resolution failed for {service}")
    
    def test_network_latency(self):
        """Test network latency is acceptable"""
        targets = ["8.8.8.8", "1.1.1.1"]  # External DNS servers
        
        for target in targets:
            result = subprocess.run(['ping', '-c', '5', target], 
                                   capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, f"Cannot reach {target}")
            
            # Extract average latency (simplified)
            if "avg" in result.stdout:
                # This would need proper parsing for production use
                pass

class PerformanceTests(unittest.TestCase):
    """Performance benchmark tests"""
    
    def test_storage_performance(self):
        """Test storage performance meets baseline"""
        # Run simple I/O test
        fio_cmd = [
            'fio', '--name=test', '--ioengine=libaio', '--rw=randread',
            '--bs=4k', '--size=1G', '--numjobs=1', '--iodepth=8',
            '--runtime=30', '--group_reporting', '--output-format=json'
        ]
        
        try:
            result = subprocess.run(fio_cmd, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, "FIO test failed")
            
            data = json.loads(result.stdout)
            read_iops = data['jobs'][0]['read']['iops']
            
            # Check against baseline (example: minimum 5000 IOPS)
            self.assertGreater(read_iops, 5000, f"Read IOPS too low: {read_iops}")
            
        except (subprocess.CalledProcessError, json.JSONDecodeError, KeyError) as e:
            self.fail(f"Performance test failed: {e}")

def create_test_suite():
    """Create comprehensive test suite"""
    suite = unittest.TestSuite()
    
    # Add test classes
    test_classes = [
        HyperFlexTests,
        VMwareTests,
        ACITests,
        NetworkTests,
        PerformanceTests
    ]
    
    for test_class in test_classes:
        tests = unittest.TestLoader().loadTestsFromTestCase(test_class)
        suite.addTests(tests)
    
    return suite

class TestResultsReporter:
    """Custom test results reporter"""
    
    def __init__(self):
        self.results = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S'),
            'total_tests': 0,
            'passed_tests': 0,
            'failed_tests': 0,
            'error_tests': 0,
            'failures': [],
            'errors': []
        }
    
    def generate_report(self, test_result):
        """Generate test report"""
        self.results['total_tests'] = test_result.testsRun
        self.results['passed_tests'] = (test_result.testsRun - 
                                       len(test_result.failures) - 
                                       len(test_result.errors))
        self.results['failed_tests'] = len(test_result.failures)
        self.results['error_tests'] = len(test_result.errors)
        
        # Record failures and errors
        for test, traceback in test_result.failures:
            self.results['failures'].append({
                'test': str(test),
                'traceback': traceback
            })
        
        for test, traceback in test_result.errors:
            self.results['errors'].append({
                'test': str(test),
                'traceback': traceback
            })
        
        # Save to file
        with open('automated_test_results.json', 'w') as f:
            json.dump(self.results, f, indent=2)
        
        # Print summary
        print(f"\n=== Automated Test Results ===")
        print(f"Timestamp: {self.results['timestamp']}")
        print(f"Total tests: {self.results['total_tests']}")
        print(f"Passed: {self.results['passed_tests']}")
        print(f"Failed: {self.results['failed_tests']}")
        print(f"Errors: {self.results['error_tests']}")
        
        if self.results['failures']:
            print(f"\nFailures:")
            for failure in self.results['failures']:
                print(f"  - {failure['test']}")
        
        if self.results['errors']:
            print(f"\nErrors:")
            for error in self.results['errors']:
                print(f"  - {error['test']}")
        
        return self.results

def run_automated_tests():
    """Main function to run automated tests"""
    print("=== Running Automated Test Suite ===")
    
    # Create test suite
    suite = create_test_suite()
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Generate report
    reporter = TestResultsReporter()
    report = reporter.generate_report(result)
    
    # Return success/failure for CI/CD integration
    return len(report['failures']) == 0 and len(report['errors']) == 0

if __name__ == "__main__":
    success = run_automated_tests()
    exit(0 if success else 1)
```

## Test Documentation

### 7.1 Test Case Templates

**Test Case Template:**

```yaml
test_case:
  id: "TC-001"
  title: "HyperFlex Cluster Status Validation"
  category: "Infrastructure"
  priority: "Critical"
  
  description: "Verify that the HyperFlex cluster is online and all nodes are healthy"
  
  preconditions:
    - HyperFlex cluster is deployed
    - Management network connectivity is established
    - HyperFlex CLI is accessible
  
  test_steps:
    - step: 1
      action: "Execute 'hxcli cluster info' command"
      expected_result: "Command executes successfully"
    
    - step: 2
      action: "Verify cluster status in command output"
      expected_result: "Status shows 'ONLINE'"
    
    - step: 3
      action: "Verify cluster health in command output"
      expected_result: "Health shows 'HEALTHY'"
  
  postconditions:
    - System remains in operational state
    - No configuration changes made
  
  pass_criteria:
    - All test steps pass
    - Cluster shows ONLINE and HEALTHY status
  
  test_data:
    cluster_ip: "192.168.100.10"
    expected_nodes: 4
    expected_status: "ONLINE"
```

### 7.2 Test Execution Reports

**Test Execution Report Template:**

```markdown
# Test Execution Report

## Executive Summary
- **Test Date**: [Date]
- **Test Environment**: Production/Staging
- **Total Test Cases**: [Number]
- **Passed**: [Number] ([Percentage]%)
- **Failed**: [Number] ([Percentage]%)
- **Overall Result**: PASS/FAIL

## Test Environment Details
- **HyperFlex Version**: [Version]
- **VMware vCenter Version**: [Version]
- **ACI APIC Version**: [Version]
- **Intersight Version**: [Version]

## Test Results Summary

### Infrastructure Tests
| Test Case ID | Test Name | Status | Notes |
|--------------|-----------|--------|-------|
| TC-001 | Cluster Status | PASS | All nodes online |
| TC-002 | Storage Capacity | PASS | 65% utilization |
| TC-003 | Network Connectivity | PASS | All links up |

### Performance Tests
| Test Case ID | Test Name | Baseline | Actual | Status |
|--------------|-----------|----------|--------|--------|
| TC-101 | Storage IOPS | 50,000 | 52,000 | PASS |
| TC-102 | Network Bandwidth | 10 Gbps | 9.8 Gbps | PASS |
| TC-103 | VM Boot Time | 60s | 45s | PASS |

### Security Tests
| Test Case ID | Test Name | Status | Findings |
|--------------|-----------|--------|----------|
| TC-201 | Certificate Validation | PASS | Valid certificates |
| TC-202 | Access Control | PASS | Proper permissions |
| TC-203 | Encryption Status | PASS | All traffic encrypted |

## Issues and Recommendations

### Critical Issues
- None identified

### Non-Critical Issues
1. **Issue**: Minor performance variance in storage latency
   - **Impact**: Low
   - **Recommendation**: Monitor during production

### Recommendations
1. Implement automated monitoring for performance baselines
2. Schedule quarterly disaster recovery testing
3. Update security certificates before expiration

## Sign-off
- **Test Manager**: [Name] - [Date]
- **Technical Lead**: [Name] - [Date]
- **Customer Representative**: [Name] - [Date]
```

---

**Testing Procedures Version**: 1.0  
**Last Updated**: [Date]  
**Next Review**: [Date + 90 days]
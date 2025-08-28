# Dell PowerEdge CI Infrastructure - Troubleshooting Guide

## Overview

This comprehensive troubleshooting guide provides systematic approaches to diagnosing and resolving common issues encountered in Dell PowerEdge CI infrastructure environments. The guide is organized by component and includes step-by-step diagnostic procedures, root cause analysis techniques, and resolution strategies.

## Troubleshooting Methodology

### Systematic Approach
```yaml
troubleshooting_process:
  step_1_identify:
    - "Clearly define the problem and symptoms"
    - "Gather information about when the issue started"
    - "Identify which components are affected"
    - "Determine the scope and impact of the problem"
  
  step_2_gather_data:
    - "Collect relevant logs and error messages"
    - "Review monitoring data and metrics"
    - "Check system configurations and recent changes"
    - "Document environmental conditions"
  
  step_3_analyze:
    - "Compare current state to baseline configuration"
    - "Analyze patterns in logs and monitoring data"
    - "Identify potential root causes"
    - "Correlate events across multiple systems"
  
  step_4_hypothesize:
    - "Develop theories about the root cause"
    - "Prioritize hypotheses based on likelihood"
    - "Plan diagnostic tests to validate theories"
    - "Consider impact of potential solutions"
  
  step_5_test_resolve:
    - "Implement diagnostic tests safely"
    - "Apply solutions in order of risk/complexity"
    - "Validate that solutions resolve the problem"
    - "Document the resolution and lessons learned"
```

### Diagnostic Tools and Commands
```bash
#!/bin/bash
# Essential diagnostic tools for PowerEdge CI infrastructure

# System information gathering
diagnostic_commands() {
    echo "=== System Diagnostic Information ==="
    
    # Basic system information
    echo "System Information:"
    uname -a
    uptime
    who
    
    # Hardware information
    echo "Hardware Information:"
    lscpu | head -20
    free -h
    lsblk
    lspci | grep -E "(Network|Storage)"
    
    # Process information
    echo "Process Information:"
    ps aux --sort=-%cpu | head -10
    ps aux --sort=-%mem | head -10
    
    # Network information
    echo "Network Information:"
    ip addr show
    ip route show
    netstat -tuln | head -20
    
    # Storage information
    echo "Storage Information:"
    df -h
    mount | grep -E "(ext4|xfs|nfs)"
    iostat -x 1 3
    
    # Log files
    echo "Recent System Logs:"
    journalctl -n 50 --no-pager
    
    # Dell-specific information
    echo "Dell Hardware Information:"
    if command -v racadm >/dev/null 2>&1; then
        racadm getsysinfo
        racadm gethealthstatus
    fi
    
    if command -v omreport >/dev/null 2>&1; then
        omreport system summary
        omreport storage controller
    fi
}

# Performance monitoring
performance_check() {
    echo "=== Performance Analysis ==="
    
    # CPU utilization
    echo "CPU Utilization:"
    top -bn1 | grep "Cpu(s)"
    
    # Memory utilization
    echo "Memory Utilization:"
    free -h
    
    # Disk I/O
    echo "Disk I/O Statistics:"
    iostat -x 1 3
    
    # Network I/O
    echo "Network Statistics:"
    sar -n DEV 1 3 2>/dev/null || echo "sar not available"
    
    # Load average
    echo "System Load:"
    uptime
    
    # Process tree
    echo "Process Tree:"
    pstree -p | head -20
}

# Network connectivity tests
network_diagnostics() {
    local target_hosts=("8.8.8.8" "jenkins.company.com" "gitlab.company.com")
    
    echo "=== Network Diagnostics ==="
    
    for host in "${target_hosts[@]}"; do
        echo "Testing connectivity to $host:"
        ping -c 3 "$host"
        echo ""
    done
    
    # DNS resolution test
    echo "DNS Resolution Test:"
    nslookup jenkins.company.com
    nslookup gitlab.company.com
    
    # Port connectivity test
    echo "Port Connectivity Test:"
    nc -zv jenkins.company.com 8080
    nc -zv gitlab.company.com 80
    nc -zv gitlab.company.com 443
}
```

## Hardware Troubleshooting

### 1. PowerEdge Server Issues

#### Server Won't Power On
```yaml
power_on_issues:
  symptoms:
    - "Server does not respond to power button"
    - "No LED activity on front panel"
    - "No fan noise or activity"
    - "iDRAC not accessible"
  
  diagnostic_steps:
    step_1: "Check power connections and PDU status"
    step_2: "Verify power supply LED indicators"
    step_3: "Check iDRAC logs for power events"
    step_4: "Test with single power supply if dual PSU"
    step_5: "Reseat memory and expansion cards"
  
  common_causes:
    - "Failed power supply unit"
    - "Faulty power distribution unit"
    - "Overheating protection triggered"
    - "Memory or hardware component failure"
    - "System board failure"
  
  resolution_steps:
    immediate:
      - "Check and replace power cables"
      - "Reset power supplies (AC power cycle)"
      - "Clear NVRAM/CMOS if accessible"
      - "Remove non-essential hardware"
    
    advanced:
      - "Replace suspected power supply"
      - "Test with minimal hardware configuration"
      - "Contact Dell support for system board issues"
      - "Review environmental conditions"
```

#### Server Performance Issues
```bash
#!/bin/bash
# Server performance troubleshooting script

server_performance_check() {
    local server_ip=$1
    echo "=== Server Performance Diagnostics ($server_ip) ==="
    
    if [[ -z "$server_ip" ]]; then
        # Local server diagnostics
        echo "Running local performance diagnostics..."
        
        # CPU performance
        echo "1. CPU Performance Analysis:"
        echo "CPU Usage:"
        top -bn1 | head -20
        
        echo "CPU Information:"
        lscpu
        
        echo "Load Average Trend:"
        uptime
        
        # Memory performance
        echo "2. Memory Performance Analysis:"
        echo "Memory Usage:"
        free -h
        
        echo "Memory Details:"
        cat /proc/meminfo | head -20
        
        echo "Swap Usage:"
        swapon --show
        
        # Storage performance
        echo "3. Storage Performance Analysis:"
        echo "Disk Usage:"
        df -h
        
        echo "I/O Statistics:"
        iostat -x 1 3
        
        echo "Disk Health (if smartctl available):"
        if command -v smartctl >/dev/null 2>&1; then
            for device in /dev/sd[a-z]; do
                if [[ -b "$device" ]]; then
                    echo "Device: $device"
                    smartctl -H "$device"
                fi
            done
        fi
        
        # Network performance
        echo "4. Network Performance Analysis:"
        echo "Network Interfaces:"
        ip link show
        
        echo "Network Statistics:"
        cat /proc/net/dev
        
        # Process analysis
        echo "5. Process Analysis:"
        echo "Top CPU Consumers:"
        ps aux --sort=-%cpu | head -10
        
        echo "Top Memory Consumers:"
        ps aux --sort=-%mem | head -10
        
    else
        # Remote server diagnostics via SSH
        echo "Running remote performance diagnostics on $server_ip..."
        
        ssh -o ConnectTimeout=10 "root@$server_ip" << 'EOSSH'
            echo "=== Remote Server Performance Check ==="
            
            echo "System Load and Uptime:"
            uptime
            
            echo "CPU Usage:"
            top -bn1 | head -5
            
            echo "Memory Usage:"
            free -h
            
            echo "Disk Usage:"
            df -h | head -10
            
            echo "Process Count:"
            ps aux | wc -l
            
            echo "Network Connections:"
            netstat -an | wc -l
EOSSH
    fi
}

# Dell-specific hardware diagnostics
dell_hardware_check() {
    echo "=== Dell Hardware Diagnostics ==="
    
    # iDRAC connectivity test
    echo "1. iDRAC Connectivity Test:"
    local idrac_ips=("10.1.100.101" "10.1.100.102" "10.1.100.103")
    
    for ip in "${idrac_ips[@]}"; do
        echo "Testing iDRAC at $ip:"
        if ping -c 2 "$ip" >/dev/null 2>&1; then
            echo "  ✓ iDRAC $ip accessible"
            
            # Test iDRAC web interface
            if curl -k -s --connect-timeout 5 "https://$ip" >/dev/null 2>&1; then
                echo "  ✓ iDRAC web interface responding"
            else
                echo "  ✗ iDRAC web interface not responding"
            fi
        else
            echo "  ✗ iDRAC $ip not accessible"
        fi
    done
    
    # OpenManage Enterprise connectivity
    echo "2. OpenManage Enterprise Check:"
    if ping -c 2 "10.1.100.20" >/dev/null 2>&1; then
        echo "  ✓ OME server accessible"
        
        if curl -k -s --connect-timeout 5 "https://10.1.100.20" >/dev/null 2>&1; then
            echo "  ✓ OME web interface responding"
        else
            echo "  ✗ OME web interface not responding"
        fi
    else
        echo "  ✗ OME server not accessible"
    fi
    
    # Dell hardware status (if omreport available)
    echo "3. Dell Hardware Status:"
    if command -v omreport >/dev/null 2>&1; then
        echo "Overall System Health:"
        omreport system summary
        
        echo "Storage Controller Status:"
        omreport storage controller
        
        echo "Memory Status:"
        omreport chassis memory
        
        echo "Temperature Status:"
        omreport chassis temps
        
        echo "Fan Status:"
        omreport chassis fans
        
        echo "Power Supply Status:"
        omreport chassis pwrsupplies
    else
        echo "OpenManage tools not installed locally"
        echo "Check iDRAC web interface for hardware status"
    fi
}

# Usage examples
server_performance_check
dell_hardware_check
```

#### Memory Issues
```yaml
memory_troubleshooting:
  symptoms:
    - "System crashes or freezes under load"
    - "Applications terminated by OOM killer"
    - "Slow system performance"
    - "Memory-related error messages"
  
  diagnostic_commands:
    basic_checks:
      - "free -h"
      - "cat /proc/meminfo"
      - "vmstat 1 5"
      - "dmesg | grep -i memory"
    
    advanced_checks:
      - "omreport chassis memory"
      - "dmidecode --type memory"
      - "memtest86+ (requires reboot)"
      - "racadm getsysinfo | grep -i memory"
  
  common_issues:
    insufficient_memory:
      cause: "Not enough RAM for workload"
      solution: "Add memory or optimize applications"
      
    memory_leaks:
      cause: "Applications not releasing memory"
      solution: "Restart applications, fix memory leaks"
      
    faulty_memory:
      cause: "Physical memory module failure"
      solution: "Replace faulty memory modules"
      
    memory_configuration:
      cause: "Incorrect memory configuration"
      solution: "Follow Dell memory configuration guidelines"
```

### 2. Storage System Issues

#### Dell Unity Storage Problems
```bash
#!/bin/bash
# Dell Unity storage troubleshooting

unity_diagnostics() {
    local unity_ip="10.1.100.30"
    local unity_user="admin"
    local unity_pass="$UNITY_PASSWORD"
    
    echo "=== Dell Unity Storage Diagnostics ==="
    
    # Connectivity test
    echo "1. Unity Connectivity Test:"
    if ping -c 3 "$unity_ip" >/dev/null 2>&1; then
        echo "  ✓ Unity storage accessible at $unity_ip"
    else
        echo "  ✗ Unity storage not accessible at $unity_ip"
        echo "  Check network connectivity and Unity power status"
        return 1
    fi
    
    # Unity system health check
    echo "2. Unity System Health:"
    if command -v uemcli >/dev/null 2>&1; then
        # System general information
        echo "System Information:"
        uemcli -d "$unity_ip" -u "$unity_user" -p "$unity_pass" \
            /sys/general show
        
        # System alerts
        echo "System Alerts:"
        uemcli -d "$unity_ip" -u "$unity_user" -p "$unity_pass" \
            /sys/alert show
        
        # Storage pool health
        echo "Storage Pool Health:"
        uemcli -d "$unity_ip" -u "$unity_user" -p "$unity_pass" \
            /stor/config/pool show -detail
        
        # File system health
        echo "File System Health:"
        uemcli -d "$unity_ip" -u "$unity_user" -p "$unity_pass" \
            /stor/prov/fs show -detail
        
        # Performance statistics
        echo "Performance Statistics:"
        uemcli -d "$unity_ip" -u "$unity_user" -p "$unity_pass" \
            /stats/config/capmetric show -interval hour -count 24
        
    else
        echo "Unity CLI not available - checking via web interface"
        if curl -k -s --connect-timeout 10 "https://$unity_ip" >/dev/null 2>&1; then
            echo "  ✓ Unity web interface accessible"
            echo "  Log into web interface for detailed diagnostics"
        else
            echo "  ✗ Unity web interface not accessible"
        fi
    fi
    
    # NFS mount test
    echo "3. NFS Mount Test:"
    test_nfs_connectivity
}

test_nfs_connectivity() {
    local nfs_server="10.1.100.30"
    local test_mount="/mnt/nfs-test"
    
    echo "Testing NFS connectivity to $nfs_server:"
    
    # Check if NFS services are running
    echo "NFS Service Check:"
    rpcinfo -p "$nfs_server" | grep nfs
    
    # Test NFS exports
    echo "Available NFS Exports:"
    showmount -e "$nfs_server"
    
    # Test mount
    echo "Testing NFS Mount:"
    mkdir -p "$test_mount"
    
    if mount -t nfs "$nfs_server:/ci-shared" "$test_mount" >/dev/null 2>&1; then
        echo "  ✓ NFS mount successful"
        
        # Test read/write
        if echo "test" > "$test_mount/test-file" 2>/dev/null; then
            echo "  ✓ NFS write successful"
            rm -f "$test_mount/test-file"
        else
            echo "  ✗ NFS write failed"
        fi
        
        umount "$test_mount"
    else
        echo "  ✗ NFS mount failed"
        echo "  Check NFS services and export permissions"
    fi
    
    rmdir "$test_mount" 2>/dev/null
}

# Storage performance testing
storage_performance_test() {
    echo "=== Storage Performance Test ==="
    
    # Test directories
    local test_dirs=("/mnt/ci-shared" "/mnt/ci-cache" "/var/lib/jenkins")
    
    for test_dir in "${test_dirs[@]}"; do
        if [[ -d "$test_dir" && -w "$test_dir" ]]; then
            echo "Testing storage performance in $test_dir:"
            
            # Sequential write test
            echo "  Sequential Write Test:"
            dd if=/dev/zero of="$test_dir/test-write" bs=1M count=100 oflag=direct 2>&1 | \
                grep -E 'copied|MB/s'
            
            # Sequential read test
            echo "  Sequential Read Test:"
            dd if="$test_dir/test-write" of=/dev/null bs=1M iflag=direct 2>&1 | \
                grep -E 'copied|MB/s'
            
            # Random I/O test (if fio is available)
            if command -v fio >/dev/null 2>&1; then
                echo "  Random I/O Test (4KB):"
                fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread \
                    --bs=4k --direct=1 --size=100M --numjobs=1 --runtime=30 \
                    --group_reporting --filename="$test_dir/fio-test"
                rm -f "$test_dir/fio-test"
            fi
            
            # Cleanup
            rm -f "$test_dir/test-write"
        else
            echo "$test_dir not accessible for testing"
        fi
    done
}

unity_diagnostics
storage_performance_test
```

#### iSCSI Connectivity Issues
```yaml
iscsi_troubleshooting:
  symptoms:
    - "iSCSI targets not discoverable"
    - "Login failures to iSCSI targets"
    - "Intermittent iSCSI disconnections"
    - "Poor iSCSI performance"
  
  diagnostic_steps:
    connectivity:
      - "ping iscsi-target-ip"
      - "telnet iscsi-target-ip 3260"
      - "iscsiadm --mode discovery --type sendtargets --portal target-ip"
    
    configuration:
      - "cat /etc/iscsi/iscsid.conf"
      - "iscsiadm --mode node --print=1"
      - "systemctl status iscsid iscsi"
    
    performance:
      - "iostat -x 1 5"
      - "sar -n DEV 1 5"
      - "netstat -i"
  
  resolution_strategies:
    network_issues:
      - "Check network connectivity to storage"
      - "Verify VLAN configuration"
      - "Test network performance with iperf3"
    
    authentication_issues:
      - "Verify CHAP credentials"
      - "Check target access permissions"
      - "Validate initiator IQN configuration"
    
    performance_issues:
      - "Tune iSCSI parameters (queue depth, timeout)"
      - "Check network MTU settings"
      - "Verify multipath configuration"
```

### 3. Network Infrastructure Issues

#### Switch and Network Problems
```bash
#!/bin/bash
# Network infrastructure troubleshooting

network_infrastructure_check() {
    echo "=== Network Infrastructure Diagnostics ==="
    
    # Basic connectivity tests
    echo "1. Basic Connectivity Tests:"
    
    # Test gateway connectivity
    local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
    if [[ -n "$gateway" ]]; then
        echo "Testing gateway connectivity ($gateway):"
        ping -c 3 "$gateway"
    fi
    
    # Test DNS servers
    echo "Testing DNS servers:"
    local dns_servers=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
    for dns in $dns_servers; do
        echo "  Testing DNS server $dns:"
        ping -c 2 "$dns"
        
        echo "  Testing DNS resolution:"
        nslookup google.com "$dns"
    done
    
    # VLAN connectivity tests
    echo "2. VLAN Connectivity Tests:"
    local vlans=(
        "10.1.100.1:Management"
        "10.1.200.1:CI-Control"
        "10.1.300.1:CI-Data"
        "10.1.400.1:Storage"
    )
    
    for vlan_info in "${vlans[@]}"; do
        local vlan_ip=$(echo "$vlan_info" | cut -d':' -f1)
        local vlan_name=$(echo "$vlan_info" | cut -d':' -f2)
        
        echo "Testing $vlan_name VLAN ($vlan_ip):"
        ping -c 2 "$vlan_ip"
    done
    
    # Switch connectivity (if SNMP is available)
    echo "3. Switch Status Check:"
    local switches=("10.1.100.10" "10.1.100.11")
    
    for switch_ip in "${switches[@]}"; do
        echo "Checking switch at $switch_ip:"
        
        # Basic connectivity
        if ping -c 2 "$switch_ip" >/dev/null 2>&1; then
            echo "  ✓ Switch $switch_ip accessible"
            
            # SNMP check (if snmpwalk is available)
            if command -v snmpwalk >/dev/null 2>&1; then
                echo "  SNMP System Information:"
                snmpwalk -v2c -c public "$switch_ip" 1.3.6.1.2.1.1.1 2>/dev/null || \
                    echo "    SNMP not accessible or community string incorrect"
            fi
        else
            echo "  ✗ Switch $switch_ip not accessible"
        fi
    done
    
    # Bandwidth and performance tests
    echo "4. Network Performance Tests:"
    
    # Interface statistics
    echo "Network Interface Statistics:"
    cat /proc/net/dev
    
    # Network utilization
    echo "Network Utilization (if sar available):"
    sar -n DEV 1 3 2>/dev/null || echo "sar not available"
    
    # Connection counts
    echo "Active Network Connections:"
    echo "Total connections: $(netstat -an | wc -l)"
    echo "Established TCP connections: $(netstat -an | grep ESTABLISHED | wc -l)"
    echo "Listening services: $(netstat -tln | wc -l)"
}

# Specific network service tests
network_service_tests() {
    echo "=== Network Service Tests ==="
    
    # Web services connectivity
    echo "1. Web Services Connectivity:"
    local web_services=(
        "jenkins.company.com:8080"
        "gitlab.company.com:80"
        "gitlab.company.com:443"
        "monitoring.company.com:3000"
    )
    
    for service in "${web_services[@]}"; do
        local host=$(echo "$service" | cut -d':' -f1)
        local port=$(echo "$service" | cut -d':' -f2)
        
        echo "Testing $service:"
        
        # DNS resolution
        if nslookup "$host" >/dev/null 2>&1; then
            echo "  ✓ DNS resolution successful"
        else
            echo "  ✗ DNS resolution failed"
            continue
        fi
        
        # Port connectivity
        if nc -z -w5 "$host" "$port" 2>/dev/null; then
            echo "  ✓ Port $port accessible"
            
            # HTTP response test
            if [[ "$port" == "80" || "$port" == "443" || "$port" == "8080" || "$port" == "3000" ]]; then
                local protocol="http"
                [[ "$port" == "443" ]] && protocol="https"
                
                local response_code=$(curl -s -o /dev/null -w "%{http_code}" \
                    --connect-timeout 10 "$protocol://$host:$port/" 2>/dev/null)
                
                if [[ -n "$response_code" ]]; then
                    echo "  HTTP Response Code: $response_code"
                else
                    echo "  HTTP request failed or timed out"
                fi
            fi
        else
            echo "  ✗ Port $port not accessible"
        fi
    done
    
    # Database connectivity tests
    echo "2. Database Connectivity Tests:"
    
    # PostgreSQL (GitLab)
    if nc -z -w5 gitlab-db.company.com 5432 2>/dev/null; then
        echo "  ✓ PostgreSQL port accessible"
    else
        echo "  ✗ PostgreSQL port not accessible"
    fi
    
    # Redis (GitLab caching)
    if nc -z -w5 gitlab-redis.company.com 6379 2>/dev/null; then
        echo "  ✓ Redis port accessible"
    else
        echo "  ✗ Redis port not accessible"
    fi
}

# Network security and firewall tests
network_security_check() {
    echo "=== Network Security Check ==="
    
    # Firewall status
    echo "1. Firewall Status:"
    if systemctl is-active firewalld >/dev/null 2>&1; then
        echo "  ✓ FirewallD is active"
        echo "  Active zones:"
        firewall-cmd --get-active-zones
        
        echo "  Public zone services:"
        firewall-cmd --zone=public --list-services
        
        echo "  Public zone ports:"
        firewall-cmd --zone=public --list-ports
    else
        echo "  FirewallD not active - checking iptables"
        if command -v iptables >/dev/null 2>&1; then
            echo "  iptables rules count: $(iptables -L | wc -l)"
        fi
    fi
    
    # SSL certificate checks
    echo "2. SSL Certificate Checks:"
    local ssl_services=(
        "gitlab.company.com:443"
        "monitoring.company.com:443"
        "registry.company.com:443"
    )
    
    for service in "${ssl_services[@]}"; do
        local host=$(echo "$service" | cut -d':' -f1)
        local port=$(echo "$service" | cut -d':' -f2)
        
        echo "Checking SSL certificate for $service:"
        
        if echo | openssl s_client -servername "$host" -connect "$service" 2>/dev/null | \
           openssl x509 -noout -dates 2>/dev/null; then
            echo "  ✓ SSL certificate information retrieved"
        else
            echo "  ✗ SSL certificate check failed"
        fi
    done
}

# Execute network diagnostics
network_infrastructure_check
network_service_tests
network_security_check
```

## Application Troubleshooting

### 1. Jenkins Issues

#### Jenkins Controller Problems
```yaml
jenkins_controller_issues:
  service_not_starting:
    symptoms:
      - "Jenkins service fails to start"
      - "Jenkins web interface not accessible"
      - "Jenkins process not running"
    
    diagnostic_steps:
      - "systemctl status jenkins"
      - "journalctl -u jenkins -f"
      - "cat /var/log/jenkins/jenkins.log"
      - "check disk space: df -h /var/lib/jenkins"
      - "check Java version: java -version"
    
    common_causes:
      insufficient_disk_space: "Jenkins home directory full"
      java_issues: "Incorrect Java version or JAVA_HOME"
      port_conflicts: "Port 8080 already in use"
      permission_issues: "Incorrect file permissions"
      memory_issues: "Insufficient memory allocation"
    
    resolution_steps:
      - "Free up disk space in /var/lib/jenkins"
      - "Verify Java 11 or 17 installation"
      - "Check and change Jenkins port if needed"
      - "Fix file ownership: chown -R jenkins:jenkins /var/lib/jenkins"
      - "Increase Java heap size in /etc/sysconfig/jenkins"
  
  performance_issues:
    symptoms:
      - "Slow build execution"
      - "Jenkins web interface sluggish"
      - "Build queue not processing"
      - "High memory usage"
    
    diagnostic_commands:
      - "curl -s http://jenkins:8080/computer/api/json | jq '.computer[] | {name: .displayName, offline: .offline}'"
      - "curl -s http://jenkins:8080/queue/api/json | jq '.items | length'"
      - "ps aux | grep java | grep jenkins"
      - "jstat -gc $(pgrep -f jenkins) 5s"
    
    optimization_steps:
      - "Increase Jenkins heap size (-Xmx parameter)"
      - "Clean up old build artifacts and logs"
      - "Optimize Jenkins plugin usage"
      - "Configure build agent auto-scaling"
      - "Implement build result caching"
```

#### Jenkins Agent Problems
```bash
#!/bin/bash
# Jenkins agent troubleshooting

jenkins_agent_diagnostics() {
    echo "=== Jenkins Agent Diagnostics ==="
    
    # Check Jenkins controller connectivity
    echo "1. Jenkins Controller Connectivity:"
    local jenkins_controller="jenkins.company.com:8080"
    
    if curl -s --connect-timeout 10 "http://$jenkins_controller" >/dev/null; then
        echo "  ✓ Jenkins controller accessible"
        
        # Check agent status via API
        echo "  Agent Status from Controller:"
        curl -s "http://admin:$JENKINS_API_TOKEN@$jenkins_controller/computer/api/json" | \
            jq -r '.computer[] | "\(.displayName): \(if .offline then "OFFLINE" else "ONLINE" end)"'
    else
        echo "  ✗ Jenkins controller not accessible"
        return 1
    fi
    
    # Check local agent processes
    echo "2. Local Agent Process Check:"
    if pgrep -f "jenkins.*agent" >/dev/null; then
        echo "  ✓ Jenkins agent process running"
        echo "  Agent processes:"
        ps aux | grep -E "jenkins.*agent" | grep -v grep
    else
        echo "  ✗ No Jenkins agent process found"
    fi
    
    # Check Docker daemon (for Docker agents)
    echo "3. Docker Daemon Status:"
    if systemctl is-active docker >/dev/null 2>&1; then
        echo "  ✓ Docker daemon active"
        
        echo "  Docker system information:"
        docker system df
        
        echo "  Running containers:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        echo "  Docker agent containers:"
        docker ps --filter "label=jenkins" --format "table {{.Names}}\t{{.Status}}"
    else
        echo "  ✗ Docker daemon not active"
        echo "  Docker service status:"
        systemctl status docker --no-pager
    fi
    
    # Check system resources
    echo "4. System Resource Check:"
    echo "  CPU Usage:"
    top -bn1 | grep "Cpu(s)" | head -1
    
    echo "  Memory Usage:"
    free -h
    
    echo "  Disk Usage:"
    df -h | grep -E "(jenkins|docker|var)"
    
    echo "  System Load:"
    uptime
    
    # Check network connectivity to required services
    echo "5. Network Connectivity Check:"
    local services=("gitlab.company.com:443" "registry.company.com:443" "nexus.company.com:8081")
    
    for service in "${services[@]}"; do
        local host=$(echo "$service" | cut -d':' -f1)
        local port=$(echo "$service" | cut -d':' -f2)
        
        if nc -z -w5 "$host" "$port" 2>/dev/null; then
            echo "  ✓ $service accessible"
        else
            echo "  ✗ $service not accessible"
        fi
    done
}

# Agent performance optimization
jenkins_agent_optimization() {
    echo "=== Jenkins Agent Optimization ==="
    
    # Clean up Docker resources
    echo "1. Docker Cleanup:"
    if command -v docker >/dev/null 2>&1; then
        echo "  Cleaning up unused Docker resources:"
        
        # Remove stopped containers
        echo "    Removing stopped containers:"
        docker container prune -f
        
        # Remove unused images
        echo "    Removing unused images:"
        docker image prune -a -f
        
        # Remove unused volumes
        echo "    Removing unused volumes:"
        docker volume prune -f
        
        # Remove unused networks
        echo "    Removing unused networks:"
        docker network prune -f
        
        echo "  Post-cleanup disk usage:"
        docker system df
    fi
    
    # Clean up Jenkins workspace
    echo "2. Jenkins Workspace Cleanup:"
    local jenkins_home="/home/jenkins"
    
    if [[ -d "$jenkins_home" ]]; then
        echo "  Cleaning up old workspaces:"
        find "$jenkins_home/workspace" -type d -mtime +7 -name "*" | head -10
        
        echo "  Current workspace disk usage:"
        du -sh "$jenkins_home/workspace"
        
        # Clean up old workspaces (older than 7 days)
        find "$jenkins_home/workspace" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true
    fi
    
    # System performance tuning
    echo "3. System Performance Tuning:"
    
    # Check and adjust swappiness
    local current_swappiness=$(cat /proc/sys/vm/swappiness)
    echo "  Current swappiness: $current_swappiness"
    if [[ "$current_swappiness" -gt 10 ]]; then
        echo "  Consider reducing swappiness for better performance"
        echo "  echo 'vm.swappiness=10' >> /etc/sysctl.conf"
    fi
    
    # Check file descriptor limits
    echo "  File descriptor limits:"
    ulimit -n
    
    # Check process limits
    echo "  Process limits:"
    ulimit -u
}

jenkins_agent_diagnostics
jenkins_agent_optimization
```

### 2. GitLab Issues

#### GitLab Service Problems
```yaml
gitlab_troubleshooting:
  service_startup_issues:
    symptoms:
      - "GitLab services not starting"
      - "502 Bad Gateway errors"
      - "Database connection errors"
      - "Redis connection failures"
    
    diagnostic_commands:
      - "gitlab-ctl status"
      - "gitlab-ctl tail"
      - "gitlab-rake gitlab:check"
      - "gitlab-rake gitlab:doctor:secrets"
    
    common_resolutions:
      - "gitlab-ctl reconfigure"
      - "gitlab-ctl restart"
      - "Check disk space and permissions"
      - "Verify database and Redis connectivity"
  
  performance_issues:
    symptoms:
      - "Slow GitLab web interface"
      - "Git operations timing out"
      - "CI/CD pipelines not starting"
      - "High server load"
    
    optimization_steps:
      - "Increase unicorn worker processes"
      - "Optimize PostgreSQL configuration"
      - "Configure Redis for better performance"
      - "Enable GitLab caching features"
      - "Implement GitLab monitoring"
```

#### GitLab Runner Issues
```bash
#!/bin/bash
# GitLab Runner troubleshooting

gitlab_runner_diagnostics() {
    echo "=== GitLab Runner Diagnostics ==="
    
    # Check GitLab Runner service
    echo "1. GitLab Runner Service Status:"
    if systemctl is-active gitlab-runner >/dev/null 2>&1; then
        echo "  ✓ GitLab Runner service active"
        
        echo "  Runner status:"
        gitlab-runner status
        
        echo "  Registered runners:"
        gitlab-runner list
    else
        echo "  ✗ GitLab Runner service not active"
        echo "  Service status:"
        systemctl status gitlab-runner --no-pager
    fi
    
    # Check runner configuration
    echo "2. Runner Configuration Check:"
    local config_file="/etc/gitlab-runner/config.toml"
    
    if [[ -f "$config_file" ]]; then
        echo "  Configuration file exists: $config_file"
        
        echo "  Concurrent jobs setting:"
        grep "concurrent" "$config_file" || echo "  No concurrent setting found"
        
        echo "  Configured runners:"
        grep -A 5 "\[\[runners\]\]" "$config_file" | head -20
    else
        echo "  ✗ Configuration file not found: $config_file"
    fi
    
    # Check Docker executor (if Docker runner)
    echo "3. Docker Executor Check:"
    if grep -q "executor = \"docker\"" "$config_file" 2>/dev/null; then
        echo "  Docker executor configured"
        
        if systemctl is-active docker >/dev/null 2>&1; then
            echo "  ✓ Docker daemon active"
            
            echo "  Docker system info:"
            docker system df
            
            echo "  GitLab Runner containers:"
            docker ps --filter "name=runner-" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
        else
            echo "  ✗ Docker daemon not active"
        fi
    fi
    
    # Check Kubernetes executor (if K8s runner)
    echo "4. Kubernetes Executor Check:"
    if grep -q "executor = \"kubernetes\"" "$config_file" 2>/dev/null; then
        echo "  Kubernetes executor configured"
        
        if command -v kubectl >/dev/null 2>&1; then
            echo "  Kubernetes cluster connectivity:"
            kubectl cluster-info --request-timeout=10s
            
            echo "  GitLab Runner pods:"
            kubectl get pods -l app=gitlab-runner -o wide
            
            echo "  Kubernetes node status:"
            kubectl get nodes
        else
            echo "  kubectl not available"
        fi
    fi
    
    # Check connectivity to GitLab instance
    echo "5. GitLab Instance Connectivity:"
    local gitlab_url=$(grep "url =" "$config_file" | head -1 | sed 's/.*url = "\([^"]*\)".*/\1/')
    
    if [[ -n "$gitlab_url" ]]; then
        echo "  GitLab URL: $gitlab_url"
        
        if curl -s --connect-timeout 10 "$gitlab_url" >/dev/null; then
            echo "  ✓ GitLab instance accessible"
        else
            echo "  ✗ GitLab instance not accessible"
        fi
    else
        echo "  GitLab URL not found in configuration"
    fi
    
    # Check recent jobs and logs
    echo "6. Recent Jobs and Logs:"
    echo "  Checking GitLab Runner logs:"
    journalctl -u gitlab-runner -n 20 --no-pager
}

# GitLab Runner performance optimization
gitlab_runner_optimization() {
    echo "=== GitLab Runner Optimization ==="
    
    # Optimize concurrent jobs
    echo "1. Concurrent Jobs Optimization:"
    local config_file="/etc/gitlab-runner/config.toml"
    local current_concurrent=$(grep "concurrent" "$config_file" | sed 's/concurrent = //')
    local cpu_cores=$(nproc)
    local recommended_concurrent=$((cpu_cores * 2))
    
    echo "  Current concurrent jobs: $current_concurrent"
    echo "  CPU cores: $cpu_cores"
    echo "  Recommended concurrent jobs: $recommended_concurrent"
    
    if [[ "$current_concurrent" -lt "$recommended_concurrent" ]]; then
        echo "  Consider increasing concurrent jobs for better utilization"
    fi
    
    # Docker optimization (if using Docker executor)
    echo "2. Docker Optimization:"
    if grep -q "executor = \"docker\"" "$config_file" 2>/dev/null; then
        echo "  Checking Docker configuration:"
        
        # Check Docker storage driver
        echo "  Docker storage driver: $(docker info --format '{{.Driver}}')"
        
        # Check Docker daemon configuration
        if [[ -f /etc/docker/daemon.json ]]; then
            echo "  Docker daemon configuration:"
            cat /etc/docker/daemon.json
        fi
        
        # Optimize Docker resources
        echo "  Docker system prune (removing unused resources):"
        docker system prune -f --volumes
    fi
    
    # System resource optimization
    echo "3. System Resource Optimization:"
    
    # Check memory usage
    local mem_usage=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    echo "  Memory usage: ${mem_usage}%"
    
    # Check disk usage
    echo "  Disk usage for GitLab Runner:"
    du -sh /var/lib/gitlab-runner 2>/dev/null || echo "  GitLab Runner directory not found"
    
    # Check system load
    echo "  System load average:"
    uptime
}

gitlab_runner_diagnostics
gitlab_runner_optimization
```

### 3. Kubernetes Issues

#### Cluster-Level Problems
```bash
#!/bin/bash
# Kubernetes cluster troubleshooting

k8s_cluster_diagnostics() {
    echo "=== Kubernetes Cluster Diagnostics ==="
    
    # Check cluster connectivity
    echo "1. Cluster Connectivity:"
    if kubectl cluster-info --request-timeout=10s >/dev/null 2>&1; then
        echo "  ✓ Kubernetes cluster accessible"
        kubectl cluster-info
    else
        echo "  ✗ Kubernetes cluster not accessible"
        echo "  Check kubeconfig and cluster status"
        return 1
    fi
    
    # Check node status
    echo "2. Node Status:"
    kubectl get nodes -o wide
    
    echo "  Node conditions:"
    kubectl describe nodes | grep -A 5 "Conditions:" | head -20
    
    # Check system pods
    echo "3. System Pods Status:"
    kubectl get pods -n kube-system
    
    echo "  Failed or pending pods:"
    kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
    
    # Check cluster resources
    echo "4. Cluster Resource Usage:"
    if command -v kubectl-top >/dev/null 2>&1 || kubectl top nodes >/dev/null 2>&1; then
        echo "  Node resource usage:"
        kubectl top nodes
        
        echo "  Pod resource usage (top consumers):"
        kubectl top pods --all-namespaces --sort-by=cpu | head -10
    else
        echo "  Metrics server not available or not configured"
    fi
    
    # Check cluster events
    echo "5. Recent Cluster Events:"
    kubectl get events --all-namespaces --sort-by='.metadata.creationTimestamp' | tail -20
    
    # Check persistent volumes
    echo "6. Storage Status:"
    kubectl get pv,pvc --all-namespaces
    
    echo "  Storage classes:"
    kubectl get storageclass
    
    # Check network status
    echo "7. Network Status:"
    kubectl get svc --all-namespaces | head -10
    
    echo "  Network policies:"
    kubectl get networkpolicies --all-namespaces
    
    # Check RBAC
    echo "8. RBAC Status:"
    kubectl get clusterroles | head -10
    kubectl get clusterrolebindings | head -10
}

# Pod-specific troubleshooting
k8s_pod_diagnostics() {
    local pod_name="$1"
    local namespace="${2:-default}"
    
    if [[ -z "$pod_name" ]]; then
        echo "Usage: k8s_pod_diagnostics <pod_name> [namespace]"
        return 1
    fi
    
    echo "=== Pod Diagnostics: $pod_name (namespace: $namespace) ==="
    
    # Pod status
    echo "1. Pod Status:"
    kubectl get pod "$pod_name" -n "$namespace" -o wide
    
    # Pod description
    echo "2. Pod Description:"
    kubectl describe pod "$pod_name" -n "$namespace"
    
    # Pod logs
    echo "3. Pod Logs (last 50 lines):"
    kubectl logs "$pod_name" -n "$namespace" --tail=50
    
    # Previous container logs (if pod restarted)
    echo "4. Previous Container Logs (if available):"
    kubectl logs "$pod_name" -n "$namespace" --previous --tail=20 2>/dev/null || \
        echo "  No previous container logs available"
    
    # Pod resource usage
    echo "5. Pod Resource Usage:"
    kubectl top pod "$pod_name" -n "$namespace" 2>/dev/null || \
        echo "  Resource usage metrics not available"
    
    # Pod network connectivity test
    echo "6. Pod Network Test:"
    kubectl exec "$pod_name" -n "$namespace" -- nslookup kubernetes.default.svc.cluster.local 2>/dev/null || \
        echo "  Cannot test network connectivity (exec not available)"
}

# Application-specific troubleshooting
k8s_application_diagnostics() {
    local app_label="$1"
    local namespace="${2:-default}"
    
    if [[ -z "$app_label" ]]; then
        echo "Usage: k8s_application_diagnostics <app_label> [namespace]"
        return 1
    fi
    
    echo "=== Application Diagnostics: $app_label (namespace: $namespace) ==="
    
    # Get all resources for the application
    echo "1. Application Resources:"
    kubectl get all -l "app=$app_label" -n "$namespace"
    
    # Check deployments
    echo "2. Deployment Status:"
    kubectl get deployments -l "app=$app_label" -n "$namespace" -o wide
    
    # Check replica sets
    echo "3. ReplicaSet Status:"
    kubectl get rs -l "app=$app_label" -n "$namespace" -o wide
    
    # Check services
    echo "4. Service Status:"
    kubectl get svc -l "app=$app_label" -n "$namespace" -o wide
    
    # Check ingress
    echo "5. Ingress Status:"
    kubectl get ingress -l "app=$app_label" -n "$namespace" -o wide 2>/dev/null || \
        echo "  No ingress resources found"
    
    # Check persistent volume claims
    echo "6. Persistent Volume Claims:"
    kubectl get pvc -l "app=$app_label" -n "$namespace" -o wide 2>/dev/null || \
        echo "  No PVC resources found"
    
    # Application-specific events
    echo "7. Application Events:"
    kubectl get events -n "$namespace" --field-selector involvedObject.name="$app_label" | tail -10
}

# Network troubleshooting
k8s_network_diagnostics() {
    echo "=== Kubernetes Network Diagnostics ==="
    
    # CNI plugin check
    echo "1. CNI Plugin Status:"
    kubectl get pods -n kube-system | grep -E "(calico|flannel|weave|cilium)"
    
    # CoreDNS status
    echo "2. CoreDNS Status:"
    kubectl get pods -n kube-system | grep coredns
    
    echo "  CoreDNS configuration:"
    kubectl get configmap coredns -n kube-system -o yaml | grep -A 20 "Corefile:"
    
    # Service mesh (if Istio is installed)
    echo "3. Service Mesh Status:"
    if kubectl get namespace istio-system >/dev/null 2>&1; then
        echo "  Istio components:"
        kubectl get pods -n istio-system
    else
        echo "  No service mesh detected"
    fi
    
    # Network policies
    echo "4. Network Policies:"
    kubectl get networkpolicies --all-namespaces
    
    # Load balancer services
    echo "5. Load Balancer Services:"
    kubectl get svc --all-namespaces | grep LoadBalancer
    
    # Ingress controllers
    echo "6. Ingress Controllers:"
    kubectl get pods --all-namespaces | grep -E "(ingress|nginx|traefik|haproxy)"
}

# Usage examples and help
k8s_troubleshooting_help() {
    echo "=== Kubernetes Troubleshooting Commands ==="
    echo ""
    echo "General cluster diagnostics:"
    echo "  k8s_cluster_diagnostics"
    echo ""
    echo "Pod-specific diagnostics:"
    echo "  k8s_pod_diagnostics <pod_name> [namespace]"
    echo ""
    echo "Application diagnostics:"
    echo "  k8s_application_diagnostics <app_label> [namespace]"
    echo ""
    echo "Network diagnostics:"
    echo "  k8s_network_diagnostics"
    echo ""
    echo "Common troubleshooting commands:"
    echo "  kubectl get events --sort-by=.metadata.creationTimestamp"
    echo "  kubectl top nodes"
    echo "  kubectl top pods --all-namespaces"
    echo "  kubectl describe node <node_name>"
    echo "  kubectl logs -f <pod_name> -n <namespace>"
}

# Execute main diagnostics
k8s_cluster_diagnostics
k8s_network_diagnostics
```

## Monitoring and Alerting Issues

### 1. Prometheus Issues

#### Prometheus Not Collecting Metrics
```yaml
prometheus_troubleshooting:
  metrics_collection_issues:
    symptoms:
      - "No data in Grafana dashboards"
      - "Missing metrics from specific targets"
      - "Prometheus targets showing as down"
      - "High cardinality warnings"
    
    diagnostic_steps:
      - "Check Prometheus targets: curl http://prometheus:9090/targets"
      - "Review Prometheus logs: kubectl logs prometheus-xxx -n monitoring"
      - "Verify network connectivity to target endpoints"
      - "Check authentication and SSL certificates"
      - "Review prometheus.yml configuration"
    
    common_resolutions:
      - "Fix network connectivity issues"
      - "Update target service discovery configuration"
      - "Resolve authentication/SSL certificate problems"
      - "Increase Prometheus storage retention"
      - "Optimize high cardinality metrics"
  
  performance_issues:
    symptoms:
      - "Slow query performance"
      - "High memory usage"
      - "Prometheus restarts frequently"
      - "Storage running out of space"
    
    optimization_steps:
      - "Increase memory allocation"
      - "Optimize PromQL queries"
      - "Reduce metrics retention period"
      - "Implement metric sampling and filtering"
      - "Scale Prometheus horizontally"
```

### 2. Grafana Dashboard Issues
```bash
#!/bin/bash
# Grafana troubleshooting

grafana_diagnostics() {
    echo "=== Grafana Diagnostics ==="
    
    # Check Grafana service
    echo "1. Grafana Service Status:"
    if curl -s --connect-timeout 10 "http://grafana.company.com:3000" >/dev/null; then
        echo "  ✓ Grafana web interface accessible"
    else
        echo "  ✗ Grafana web interface not accessible"
        
        # Check if running in Kubernetes
        if command -v kubectl >/dev/null 2>&1; then
            echo "  Checking Grafana pod status:"
            kubectl get pods -l app=grafana --all-namespaces
        fi
        
        # Check if running as systemd service
        if systemctl list-unit-files | grep -q grafana; then
            echo "  Checking Grafana systemd service:"
            systemctl status grafana-server --no-pager
        fi
    fi
    
    # Check Grafana data sources
    echo "2. Data Source Connectivity:"
    local grafana_api="http://admin:admin@grafana.company.com:3000/api"
    
    # Get data sources
    if curl -s "$grafana_api/datasources" >/dev/null 2>&1; then
        echo "  Grafana API accessible"
        
        echo "  Configured data sources:"
        curl -s "$grafana_api/datasources" | jq -r '.[] | "\(.name): \(.type) - \(.url)"'
        
        # Test data source connectivity
        echo "  Testing data source connectivity:"
        local datasource_ids=$(curl -s "$grafana_api/datasources" | jq -r '.[].id')
        
        for id in $datasource_ids; do
            local test_result=$(curl -s "$grafana_api/datasources/$id/proxy/api/v1/query?query=up" | \
                jq -r '.status // "error"')
            
            if [[ "$test_result" == "success" ]]; then
                echo "    ✓ Data source $id: Connected"
            else
                echo "    ✗ Data source $id: Connection failed"
            fi
        done
    else
        echo "  ✗ Grafana API not accessible"
    fi
    
    # Check Grafana logs
    echo "3. Recent Grafana Logs:"
    if command -v kubectl >/dev/null 2>&1; then
        local grafana_pod=$(kubectl get pods -l app=grafana -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
        if [[ -n "$grafana_pod" ]]; then
            echo "  Grafana pod logs (last 20 lines):"
            kubectl logs "$grafana_pod" --tail=20
        fi
    else
        # System logs for Grafana
        if systemctl list-unit-files | grep -q grafana; then
            echo "  Grafana service logs (last 20 lines):"
            journalctl -u grafana-server -n 20 --no-pager
        fi
    fi
    
    # Check dashboard health
    echo "4. Dashboard Health Check:"
    if curl -s "$grafana_api/search" >/dev/null 2>&1; then
        local dashboard_count=$(curl -s "$grafana_api/search" | jq length)
        echo "  Total dashboards: $dashboard_count"
        
        echo "  Recent dashboard access:"
        curl -s "$grafana_api/search" | jq -r '.[] | "\(.title): \(.type)"' | head -10
    else
        echo "  Cannot retrieve dashboard information"
    fi
}

grafana_diagnostics
```

### 3. ELK Stack Issues

#### Elasticsearch Cluster Problems
```bash
#!/bin/bash
# Elasticsearch troubleshooting

elasticsearch_diagnostics() {
    echo "=== Elasticsearch Diagnostics ==="
    
    # Check Elasticsearch cluster health
    echo "1. Cluster Health:"
    local es_url="http://elasticsearch.company.com:9200"
    
    if curl -s --connect-timeout 10 "$es_url" >/dev/null; then
        echo "  ✓ Elasticsearch accessible"
        
        # Cluster health
        echo "  Cluster health:"
        curl -s "$es_url/_cluster/health" | jq '.'
        
        # Node information
        echo "  Node information:"
        curl -s "$es_url/_cat/nodes?v"
        
        # Index information
        echo "  Index information:"
        curl -s "$es_url/_cat/indices?v" | head -10
        
        # Cluster stats
        echo "  Cluster statistics:"
        curl -s "$es_url/_cluster/stats" | jq '.indices.count, .nodes.count'
        
    else
        echo "  ✗ Elasticsearch not accessible at $es_url"
        
        # Check if running in Kubernetes
        if command -v kubectl >/dev/null 2>&1; then
            echo "  Checking Elasticsearch pods:"
            kubectl get pods -l app=elasticsearch --all-namespaces
        fi
    fi
    
    # Check for common issues
    echo "2. Common Issue Checks:"
    
    # Disk space check
    echo "  Disk usage on Elasticsearch nodes:"
    curl -s "$es_url/_cat/allocation?v" 2>/dev/null || echo "  Cannot retrieve disk usage"
    
    # Pending tasks
    echo "  Pending cluster tasks:"
    local pending_tasks=$(curl -s "$es_url/_cluster/pending_tasks" | jq '.tasks | length')
    echo "    Pending tasks: $pending_tasks"
    
    # Shard allocation
    echo "  Unassigned shards:"
    local unassigned=$(curl -s "$es_url/_cat/shards" | grep UNASSIGNED | wc -l)
    echo "    Unassigned shards: $unassigned"
    
    if [[ "$unassigned" -gt 0 ]]; then
        echo "    Unassigned shard details:"
        curl -s "$es_url/_cat/shards" | grep UNASSIGNED | head -5
    fi
}

# Logstash diagnostics
logstash_diagnostics() {
    echo "=== Logstash Diagnostics ==="
    
    # Check Logstash API
    echo "1. Logstash Status:"
    local logstash_url="http://logstash.company.com:9600"
    
    if curl -s --connect-timeout 10 "$logstash_url" >/dev/null; then
        echo "  ✓ Logstash API accessible"
        
        # Node info
        echo "  Node information:"
        curl -s "$logstash_url/_node" | jq '.version, .status'
        
        # Pipeline stats
        echo "  Pipeline statistics:"
        curl -s "$logstash_url/_node/stats/pipelines" | \
            jq '.pipelines | to_entries[] | {name: .key, events: .value.events}'
        
        # JVM stats
        echo "  JVM statistics:"
        curl -s "$logstash_url/_node/stats/jvm" | \
            jq '.jvm.mem.heap_used_percent, .jvm.mem.heap_max_in_bytes'
            
    else
        echo "  ✗ Logstash API not accessible at $logstash_url"
    fi
    
    # Check Logstash logs
    echo "2. Recent Logstash Logs:"
    if command -v kubectl >/dev/null 2>&1; then
        local logstash_pod=$(kubectl get pods -l app=logstash -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
        if [[ -n "$logstash_pod" ]]; then
            echo "  Logstash pod logs (last 15 lines):"
            kubectl logs "$logstash_pod" --tail=15 | grep -E "(ERROR|WARN|INFO)"
        fi
    else
        echo "  Check Logstash service logs manually"
    fi
}

# Kibana diagnostics
kibana_diagnostics() {
    echo "=== Kibana Diagnostics ==="
    
    # Check Kibana web interface
    echo "1. Kibana Web Interface:"
    local kibana_url="http://kibana.company.com:5601"
    
    if curl -s --connect-timeout 10 "$kibana_url" >/dev/null; then
        echo "  ✓ Kibana web interface accessible"
        
        # Kibana status API
        local status=$(curl -s "$kibana_url/api/status" | jq -r '.status.overall.state')
        echo "  Overall status: $status"
        
        if [[ "$status" != "green" ]]; then
            echo "  Status details:"
            curl -s "$kibana_url/api/status" | jq '.status.statuses[]'
        fi
        
    else
        echo "  ✗ Kibana not accessible at $kibana_url"
    fi
    
    # Check index patterns
    echo "2. Index Patterns:"
    local index_patterns=$(curl -s "$kibana_url/api/saved_objects/_find?type=index-pattern" | \
        jq -r '.saved_objects[].attributes.title' 2>/dev/null)
    
    if [[ -n "$index_patterns" ]]; then
        echo "  Configured index patterns:"
        echo "$index_patterns"
    else
        echo "  No index patterns found or API not accessible"
    fi
}

elasticsearch_diagnostics
logstash_diagnostics
kibana_diagnostics
```

## Emergency Response Procedures

### 1. Critical System Failure Response

#### Incident Response Checklist
```yaml
emergency_response:
  immediate_actions:
    - "Assess the scope and impact of the failure"
    - "Notify the incident response team"
    - "Activate the incident command center"
    - "Begin documenting all actions and timestamps"
    
  assessment_phase:
    - "Identify which services are affected"
    - "Determine if this is a security incident"
    - "Estimate the recovery time objective (RTO)"
    - "Identify dependencies and downstream impacts"
    
  communication_plan:
    - "Notify stakeholders within 15 minutes"
    - "Post status updates every 30 minutes"
    - "Prepare communication for external users"
    - "Document decisions and rationale"
    
  recovery_priorities:
    priority_1: "Critical CI/CD pipeline functionality"
    priority_2: "Source code repository access"
    priority_3: "Monitoring and alerting systems"
    priority_4: "Development and testing environments"
```

### 2. Service Recovery Procedures
```bash
#!/bin/bash
# Emergency service recovery procedures

emergency_recovery() {
    local service_type="$1"
    
    echo "=== Emergency Recovery Procedure: $service_type ==="
    echo "Timestamp: $(date)"
    echo ""
    
    case "$service_type" in
        "jenkins")
            jenkins_emergency_recovery
            ;;
        "gitlab")
            gitlab_emergency_recovery
            ;;
        "kubernetes")
            kubernetes_emergency_recovery
            ;;
        "storage")
            storage_emergency_recovery
            ;;
        "network")
            network_emergency_recovery
            ;;
        *)
            echo "Unknown service type. Available options:"
            echo "  jenkins, gitlab, kubernetes, storage, network"
            ;;
    esac
}

jenkins_emergency_recovery() {
    echo "=== Jenkins Emergency Recovery ==="
    
    # Step 1: Assess Jenkins status
    echo "1. Assessing Jenkins status..."
    if curl -s --connect-timeout 5 http://jenkins.company.com:8080 >/dev/null; then
        echo "  ✓ Jenkins web interface responding"
    else
        echo "  ✗ Jenkins web interface not responding"
        
        # Check service status
        echo "2. Checking Jenkins service..."
        if systemctl is-active jenkins >/dev/null 2>&1; then
            echo "  ✓ Jenkins service running"
        else
            echo "  ✗ Jenkins service not running - attempting restart"
            systemctl start jenkins
            sleep 30
        fi
    fi
    
    # Step 2: Check disk space
    echo "3. Checking disk space..."
    local jenkins_disk_usage=$(df /var/lib/jenkins | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ "$jenkins_disk_usage" -gt 90 ]]; then
        echo "  ⚠️ Critical disk space issue: ${jenkins_disk_usage}% used"
        echo "  Cleaning up old builds and logs..."
        
        # Emergency cleanup
        find /var/lib/jenkins/jobs -name "builds" -type d -exec find {} -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null
        find /var/lib/jenkins -name "*.log" -mtime +7 -delete 2>/dev/null
    fi
    
    # Step 3: Restart Jenkins agents
    echo "4. Restarting Jenkins agents..."
    local agent_hosts=("agent1.company.com" "agent2.company.com" "agent3.company.com")
    
    for agent in "${agent_hosts[@]}"; do
        echo "  Restarting agent: $agent"
        ssh -o ConnectTimeout=10 "$agent" "systemctl restart jenkins-agent" 2>/dev/null || \
            echo "    Failed to restart $agent"
    done
}

gitlab_emergency_recovery() {
    echo "=== GitLab Emergency Recovery ==="
    
    # Step 1: Check GitLab status
    echo "1. Checking GitLab status..."
    if curl -s --connect-timeout 5 http://gitlab.company.com >/dev/null; then
        echo "  ✓ GitLab web interface responding"
    else
        echo "  ✗ GitLab web interface not responding"
        
        # Check GitLab services
        echo "2. Checking GitLab services..."
        gitlab-ctl status
        
        # Restart GitLab services
        echo "3. Restarting GitLab services..."
        gitlab-ctl restart
        
        # Wait for services to start
        echo "4. Waiting for services to start..."
        sleep 60
        
        # Verify GitLab health
        echo "5. Verifying GitLab health..."
        gitlab-rake gitlab:check SANITIZE=true
    fi
    
    # Check database connectivity
    echo "6. Checking database connectivity..."
    if gitlab-rails runner "ActiveRecord::Base.connection.active?" >/dev/null 2>&1; then
        echo "  ✓ Database connection successful"
    else
        echo "  ✗ Database connection failed"
        echo "  Check PostgreSQL service and connectivity"
    fi
    
    # Check Redis connectivity
    echo "7. Checking Redis connectivity..."
    if gitlab-rails runner "Gitlab::Redis::Cache.with { |redis| redis.ping }" >/dev/null 2>&1; then
        echo "  ✓ Redis connection successful"
    else
        echo "  ✗ Redis connection failed"
        echo "  Check Redis service and connectivity"
    fi
}

kubernetes_emergency_recovery() {
    echo "=== Kubernetes Emergency Recovery ==="
    
    # Step 1: Check cluster connectivity
    echo "1. Checking cluster connectivity..."
    if kubectl cluster-info --request-timeout=10s >/dev/null 2>&1; then
        echo "  ✓ Cluster accessible"
    else
        echo "  ✗ Cluster not accessible"
        echo "  Check kubeconfig and cluster status"
        return 1
    fi
    
    # Step 2: Check node status
    echo "2. Checking node status..."
    local not_ready_nodes=$(kubectl get nodes --no-headers | grep -v Ready | wc -l)
    
    if [[ "$not_ready_nodes" -gt 0 ]]; then
        echo "  ⚠️ $not_ready_nodes nodes not ready"
        echo "  Not ready nodes:"
        kubectl get nodes | grep -v Ready
        
        # Attempt to restart kubelet on not ready nodes
        echo "3. Attempting to restart kubelet on not ready nodes..."
        kubectl get nodes --no-headers | grep -v Ready | awk '{print $1}' | \
        while read node; do
            echo "  Restarting kubelet on $node"
            # This would require SSH access to nodes
            # ssh "$node" "systemctl restart kubelet"
        done
    fi
    
    # Step 3: Check critical system pods
    echo "4. Checking critical system pods..."
    kubectl get pods -n kube-system | grep -E "(api-server|etcd|scheduler|controller)"
    
    # Step 4: Restart failed pods
    echo "5. Restarting failed pods..."
    local failed_pods=$(kubectl get pods --all-namespaces --field-selector=status.phase=Failed -o jsonpath='{.items[*].metadata.name}')
    
    for pod in $failed_pods; do
        local namespace=$(kubectl get pod "$pod" --all-namespaces -o jsonpath='{.items[0].metadata.namespace}')
        echo "  Deleting failed pod: $pod (namespace: $namespace)"
        kubectl delete pod "$pod" -n "$namespace"
    done
}

storage_emergency_recovery() {
    echo "=== Storage Emergency Recovery ==="
    
    # Step 1: Check Dell Unity status
    echo "1. Checking Dell Unity storage status..."
    if ping -c 3 10.1.100.30 >/dev/null 2>&1; then
        echo "  ✓ Unity storage accessible"
        
        # Check storage health via CLI if available
        if command -v uemcli >/dev/null 2>&1; then
            echo "  Checking storage system alerts..."
            uemcli -d 10.1.100.30 -u admin -p "$UNITY_PASSWORD" /sys/alert show
        fi
    else
        echo "  ✗ Unity storage not accessible"
        echo "  Check network connectivity and storage power status"
    fi
    
    # Step 2: Check NFS mounts
    echo "2. Checking NFS mounts..."
    local critical_mounts=("/mnt/ci-shared" "/mnt/ci-cache" "/var/lib/jenkins")
    
    for mount_point in "${critical_mounts[@]}"; do
        if mountpoint -q "$mount_point" 2>/dev/null; then
            echo "  ✓ $mount_point mounted"
        else
            echo "  ✗ $mount_point not mounted - attempting remount"
            
            # Attempt to remount
            mount "$mount_point" 2>/dev/null || \
                echo "    Failed to mount $mount_point - check /etc/fstab"
        fi
    done
    
    # Step 3: Check iSCSI connections
    echo "3. Checking iSCSI connections..."
    if command -v iscsiadm >/dev/null 2>&1; then
        echo "  Active iSCSI sessions:"
        iscsiadm -m session
        
        # Restart iSCSI service if no active sessions
        local session_count=$(iscsiadm -m session 2>/dev/null | wc -l)
        if [[ "$session_count" -eq 0 ]]; then
            echo "  No active iSCSI sessions - restarting services"
            systemctl restart iscsid iscsi
        fi
    fi
}

network_emergency_recovery() {
    echo "=== Network Emergency Recovery ==="
    
    # Step 1: Check network interfaces
    echo "1. Checking network interfaces..."
    ip link show | grep -E "(DOWN|NO-CARRIER)" && \
        echo "  ⚠️ Network interfaces with issues detected"
    
    # Step 2: Check routing
    echo "2. Checking default route..."
    if ip route | grep -q default; then
        echo "  ✓ Default route present"
    else
        echo "  ✗ No default route - network connectivity compromised"
    fi
    
    # Step 3: Check DNS resolution
    echo "3. Checking DNS resolution..."
    if nslookup google.com >/dev/null 2>&1; then
        echo "  ✓ DNS resolution working"
    else
        echo "  ✗ DNS resolution failed"
        echo "  Checking /etc/resolv.conf..."
        cat /etc/resolv.conf
    fi
    
    # Step 4: Check critical services connectivity
    echo "4. Testing critical service connectivity..."
    local critical_services=(
        "jenkins.company.com:8080"
        "gitlab.company.com:443"
        "10.1.100.30:443"  # Unity storage
    )
    
    for service in "${critical_services[@]}"; do
        local host=$(echo "$service" | cut -d':' -f1)
        local port=$(echo "$service" | cut -d':' -f2)
        
        if nc -z -w5 "$host" "$port" 2>/dev/null; then
            echo "  ✓ $service accessible"
        else
            echo "  ✗ $service not accessible"
        fi
    done
}

# Emergency contact information
emergency_contacts() {
    echo "=== Emergency Contacts ==="
    echo ""
    echo "Dell ProSupport Plus: 1-800-DELL-CARE"
    echo "Dell Emergency Support: 1-800-945-3355"
    echo ""
    echo "Internal Escalation:"
    echo "  Operations Manager: +1-555-OPS-MGR"
    echo "  Infrastructure Lead: +1-555-INFRA-LEAD"
    echo "  CTO Emergency Line: +1-555-CTO-EMRG"
    echo ""
    echo "Vendor Support:"
    echo "  Jenkins Support: support@jenkins.io"
    echo "  GitLab Support: support@gitlab.com"
    echo "  Kubernetes Support: Community Forums"
}

# Usage help
emergency_help() {
    echo "=== Emergency Recovery Usage ==="
    echo ""
    echo "Available recovery procedures:"
    echo "  emergency_recovery jenkins    - Jenkins emergency recovery"
    echo "  emergency_recovery gitlab     - GitLab emergency recovery"
    echo "  emergency_recovery kubernetes - Kubernetes emergency recovery"
    echo "  emergency_recovery storage    - Storage emergency recovery"
    echo "  emergency_recovery network    - Network emergency recovery"
    echo ""
    echo "Emergency contacts:"
    echo "  emergency_contacts"
    echo ""
    echo "Remember to:"
    echo "  1. Document all actions taken"
    echo "  2. Notify stakeholders immediately"
    echo "  3. Follow incident response procedures"
    echo "  4. Schedule post-incident review"
}

# Show help if no arguments provided
if [[ $# -eq 0 ]]; then
    emergency_help
fi
```

## Escalation Procedures

### Internal Escalation
```yaml
escalation_matrix:
  level_1_operations:
    response_time: "15 minutes"
    scope: "Routine issues, service restarts, basic troubleshooting"
    contacts:
      - "Operations Team Lead: +1-555-0101"
      - "On-call Engineer: +1-555-0102"
    
  level_2_technical:
    response_time: "30 minutes"
    scope: "Complex technical issues, system failures, performance problems"
    contacts:
      - "Technical Lead: +1-555-0201"
      - "Infrastructure Architect: +1-555-0202"
    
  level_3_vendor:
    response_time: "1 hour"
    scope: "Hardware failures, vendor software issues, warranty claims"
    contacts:
      - "Dell ProSupport Plus: 1-800-DELL-CARE"
      - "Dell Account Team: account-team@dell.com"
    
  emergency_escalation:
    response_time: "Immediate"
    scope: "Critical business impact, data center emergencies, security incidents"
    contacts:
      - "CTO: +1-555-0301"
      - "IT Director: +1-555-0302"
      - "Dell Emergency Support: +1-800-945-3355"
```

### Vendor Support Procedures
```bash
#!/bin/bash
# Vendor support case creation

create_dell_support_case() {
    local issue_description="$1"
    local severity="$2"
    local service_tag="$3"
    
    echo "=== Creating Dell Support Case ==="
    echo "Issue: $issue_description"
    echo "Severity: $severity"
    echo "Service Tag: $service_tag"
    echo "Timestamp: $(date)"
    
    # Collect system information
    echo ""
    echo "Collecting system information..."
    
    # Hardware information
    if command -v racadm >/dev/null 2>&1; then
        echo "System Information:" > /tmp/dell-support-info.txt
        racadm getsysinfo >> /tmp/dell-support-info.txt
        
        echo "System Event Log:" >> /tmp/dell-support-info.txt
        racadm getsel >> /tmp/dell-support-info.txt
        
        echo "Hardware Inventory:" >> /tmp/dell-support-info.txt
        racadm inventory >> /tmp/dell-support-info.txt
    fi
    
    # System logs
    echo "System Logs:" >> /tmp/dell-support-info.txt
    journalctl -n 100 --no-pager >> /tmp/dell-support-info.txt
    
    echo ""
    echo "System information collected in /tmp/dell-support-info.txt"
    echo ""
    echo "Dell Support Contact Information:"
    echo "  Phone: 1-800-DELL-CARE"
    echo "  Online: https://www.dell.com/support"
    echo "  Service Tag: $service_tag"
    echo ""
    echo "When calling, provide:"
    echo "  1. Service Tag: $service_tag"
    echo "  2. Issue Description: $issue_description"
    echo "  3. Severity Level: $severity"
    echo "  4. System Information File: /tmp/dell-support-info.txt"
}

# Usage example
# create_dell_support_case "Server not powering on" "Critical" "ABC123"
```

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Review Schedule**: Quarterly  
**Owner**: Technical Support Team

## Appendix

### A. Quick Reference Commands
- Essential diagnostic commands
- Common log file locations
- Service restart procedures
- Performance monitoring tools

### B. Contact Information
- Internal escalation contacts
- Vendor support information
- Emergency response procedures
- After-hours support contacts

### C. Tool Configurations
- Monitoring tool configurations
- Log aggregation settings
- Alert threshold values
- Dashboard access information

### D. Known Issues Database
- Previously resolved issues
- Workaround procedures
- Permanent fix tracking
- Lessons learned documentation
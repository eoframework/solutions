# Dell PowerEdge CI Infrastructure - Configuration Templates

## Overview

This document provides comprehensive configuration templates for Dell PowerEdge CI infrastructure components. These templates are optimized for high-performance CI/CD workloads and provide secure, scalable foundations for development environments.

## PowerEdge Server Configuration

### PowerEdge R750 Configuration (Primary CI Nodes)

#### BIOS Configuration Template
```yaml
# BIOS Settings for CI/CD Optimization
bios_settings:
  system_profile: "Performance Optimized"
  power_management: "OS Control"
  cpu_settings:
    virtualization_technology: "Enabled"
    hyper_threading: "Enabled"
    turbo_boost: "Enabled"
    c_states: "Disabled"  # For consistent performance
  memory_settings:
    node_interleaving: "Disabled"
    memory_patrol_scrub: "Standard"
    memory_refresh_rate: "1x"
  storage_settings:
    integrated_raid: "AHCI"  # For NVMe performance
    write_cache: "Enabled with BBU"
  network_settings:
    sr_iov: "Enabled"
    wake_on_lan: "Disabled"
    network_stack: "Enabled"
```

#### Hardware Specifications Template
```yaml
# Recommended Hardware Configuration
hardware_config:
  cpu: "2x Intel Xeon Gold 6338 (32 cores total)"
  memory: "256GB DDR4-3200 ECC"
  storage:
    primary: "2x 960GB NVMe SSD (RAID 1)"
    cache: "4x 3.84TB NVMe SSD (RAID 10)"
    backup: "2x 10TB SAS HDD (RAID 1)"
  network:
    management: "1x iDRAC Enterprise"
    data: "2x 25GbE SFP28 (Broadcom 57414)"
  power: "2x 800W Redundant PSU"
```

### PowerEdge R650 Configuration (Build Agents)

#### Optimized for Container Workloads
```yaml
# R650 Build Agent Configuration
build_agent_config:
  cpu: "2x Intel Xeon Silver 4314 (32 cores total)"
  memory: "128GB DDR4-3200 ECC"
  storage:
    os: "2x 480GB SATA SSD (RAID 1)"
    containers: "2x 1.92TB NVMe SSD (RAID 0)"
  network:
    primary: "2x 10GbE RJ45"
    management: "iDRAC Express"
  containers:
    docker_storage_driver: "overlay2"
    docker_log_driver: "json-file"
    docker_log_max_size: "10m"
    docker_log_max_file: "5"
```

## iDRAC Management Configuration

### iDRAC Enterprise Template
```yaml
# iDRAC Configuration for CI Infrastructure
idrac_config:
  network:
    ip_source: "Static"
    ipv4_settings:
      address: "10.1.100.x"  # Management network
      netmask: "255.255.255.0"
      gateway: "10.1.100.1"
      dns1: "10.1.100.10"
      dns2: "10.1.100.11"
    
  user_management:
    - username: "ci-admin"
      password: "[SECURE_PASSWORD]"
      role: "Administrator"
      enabled: true
    - username: "ci-operator" 
      password: "[SECURE_PASSWORD]"
      role: "Operator"
      enabled: true
    - username: "ci-readonly"
      password: "[SECURE_PASSWORD]"
      role: "ReadOnly"
      enabled: true
  
  alerts:
    email_notifications:
      smtp_server: "smtp.company.com"
      smtp_port: 587
      sender_email: "idrac-alerts@company.com"
      recipients:
        - "ops-team@company.com"
        - "ci-admin@company.com"
    
    alert_categories:
      - "System Health"
      - "Storage"
      - "Power Supply"
      - "Temperature"
      - "Fan"
  
  remote_access:
    virtual_console: "Enabled"
    virtual_media: "Enabled"
    ssh: "Enabled"
    telnet: "Disabled"
    web_server: "Enabled"
    ssl_encryption: "TLS 1.2 and Higher Only"
```

### SNMP Configuration for Monitoring
```yaml
# SNMP Configuration Template
snmp_config:
  version: "v3"
  community:
    read_community: "[SECURE_COMMUNITY]"
    trap_community: "[SECURE_COMMUNITY]"
  v3_users:
    - username: "ci-monitor"
      auth_protocol: "SHA"
      auth_password: "[SECURE_AUTH_PASSWORD]"
      privacy_protocol: "AES"
      privacy_password: "[SECURE_PRIV_PASSWORD]"
  trap_destination:
    - ip: "10.1.100.50"  # Monitoring server
      port: 162
      community: "[SECURE_COMMUNITY]"
```

## OpenManage Enterprise Configuration

### OME Server Setup Template
```yaml
# OpenManage Enterprise Configuration
ome_config:
  appliance:
    hostname: "ome-ci-primary"
    ip_address: "10.1.100.20"
    netmask: "255.255.255.0"
    gateway: "10.1.100.1"
    dns_servers:
      - "10.1.100.10"
      - "10.1.100.11"
    ntp_servers:
      - "pool.ntp.org"
      - "time.google.com"
  
  discovery:
    ranges:
      - start_ip: "10.1.100.100"
        end_ip: "10.1.100.200"
        credentials:
          - username: "ci-admin"
            password: "[SECURE_PASSWORD]"
  
  device_groups:
    - name: "CI-Primary-Nodes"
      description: "Main CI/CD processing nodes"
      criteria: "Model contains 'R750'"
    - name: "CI-Build-Agents"
      description: "Container build agents"  
      criteria: "Model contains 'R650'"
    - name: "CI-Storage-Nodes"
      description: "Storage infrastructure"
      criteria: "Service Tag starts with 'STG'"
  
  compliance_templates:
    - name: "CI-Security-Baseline"
      description: "Security hardening for CI infrastructure"
      categories:
        - "BIOS"
        - "iDRAC"
        - "Operating System"
    - name: "CI-Performance-Template"
      description: "Performance optimization settings"
      categories:
        - "BIOS"
        - "RAID"
        - "Network"
```

### OME Policy Templates
```yaml
# Power Management Policy
power_policy:
  name: "CI-Power-Policy"
  description: "Power management for CI workloads"
  settings:
    power_cap: "Disabled"  # Maximum performance
    power_profile: "Performance"
    redundancy: "Grid Redundancy"
    hot_spare: "Enabled"

# Update Policy  
update_policy:
  name: "CI-Update-Policy"
  description: "Automated updates for CI infrastructure"
  schedule:
    frequency: "Monthly"
    day_of_month: 15
    time: "02:00 AM"
    maintenance_window: "4 hours"
  components:
    - "BIOS"
    - "iDRAC"
    - "Network Drivers"
    - "Storage Controllers"
  notifications:
    - email: "ops-team@company.com"
    - webhook: "https://monitoring.company.com/webhooks/updates"
```

## CI/CD Tool Configuration

### Jenkins Configuration Template

#### Jenkins Controller Configuration
```yaml
# Jenkins Controller on PowerEdge R750
jenkins_controller:
  system:
    java_opts: "-Xmx16g -Xms8g -XX:+UseG1GC -XX:G1HeapRegionSize=32m"
    home: "/var/lib/jenkins"
    user: "jenkins"
    port: 8080
    prefix: "/jenkins"
  
  plugins:
    essential:
      - "workflow-aggregator"  # Pipeline
      - "docker-plugin"
      - "kubernetes"
      - "git"
      - "github"
      - "gitlab-plugin"
      - "build-timeout"
      - "timestamper"
      - "ws-cleanup"
      - "ant"
      - "gradle"
      - "maven-plugin"
      - "nodejs"
    
    monitoring:
      - "monitoring"
      - "prometheus"
      - "build-metrics"
  
  security:
    realm: "ldap"
    authorization: "matrix-auth"
    ldap_config:
      server: "ldap://ldap.company.com:389"
      root_dn: "dc=company,dc=com"
      user_search_base: "ou=users"
      group_search_base: "ou=groups"
      manager_dn: "cn=jenkins,ou=service-accounts,dc=company,dc=com"
      manager_password: "[SECURE_PASSWORD]"
```

#### Jenkins Agent Configuration
```yaml
# Jenkins Agents on PowerEdge R650
jenkins_agents:
  docker_agents:
    image: "jenkins/agent:latest"
    container_cap: 10
    docker_template:
      cpu_period: 100000
      cpu_quota: 400000  # 4 CPU cores
      memory: 8589934592  # 8GB RAM
      volumes:
        - "/var/run/docker.sock:/var/run/docker.sock"
        - "/tmp:/tmp"
      environment:
        - "JENKINS_AGENT_WORKDIR=/home/jenkins/agent"
  
  static_agents:
    count: 8
    executors: 4
    labels: "linux docker kubernetes maven gradle nodejs python"
    remote_fs: "/home/jenkins"
    java_path: "/usr/bin/java"
    jvm_options: "-Xmx4g -Xms2g"
```

### GitLab Runner Configuration

#### GitLab Runner on PowerEdge
```yaml
# GitLab Runner Configuration
gitlab_runner:
  concurrent: 10
  check_interval: 0
  session_timeout: 1800
  
  runners:
    - name: "poweredge-docker-runner"
      url: "https://gitlab.company.com"
      token: "[RUNNER_TOKEN]"
      executor: "docker"
      docker:
        image: "ubuntu:20.04"
        privileged: true
        volumes:
          - "/cache"
          - "/var/run/docker.sock:/var/run/docker.sock"
        pull_policy: "if-not-present"
        memory: "8g"
        cpus: "4"
    
    - name: "poweredge-kubernetes-runner"
      url: "https://gitlab.company.com"
      token: "[RUNNER_TOKEN]"
      executor: "kubernetes"
      kubernetes:
        namespace: "gitlab-runner"
        image: "ubuntu:20.04"
        cpu_request: "2"
        cpu_limit: "4"
        memory_request: "4Gi"
        memory_limit: "8Gi"
        service_cpu_request: "100m"
        service_memory_request: "128Mi"
```

## Kubernetes Configuration

### Kubernetes Cluster Template
```yaml
# Kubernetes Cluster for CI Workloads
kubernetes_cluster:
  cluster_name: "ci-cluster"
  version: "1.28"
  
  master_nodes:
    count: 3
    hardware: "PowerEdge R750"
    specs:
      cpu: "8 cores"
      memory: "32GB"
      storage: "100GB SSD"
  
  worker_nodes:
    count: 6
    hardware: "PowerEdge R650" 
    specs:
      cpu: "16 cores"
      memory: "64GB"
      storage: "200GB SSD"
  
  networking:
    pod_subnet: "10.244.0.0/16"
    service_subnet: "10.96.0.0/12"
    cni: "calico"
  
  storage:
    default_storage_class: "dell-csi-unity"
    csi_drivers:
      - "dell-unity-csi"
      - "dell-powerstore-csi"
  
  ingress:
    controller: "nginx-ingress"
    load_balancer: "metallb"
```

### Container Resource Templates
```yaml
# Resource Limits for CI Workloads
resource_templates:
  small_build:
    requests:
      cpu: "500m"
      memory: "1Gi" 
    limits:
      cpu: "2"
      memory: "4Gi"
  
  medium_build:
    requests:
      cpu: "1"
      memory: "2Gi"
    limits:
      cpu: "4"
      memory: "8Gi"
  
  large_build:
    requests:
      cpu: "2"
      memory: "4Gi"
    limits:
      cpu: "8"
      memory: "16Gi"
  
  test_execution:
    requests:
      cpu: "1"
      memory: "2Gi"
    limits:
      cpu: "4"
      memory: "8Gi"
```

## Network Configuration

### Network Architecture Template
```yaml
# Network Configuration for CI Infrastructure
network_config:
  vlans:
    management:
      vlan_id: 100
      subnet: "10.1.100.0/24"
      gateway: "10.1.100.1"
      description: "Management network for iDRAC and OME"
    
    ci_control:
      vlan_id: 200
      subnet: "10.1.200.0/24" 
      gateway: "10.1.200.1"
      description: "CI/CD control plane traffic"
    
    ci_data:
      vlan_id: 300
      subnet: "10.1.300.0/24"
      gateway: "10.1.300.1"  
      description: "CI/CD data and build traffic"
    
    storage:
      vlan_id: 400
      subnet: "10.1.400.0/24"
      gateway: "10.1.400.1"
      description: "Storage network (iSCSI/NFS)"
  
  dns:
    primary: "10.1.100.10"
    secondary: "10.1.100.11"
    search_domains:
      - "ci.company.com"
      - "company.com"
  
  ntp:
    servers:
      - "ntp1.company.com"
      - "ntp2.company.com"
      - "pool.ntp.org"
```

### Dell Networking Switch Configuration
```bash
# Dell OS10 Switch Configuration Template
configure terminal

# VLAN Configuration
interface vlan 100
  description "Management VLAN"
  ip address 10.1.100.1/24
  
interface vlan 200  
  description "CI Control VLAN"
  ip address 10.1.200.1/24
  
interface vlan 300
  description "CI Data VLAN" 
  ip address 10.1.300.1/24

interface vlan 400
  description "Storage VLAN"
  ip address 10.1.400.1/24

# Port Channel Configuration for High Availability
interface port-channel 1
  description "PowerEdge R750 LAG"
  switchport mode trunk
  switchport trunk allowed vlan 100,200,300,400
  spanning-tree guard root
  
# Individual Port Configuration  
interface ethernet 1/1/1
  description "PowerEdge R750-01 NIC1"
  channel-group 1 mode active
  no shutdown
  
interface ethernet 1/1/2
  description "PowerEdge R750-01 NIC2"  
  channel-group 1 mode active
  no shutdown
```

## Storage Configuration

### Dell Unity Storage Template
```yaml
# Dell Unity XT Storage Configuration
unity_storage:
  system:
    model: "Unity XT 480F"
    management_ip: "10.1.100.30"
    service_ip: "10.1.400.30"
  
  storage_pools:
    - name: "ci-fast-pool"
      description: "High-performance storage for active builds"
      drives: "24x 3.84TB NVMe SSD"
      raid_level: "RAID 5"
      hot_spares: 2
    
    - name: "ci-capacity-pool"
      description: "Large capacity for build artifacts"
      drives: "12x 10TB NL-SAS"
      raid_level: "RAID 6" 
      hot_spares: 2
  
  file_systems:
    - name: "ci-shared-storage"
      pool: "ci-fast-pool"
      size: "10TB"
      protocol: "NFS"
      export_path: "/ci-shared"
      access_policy: "Unix"
    
    - name: "ci-build-cache"
      pool: "ci-fast-pool"
      size: "5TB"
      protocol: "NFS"
      export_path: "/ci-cache"
      access_policy: "Unix"
  
  block_storage:
    - name: "ci-database-lun"
      pool: "ci-fast-pool"
      size: "2TB"
      protocol: "iSCSI"
      host_access: "ci-database-host"
```

### NFS Export Configuration
```bash
# NFS Exports for CI Infrastructure
# /etc/exports

/ci-shared 10.1.200.0/24(rw,sync,no_root_squash,no_subtree_check)
/ci-cache 10.1.200.0/24(rw,sync,no_root_squash,no_subtree_check)
/ci-artifacts 10.1.200.0/24(rw,sync,root_squash,no_subtree_check)

# NFS Client Mount Points
# /etc/fstab entries for CI nodes
10.1.400.30:/ci-shared /mnt/ci-shared nfs defaults,hard,intr 0 0
10.1.400.30:/ci-cache /mnt/ci-cache nfs defaults,hard,intr 0 0
10.1.400.30:/ci-artifacts /mnt/ci-artifacts nfs defaults,hard,intr 0 0
```

## Security Configuration

### Security Hardening Template
```yaml
# Security Configuration for CI Infrastructure
security_config:
  authentication:
    ldap:
      server: "ldaps://ldap.company.com:636"
      base_dn: "dc=company,dc=com"
      bind_dn: "cn=ci-service,ou=service-accounts,dc=company,dc=com"
      bind_password: "[SECURE_PASSWORD]"
      user_filter: "(&(objectClass=user)(memberOf=CN=CI-Users,OU=Groups,DC=company,DC=com))"
      group_filter: "(&(objectClass=group)(member={0}))"
  
  ssl_certificates:
    ca_certificate: "/etc/ssl/certs/company-ca.crt"
    ssl_certificate: "/etc/ssl/certs/ci.company.com.crt"
    ssl_private_key: "/etc/ssl/private/ci.company.com.key"
    
  firewall_rules:
    management:
      - port: 22
        protocol: "TCP"
        source: "10.1.100.0/24"
        description: "SSH Management"
      - port: 443
        protocol: "TCP" 
        source: "10.1.100.0/24"
        description: "HTTPS Management"
    
    ci_services:
      - port: 8080
        protocol: "TCP"
        source: "10.1.200.0/24"
        description: "Jenkins"
      - port: 80
        protocol: "TCP"
        source: "10.1.200.0/24"  
        description: "GitLab HTTP"
      - port: 443
        protocol: "TCP"
        source: "10.1.200.0/24"
        description: "GitLab HTTPS"
  
  vulnerability_scanning:
    schedule: "Daily"
    scanners:
      - "OpenVAS"
      - "Nessus"
    report_recipients:
      - "security-team@company.com"
      - "ci-admin@company.com"
```

## Monitoring and Logging Configuration

### Monitoring Stack Template
```yaml
# Monitoring Configuration
monitoring_config:
  prometheus:
    retention: "30d"
    storage: "1TB SSD"
    scrape_interval: "15s"
    targets:
      - job_name: "poweredge-servers"
        static_configs:
          - targets: ["10.1.100.101:9100", "10.1.100.102:9100"]
      - job_name: "jenkins"
        static_configs:
          - targets: ["10.1.200.10:8080"]
      - job_name: "kubernetes"
        kubernetes_sd_configs:
          - role: "node"
  
  grafana:
    admin_password: "[SECURE_PASSWORD]"
    datasources:
      - name: "Prometheus"
        type: "prometheus"
        url: "http://prometheus:9090"
    dashboards:
      - "Dell PowerEdge Server Metrics"
      - "Jenkins Build Metrics"
      - "Kubernetes Cluster Overview"
      - "CI/CD Pipeline Performance"
  
  alertmanager:
    smtp:
      smarthost: "smtp.company.com:587"
      from: "alerts@company.com"
      username: "alerts@company.com"
      password: "[SECURE_PASSWORD]"
    routes:
      - match:
          severity: "critical"
        receiver: "ops-team"
      - match:
          severity: "warning"
        receiver: "ops-team-low-priority"
```

### Log Management Template
```yaml
# Logging Configuration  
logging_config:
  elasticsearch:
    cluster_name: "ci-logs"
    nodes: 3
    heap_size: "16g"
    storage: "2TB per node"
    retention_policy: "90 days"
  
  logstash:
    inputs:
      - beats
      - syslog
      - jenkins
    filters:
      - grok
      - date
      - mutate
    outputs:
      - elasticsearch
  
  filebeat:
    inputs:
      - type: "log"
        paths: ["/var/log/jenkins/*.log"]
        fields:
          service: "jenkins"
      - type: "log"
        paths: ["/var/log/docker/*.log"]
        fields:
          service: "docker"
      - type: "log"  
        paths: ["/var/log/kubernetes/*.log"]
        fields:
          service: "kubernetes"
  
  kibana:
    server_name: "ci-logs.company.com"
    elasticsearch_url: "http://elasticsearch:9200"
    default_app_id: "discover"
```

## Configuration Management

### Ansible Configuration
```yaml
# Ansible Inventory and Configuration
inventory:
  poweredge_servers:
    hosts:
      r750-ci-01:
        ansible_host: 10.1.200.101
        server_role: "ci-controller"
      r750-ci-02:
        ansible_host: 10.1.200.102
        server_role: "ci-controller"
      r650-agent-[01:08]:
        ansible_host: 10.1.200.[111:118]
        server_role: "ci-agent"
    
    vars:
      ansible_user: "ci-admin"
      ansible_ssh_private_key_file: "~/.ssh/ci_rsa"
      ansible_become: yes
      ansible_become_method: sudo

# Ansible Configuration File
[defaults]
host_key_checking = False
inventory = inventory/hosts
remote_user = ci-admin
private_key_file = ~/.ssh/ci_rsa
become = True
become_method = sudo
become_user = root
gathering = smart
fact_caching = memory
stdout_callback = yaml
```

### Terraform Configuration
```hcl
# Terraform Configuration for Infrastructure as Code
terraform {
  required_version = ">= 1.0"
  required_providers {
    dell = {
      source  = "dell/poweredge"
      version = "~> 1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" 
      version = "~> 2.0"
    }
  }
}

# PowerEdge Server Resources
resource "dell_poweredge_server" "ci_controllers" {
  count = 2
  
  model = "PowerEdge R750"
  service_tag = var.controller_service_tags[count.index]
  
  bios_config = {
    system_profile = "Performance Optimized"
    virtualization = "Enabled" 
    hyper_threading = "Enabled"
  }
  
  idrac_config = {
    ip_address = "10.1.100.${101 + count.index}"
    netmask = "255.255.255.0"
    gateway = "10.1.100.1"
    
    user {
      username = "ci-admin"
      password = var.idrac_password
      role = "Administrator"
    }
  }
  
  tags = {
    Environment = "CI"
    Role = "Controller"
    Project = "PowerEdge-CI-Infrastructure"
  }
}
```

---

**Configuration Version**: 1.0  
**Last Updated**: [Current Date]  
**Validation Status**: Template - Requires Environment-Specific Values  
**Owner**: Dell Professional Services Team

## Notes

1. **Security**: Replace all `[SECURE_PASSWORD]` and `[TOKEN]` placeholders with actual secure values
2. **Network**: Adjust IP ranges and VLANs to match your environment
3. **Storage**: Size storage pools based on your capacity requirements
4. **Monitoring**: Customize alert thresholds based on your SLAs
5. **Compliance**: Verify configurations meet your security and compliance requirements
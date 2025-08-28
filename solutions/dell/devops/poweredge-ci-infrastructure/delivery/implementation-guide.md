# Dell PowerEdge CI Infrastructure - Implementation Guide

## Overview

This comprehensive implementation guide provides step-by-step procedures for deploying Dell PowerEdge CI infrastructure solutions. The guide is designed for technical teams and covers all phases from initial planning through production deployment.

## Implementation Phases

### Phase 1: Pre-Implementation Planning (Week 1-2)

#### 1.1 Infrastructure Assessment

**Prerequisites Validation Checklist**
- [ ] Data center power and cooling capacity verified
- [ ] Network infrastructure and VLAN design completed
- [ ] IP address ranges allocated and documented
- [ ] DNS and NTP services configured
- [ ] Security policies and certificate requirements defined
- [ ] Backup and disaster recovery requirements documented

**Capacity Planning Worksheet**
```yaml
# Capacity Requirements Assessment
capacity_assessment:
  workload_analysis:
    concurrent_builds: 50              # Peak concurrent builds
    build_duration_avg: "15 minutes"   # Average build time
    build_size_avg: "2GB"             # Average build artifact size
    daily_builds: 500                  # Total daily builds
    peak_hours: "9 AM - 6 PM EST"      # Peak usage hours
  
  compute_requirements:
    total_cpu_cores: 256               # Total CPU cores needed
    total_memory_gb: 1024              # Total memory in GB
    storage_iops: 10000                # Required IOPS
    network_bandwidth_gbps: 20         # Network bandwidth
  
  growth_projections:
    year_1_growth: "50%"               # Expected growth year 1
    year_2_growth: "100%"              # Expected growth year 2
    max_capacity_buffer: "30%"         # Capacity headroom
```

**Site Survey Documentation**
- [ ] Rack space availability (minimum 4 racks required)
- [ ] Power requirements (380V 3-phase, 32A per rack)
- [ ] Cooling capacity (15kW per rack)
- [ ] Network connectivity to data center backbone
- [ ] Physical security controls and access procedures
- [ ] Environmental monitoring systems

#### 1.2 Team Preparation

**Required Team Members**
```yaml
implementation_team:
  project_manager:
    role: "Overall project coordination"
    skills: ["Project Management", "Risk Management"]
    commitment: "Full-time"
  
  infrastructure_architect:
    role: "Solution design and architecture"
    skills: ["Dell PowerEdge", "Virtualization", "Networking"]
    commitment: "Full-time"
  
  systems_engineers:
    count: 2
    role: "Hands-on implementation"
    skills: ["Linux/Windows Admin", "Dell OpenManage", "Automation"]
    commitment: "Full-time"
  
  network_engineer:
    role: "Network configuration and optimization"
    skills: ["Dell Networking", "VLANs", "Load Balancing"]
    commitment: "Part-time (50%)"
  
  security_engineer:
    role: "Security hardening and compliance"
    skills: ["Security Hardening", "SSL/TLS", "LDAP"]
    commitment: "Part-time (25%)"
  
  application_engineers:
    count: 2
    role: "CI/CD tool configuration"
    skills: ["Jenkins", "GitLab", "Kubernetes", "Docker"]
    commitment: "Full-time"
```

**Training Requirements**
- [ ] Dell PowerEdge Server Management (2-day course)
- [ ] OpenManage Enterprise Administration (1-day course)
- [ ] iDRAC Advanced Management (1-day course)
- [ ] Container Orchestration with Kubernetes (3-day course)
- [ ] Jenkins Administration and Pipeline Development (2-day course)

#### 1.3 Tool and Resource Preparation

**Required Software and Tools**
```bash
# Essential tools installation checklist
tools_checklist:
  management_tools:
    - "Dell OpenManage Enterprise"
    - "iDRAC Service Module"
    - "Dell Repository Manager"
    - "OpenManage Integration for VMware vCenter"
  
  deployment_tools:
    - "Ansible >= 2.9"
    - "Terraform >= 1.0"
    - "Docker CE >= 20.0"
    - "Kubernetes kubectl >= 1.24"
    - "Helm >= 3.8"
  
  monitoring_tools:
    - "Prometheus"
    - "Grafana"
    - "AlertManager"
    - "ELK Stack (Elasticsearch, Logstash, Kibana)"
  
  development_tools:
    - "Git >= 2.30"
    - "Jenkins >= 2.400"
    - "GitLab CE/EE >= 15.0"
    - "Maven >= 3.8"
    - "Gradle >= 7.0"
    - "Node.js >= 16 LTS"
```

### Phase 2: Hardware Deployment (Week 3-4)

#### 2.1 PowerEdge Server Installation

**Physical Installation Procedure**

1. **Rack Installation**
```bash
# PowerEdge R750 Installation Checklist
rack_installation:
  preparation:
    - "Verify rack compatibility (Dell ReadyRails II)"
    - "Install rack mounting hardware"
    - "Route power and network cables"
    - "Label cables according to naming convention"
  
  server_installation:
    - "Install servers in designated rack positions"
    - "Connect power cables (redundant PSU configuration)"
    - "Connect network cables (management and data)"
    - "Verify all connections secure and labeled"
  
  initial_power_on:
    - "Power on servers in sequence"
    - "Monitor POST process for errors"
    - "Verify iDRAC accessibility"
    - "Document MAC addresses and service tags"
```

2. **Initial Server Configuration**
```bash
#!/bin/bash
# Initial PowerEdge Server Setup Script

# Variables
SERVER_LIST="server-list.txt"
ADMIN_USER="ci-admin"
ADMIN_PASS="[SECURE_PASSWORD]"

# Function to configure individual server
configure_server() {
    local server_ip=$1
    local server_role=$2
    
    echo "Configuring server: $server_ip ($server_role)"
    
    # Configure iDRAC settings
    racadm -r $server_ip -u root -p calvin set iDRAC.NIC.Enable 1
    racadm -r $server_ip -u root -p calvin set iDRAC.IPv4.Address $server_ip
    racadm -r $server_ip -u root -p calvin set iDRAC.IPv4.Netmask 255.255.255.0
    racadm -r $server_ip -u root -p calvin set iDRAC.IPv4.Gateway 10.1.100.1
    
    # Create admin user
    racadm -r $server_ip -u root -p calvin set iDRAC.Users.2.UserName $ADMIN_USER
    racadm -r $server_ip -u root -p calvin set iDRAC.Users.2.Password $ADMIN_PASS
    racadm -r $server_ip -u root -p calvin set iDRAC.Users.2.Privilege 0x1ff
    racadm -r $server_ip -u root -p calvin set iDRAC.Users.2.Enable 1
    
    # Configure BIOS for CI workloads
    racadm -r $server_ip -u $ADMIN_USER -p $ADMIN_PASS set BIOS.SysProfileSettings.SysProfile PerfOptimized
    racadm -r $server_ip -u $ADMIN_USER -p $ADMIN_PASS set BIOS.ProcSettings.LogicalProc Enabled
    racadm -r $server_ip -u $ADMIN_USER -p $ADMIN_PASS set BIOS.ProcSettings.Virtualization Enabled
    
    echo "Server $server_ip configured successfully"
}

# Main execution
while IFS=',' read -r ip role; do
    configure_server "$ip" "$role"
done < "$SERVER_LIST"

echo "All servers configured. Rebooting for BIOS changes to take effect."
```

#### 2.2 Network Infrastructure Setup

**Network Switch Configuration**
```bash
# Dell OS10 Switch Configuration Script
# Execute on each Dell networking switch

# Basic system configuration
configure terminal
hostname ci-switch-01
username admin password [SECURE_PASSWORD] role sysadmin priv-lvl 15

# Management interface
interface mgmt 1/1/1
  ip address 10.1.100.10/24
  no shutdown

# VLAN configuration
vlan 100
  name "Management"
vlan 200  
  name "CI-Control"
vlan 300
  name "CI-Data"  
vlan 400
  name "Storage"

# Trunk ports for server connections
interface range ethernet 1/1/1-1/1/24
  description "PowerEdge Server Connections"
  switchport mode trunk
  switchport trunk allowed vlan 100,200,300,400
  spanning-tree port type edge-port
  spanning-tree bpduguard enable
  no shutdown

# Access ports for management devices
interface range ethernet 1/1/25-1/1/32
  description "Management Device Access"
  switchport mode access
  switchport access vlan 100
  no shutdown

# Inter-switch links (if applicable)
interface range ethernet 1/1/49-1/1/52
  description "Inter-switch Links"
  switchport mode trunk
  switchport trunk allowed vlan all
  channel-group 1 mode active
  no shutdown

# Save configuration
copy running-config startup-config
```

**Network Validation Script**
```bash
#!/bin/bash
# Network connectivity validation

# Test connectivity to all management interfaces
echo "Testing Management Network Connectivity..."
for ip in $(seq 101 120); do
    if ping -c 2 10.1.100.$ip >/dev/null 2>&1; then
        echo "✓ 10.1.100.$ip - Reachable"
    else
        echo "✗ 10.1.100.$ip - Not Reachable"
    fi
done

# Test VLAN connectivity
echo -e "\nTesting VLAN Connectivity..."
vlans=("10.1.200.1" "10.1.300.1" "10.1.400.1")
vlan_names=("CI-Control" "CI-Data" "Storage")

for i in "${!vlans[@]}"; do
    if ping -c 2 "${vlans[$i]}" >/dev/null 2>&1; then
        echo "✓ ${vlan_names[$i]} (${vlans[$i]}) - Reachable"
    else
        echo "✗ ${vlan_names[$i]} (${vlans[$i]}) - Not Reachable"
    fi
done

# Test DNS resolution
echo -e "\nTesting DNS Resolution..."
dns_entries=("ci.company.com" "jenkins.company.com" "gitlab.company.com")
for dns in "${dns_entries[@]}"; do
    if nslookup "$dns" >/dev/null 2>&1; then
        echo "✓ $dns - Resolves"
    else
        echo "✗ $dns - Does not resolve"
    fi
done
```

### Phase 3: Software Platform Deployment (Week 5-6)

#### 3.1 Operating System Installation

**Automated OS Deployment with PXE**
```yaml
# Kickstart configuration for RHEL 8
# /var/lib/tftpboot/pxelinux.cfg/default

DEFAULT local
TIMEOUT 100
PROMPT 1

LABEL rhel8-ci
  MENU LABEL RHEL 8 CI Infrastructure
  KERNEL rhel8/vmlinuz
  APPEND initrd=rhel8/initrd.img inst.ks=http://10.1.100.50/kickstart/rhel8-ci.cfg

# Kickstart file content
# /var/www/html/kickstart/rhel8-ci.cfg
install
url --url="http://10.1.100.50/rhel8"
lang en_US.UTF-8
keyboard us
timezone America/New_York --isUtc
rootpw --iscrypted [ENCRYPTED_PASSWORD_HASH]

# Create ci-admin user
user --name=ci-admin --groups=wheel --password=[ENCRYPTED_PASSWORD_HASH] --iscrypted

# Partitioning
clearpart --all --initlabel
part /boot --fstype=xfs --size=1024
part pv.01 --size=1 --grow
volgroup vg_root pv.01
logvol / --fstype=xfs --name=lv_root --vgname=vg_root --size=50000
logvol /var --fstype=xfs --name=lv_var --vgname=vg_root --size=20000
logvol /var/log --fstype=xfs --name=lv_log --vgname=vg_root --size=10000
logvol /tmp --fstype=xfs --name=lv_tmp --vgname=vg_root --size=5000
logvol swap --name=lv_swap --vgname=vg_root --size=16000

# Network configuration
network --bootproto=dhcp --device=eno1 --onboot=yes --noipv6
network --bootproto=static --device=eno2 --ip=10.1.200.%HOSTIP% --netmask=255.255.255.0 --gateway=10.1.200.1 --nameserver=10.1.100.10 --onboot=yes --noipv6

# Security configuration
firewall --enabled --ssh
selinux --enforcing
services --enabled=chronyd,sshd

# Package selection
%packages
@base
@development
docker-ce
kubernetes-kubeadm
kubernetes-kubelet  
kubernetes-kubectl
ansible
git
vim
wget
curl
%end

# Post-installation script
%post
# Configure SSH keys
mkdir -p /home/ci-admin/.ssh
cat > /home/ci-admin/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAC... ci-admin@deployment-server
EOF
chmod 700 /home/ci-admin/.ssh
chmod 600 /home/ci-admin/.ssh/authorized_keys
chown -R ci-admin:ci-admin /home/ci-admin/.ssh

# Configure sudoers
echo "ci-admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ci-admin

# Install Dell OpenManage Server Administrator
wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash
yum install -y srvadmin-all

# Configure Docker
systemctl enable docker
usermod -aG docker ci-admin

# Configure time synchronization
cat > /etc/chrony.conf << 'EOF'
server ntp1.company.com iburst
server ntp2.company.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
EOF

systemctl enable chronyd
%end

reboot
```

#### 3.2 Dell OpenManage Enterprise Installation

**OME Appliance Deployment**
```bash
#!/bin/bash
# OpenManage Enterprise Deployment Script

# Variables
OME_OVA="Dell-OpenManage-Enterprise-3.8.1.ova"
VCENTER_SERVER="vcenter.company.com"
DATACENTER="Primary-DC"
CLUSTER="CI-Cluster"
DATASTORE="ci-storage"
NETWORK="Management-VLAN-100"

# Deploy OME appliance
echo "Deploying OpenManage Enterprise appliance..."
ovftool \
    --name="OpenManage-Enterprise" \
    --datastore="$DATASTORE" \
    --network="$NETWORK" \
    --diskMode=thin \
    --powerOn \
    --prop:vami.ip0.OME=10.1.100.20 \
    --prop:vami.netmask0.OME=255.255.255.0 \
    --prop:vami.gateway.OME=10.1.100.1 \
    --prop:vami.DNS.OME=10.1.100.10 \
    --prop:vami.domain.OME=company.com \
    --prop:vami.searchpath.OME=company.com \
    "$OME_OVA" \
    "vi://administrator@vsphere.local@$VCENTER_SERVER/$DATACENTER/host/$CLUSTER"

echo "OME deployment initiated. Waiting for appliance to boot..."
sleep 300

# Verify OME accessibility
echo "Verifying OME accessibility..."
timeout=600
while [ $timeout -gt 0 ]; do
    if curl -k -s https://10.1.100.20 > /dev/null; then
        echo "OME appliance is accessible!"
        break
    fi
    sleep 30
    timeout=$((timeout - 30))
done

if [ $timeout -eq 0 ]; then
    echo "ERROR: OME appliance is not accessible after 10 minutes"
    exit 1
fi

echo "OpenManage Enterprise deployment completed successfully!"
```

**Initial OME Configuration**
```bash
#!/bin/bash
# OME Initial Configuration Script

OME_IP="10.1.100.20"
OME_USER="admin"
OME_PASS="[SECURE_PASSWORD]"

# Get authentication token
get_token() {
    curl -k -X POST https://$OME_IP/api/SessionService/Sessions \
        -H "Content-Type: application/json" \
        -d "{\"UserName\":\"$OME_USER\",\"Password\":\"$OME_PASS\",\"SessionType\":\"API\"}" \
        | jq -r '.["@odata.id"]' | cut -d'/' -f5
}

TOKEN=$(get_token)
echo "Authenticated with OME. Token: $TOKEN"

# Configure discovery settings
echo "Configuring discovery settings..."
curl -k -X POST https://$OME_IP/api/DiscoveryConfigService/DiscoveryConfigGroups \
    -H "X-Auth-Token: $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "DiscoveryConfigGroupName": "PowerEdge-CI-Servers",
        "DiscoveryConfigGroupDescription": "CI Infrastructure Servers",
        "DiscoveryConfigModels": [{
            "DiscoveryConfigTargets": [{
                "NetworkAddressDetail": "10.1.100.101-10.1.100.120"
            }],
            "ConnectionProfile": "iDRAC",
            "DeviceType": [1000]
        }],
        "CreateGroup": true,
        "TrapDestination": true
    }'

# Create device groups
echo "Creating device groups..."
curl -k -X POST https://$OME_IP/api/GroupService/Groups \
    -H "X-Auth-Token: $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "GroupModel": {
            "Name": "CI-Primary-Nodes",
            "Description": "Primary CI/CD processing nodes",
            "ParentId": 0
        }
    }'

curl -k -X POST https://$OME_IP/api/GroupService/Groups \
    -H "X-Auth-Token: $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "GroupModel": {
            "Name": "CI-Build-Agents", 
            "Description": "Container build agents",
            "ParentId": 0
        }
    }'

echo "OME initial configuration completed!"
```

#### 3.3 Container Platform Installation

**Kubernetes Cluster Installation**
```bash
#!/bin/bash
# Kubernetes cluster installation script

# Variables
MASTER_NODES=("10.1.200.101" "10.1.200.102" "10.1.200.103")
WORKER_NODES=("10.1.200.111" "10.1.200.112" "10.1.200.113" "10.1.200.114" "10.1.200.115" "10.1.200.116")
K8S_VERSION="1.28.2"
POD_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"

# Function to install Kubernetes on all nodes
install_kubernetes() {
    local node_ip=$1
    echo "Installing Kubernetes on $node_ip..."
    
    ssh ci-admin@$node_ip << 'EOSSH'
        # Disable swap
        sudo swapoff -a
        sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
        
        # Load kernel modules
        cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
        
        cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
        sudo sysctl --system
        
        # Install container runtime (containerd)
        sudo yum install -y containerd.io
        sudo mkdir -p /etc/containerd
        containerd config default | sudo tee /etc/containerd/config.toml
        sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
        sudo systemctl enable --now containerd
        
        # Install kubeadm, kubelet, kubectl
        cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
        
        sudo yum install -y kubelet-$K8S_VERSION kubeadm-$K8S_VERSION kubectl-$K8S_VERSION --disableexcludes=kubernetes
        sudo systemctl enable --now kubelet
        
        echo "Kubernetes components installed on $node_ip"
EOSSH
}

# Install Kubernetes on all nodes
for node in "${MASTER_NODES[@]}" "${WORKER_NODES[@]}"; do
    install_kubernetes "$node"
done

# Initialize first master node
echo "Initializing Kubernetes cluster..."
ssh ci-admin@${MASTER_NODES[0]} << EOSSH
    sudo kubeadm init \
        --control-plane-endpoint="10.1.200.100" \
        --upload-certs \
        --pod-network-cidr=$POD_CIDR \
        --service-cidr=$SERVICE_CIDR \
        --kubernetes-version=$K8S_VERSION
    
    # Configure kubectl for admin user
    mkdir -p \$HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
    sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config
    
    # Generate join tokens
    kubeadm token create --print-join-command > /tmp/worker-join.sh
    kubeadm init phase upload-certs --upload-certs > /tmp/cert-key.txt
    CERT_KEY=\$(tail -1 /tmp/cert-key.txt)
    kubeadm token create --print-join-command --certificate-key \$CERT_KEY > /tmp/master-join.sh
EOSSH

# Get join commands
scp ci-admin@${MASTER_NODES[0]}:/tmp/master-join.sh ./
scp ci-admin@${MASTER_NODES[0]}:/tmp/worker-join.sh ./

# Join additional master nodes
for master in "${MASTER_NODES[@]:1}"; do
    echo "Joining master node $master to cluster..."
    scp ./master-join.sh ci-admin@$master:/tmp/
    ssh ci-admin@$master "sudo bash /tmp/master-join.sh"
done

# Join worker nodes
for worker in "${WORKER_NODES[@]}"; do
    echo "Joining worker node $worker to cluster..."
    scp ./worker-join.sh ci-admin@$worker:/tmp/
    ssh ci-admin@$worker "sudo bash /tmp/worker-join.sh"
done

# Install CNI (Calico)
echo "Installing Calico CNI..."
ssh ci-admin@${MASTER_NODES[0]} << 'EOSSH'
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
    
    # Wait for all nodes to be ready
    echo "Waiting for all nodes to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Verify cluster status
    kubectl get nodes -o wide
    kubectl get pods -A
EOSSH

echo "Kubernetes cluster installation completed!"
```

### Phase 4: CI/CD Tool Installation (Week 7-8)

#### 4.1 Jenkins Installation and Configuration

**Jenkins Controller Installation**
```bash
#!/bin/bash
# Jenkins installation on PowerEdge R750

JENKINS_SERVER="10.1.200.101"
JENKINS_HOME="/var/lib/jenkins"
JENKINS_USER="jenkins"
JAVA_OPTS="-Xmx16g -Xms8g -XX:+UseG1GC -XX:G1HeapRegionSize=32m"

ssh ci-admin@$JENKINS_SERVER << EOSSH
    # Install Java 11
    sudo yum install -y java-11-openjdk java-11-openjdk-devel
    
    # Add Jenkins repository
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    
    # Install Jenkins
    sudo yum install -y jenkins
    
    # Configure Jenkins
    sudo mkdir -p $JENKINS_HOME
    sudo chown $JENKINS_USER:$JENKINS_USER $JENKINS_HOME
    
    # Set Java options
    sudo tee /etc/sysconfig/jenkins << EOF
JENKINS_HOME="$JENKINS_HOME"
JENKINS_JAVA_CMD="/usr/bin/java"
JENKINS_JAVA_OPTIONS="$JAVA_OPTS"
JENKINS_PORT="8080"
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"
JENKINS_HANDLER_IDLE="20"
JENKINS_ARGS=""
EOF
    
    # Start and enable Jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    
    # Wait for Jenkins to start
    sleep 60
    
    # Get initial admin password
    echo "Jenkins initial admin password:"
    sudo cat $JENKINS_HOME/secrets/initialAdminPassword
EOSSH
```

**Jenkins Configuration as Code (JCasC)**
```yaml
# jenkins.yaml - Jenkins Configuration as Code
jenkins:
  systemMessage: "Dell PowerEdge CI Infrastructure - Jenkins Controller"
  numExecutors: 2
  mode: NORMAL
  
  securityRealm:
    ldap:
      configurations:
        - server: "ldap://ldap.company.com:389"
          rootDN: "dc=company,dc=com"
          inhibitInferRootDN: false
          userSearchBase: "ou=users"
          userSearch: "uid={0}"
          groupSearchBase: "ou=groups"
          groupSearchFilter: "member={0}"
          managerDN: "cn=jenkins,ou=service-accounts,dc=company,dc=com"
          managerPasswordSecret: "${LDAP_MANAGER_PASSWORD}"
          displayNameAttributeName: "displayName"
          mailAddressAttributeName: "mail"
  
  authorizationStrategy:
    projectMatrix:
      permissions:
        - "Overall/Administer:CI-Administrators"
        - "Overall/Read:authenticated"
        - "Job/Build:CI-Developers"
        - "Job/Cancel:CI-Developers"
        - "Job/Read:CI-Developers"

  globalNodeProperties:
    - envVars:
        env:
          - key: "DOCKER_HOST"
            value: "unix:///var/run/docker.sock"
          - key: "KUBECONFIG"
            value: "/var/lib/jenkins/.kube/config"

  nodes:
    - permanent:
        name: "poweredge-agent-01"
        remoteFS: "/home/jenkins"
        labelString: "linux docker maven gradle nodejs python"
        launcher:
          ssh:
            host: "10.1.200.111"
            credentialsId: "jenkins-ssh-key"
            sshHostKeyVerificationStrategy: "nonVerifyingKeyVerificationStrategy"

tool:
  maven:
    installations:
      - name: "Maven-3.8"
        properties:
          - installSource:
              installers:
                - maven:
                    id: "3.8.6"
  
  gradle:
    installations:
      - name: "Gradle-7"
        properties:
          - installSource:
              installers:
                - gradleInstaller:
                    id: "7.5"
  
  nodejs:
    installations:
      - name: "NodeJS-16"
        properties:
          - installSource:
              installers:
                - nodeJSInstaller:
                    id: "16.17.0"

jobs:
  - script: |
      folder('CI-Pipelines') {
          description('CI/CD pipeline jobs')
      }
      
      pipelineJob('CI-Pipelines/sample-java-app') {
          definition {
              cpsScm {
                  scm {
                      git {
                          remote {
                              url('https://github.com/company/sample-java-app.git')
                          }
                          branch('*/main')
                      }
                  }
                  scriptPath('Jenkinsfile')
              }
          }
          triggers {
              scm('H/5 * * * *')
          }
      }

unclassified:
  location:
    url: "https://jenkins.company.com"
    adminAddress: "jenkins-admin@company.com"
  
  prometheus:
    path: "/prometheus"
    useAuthenticatedEndpoint: true
  
  buildMetrics:
    enabled: true
    
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: "github-credentials"
              username: "ci-service-account"
              password: "${GITHUB_TOKEN}"
              description: "GitHub service account"
          
          - basicSSHUserPrivateKey:
              scope: GLOBAL
              id: "jenkins-ssh-key"
              username: "jenkins"
              privateKeySource:
                directEntry:
                  privateKey: "${JENKINS_SSH_PRIVATE_KEY}"
              description: "SSH key for Jenkins agents"
          
          - string:
              scope: GLOBAL
              id: "docker-registry-token"
              secret: "${DOCKER_REGISTRY_TOKEN}"
              description: "Docker registry authentication token"
```

#### 4.2 GitLab Installation

**GitLab Runner Installation on PowerEdge**
```bash
#!/bin/bash
# GitLab Runner installation script

RUNNER_NODES=("10.1.200.111" "10.1.200.112" "10.1.200.113" "10.1.200.114")
GITLAB_URL="https://gitlab.company.com"
REGISTRATION_TOKEN="[RUNNER_REGISTRATION_TOKEN]"

# Function to install GitLab Runner
install_gitlab_runner() {
    local node_ip=$1
    echo "Installing GitLab Runner on $node_ip..."
    
    ssh ci-admin@$node_ip << EOSSH
        # Add GitLab Runner repository
        curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
        
        # Install GitLab Runner
        sudo yum install -y gitlab-runner
        
        # Register runner with Docker executor
        sudo gitlab-runner register \
            --non-interactive \
            --url "$GITLAB_URL" \
            --registration-token "$REGISTRATION_TOKEN" \
            --executor "docker" \
            --docker-image "ubuntu:20.04" \
            --description "poweredge-docker-runner-$node_ip" \
            --tag-list "docker,linux,poweredge" \
            --run-untagged="true" \
            --locked="false" \
            --docker-privileged="true" \
            --docker-volumes "/cache" \
            --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
        
        # Configure concurrent builds
        sudo sed -i 's/concurrent = 1/concurrent = 4/' /etc/gitlab-runner/config.toml
        
        # Start and enable GitLab Runner
        sudo systemctl enable gitlab-runner
        sudo systemctl start gitlab-runner
        
        echo "GitLab Runner installed and configured on $node_ip"
EOSSH
}

# Install GitLab Runner on all nodes
for node in "${RUNNER_NODES[@]}"; do
    install_gitlab_runner "$node"
done

echo "GitLab Runner installation completed on all nodes!"
```

### Phase 5: Storage Configuration (Week 8)

#### 5.1 Dell Unity Storage Setup

**Unity Storage Configuration Script**
```bash
#!/bin/bash
# Dell Unity XT storage configuration

UNITY_IP="10.1.100.30"
UNITY_USER="admin"
UNITY_PASS="[SECURE_PASSWORD]"
UNISPHERE_CLI="/opt/dell/unity/bin/uemcli"

# Configure storage pools
echo "Configuring storage pools..."
$UNISPHERE_CLI -d $UNITY_IP -u $UNITY_USER -p $UNITY_PASS \
    /stor/config/pool create \
    -name "ci-fast-pool" \
    -descr "High-performance storage for CI workloads" \
    -type "Dynamic" \
    -diskGroup "dg_15k_sas_01" \
    -alertThresholds "60,70,80,90" \
    -poolSpaceHarvestHighThreshold "95" \
    -poolSpaceHarvestLowThreshold "85"

$UNISPHERE_CLI -d $UNITY_IP -u $UNITY_USER -p $UNITY_PASS \
    /stor/config/pool create \
    -name "ci-capacity-pool" \
    -descr "Large capacity storage for artifacts" \
    -type "Dynamic" \
    -diskGroup "dg_nl_sas_01" \
    -alertThresholds "70,80,85,90"

# Create file systems for NFS shares
echo "Creating NFS file systems..."
$UNISPHERE_CLI -d $UNITY_IP -u $UNITY_USER -p $UNITY_PASS \
    /stor/prov/fs create \
    -name "ci-shared-storage" \
    -pool "pool_1" \
    -nasServer "nas_1" \
    -size "10T" \
    -proto "NFS" \
    -multiProto "true" \
    -descr "Shared storage for CI infrastructure"

$UNISPHERE_CLI -d $UNITY_IP -u $UNITY_USER -p $UNITY_PASS \
    /stor/prov/fs create \
    -name "ci-build-cache" \
    -pool "pool_1" \
    -nasServer "nas_1" \
    -size "5T" \
    -proto "NFS" \
    -multiProto "true" \
    -descr "Build cache and temporary storage"

# Configure NFS exports
echo "Configuring NFS exports..."
$UNISPHERE_CLI -d $UNITY_IP -u $UNITY_USER -p $UNITY_PASS \
    /stor/prov/fs/nfs create \
    -path "/ci-shared" \
    -fs "fs_1" \
    -host "10.1.200.0/24" \
    -access "RW" \
    -rootAccess "Root" \
    -noAccessHosts ""

$UNISPHERE_CLI -d $UNITY_IP -u $UNITY_USER -p $UNITY_PASS \
    /stor/prov/fs/nfs create \
    -path "/ci-cache" \
    -fs "fs_2" \
    -host "10.1.200.0/24" \
    -access "RW" \
    -rootAccess "Root"

echo "Dell Unity storage configuration completed!"
```

#### 5.2 Kubernetes Storage Integration

**Dell CSI Driver Installation**
```yaml
# dell-unity-csi-driver.yaml
apiVersion: v1
kind: Secret
metadata:
  name: unity-creds
  namespace: unity
type: Opaque
data:
  config.yaml: |
    storageArrayList:
      - storageArrayId: "Unity-XT-480F-001"
        managementHttps: true
        managementIP: "10.1.100.30"
        managementPort: 443
        username: "admin"
        password: "[BASE64_ENCODED_PASSWORD]"
        skipCertificateValidation: true
        insecure: true
        isDefault: true
        
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: unity-nfs
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi-unity.dellemc.com
reclaimPolicy: Delete
allowVolumeExpansion: true
parameters:
  storagePool: "ci-fast-pool"
  thinProvisioned: "true"
  protocol: "NFS"
  nasServer: "nas_1"
  
---
apiVersion: storage.k8s.io/v1
kind: StorageClass  
metadata:
  name: unity-iscsi
provisioner: csi-unity.dellemc.com
reclaimPolicy: Delete
allowVolumeExpansion: true
parameters:
  storagePool: "ci-fast-pool"
  thinProvisioned: "true"
  protocol: "iSCSI"
  arrayId: "Unity-XT-480F-001"
```

**Persistent Volume Claims for CI Workloads**
```yaml
# ci-storage-claims.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-home
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: unity-nfs
  resources:
    requests:
      storage: 100Gi
      
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gitlab-data
  namespace: gitlab  
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: unity-nfs
  resources:
    requests:
      storage: 500Gi
      
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: build-cache
  namespace: ci-shared
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: unity-nfs
  resources:
    requests:
      storage: 1Ti
```

### Phase 6: Monitoring and Observability (Week 9)

#### 6.1 Prometheus and Grafana Installation

**Prometheus Installation via Helm**
```bash
#!/bin/bash
# Prometheus and Grafana installation

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus Operator
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=unity-nfs \
    --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce \
    --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=100Gi \
    --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.storageClassName=unity-nfs \
    --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce \
    --set alertmanager.alertmanagerSpec.storage.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
    --set grafana.persistence.enabled=true \
    --set grafana.persistence.storageClassName=unity-nfs \
    --set grafana.persistence.size=20Gi

# Configure Grafana with Dell PowerEdge dashboards
kubectl create configmap dell-poweredge-dashboard \
    --from-file=dell-poweredge-dashboard.json \
    --namespace monitoring

# Label configmap for Grafana discovery
kubectl label configmap dell-poweredge-dashboard \
    grafana_dashboard=1 \
    --namespace monitoring
```

#### 6.2 ELK Stack Installation

**Elasticsearch, Logstash, Kibana Installation**
```yaml
# elk-stack.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: logging
  
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: logging
spec:
  serviceName: "elasticsearch"
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
        ports:
        - containerPort: 9200
          name: rest
          protocol: TCP
        - containerPort: 9300
          name: inter-node
          protocol: TCP
        volumeMounts:
        - name: data
          mountPath: /usr/share/elasticsearch/data
        env:
        - name: cluster.name
          value: ci-logs
        - name: node.name
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: discovery.seed_hosts
          value: "elasticsearch-0.elasticsearch,elasticsearch-1.elasticsearch,elasticsearch-2.elasticsearch"
        - name: cluster.initial_master_nodes
          value: "elasticsearch-0,elasticsearch-1,elasticsearch-2"
        - name: ES_JAVA_OPTS
          value: "-Xms2g -Xmx2g"
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: unity-nfs
      resources:
        requests:
          storage: 200Gi
```

### Phase 7: Security Hardening (Week 10)

#### 7.1 Security Configuration

**System Security Hardening Script**
```bash
#!/bin/bash
# Security hardening for PowerEdge CI infrastructure

NODES=("10.1.200.101" "10.1.200.102" "10.1.200.103" "10.1.200.111" "10.1.200.112" "10.1.200.113" "10.1.200.114" "10.1.200.115" "10.1.200.116")

harden_node() {
    local node_ip=$1
    echo "Hardening security on $node_ip..."
    
    ssh ci-admin@$node_ip << 'EOSSH'
        # Update all packages
        sudo yum update -y
        
        # Configure firewall
        sudo systemctl enable firewalld
        sudo systemctl start firewalld
        
        # Allow specific services
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --permanent --add-port=6443/tcp  # Kubernetes API
        sudo firewall-cmd --permanent --add-port=10250/tcp # Kubelet
        sudo firewall-cmd --permanent --add-port=8080/tcp  # Jenkins
        sudo firewall-cmd --reload
        
        # Configure SSH security
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
        sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
        sudo systemctl restart sshd
        
        # Install and configure fail2ban
        sudo yum install -y epel-release
        sudo yum install -y fail2ban
        
        sudo tee /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = 22
logpath = /var/log/secure
EOF
        
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        
        # Configure audit daemon
        sudo systemctl enable auditd
        sudo systemctl start auditd
        
        # Set file permissions
        sudo chmod 700 /root
        sudo chmod 600 /etc/ssh/sshd_config
        
        # Disable unnecessary services
        sudo systemctl disable cups
        sudo systemctl disable avahi-daemon
        
        echo "Security hardening completed on $node_ip"
EOSSH
}

# Harden all nodes
for node in "${NODES[@]}"; do
    harden_node "$node"
done

echo "Security hardening completed on all nodes!"
```

#### 7.2 SSL/TLS Certificate Configuration

**SSL Certificate Management**
```bash
#!/bin/bash
# SSL certificate configuration script

CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CA_CERT="company-ca.crt"
CERT_DOMAINS=("jenkins.company.com" "gitlab.company.com" "monitoring.company.com")

# Generate certificate signing requests
for domain in "${CERT_DOMAINS[@]}"; do
    echo "Generating certificate for $domain..."
    
    # Create private key
    openssl genrsa -out "$KEY_DIR/$domain.key" 2048
    
    # Create certificate signing request
    openssl req -new -key "$KEY_DIR/$domain.key" -out "/tmp/$domain.csr" \
        -subj "/C=US/ST=State/L=City/O=Company/OU=IT/CN=$domain"
    
    # Generate certificate (replace with your CA process)
    openssl x509 -req -in "/tmp/$domain.csr" -CA "$CERT_DIR/$CA_CERT" \
        -CAkey "$KEY_DIR/company-ca.key" -CAcreateserial \
        -out "$CERT_DIR/$domain.crt" -days 365 -sha256
    
    # Set proper permissions
    chmod 644 "$CERT_DIR/$domain.crt"
    chmod 600 "$KEY_DIR/$domain.key"
    
    echo "Certificate generated for $domain"
done

echo "SSL certificate configuration completed!"
```

## Validation and Testing

### System Validation Checklist

```bash
#!/bin/bash
# Comprehensive system validation script

echo "=== Dell PowerEdge CI Infrastructure Validation ==="

# Hardware validation
echo "1. Hardware Validation:"
echo "   - PowerEdge servers accessible via iDRAC: $(ping -c 1 10.1.100.101 >/dev/null && echo "✓" || echo "✗")"
echo "   - OpenManage Enterprise accessible: $(curl -k -s https://10.1.100.20 >/dev/null && echo "✓" || echo "✗")"
echo "   - Network connectivity verified: $(ping -c 1 10.1.200.1 >/dev/null && echo "✓" || echo "✗")"

# Software platform validation  
echo "2. Software Platform Validation:"
echo "   - All servers running latest OS: $(ansible all -i inventory/hosts -m command -a 'uname -r' | grep -c 'SUCCESS')/$(wc -l < inventory/hosts) servers"
echo "   - Docker installed and running: $(ansible all -i inventory/hosts -m systemd -a 'name=docker state=started' | grep -c 'SUCCESS')"
echo "   - Kubernetes cluster healthy: $(kubectl get nodes | grep -c Ready) nodes ready"

# CI/CD tools validation
echo "3. CI/CD Tools Validation:"
echo "   - Jenkins accessible: $(curl -s http://jenkins.company.com:8080 >/dev/null && echo "✓" || echo "✗")"
echo "   - GitLab runners registered: $(gitlab-runner list 2>/dev/null | grep -c 'poweredge')"
echo "   - Container registry accessible: $(docker login registry.company.com >/dev/null 2>&1 && echo "✓" || echo "✗")"

# Storage validation
echo "4. Storage Validation:"
echo "   - Dell Unity storage accessible: $(ping -c 1 10.1.100.30 >/dev/null && echo "✓" || echo "✗")"
echo "   - NFS mounts functional: $(ls /mnt/ci-shared >/dev/null 2>&1 && echo "✓" || echo "✗")"
echo "   - Kubernetes storage classes available: $(kubectl get sc | grep -c unity)"

# Monitoring validation
echo "5. Monitoring Validation:"
echo "   - Prometheus collecting metrics: $(curl -s http://prometheus.company.com:9090/-/healthy >/dev/null && echo "✓" || echo "✗")"
echo "   - Grafana dashboards accessible: $(curl -s http://grafana.company.com:3000 >/dev/null && echo "✓" || echo "✗")"
echo "   - Alert manager configured: $(curl -s http://alertmanager.company.com:9093/-/healthy >/dev/null && echo "✓" || echo "✗")"

# Security validation
echo "6. Security Validation:"
echo "   - SSL certificates valid: $(echo | openssl s_client -connect jenkins.company.com:443 2>/dev/null | grep -c 'Verify return code: 0')"
echo "   - Firewall rules active: $(ansible all -i inventory/hosts -m systemd -a 'name=firewalld' | grep -c 'active')"
echo "   - User authentication working: $(ldapsearch -x -H ldap://ldap.company.com -b 'dc=company,dc=com' >/dev/null 2>&1 && echo "✓" || echo "✗")"

echo "=== Validation Complete ==="
```

### Performance Testing

```bash
#!/bin/bash
# Performance testing script

echo "=== Performance Testing ==="

# Build performance test
echo "1. Build Performance Test:"
git clone https://github.com/company/sample-java-app.git /tmp/test-app
cd /tmp/test-app

START_TIME=$(date +%s)
mvn clean package -DskipTests
END_TIME=$(date +%s)
BUILD_TIME=$((END_TIME - START_TIME))

echo "   - Maven build time: ${BUILD_TIME}s (Target: <900s)"

# Container build test
echo "2. Container Build Test:"
START_TIME=$(date +%s)
docker build -t test-app:latest .
END_TIME=$(date +%s)
DOCKER_BUILD_TIME=$((END_TIME - START_TIME))

echo "   - Docker build time: ${DOCKER_BUILD_TIME}s (Target: <300s)"

# Kubernetes deployment test
echo "3. Kubernetes Deployment Test:"
kubectl create deployment test-app --image=test-app:latest
kubectl wait --for=condition=available --timeout=300s deployment/test-app
kubectl scale deployment test-app --replicas=10
kubectl wait --for=condition=available --timeout=300s deployment/test-app

echo "   - Kubernetes scaling completed successfully"

# Storage performance test
echo "4. Storage Performance Test:"
fio --name=randwrite --ioengine=libaio --iodepth=16 --rw=randwrite \
    --bs=4k --direct=0 --size=1G --numjobs=4 --runtime=60 \
    --filename=/mnt/ci-shared/test-file --group_reporting

echo "=== Performance Testing Complete ==="
```

## Go-Live Procedures

### Production Cutover Checklist

- [ ] **Pre-Cutover Validation**
  - [ ] All systems pass health checks
  - [ ] Performance benchmarks met
  - [ ] Security scans completed
  - [ ] Backup and recovery tested
  - [ ] Rollback procedures validated

- [ ] **Cutover Execution**
  - [ ] DNS records updated to point to new infrastructure
  - [ ] SSL certificates installed and validated
  - [ ] User access permissions migrated
  - [ ] CI/CD pipelines migrated and tested
  - [ ] Monitoring and alerting activated

- [ ] **Post-Cutover Validation**
  - [ ] All applications functional
  - [ ] Performance monitoring active
  - [ ] User acceptance testing completed
  - [ ] Support team trained and available
  - [ ] Documentation updated and accessible

### Support Transition

**Level 1 Support Handover**
- [ ] Operations runbook reviewed and accepted
- [ ] Monitoring dashboards configured
- [ ] Alert escalation procedures documented
- [ ] Standard troubleshooting procedures trained
- [ ] Access credentials and tools provided

**Level 2 Support Handover**  
- [ ] Technical architecture documentation reviewed
- [ ] Advanced troubleshooting procedures trained
- [ ] Configuration management procedures documented
- [ ] Escalation contacts and procedures established
- [ ] Change management processes defined

## Implementation Success Criteria

### Technical Success Metrics
- **Build Performance**: Average build time < 15 minutes
- **System Availability**: 99.9% uptime (measured monthly)
- **Deployment Frequency**: Support for multiple deployments per day
- **Recovery Time**: System recovery < 30 minutes for any component failure
- **Resource Utilization**: Average compute utilization 70-85%

### Business Success Metrics
- **Developer Productivity**: 40% improvement in development velocity
- **Time to Market**: 50% reduction in feature delivery time
- **Operational Efficiency**: 60% reduction in manual operational tasks
- **Infrastructure TCO**: 30% reduction in total cost of ownership over 3 years

## Post-Implementation Activities

### Ongoing Optimization
- Monthly performance reviews and optimization recommendations
- Quarterly capacity planning and scaling assessments  
- Semi-annual security audits and compliance reviews
- Annual architecture reviews and technology updates

### Documentation Maintenance
- Weekly updates to operational procedures based on lessons learned
- Monthly review and update of troubleshooting guides
- Quarterly review of all technical documentation
- Annual comprehensive documentation audit and refresh

---

**Document Version**: 1.0  
**Implementation Timeframe**: 10 weeks  
**Next Review Date**: 30 days post-implementation  
**Owner**: Dell Professional Services Implementation Team
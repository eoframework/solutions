# Cisco Hybrid Infrastructure Implementation Guide

## Overview

This comprehensive implementation guide provides step-by-step procedures for deploying a Cisco Hybrid Cloud Infrastructure solution. The guide covers the complete deployment lifecycle from pre-installation planning through production go-live.

## Table of Contents

1. [Pre-Implementation Planning](#pre-implementation-planning)
2. [Hardware Installation](#hardware-installation)
3. [Network Configuration](#network-configuration)
4. [HyperFlex Deployment](#hyperflex-deployment)
5. [ACI Configuration](#aci-configuration)
6. [Intersight Integration](#intersight-integration)
7. [VMware Integration](#vmware-integration)
8. [Security Configuration](#security-configuration)
9. [Monitoring Setup](#monitoring-setup)
10. [Testing and Validation](#testing-and-validation)
11. [Production Cutover](#production-cutover)

## Pre-Implementation Planning

### 1.1 Requirements Validation

**Prerequisites Checklist:**
- [ ] Site survey completed and approved
- [ ] Network design validated and approved
- [ ] Power and cooling requirements confirmed
- [ ] Rack space and cable management planned
- [ ] IP addressing scheme documented
- [ ] VLAN assignments confirmed
- [ ] Security policies defined
- [ ] Change management approvals obtained

**Resource Requirements:**
- Implementation team: 3-4 engineers
- Customer resources: 2-3 technical staff
- Timeline: 12-16 weeks
- Maintenance windows: 4-6 scheduled outages

### 1.2 Project Initialization

```bash
# Create project directory structure
mkdir -p /opt/cisco-hybrid-deployment/{logs,configs,scripts,docs}

# Set up logging
export DEPLOYMENT_LOG="/opt/cisco-hybrid-deployment/logs/deployment.log"
echo "$(date): Deployment started" >> $DEPLOYMENT_LOG
```

### 1.3 Tool Preparation

**Required Software:**
- Cisco HyperFlex Connect 4.5+
- VMware vCenter 7.0+
- Cisco APIC 5.2+
- Intersight account with appropriate licenses
- Network monitoring tools (PRTG, SolarWinds, etc.)

## Hardware Installation

### 2.1 Cisco UCS Hardware Deployment

**Installation Steps:**

1. **Rack and Stack Equipment**
   ```bash
   # Verify hardware placement
   # - UCS Fabric Interconnects in separate power zones
   # - HyperFlex nodes distributed across racks
   # - Proper cable management and labeling
   ```

2. **Initial UCS Configuration**
   ```bash
   # Connect to Fabric Interconnect A
   ssh admin@<FI-A-MGMT-IP>
   
   # Initial setup wizard
   configure
   set system name UCS-FI-A-<SITE>
   set system virtual-ip <UCS-VIP>
   commit-buffer
   ```

3. **Cable Connectivity Verification**
   ```bash
   # Verify fabric interconnect connectivity
   show fabric-interconnect
   show interface brief
   
   # Check discovery status
   show server status
   show chassis status
   ```

### 2.2 Network Switch Configuration

**Access Switch Configuration:**
```cisco
! Basic configuration template
hostname ACCESS-SW-<LOCATION>
!
! Management interface
interface GigabitEthernet0/0
 ip address <MGMT-IP> <NETMASK>
 no shutdown
!
! Trunk configuration for HyperFlex
interface range GigabitEthernet1/0/1-4
 switchport mode trunk
 switchport trunk allowed vlan 100,101,102,200-202
 spanning-tree portfast trunk
 no shutdown
!
! VLAN configuration
vlan 100
 name Management
vlan 101
 name vMotion
vlan 102
 name Storage
vlan 200
 name Production-Web
vlan 201
 name Production-App
vlan 202
 name Production-DB
```

## HyperFlex Deployment

### 3.1 HyperFlex Cluster Installation

**Step 1: HyperFlex Connect Setup**

```bash
# Download and launch HyperFlex Connect
wget https://software.cisco.com/download/hyperflex-connect
chmod +x hyperflex-connect
./hyperflex-connect

# Launch web interface
# Navigate to https://localhost:9443
```

**Step 2: Cluster Configuration**

1. **Node Discovery and Validation**
   - Access HyperFlex Connect web interface
   - Navigate to "New Cluster" wizard
   - Discover HyperFlex nodes
   - Validate hardware compatibility

2. **Network Configuration**
   ```yaml
   # Network settings for HyperFlex cluster
   management_network:
     subnet: "192.168.100.0/24"
     gateway: "192.168.100.1"
     dns_servers: ["8.8.8.8", "8.8.4.4"]
     ntp_servers: ["pool.ntp.org"]
     
   data_network:
     vlan_range: "200-299"
     mtu: 9000
     
   storage_network:
     vlan: 102
     mtu: 9000
     jumbo_frames: enabled
   ```

3. **Storage Configuration**
   ```yaml
   storage_policy:
     data_replication_factor: 3
     compression: enabled
     deduplication: enabled
     encryption: enabled
     cache_size: "auto"
   ```

**Step 3: Cluster Deployment**

```bash
# Monitor deployment progress
tail -f /var/log/springpath/hxcli.log

# Verify cluster status after deployment
hxcli cluster info
hxcli datastore list
hxcli node list
```

### 3.2 Post-Installation Validation

```bash
# Health check commands
hxcli cluster storage-summary
hxcli cluster network-test
hxcli cluster upgrade-status

# Performance baseline
hxcli cluster iostat
hxcli node iostat --node-ip <NODE-IP>
```

## ACI Configuration

### 4.1 APIC Initial Setup

**Initial Configuration:**

```bash
# Connect to APIC
ssh admin@<APIC-IP>

# Basic system configuration
configure
set system name APIC-<SITE>
set system domain <DOMAIN-NAME>
set system dns-servers <DNS1> <DNS2>
set system ntp-servers <NTP-SERVER>
commit
```

### 4.2 Fabric Discovery and Configuration

**Fabric Initialization:**

1. **Switch Discovery**
   ```bash
   # Verify fabric switch discovery
   show fabric topology
   show fabric membership
   
   # Configure switch roles
   configure
   set fabric switch <SWITCH-ID> role spine
   set fabric switch <SWITCH-ID> role leaf
   commit
   ```

2. **Interface Configuration**
   ```bash
   # Configure leaf switch interfaces
   configure
   set interface ethernet 1/1 description "HyperFlex-Node-1"
   set interface ethernet 1/1 mode access
   set interface ethernet 1/1 access-vlan <VLAN-ID>
   commit
   ```

### 4.3 Tenant and Application Configuration

**Tenant Creation:**

```python
# Python ACI SDK example for tenant configuration
from cobra.mit.access import MoDirectory
from cobra.mit.session import LoginSession
from cobra.model.fv import Tenant, Ctx, BD, Ap, AEPg
from cobra.model.fv import RsBd, RsCtx

# APIC login
session = LoginSession('https://<APIC-IP>', '<USERNAME>', '<PASSWORD>')
moDir = MoDirectory(session)
moDir.login()

# Create tenant
uniMo = moDir.lookupByDn('uni')
tenant = Tenant(uniMo, name='<TENANT-NAME>')

# Create VRF
vrf = Ctx(tenant, name='Production-VRF')

# Create Bridge Domain
bd = BD(tenant, name='Web-BD')
bdRsCtx = RsCtx(bd, tnFvCtxName='Production-VRF')

# Commit configuration
configRequest = ConfigRequest()
configRequest.addMo(tenant)
moDir.commit(configRequest)
```

## Intersight Integration

### 5.1 Intersight Account Setup

**Account Configuration:**

1. **API Key Generation**
   ```bash
   # Generate API key pair
   openssl genrsa -out intersight_private_key.pem 2048
   openssl rsa -in intersight_private_key.pem -pubout -out intersight_public_key.pem
   
   # Upload public key to Intersight portal
   # Navigate to Settings > API Keys > Generate API Key
   ```

2. **Target Registration**
   ```python
   # Python script for target registration
   import intersight
   from intersight.model.asset_target import AssetTarget
   
   # Configure API client
   configuration = intersight.Configuration(
       host="https://intersight.com",
       signing_scheme=intersight.signing.SCHEME_RSA_SHA256,
       signing_algorithm=intersight.signing.ALGORITHM_RSASSA_PKCS1v15,
       private_key_path="intersight_private_key.pem",
       api_key_id="<API-KEY-ID>"
   )
   
   # Register HyperFlex target
   api_client = intersight.ApiClient(configuration)
   api_instance = intersight.AssetApi(api_client)
   
   target = AssetTarget(
       name="HX-Cluster-<SITE>",
       target_type="HyperFlexCluster",
       connection_properties={
           "endpoint": "<HX-CLUSTER-IP>",
           "username": "<USERNAME>",
           "password": "<PASSWORD>"
       }
   )
   
   result = api_instance.create_asset_target(target)
   ```

### 5.2 Policy Configuration

**Server Profile Templates:**

```yaml
# Intersight Server Profile Template
server_profile_template:
  name: "HX-Server-Template"
  description: "HyperFlex server profile template"
  
  policies:
    bios_policy:
      name: "HX-BIOS-Policy"
      settings:
        intel_vt_enabled: true
        intel_vtd_enabled: true
        sr_iov_enabled: true
        
    boot_policy:
      name: "HX-Boot-Policy"
      boot_mode: "Uefi"
      secure_boot: false
      
    lan_connectivity_policy:
      name: "HX-LAN-Policy"
      vnics:
        - name: "eth0"
          mac_address_type: "POOL"
          fabric_failover: true
          placement_slot: "MLOM"
```

## VMware Integration

### 6.1 vCenter Deployment

**vCenter Server Appliance Installation:**

```bash
# Mount vCenter ISO
mount -o loop VMware-VCSA-all-7.0.x.iso /mnt/vcsa

# Run CLI installer
cd /mnt/vcsa/vcsa-cli-installer/lin64
./vcsa-deploy install --accept-eula --acknowledge-ceip vcsa-config.json

# vcsa-config.json template
{
    "__version": "2.13.0",
    "__comments": "vCenter Server Appliance deployment configuration",
    "new_vcsa": {
        "esxi": {
            "hostname": "<ESX-HOST-IP>",
            "username": "root",
            "password": "<ROOT-PASSWORD>",
            "deployment_network": "VM Network",
            "datastore": "datastore1"
        },
        "appliance": {
            "__comments": "vCenter Server Appliance configuration",
            "thin_disk_mode": true,
            "deployment_option": "medium",
            "name": "vcsa-<SITE>"
        },
        "network": {
            "ip_family": "ipv4",
            "mode": "static",
            "ip": "<VCENTER-IP>",
            "dns_servers": ["<DNS1>", "<DNS2>"],
            "prefix": "24",
            "gateway": "<GATEWAY>"
        },
        "os": {
            "password": "<APPLIANCE-PASSWORD>",
            "ntp_servers": ["<NTP-SERVER>"],
            "ssh_enable": true
        },
        "sso": {
            "password": "<SSO-PASSWORD>",
            "domain_name": "vsphere.local"
        }
    },
    "ceip": {
        "settings": {
            "ceip_enabled": false
        }
    }
}
```

### 6.2 HyperFlex vCenter Integration

**Integration Steps:**

```powershell
# PowerCLI script for vCenter integration
Connect-VIServer -Server <VCENTER-IP> -Username administrator@vsphere.local -Password <PASSWORD>

# Add HyperFlex cluster to vCenter
$ClusterSpec = New-Object VMware.Vim.ClusterSpec
$ClusterSpec.DrsConfig = New-Object VMware.Vim.ClusterDrsConfigInfo
$ClusterSpec.DrsConfig.Enabled = $true
$ClusterSpec.DrsConfig.EnableVmBehaviorOverrides = $true
$ClusterSpec.DrsConfig.DefaultVmBehavior = "manual"

New-Cluster -Name "HX-Compute-Cluster" -Location (Get-Datacenter "Datacenter") -Spec $ClusterSpec

# Add ESXi hosts to cluster
$Cluster = Get-Cluster "HX-Compute-Cluster"
Add-VMHost -Name <ESX-HOST-IP> -Location $Cluster -Username root -Password <PASSWORD> -Force
```

## Security Configuration

### 7.1 Certificate Management

**SSL Certificate Installation:**

```bash
# Generate certificate signing request
openssl req -new -newkey rsa:2048 -nodes -keyout hyperflex.key -out hyperflex.csr

# Install signed certificate
hxcli certificate install --cert-file hyperflex.crt --key-file hyperflex.key

# Verify certificate installation
hxcli certificate show
```

### 7.2 User Authentication

**LDAP Integration:**

```bash
# Configure LDAP authentication for HyperFlex
hxcli user auth-config --auth-method ldap \
  --ldap-server <LDAP-SERVER> \
  --ldap-port 636 \
  --ldap-base-dn "DC=company,DC=com" \
  --ldap-bind-dn "CN=service,DC=company,DC=com" \
  --ldap-bind-password <PASSWORD>

# Test LDAP authentication
hxcli user auth-test --username testuser --password <PASSWORD>
```

### 7.3 Network Security

**Firewall Configuration:**

```bash
# Configure ESXi firewall rules
esxcli network firewall set --default-action false --enabled true

# Allow required services
esxcli network firewall ruleset set --ruleset-id httpClient --enabled true
esxcli network firewall ruleset set --ruleset-id ntpClient --enabled true
esxcli network firewall ruleset set --ruleset-id sshClient --enabled true
esxcli network firewall ruleset set --ruleset-id vSphereClient --enabled true

# Custom rules for HyperFlex
esxcli network firewall ruleset rule add --ruleset-id customRule \
  --direction outbound --port-type dst --port-begin 2049 --port-end 2049 --protocol tcp
```

## Monitoring Setup

### 8.1 SNMP Configuration

**Enable SNMP Monitoring:**

```bash
# Configure SNMP on HyperFlex
hxcli snmp enable --version v3 \
  --username <SNMP-USER> \
  --auth-protocol SHA \
  --auth-password <AUTH-PASSWORD> \
  --priv-protocol AES128 \
  --priv-password <PRIV-PASSWORD>

# Add trap destinations
hxcli snmp trap-destination add --host <MONITORING-SERVER> --port 162
```

### 8.2 Performance Monitoring

**Baseline Performance Collection:**

```python
# Python script for performance data collection
import time
import subprocess
import json

def collect_performance_metrics():
    metrics = {}
    
    # CPU utilization
    cpu_cmd = "hxcli cluster cpu-usage"
    cpu_output = subprocess.check_output(cpu_cmd.split())
    metrics['cpu'] = json.loads(cpu_output)
    
    # Memory utilization
    mem_cmd = "hxcli cluster memory-usage"
    mem_output = subprocess.check_output(mem_cmd.split())
    metrics['memory'] = json.loads(mem_output)
    
    # Storage performance
    storage_cmd = "hxcli cluster storage-performance"
    storage_output = subprocess.check_output(storage_cmd.split())
    metrics['storage'] = json.loads(storage_output)
    
    return metrics

# Collect baseline metrics
baseline_metrics = collect_performance_metrics()
with open('baseline_performance.json', 'w') as f:
    json.dump(baseline_metrics, f, indent=2)
```

## Testing and Validation

### 9.1 Infrastructure Testing

**Network Connectivity Tests:**

```bash
# Test management network connectivity
ping -c 5 <VCENTER-IP>
ping -c 5 <APIC-IP>
ping -c 5 <HX-CONTROLLER-IP>

# Test storage network performance
iperf3 -c <STORAGE-TARGET-IP> -p 5201 -t 60 -P 4

# Test vMotion network
vmware-cmd -l | head -1 | xargs vmware-cmd -s suspend
vmware-cmd -l | head -1 | xargs vmware-cmd -s start
```

**Storage Performance Testing:**

```bash
# FIO storage performance test
fio --name=random-write --ioengine=libaio --rw=randwrite --bs=4k \
    --size=10G --numjobs=4 --iodepth=32 --runtime=300 --group_reporting

# Sequential read test
fio --name=sequential-read --ioengine=libaio --rw=read --bs=1M \
    --size=10G --numjobs=1 --iodepth=8 --runtime=300 --group_reporting
```

### 9.2 Application Testing

**VM Deployment Test:**

```powershell
# PowerCLI script for VM deployment testing
$VMName = "Test-VM-001"
$Template = "Windows-2019-Template"
$Datastore = "HX-Datastore-01"
$Cluster = "HX-Compute-Cluster"

# Deploy VM from template
New-VM -Name $VMName -Template $Template -Datastore $Datastore -Location $Cluster

# Power on VM
Start-VM -VM $VMName

# Verify VM status
Get-VM -Name $VMName | Select Name, PowerState, GuestFullName
```

### 9.3 Disaster Recovery Testing

**Backup and Recovery Validation:**

```bash
# Test VM snapshot functionality
vim-cmd vmsvc/getallvms | grep "Test-VM" | awk '{print $1}' | \
  xargs -I {} vim-cmd vmsvc/snapshot.create {} "DR-Test-Snapshot" "Disaster Recovery Test"

# Test snapshot removal
vim-cmd vmsvc/getallvms | grep "Test-VM" | awk '{print $1}' | \
  xargs -I {} vim-cmd vmsvc/snapshot.removeall {}
```

## Production Cutover

### 10.1 Migration Planning

**Workload Migration Checklist:**

- [ ] Application dependency mapping completed
- [ ] Migration sequence defined
- [ ] Rollback procedures documented
- [ ] Maintenance windows scheduled
- [ ] Communication plan activated

### 10.2 Migration Execution

**VM Migration Process:**

```powershell
# PowerCLI script for VM migration
$SourceDatastore = "Old-SAN-Datastore"
$TargetDatastore = "HX-Datastore-01"
$VMs = Get-VM -Location $SourceCluster

foreach ($VM in $VMs) {
    Write-Host "Migrating VM: $($VM.Name)"
    Move-VM -VM $VM -Datastore $TargetDatastore -VMotionPriority High
    
    # Verify migration success
    $NewLocation = Get-VM -Name $VM.Name | Get-Datastore
    if ($NewLocation.Name -eq $TargetDatastore) {
        Write-Host "Migration successful for $($VM.Name)"
    } else {
        Write-Error "Migration failed for $($VM.Name)"
    }
}
```

### 10.3 Post-Migration Validation

**System Health Verification:**

```bash
# Comprehensive health check script
#!/bin/bash

echo "=== Cisco Hybrid Infrastructure Health Check ==="
echo "Timestamp: $(date)"
echo ""

# HyperFlex cluster health
echo "HyperFlex Cluster Status:"
hxcli cluster info | grep -E "(Cluster Status|Cluster Health)"
echo ""

# VMware cluster health
echo "VMware Cluster Status:"
vim-cmd hostsvc/hostsummary | grep overallStatus
echo ""

# ACI fabric health
echo "ACI Fabric Health:"
# Commands would vary based on specific APIC version and access method
echo "Manual verification required via APIC GUI"
echo ""

# Network connectivity tests
echo "Network Connectivity Tests:"
ping -c 3 <CRITICAL-SERVER-IP> && echo "Critical server reachable" || echo "Critical server unreachable"
ping -c 3 <DNS-SERVER> && echo "DNS server reachable" || echo "DNS server unreachable"
echo ""

# Storage performance check
echo "Storage Performance Check:"
hxcli datastore list | grep -E "(Datastore|Status|Usage)"
echo ""

echo "=== Health Check Complete ==="
```

## Troubleshooting Guide

### Common Issues and Resolutions

**Issue: HyperFlex Node Not Discovered**
```bash
# Check network connectivity
ping <NODE-MANAGEMENT-IP>

# Verify IPMI/BMC connectivity
ipmitool -I lanplus -H <BMC-IP> -U <BMC-USER> -P <BMC-PASSWORD> chassis status

# Check UCS discovery
show server status
```

**Issue: vCenter Integration Failure**
```bash
# Verify vCenter connectivity
curl -k https://<VCENTER-IP>/ui/

# Check ESXi host connectivity
ssh root@<ESX-HOST-IP> "esxcli system version get"

# Validate certificates
openssl s_client -connect <VCENTER-IP>:443 -showcerts
```

**Issue: ACI Connectivity Problems**
```bash
# Check APIC accessibility
curl -k https://<APIC-IP>/api/node/class/topSystem.json

# Verify fabric connectivity
# Access APIC GUI and check Fabric > Inventory
```

## Post-Implementation Tasks

### Documentation Updates
- [ ] As-built documentation completed
- [ ] Network diagrams updated
- [ ] Configuration backups taken
- [ ] Operational procedures documented
- [ ] Emergency contact list updated

### Knowledge Transfer
- [ ] Administrator training completed
- [ ] Operations team handover completed
- [ ] Support procedures documented
- [ ] Escalation procedures defined

### Ongoing Maintenance
- [ ] Monitoring alerts configured
- [ ] Backup procedures implemented
- [ ] Patch management process defined
- [ ] Capacity planning procedures established

---

**Implementation Guide Version**: 1.0  
**Last Updated**: [Date]  
**Next Review**: [Date + 90 days]
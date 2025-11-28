---
document_title: Implementation Guide
solution_name: Cisco HyperFlex Hybrid Cloud Infrastructure
document_version: "1.0"
author: "[TECH_LEAD]"
last_updated: "[DATE]"
technology_provider: cisco
client_name: "[CLIENT]"
client_logo: ../../assets/logos/client_logo.png
vendor_logo: ../../assets/logos/consulting_company_logo.png
eoframework_logo: ../../assets/logos/eo-framework-logo-real.png
---

# Executive Summary

This Implementation Guide provides comprehensive deployment procedures for the Cisco HyperFlex Hybrid Cloud Infrastructure solution. The guide covers HyperFlex cluster deployment, Fabric Interconnect configuration, VMware vSphere 8 installation, Cisco Intersight integration, and VM migration procedures using a combination of automated tools and manual configuration.

## Document Purpose

This document serves as the primary technical reference for the implementation team, providing step-by-step procedures for deploying the HyperFlex infrastructure and migrating 180 VMs to the new platform. All procedures have been validated against Cisco HyperFlex and VMware vSphere 8 environments.

## Implementation Approach

The implementation follows a phased methodology starting with hardware installation, progressing through HyperFlex cluster deployment, VMware configuration, and concluding with wave-based VM migrations. The approach ensures validated milestones before proceeding to each subsequent phase.

## Automation Framework Overview

The following automation technologies are included in this delivery.

<!-- TABLE_CONFIG: widths=[20, 30, 25, 25] -->
| Technology | Purpose | Location | Prerequisites |
|------------|---------|----------|---------------|
| HyperFlex Installer | Cluster deployment wizard | HX Installer VM | vCenter access |
| Intersight | Cloud-based management | intersight.com | Internet connectivity |
| PowerCLI | VMware automation scripts | `scripts/powercli/` | PowerShell 7.0+ |
| Bash | Linux automation scripts | `scripts/bash/` | Bash 4.0+ |

## Scope Summary

### In Scope

The following components are deployed using the procedures in this guide.

- HyperFlex 4-node cluster with HX240c M5 nodes
- UCS 6454 Fabric Interconnect HA pair
- Cisco Intersight cloud management integration
- VMware vSphere 8.0 U2 and vCenter Server
- VMware HA and DRS cluster configuration
- Veeam backup integration
- VM migration (180 VMs across 3 waves)
- Operations team training (24 hours)

### Out of Scope

The following items are excluded from this implementation guide.

- Application-level configuration within migrated VMs
- Legacy infrastructure decommissioning
- DR site implementation (Phase 2)
- Custom integrations beyond standard monitoring

## Timeline Overview

The implementation follows a phased deployment approach with validation gates.

<!-- TABLE_CONFIG: widths=[15, 30, 30, 25] -->
| Phase | Activities | Duration | Exit Criteria |
|-------|------------|----------|---------------|
| 1 | Prerequisites & Data Center Prep | 2 weeks | Site ready, hardware received |
| 2 | Foundation Infrastructure | 2 weeks | HX cluster and FIs operational |
| 3 | Virtualization Platform | 1.5 weeks | vSphere 8, vCenter configured |
| 4 | Migration Execution | 6 weeks | All 180 VMs migrated |
| 5 | Optimization & Training | 1.5 weeks | Performance tuned, team trained |
| 6 | Go-Live & Hypercare | 4 weeks | Production stable |

**Total Implementation:** ~12 weeks + 4 weeks hypercare

# Prerequisites

This section documents all requirements that must be satisfied before infrastructure deployment can begin.

## Tool Installation

The following tools must be installed on the deployment workstation before proceeding.

### Required Tools Checklist

Use the following checklist to verify all required tools are installed.

- [ ] **HyperFlex Installer VM** >= 5.0 - Cluster deployment
- [ ] **vSphere Client** >= 8.0 - VMware management
- [ ] **PowerCLI** >= 13.0 - PowerShell automation
- [ ] **Intersight Account** - Cloud management access
- [ ] **SSH Client** - Node and CIMC access

### HyperFlex Installer Setup

Deploy and configure the HyperFlex Installer VM.

```bash
# Download HyperFlex Installer OVA from Cisco
# Deploy to existing vCenter or standalone ESXi

# Verify installer accessibility
ping hx-installer.client.local

# Access installer web UI
# Navigate to https://hx-installer.client.local
```

### PowerCLI Installation

Install VMware PowerCLI for automation scripts.

```powershell
# Install PowerCLI module
Install-Module -Name VMware.PowerCLI -Scope CurrentUser

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Configure PowerCLI settings
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -ParticipateInCEIP $false -Confirm:$false

# Verify installation
Get-Module -Name VMware.PowerCLI -ListAvailable
```

## Hardware Prerequisites

The following hardware must be installed and cabled before software deployment.

### HyperFlex Node Installation

- [ ] 4x HX240c M5 nodes rack-mounted
- [ ] Power cables connected (2x per node for redundancy)
- [ ] CIMC management ports cabled to out-of-band network
- [ ] 25GbE ports cabled to Fabric Interconnects

### Fabric Interconnect Installation

- [ ] 2x UCS 6454 FIs rack-mounted
- [ ] L1/L2 cluster ports directly connected
- [ ] Uplinks cabled to upstream switches
- [ ] Management ports connected

### Network Prerequisites

- [ ] VLANs configured on upstream switches (100, 101, 102, 200-250)
- [ ] DHCP scope for HyperFlex deployment (temporary)
- [ ] DNS records created for all components
- [ ] NTP server accessible from management network
- [ ] Internet connectivity for Intersight (outbound HTTPS)

## Prerequisite Validation

Run the prerequisite validation to verify all requirements.

```bash
# Validate network connectivity
ping -c 4 10.100.1.10  # FI-A
ping -c 4 10.100.1.11  # FI-B
ping -c 4 10.100.4.10  # NTP server
ping -c 4 10.100.5.10  # DNS server

# Validate Intersight connectivity
curl -I https://intersight.com

# Verify CIMC access for each node
for node in 10.100.1.21 10.100.1.22 10.100.1.23 10.100.1.24; do
  echo "Testing CIMC: $node"
  curl -k -s -o /dev/null -w "%{http_code}" https://$node
done
```

### Validation Checklist

Complete this checklist before proceeding to environment setup.

- [ ] All 4 HyperFlex nodes powered on and CIMC accessible
- [ ] Both Fabric Interconnects powered on and accessible
- [ ] Network VLANs verified on upstream switches
- [ ] DNS records resolve correctly
- [ ] NTP connectivity confirmed
- [ ] Intersight.com reachable from management network
- [ ] VMware licenses available and valid

# Environment Setup

This section covers the initial setup of Fabric Interconnects and preparation for HyperFlex deployment.

## Fabric Interconnect Initial Setup

Configure the UCS 6454 Fabric Interconnects for cluster mode.

### FI-A Initial Configuration

```
# Connect to FI-A console (serial or SSH after initial setup)

Enter the configuration method. (console/gui) ? console
Enter the setup mode; setup newly or restore from backup. (setup/restore) ? setup
You have chosen to setup a new Fabric interconnect. Continue? (y/n): y

Enter the password for "admin": ********
Confirm the password for "admin": ********

Do you want to create a new cluster on this Fabric interconnect (select 'no'
for standalone setup or if this is a subordinate) ? (yes/no) [n]: yes

Enter the cluster name: hx-cluster-prod

Physical Switch Mgmt0 IPv4 address : 10.100.1.10
Physical Switch Mgmt0 IPv4 netmask : 255.255.255.0
IPv4 address of the default gateway : 10.100.1.1
Cluster IPv4 address : 10.100.1.12
Configure the DNS Server IP address? (yes/no) [n]: yes
  DNS IP address : 10.100.5.10
Configure the default domain name? (yes/no) [n]: yes
  Default domain name : client.local
```

### FI-B Initial Configuration

```
# Connect to FI-B console after FI-A is configured

Enter the configuration method. (console/gui) ? console
Installer has detected the presence of a peer Fabric interconnect.
This Fabric interconnect will be added to the cluster.
Continue (y/n) ? y

Enter the admin password of the peer Fabric interconnect: ********
Connecting to peer Fabric interconnect... done
Retrieving config from peer Fabric interconnect... done

Physical Switch Mgmt0 IPv4 address : 10.100.1.11

Apply and save the configuration (select 'no' if you want to re-enter)? (yes/no): yes
```

## VLAN Configuration

Configure VLANs on the Fabric Interconnects.

```
# Connect to FI via UCS Manager

# Create VLANs
scope eth-uplink
  create vlan hx-mgmt 100
  create vlan hx-vmotion 101
  create vlan hx-storage 102
  create vlan vm-prod-1 200
  create vlan vm-prod-2 201
  commit-buffer
end
```

## Intersight Setup

Configure Intersight account and device connector.

### Intersight Account Creation

1. Navigate to https://intersight.com
2. Create account or login with existing Cisco credentials
3. Note the Account ID for device claiming
4. Generate API keys for automation (optional)

### Device Connector Configuration

```bash
# Access FI via UCS Manager CLI
connect nxos a

# Configure Intersight device connector
intersight
  set device-connector https-proxy-host ""
  set device-connector mode intersight-cloud
  cloud-connector claim-code
  # Note the claim code displayed

# Claim device in Intersight portal
# Navigate to Admin > Device Connectors > Claim a Target
# Enter the claim code from FI
```

# Infrastructure Deployment

This section covers the phased deployment of HyperFlex infrastructure.

## Deployment Overview

Infrastructure deployment follows a dependency-ordered sequence.

<!-- TABLE_CONFIG: widths=[15, 25, 35, 25] -->
| Phase | Layer | Components | Dependencies |
|-------|-------|------------|--------------|
| 1 | Networking | FI cluster, VLANs, uplinks | Hardware installed |
| 2 | Security | CIMC credentials, admin accounts | Networking |
| 3 | Compute | HyperFlex cluster deployment | Security |
| 4 | Monitoring | Intersight integration, alerts | Compute |

## Phase 1: Networking Layer

Deploy the foundational networking infrastructure.

### Networking Components

The networking layer deploys the following resources.

- Fabric Interconnect HA cluster (completed in Environment Setup)
- VLAN definitions for all traffic types
- Uplink port channels to upstream switches
- Server ports for HyperFlex nodes

### FI Uplink Configuration

```
# Configure uplink port-channel to upstream switches
scope eth-uplink
  scope fabric a
    create port-channel 1
    set ports 1/49,1/50
    create member-port 1/49
    create member-port 1/50
    exit
    create uplink-port-channel 1
    set vlans hx-mgmt,hx-vmotion,vm-prod-1,vm-prod-2
    commit-buffer
  exit
  scope fabric b
    create port-channel 2
    set ports 1/49,1/50
    create member-port 1/49
    create member-port 1/50
    exit
    create uplink-port-channel 2
    set vlans hx-mgmt,hx-vmotion,vm-prod-1,vm-prod-2
    commit-buffer
  exit
end
```

### Networking Validation

```bash
# Verify FI cluster status
ssh admin@10.100.1.12
show cluster state

# Verify VLAN configuration
show vlan

# Verify uplink status
show interface port-channel 1
show interface port-channel 2

# Verify connectivity to upstream
ping 10.100.1.1  # Gateway
```

## Phase 2: Security Layer

Configure security settings and credentials.

### Security Components

- CIMC credentials for all HyperFlex nodes
- UCS Manager admin account
- Service accounts for integrations
- SSH key distribution

### CIMC Configuration

```bash
# Configure CIMC on each HyperFlex node via KVM
# Access https://<cimc-ip> for each node

# Set admin password
# Configure network settings
# Enable SSH access

# Verify CIMC access
for node in node01 node02 node03 node04; do
  echo "Testing CIMC: hx-$node"
  ssh admin@hx-$node-cimc "show chassis"
done
```

### Security Validation

```bash
# Verify admin access to FI
ssh admin@10.100.1.12
show system

# Verify CIMC credentials
ipmitool -I lanplus -H 10.100.1.21 -U admin -P ******** chassis status
```

## Phase 3: Compute Layer

Deploy HyperFlex cluster using the Installer.

### HyperFlex Cluster Deployment

Access the HyperFlex Installer and complete the deployment wizard.

```
# Navigate to https://hx-installer.client.local

# Step 1: Create Cluster
- Select "Create Cluster"
- Choose "Standard Cluster"
- Enter cluster name: hx-cluster-prod

# Step 2: Credentials
- UCS Manager IP: 10.100.1.12
- UCS Manager credentials: admin / ********
- Hypervisor type: ESXi

# Step 3: IP Addresses
- Management Network: 10.100.1.0/24
- Gateway: 10.100.1.1
- Management VLAN: 100
- Data Network: 10.100.10.0/24
- Data VLAN: 102

# Step 4: Node Configuration
- Add 4 nodes from discovered servers
- Assign hostnames: hx-node-01 through hx-node-04
- Assign management IPs: 10.100.1.31-34
- Assign data IPs: 10.100.10.31-34

# Step 5: vCenter Configuration
- vCenter IP: 10.100.1.30
- vCenter credentials: administrator@vsphere.local / ********
- Datacenter name: HX-Datacenter
- Cluster name: HX-Cluster

# Step 6: HyperFlex Configuration
- Cluster management IP: 10.100.1.20
- Replication factor: 3
- Enable deduplication: Yes
- Enable compression: Yes

# Step 7: Review and Deploy
- Review all settings
- Click "Deploy" to begin installation
```

### Deployment Monitoring

Monitor the deployment progress.

```bash
# Monitor installation via HX Installer UI
# Progress displayed for each phase:
# - UCS Manager configuration
# - Server boot and ESXi installation
# - HyperFlex software installation
# - Cluster creation
# - vCenter registration

# Expected duration: 3-4 hours for 4-node cluster
```

### Compute Validation

```bash
# Verify HyperFlex cluster status
ssh admin@10.100.1.20
hxcli cluster info

# Expected output:
# Cluster Name: hx-cluster-prod
# Cluster State: Online
# Health State: Healthy
# Nodes: 4

# Verify storage status
hxcli datastore list
hxcli disk list

# Verify replication factor
hxcli cluster replication-factor
# Expected: 3
```

## Phase 4: Monitoring Layer

Configure monitoring and alerting via Intersight.

### Intersight Claim

Claim HyperFlex cluster in Intersight.

```bash
# Generate claim code on HyperFlex controller
ssh admin@10.100.1.20
hxcli security encrypt-password --set  # If not already set
exit

# Access HX Connect UI
# Navigate to https://10.100.1.20
# Go to System Information > Intersight Registration
# Copy the claim code

# In Intersight portal:
# Navigate to Admin > Device Connectors > Claim a Target
# Enter claim code
# Select "HyperFlex" target type
# Complete claiming process
```

### Intersight Configuration

Configure monitoring and alerts in Intersight.

```
# In Intersight portal:

# 1. Configure Email Alerts
# Navigate to Settings > Email
# Add recipient: infra-ops@client.local
# Enable critical and warning alerts

# 2. Configure SNMP (optional)
# Navigate to Settings > SNMP
# Add SNMP server: 10.100.3.10
# Configure community string

# 3. Create Dashboard
# Navigate to Dashboards > Create
# Add HyperFlex cluster health widgets
# Add storage utilization widget
# Add alarm summary widget
```

### Monitoring Validation

```bash
# Verify Intersight connectivity
# In Intersight portal, check:
# - Device Connectors shows "Connected"
# - HyperFlex cluster visible in Infrastructure
# - Health status shows "Healthy"

# Generate test alert
# In HX Connect, trigger a non-critical event
# Verify email notification received
```

# Application Configuration

This section covers VMware vSphere and vCenter configuration.

## VMware vCenter Configuration

Configure vCenter for HyperFlex cluster management.

### vCenter Access

```powershell
# Connect to vCenter using PowerCLI
Connect-VIServer -Server vcenter.client.local -User administrator@vsphere.local -Password ********

# Verify connection
$global:DefaultVIServer
```

### Cluster Configuration

```powershell
# Verify HyperFlex cluster exists in vCenter
Get-Cluster -Name "HX-Cluster"

# Verify all ESXi hosts
Get-VMHost -Location "HX-Cluster" | Format-Table Name, ConnectionState, PowerState

# Verify HyperFlex datastore
Get-Datastore | Where-Object {$_.Name -like "HX-*"}
```

### VMware HA Configuration

```powershell
# Configure HA settings
$cluster = Get-Cluster -Name "HX-Cluster"

# Enable HA
Set-Cluster -Cluster $cluster -HAEnabled:$true -HAAdmissionControlEnabled:$true -Confirm:$false

# Configure admission control
$haSpec = New-Object VMware.Vim.ClusterConfigSpecEx
$haSpec.dasConfig = New-Object VMware.Vim.ClusterDasConfigInfo
$haSpec.dasConfig.admissionControlPolicy = New-Object VMware.Vim.ClusterFailoverHostAdmissionControlPolicy
$haSpec.dasConfig.admissionControlPolicy.failoverHosts = @()
$haSpec.dasConfig.admissionControlEnabled = $true

# Verify HA status
Get-Cluster "HX-Cluster" | Select Name, HAEnabled, HAAdmissionControlEnabled
```

### VMware DRS Configuration

```powershell
# Enable DRS
Set-Cluster -Cluster $cluster -DrsEnabled:$true -DrsAutomationLevel FullyAutomated -Confirm:$false

# Configure DRS rules for HyperFlex
# (HyperFlex controller VMs must run on specific hosts)

# Verify DRS status
Get-Cluster "HX-Cluster" | Select Name, DrsEnabled, DrsAutomationLevel
```

## Veeam Backup Configuration

Configure Veeam for HyperFlex backup integration.

### Veeam Server Connection

```powershell
# In Veeam Backup & Replication console:
# 1. Add vCenter as managed server
# 2. Add HyperFlex storage system
# 3. Configure backup repository

# Connect Veeam to vCenter
# Backup Infrastructure > Managed Servers > Add Server
# Select "VMware vSphere"
# Enter: vcenter.client.local
# Provide credentials
```

### Backup Job Configuration

```powershell
# Create backup job for production VMs
# Home > Backup Job > VMware vSphere

# Job Settings:
# - Name: HX-Production-Daily
# - VMs: Select from HX-Cluster
# - Storage: Backup Repository
# - Retention: 30 restore points
# - Schedule: Daily at 22:00
# - Enable application-aware processing
# - Enable HyperFlex snapshot integration
```

# Integration Testing

This section covers integration testing procedures.

## Test Environment Preparation

Prepare test VMs for validation.

```powershell
# Create test VM
$datastore = Get-Datastore -Name "HX-Datastore-01"
$vmhost = Get-VMHost | Select -First 1
$network = Get-VirtualPortGroup -Name "VM Network"

New-VM -Name "Test-VM-01" -Datastore $datastore -VMHost $vmhost `
  -NumCPU 2 -MemoryGB 4 -DiskGB 50 -NetworkName $network.Name `
  -GuestId windows2019srv_64Guest

# Power on test VM
Start-VM -VM "Test-VM-01"
```

## Integration Test Execution

### Functional Tests

```powershell
# Test VM provisioning
$testVM = Get-VM "Test-VM-01"
Write-Host "VM Name: $($testVM.Name)"
Write-Host "Power State: $($testVM.PowerState)"
Write-Host "VMHost: $($testVM.VMHost)"

# Test vMotion
$targetHost = Get-VMHost | Where-Object {$_.Name -ne $testVM.VMHost.Name} | Select -First 1
Move-VM -VM $testVM -Destination $targetHost -VMotionPriority High
Write-Host "vMotion complete. New host: $($testVM.VMHost)"

# Test Storage vMotion
$targetDS = Get-Datastore | Where-Object {$_.Name -ne $testVM.ExtensionData.Config.DatastoreUrl[0].Name} | Select -First 1
Move-VM -VM $testVM -Datastore $targetDS
Write-Host "Storage vMotion complete."
```

### HyperFlex Tests

```bash
# Test cluster health
ssh admin@10.100.1.20
hxcli cluster health
hxcli cluster storage-summary

# Test storage performance
hxcli benchmark --type sequential-write --size 10G
hxcli benchmark --type random-read --size 10G

# Expected results:
# - Sequential write: > 1 GB/s
# - Random read IOPS: > 100,000
```

### Backup Tests

```powershell
# Run test backup
# In Veeam console, select test VM and run backup

# Verify backup completion
# Check job session for success

# Test restore
# Perform instant VM recovery test
# Verify VM boots and is accessible
```

## Test Success Criteria

Complete this checklist before proceeding.

- [ ] All ESXi hosts healthy and connected to vCenter
- [ ] HyperFlex cluster status: Healthy
- [ ] VMware HA enabled and tested
- [ ] VMware DRS enabled and balancing VMs
- [ ] vMotion tested successfully between all hosts
- [ ] Storage vMotion tested successfully
- [ ] Backup job completes successfully
- [ ] Restore test completes successfully
- [ ] Storage performance meets targets (100K IOPS, <5ms latency)

# Security Validation

This section covers security validation procedures.

## Security Scan Execution

### Access Control Validation

```powershell
# Verify vCenter permissions
Connect-VIServer -Server vcenter.client.local
Get-VIPermission | Format-Table Principal, Role, Entity

# Verify no unnecessary admin accounts
Get-VIPermission | Where-Object {$_.Role -eq "Admin"}
```

### Network Security Validation

```bash
# Verify VLAN isolation
# From test VM on VLAN 200, attempt to reach management network
ping 10.100.1.20  # Should fail if properly isolated

# Verify storage network isolation
# Storage VLAN 102 should not be accessible from VM networks
```

### Encryption Validation

```bash
# Verify HyperFlex encryption status
ssh admin@10.100.1.20
hxcli encryption status

# Verify vCenter uses HTTPS
curl -I https://vcenter.client.local
# Should return TLS certificate information
```

## Compliance Validation Checklist

- [ ] Role-based access control configured
- [ ] Admin accounts use strong passwords
- [ ] Audit logging enabled on all components
- [ ] Management interfaces use TLS 1.2+
- [ ] Storage encryption configured (if required)
- [ ] Backup encryption enabled
- [ ] Network segmentation verified

# Migration & Cutover

This section covers VM migration procedures.

## Pre-Migration Checklist

- [ ] All infrastructure validated and healthy
- [ ] Backup jobs configured and tested
- [ ] Application owners notified
- [ ] Rollback procedures documented
- [ ] Migration window approved
- [ ] Support contacts available

## Migration Execution

### Pilot Migration: 20 VMs

```powershell
# Connect to source vCenter (if different)
Connect-VIServer -Server source-vcenter.client.local

# Get pilot VM list
$pilotVMs = Get-Content "pilot-vm-list.txt"

# Migrate each VM using vMotion
foreach ($vmName in $pilotVMs) {
    $vm = Get-VM -Name $vmName
    Write-Host "Migrating: $vmName"

    # Create snapshot before migration
    New-Snapshot -VM $vm -Name "Pre-Migration" -Description "Before HyperFlex migration"

    # Perform cross-vCenter vMotion (if applicable)
    # Or traditional vMotion if same vCenter
    Move-VM -VM $vm -Destination (Get-VMHost -Location "HX-Cluster" | Get-Random) `
      -Datastore (Get-Datastore "HX-Datastore-01") -VMotionPriority High

    Write-Host "Migration complete: $vmName"
}
```

### Migration Validation

```powershell
# Verify migrated VMs
foreach ($vmName in $pilotVMs) {
    $vm = Get-VM -Name $vmName
    Write-Host "$vmName - Host: $($vm.VMHost) - Datastore: $($vm.ExtensionData.Config.DatastoreUrl[0].Name)"
}

# Verify VM health
foreach ($vmName in $pilotVMs) {
    $vm = Get-VM -Name $vmName
    if ($vm.PowerState -eq "PoweredOn") {
        $guestInfo = Get-VMGuest -VM $vm
        Write-Host "$vmName - IP: $($guestInfo.IPAddress)"
    }
}
```

### Wave 1-3 Migrations

Repeat migration process for each wave:
- Wave 1: 50 business VMs
- Wave 2: 50 critical VMs
- Wave 3: Remaining ~60 VMs

## Rollback Procedures

If critical issues are identified, execute rollback.

```powershell
# Revert to pre-migration snapshot
$vm = Get-VM -Name "Problem-VM"
$snapshot = Get-Snapshot -VM $vm -Name "Pre-Migration"
Set-VM -VM $vm -Snapshot $snapshot -Confirm:$false

# Or restore from Veeam backup
# In Veeam console: Instant VM Recovery
```

# Operational Handover

This section covers the transition to ongoing operations.

## Monitoring Dashboard Access

### Intersight Dashboard

```
# Access Intersight
URL: https://intersight.com
Login: Use Cisco/company SSO credentials

# Key dashboards:
# - Infrastructure > HyperFlex Clusters
# - Alarms > Active Alarms
# - Reports > Custom Reports
```

### vCenter Dashboard

```powershell
# Key monitoring locations in vCenter:
# - Cluster > Monitor > Performance
# - Cluster > Monitor > Events
# - HyperFlex plugin > Health Dashboard
```

### Key Metrics to Monitor

<!-- TABLE_CONFIG: widths=[25, 25, 25, 25] -->
| Metric | Threshold | Alert Severity | Response |
|--------|-----------|----------------|----------|
| Cluster Health | Not Healthy | Critical | Investigate immediately |
| Storage IOPS | > 100,000 sustained | Warning | Capacity planning |
| Storage Latency | > 5ms | Warning | Performance analysis |
| CPU Utilization | > 80% | Warning | DRS review, capacity |
| Memory Utilization | > 85% | Warning | Capacity planning |
| Datastore Capacity | > 80% | Warning | Storage expansion |

## Support Transition

### Support Model

<!-- TABLE_CONFIG: widths=[15, 30, 25, 30] -->
| Tier | Responsibility | Team | Response Time |
|------|---------------|------|---------------|
| L1 | Initial triage, known issues | Client Help Desk | 15 minutes |
| L2 | Technical troubleshooting | Client Infrastructure | 1 hour |
| L3 | HyperFlex/VMware issues | Vendor Support | 4 hours |
| L4 | Engineering escalation | Cisco TAC | Next business day |

### Escalation Contacts

<!-- TABLE_CONFIG: widths=[25, 25, 30, 20] -->
| Role | Name | Email | Phone |
|------|------|-------|-------|
| Technical Lead | [NAME] | [EMAIL] | [PHONE] |
| Project Manager | [NAME] | [EMAIL] | [PHONE] |
| Cisco TAC | N/A | support@cisco.com | 1-800-553-2447 |
| VMware Support | N/A | support@vmware.com | 1-877-486-9273 |

# Training Program

This section documents the training program for the HyperFlex solution.

## Training Overview

Training ensures all user groups achieve competency with the HyperFlex infrastructure.

### Training Schedule

<!-- TABLE_CONFIG: widths=[10, 28, 17, 10, 15, 20] -->
| ID | Module Name | Audience | Hours | Format | Prerequisites |
|----|-------------|----------|-------|--------|---------------|
| TRN-001 | HyperFlex Administration | HCI Team | 8 | Hands-On | None |
| TRN-002 | Intersight Cloud Management | HCI Team | 4 | Hands-On | TRN-001 |
| TRN-003 | vSphere 8 on HyperFlex | Virt Team | 8 | Hands-On | VMware basics |
| TRN-004 | Backup and Recovery | Backup Team | 4 | Hands-On | Veeam basics |

**Total Training Hours:** 24 hours per SOW

## Training Materials

The following training materials are provided.

- HyperFlex Quick Start Guide
- Intersight User Guide
- vSphere on HyperFlex Best Practices
- Troubleshooting Runbook
- Hands-on Lab Exercises

# Appendices

## Appendix A: Environment Reference

### Production Environment

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Parameter | Value | Description |
|-----------|-------|-------------|
| Cluster Name | hx-cluster-prod | HyperFlex cluster identifier |
| Management IP | 10.100.1.20 | Cluster management interface |
| vCenter | vcenter.client.local | VMware management server |
| Intersight | intersight.com | Cloud management portal |
| Node Count | 4 | HX240c M5 nodes |
| Replication Factor | 3 | Data protection level |

## Appendix B: Troubleshooting Guide

### Common Issues and Resolutions

<!-- TABLE_CONFIG: widths=[25, 35, 40] -->
| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| Cluster unhealthy | Node offline | Check node power and connectivity |
| High latency | Resource contention | Review DRS settings, check workload |
| vMotion failure | Network issue | Verify vMotion VLAN connectivity |
| Backup failure | Snapshot issue | Check HyperFlex snapshot status |
| Intersight disconnected | Internet outage | Verify outbound HTTPS connectivity |

### Diagnostic Commands

```bash
# HyperFlex cluster diagnostics
ssh admin@10.100.1.20
hxcli cluster health
hxcli node list
hxcli disk list --summary

# Check storage controller VMs
hxcli stctl status

# ESXi host diagnostics
esxcli system version get
esxcli storage vmfs extent list
esxcli network nic list
```

## Appendix C: Reference Documentation

### Cisco Documentation

- Cisco HyperFlex Systems Installation Guide
- Cisco Intersight User Guide
- Cisco UCS Manager CLI Configuration Guide

### VMware Documentation

- VMware vSphere 8 Documentation
- vSphere on HyperFlex Best Practices
- VMware PowerCLI Reference

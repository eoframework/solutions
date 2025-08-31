# Dell VxRail HCI - Terraform Infrastructure
# Hyper-converged infrastructure deployment for Dell VxRail platform

terraform {
  required_version = ">= 1.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configure vSphere provider for VxRail management
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  
  # Allow unverified SSL certificates for lab environments
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Local values
locals {
  # Common tags for all resources
  common_tags = {
    Environment    = var.environment
    Project       = var.project_name
    Solution      = "Dell VxRail HCI"
    ManagedBy     = "Terraform"
    Owner         = var.resource_owner
  }
  
  # VxRail cluster naming
  cluster_name = "${var.project_name}-${var.environment}-vxrail"
}

# Random resources for unique naming
resource "random_id" "deployment_id" {
  byte_length = 4
}

# Data sources for vSphere environment
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = var.datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.compute_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "management_network" {
  name          = var.management_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vmotion_network" {
  name          = var.vmotion_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vsan_network" {
  name          = var.vsan_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm_network" {
  name          = var.vm_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# VxRail Manager VM configuration
data "vsphere_virtual_machine" "vxrail_manager_template" {
  name          = var.vxrail_manager_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Resource pool for VxRail workloads
resource "vsphere_resource_pool" "vxrail_pool" {
  name                    = "${local.cluster_name}-pool"
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  
  cpu_share_level    = "normal"
  cpu_reservation    = var.cpu_reservation
  cpu_expandable     = true
  cpu_limit          = var.cpu_limit
  
  memory_share_level = "normal"
  memory_reservation = var.memory_reservation
  memory_expandable  = true
  memory_limit       = var.memory_limit
  
  tags = [
    vsphere_tag.environment.id,
    vsphere_tag.solution.id
  ]
}

# vSphere tags for resource organization
resource "vsphere_tag_category" "environment" {
  name               = "Environment"
  description        = "Environment classification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine", "ResourcePool", "Datastore"]
}

resource "vsphere_tag" "environment" {
  name        = var.environment
  category_id = vsphere_tag_category.environment.id
  description = "Environment: ${var.environment}"
}

resource "vsphere_tag_category" "solution" {
  name               = "Solution"
  description        = "Solution classification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine", "ResourcePool", "Datastore"]
}

resource "vsphere_tag" "solution" {
  name        = "Dell-VxRail-HCI"
  category_id = vsphere_tag_category.solution.id
  description = "Dell VxRail Hyper-Converged Infrastructure"
}

# Distributed Virtual Switch configuration
resource "vsphere_distributed_virtual_switch" "vds" {
  name              = "${local.cluster_name}-vds"
  datacenter_id     = data.vsphere_datacenter.dc.id
  uplinks           = var.vds_uplinks
  active_uplinks    = var.vds_active_uplinks
  standby_uplinks   = var.vds_standby_uplinks
  
  # vLAN configuration for different traffic types
  max_mtu = var.vds_max_mtu
  
  # Load balancing and failover
  port_policy {
    active_uplinks    = var.vds_active_uplinks
    standby_uplinks   = var.vds_standby_uplinks
  }
  
  tags = [
    vsphere_tag.environment.id,
    vsphere_tag.solution.id
  ]
}

# Port groups for different network traffic types
resource "vsphere_distributed_port_group" "management_pg" {
  name                            = "${local.cluster_name}-management-pg"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.vds.id
  
  vlan_id = var.management_vlan_id
  
  active_uplinks  = var.vds_active_uplinks
  standby_uplinks = var.vds_standby_uplinks
}

resource "vsphere_distributed_port_group" "vmotion_pg" {
  name                            = "${local.cluster_name}-vmotion-pg"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.vds.id
  
  vlan_id = var.vmotion_vlan_id
  
  active_uplinks  = var.vds_active_uplinks
  standby_uplinks = var.vds_standby_uplinks
}

resource "vsphere_distributed_port_group" "vsan_pg" {
  name                            = "${local.cluster_name}-vsan-pg"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.vds.id
  
  vlan_id = var.vsan_vlan_id
  
  active_uplinks  = var.vds_active_uplinks
  standby_uplinks = var.vds_standby_uplinks
}

resource "vsphere_distributed_port_group" "vm_pg" {
  name                            = "${local.cluster_name}-vm-pg"
  distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.vds.id
  
  vlan_id = var.vm_vlan_id
  
  active_uplinks  = var.vds_active_uplinks
  standby_uplinks = var.vds_standby_uplinks
}

# VxRail node configuration (example for first node)
resource "vsphere_virtual_machine" "vxrail_node" {
  count = var.vxrail_node_count
  
  name             = "${local.cluster_name}-node-${count.index + 1}"
  resource_pool_id = vsphere_resource_pool.vxrail_pool.id
  datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  
  num_cpus               = var.node_cpu_count
  num_cores_per_socket   = var.node_cores_per_socket
  memory                 = var.node_memory_mb
  guest_id               = data.vsphere_virtual_machine.vxrail_manager_template.guest_id
  scsi_type              = data.vsphere_virtual_machine.vxrail_manager_template.scsi_type
  firmware               = data.vsphere_virtual_machine.vxrail_manager_template.firmware
  
  # Enable hardware features for performance
  enable_disk_uuid       = true
  cpu_hot_add_enabled    = true
  cpu_hot_remove_enabled = true
  memory_hot_add_enabled = true
  
  # Network interfaces for different traffic types
  network_interface {
    network_id   = vsphere_distributed_port_group.management_pg.id
    adapter_type = "vmxnet3"
  }
  
  network_interface {
    network_id   = vsphere_distributed_port_group.vmotion_pg.id
    adapter_type = "vmxnet3"
  }
  
  network_interface {
    network_id   = vsphere_distributed_port_group.vsan_pg.id
    adapter_type = "vmxnet3"
  }
  
  network_interface {
    network_id   = vsphere_distributed_port_group.vm_pg.id
    adapter_type = "vmxnet3"
  }
  
  # Boot disk
  disk {
    label            = "disk0"
    size             = var.boot_disk_size_gb
    thin_provisioned = false
    eagerly_scrub    = true
    unit_number      = 0
  }
  
  # vSAN cache disk (SSD)
  disk {
    label            = "cache-disk"
    size             = var.cache_disk_size_gb
    thin_provisioned = false
    eagerly_scrub    = true
    unit_number      = 1
  }
  
  # vSAN capacity disks
  dynamic "disk" {
    for_each = range(var.capacity_disk_count)
    content {
      label            = "capacity-disk-${disk.value}"
      size             = var.capacity_disk_size_gb
      thin_provisioned = false
      eagerly_scrub    = true
      unit_number      = disk.value + 2
    }
  }
  
  # VM customization
  clone {
    template_uuid = data.vsphere_virtual_machine.vxrail_manager_template.id
    
    customize {
      linux_options {
        host_name = "${local.cluster_name}-node-${count.index + 1}"
        domain    = var.domain_name
      }
      
      network_interface {
        ipv4_address = cidrhost(var.management_subnet, 10 + count.index)
        ipv4_netmask = split("/", var.management_subnet)[1]
      }
      
      ipv4_gateway    = var.management_gateway
      dns_server_list = var.dns_servers
    }
  }
  
  # Wait for network connectivity
  wait_for_guest_net_timeout = 5
  wait_for_guest_ip_timeout  = 5
  
  tags = [
    vsphere_tag.environment.id,
    vsphere_tag.solution.id
  ]
}

# Storage policy for vSAN
resource "vsphere_storage_policy" "vxrail_policy" {
  name = "${local.cluster_name}-vsan-policy"
  
  tag_rules {
    tag_category                 = vsphere_tag_category.solution.name
    tags                        = [vsphere_tag.solution.name]
    include_datastores_with_tags = true
  }
}

# DRS (Distributed Resource Scheduler) rules
resource "vsphere_drs_vm_override" "vxrail_nodes_override" {
  count                = var.vxrail_node_count
  compute_cluster_id   = data.vsphere_compute_cluster.cluster.id
  virtual_machine_id   = vsphere_virtual_machine.vxrail_node[count.index].id
  drs_automation_level = var.drs_automation_level
}

# HA (High Availability) configuration
resource "vsphere_ha_vm_override" "vxrail_nodes_ha" {
  count                        = var.vxrail_node_count
  compute_cluster_id          = data.vsphere_compute_cluster.cluster.id
  virtual_machine_id          = vsphere_virtual_machine.vxrail_node[count.index].id
  ha_vm_restart_priority      = "high"
  ha_vm_restart_timeout       = 600
  ha_host_isolation_response  = "powerOff"
}
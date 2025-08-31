# Dell PowerEdge CI Infrastructure - Terraform Configuration
# Infrastructure as Code for CI/CD pipeline infrastructure

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

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Data sources
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# CI Master Node
resource "vsphere_virtual_machine" "ci_master" {
  name             = "${var.project_name}-ci-master"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.ci_master_cpu
  memory   = var.ci_master_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.ci_master_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.project_name}-ci-master"
        domain    = var.domain_name
      }

      network_interface {
        ipv4_address = var.ci_master_ip
        ipv4_netmask = var.network_netmask
      }

      ipv4_gateway    = var.network_gateway
      dns_server_list = var.dns_servers
    }
  }

  tags = [
    vsphere_tag.environment.id,
    vsphere_tag.role_ci_master.id
  ]
}

# CI Worker Nodes
resource "vsphere_virtual_machine" "ci_workers" {
  count            = var.ci_worker_count
  name             = "${var.project_name}-ci-worker-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.ci_worker_cpu
  memory   = var.ci_worker_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.ci_worker_disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.project_name}-ci-worker-${count.index + 1}"
        domain    = var.domain_name
      }

      network_interface {
        ipv4_address = cidrhost(var.ci_worker_subnet, count.index + 10)
        ipv4_netmask = var.network_netmask
      }

      ipv4_gateway    = var.network_gateway
      dns_server_list = var.dns_servers
    }
  }

  tags = [
    vsphere_tag.environment.id,
    vsphere_tag.role_ci_worker.id
  ]
}

# Tags for resource management
resource "vsphere_tag_category" "environment" {
  name               = "Environment"
  description        = "Environment classification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine"]
}

resource "vsphere_tag" "environment" {
  name        = var.environment
  category_id = vsphere_tag_category.environment.id
  description = "Environment: ${var.environment}"
}

resource "vsphere_tag_category" "role" {
  name               = "Role"
  description        = "Server role classification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine"]
}

resource "vsphere_tag" "role_ci_master" {
  name        = "CI-Master"
  category_id = vsphere_tag_category.role.id
  description = "CI/CD Master Node"
}

resource "vsphere_tag" "role_ci_worker" {
  name        = "CI-Worker"
  category_id = vsphere_tag_category.role.id
  description = "CI/CD Worker Node"
}
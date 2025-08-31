# Dell VxRail Hyperconverged Infrastructure - Terraform Configuration
# Complete hyperconverged infrastructure deployment with integrated storage and compute

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

# Configure vSphere provider
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  
  allow_unverified_ssl = var.allow_unverified_ssl
}

# Local values
locals {
  cluster_name = "${var.project_name}-${var.environment}-hyperconverged"
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Solution    = "Dell VxRail Hyperconverged"
    ManagedBy   = "Terraform"
  }
}

# Data sources
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.compute_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# VxRail hyperconverged cluster configuration
resource "vsphere_compute_cluster" "vxrail_cluster" {
  name            = local.cluster_name
  datacenter_id   = data.vsphere_datacenter.dc.id
  
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  
  ha_enabled = true
  
  vsan_enabled = true
  
  tags = [
    vsphere_tag.environment.id,
    vsphere_tag.solution.id
  ]
}

# Tags for resource management
resource "vsphere_tag_category" "environment" {
  name               = "Environment"
  description        = "Environment classification"
  cardinality        = "SINGLE"
  associable_types   = ["VirtualMachine", "ClusterComputeResource"]
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
  associable_types   = ["VirtualMachine", "ClusterComputeResource"]
}

resource "vsphere_tag" "solution" {
  name        = "Dell-VxRail-Hyperconverged"
  category_id = vsphere_tag_category.solution.id
  description = "Dell VxRail Hyperconverged Infrastructure"
}
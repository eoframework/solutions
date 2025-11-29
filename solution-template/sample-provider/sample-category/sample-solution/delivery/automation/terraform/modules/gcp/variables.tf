# Google Cloud Module Variables
# Variables specific to GCP provider resources

# Core Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    cidr   = string
    region = string
  }))
  default = {
    web = {
      cidr   = "10.2.1.0/24"
      region = "us-central1"
    }
    app = {
      cidr   = "10.2.2.0/24"
      region = "us-central1"
    }
    data = {
      cidr   = "10.2.3.0/24"
      region = "us-central1"
    }
  }
}

# Security Variables
variable "firewall_rules" {
  description = "Firewall rule configurations"
  type = map(object({
    direction     = string
    ports         = list(string)
    source_ranges = list(string)
    target_tags   = list(string)
  }))
  default = {}
}

variable "enable_iam_policies" {
  description = "Enable IAM policies"
  type        = bool
  default     = true
}

# Compute Variables
variable "instances" {
  description = "Compute Engine instance configurations"
  type = map(object({
    machine_type = string
    zone         = string
    image        = string
    disk_size    = number
    disk_type    = string
    preemptible  = bool
  }))
  default = {}
}

variable "sql_config" {
  description = "Cloud SQL configuration"
  type = object({
    database_version   = string
    tier              = string
    disk_size         = number
    disk_type         = string
    backup_enabled    = bool
    binary_log_enabled = bool
    ipv4_enabled      = bool
  })
  default = {
    database_version   = "MYSQL_8_0"
    tier              = "db-f1-micro"
    disk_size         = 20
    disk_type         = "PD_STANDARD"
    backup_enabled    = true
    binary_log_enabled = false
    ipv4_enabled      = false
  }
}

# Instance Group Variables
variable "enable_instance_group" {
  description = "Enable Managed Instance Group"
  type        = bool
  default     = false
}

variable "instance_group_config" {
  description = "Managed Instance Group configuration"
  type = object({
    base_instance_name = string
    target_size        = number
    zone               = string
    template = object({
      machine_type = string
      source_image = string
      disk_size    = number
      disk_type    = string
      network_tags = list(string)
    })
    auto_healing_policies = object({
      health_check      = string
      initial_delay_sec = number
    })
  })
  default = {
    base_instance_name = "instance"
    target_size        = 2
    zone               = "us-central1-a"
    template = {
      machine_type = "e2-medium"
      source_image = "ubuntu-os-cloud/ubuntu-2004-lts"
      disk_size    = 20
      disk_type    = "pd-standard"
      network_tags = ["web-server"]
    }
    auto_healing_policies = {
      health_check      = ""
      initial_delay_sec = 300
    }
  }
}

# Load Balancer Variables
variable "enable_load_balancer" {
  description = "Enable load balancer"
  type        = bool
  default     = false
}

variable "load_balancer_config" {
  description = "Load balancer configuration"
  type = object({
    type                = string # INTERNAL, EXTERNAL
    ip_protocol         = string # TCP, UDP
    load_balancing_scheme = string # INTERNAL, EXTERNAL
    port_range          = string
  })
  default = {
    type                = "EXTERNAL"
    ip_protocol         = "TCP"
    load_balancing_scheme = "EXTERNAL"
    port_range          = "80"
  }
}
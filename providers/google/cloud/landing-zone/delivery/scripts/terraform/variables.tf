variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "organization_id" {
  description = "The Google Cloud Organization ID"
  type        = string
  default     = ""
}

variable "parent_folder_id" {
  description = "Parent folder ID if not using organization"
  type        = string
  default     = ""
}

variable "billing_account_id" {
  description = "Billing account ID for budget alerts"
  type        = string
  default     = ""
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "network_prefix" {
  description = "Prefix for network resource names"
  type        = string
  default     = "lz"
}

variable "terraform_state_bucket" {
  description = "GCS bucket for Terraform state"
  type        = string
}

variable "create_folders" {
  description = "Whether to create organizational folders"
  type        = bool
  default     = true
}

# Network Configuration
variable "internal_ip_range" {
  description = "Internal IP range for firewall rules"
  type        = string
  default     = "10.0.0.0/8"
}

variable "hub_subnets" {
  description = "Hub VPC subnets configuration"
  type = map(object({
    cidr            = string
    region          = string
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = {
    hub-central = {
      cidr   = "10.0.1.0/24"
      region = "us-central1"
    }
    hub-east = {
      cidr   = "10.1.1.0/24"
      region = "us-east1"
    }
  }
}

variable "shared_services_subnets" {
  description = "Shared services VPC subnets configuration"
  type = map(object({
    cidr   = string
    region = string
  }))
  default = {
    shared-central = {
      cidr   = "10.0.2.0/24"
      region = "us-central1"
    }
    shared-east = {
      cidr   = "10.1.2.0/24"
      region = "us-east1"
    }
  }
}

variable "production_spokes" {
  description = "Production spoke VPCs configuration"
  type = map(object({
    cidr            = string
    region          = string
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = {
    app1 = {
      cidr   = "10.10.0.0/16"
      region = "us-central1"
      secondary_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "192.168.0.0/16"
        },
        {
          range_name    = "services"
          ip_cidr_range = "172.16.0.0/16"
        }
      ]
    }
    app2 = {
      cidr   = "10.20.0.0/16"
      region = "us-east1"
    }
  }
}

# DNS Configuration
variable "enable_private_dns" {
  description = "Enable private DNS zone"
  type        = bool
  default     = true
}

variable "private_dns_domain" {
  description = "Private DNS domain name"
  type        = string
  default     = "internal.example.com"
}

# Security Configuration
variable "kms_location" {
  description = "Location for KMS key ring"
  type        = string
  default     = "us-central1"
}

variable "enable_security_logging" {
  description = "Enable security audit logging"
  type        = bool
  default     = true
}

variable "security_logs_retention_days" {
  description = "Retention period for security logs in days"
  type        = number
  default     = 365
}

variable "logs_bucket_location" {
  description = "Location for security logs bucket"
  type        = string
  default     = "US"
}

variable "enable_scc_notifications" {
  description = "Enable Security Command Center notifications"
  type        = bool
  default     = true
}

variable "scc_notification_topic" {
  description = "Pub/Sub topic for SCC notifications"
  type        = string
  default     = ""
}

# Organization Policies
variable "enable_org_policies" {
  description = "Enable organization policies"
  type        = bool
  default     = true
}

# Budget Configuration
variable "enable_budget_alerts" {
  description = "Enable budget alerts"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 10000
}

variable "budget_notification_channels" {
  description = "Notification channels for budget alerts"
  type        = list(string)
  default     = []
}

# IAM Configuration
variable "folder_iam_members" {
  description = "IAM members for folders"
  type = map(object({
    security_admins       = optional(list(string), [])
    network_admins        = optional(list(string), [])
    project_creators      = optional(list(string), [])
    billing_admins        = optional(list(string), [])
    org_policy_admins     = optional(list(string), [])
    compute_admins        = optional(list(string), [])
    storage_admins        = optional(list(string), [])
    monitoring_viewers    = optional(list(string), [])
  }))
  default = {}
}

variable "essential_contacts" {
  description = "Essential contacts for the organization"
  type = map(object({
    email                    = string
    notification_category_subscriptions = list(string)
    language_tag            = optional(string, "en-US")
  }))
  default = {}
}

# Monitoring Configuration
variable "enable_monitoring_workspace" {
  description = "Enable Cloud Monitoring workspace"
  type        = bool
  default     = true
}

variable "notification_channels" {
  description = "Monitoring notification channels"
  type = map(object({
    type         = string
    display_name = string
    labels       = map(string)
    user_labels  = optional(map(string), {})
    enabled      = optional(bool, true)
  }))
  default = {}
}

# VPN Configuration (optional)
variable "enable_vpn" {
  description = "Enable VPN gateway"
  type        = bool
  default     = false
}

variable "vpn_config" {
  description = "VPN configuration"
  type = object({
    peer_gateways = map(object({
      ip_address = string
      shared_secret = string
      peer_ip_ranges = list(string)
    }))
    local_traffic_selector  = optional(list(string), ["10.0.0.0/8"])
    remote_traffic_selector = optional(list(string), ["192.168.0.0/16"])
  })
  default = {
    peer_gateways = {}
  }
}

# Interconnect Configuration (optional)
variable "enable_interconnect" {
  description = "Enable Cloud Interconnect"
  type        = bool
  default     = false
}

variable "interconnect_config" {
  description = "Interconnect configuration"
  type = object({
    interconnect_attachment_name = string
    router_name                 = string
    bgp_asn                    = number
    vlan_tag                   = number
    bandwidth                  = string
    admin_enabled              = bool
  })
  default = {
    interconnect_attachment_name = ""
    router_name                 = ""
    bgp_asn                    = 65000
    vlan_tag                   = 100
    bandwidth                  = "BPS_1G"
    admin_enabled              = true
  }
}

# Firewall Configuration
variable "custom_firewall_rules" {
  description = "Custom firewall rules"
  type = map(object({
    description             = string
    direction              = string
    priority               = number
    source_ranges          = optional(list(string), [])
    destination_ranges     = optional(list(string), [])
    source_tags            = optional(list(string), [])
    target_tags            = optional(list(string), [])
    allow_rules = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny_rules = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
  }))
  default = {}
}

# Labels
variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    created_by = "terraform"
    project    = "landing-zone"
  }
}

# Feature Flags
variable "enable_shielded_vm_policy" {
  description = "Enable shielded VM organization policy"
  type        = bool
  default     = true
}

variable "enable_os_login_policy" {
  description = "Enable OS Login organization policy"
  type        = bool
  default     = true
}

variable "enable_serial_port_policy" {
  description = "Enable disable serial port access policy"
  type        = bool
  default     = true
}

variable "enable_ip_forwarding_policy" {
  description = "Enable disable IP forwarding policy"
  type        = bool
  default     = true
}

variable "enable_uniform_bucket_level_access_policy" {
  description = "Enable uniform bucket level access policy"
  type        = bool
  default     = true
}

# Cloud Asset Inventory
variable "enable_cloud_asset_inventory" {
  description = "Enable Cloud Asset Inventory feeds"
  type        = bool
  default     = true
}

variable "asset_inventory_config" {
  description = "Cloud Asset Inventory configuration"
  type = object({
    feed_output_config = object({
      bigquery_destination = optional(object({
        dataset = string
        table   = string
        force   = optional(bool, false)
      }))
      pubsub_destination = optional(object({
        topic = string
      }))
    })
    asset_types = optional(list(string), [])
    asset_names = optional(list(string), [])
  })
  default = {
    feed_output_config = {}
  }
}

# Backup and Disaster Recovery
variable "enable_backup_policies" {
  description = "Enable backup policies"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

# Compute Configuration
variable "default_compute_service_account_scopes" {
  description = "Default scopes for compute service accounts"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

variable "enable_compute_instance_templates" {
  description = "Create default compute instance templates"
  type        = bool
  default     = false
}

variable "compute_instance_templates" {
  description = "Compute instance templates configuration"
  type = map(object({
    machine_type   = string
    disk_size_gb   = number
    disk_type      = string
    image_family   = string
    image_project  = string
    startup_script = optional(string, "")
    metadata       = optional(map(string), {})
    tags          = optional(list(string), [])
    network_tags  = optional(list(string), [])
  }))
  default = {}
}
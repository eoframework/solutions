#------------------------------------------------------------------------------
# GCP Shared VPC Module Variables
#------------------------------------------------------------------------------

variable "host_project_id" {
  description = "Host project ID for Shared VPC"
  type        = string
}

variable "region" {
  description = "GCP region for network resources"
  type        = string
}

variable "delete_default_routes" {
  description = "Delete default routes on VPC creation"
  type        = bool
  default     = false
}

variable "network" {
  description = "Network configuration object"
  type = object({
    vpc_name                      = string
    vpc_routing_mode              = string
    subnet_dev_cidr               = string
    subnet_staging_cidr           = string
    subnet_prod_cidr              = string
    subnet_shared_cidr            = string
    enable_private_google_access  = bool
    enable_flow_logs              = bool
    flow_log_sampling             = number
    flow_log_aggregation_interval = string
  })
}

variable "nat" {
  description = "Cloud NAT configuration object"
  type = object({
    enabled          = bool
    gateway_count    = number
    logging_enabled  = bool
    min_ports_per_vm = number
    cloud_router_asn = number
  })
  default = {
    enabled          = true
    gateway_count    = 1
    logging_enabled  = true
    min_ports_per_vm = 64
    cloud_router_asn = 64514
  }
}

variable "firewall" {
  description = "Firewall configuration"
  type = object({
    # Google Cloud standard ranges - these are fixed by Google
    iap_cidr_range           = optional(string, "35.235.240.0/20")
    health_check_cidr_ranges = optional(list(string), ["35.191.0.0/16", "130.211.0.0/22"])
    # Firewall rule priorities
    deny_all_priority        = optional(number, 65534)
    allow_internal_priority  = optional(number, 1000)
    allow_iap_priority       = optional(number, 1000)
    allow_health_priority    = optional(number, 1000)
  })
  default = {}
}

variable "common_tags" {
  description = "Common labels for all resources"
  type        = map(string)
  default     = {}
}

# Generic AWS VPC Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting flow logs"
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Network Configuration (grouped object)
#------------------------------------------------------------------------------

variable "network" {
  description = "VPC and networking configuration"
  type = object({
    vpc_cidr                   = string
    public_subnet_cidrs        = list(string)
    private_subnet_cidrs       = list(string)
    database_subnet_cidrs      = list(string)
    enable_dns_hostnames       = bool
    enable_dns_support         = bool
    enable_nat_gateway         = bool
    single_nat_gateway         = bool
    map_public_ip_on_launch    = optional(bool, true)
    enable_flow_logs           = bool
    flow_log_retention_days    = number
    flow_log_traffic_type      = optional(string, "ALL")
    flow_log_destination_type  = optional(string, "cloud-watch-logs")
    flow_log_aggregation_interval = optional(number, 60)
    https_port                 = optional(number, 443)
    http_port                  = optional(number, 80)
    ssh_port                   = optional(number, 22)
  })
}

#------------------------------------------------------------------------------
# Networking Module Variables (Solution-Level)
#------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "network" {
  description = "Network configuration"
  type = object({
    vpc_cidr                = string
    enable_dns_hostnames    = optional(bool, true)
    enable_dns_support      = optional(bool, true)
    public_subnet_cidrs     = list(string)
    private_subnet_cidrs    = list(string)
    enable_nat_gateway      = bool
    single_nat_gateway      = bool
    enable_flow_logs        = bool
    flow_log_retention_days = number
  })
}

#------------------------------------------------------------------------------
# AWS Route53 Module Variables
#------------------------------------------------------------------------------

variable "cluster_name" {
  description = "OpenShift cluster name"
  type        = string
}

variable "base_domain" {
  description = "Base DNS domain"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
  default     = null
}

variable "create_hosted_zone" {
  description = "Create new hosted zone or use existing"
  type        = bool
  default     = false
}

variable "private_zone" {
  description = "Create private hosted zone"
  type        = bool
  default     = false
}

variable "api_lb_dns_name" {
  description = "API load balancer DNS name"
  type        = string
}

variable "api_lb_zone_id" {
  description = "API load balancer zone ID"
  type        = string
}

variable "ingress_lb_dns_name" {
  description = "Ingress load balancer DNS name"
  type        = string
  default     = null
}

variable "ingress_lb_zone_id" {
  description = "Ingress load balancer zone ID"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

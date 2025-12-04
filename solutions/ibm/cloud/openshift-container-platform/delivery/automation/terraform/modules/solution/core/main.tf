#------------------------------------------------------------------------------
# OpenShift Solution - Core Module
#------------------------------------------------------------------------------
# Orchestrates core infrastructure using AWS provider modules:
# - VPC and networking
# - Security groups
# - EC2 instances for OpenShift nodes
# - Load balancers
# - Route53 DNS records
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.cluster.name}-${var.environment}"

  common_tags = merge(var.common_tags, {
    Environment = var.environment
    Cluster     = var.cluster.name
    Platform    = "openshift"
    ManagedBy   = "terraform"
  })

  availability_zones = length(var.network.availability_zones) > 0 ? var.network.availability_zones : [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]
}

#------------------------------------------------------------------------------
# VPC and Networking
#------------------------------------------------------------------------------
module "vpc" {
  source = "../../aws/vpc"

  name_prefix          = local.name_prefix
  cluster_name         = var.cluster.name
  vpc_cidr             = var.network.vpc_cidr
  public_subnet_cidrs  = var.network.public_subnets
  private_subnet_cidrs = var.network.private_subnets
  availability_zones   = local.availability_zones
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "prod"

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
module "security_groups" {
  source = "../../aws/security-group"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = module.vpc.vpc_cidr
  allowed_api_cidrs = var.security.allowed_api_cidrs

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# OpenShift Nodes (EC2)
#------------------------------------------------------------------------------
module "ocp_nodes" {
  source = "../../aws/ec2-ocp"

  name_prefix    = local.name_prefix
  cluster_name   = var.cluster.name
  rhcos_ami      = var.compute.rhcos_ami

  private_subnet_ids               = module.vpc.private_subnet_ids
  control_plane_security_group_ids = [module.security_groups.control_plane_security_group_id]
  worker_security_group_ids        = [module.security_groups.worker_security_group_id]

  key_name    = var.compute.key_name
  kms_key_arn = var.security.kms_key_arn

  # Bootstrap (set to false after cluster initialization)
  create_bootstrap          = var.cluster.create_bootstrap
  bootstrap_instance_type   = var.compute.control_plane_instance_type
  bootstrap_ignition_config = var.ignition.bootstrap

  # Control plane configuration
  control_plane_count         = var.compute.control_plane_count
  control_plane_instance_type = var.compute.control_plane_instance_type
  master_ignition_config      = var.ignition.master

  # Worker configuration
  worker_count         = var.compute.worker_count
  worker_instance_type = var.compute.worker_instance_type
  worker_ignition_config = var.ignition.worker

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Load Balancers
#------------------------------------------------------------------------------
module "nlb" {
  source = "../../aws/nlb"

  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  private_subnet_ids         = module.vpc.private_subnet_ids
  control_plane_instance_ids = module.ocp_nodes.control_plane_instance_ids
  worker_instance_ids        = module.ocp_nodes.worker_instance_ids
  api_internal               = var.cluster.api_internal
  create_ingress_lb          = true

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# DNS Records
#------------------------------------------------------------------------------
module "dns" {
  source = "../../aws/route53"

  cluster_name        = var.cluster.name
  base_domain         = var.cluster.base_domain
  vpc_id              = module.vpc.vpc_id
  create_hosted_zone  = var.dns.create_hosted_zone
  private_zone        = var.dns.private_zone
  api_lb_dns_name     = module.nlb.api_lb_dns_name
  api_lb_zone_id      = module.nlb.api_lb_zone_id
  ingress_lb_dns_name = module.nlb.ingress_lb_dns_name
  ingress_lb_zone_id  = module.nlb.ingress_lb_zone_id

  common_tags = local.common_tags
}

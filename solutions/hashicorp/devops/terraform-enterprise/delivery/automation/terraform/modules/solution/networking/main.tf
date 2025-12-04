#------------------------------------------------------------------------------
# Networking Module (Solution-Level)
#------------------------------------------------------------------------------
# Composes aws/vpc provider module for TFE platform networking
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# VPC (uses aws/vpc provider module)
#------------------------------------------------------------------------------
module "vpc" {
  source = "../../aws/vpc"

  name_prefix          = var.name_prefix
  common_tags          = var.common_tags
  vpc_cidr             = var.network.vpc_cidr
  enable_dns_hostnames = var.network.enable_dns_hostnames
  enable_dns_support   = var.network.enable_dns_support
  public_subnet_cidrs  = var.network.public_subnet_cidrs
  private_subnet_cidrs = var.network.private_subnet_cidrs
  enable_nat_gateway   = var.network.enable_nat_gateway
  single_nat_gateway   = var.network.single_nat_gateway
  enable_flow_logs     = var.network.enable_flow_logs
  flow_log_retention_days = var.network.flow_log_retention_days
  create_db_subnet_group = true
  create_database_sg     = true

  # EKS-specific subnet tags for TFE on EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  }
}

# AWS Provider-Specific Module
# This module contains all AWS-specific resources and configurations

# Local values for AWS resource naming
locals {
  aws_name_prefix = "${var.name_prefix}-aws"

  # Common tags for all AWS resources
  aws_tags = merge(var.tags, {
    Provider = "AWS"
    Region   = var.region
  })
}

# AWS Networking Module
module "networking" {
  source = "./networking"

  name_prefix = local.aws_name_prefix
  tags        = local.aws_tags

  # VPC Configuration
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# AWS Security Module
module "security" {
  source = "./security"

  name_prefix = local.aws_name_prefix
  tags        = local.aws_tags
}

# AWS Compute Module
module "compute" {
  source = "./compute"

  name_prefix = local.aws_name_prefix
  tags        = local.aws_tags
}

# AWS Monitoring Module
module "monitoring" {
  source = "./monitoring"

  project_name        = var.project_name
  environment         = var.environment
  name_prefix         = local.aws_name_prefix
  region              = var.region
  tags                = local.aws_tags
  log_retention_days  = var.log_retention_days
}

# Example AWS-specific resources
resource "aws_s3_bucket" "app_bucket" {
  bucket = "${local.aws_name_prefix}-app-bucket-${random_id.bucket_suffix.hex}"

  tags = merge(local.aws_tags, {
    Name = "${local.aws_name_prefix}-app-bucket"
  })
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
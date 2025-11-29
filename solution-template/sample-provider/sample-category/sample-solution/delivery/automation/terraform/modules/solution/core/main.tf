# Solution Core Module
# Deploys: VPC, Subnets, NAT Gateway, ALB, ASG, and base security groups
#
# This module is always required - it provides the foundational infrastructure
# that other solution modules depend on.
#
# Uses generic AWS modules for reusable components.

terraform {
  required_version = ">= 1.6.0"
}

locals {
  # Use provided name_prefix, or fall back to project_name-environment
  name_prefix = var.name_prefix != "" ? var.name_prefix : "${var.project_name}-${var.environment}"

  # Tags are inherited from environment (additional_tags contains all common tags)
  # Only add minimal tags if additional_tags is empty (backward compatibility)
  common_tags = length(var.additional_tags) > 0 ? var.additional_tags : {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

#------------------------------------------------------------------------------
# VPC and Networking (using generic VPC module)
#------------------------------------------------------------------------------

module "vpc" {
  source = "../../aws/vpc"

  name_prefix           = local.name_prefix
  tags                  = local.common_tags
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support
  enable_nat_gateway    = var.enable_nat_gateway
  single_nat_gateway    = var.single_nat_gateway
  enable_flow_logs      = var.enable_flow_logs
  flow_log_retention    = var.flow_log_retention_days
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = toset(var.allowed_https_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from allowed CIDRs"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = toset(var.allowed_http_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTP from allowed CIDRs (redirect to HTTPS)"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "alb_to_instances" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Allow traffic to application instances"
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instances.id
}

# Instance Security Group
resource "aws_security_group" "instances" {
  name        = "${local.name_prefix}-instances-sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-instances-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "instances_from_alb" {
  security_group_id            = aws_security_group.instances.id
  description                  = "Allow traffic from ALB"
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "instances_ssh" {
  for_each = var.enable_ssh_access ? toset(var.allowed_ssh_cidrs) : toset([])

  security_group_id = aws_security_group.instances.id
  description       = "SSH access from allowed CIDRs"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "instances_all" {
  security_group_id = aws_security_group.instances.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Database Security Group
resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-database-sg"
  description = "Security group for database instances"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "database_from_instances" {
  security_group_id            = aws_security_group.database.id
  description                  = "Allow traffic from application instances"
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instances.id
}

# Cache Security Group
resource "aws_security_group" "cache" {
  name        = "${local.name_prefix}-cache-sg"
  description = "Security group for cache instances"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cache-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "cache_from_instances" {
  security_group_id            = aws_security_group.cache.id
  description                  = "Allow traffic from application instances"
  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instances.id
}

#------------------------------------------------------------------------------
# IAM Role for EC2 Instances
#------------------------------------------------------------------------------

resource "aws_iam_role" "instances" {
  count = var.enable_instance_profile ? 1 : 0

  name = "${local.name_prefix}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_instance_profile && var.enable_ssm_access ? 1 : 0

  role       = aws_iam_role.instances[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.enable_instance_profile ? 1 : 0

  role       = aws_iam_role.instances[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "instances" {
  count = var.enable_instance_profile ? 1 : 0

  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.instances[0].name

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Application Load Balancer (using generic ALB module)
#------------------------------------------------------------------------------

module "alb" {
  source = "../../aws/alb"
  count  = var.enable_alb ? 1 : 0

  name_prefix              = local.name_prefix
  tags                     = local.common_tags
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnet_ids
  security_group_ids       = [aws_security_group.alb.id]
  internal                 = var.alb_internal
  enable_deletion_protection = var.enable_lb_deletion_protection
  target_port              = var.app_port
  health_check_path        = var.health_check_path
  health_check_interval    = var.health_check_interval
  health_check_timeout     = var.health_check_timeout
  healthy_threshold        = var.healthy_threshold
  unhealthy_threshold      = var.unhealthy_threshold
  certificate_arn          = var.acm_certificate_arn
}

#------------------------------------------------------------------------------
# Auto Scaling Group (using generic ASG module)
#------------------------------------------------------------------------------

module "asg" {
  source = "../../aws/asg"
  count  = var.enable_auto_scaling ? 1 : 0

  name_prefix            = local.name_prefix
  tags                   = local.common_tags
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  security_group_ids     = [aws_security_group.instances.id]
  instance_type          = var.instance_type
  use_latest_ami         = var.use_latest_ami
  ami_id                 = var.ami_id
  iam_instance_profile_name = var.enable_instance_profile ? aws_iam_instance_profile.instances[0].name : null
  root_volume_size       = var.root_volume_size
  root_volume_type       = var.root_volume_type
  root_volume_iops       = var.root_volume_iops
  root_volume_throughput = var.root_volume_throughput
  enable_ebs_encryption  = var.enable_kms_encryption
  kms_key_arn            = var.kms_key_arn != "" ? var.kms_key_arn : null
  require_imdsv2         = var.require_imdsv2
  metadata_hop_limit     = var.metadata_hop_limit
  enable_detailed_monitoring = var.enable_detailed_monitoring
  min_size               = var.asg_min_size
  max_size               = var.asg_max_size
  desired_capacity       = var.asg_desired_capacity
  health_check_type      = var.enable_alb ? "ELB" : "EC2"
  health_check_grace_period = var.health_check_grace_period
  target_group_arns      = var.enable_alb ? [module.alb[0].target_group_arn] : []
  scale_up_threshold     = var.scale_up_threshold
  scale_down_threshold   = var.scale_down_threshold
}

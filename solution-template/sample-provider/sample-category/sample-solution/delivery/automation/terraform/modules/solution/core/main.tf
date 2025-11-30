# Solution Core Module
# Deploys: VPC, Subnets, NAT Gateway, ALB, ASG, and Security Groups

locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : "${var.project_name}-${var.environment}"
  common_tags = length(var.additional_tags) > 0 ? var.additional_tags : {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

#------------------------------------------------------------------------------
# VPC and Networking
#------------------------------------------------------------------------------

module "vpc" {
  source = "../../aws/vpc"

  name_prefix = local.name_prefix
  tags        = local.common_tags
  network     = var.network
  kms_key_arn = var.kms_key_arn
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each          = toset(var.security.allowed_https_cidrs)
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from allowed CIDRs"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each          = toset(var.security.allowed_http_cidrs)
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
  from_port                    = var.application.port
  to_port                      = var.application.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instances.id
}

resource "aws_security_group" "instances" {
  name        = "${local.name_prefix}-instances-sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-instances-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "instances_from_alb" {
  security_group_id            = aws_security_group.instances.id
  description                  = "Allow traffic from ALB"
  from_port                    = var.application.port
  to_port                      = var.application.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "instances_ssh" {
  for_each          = var.security.enable_ssh_access ? toset(var.security.allowed_ssh_cidrs) : toset([])
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

resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-database-sg"
  description = "Security group for database instances"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-database-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "database_from_instances" {
  security_group_id            = aws_security_group.database.id
  description                  = "Allow traffic from application instances"
  from_port                    = var.security.db_port
  to_port                      = var.security.db_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instances.id
}

resource "aws_security_group" "cache" {
  name        = "${local.name_prefix}-cache-sg"
  description = "Security group for cache instances"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cache-sg" })
}

resource "aws_vpc_security_group_ingress_rule" "cache_from_instances" {
  security_group_id            = aws_security_group.cache.id
  description                  = "Allow traffic from application instances"
  from_port                    = var.security.cache_port
  to_port                      = var.security.cache_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.instances.id
}

#------------------------------------------------------------------------------
# IAM Role for EC2 Instances
#------------------------------------------------------------------------------

resource "aws_iam_role" "instances" {
  count = var.security.enable_instance_profile ? 1 : 0
  name  = "${local.name_prefix}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.security.enable_instance_profile && var.security.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.instances[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count      = var.security.enable_instance_profile ? 1 : 0
  role       = aws_iam_role.instances[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "instances" {
  count = var.security.enable_instance_profile ? 1 : 0
  name  = "${local.name_prefix}-instance-profile"
  role  = aws_iam_role.instances[0].name

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# Application Load Balancer
#------------------------------------------------------------------------------

module "alb" {
  source = "../../aws/alb"
  count  = var.alb.enabled ? 1 : 0

  name_prefix        = local.name_prefix
  tags               = local.common_tags
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]
  target_port        = var.application.port
  alb                = var.alb
}

#------------------------------------------------------------------------------
# Auto Scaling Group
#------------------------------------------------------------------------------

module "asg" {
  source = "../../aws/asg"
  count  = var.compute.enable_auto_scaling ? 1 : 0

  name_prefix               = local.name_prefix
  tags                      = local.common_tags
  subnet_ids                = module.vpc.private_subnet_ids
  security_group_ids        = [aws_security_group.instances.id]
  target_group_arns         = var.alb.enabled ? [module.alb[0].target_group_arn] : []
  iam_instance_profile_name = var.security.enable_instance_profile ? aws_iam_instance_profile.instances[0].name : ""
  kms_key_arn               = var.kms_key_arn != "" ? var.kms_key_arn : null
  health_check_type         = var.alb.enabled ? "ELB" : "EC2"
  compute                   = var.compute
  security = {
    require_imdsv2        = var.security.require_imdsv2
    metadata_hop_limit    = var.security.metadata_hop_limit
    enable_kms_encryption = var.security.enable_kms_encryption
  }
}

#------------------------------------------------------------------------------
# AAP Solution - Core Module
#------------------------------------------------------------------------------
# Orchestrates core infrastructure using AWS provider modules:
# - VPC and networking
# - Security groups
# - EC2 instances for AAP nodes
# - RDS PostgreSQL database
# - Load balancer
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.solution.abbr}-${var.environment}"

  common_tags = merge(var.common_tags, {
    Environment = var.environment
    Platform    = "ansible-automation-platform"
    ManagedBy   = "terraform"
  })
}

#------------------------------------------------------------------------------
# VPC and Networking (reuse from shared module or create)
#------------------------------------------------------------------------------
module "vpc" {
  source = "../../../modules/aws/vpc"
  count  = var.create_vpc ? 1 : 0

  name_prefix          = local.name_prefix
  cluster_name         = local.name_prefix
  vpc_cidr             = var.network.vpc_cidr
  public_subnet_cidrs  = var.network.public_subnets
  private_subnet_cidrs = var.network.private_subnets
  availability_zones   = var.network.availability_zones
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "prod"

  common_tags = local.common_tags
}

locals {
  vpc_id             = var.create_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  private_subnet_ids = var.create_vpc ? module.vpc[0].private_subnet_ids : var.existing_private_subnet_ids
  public_subnet_ids  = var.create_vpc ? module.vpc[0].public_subnet_ids : var.existing_public_subnet_ids
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
resource "aws_security_group" "controller" {
  name        = "${local.name_prefix}-controller-sg"
  description = "Security group for AAP Controller"
  vpc_id      = local.vpc_id

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.security.allowed_cidrs
    description = "HTTPS access"
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.security.allowed_cidrs
    description = "SSH access"
  }

  # Controller-to-controller communication
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Internal cluster communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-controller-sg"
  })
}

resource "aws_security_group" "execution" {
  name        = "${local.name_prefix}-execution-sg"
  description = "Security group for AAP Execution nodes"
  vpc_id      = local.vpc_id

  # SSH from controller
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.controller.id]
    description     = "SSH from controller"
  }

  # Receptor (mesh) communication
  ingress {
    from_port       = 27199
    to_port         = 27199
    protocol        = "tcp"
    security_groups = [aws_security_group.controller.id]
    description     = "Receptor mesh from controller"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-execution-sg"
  })
}

resource "aws_security_group" "database" {
  name        = "${local.name_prefix}-db-sg"
  description = "Security group for AAP PostgreSQL"
  vpc_id      = local.vpc_id

  # PostgreSQL from controller
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.controller.id]
    description     = "PostgreSQL from controller"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
  })
}

#------------------------------------------------------------------------------
# RDS PostgreSQL Database
#------------------------------------------------------------------------------
module "database" {
  source = "../../../modules/aws/rds-postgres"

  name_prefix        = local.name_prefix
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.database.id]

  engine_version        = "15.4"
  instance_class        = var.database.instance_class
  allocated_storage     = var.database.storage_gb
  max_allocated_storage = var.database.storage_gb * 5

  database_name     = var.database.name
  master_username   = var.database.username
  master_password   = var.database.password

  kms_key_arn           = var.security.kms_key_arn
  multi_az              = var.database.multi_az
  deletion_protection   = var.environment == "prod"
  backup_retention_days = var.backup.retention_days
  create_read_replica   = var.dr.db_replication_enabled

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# AAP Nodes (EC2)
#------------------------------------------------------------------------------
module "aap_nodes" {
  source = "../../../modules/aws/ec2-aap"

  name_prefix        = local.name_prefix
  ami_id             = var.compute.ami_id
  private_subnet_ids = local.private_subnet_ids
  key_name           = var.compute.key_name
  kms_key_arn        = var.security.kms_key_arn

  controller_count         = var.compute.controller_count
  controller_instance_type = var.compute.controller_instance_type
  controller_security_group_ids = [aws_security_group.controller.id]

  execution_count         = var.compute.execution_count
  execution_instance_type = var.compute.execution_instance_type
  execution_security_group_ids = [aws_security_group.execution.id]

  create_hub         = true
  hub_instance_type  = var.compute.hub_instance_type
  hub_security_group_ids = [aws_security_group.controller.id]

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Application Load Balancer
#------------------------------------------------------------------------------
resource "aws_lb" "controller" {
  name               = "${local.name_prefix}-controller-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.controller.id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = var.environment == "prod"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-controller-alb"
  })
}

resource "aws_lb_target_group" "controller" {
  name     = "${local.name_prefix}-ctrl-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = local.vpc_id

  health_check {
    enabled             = true
    path                = "/api/v2/ping/"
    port                = "443"
    protocol            = "HTTPS"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = local.common_tags
}

resource "aws_lb_listener" "controller_https" {
  load_balancer_arn = aws_lb.controller.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.security.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_lb_target_group_attachment" "controller" {
  count = var.compute.controller_count

  target_group_arn = aws_lb_target_group.controller.arn
  target_id        = module.aap_nodes.controller_instance_ids[count.index]
  port             = 443
}

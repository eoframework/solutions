# AWS Disaster Recovery for Web Applications
# Multi-region DR setup with automated failover

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configurations for both regions
provider "aws" {
  alias  = "primary"
  region = var.primary_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Solution    = "disaster-recovery"
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Solution    = "disaster-recovery"
      ManagedBy   = "terraform"
    }
  }
}

# Data sources for existing resources
data "aws_availability_zones" "primary" {
  provider = aws.primary
  state    = "available"
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Primary Region Infrastructure
module "primary_vpc" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.primary
  }
  
  cidr_block           = var.primary_vpc_cidr
  availability_zones   = slice(data.aws_availability_zones.primary.names, 0, 3)
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.project_name}-primary-vpc"
    Type = "Primary"
  }
}

module "secondary_vpc" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws.secondary
  }
  
  cidr_block           = var.secondary_vpc_cidr
  availability_zones   = slice(data.aws_availability_zones.secondary.names, 0, 3)
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.project_name}-secondary-vpc"
    Type = "Secondary"
  }
}

# Security Groups
resource "aws_security_group" "web_tier_primary" {
  provider    = aws.primary
  name        = "${var.project_name}-web-tier-primary"
  description = "Security group for web tier in primary region"
  vpc_id      = module.primary_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-tier-primary"
  }
}

resource "aws_security_group" "web_tier_secondary" {
  provider    = aws.secondary
  name        = "${var.project_name}-web-tier-secondary"
  description = "Security group for web tier in secondary region"
  vpc_id      = module.secondary_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-tier-secondary"
  }
}

resource "aws_security_group" "database_primary" {
  provider    = aws.primary
  name        = "${var.project_name}-database-primary"
  description = "Security group for database in primary region"
  vpc_id      = module.primary_vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier_primary.id]
  }

  tags = {
    Name = "${var.project_name}-database-primary"
  }
}

resource "aws_security_group" "database_secondary" {
  provider    = aws.secondary
  name        = "${var.project_name}-database-secondary"
  description = "Security group for database in secondary region"
  vpc_id      = module.secondary_vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier_secondary.id]
  }

  tags = {
    Name = "${var.project_name}-database-secondary"
  }
}

# Application Load Balancers
resource "aws_lb" "primary" {
  provider           = aws.primary
  name               = "${var.project_name}-primary-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_tier_primary.id]
  subnets            = module.primary_vpc.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.project_name}-primary-alb"
  }
}

resource "aws_lb" "secondary" {
  provider           = aws.secondary
  name               = "${var.project_name}-secondary-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_tier_secondary.id]
  subnets            = module.secondary_vpc.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name = "${var.project_name}-secondary-alb"
  }
}

# Target Groups
resource "aws_lb_target_group" "primary" {
  provider = aws.primary
  name     = "${var.project_name}-primary-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.primary_vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-primary-tg"
  }
}

resource "aws_lb_target_group" "secondary" {
  provider = aws.secondary
  name     = "${var.project_name}-secondary-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.secondary_vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-secondary-tg"
  }
}

# Load Balancer Listeners
resource "aws_lb_listener" "primary" {
  provider          = aws.primary
  load_balancer_arn = aws_lb.primary.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }
}

resource "aws_lb_listener" "secondary" {
  provider          = aws.secondary
  load_balancer_arn = aws_lb.secondary.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secondary.arn
  }
}

# RDS Subnet Groups
resource "aws_db_subnet_group" "primary" {
  provider   = aws.primary
  name       = "${var.project_name}-primary-db-subnet-group"
  subnet_ids = module.primary_vpc.private_subnet_ids

  tags = {
    Name = "${var.project_name}-primary-db-subnet-group"
  }
}

resource "aws_db_subnet_group" "secondary" {
  provider   = aws.secondary
  name       = "${var.project_name}-secondary-db-subnet-group"
  subnet_ids = module.secondary_vpc.private_subnet_ids

  tags = {
    Name = "${var.project_name}-secondary-db-subnet-group"
  }
}

# RDS Primary Database
resource "aws_db_instance" "primary" {
  provider = aws.primary
  
  identifier     = "${var.project_name}-primary-db"
  engine         = "mysql"
  engine_version = var.mysql_engine_version
  instance_class = var.rds_instance_class
  
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = var.enable_encryption
  
  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  
  vpc_security_group_ids = [aws_security_group.database_primary.id]
  db_subnet_group_name   = aws_db_subnet_group.primary.name
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  multi_az               = true
  publicly_accessible    = false
  deletion_protection    = var.enable_deletion_protection
  skip_final_snapshot    = !var.enable_final_snapshot
  final_snapshot_identifier = var.enable_final_snapshot ? "${var.project_name}-primary-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null
  
  enabled_cloudwatch_logs_exports = ["error", "general", "slow_query"]
  monitoring_interval             = 60
  monitoring_role_arn            = aws_iam_role.rds_monitoring.arn
  
  tags = {
    Name = "${var.project_name}-primary-database"
  }
}

# RDS Read Replica in Secondary Region
resource "aws_db_instance" "secondary" {
  provider = aws.secondary
  
  identifier = "${var.project_name}-secondary-db"
  
  replicate_source_db = aws_db_instance.primary.arn
  instance_class      = var.rds_instance_class
  
  publicly_accessible = false
  
  vpc_security_group_ids = [aws_security_group.database_secondary.id]
  
  tags = {
    Name = "${var.project_name}-secondary-database"
    Type = "ReadReplica"
  }
}

# S3 Buckets for application data
resource "aws_s3_bucket" "primary" {
  provider = aws.primary
  bucket   = "${var.project_name}-primary-${random_string.bucket_suffix.result}"

  tags = {
    Name = "${var.project_name}-primary-bucket"
  }
}

resource "aws_s3_bucket" "secondary" {
  provider = aws.secondary
  bucket   = "${var.project_name}-secondary-${random_string.bucket_suffix.result}"

  tags = {
    Name = "${var.project_name}-secondary-bucket"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Cross-Region Replication
resource "aws_s3_bucket_replication_configuration" "primary_to_secondary" {
  provider   = aws.primary
  depends_on = [aws_s3_bucket_versioning.primary]

  role   = aws_iam_role.s3_replication.arn
  bucket = aws_s3_bucket.primary.id

  rule {
    id     = "replicate-to-secondary"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD_IA"
    }
  }
}

# S3 Bucket versioning (required for replication)
resource "aws_s3_bucket_versioning" "primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.primary.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "secondary" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.secondary.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Route 53 Configuration
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-zone"
  }
}

# Route 53 Health Checks
resource "aws_route53_health_check" "primary" {
  fqdn              = aws_lb.primary.dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = var.health_check_path
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "${var.project_name}-primary-health-check"
  }
}

# Route 53 Records with Failover
resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = aws_lb.primary.dns_name
    zone_id                = aws_lb.primary.zone_id
    evaluate_target_health = true
  }

  health_check_id = aws_route53_health_check.primary.id
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = aws_lb.secondary.dns_name
    zone_id                = aws_lb.secondary.zone_id
    evaluate_target_health = true
  }
}

# Launch Templates
resource "aws_launch_template" "primary" {
  provider = aws.primary
  
  name_prefix   = "${var.project_name}-primary-"
  image_id      = var.ami_id_primary
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.web_tier_primary.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-primary-instance"
    }
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    region      = var.primary_region
    bucket_name = aws_s3_bucket.primary.id
    db_endpoint = aws_db_instance.primary.endpoint
  }))
}

resource "aws_launch_template" "secondary" {
  provider = aws.secondary
  
  name_prefix   = "${var.project_name}-secondary-"
  image_id      = var.ami_id_secondary
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.web_tier_secondary.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-secondary-instance"
    }
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    region      = var.secondary_region
    bucket_name = aws_s3_bucket.secondary.id
    db_endpoint = aws_db_instance.secondary.endpoint
  }))
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "primary" {
  provider = aws.primary
  
  name                = "${var.project_name}-primary-asg"
  vpc_zone_identifier = module.primary_vpc.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.primary.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.primary.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-primary-asg"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_group" "secondary" {
  provider = aws.secondary
  
  name                = "${var.project_name}-secondary-asg"
  vpc_zone_identifier = module.secondary_vpc.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.secondary.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 0  # Keep minimal in DR region
  max_size         = var.asg_max_size
  desired_capacity = 0  # Start with 0 instances

  launch_template {
    id      = aws_launch_template.secondary.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-secondary-asg"
    propagate_at_launch = false
  }
}
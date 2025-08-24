# HashiCorp Terraform Enterprise Platform Infrastructure
# This Terraform configuration deploys a complete Terraform Enterprise platform
# with high availability, security, and scalability features.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    bucket = var.terraform_state_bucket
    key    = "terraform-enterprise/terraform.tfstate"
    region = var.aws_region
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Configure Kubernetes Provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Configure Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Solution    = "terraform-enterprise"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }

  cluster_name = "${var.project_name}-tfe-${var.environment}"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# VPC for Terraform Enterprise
resource "aws_vpc" "tfe_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "tfe_igw" {
  vpc_id = aws_vpc.tfe_vpc.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.tfe_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "public"
  })
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.tfe_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "private"
  })
}

# Database Subnets
resource "aws_subnet" "database_subnets" {
  count = length(var.database_subnet_cidrs)

  vpc_id            = aws_vpc.tfe_vpc.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-subnet-${count.index + 1}"
    Type = "database"
  })
}

# NAT Gateways
resource "aws_eip" "nat_eips" {
  count = length(aws_subnet.public_subnets)

  domain = "vpc"
  depends_on = [aws_internet_gateway.tfe_igw]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "nat_gateways" {
  count = length(aws_subnet.public_subnets)

  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-gateway-${count.index + 1}"
  })
}

# Route Tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tfe_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfe_igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table" "private_rts" {
  count = length(aws_nat_gateway.nat_gateways)

  vpc_id = aws_vpc.tfe_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public_rta" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  count = length(aws_subnet.private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rts[count.index % length(aws_route_table.private_rts)].id
}

resource "aws_route_table_association" "database_rta" {
  count = length(aws_subnet.database_subnets)

  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = aws_route_table.private_rts[count.index % length(aws_route_table.private_rts)].id
}

# Security Groups
resource "aws_security_group" "tfe_alb_sg" {
  name        = "${var.project_name}-tfe-alb-sg"
  description = "Security group for Terraform Enterprise ALB"
  vpc_id      = aws_vpc.tfe_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-alb-sg"
  })
}

resource "aws_security_group" "tfe_app_sg" {
  name        = "${var.project_name}-tfe-app-sg"
  description = "Security group for Terraform Enterprise application"
  vpc_id      = aws_vpc.tfe_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.tfe_alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.tfe_alb_sg.id]
  }

  ingress {
    from_port       = 8800
    to_port         = 8800
    protocol        = "tcp"
    security_groups = [aws_security_group.tfe_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-app-sg"
  })
}

resource "aws_security_group" "tfe_db_sg" {
  name        = "${var.project_name}-tfe-db-sg"
  description = "Security group for Terraform Enterprise database"
  vpc_id      = aws_vpc.tfe_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.tfe_app_sg.id]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-db-sg"
  })
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = aws_vpc.tfe_vpc.id
  subnet_ids                     = aws_subnet.private_subnets[*].id
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    tfe_nodes = {
      min_size     = var.min_node_count
      max_size     = var.max_node_count
      desired_size = var.desired_node_count

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      disk_size = var.node_disk_size

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key               = var.ssh_key_name
        source_security_group_ids = [aws_security_group.tfe_app_sg.id]
      }
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role_name}"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]

  tags = local.common_tags
}

# RDS PostgreSQL Database
resource "aws_db_subnet_group" "tfe_db_subnet_group" {
  name       = "${var.project_name}-tfe-db-subnet-group"
  subnet_ids = aws_subnet.database_subnets[*].id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "tfe_db_params" {
  family = "postgres14"
  name   = "${var.project_name}-tfe-db-params"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = local.common_tags
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-tfe-db-password"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_db_instance" "tfe_database" {
  identifier = "${var.project_name}-tfe-database"

  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.database_username
  password = random_password.db_password.result

  vpc_security_group_ids = [aws_security_group.tfe_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.tfe_db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.tfe_db_params.name

  backup_retention_period = var.db_backup_retention_days
  backup_window          = var.db_backup_window
  maintenance_window     = var.db_maintenance_window

  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-tfe-database-final-snapshot"

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  performance_insights_enabled = true
  performance_insights_retention_period = 7

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-tfe-database"
  })
}

# RDS Enhanced Monitoring Role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "${var.project_name}-rds-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# S3 Bucket for Terraform State and Blob Storage
resource "aws_s3_bucket" "tfe_storage" {
  bucket = "${var.project_name}-tfe-storage-${random_string.bucket_suffix.result}"

  tags = local.common_tags
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "tfe_storage_versioning" {
  bucket = aws_s3_bucket.tfe_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfe_storage_encryption" {
  bucket = aws_s3_bucket.tfe_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfe_storage_pab" {
  bucket = aws_s3_bucket.tfe_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Application Load Balancer
resource "aws_lb" "tfe_alb" {
  name               = "${var.project_name}-tfe-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tfe_alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = var.enable_deletion_protection

  tags = local.common_tags
}

# ALB Target Group
resource "aws_lb_target_group" "tfe_tg" {
  name     = "${var.project_name}-tfe-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tfe_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/_health_check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = local.common_tags
}

# ACM Certificate
resource "aws_acm_certificate" "tfe_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

# ALB Listener
resource "aws_lb_listener" "tfe_https" {
  load_balancer_arn = aws_lb.tfe_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.tfe_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tfe_tg.arn
  }
}

resource "aws_lb_listener" "tfe_http" {
  load_balancer_arn = aws_lb.tfe_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Terraform Enterprise Kubernetes Resources
resource "kubernetes_namespace" "terraform_enterprise" {
  metadata {
    name = "terraform-enterprise"
    
    labels = {
      name = "terraform-enterprise"
    }
  }

  depends_on = [module.eks]
}

resource "kubernetes_secret" "tfe_database" {
  metadata {
    name      = "tfe-database-credentials"
    namespace = kubernetes_namespace.terraform_enterprise.metadata[0].name
  }

  data = {
    username = var.database_username
    password = random_password.db_password.result
    host     = aws_db_instance.tfe_database.endpoint
    port     = aws_db_instance.tfe_database.port
    database = var.database_name
    url      = "postgres://${var.database_username}:${random_password.db_password.result}@${aws_db_instance.tfe_database.endpoint}:${aws_db_instance.tfe_database.port}/${var.database_name}"
  }

  type = "Opaque"

  depends_on = [module.eks]
}

resource "kubernetes_secret" "tfe_storage" {
  metadata {
    name      = "tfe-storage-credentials"
    namespace = kubernetes_namespace.terraform_enterprise.metadata[0].name
  }

  data = {
    bucket = aws_s3_bucket.tfe_storage.bucket
    region = var.aws_region
  }

  type = "Opaque"

  depends_on = [module.eks]
}

# Terraform Enterprise Helm Chart
resource "helm_release" "terraform_enterprise" {
  name       = "terraform-enterprise"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "terraform-enterprise"
  version    = var.tfe_helm_chart_version
  namespace  = kubernetes_namespace.terraform_enterprise.metadata[0].name

  values = [
    templatefile("${path.module}/tfe-values.yaml", {
      domain_name       = var.domain_name
      database_secret   = kubernetes_secret.tfe_database.metadata[0].name
      storage_secret    = kubernetes_secret.tfe_storage.metadata[0].name
      license_secret    = var.tfe_license_secret_name
      replica_count     = var.tfe_replica_count
      resources         = var.tfe_resources
      storage_class     = var.storage_class
      ingress_class     = var.ingress_class
    })
  ]

  depends_on = [
    module.eks,
    kubernetes_namespace.terraform_enterprise,
    kubernetes_secret.tfe_database,
    kubernetes_secret.tfe_storage
  ]
}

# Route53 DNS Record (optional)
data "aws_route53_zone" "domain" {
  count = var.create_dns_record ? 1 : 0
  name  = var.domain_name
}

resource "aws_route53_record" "tfe" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = data.aws_route53_zone.domain[0].zone_id
  name    = "tfe.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.tfe_alb.dns_name
    zone_id                = aws_lb.tfe_alb.zone_id
    evaluate_target_health = true
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "tfe_logs" {
  name              = "/aws/eks/${local.cluster_name}/terraform-enterprise"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}
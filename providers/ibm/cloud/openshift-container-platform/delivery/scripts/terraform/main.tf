# IBM OpenShift Container Platform on AWS
# Terraform configuration for deploying OpenShift cluster

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = ">= 1.0.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configure providers
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

provider "rhcs" {
  token = var.openshift_cluster_manager_token
  url   = var.rhcs_url
}

# Local values
locals {
  cluster_name = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Solution    = "IBM OpenShift Container Platform"
    ManagedBy   = "Terraform"
    CreatedBy   = "IBM Red Hat Services"
  }
  
  # Calculate machine pools based on deployment type
  compute_machine_type = var.deployment_type == "single-az" ? "m5.xlarge" : "m5.2xlarge"
  compute_replicas     = var.deployment_type == "single-az" ? 2 : 3
  
  # Network configuration
  availability_zones = var.deployment_type == "single-az" ? 
    slice(data.aws_availability_zones.available.names, 0, 1) : 
    slice(data.aws_availability_zones.available.names, 0, 3)
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Random resources for unique naming
resource "random_id" "cluster_suffix" {
  byte_length = 4
}

# VPC Configuration
resource "aws_vpc" "openshift_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "openshift_igw" {
  vpc_id = aws_vpc.openshift_vpc.id
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(local.availability_zones)
  
  vpc_id                  = aws_vpc.openshift_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-public-subnet-${count.index + 1}"
    Type = "public"
  })
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(local.availability_zones)
  
  vpc_id            = aws_vpc.openshift_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-private-subnet-${count.index + 1}"
    Type = "private"
  })
}

# NAT Gateways
resource "aws_eip" "nat_eips" {
  count = var.deployment_type == "single-az" ? 1 : length(local.availability_zones)
  
  domain = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-nat-eip-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.openshift_igw]
}

resource "aws_nat_gateway" "nat_gateways" {
  count = var.deployment_type == "single-az" ? 1 : length(local.availability_zones)
  
  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-nat-gateway-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.openshift_igw]
}

# Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.openshift_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.openshift_igw.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-public-rt"
  })
}

resource "aws_route_table" "private_route_tables" {
  count = var.deployment_type == "single-az" ? 1 : length(local.availability_zones)
  
  vpc_id = aws_vpc.openshift_vpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-private-rt-${count.index + 1}"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_associations" {
  count = length(aws_subnet.public_subnets)
  
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_associations" {
  count = length(aws_subnet.private_subnets)
  
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[
    var.deployment_type == "single-az" ? 0 : count.index
  ].id
}

# Security Groups
resource "aws_security_group" "openshift_cluster_sg" {
  name_prefix = "${local.cluster_name}-cluster-"
  vpc_id      = aws_vpc.openshift_vpc.id
  description = "Security group for OpenShift cluster"
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS access to OpenShift console
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS access to OpenShift console"
  }
  
  # Allow HTTP for redirects
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTP access for redirects"
  }
  
  # Allow SSH access (if bastion is needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "SSH access"
  }
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-cluster-sg"
  })
}

# KMS Key for encryption
resource "aws_kms_key" "openshift_kms_key" {
  description             = "KMS key for OpenShift cluster encryption"
  deletion_window_in_days = 7
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-kms-key"
  })
}

resource "aws_kms_alias" "openshift_kms_alias" {
  name          = "alias/${local.cluster_name}-kms-key"
  target_key_id = aws_kms_key.openshift_kms_key.key_id
}

# Generate SSH key pair for cluster access
resource "tls_private_key" "cluster_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "cluster_key_pair" {
  key_name   = "${local.cluster_name}-key"
  public_key = tls_private_key.cluster_key.public_key_openssh
  
  tags = local.common_tags
}

# Store private key in AWS Secrets Manager
resource "aws_secretsmanager_secret" "cluster_private_key" {
  name        = "${local.cluster_name}-private-key"
  description = "Private SSH key for OpenShift cluster"
  
  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "cluster_private_key_version" {
  secret_id     = aws_secretsmanager_secret.cluster_private_key.id
  secret_string = tls_private_key.cluster_key.private_key_pem
}

# Red Hat OpenShift Cluster
resource "rhcs_cluster_rosa_classic" "openshift_cluster" {
  name                         = local.cluster_name
  cloud_region                 = var.aws_region
  aws_account_id              = data.aws_caller_identity.current.account_id
  version                     = var.openshift_version
  
  # Network configuration
  aws_subnet_ids = concat(
    aws_subnet.public_subnets[*].id,
    aws_subnet.private_subnets[*].id
  )
  
  # Machine configuration
  compute_machine_type = local.compute_machine_type
  replicas             = local.compute_replicas
  
  # Cluster configuration
  multi_az                    = var.deployment_type != "single-az"
  disable_workload_monitoring = false
  
  # Security and compliance
  fips                        = var.deployment_type == "fips"
  etcd_encryption             = true
  kms_key_arn                = aws_kms_key.openshift_kms_key.arn
  
  # Networking
  private                     = var.deployment_type == "private"
  host_prefix                 = 23
  machine_cidr                = var.vpc_cidr
  service_cidr                = "172.30.0.0/16"
  pod_cidr                    = "10.128.0.0/14"
  
  # Additional properties
  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }
  
  wait_for_create_complete = true
  
  tags = local.common_tags
  
  depends_on = [
    aws_subnet.public_subnets,
    aws_subnet.private_subnets
  ]
}

# Machine Pool for additional worker nodes (if needed)
resource "rhcs_machine_pool" "additional_workers" {
  count = var.enable_additional_machine_pool ? 1 : 0
  
  cluster      = rhcs_cluster_rosa_classic.openshift_cluster.id
  name         = "additional-workers"
  machine_type = var.additional_machine_type
  replicas     = var.additional_machine_replicas
  
  # Auto-scaling configuration
  autoscaling_enabled      = var.enable_autoscaling
  min_replicas            = var.enable_autoscaling ? var.min_replicas : null
  max_replicas            = var.enable_autoscaling ? var.max_replicas : null
  
  # Labels and taints
  labels = {
    "node-role" = "worker"
    "workload"  = "general"
  }
  
  # Only create after cluster is ready
  depends_on = [rhcs_cluster_rosa_classic.openshift_cluster]
}

# Identity Provider (if specified)
resource "rhcs_identity_provider" "cluster_identity_provider" {
  count = var.identity_provider_type != "" ? 1 : 0
  
  cluster = rhcs_cluster_rosa_classic.openshift_cluster.id
  name    = var.identity_provider_name
  
  dynamic "htpasswd" {
    for_each = var.identity_provider_type == "htpasswd" ? [1] : []
    content {
      users = var.htpasswd_users
    }
  }
  
  dynamic "openid" {
    for_each = var.identity_provider_type == "openid" ? [1] : []
    content {
      client_id                         = var.openid_client_id
      client_secret                     = var.openid_client_secret
      issuer                           = var.openid_issuer
      email_claims                     = ["email"]
      name_claims                      = ["name"]
      username_claims                  = ["preferred_username"]
      extra_scopes                     = ["email", "profile"]
    }
  }
}

# Cluster Admin User (if htpasswd is used)
resource "rhcs_cluster_rosa_classic" "cluster_admin" {
  count = var.identity_provider_type == "htpasswd" && var.create_cluster_admin ? 1 : 0
  
  # This would be implemented based on the cluster admin creation requirements
  # For now, this is a placeholder for the cluster admin user creation
}

# S3 Bucket for cluster backups and logging (optional)
resource "aws_s3_bucket" "cluster_storage" {
  count = var.create_s3_storage ? 1 : 0
  
  bucket = "${local.cluster_name}-storage-${random_id.cluster_suffix.hex}"
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-storage"
    Purpose = "OpenShift cluster storage"
  })
}

resource "aws_s3_bucket_encryption_configuration" "cluster_storage_encryption" {
  count = var.create_s3_storage ? 1 : 0
  
  bucket = aws_s3_bucket.cluster_storage[0].id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.openshift_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "cluster_storage_versioning" {
  count = var.create_s3_storage ? 1 : 0
  
  bucket = aws_s3_bucket.cluster_storage[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cluster_storage_lifecycle" {
  count = var.create_s3_storage ? 1 : 0
  
  bucket = aws_s3_bucket.cluster_storage[0].id
  
  rule {
    id     = "cleanup"
    status = "Enabled"
    
    expiration {
      days = 90
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Application Load Balancer for additional ingress (optional)
resource "aws_lb" "openshift_alb" {
  count = var.create_additional_alb ? 1 : 0
  
  name               = "${local.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.openshift_cluster_sg.id]
  subnets           = aws_subnet.public_subnets[*].id
  
  enable_deletion_protection = false
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-alb"
  })
}

# Route 53 Hosted Zone (if domain management is enabled)
resource "aws_route53_zone" "cluster_zone" {
  count = var.manage_dns ? 1 : 0
  
  name = var.cluster_domain
  
  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-zone"
  })
}

# Route 53 records for cluster endpoints
resource "aws_route53_record" "cluster_api" {
  count = var.manage_dns ? 1 : 0
  
  zone_id = aws_route53_zone.cluster_zone[0].zone_id
  name    = "api.${var.cluster_domain}"
  type    = "CNAME"
  ttl     = 300
  
  records = [rhcs_cluster_rosa_classic.openshift_cluster.api_url]
}

resource "aws_route53_record" "cluster_apps" {
  count = var.manage_dns ? 1 : 0
  
  zone_id = aws_route53_zone.cluster_zone[0].zone_id
  name    = "*.apps.${var.cluster_domain}"
  type    = "CNAME"
  ttl     = 300
  
  records = [rhcs_cluster_rosa_classic.openshift_cluster.console_url]
}
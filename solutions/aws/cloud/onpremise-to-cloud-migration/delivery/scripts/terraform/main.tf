# AWS On-Premise to Cloud Migration - Main Terraform Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.default_tags
  }
}

# Migration Hub for application discovery and migration tracking
resource "aws_migrationhub_home_region_control" "migration_hub" {
  home_region = var.aws_region
  
  target {
    type = "ACCOUNT"
    id   = data.aws_caller_identity.current.account_id
  }
}

# Application Discovery Service Configuration
resource "aws_iam_role" "application_discovery_service_role" {
  name = "${var.project_name}-ads-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-discovery.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ads_policy" {
  role       = aws_iam_role.application_discovery_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/ApplicationDiscoveryServiceLinkedRolePolicy"
}

# DMS Replication Instance for database migration
resource "aws_dms_replication_instance" "migration_instance" {
  count = var.enable_database_migration ? 1 : 0
  
  replication_instance_class = var.dms_instance_class
  replication_instance_id    = "${var.project_name}-replication-instance"
  
  allocated_storage            = var.dms_allocated_storage
  auto_minor_version_upgrade   = true
  engine_version              = var.dms_engine_version
  multi_az                    = var.dms_multi_az
  publicly_accessible        = false
  
  vpc_security_group_ids = [aws_security_group.dms_security_group[0].id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.migration_subnet_group[0].id
  
  tags = var.default_tags
}

# DMS Subnet Group
resource "aws_dms_replication_subnet_group" "migration_subnet_group" {
  count = var.enable_database_migration ? 1 : 0
  
  replication_subnet_group_description = "${var.project_name} DMS subnet group"
  replication_subnet_group_id          = "${var.project_name}-subnet-group"
  
  subnet_ids = var.subnet_ids
  
  tags = var.default_tags
}

# Security Group for DMS
resource "aws_security_group" "dms_security_group" {
  count = var.enable_database_migration ? 1 : 0
  
  name        = "${var.project_name}-dms-sg"
  description = "Security group for DMS replication instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = var.default_tags
}

# DataSync for file transfer
resource "aws_datasync_location_s3" "migration_s3_location" {
  count = var.enable_file_migration ? 1 : 0
  
  s3_bucket_arn = aws_s3_bucket.migration_data[0].arn
  subdirectory  = "/migrated-data"
  
  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_role[0].arn
  }
  
  tags = var.default_tags
}

# S3 bucket for migrated data
resource "aws_s3_bucket" "migration_data" {
  count = var.enable_file_migration ? 1 : 0
  
  bucket = var.migration_data_bucket_name
  
  tags = var.default_tags
}

resource "aws_s3_bucket_versioning" "migration_data_versioning" {
  count = var.enable_file_migration ? 1 : 0
  
  bucket = aws_s3_bucket.migration_data[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# DataSync S3 IAM Role
resource "aws_iam_role" "datasync_s3_role" {
  count = var.enable_file_migration ? 1 : 0
  
  name = "${var.project_name}-datasync-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Log Group for migration monitoring
resource "aws_cloudwatch_log_group" "migration_logs" {
  name              = "/aws/migration/${var.project_name}"
  retention_in_days = var.log_retention_days
  
  tags = var.default_tags
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}
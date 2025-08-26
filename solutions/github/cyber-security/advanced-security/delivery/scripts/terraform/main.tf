# GitHub Advanced Security Platform - Terraform Main Configuration
# This file defines the core infrastructure for GitHub Advanced Security automation
# including SIEM integrations, compliance monitoring, and security scanning automation

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
  
  backend "s3" {
    bucket = "github-security-terraform-state"
    key    = "github-advanced-security/terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure providers
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

provider "github" {
  token = var.github_token
  organization = var.github_organization
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

# Local values
locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Solution    = "github-advanced-security"
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# VPC for security monitoring infrastructure
resource "aws_vpc" "security_monitoring" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "security_monitoring" {
  vpc_id = aws_vpc.security_monitoring.id
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

# Public Subnets for NAT Gateways and Load Balancers
resource "aws_subnet" "public" {
  count = length(var.availability_zones)
  
  vpc_id                  = aws_vpc.security_monitoring.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Type = "Public"
  })
}

# Private Subnets for security monitoring services
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  
  vpc_id            = aws_vpc.security_monitoring.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    Type = "Private"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  
  domain = "vpc"
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-eip-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.security_monitoring]
}

# NAT Gateways
resource "aws_nat_gateway" "security_monitoring" {
  count = length(var.availability_zones)
  
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  })
  
  depends_on = [aws_internet_gateway.security_monitoring]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.security_monitoring.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.security_monitoring.id
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)
  
  vpc_id = aws_vpc.security_monitoring.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.security_monitoring[count.index].id
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Groups
resource "aws_security_group" "security_monitoring" {
  name_prefix = "${var.project_name}-${var.environment}-monitoring"
  vpc_id      = aws_vpc.security_monitoring.id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS inbound"
  }
  
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.security_monitoring.cidr_block]
    description = "Elasticsearch"
  }
  
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.security_monitoring.cidr_block]
    description = "Kibana"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-monitoring-sg"
  })
}

# KMS Key for encryption
resource "aws_kms_key" "security_monitoring" {
  description = "KMS key for GitHub Advanced Security Platform encryption"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
  
  tags = local.common_tags
}

resource "aws_kms_alias" "security_monitoring" {
  name          = "alias/${var.project_name}-${var.environment}-security"
  target_key_id = aws_kms_key.security_monitoring.key_id
}

# S3 Bucket for security logs and reports
resource "aws_s3_bucket" "security_logs" {
  bucket = var.security_logs_bucket_name != "" ? var.security_logs_bucket_name : "${var.project_name}-${var.environment}-security-logs-${random_string.bucket_suffix.result}"
  
  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.security_monitoring.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "security_logs" {
  bucket = aws_s3_bucket.security_logs.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Random string for unique bucket naming
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# IAM Role for security monitoring
resource "aws_iam_role" "security_monitoring" {
  name = "${var.project_name}-${var.environment}-security-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
        }
      }
    ]
  })
  
  tags = local.common_tags
}

# IAM Policy for security monitoring
resource "aws_iam_role_policy" "security_monitoring" {
  name = "${var.project_name}-${var.environment}-security-policy"
  role = aws_iam_role.security_monitoring.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.security_logs.arn,
          "${aws_s3_bucket.security_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.security_monitoring.arn
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "security_monitoring" {
  name              = "/aws/github-security/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.security_monitoring.arn
  
  tags = local.common_tags
}

# SNS Topic for security alerts
resource "aws_sns_topic" "security_alerts" {
  name              = "${var.project_name}-${var.environment}-security-alerts"
  kms_master_key_id = aws_kms_key.security_monitoring.id
  
  tags = local.common_tags
}

# Lambda function for GitHub webhook processing
resource "aws_lambda_function" "security_webhook" {
  count = var.enable_webhook ? 1 : 0
  
  filename         = "security_webhook.zip"
  function_name    = "${var.project_name}-${var.environment}-security-webhook"
  role            = aws_iam_role.security_monitoring.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 300
  
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.security_alerts.arn
      S3_BUCKET     = aws_s3_bucket.security_logs.bucket
    }
  }
  
  tags = local.common_tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "security_monitoring" {
  count = var.enable_dashboard ? 1 : 0
  
  dashboard_name = var.dashboard_name != "" ? var.dashboard_name : "${var.project_name}-${var.environment}-security"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.security_webhook[0].function_name],
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.security_webhook[0].function_name],
            ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.security_webhook[0].function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "GitHub Security Webhook Metrics"
          period  = 300
        }
      }
    ]
  })
}
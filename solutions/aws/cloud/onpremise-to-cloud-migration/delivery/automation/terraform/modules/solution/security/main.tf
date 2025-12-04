#------------------------------------------------------------------------------
# DR Web Application Security Module
#------------------------------------------------------------------------------
# Provides core security infrastructure for disaster recovery:
# - KMS keys for encryption at rest (primary and DR regions)
# - WAF Web ACL for application protection
# - Security groups for ALB and EC2
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Key for Primary Region Encryption
#------------------------------------------------------------------------------
resource "aws_kms_key" "primary" {
  description             = "${var.project.name}-${var.project.environment} primary encryption key"
  deletion_window_in_days = var.security.kms_deletion_window_days
  enable_key_rotation     = var.security.enable_kms_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowRDSAccess"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_kms_alias" "primary" {
  name          = "alias/${var.project.name}-${var.project.environment}"
  target_key_id = aws_kms_key.primary.key_id
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

#------------------------------------------------------------------------------
# WAF Web ACL (for ALB protection)
#------------------------------------------------------------------------------
resource "aws_wafv2_web_acl" "main" {
  count = var.security.enable_waf ? 1 : 0

  name        = "${var.project.name}-${var.project.environment}-waf"
  description = "WAF ACL for ${var.project.name} ${var.project.environment} environment"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rules - Common Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project.name}-common-rules"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rules - Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project.name}-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # Rate Limiting Rule
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.security.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project.name}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project.name}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project.name}-${var.project.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.network.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet (redirect to HTTPS)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project.name}-${var.project.environment}-alb-sg"
  })
}

# Application Security Group
resource "aws_security_group" "app" {
  name        = "${var.project.name}-${var.project.environment}-app-sg"
  description = "Security group for application instances"
  vpc_id      = var.network.vpc_id

  ingress {
    from_port       = var.network.app_port
    to_port         = var.network.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Application traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project.name}-${var.project.environment}-app-sg"
  })
}

# Database Security Group
resource "aws_security_group" "db" {
  name        = "${var.project.name}-${var.project.environment}-db-sg"
  description = "Security group for Aurora database"
  vpc_id      = var.network.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "MySQL from application tier"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project.name}-${var.project.environment}-db-sg"
  })
}

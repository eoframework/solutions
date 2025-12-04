#------------------------------------------------------------------------------
# AWS KMS Module (Provider-Level Primitive)
#------------------------------------------------------------------------------
# Reusable KMS key with configurable policies
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# KMS Key
#------------------------------------------------------------------------------
resource "aws_kms_key" "main" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region

  policy = var.policy != "" ? var.policy : jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ],
    var.enable_cloudwatch_logs ? [{
      Sid    = "Allow CloudWatch Logs"
      Effect = "Allow"
      Principal = {
        Service = "logs.${data.aws_region.current.name}.amazonaws.com"
      }
      Action = [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ]
      Resource = "*"
      Condition = {
        ArnLike = {
          "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        }
      }
    }] : [],
    var.enable_sns ? [{
      Sid    = "Allow SNS"
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ]
      Resource = "*"
    }] : [],
    var.enable_s3 ? [{
      Sid    = "Allow S3"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = [
        "kms:GenerateDataKey*",
        "kms:Decrypt"
      ]
      Resource = "*"
    }] : [],
    var.enable_rds ? [{
      Sid    = "Allow RDS"
      Effect = "Allow"
      Principal = {
        Service = "rds.amazonaws.com"
      }
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ]
      Resource = "*"
    }] : [],
    var.enable_eks ? [{
      Sid    = "Allow EKS"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      Resource = "*"
    }] : []
    )
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-kms-key"
  })
}

#------------------------------------------------------------------------------
# KMS Alias
#------------------------------------------------------------------------------
resource "aws_kms_alias" "main" {
  name          = "alias/${var.name_prefix}"
  target_key_id = aws_kms_key.main.key_id
}

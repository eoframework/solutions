#------------------------------------------------------------------------------
# IDP Security Module - KMS Encryption + Lambda VPC Security
#------------------------------------------------------------------------------
# Provides core security infrastructure:
# - KMS key for encryption at rest (S3, DynamoDB, CloudWatch, etc.)
# - Lambda VPC security group (optional, when Lambda VPC mode enabled)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# KMS Key for Encryption
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = "${var.project.name}-${var.project.environment} encryption key"
  deletion_window_in_days = var.security.kms_deletion_window_days
  enable_key_rotation     = var.security.enable_kms_key_rotation

  tags = var.common_tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project.name}-${var.project.environment}"
  target_key_id = aws_kms_key.main.key_id
}

#------------------------------------------------------------------------------
# Lambda VPC Security Group (optional)
#------------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  count = var.lambda_vpc_enabled ? 1 : 0

  name        = "${var.project.name}-${var.project.environment}-lambda-sg"
  description = "Security group for Lambda functions in VPC"
  vpc_id      = var.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project.name}-${var.project.environment}-lambda-sg"
  })
}

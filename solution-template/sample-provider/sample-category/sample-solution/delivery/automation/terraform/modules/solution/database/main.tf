# Solution Database Module
# Deploys: RDS PostgreSQL/MySQL with encryption and CloudWatch alarms

locals {
  name_prefix = var.name_prefix
  common_tags = var.common_tags

  # Construct full secret name from prefix and suffix
  db_password_secret_name = "${var.name_prefix}-${var.database.password_secret_name}"
}

#------------------------------------------------------------------------------
# Retrieve Database Password from Secrets Manager
#------------------------------------------------------------------------------

data "aws_secretsmanager_secret_version" "db_password" {
  count     = var.database.enabled ? 1 : 0
  secret_id = local.db_password_secret_name
}

#------------------------------------------------------------------------------
# RDS Database
#------------------------------------------------------------------------------

module "rds" {
  source = "../../aws/rds"

  name_prefix          = local.name_prefix
  tags                 = local.common_tags
  environment          = var.environment
  db_subnet_group_name = var.db_subnet_group_name
  security_group_ids   = var.security_group_ids
  kms_key_arn          = var.kms_key_arn
  db_password          = var.database.enabled ? data.aws_secretsmanager_secret_version.db_password[0].secret_string : ""
  database             = var.database
}

# NOTE: CloudWatch alarms removed from this module to avoid circular dependencies
# Database alarms should be created in environment main.tf INTEGRATIONS section
# This allows monitoring module to be created first, then database, then alarms

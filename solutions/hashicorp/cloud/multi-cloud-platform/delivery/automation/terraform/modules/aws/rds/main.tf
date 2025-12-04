#------------------------------------------------------------------------------
# RDS PostgreSQL Module
#------------------------------------------------------------------------------
# Creates RDS PostgreSQL for Terraform Cloud/Enterprise state backend
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# RDS Instance
#------------------------------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier = "${var.name_prefix}-postgresql"

  engine               = "postgres"
  engine_version       = var.database.engine_version
  instance_class       = var.database.instance_class
  allocated_storage    = var.database.allocated_storage
  max_allocated_storage = var.database.max_allocated_storage
  storage_type         = var.database.storage_type
  storage_encrypted    = true
  kms_key_id           = var.kms_key_arn

  db_name  = var.database.rds_database_name
  username = var.database.rds_username
  password = var.database.rds_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids

  multi_az                        = var.database.multi_az
  publicly_accessible             = false
  backup_retention_period         = var.database.backup_retention_days
  backup_window                   = var.database.backup_window
  maintenance_window              = var.database.maintenance_window
  auto_minor_version_upgrade      = var.database.auto_minor_version_upgrade
  deletion_protection             = var.database.deletion_protection
  skip_final_snapshot             = var.database.skip_final_snapshot
  final_snapshot_identifier       = var.database.skip_final_snapshot ? null : "${var.name_prefix}-final-snapshot"
  copy_tags_to_snapshot           = true
  performance_insights_enabled    = var.database.performance_insights_enabled
  performance_insights_kms_key_id = var.database.performance_insights_enabled ? var.kms_key_arn : null

  enabled_cloudwatch_logs_exports = var.database.enabled_cloudwatch_logs_exports

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-postgresql"
  })
}

#------------------------------------------------------------------------------
# Parameter Group
#------------------------------------------------------------------------------
resource "aws_db_parameter_group" "main" {
  name   = "${var.name_prefix}-pg-params"
  family = "postgres${split(".", var.database.engine_version)[0]}"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-pg-params"
  })
}

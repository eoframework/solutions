# Generic AWS RDS Module
# Creates RDS instance with parameter group

locals {
  # Derive parameter group family from engine and version
  param_family = var.database.engine == "postgres" ? "postgres${split(".", var.database.engine_version)[0]}" : "mysql${split(".", var.database.engine_version)[0]}"

  # Use configured log exports or derive from engine
  log_exports = var.database.engine == "postgres" ? var.database.log_exports_postgres : var.database.log_exports_mysql
}

#------------------------------------------------------------------------------
# Parameter Group
#------------------------------------------------------------------------------

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-db-params"
  family = local.param_family

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-params" })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# RDS Instance
#------------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-db"

  # Engine
  engine               = var.database.engine
  engine_version       = var.database.engine_version
  instance_class       = var.database.instance_class
  parameter_group_name = aws_db_parameter_group.this.name

  # Storage
  allocated_storage     = var.database.allocated_storage
  max_allocated_storage = var.database.max_allocated_storage
  storage_type          = var.database.storage_type
  iops                  = var.database.storage_type == "gp3" || var.database.storage_type == "io1" || var.database.storage_type == "io2" ? var.database.storage_iops : null
  storage_throughput    = var.database.storage_type == "gp3" ? var.database.storage_throughput : null
  storage_encrypted     = var.database.storage_encrypted
  kms_key_id            = var.database.storage_encrypted ? var.kms_key_arn : null

  # Network
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = var.database.publicly_accessible

  # Database
  db_name  = var.database.name
  username = var.database.username
  password = var.db_password

  # High Availability
  multi_az = var.database.multi_az

  # Backup
  backup_retention_period = var.database.backup_retention
  backup_window           = var.database.backup_window
  maintenance_window      = var.database.maintenance_window
  copy_tags_to_snapshot   = var.database.copy_tags_to_snapshot

  # Monitoring
  performance_insights_enabled          = var.database.performance_insights
  performance_insights_retention_period = var.database.performance_insights ? var.database.performance_insights_retention : null
  enabled_cloudwatch_logs_exports       = local.log_exports

  # Protection
  deletion_protection       = var.database.deletion_protection
  skip_final_snapshot       = var.database.skip_final_snapshot
  final_snapshot_identifier = !var.database.skip_final_snapshot ? "${var.name_prefix}-db-final-snapshot" : null

  # Upgrades
  auto_minor_version_upgrade  = var.database.auto_minor_version_upgrade
  allow_major_version_upgrade = var.database.allow_major_version_upgrade

  tags = merge(var.tags, { Name = "${var.name_prefix}-db" })
}

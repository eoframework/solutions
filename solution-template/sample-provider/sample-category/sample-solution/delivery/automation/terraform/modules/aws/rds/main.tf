# Generic AWS RDS Module
# Creates RDS instance with parameter group and optional read replica

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# Parameter Group
#------------------------------------------------------------------------------

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-db-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-params"
  })

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
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  parameter_group_name = aws_db_parameter_group.this.name

  # Storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.storage_encrypted ? var.kms_key_arn : null

  # Network
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids
  port                   = var.port
  publicly_accessible    = var.publicly_accessible

  # Database
  db_name  = var.db_name
  username = var.username
  password = var.password

  # High Availability
  multi_az = var.multi_az

  # Backup
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  # Monitoring
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  enabled_cloudwatch_logs_exports       = var.cloudwatch_logs_exports

  # Protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-db-final-snapshot"

  # Upgrades
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db"
  })
}

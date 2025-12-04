#------------------------------------------------------------------------------
# RDS PostgreSQL Module for Terraform Enterprise
#------------------------------------------------------------------------------
# Manages RDS PostgreSQL for TFE state storage
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# RDS Instance
#------------------------------------------------------------------------------
resource "aws_db_instance" "tfe" {
  identifier = "${var.name_prefix}-postgres"

  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = var.database.rds_instance_class
  allocated_storage    = var.database.rds_storage_gb
  max_allocated_storage = var.database.rds_storage_gb * 2
  storage_type         = "gp3"
  storage_encrypted    = true
  kms_key_id           = var.kms_key_arn

  db_name  = var.database.rds_database_name
  username = "tfe_admin"
  password = random_password.db_password.result

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.security_group_ids

  multi_az               = var.database.rds_multi_az
  publicly_accessible    = false
  deletion_protection    = var.database.rds_deletion_protection

  backup_retention_period = var.database.rds_backup_retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  auto_minor_version_upgrade = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-final-snapshot"

  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Database Password
#------------------------------------------------------------------------------
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}

#------------------------------------------------------------------------------
# Store Password in Secrets Manager
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "db_password" {
  name       = "${var.name_prefix}-db-password"
  kms_key_id = var.kms_key_arn

  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = aws_db_instance.tfe.username
    password = random_password.db_password.result
    host     = aws_db_instance.tfe.address
    port     = aws_db_instance.tfe.port
    database = aws_db_instance.tfe.db_name
  })
}

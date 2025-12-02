#------------------------------------------------------------------------------
# IDP Production Environment - Serverless Architecture
#------------------------------------------------------------------------------
# Composes: storage + document-processing + human-review + api + auth
#
# This is a full production deployment with:
# - S3 buckets for document storage
# - DynamoDB tables for metadata and results
# - Lambda functions for processing
# - Step Functions for orchestration
# - API Gateway REST API
# - Cognito for authentication
# - A2I for human review
# - Textract for OCR
# - Comprehend for NLP/PII detection
#
# See providers.tf for Terraform/AWS provider configuration
# See README.md for prerequisites and setup instructions
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Naming Standards & Common Tags
#------------------------------------------------------------------------------

locals {
  # Auto-discover environment from folder name (prod, test, dr)
  environment = basename(path.module)

  # Environment display names for human-readable outputs
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

  # Standardized naming prefix: {solution_abbr}-{environment}
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Common tags applied to ALL resources via provider default_tags
  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    EnvDisplay   = lookup(local.env_display_name, local.environment, local.environment)
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    Region       = var.aws.region
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
  }

  # Project configuration for modules
  project = {
    name        = var.solution.abbr
    environment = local.environment
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#------------------------------------------------------------------------------
# KMS Key for Encryption
#------------------------------------------------------------------------------

resource "aws_kms_key" "main" {
  description             = "${local.name_prefix} encryption key"
  deletion_window_in_days = var.security.kms_deletion_window_days
  enable_key_rotation     = var.security.enable_kms_key_rotation

  tags = local.common_tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/${local.name_prefix}"
  target_key_id = aws_kms_key.main.key_id
}

#------------------------------------------------------------------------------
# Storage Module (S3 + DynamoDB)
#------------------------------------------------------------------------------

module "storage" {
  source = "../../modules/solution/storage"

  project        = local.project
  aws_account_id = data.aws_caller_identity.current.account_id

  storage = var.storage

  database = var.database

  # Trigger document processing on upload
  processing_trigger_lambda_arn = module.document_processing.lambda_arns.validate_document

  kms_key_arn = aws_kms_key.main.arn

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Document Processing Module (Textract + Comprehend + Step Functions)
#------------------------------------------------------------------------------

module "document_processing" {
  source = "../../modules/solution/document-processing"

  project = local.project

  lambda_runtime = var.application.lambda_runtime

  # Lambda deployment packages (placeholders - to be built by CI/CD)
  lambda_packages = {
    start_analysis      = var.lambda_packages.start_analysis
    process_textract    = var.lambda_packages.process_textract
    comprehend_analysis = var.lambda_packages.comprehend_analysis
    validate_document   = var.lambda_packages.validate_document
    finalize_results    = var.lambda_packages.finalize_results
  }

  lambda_source_hashes = {
    start_analysis      = var.lambda_source_hashes.start_analysis
    process_textract    = var.lambda_source_hashes.process_textract
    comprehend_analysis = var.lambda_source_hashes.comprehend_analysis
    validate_document   = var.lambda_source_hashes.validate_document
    finalize_results    = var.lambda_source_hashes.finalize_results
  }

  # VPC configuration (optional - for VPC-bound Lambda)
  vpc_subnet_ids         = var.application.lambda_vpc_enabled ? var.network.private_subnet_ids : null
  vpc_security_group_ids = var.application.lambda_vpc_enabled ? [aws_security_group.lambda[0].id] : []

  # Storage references
  documents_bucket_name = module.storage.documents_bucket_name
  documents_bucket_arn  = module.storage.documents_bucket_arn
  results_table_name    = module.storage.results_table_name
  results_table_arn     = module.storage.results_table_arn

  # Human review queue (for low-confidence results)
  human_review_queue_url = var.human_review.enabled ? module.human_review[0].review_queue_url : null
  human_review_queue_arn = var.human_review.enabled ? module.human_review[0].review_queue_arn : null

  # AI service configurations
  textract   = var.textract
  comprehend = var.comprehend

  logging    = var.logging
  monitoring = var.monitoring

  kms_key_arn = aws_kms_key.main.arn

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Human Review Module (A2I)
#------------------------------------------------------------------------------

module "human_review" {
  source = "../../modules/solution/human-review"
  count  = var.human_review.enabled ? 1 : 0

  project = local.project

  lambda_runtime = var.application.lambda_runtime

  lambda_packages = {
    process_review = var.lambda_packages.process_review
    create_task    = var.lambda_packages.create_task
    complete_task  = var.lambda_packages.complete_task
  }

  lambda_source_hashes = {
    process_review = var.lambda_source_hashes.process_review
    create_task    = var.lambda_source_hashes.create_task
    complete_task  = var.lambda_source_hashes.complete_task
  }

  vpc_subnet_ids         = var.application.lambda_vpc_enabled ? var.network.private_subnet_ids : null
  vpc_security_group_ids = var.application.lambda_vpc_enabled ? [aws_security_group.lambda[0].id] : []

  # Storage references
  documents_bucket_name = module.storage.documents_bucket_name
  documents_bucket_arn  = module.storage.documents_bucket_arn
  results_table_name    = module.storage.results_table_name
  results_table_arn     = module.storage.results_table_arn

  # Step Functions reference
  step_functions_arn = module.document_processing.state_machine_arn

  # A2I configuration
  a2i = var.human_review

  kms_key_arn = aws_kms_key.main.arn

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# API Module (API Gateway + Lambda)
#------------------------------------------------------------------------------

module "api" {
  source = "../../modules/solution/api"

  project = local.project

  lambda_runtime = var.application.lambda_runtime

  lambda_packages = {
    upload  = var.lambda_packages.api_upload
    status  = var.lambda_packages.api_status
    results = var.lambda_packages.api_results
    list    = var.lambda_packages.api_list
    delete  = var.lambda_packages.api_delete
    health  = var.lambda_packages.api_health
  }

  lambda_source_hashes = {
    upload  = var.lambda_source_hashes.api_upload
    status  = var.lambda_source_hashes.api_status
    results = var.lambda_source_hashes.api_results
    list    = var.lambda_source_hashes.api_list
    delete  = var.lambda_source_hashes.api_delete
    health  = var.lambda_source_hashes.api_health
  }

  vpc_subnet_ids         = var.application.lambda_vpc_enabled ? var.network.private_subnet_ids : null
  vpc_security_group_ids = var.application.lambda_vpc_enabled ? [aws_security_group.lambda[0].id] : []

  # Storage references
  documents_bucket_name = module.storage.documents_bucket_name
  documents_bucket_arn  = module.storage.documents_bucket_arn
  results_table_name    = module.storage.results_table_name
  results_table_arn     = module.storage.results_table_arn

  # Step Functions reference
  state_machine_arn = module.document_processing.state_machine_arn

  # Authentication
  cognito_user_pool_arn = var.auth.enabled ? module.auth[0].user_pool_arn : null

  # API configuration
  api = var.api

  logging    = var.logging
  monitoring = var.monitoring

  kms_key_arn = aws_kms_key.main.arn

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Authentication Module (Cognito)
#------------------------------------------------------------------------------

module "auth" {
  source = "../../modules/aws/cognito"
  count  = var.auth.enabled ? 1 : 0

  user_pool_name = "${local.name_prefix}-users"

  # Username configuration
  username_attributes      = var.auth.username_attributes
  auto_verified_attributes = var.auth.auto_verified_attributes

  # Password policy
  password_minimum_length  = var.auth.password_minimum_length
  password_require_lowercase = var.auth.password_require_lowercase
  password_require_numbers   = var.auth.password_require_numbers
  password_require_symbols   = var.auth.password_require_symbols
  password_require_uppercase = var.auth.password_require_uppercase

  # MFA
  mfa_configuration = var.auth.mfa_configuration

  # Advanced security
  advanced_security_mode = var.auth.advanced_security_mode

  # Domain
  domain = var.auth.domain

  # Clients
  clients = {
    web = {
      generate_secret = false
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      callback_urls = var.auth.callback_urls
      logout_urls   = var.auth.logout_urls
    }
    api = {
      generate_secret = true
      explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
    }
  }

  # User groups
  user_groups = {
    admins = {
      description = "IDP Administrators"
      precedence  = 1
    }
    reviewers = {
      description = "Human Review Team"
      precedence  = 2
    }
    users = {
      description = "Standard Users"
      precedence  = 3
    }
  }

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Lambda VPC Security Group (optional)
#------------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  count = var.application.lambda_vpc_enabled ? 1 : 0

  name        = "${local.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-lambda-sg"
  })
}

#------------------------------------------------------------------------------
# CloudWatch Alarms
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "api_errors" {
  count = var.monitoring.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.monitoring.api_error_threshold
  alarm_description   = "API Gateway 5XX errors exceeded threshold"

  dimensions = {
    ApiName = module.api.api_id
    Stage   = var.api.stage_name
  }

  alarm_actions = var.monitoring.sns_topic_arn != null ? [var.monitoring.sns_topic_arn] : []

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "step_functions_failed" {
  count = var.monitoring.enable_alarms ? 1 : 0

  alarm_name          = "${local.name_prefix}-sfn-failed-executions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 300
  statistic           = "Sum"
  threshold           = var.monitoring.sfn_failure_threshold
  alarm_description   = "Step Functions execution failures exceeded threshold"

  dimensions = {
    StateMachineArn = module.document_processing.state_machine_arn
  }

  alarm_actions = var.monitoring.sns_topic_arn != null ? [var.monitoring.sns_topic_arn] : []

  tags = local.common_tags
}

#------------------------------------------------------------------------------
# DR Vault Module (Creates DR Region Infrastructure)
#------------------------------------------------------------------------------
# Provisions resources in DR region to receive replicated data:
# - KMS key for DR encryption
# - S3 bucket for document replication (CRR destination)
# - Backup vault for DynamoDB backup copies
# - IAM roles for restore operations
#------------------------------------------------------------------------------

module "dr_vault" {
  source = "../../modules/solution/dr-vault"
  count  = var.dr.vault_enabled ? 1 : 0

  providers = {
    aws = aws.dr
  }

  project = local.project

  dr = {
    vault_enabled                          = var.dr.vault_enabled
    vault_kms_deletion_window_days         = var.dr.vault_kms_deletion_window_days
    vault_transition_to_ia_days            = var.dr.vault_transition_to_ia_days
    vault_noncurrent_version_expiration_days = var.dr.vault_noncurrent_version_expiration_days
    vault_enable_lock                      = var.dr.vault_enable_lock
  }

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# DR Replication Module (Configures Replication from Prod to DR)
#------------------------------------------------------------------------------
# Sets up cross-region replication:
# - S3 Cross-Region Replication (CRR) for continuous document sync
# - AWS Backup plans with cross-region copy for DynamoDB
# - IAM roles for replication operations
# - CloudWatch alarms for replication monitoring
#------------------------------------------------------------------------------

module "dr_replication" {
  source = "../../modules/solution/dr-replication"
  count  = var.dr.replication_enabled ? 1 : 0

  project = local.project

  # Source resources (from storage module)
  source_bucket_id                 = module.storage.documents_bucket_id
  source_bucket_arn                = module.storage.documents_bucket_arn
  source_bucket_versioning_enabled = true
  results_table_arn                = module.storage.results_table_arn
  jobs_table_arn                   = module.storage.jobs_table_arn
  kms_key_arn                      = aws_kms_key.main.arn
  sns_topic_arn                    = var.monitoring.sns_topic_arn

  # DR configuration from consolidated dr variable
  dr = {
    enabled                         = var.dr.replication_enabled
    dr_region                       = var.aws.dr_region
    dr_bucket_arn                   = var.dr.vault_enabled ? module.dr_vault[0].bucket_arn : ""
    dr_bucket_id                    = var.dr.vault_enabled ? module.dr_vault[0].bucket_id : ""
    dr_kms_key_arn                  = var.dr.vault_enabled ? module.dr_vault[0].kms_key_arn : ""
    dr_vault_arn                    = var.dr.vault_enabled ? module.dr_vault[0].vault_arn : ""
    storage_replication_class       = var.dr.storage_replication_class
    enable_replication_time_control = var.dr.enable_replication_time_control
    backup_local_retention_days     = var.dr.backup_local_retention_days
    backup_retention_days           = var.dr.backup_retention_days
    enable_weekly_backup            = var.dr.enable_weekly_backup
    weekly_backup_retention_days    = var.dr.weekly_backup_retention_days
  }

  common_tags = local.common_tags

  depends_on = [module.dr_vault]
}

#------------------------------------------------------------------------------
# Well-Architected: Cost Optimization - AWS Budgets
#------------------------------------------------------------------------------
# Monitors spend and alerts before costs exceed thresholds
# Critical for IDP due to variable AI service costs (Textract, Comprehend)
#------------------------------------------------------------------------------

module "budget" {
  source = "../../modules/aws/best-practices/cost-optimization/budgets"
  count  = var.budget.enabled ? 1 : 0

  name_prefix = local.name_prefix
  environment = local.environment

  budget = {
    enabled               = var.budget.enabled
    monthly_amount        = var.budget.monthly_amount
    alert_thresholds      = var.budget.alert_thresholds
    enable_forecast_alert = var.budget.enable_forecast_alert
    alert_emails          = var.budget.alert_emails
    # Filter to this solution's resources by tag
    cost_filter_tags = {
      Solution = var.solution.name
    }
  }

  sns_topic_arns = var.monitoring.sns_topic_arn != null ? [var.monitoring.sns_topic_arn] : []

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Well-Architected: Operational Excellence - AWS Config Rules
#------------------------------------------------------------------------------
# Continuous compliance monitoring and configuration drift detection
# Important for IDP handling sensitive documents
#------------------------------------------------------------------------------

module "config_rules" {
  source = "../../modules/aws/best-practices/operational-excellence/config-rules"
  count  = var.config_rules.enabled ? 1 : 0

  name_prefix = local.name_prefix

  config_rules = {
    enabled                  = var.config_rules.enabled
    create_recorder          = var.config_rules.enable_recorder
    retention_days           = var.config_rules.retention_days
    enable_security_rules    = var.config_rules.enable_security_rules
    enable_reliability_rules = var.config_rules.enable_reliability_rules
    # IDP-specific: focus on S3, DynamoDB, Lambda, API Gateway
    record_all_resources     = true
    include_global_resources = true
  }

  kms_key_arn   = aws_kms_key.main.arn
  sns_topic_arn = var.monitoring.sns_topic_arn

  common_tags = local.common_tags
}

#------------------------------------------------------------------------------
# Well-Architected: Security - GuardDuty Threat Detection
#------------------------------------------------------------------------------
# Threat detection with S3 malware protection for uploaded documents
# Essential for IDP accepting files from external users
#------------------------------------------------------------------------------

module "guardduty" {
  source = "../../modules/aws/best-practices/security/guardduty"
  count  = var.guardduty.enabled ? 1 : 0

  name_prefix = local.name_prefix

  guardduty = {
    enabled                   = var.guardduty.enabled
    enable_s3_protection      = var.guardduty.enable_s3_protection
    enable_malware_protection = var.guardduty.enable_malware_protection
    alert_severity_threshold  = var.guardduty.severity_threshold
    enable_alerts             = true
    # Export findings for analysis
    enable_s3_export          = true
    findings_retention_days   = 365
  }

  kms_key_arn   = aws_kms_key.main.arn
  sns_topic_arn = var.monitoring.sns_topic_arn

  common_tags = local.common_tags
}

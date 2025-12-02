#------------------------------------------------------------------------------
# IDP Test Environment
#------------------------------------------------------------------------------
# Intelligent Document Processing - Serverless document processing with
# AWS Textract, Comprehend, and Step Functions orchestration
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  #----------------------------------------------------------------------------
  # Shared Configuration Objects
  #----------------------------------------------------------------------------
  project = {
    name        = var.solution.abbr
    environment = local.environment
  }

  common_tags = {
    Solution     = var.solution.name
    SolutionAbbr = var.solution.abbr
    Environment  = local.environment
    Provider     = var.solution.provider_name
    Category     = var.solution.category_name
    Region       = var.aws.region
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
  }

  #----------------------------------------------------------------------------
  # Lambda Configuration (shared by document_processing, human_review, idp_api)
  #----------------------------------------------------------------------------
  lambda = {
    runtime       = var.application.lambda_runtime
    packages      = var.lambda_packages
    source_hashes = var.lambda_source_hashes
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#===============================================================================
# FOUNDATION - Core infrastructure that other modules depend on
#===============================================================================
#------------------------------------------------------------------------------
# Security (KMS + Lambda VPC Security Group)
#------------------------------------------------------------------------------
module "security" {
  source = "../../modules/solution/security"

  project            = local.project
  security           = var.security
  lambda_vpc_enabled = var.application.lambda_vpc_enabled
  network            = var.network
  common_tags        = local.common_tags
}

#------------------------------------------------------------------------------
# Authentication (Cognito)
#------------------------------------------------------------------------------
module "auth" {
  source = "../../modules/aws/cognito"
  count  = var.auth.enabled ? 1 : 0

  user_pool_name = "${local.name_prefix}-users"
  auth           = var.auth
  common_tags    = local.common_tags

  clients = {
    web = {
      generate_secret     = false
      explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
      callback_urls       = var.auth.callback_urls
      logout_urls         = var.auth.logout_urls
    }
    api = {
      generate_secret     = true
      explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
    }
  }

  user_groups = {
    admins    = { description = "IDP Administrators", precedence = 1 }
    reviewers = { description = "Human Review Team", precedence = 2 }
    users     = { description = "Standard Users", precedence = 3 }
  }
}

#===============================================================================
# CORE SOLUTION - Primary solution components for document processing
#===============================================================================
#------------------------------------------------------------------------------
# Storage (S3 + DynamoDB)
#------------------------------------------------------------------------------
module "storage" {
  source = "../../modules/solution/storage"

  project        = local.project
  aws_account_id = data.aws_caller_identity.current.account_id
  storage        = var.storage
  database       = var.database
  kms_key_arn    = module.security.kms_key_arn
  common_tags    = local.common_tags

  depends_on = [module.security]
}

#------------------------------------------------------------------------------
# Human Review (A2I) - Created before document_processing to avoid circular deps
#------------------------------------------------------------------------------
module "human_review" {
  source = "../../modules/solution/human-review"
  count  = var.human_review.enabled ? 1 : 0

  project     = local.project
  lambda      = local.lambda
  vpc         = module.security.lambda_vpc
  storage     = module.storage.outputs
  a2i         = var.human_review
  kms_key_arn = module.security.kms_key_arn
  common_tags = local.common_tags

  depends_on = [module.security, module.storage]
}

#------------------------------------------------------------------------------
# Document Processing (Textract + Comprehend + Step Functions)
#------------------------------------------------------------------------------
module "document_processing" {
  source = "../../modules/solution/document-processing"

  project      = local.project
  lambda       = local.lambda
  vpc          = module.security.lambda_vpc
  storage      = module.storage.outputs
  ai_services  = { textract = var.textract, comprehend = var.comprehend }
  human_review = var.human_review.enabled ? module.human_review[0].outputs : null
  logging      = var.logging
  monitoring   = var.monitoring
  kms_key_arn  = module.security.kms_key_arn
  common_tags  = local.common_tags

  depends_on = [module.security, module.storage, module.human_review]
}

#------------------------------------------------------------------------------
# IDP API (REST interface for document upload, status, and results)
#------------------------------------------------------------------------------
module "idp_api" {
  source = "../../modules/solution/api"

  project               = local.project
  lambda                = local.lambda
  vpc                   = module.security.lambda_vpc
  storage               = module.storage.outputs
  state_machine_arn     = module.document_processing.state_machine_arn
  cognito_user_pool_arn = var.auth.enabled ? module.auth[0].user_pool_arn : null
  api                   = var.api
  logging               = var.logging
  monitoring            = var.monitoring
  kms_key_arn           = module.security.kms_key_arn
  common_tags           = local.common_tags

  depends_on = [module.security, module.auth, module.storage, module.document_processing]
}

#===============================================================================
# INTEGRATIONS - Wiring between modules (avoids circular dependencies)
#===============================================================================
#------------------------------------------------------------------------------
# SSM Parameter: Step Functions ARN (for human_review Lambda to lookup at runtime)
#------------------------------------------------------------------------------
resource "aws_ssm_parameter" "step_functions_arn" {
  count = var.human_review.enabled ? 1 : 0

  name        = module.human_review[0].ssm_step_functions_arn_path
  description = "Document processing Step Functions state machine ARN"
  type        = "String"
  value       = module.document_processing.state_machine_arn

  tags = local.common_tags

  depends_on = [module.document_processing]
}

#------------------------------------------------------------------------------
# S3 → Lambda Trigger (document upload triggers processing)
#------------------------------------------------------------------------------
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.document_processing.lambda_arns.validate_document
  principal     = "s3.amazonaws.com"
  source_arn    = module.storage.documents_bucket_arn

  depends_on = [module.document_processing]
}

resource "aws_s3_bucket_notification" "document_upload" {
  bucket = module.storage.documents_bucket_id

  lambda_function {
    lambda_function_arn = module.document_processing.lambda_arns.validate_document
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

#===============================================================================
# OPERATIONS - Disaster recovery, compliance, and observability
#===============================================================================
#------------------------------------------------------------------------------
# DR Infrastructure (Vault + Cross-Region Replication)
#------------------------------------------------------------------------------
module "dr" {
  source = "../../modules/solution/dr"
  count  = var.dr.vault_enabled || var.dr.replication_enabled ? 1 : 0

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  project       = local.project
  storage       = module.storage.outputs
  kms_key_arn   = module.security.kms_key_arn
  sns_topic_arn = var.monitoring.sns_topic_arn
  dr            = var.dr
  common_tags   = local.common_tags

  depends_on = [module.security, module.storage]
}

#------------------------------------------------------------------------------
# Best Practices (Budget + Config Rules + GuardDuty)
#------------------------------------------------------------------------------
module "best_practices" {
  source = "../../modules/solution/best-practices"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  name_prefix   = local.name_prefix
  environment   = local.environment
  kms_key_arn   = module.security.kms_key_arn
  sns_topic_arn = var.monitoring.sns_topic_arn != null ? var.monitoring.sns_topic_arn : ""
  common_tags   = local.common_tags

  budget       = var.budget
  config_rules = var.config_rules
  guardduty_enhanced = {
    enabled                   = var.guardduty.enabled
    enable_malware_protection = var.guardduty.enable_malware_protection
    severity_threshold        = var.guardduty.severity_threshold
  }

  depends_on = [module.security]
}

#------------------------------------------------------------------------------
# Monitoring (CloudWatch Alarms)
#------------------------------------------------------------------------------
module "monitoring" {
  source = "../../modules/solution/monitoring"
  count  = var.monitoring.enable_alarms ? 1 : 0

  project = local.project
  resources = {
    api_id            = module.idp_api.api_id
    api_stage         = var.api.stage_name
    state_machine_arn = module.document_processing.state_machine_arn
  }
  monitoring  = var.monitoring
  common_tags = local.common_tags

  depends_on = [module.idp_api, module.document_processing]
}

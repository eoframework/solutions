#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - DR Environment
#------------------------------------------------------------------------------
# Disaster Recovery configuration for CI/CD platform including:
# - GitHub organization Actions configuration (DR standby)
# - Self-hosted runner autoscaling groups (minimal capacity)
# - Container registry integration
# - Environment-based deployment governance
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

#------------------------------------------------------------------------------
# Locals
#------------------------------------------------------------------------------
locals {
  environment = basename(path.module)
  name_prefix = "${var.solution.abbr}-${local.environment}"

  # Environment display name mapping
  env_display_name = {
    prod = "Production"
    test = "Test"
    dr   = "Disaster Recovery"
  }

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
    ManagedBy    = "terraform"
    CostCenter   = var.ownership.cost_center
    Owner        = var.ownership.owner_email
    ProjectCode  = var.ownership.project_code
    Purpose      = "Disaster Recovery"
    Standby      = "true"
  }
}

#------------------------------------------------------------------------------
# Provider Configuration
#------------------------------------------------------------------------------
provider "github" {
  owner = var.github.organization_name
  token = var.auth.api_token
}

provider "aws" {
  region = var.aws.region

  default_tags {
    tags = local.common_tags
  }
}

#===============================================================================
# FOUNDATION - Organization Configuration
#===============================================================================
module "organization" {
  source = "../../modules/github/organization"

  organization = var.github.organization_name

  # Actions permissions
  allowed_actions                  = "selected"
  enabled_repositories             = "all"
  github_owned_allowed             = true
  verified_allowed                 = true
  patterns_allowed                 = var.actions_allowed_patterns
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false

  # Runner groups
  runner_groups = {
    default = {
      name                       = "default-runners"
      visibility                 = "all"
      allows_public_repositories = false
    }
    production = {
      name                       = "production-runners"
      visibility                 = "selected"
      repository_ids             = var.production_repository_ids
      allows_public_repositories = false
    }
    security = {
      name                       = "security-runners"
      visibility                 = "selected"
      repository_ids             = var.security_repository_ids
      allows_public_repositories = false
    }
  }

  # Organization secrets
  organization_secrets = var.organization_secrets

  # Organization variables
  organization_variables = {
    GITHUB_ORG       = var.github.organization_name
    ENVIRONMENT      = local.environment
    AWS_REGION       = var.aws.region
    AWS_ACCOUNT_ID   = var.aws.account_id
    EKS_CLUSTER_NAME = var.kubernetes.eks_cluster_name
    ECR_REGISTRY_URL = var.container.ecr_registry_url
    GHCR_REGISTRY    = var.container.ghcr_registry_url
  }
}

#===============================================================================
# CORE SOLUTION - Template Repository
#===============================================================================
module "github_repo" {
  source = "../../modules/github/repository"

  repository_name   = ".github"
  create_repository = var.create_github_repo
  description       = "Organization workflow templates and configuration"
  visibility        = "public"

  # Repository features
  has_issues      = true
  has_wiki        = false
  has_projects    = false
  has_discussions = false

  # Merge settings
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = true
  delete_branch_on_merge = true

  # Security
  vulnerability_alerts = true

  # Branch protection
  enable_branch_protection        = var.governance.branch_protection_enabled
  protected_branch_pattern        = "main"
  require_up_to_date_branch       = true
  required_status_checks          = ["lint", "validate"]
  dismiss_stale_reviews           = true
  require_code_owner_reviews      = true
  required_approving_review_count = var.governance.environment_reviewers_count
  enforce_admins                  = false
  require_signed_commits          = false
  require_linear_history          = true
  require_conversation_resolution = true

  # Repository secrets
  repository_secrets = {
    AWS_ROLE_ARN              = var.oidc.provider_arn
    DATADOG_API_KEY           = var.monitoring.datadog_api_key
    DATADOG_APP_KEY           = var.monitoring.datadog_app_key
    PAGERDUTY_INTEGRATION_KEY = var.monitoring.pagerduty_integration_key
  }

  # Repository variables
  repository_variables = {
    DEFAULT_RUNNER_GROUP  = "default-runners"
    WORKFLOW_TIMEOUT      = tostring(var.workflows.build_timeout)
    ARTIFACT_RETENTION    = tostring(var.workflows.artifact_retention)
    CACHE_KEY_PREFIX      = var.workflows.cache_key_prefix
  }

  # Environments with deployment protection
  environments = {
    production = {
      wait_timer = var.governance.environment_wait_timer
      reviewers = {
        teams = var.production_reviewer_teams
        users = var.production_reviewer_users
      }
      deployment_branch_policy = {
        protected_branches     = true
        custom_branch_policies = false
      }
      secrets = {
        AWS_DEPLOY_ROLE   = var.oidc.role_deploy
        SLACK_WEBHOOK_URL = var.notifications.slack_webhook_url
        TEAMS_WEBHOOK_URL = var.notifications.teams_webhook_url
      }
      variables = {
        AWS_REGION       = var.aws.region
        AWS_ACCOUNT_ID   = var.aws.account_id
        EKS_CLUSTER_NAME = var.kubernetes.eks_cluster_name
      }
    }
  }

  depends_on = [module.organization]
}

#===============================================================================
# OPERATIONS - Security Configuration
#===============================================================================
module "security" {
  source = "../../modules/github/security"

  repository_name = module.github_repo.repository_name

  # Advanced Security
  enable_advanced_security               = var.security.enable_security_scanning
  enable_secret_scanning                 = var.security.enable_secret_scanning
  enable_secret_scanning_push_protection = var.security.enable_secret_scanning

  # OIDC configuration
  enable_oidc_customization = true
  oidc_claim_keys           = ["repo", "context", "job_workflow_ref", "repository_owner"]

  # Security webhook
  enable_security_webhook = var.security.enable_security_scanning
  webhook_url             = var.notifications.slack_webhook_url
  webhook_secret          = ""

  depends_on = [module.github_repo]
}

#===============================================================================
# INTEGRATIONS - Self-Hosted Runners (AWS)
#===============================================================================
module "runners" {
  source = "../../modules/aws/runners"

  name_prefix = local.name_prefix
  tags        = local.common_tags

  # Network
  vpc_id            = var.runners.vpc_id
  subnet_ids        = split(",", var.runners.subnet_ids)
  security_group_id = var.runners.security_group_id

  # Linux runners
  linux_ami_id       = var.runners.ami_linux
  linux_instance_type = var.runners.instance_type_linux
  linux_asg_min      = var.runners.asg_min_linux
  linux_asg_max      = var.runners.asg_max_linux
  linux_asg_desired  = var.runners.count_linux

  # Windows runners
  windows_ami_id       = var.runners.ami_windows
  windows_instance_type = var.runners.instance_type_windows
  windows_asg_min      = var.runners.asg_min_windows
  windows_asg_max      = var.runners.asg_max_windows
  windows_asg_desired  = var.runners.count_windows

  # Scaling configuration
  scale_up_threshold   = var.runners.scale_up_threshold
  scale_down_cooldown  = var.runners.scale_down_cooldown

  # GitHub configuration
  github_organization = var.github.organization_name
  github_token        = var.auth.api_token

  depends_on = [module.organization]
}

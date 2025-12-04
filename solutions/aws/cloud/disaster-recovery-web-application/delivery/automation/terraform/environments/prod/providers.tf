#------------------------------------------------------------------------------
# DR Web Application - Production Environment Providers
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    # Values loaded from backend.tfvars via -backend-config flag
    # Run setup/backend/state-backend.sh to create backend resources
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws.region
  profile = var.aws.profile != "" ? var.aws.profile : null

  default_tags {
    tags = local.common_tags
  }
}

# DR region provider for cross-region resources
provider "aws" {
  alias   = "dr"
  region  = var.aws.dr_region
  profile = var.aws.profile != "" ? var.aws.profile : null

  default_tags {
    tags = local.common_tags
  }
}

#------------------------------------------------------------------------------
# DR Web Application - Test Environment Providers
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  backend "s3" {}

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

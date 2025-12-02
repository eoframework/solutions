#------------------------------------------------------------------------------
# DR Vault Module - Provider Requirements
#------------------------------------------------------------------------------
# This module requires an AWS provider to be passed explicitly because it
# operates in the DR region (via aws.dr alias from the root module).
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

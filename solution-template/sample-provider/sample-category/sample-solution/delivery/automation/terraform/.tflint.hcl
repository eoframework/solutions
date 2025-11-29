# TFLint Configuration
# Documentation: https://github.com/terraform-linters/tflint

config {
  # Enable module inspection
  module = true

  # Force to return error code
  force = false
}

# Terraform plugin for general Terraform checks
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS plugin for AWS-specific checks
plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Azure plugin for Azure-specific checks
plugin "azurerm" {
  enabled = true
  version = "0.25.1"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Google Cloud plugin for GCP-specific checks
plugin "google" {
  enabled = true
  version = "0.25.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}

# ============================================================
# Terraform Rules
# ============================================================

# Disallow deprecated syntax
rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Disallow legacy dot index syntax
rule "terraform_deprecated_index" {
  enabled = true
}

# Disallow variables, data sources, and locals that are declared but never used
rule "terraform_unused_declarations" {
  enabled = true
}

# Disallow output declarations without description
rule "terraform_documented_outputs" {
  enabled = true
}

# Disallow variable declarations without description
rule "terraform_documented_variables" {
  enabled = true
}

# Disallow variable declarations without type
rule "terraform_typed_variables" {
  enabled = true
}

# Enforce naming conventions
rule "terraform_naming_convention" {
  enabled = true

  # Use snake_case for all identifiers
  custom = "^[a-z][a-z0-9_]*$"

  variable {
    custom = "^[a-z][a-z0-9_]*$"
  }

  locals {
    custom = "^[a-z][a-z0-9_]*$"
  }

  output {
    custom = "^[a-z][a-z0-9_]*$"
  }

  resource {
    custom = "^[a-z][a-z0-9_]*$"
  }

  module {
    custom = "^[a-z][a-z0-9_]*$"
  }

  data {
    custom = "^[a-z][a-z0-9_]*$"
  }
}

# Require terraform version constraint
rule "terraform_required_version" {
  enabled = true
}

# Require provider version constraints
rule "terraform_required_providers" {
  enabled = true
}

# Disallow terraform workspace switching
rule "terraform_workspace_remote" {
  enabled = true
}

# ============================================================
# AWS-Specific Rules
# ============================================================

# Ensure EC2 instances have detailed monitoring enabled
rule "aws_instance_invalid_type" {
  enabled = true
}

# Ensure RDS instances are not publicly accessible
rule "aws_db_instance_invalid_type" {
  enabled = true
}

# Ensure S3 buckets have versioning enabled
rule "aws_s3_bucket_invalid_acl" {
  enabled = true
}

# ============================================================
# Azure-Specific Rules
# ============================================================

# Ensure valid Azure VM sizes
rule "azurerm_linux_virtual_machine_invalid_size" {
  enabled = true
}

rule "azurerm_windows_virtual_machine_invalid_size" {
  enabled = true
}

# ============================================================
# GCP-Specific Rules
# ============================================================

# Ensure valid GCP machine types
rule "google_compute_instance_invalid_machine_type" {
  enabled = true
}

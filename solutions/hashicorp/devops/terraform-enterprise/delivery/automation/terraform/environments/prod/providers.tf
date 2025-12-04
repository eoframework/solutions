#------------------------------------------------------------------------------
# Terraform Configuration and Providers
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.50"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # Backend configuration - use setup/backend for initialization
  backend "s3" {}
}

#------------------------------------------------------------------------------
# AWS Provider - Primary Region
#------------------------------------------------------------------------------
provider "aws" {
  region = var.aws.region

  default_tags {
    tags = {
      Solution    = var.solution.name
      Environment = basename(path.module)
      ManagedBy   = "terraform"
    }
  }
}

#------------------------------------------------------------------------------
# AWS Provider - DR Region
#------------------------------------------------------------------------------
provider "aws" {
  alias  = "dr"
  region = var.aws.dr_region

  default_tags {
    tags = {
      Solution    = var.solution.name
      Environment = "${basename(path.module)}-dr"
      ManagedBy   = "terraform"
    }
  }
}

#------------------------------------------------------------------------------
# Terraform Enterprise Provider
#------------------------------------------------------------------------------
provider "tfe" {
  hostname = var.tfe.hostname
  # Token provided via TFE_TOKEN environment variable or terraform.tfvars
}

#------------------------------------------------------------------------------
# Kubernetes Provider (for EKS)
#------------------------------------------------------------------------------
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

#------------------------------------------------------------------------------
# Helm Provider (for Terraform Enterprise deployment)
#------------------------------------------------------------------------------
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

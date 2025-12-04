#------------------------------------------------------------------------------
# Terraform and Provider Configuration
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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.50"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.20"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.18"
    }
  }
}

#------------------------------------------------------------------------------
# AWS Provider - Primary Region
#------------------------------------------------------------------------------
provider "aws" {
  region  = var.aws.region
  profile = var.aws.profile != "" ? var.aws.profile : null

  default_tags {
    tags = local.common_tags
  }
}

#------------------------------------------------------------------------------
# AWS Provider - DR Region
#------------------------------------------------------------------------------
provider "aws" {
  alias   = "dr"
  region  = var.aws.dr_region
  profile = var.aws.profile != "" ? var.aws.profile : null

  default_tags {
    tags = local.common_tags
  }
}

#------------------------------------------------------------------------------
# Kubernetes Provider (for EKS management)
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
# Helm Provider (for Kubernetes deployments)
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

#------------------------------------------------------------------------------
# Terraform Enterprise/Cloud Provider
#------------------------------------------------------------------------------
provider "tfe" {
  hostname = var.tfc.hostname
  # Token is set via TFE_TOKEN environment variable
}

#------------------------------------------------------------------------------
# HashiCorp Vault Provider
#------------------------------------------------------------------------------
provider "vault" {
  # Address is set via VAULT_ADDR environment variable
  # Token is set via VAULT_TOKEN environment variable
}

#------------------------------------------------------------------------------
# HashiCorp Consul Provider
#------------------------------------------------------------------------------
provider "consul" {
  # Address is set via CONSUL_HTTP_ADDR environment variable
  # Token is set via CONSUL_HTTP_TOKEN environment variable
}

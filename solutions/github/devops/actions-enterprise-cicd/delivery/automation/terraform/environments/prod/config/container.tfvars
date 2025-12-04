#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Production - Container Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

container = {
  ecr_registry_url     = "[account-prod].dkr.ecr.us-east-1.amazonaws.com"
  ghcr_registry_url    = "ghcr.io/[org]"
  image_retention_days = 90
}

kubernetes = {
  eks_cluster_name = "[eks-prod-cluster]"
}

#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - DR - Container Configuration
#------------------------------------------------------------------------------

container = {
  ecr_registry_url     = "[account-dr].dkr.ecr.us-west-2.amazonaws.com"
  ghcr_registry_url    = "ghcr.io/[org]"
  image_retention_days = 90
}

kubernetes = {
  eks_cluster_name = "[eks-dr-cluster]"
}

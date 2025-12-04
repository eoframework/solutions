#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Test - Container Configuration
#------------------------------------------------------------------------------

container = {
  ecr_registry_url     = "[account-test].dkr.ecr.us-east-1.amazonaws.com"
  ghcr_registry_url    = "ghcr.io/[org]"
  image_retention_days = 30
}

kubernetes = {
  eks_cluster_name = "[eks-test-cluster]"
}

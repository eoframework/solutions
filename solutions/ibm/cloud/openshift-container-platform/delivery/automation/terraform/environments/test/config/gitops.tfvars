#------------------------------------------------------------------------------
# Gitops Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:05
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

gitops = {
  argocd_enabled = true  # Enable ArgoCD for GitOps
  argocd_replicas = 1  # ArgoCD server replica count
  argocd_repo_url = "https://github.com/company/gitops-config"  # ArgoCD Git repository URL
}

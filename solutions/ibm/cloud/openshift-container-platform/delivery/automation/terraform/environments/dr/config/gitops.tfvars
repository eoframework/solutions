#------------------------------------------------------------------------------
# Gitops Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:06
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

gitops = {
  argocd_enabled = true  # Enable ArgoCD for GitOps
  argocd_replicas = 2  # ArgoCD server replica count
  argocd_repo_url = "https://github.com/company/gitops-config"  # ArgoCD Git repository URL
}

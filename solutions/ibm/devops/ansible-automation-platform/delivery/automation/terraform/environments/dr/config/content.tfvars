#------------------------------------------------------------------------------
# Content Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

content = {
  execution_environments = ["ee-base", "ee-network", "ee-cloud"]  # Execution environment images
  git_branch_prod = "main"  # Production Git branch
  git_repo_url = "https://github.com/company/ansible-playbooks"  # Playbook Git repository URL
  sync_interval_minutes = 5  # Project sync interval in minutes
}

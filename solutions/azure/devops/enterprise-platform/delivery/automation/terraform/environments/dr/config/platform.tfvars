#------------------------------------------------------------------------------
# Platform Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:41:39
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

platform = {
  devops_org_name = "contoso-dr-devops"  # Azure DevOps organization name
  devops_process_template = "Agile"  # Azure DevOps process template
  parallel_jobs_hosted = 5  # Microsoft-hosted parallel job count
  parallel_jobs_self = 2  # Self-hosted parallel job count
}

#------------------------------------------------------------------------------
# Pipelines Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:03
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

pipelines = {
  default_service_account = "pipeline"  # Default service account for pipelines
  tekton_enabled = true  # Enable OpenShift Pipelines
  # Default pipeline execution timeout in hours
  timeout_hours = 1
}

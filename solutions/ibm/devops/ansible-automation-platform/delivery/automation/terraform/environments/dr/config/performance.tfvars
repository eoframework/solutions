#------------------------------------------------------------------------------
# Performance Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

performance = {
  forks_default = 5  # Default Ansible forks
  job_event_buffer_seconds = 5  # Job event buffer interval
  job_timeout_seconds = 3600  # Default job timeout in seconds
  max_concurrent_jobs = 100  # Maximum concurrent job executions
}

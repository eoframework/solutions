#------------------------------------------------------------------------------
# Avd Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

avd = {
  host_pool_type = "Pooled"  # Host pool type (Pooled or Personal)
  load_balancer = "BreadthFirst"  # Load balancing algorithm
  max_session_limit = 10  # Maximum sessions per host
  personal_assignment = "Automatic"  # Personal desktop assignment type
  start_vm_on_connect = true  # Start VMs automatically on connect
  validate_environment = false  # Mark as validation environment
}

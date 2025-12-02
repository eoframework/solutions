#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-01 22:34:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

compute = {
  api_gateway_stage = "v1"  # API Gateway stage
  api_throttle_burst = 100  # API burst limit
  api_throttle_rate = 50  # API steady-state rate
  enable_xray = true  # Enable X-Ray tracing
  lambda_memory = 512  # Lambda memory (MB)
  lambda_provisioned_concurrency = 0  # Provisioned concurrency
  lambda_reserved_concurrency = 50  # Reserved concurrency
  lambda_runtime = "python3.11"  # Lambda runtime
  lambda_timeout = 300  # Lambda timeout (seconds)
  lambda_vpc_enabled = false  # Enable Lambda VPC mode
  step_functions_enabled = true  # Enable Step Functions
  step_functions_type = "STANDARD"  # Step Functions type
}

#------------------------------------------------------------------------------
# Compute Configuration - Production Environment
#------------------------------------------------------------------------------

compute = {
  app_service_plan_sku      = "P1v3"
  app_service_plan_tier     = "PremiumV3"
  autoscale_enabled         = true
  autoscale_min_instances   = 2
  autoscale_max_instances   = 10
  deployment_slots_enabled  = true
}

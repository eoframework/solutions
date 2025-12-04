#------------------------------------------------------------------------------
# Autoscale Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:17
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

autoscale = {
  enabled = false  # Enable auto-scaling for session hosts
  max_hosts = 3  # Maximum number of session hosts
  min_hosts = 1  # Minimum number of session hosts
  off_peak_start = "18:00"  # Off-peak hours start time (HH:MM)
  peak_start = "09:00"  # Peak hours start time (HH:MM)
  ramp_down_capacity = 50  # Ramp down capacity threshold percentage
  ramp_down_start = "17:00"  # Ramp down start time (HH:MM)
  ramp_up_capacity = 60  # Ramp up capacity threshold percentage
  ramp_up_start = "08:00"  # Ramp up start time (HH:MM)
  # Scale down when utilization below percentage
  scale_down_threshold = 20
  # Scale up when utilization exceeds percentage
  scale_up_threshold = 80
  timezone = "Eastern Standard Time"  # Timezone for scaling schedule
}

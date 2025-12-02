#------------------------------------------------------------------------------
# Database Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-02 00:00:41
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  autoscaling_max_read = 50  # Autoscaling max read
  autoscaling_max_write = 50  # Autoscaling max write
  autoscaling_min_read = 5  # Autoscaling min read
  autoscaling_min_write = 5  # Autoscaling min write
  autoscaling_target_utilization = 70  # Autoscaling target utilization
  billing_mode = "PAY_PER_REQUEST"  # DynamoDB billing mode
  enable_autoscaling = false  # Enable autoscaling
  gsi_read_capacity = 5  # GSI read capacity (PROVISIONED)
  gsi_write_capacity = 5  # GSI write capacity (PROVISIONED)
  point_in_time_recovery = false  # Enable point-in-time recovery
  read_capacity = 5  # DynamoDB read capacity (PROVISIONED)
  stream_enabled = false  # Enable DynamoDB streams
  stream_view_type = "NEW_AND_OLD_IMAGES"  # Stream view type
  ttl_enabled = true  # Enable TTL
  write_capacity = 5  # DynamoDB write capacity (PROVISIONED)
}

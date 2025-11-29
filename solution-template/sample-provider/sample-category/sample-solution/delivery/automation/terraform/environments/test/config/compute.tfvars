#------------------------------------------------------------------------------
# Compute Configuration - TEST Environment
#------------------------------------------------------------------------------

instance_type  = "t3.small"           # Test: smaller instance
use_latest_ami = true

root_volume_size       = 30           # Test: smaller volume
root_volume_type       = "gp3"
root_volume_iops       = 3000
root_volume_throughput = 125

enable_detailed_monitoring = false    # Test: disabled

enable_auto_scaling    = true
asg_min_size           = 1            # Test: minimal
asg_max_size           = 2
asg_desired_capacity   = 1

health_check_grace_period = 300

scale_up_threshold   = 70
scale_down_threshold = 30

enable_alb                    = true
alb_internal                  = false
enable_lb_deletion_protection = false # Test: disabled for easy teardown

health_check_path     = "/health"
health_check_interval = 30
health_check_timeout  = 5
healthy_threshold     = 2
unhealthy_threshold   = 3

app_port = 8080

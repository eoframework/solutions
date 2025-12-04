#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Production - Runners Configuration
#------------------------------------------------------------------------------
# Generated from configuration.csv - DO NOT EDIT DIRECTLY
# Use eof-tools/automation/scripts/generate-tfvars.py to regenerate
#------------------------------------------------------------------------------

runners = {
  vpc_id              = "[vpc-prod-id]"
  subnet_ids          = "[subnet-prod-1,subnet-prod-2]"
  security_group_id   = "[sg-prod-id]"
  instance_type_linux = "c5.2xlarge"
  instance_type_windows = "c5.2xlarge"
  count_linux         = 16
  count_windows       = 4
  asg_min_linux       = 8
  asg_max_linux       = 24
  asg_min_windows     = 2
  asg_max_windows     = 6
  scale_up_threshold  = 5
  scale_down_cooldown = 900
  ami_linux           = "[ami-linux-prod]"
  ami_windows         = "[ami-windows-prod]"
}

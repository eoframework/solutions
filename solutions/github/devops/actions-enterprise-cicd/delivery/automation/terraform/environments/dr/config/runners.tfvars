#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - DR - Runners Configuration
#------------------------------------------------------------------------------

runners = {
  vpc_id              = "[vpc-dr-id]"
  subnet_ids          = "[subnet-dr-1,subnet-dr-2]"
  security_group_id   = "[sg-dr-id]"
  instance_type_linux = "c5.2xlarge"
  instance_type_windows = "c5.2xlarge"
  count_linux         = 4
  count_windows       = 1
  asg_min_linux       = 1
  asg_max_linux       = 12
  asg_min_windows     = 0
  asg_max_windows     = 4
  scale_up_threshold  = 5
  scale_down_cooldown = 900
  ami_linux           = "[ami-linux-dr]"
  ami_windows         = "[ami-windows-dr]"
}

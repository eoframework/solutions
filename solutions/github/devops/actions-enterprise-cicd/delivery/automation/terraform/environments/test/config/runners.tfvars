#------------------------------------------------------------------------------
# GitHub Actions Enterprise CI/CD - Test - Runners Configuration
#------------------------------------------------------------------------------

runners = {
  vpc_id              = "[vpc-test-id]"
  subnet_ids          = "[subnet-test-1]"
  security_group_id   = "[sg-test-id]"
  instance_type_linux = "t3.large"
  instance_type_windows = "t3.large"
  count_linux         = 2
  count_windows       = 1
  asg_min_linux       = 1
  asg_max_linux       = 4
  asg_min_windows     = 0
  asg_max_windows     = 2
  scale_up_threshold  = 3
  scale_down_cooldown = 600
  ami_linux           = "[ami-linux-test]"
  ami_windows         = "[ami-windows-test]"
}

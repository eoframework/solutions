#------------------------------------------------------------------------------
# AWS Self-Hosted GitHub Actions Runners Module
#------------------------------------------------------------------------------
# Deploys auto-scaling groups for self-hosted GitHub Actions runners:
# - Linux runners for general workloads
# - Windows runners for .NET/Windows builds
# - Auto-scaling based on workflow queue depth
#------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_region" "current" {}

#------------------------------------------------------------------------------
# IAM Role for Runners
#------------------------------------------------------------------------------
resource "aws_iam_role" "runner" {
  name = "${var.name_prefix}-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy" "runner_secrets" {
  name = "${var.name_prefix}-runner-secrets"
  role = aws_iam_role.runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.github_token.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "runner" {
  name = "${var.name_prefix}-runner-profile"
  role = aws_iam_role.runner.name

  tags = var.tags
}

#------------------------------------------------------------------------------
# Secrets Manager for GitHub Token
#------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "github_token" {
  name        = "${var.name_prefix}/github-runner-token"
  description = "GitHub PAT for self-hosted runner registration"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "github_token" {
  secret_id     = aws_secretsmanager_secret.github_token.id
  secret_string = var.github_token
}

#------------------------------------------------------------------------------
# Launch Template - Linux Runners
#------------------------------------------------------------------------------
resource "aws_launch_template" "linux" {
  name_prefix   = "${var.name_prefix}-linux-"
  image_id      = var.linux_ami_id
  instance_type = var.linux_instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.runner.arn
  }

  vpc_security_group_ids = [var.security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 100
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/linux-userdata.sh.tpl", {
    github_organization = var.github_organization
    runner_name_prefix  = "${var.name_prefix}-linux"
    runner_labels       = "linux,self-hosted,${var.name_prefix}"
    secret_arn          = aws_secretsmanager_secret.github_token.arn
    aws_region          = data.aws_region.current.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name        = "${var.name_prefix}-linux-runner"
      RunnerType  = "linux"
      RunnerGroup = "default"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-linux-runner-volume"
    })
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Launch Template - Windows Runners
#------------------------------------------------------------------------------
resource "aws_launch_template" "windows" {
  count = var.windows_asg_max > 0 ? 1 : 0

  name_prefix   = "${var.name_prefix}-windows-"
  image_id      = var.windows_ami_id
  instance_type = var.windows_instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.runner.arn
  }

  vpc_security_group_ids = [var.security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 200
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/windows-userdata.ps1.tpl", {
    github_organization = var.github_organization
    runner_name_prefix  = "${var.name_prefix}-windows"
    runner_labels       = "windows,self-hosted,${var.name_prefix}"
    secret_arn          = aws_secretsmanager_secret.github_token.arn
    aws_region          = data.aws_region.current.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name        = "${var.name_prefix}-windows-runner"
      RunnerType  = "windows"
      RunnerGroup = "default"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-windows-runner-volume"
    })
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Auto Scaling Group - Linux Runners
#------------------------------------------------------------------------------
resource "aws_autoscaling_group" "linux" {
  name                = "${var.name_prefix}-linux-runners"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.linux_asg_min
  max_size            = var.linux_asg_max
  desired_capacity    = var.linux_asg_desired

  launch_template {
    id      = aws_launch_template.linux.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  default_cooldown          = var.scale_down_cooldown

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-linux-runner"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Auto Scaling Group - Windows Runners
#------------------------------------------------------------------------------
resource "aws_autoscaling_group" "windows" {
  count = var.windows_asg_max > 0 ? 1 : 0

  name                = "${var.name_prefix}-windows-runners"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.windows_asg_min
  max_size            = var.windows_asg_max
  desired_capacity    = var.windows_asg_desired

  launch_template {
    id      = aws_launch_template.windows[0].id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 600
  default_cooldown          = var.scale_down_cooldown

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-windows-runner"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Auto Scaling Policies - Linux
#------------------------------------------------------------------------------
resource "aws_autoscaling_policy" "linux_scale_up" {
  name                   = "${var.name_prefix}-linux-scale-up"
  autoscaling_group_name = aws_autoscaling_group.linux.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 2
  cooldown               = 300
}

resource "aws_autoscaling_policy" "linux_scale_down" {
  name                   = "${var.name_prefix}-linux-scale-down"
  autoscaling_group_name = aws_autoscaling_group.linux.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = var.scale_down_cooldown
}

#------------------------------------------------------------------------------
# CloudWatch Alarms for Auto Scaling
#------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "linux_high_cpu" {
  alarm_name          = "${var.name_prefix}-linux-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up Linux runners when CPU utilization is high"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.linux.name
  }

  alarm_actions = [aws_autoscaling_policy.linux_scale_up.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "linux_low_cpu" {
  alarm_name          = "${var.name_prefix}-linux-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Scale down Linux runners when CPU utilization is low"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.linux.name
  }

  alarm_actions = [aws_autoscaling_policy.linux_scale_down.arn]

  tags = var.tags
}

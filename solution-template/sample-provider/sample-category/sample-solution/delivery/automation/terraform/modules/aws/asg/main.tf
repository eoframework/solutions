# Generic AWS ASG Module
# Creates Auto Scaling Group with Launch Template and scaling policies

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_ami" "amazon_linux" {
  count       = var.use_latest_ami ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_id = var.use_latest_ami ? data.aws_ami.amazon_linux[0].id : var.ami_id
}

#------------------------------------------------------------------------------
# Launch Template
#------------------------------------------------------------------------------

resource "aws_launch_template" "this" {
  name          = "${var.name_prefix}-lt"
  image_id      = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  dynamic "iam_instance_profile" {
    for_each = var.instance_profile_name != "" ? [1] : []
    content {
      name = var.instance_profile_name
    }
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip
    security_groups             = var.security_group_ids
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      iops                  = var.root_volume_type == "gp3" || var.root_volume_type == "io1" || var.root_volume_type == "io2" ? var.root_volume_iops : null
      throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
      encrypted             = var.enable_ebs_encryption
      kms_key_id            = var.enable_ebs_encryption ? var.kms_key_arn : null
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = var.metadata_hop_limit
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  user_data = var.user_data_base64

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-volume"
    })
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Auto Scaling Group
#------------------------------------------------------------------------------

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  target_group_arns         = var.target_group_arns
  termination_policies      = var.termination_policies
  default_cooldown          = var.default_cooldown

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.instance_refresh_min_healthy
    }
  }

  dynamic "warm_pool" {
    for_each = var.enable_warm_pool ? [1] : []
    content {
      pool_state                  = var.warm_pool_state
      min_size                    = var.warm_pool_min_size
      max_group_prepared_capacity = var.warm_pool_max_size
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
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = false
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

#------------------------------------------------------------------------------
# Scaling Policies
#------------------------------------------------------------------------------

resource "aws_autoscaling_policy" "scale_up" {
  count = var.enable_scaling_policies ? 1 : 0

  name                   = "${var.name_prefix}-scale-up"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale_down" {
  count = var.enable_scaling_policies ? 1 : 0

  name                   = "${var.name_prefix}-scale-down"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.this.name
}

#------------------------------------------------------------------------------
# CloudWatch Alarms for Scaling
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.enable_scaling_policies ? 1 : 0

  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.scale_up_threshold
  alarm_description   = "Scale up when CPU exceeds ${var.scale_up_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_up[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count = var.enable_scaling_policies ? 1 : 0

  alarm_name          = "${var.name_prefix}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.scale_down_threshold
  alarm_description   = "Scale down when CPU falls below ${var.scale_down_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_down[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.tags
}

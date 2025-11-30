# Generic AWS ASG Module
# Creates Auto Scaling Group with Launch Template and scaling policies

data "aws_ami" "amazon_linux" {
  count       = var.compute.use_latest_ami ? 1 : 0
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
  ami_id = var.compute.use_latest_ami ? data.aws_ami.amazon_linux[0].id : var.compute.ami_id
}

#------------------------------------------------------------------------------
# Launch Template
#------------------------------------------------------------------------------

resource "aws_launch_template" "this" {
  name          = "${var.name_prefix}-lt"
  image_id      = local.ami_id
  instance_type = var.compute.instance_type

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != "" ? [1] : []
    content {
      name = var.iam_instance_profile_name
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.compute.root_volume_size
      volume_type           = var.compute.root_volume_type
      iops                  = var.compute.root_volume_type == "gp3" || var.compute.root_volume_type == "io1" || var.compute.root_volume_type == "io2" ? var.compute.root_volume_iops : null
      throughput            = var.compute.root_volume_type == "gp3" ? var.compute.root_volume_throughput : null
      encrypted             = var.security.enable_kms_encryption
      kms_key_id            = var.security.enable_kms_encryption ? var.kms_key_arn : null
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.security.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = var.security.metadata_hop_limit
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = var.compute.enable_detailed_monitoring
  }

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
  min_size                  = var.compute.asg_min_size
  max_size                  = var.compute.asg_max_size
  desired_capacity          = var.compute.asg_desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = var.health_check_type
  health_check_grace_period = var.compute.health_check_grace_period
  target_group_arns         = var.target_group_arns
  termination_policies      = ["Default"]
  default_cooldown          = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

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
  count = var.compute.enable_auto_scaling ? 1 : 0

  name                   = "${var.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale_down" {
  count = var.compute.enable_auto_scaling ? 1 : 0

  name                   = "${var.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

#------------------------------------------------------------------------------
# CloudWatch Alarms for Scaling
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.compute.enable_auto_scaling ? 1 : 0

  alarm_name          = "${var.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.compute.scale_up_threshold
  alarm_description   = "Scale up when CPU exceeds ${var.compute.scale_up_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_up[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count = var.compute.enable_auto_scaling ? 1 : 0

  alarm_name          = "${var.name_prefix}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.compute.scale_down_threshold
  alarm_description   = "Scale down when CPU falls below ${var.compute.scale_down_threshold}%"
  alarm_actions       = [aws_autoscaling_policy.scale_down[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.tags
}

# Generic AWS ALB Module
# Creates Application Load Balancer with listeners and target group

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# Application Load Balancer
#------------------------------------------------------------------------------

resource "aws_lb" "this" {
  name               = "${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = var.access_logs_bucket != "" ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

#------------------------------------------------------------------------------
# Target Group
#------------------------------------------------------------------------------

resource "aws_lb_target_group" "this" {
  name                 = "${var.name_prefix}-tg"
  port                 = var.target_port
  protocol             = var.target_protocol
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
  }

  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = var.stickiness_duration
      enabled         = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# HTTPS Listener
#------------------------------------------------------------------------------

resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = var.tags
}

#------------------------------------------------------------------------------
# HTTP Listener (redirect to HTTPS or forward)
#------------------------------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.certificate_arn == "" ? aws_lb_target_group.this.arn : null
  }

  tags = var.tags
}

#------------------------------------------------------------------------------
# Additional Certificates (for multiple domains)
#------------------------------------------------------------------------------

resource "aws_lb_listener_certificate" "additional" {
  for_each = toset(var.additional_certificate_arns)

  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = each.value
}

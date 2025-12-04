#------------------------------------------------------------------------------
# AWS NLB Module for OpenShift
#------------------------------------------------------------------------------
# Creates Network Load Balancers for API server and application ingress
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# API Load Balancer (internal or public)
#------------------------------------------------------------------------------
resource "aws_lb" "api" {
  name               = "${var.name_prefix}-api-nlb"
  internal           = var.api_internal
  load_balancer_type = "network"
  subnets            = var.api_internal ? var.private_subnet_ids : var.public_subnet_ids

  enable_cross_zone_load_balancing = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-nlb"
  })
}

resource "aws_lb_target_group" "api" {
  name     = "${var.name_prefix}-api-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    path                = "/readyz"
    port                = "6443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-api-tg"
  })
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group_attachment" "api" {
  count = length(var.control_plane_instance_ids)

  target_group_arn = aws_lb_target_group.api.arn
  target_id        = var.control_plane_instance_ids[count.index]
  port             = 6443
}

#------------------------------------------------------------------------------
# Machine Config Server Target Group (port 22623)
#------------------------------------------------------------------------------
resource "aws_lb_target_group" "mcs" {
  name     = "${var.name_prefix}-mcs-tg"
  port     = 22623
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "HTTPS"
    path                = "/healthz"
    port                = "22623"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-mcs-tg"
  })
}

resource "aws_lb_listener" "mcs" {
  load_balancer_arn = aws_lb.api.arn
  port              = 22623
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mcs.arn
  }
}

resource "aws_lb_target_group_attachment" "mcs" {
  count = length(var.control_plane_instance_ids)

  target_group_arn = aws_lb_target_group.mcs.arn
  target_id        = var.control_plane_instance_ids[count.index]
  port             = 22623
}

#------------------------------------------------------------------------------
# Ingress Load Balancer (public)
#------------------------------------------------------------------------------
resource "aws_lb" "ingress" {
  count = var.create_ingress_lb ? 1 : 0

  name               = "${var.name_prefix}-ingress-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_cross_zone_load_balancing = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ingress-nlb"
  })
}

resource "aws_lb_target_group" "ingress_http" {
  count = var.create_ingress_lb ? 1 : 0

  name     = "${var.name_prefix}-ingress-http-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "80"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ingress-http-tg"
  })
}

resource "aws_lb_listener" "ingress_http" {
  count = var.create_ingress_lb ? 1 : 0

  load_balancer_arn = aws_lb.ingress[0].arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_http[0].arn
  }
}

resource "aws_lb_target_group" "ingress_https" {
  count = var.create_ingress_lb ? 1 : 0

  name     = "${var.name_prefix}-ingress-https-tg"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    protocol            = "TCP"
    port                = "443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ingress-https-tg"
  })
}

resource "aws_lb_listener" "ingress_https" {
  count = var.create_ingress_lb ? 1 : 0

  load_balancer_arn = aws_lb.ingress[0].arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_https[0].arn
  }
}

resource "aws_lb_target_group_attachment" "ingress_http" {
  count = var.create_ingress_lb ? length(var.worker_instance_ids) : 0

  target_group_arn = aws_lb_target_group.ingress_http[0].arn
  target_id        = var.worker_instance_ids[count.index]
  port             = 80
}

resource "aws_lb_target_group_attachment" "ingress_https" {
  count = var.create_ingress_lb ? length(var.worker_instance_ids) : 0

  target_group_arn = aws_lb_target_group.ingress_https[0].arn
  target_id        = var.worker_instance_ids[count.index]
  port             = 443
}

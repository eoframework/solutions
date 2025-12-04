#------------------------------------------------------------------------------
# Cloud Migration Core Module
#------------------------------------------------------------------------------
# Provides landing zone infrastructure for on-premise to cloud migration:
# - VPC with public/private/database subnets
# - Application Load Balancer
# - Auto Scaling Group with EC2 instances
# - NAT Gateway for private subnet internet access
# - Site-to-Site VPN for hybrid connectivity
#------------------------------------------------------------------------------

locals {
  name_prefix = "${var.project.name}-${var.project.environment}"
  azs         = slice(data.aws_availability_zones.available.names, 0, 2)
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.network.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.network.vpc_cidr, 4, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-public-${local.azs[count.index]}"
    Tier = "Public"
  })
}

resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.network.vpc_cidr, 4, count.index + 4)
  availability_zone = local.azs[count.index]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-private-${local.azs[count.index]}"
    Tier = "Private"
  })
}

resource "aws_subnet" "database" {
  count = length(local.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.network.vpc_cidr, 4, count.index + 8)
  availability_zone = local.azs[count.index]

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-database-${local.azs[count.index]}"
    Tier = "Database"
  })
}

#------------------------------------------------------------------------------
# NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = var.network.enable_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-nat-eip"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.network.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.main]
}

#------------------------------------------------------------------------------
# Route Tables
#------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.network.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private.id
}

#------------------------------------------------------------------------------
# VPN Gateway (for hybrid connectivity)
#------------------------------------------------------------------------------
resource "aws_vpn_gateway" "main" {
  count = var.network.enable_site_to_site_vpn ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-vgw"
  })
}

resource "aws_vpn_gateway_attachment" "main" {
  count = var.network.enable_site_to_site_vpn ? 1 : 0

  vpc_id         = aws_vpc.main.id
  vpn_gateway_id = aws_vpn_gateway.main[0].id
}

# Route to on-premises network via VPN
resource "aws_route" "to_onprem" {
  count = var.network.enable_site_to_site_vpn && var.network.on_prem_cidr != "" ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.network.on_prem_cidr
  gateway_id             = aws_vpn_gateway.main[0].id

  depends_on = [aws_vpn_gateway_attachment.main]
}

#------------------------------------------------------------------------------
# Application Load Balancer
#------------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security.alb_security_group_id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.compute.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "main" {
  name     = "${local.name_prefix}-tg"
  port     = var.compute.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = var.compute.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

resource "aws_lb_listener" "https" {
  count = var.compute.ssl_certificate_arn != "" ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.compute.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.compute.ssl_certificate_arn != "" ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.compute.ssl_certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.compute.ssl_certificate_arn == "" ? aws_lb_target_group.main.arn : null
  }
}

#------------------------------------------------------------------------------
# Launch Template
#------------------------------------------------------------------------------
resource "aws_launch_template" "main" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = var.compute.ami_id != "" ? var.compute.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type = var.compute.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security.app_security_group_id]
  }

  iam_instance_profile {
    arn = var.compute.instance_profile_arn
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.compute.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.security.kms_key_arn
      delete_on_termination = true
    }
  }

  # Data volume
  dynamic "block_device_mappings" {
    for_each = var.compute.data_volume_size > 0 ? [1] : []
    content {
      device_name = "/dev/xvdb"

      ebs {
        volume_size           = var.compute.data_volume_size
        volume_type           = "gp3"
        encrypted             = true
        kms_key_id            = var.security.kms_key_arn
        delete_on_termination = false
      }
    }
  }

  user_data = var.compute.user_data_base64

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name   = "${local.name_prefix}-app"
      Backup = "true"
    })
  }

  tags = var.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Auto Scaling Group
#------------------------------------------------------------------------------
resource "aws_autoscaling_group" "main" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type   = "ELB"

  min_size         = var.compute.asg_min_size
  max_size         = var.compute.asg_max_size
  desired_capacity = var.compute.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = merge(var.common_tags, { Name = "${local.name_prefix}-app" })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# VPC Flow Logs
#------------------------------------------------------------------------------
resource "aws_flow_log" "main" {
  count = var.network.enable_flow_logs ? 1 : 0

  vpc_id                   = aws_vpc.main.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  max_aggregation_interval = 60

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-flow-logs"
  })
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.network.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${local.name_prefix}/flow-logs"
  retention_in_days = 30
  kms_key_id        = var.security.kms_key_arn

  tags = var.common_tags
}

resource "aws_iam_role" "flow_logs" {
  count = var.network.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.network.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

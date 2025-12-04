#------------------------------------------------------------------------------
# HashiCorp Vault Cluster Module
#------------------------------------------------------------------------------
# Deploys HashiCorp Vault cluster on AWS infrastructure
# Supports HCP Vault or self-managed on EC2/EKS
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Vault Server EC2 Instances (self-managed mode)
#------------------------------------------------------------------------------
resource "aws_instance" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? var.vault.node_count : 0

  ami                    = var.vault.ami_id
  instance_type          = var.vault.instance_type
  key_name               = var.vault.key_name
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.vault[0].id]
  iam_instance_profile   = aws_iam_instance_profile.vault[0].name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.vault.root_volume_size
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/templates/vault-userdata.sh.tpl", {
    vault_version     = var.vault.version
    vault_cluster_tag = "${var.name_prefix}-vault"
    kms_key_id        = var.kms_key_arn
    aws_region        = data.aws_region.current.name
  }))

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vault-${count.index}"
    Role = "vault-server"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

#------------------------------------------------------------------------------
# Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  name        = "${var.name_prefix}-vault-sg"
  description = "Security group for Vault servers"
  vpc_id      = var.vpc_id

  # Vault API
  ingress {
    description = "Vault API"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  # Vault cluster (Raft)
  ingress {
    description = "Vault cluster"
    from_port   = 8201
    to_port     = 8201
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vault-sg"
  })
}

#------------------------------------------------------------------------------
# IAM Role for Vault
#------------------------------------------------------------------------------
resource "aws_iam_role" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  name = "${var.name_prefix}-vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  name = "${var.name_prefix}-vault-policy"
  role = aws_iam_role.vault[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = var.kms_key_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "sts:AssumeRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  name = "${var.name_prefix}-vault-profile"
  role = aws_iam_role.vault[0].name
}

#------------------------------------------------------------------------------
# Network Load Balancer
#------------------------------------------------------------------------------
resource "aws_lb" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  name               = "${var.name_prefix}-vault-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  enable_deletion_protection = var.vault.enable_deletion_protection

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vault-nlb"
  })
}

resource "aws_lb_target_group" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  name     = "${var.name_prefix}-vault-tg"
  port     = 8200
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    port                = 8200
    protocol            = "HTTPS"
    path                = "/v1/sys/health"
  }

  tags = var.common_tags
}

resource "aws_lb_listener" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? 1 : 0

  load_balancer_arn = aws_lb.vault[0].arn
  port              = 8200
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault[0].arn
  }
}

resource "aws_lb_target_group_attachment" "vault" {
  count = var.vault.deployment_mode == "self-managed" ? var.vault.node_count : 0

  target_group_arn = aws_lb_target_group.vault[0].arn
  target_id        = aws_instance.vault[count.index].id
  port             = 8200
}

#------------------------------------------------------------------------------
# Data Sources
#------------------------------------------------------------------------------
data "aws_region" "current" {}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

#------------------------------------------------------------------------------
# AWS EC2 Module for Ansible Automation Platform
#------------------------------------------------------------------------------
# Creates EC2 instances for AAP controller, execution nodes, and hub
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# IAM Instance Profile
#------------------------------------------------------------------------------
resource "aws_iam_role" "aap_node" {
  name = "${var.name_prefix}-aap-node-role"

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

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "aap_ssm" {
  role       = aws_iam_role.aap_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "aap_custom" {
  name = "${var.name_prefix}-aap-policy"
  role = aws_iam_role.aap_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeTags",
          "s3:GetObject",
          "s3:ListBucket",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "aap_node" {
  name = "${var.name_prefix}-aap-profile"
  role = aws_iam_role.aap_node.name

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Controller Nodes
#------------------------------------------------------------------------------
resource "aws_instance" "controller" {
  count = var.controller_count

  ami                    = var.ami_id
  instance_type          = var.controller_instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = var.controller_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.aap_node.name
  key_name               = var.key_name

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/controller_userdata.sh.tpl", {
    hostname = "${var.name_prefix}-controller-${count.index}"
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-controller-${count.index}"
    Role = "controller"
  })
}

#------------------------------------------------------------------------------
# Execution Nodes
#------------------------------------------------------------------------------
resource "aws_instance" "execution" {
  count = var.execution_count

  ami                    = var.ami_id
  instance_type          = var.execution_instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = var.execution_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.aap_node.name
  key_name               = var.key_name

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/execution_userdata.sh.tpl", {
    hostname = "${var.name_prefix}-execution-${count.index}"
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-execution-${count.index}"
    Role = "execution"
  })
}

#------------------------------------------------------------------------------
# Private Automation Hub
#------------------------------------------------------------------------------
resource "aws_instance" "hub" {
  count = var.create_hub ? 1 : 0

  ami                    = var.ami_id
  instance_type          = var.hub_instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = var.hub_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.aap_node.name
  key_name               = var.key_name

  root_block_device {
    volume_size           = 200
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/hub_userdata.sh.tpl", {
    hostname = "${var.name_prefix}-hub"
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-hub"
    Role = "hub"
  })
}

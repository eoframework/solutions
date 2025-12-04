#------------------------------------------------------------------------------
# AWS EC2 Module for OpenShift Nodes
#------------------------------------------------------------------------------
# Creates EC2 instances for OpenShift bootstrap, control plane, and worker nodes
# Uses RHCOS AMI and ignition configs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# IAM Instance Profile
#------------------------------------------------------------------------------
resource "aws_iam_role" "ocp_node" {
  name = "${var.name_prefix}-ocp-node-role"

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

resource "aws_iam_role_policy_attachment" "ocp_node_ssm" {
  role       = aws_iam_role.ocp_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ocp_node_custom" {
  name = "${var.name_prefix}-ocp-node-policy"
  role = aws_iam_role.ocp_node.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "s3:GetObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ocp_node" {
  name = "${var.name_prefix}-ocp-node-profile"
  role = aws_iam_role.ocp_node.name

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Bootstrap Node (temporary)
#------------------------------------------------------------------------------
resource "aws_instance" "bootstrap" {
  count = var.create_bootstrap ? 1 : 0

  ami                    = var.rhcos_ami
  instance_type          = var.bootstrap_instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = var.control_plane_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ocp_node.name
  key_name               = var.key_name

  user_data = var.bootstrap_ignition_config

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-bootstrap"
    Role = "bootstrap"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}

#------------------------------------------------------------------------------
# Control Plane Nodes
#------------------------------------------------------------------------------
resource "aws_instance" "control_plane" {
  count = var.control_plane_count

  ami                    = var.rhcos_ami
  instance_type          = var.control_plane_instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = var.control_plane_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ocp_node.name
  key_name               = var.key_name

  user_data = var.master_ignition_config

  root_block_device {
    volume_size           = 120
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  tags = merge(var.common_tags, {
    Name                                        = "${var.cluster_name}-master-${count.index}"
    Role                                        = "master"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}

#------------------------------------------------------------------------------
# Worker Nodes
#------------------------------------------------------------------------------
resource "aws_instance" "worker" {
  count = var.worker_count

  ami                    = var.rhcos_ami
  instance_type          = var.worker_instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = var.worker_security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ocp_node.name
  key_name               = var.key_name

  user_data = var.worker_ignition_config

  root_block_device {
    volume_size           = 120
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    delete_on_termination = true
  }

  tags = merge(var.common_tags, {
    Name                                        = "${var.cluster_name}-worker-${count.index}"
    Role                                        = "worker"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  lifecycle {
    ignore_changes = [user_data]
  }
}

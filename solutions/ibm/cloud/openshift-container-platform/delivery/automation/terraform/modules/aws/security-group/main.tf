#------------------------------------------------------------------------------
# AWS Security Group Module for OpenShift
#------------------------------------------------------------------------------
# Creates security groups for control plane, worker nodes, and load balancers
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Control Plane Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "control_plane" {
  name        = "${var.name_prefix}-control-plane-sg"
  description = "Security group for OpenShift control plane nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-control-plane-sg"
  })
}

# Control plane ingress rules
resource "aws_security_group_rule" "control_plane_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_api_cidrs
  security_group_id = aws_security_group.control_plane.id
  description       = "Kubernetes API server"
}

resource "aws_security_group_rule" "control_plane_etcd" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.control_plane.id
  description              = "etcd server client API"
}

resource "aws_security_group_rule" "control_plane_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10259
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.control_plane.id
  description              = "Kubelet API"
}

resource "aws_security_group_rule" "control_plane_from_workers" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.control_plane.id
  description              = "All traffic from worker nodes"
}

resource "aws_security_group_rule" "control_plane_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.control_plane.id
  description       = "Allow all outbound traffic"
}

#------------------------------------------------------------------------------
# Worker Node Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "worker" {
  name        = "${var.name_prefix}-worker-sg"
  description = "Security group for OpenShift worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-worker-sg"
  })
}

resource "aws_security_group_rule" "worker_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
  description       = "HTTP traffic"
}

resource "aws_security_group_rule" "worker_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
  description       = "HTTPS traffic"
}

resource "aws_security_group_rule" "worker_nodeport" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.worker.id
  description       = "NodePort services"
}

resource "aws_security_group_rule" "worker_from_control_plane" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.control_plane.id
  security_group_id        = aws_security_group.worker.id
  description              = "All traffic from control plane"
}

resource "aws_security_group_rule" "worker_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.worker.id
  security_group_id        = aws_security_group.worker.id
  description              = "All traffic between workers"
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.worker.id
  description       = "Allow all outbound traffic"
}

#------------------------------------------------------------------------------
# Load Balancer Security Group
#------------------------------------------------------------------------------
resource "aws_security_group" "lb" {
  name        = "${var.name_prefix}-lb-sg"
  description = "Security group for OpenShift load balancers"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-lb-sg"
  })
}

resource "aws_security_group_rule" "lb_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_api_cidrs
  security_group_id = aws_security_group.lb.id
  description       = "Kubernetes API"
}

resource "aws_security_group_rule" "lb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
  description       = "HTTP traffic"
}

resource "aws_security_group_rule" "lb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
  description       = "HTTPS traffic"
}

resource "aws_security_group_rule" "lb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
  description       = "Allow all outbound traffic"
}

# GitHub Actions Enterprise CI/CD Platform - Terraform Configuration
# This configuration deploys the infrastructure for GitHub Actions self-hosted runners

terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "GitHub Actions Enterprise"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Configure GitHub Provider
provider "github" {
  token = var.github_token
  owner = var.github_organization
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC for GitHub Actions runners
resource "aws_vpc" "github_actions" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "github_actions" {
  vpc_id = aws_vpc.github_actions.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public subnets for runners
resource "aws_subnet" "public" {
  count = var.runner_subnet_count

  vpc_id                  = aws_vpc.github_actions.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.github_actions.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.github_actions.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count = var.runner_subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security group for GitHub Actions runners
resource "aws_security_group" "github_runners" {
  name_prefix = "${var.project_name}-runners"
  vpc_id      = aws_vpc.github_actions.id

  # Outbound internet access for GitHub API and package downloads
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP outbound"
  }

  # SSH access from management networks
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.management_cidrs
    description = "SSH access from management networks"
  }

  tags = {
    Name = "${var.project_name}-runners-sg"
  }
}

# IAM role for GitHub Actions runners
resource "aws_iam_role" "github_runner" {
  name = "${var.project_name}-runner-role"

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
}

# IAM policy for runner permissions
resource "aws_iam_role_policy" "github_runner" {
  name = "${var.project_name}-runner-policy"
  role = aws_iam_role.github_runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.artifacts.arn}/*"
      }
    ]
  })
}

# Instance profile for runners
resource "aws_iam_instance_profile" "github_runner" {
  name = "${var.project_name}-runner-profile"
  role = aws_iam_role.github_runner.name
}

# S3 bucket for build artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Auto Scaling Group for GitHub Actions runners
resource "aws_launch_template" "github_runner" {
  name_prefix   = "${var.project_name}-runner"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.runner_instance_type

  vpc_security_group_ids = [aws_security_group.github_runners.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.github_runner.name
  }

  user_data = base64encode(templatefile("${path.module}/scripts/runner-setup.sh", {
    github_org   = var.github_organization
    github_token = var.github_runner_token
    runner_group = var.runner_group
    runner_labels = join(",", var.runner_labels)
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-runner"
      Type = "github-actions-runner"
    }
  }
}

resource "aws_autoscaling_group" "github_runners" {
  name                = "${var.project_name}-runners"
  vpc_zone_identifier = aws_subnet.public[*].id
  target_group_arns   = []
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.runner_min_size
  max_size         = var.runner_max_size
  desired_capacity = var.runner_desired_capacity

  launch_template {
    id      = aws_launch_template.github_runner.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-runner-asg"
    propagate_at_launch = false
  }
}

# CloudWatch Log Group for runner logs
resource "aws_cloudwatch_log_group" "github_runners" {
  name              = "/aws/ec2/github-runners"
  retention_in_days = var.log_retention_days
}

# GitHub repository secrets for AWS integration
resource "github_actions_organization_secret" "aws_region" {
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
  visibility      = "all"
}

resource "github_actions_organization_secret" "aws_role_arn" {
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = aws_iam_role.github_runner.arn
  visibility      = "all"
}

resource "github_actions_organization_secret" "artifacts_bucket" {
  secret_name     = "ARTIFACTS_BUCKET"
  plaintext_value = aws_s3_bucket.artifacts.bucket
  visibility      = "all"
}
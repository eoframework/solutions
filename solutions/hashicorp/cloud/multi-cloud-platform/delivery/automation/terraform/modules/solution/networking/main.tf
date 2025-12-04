#------------------------------------------------------------------------------
# Networking Module - VPC, Subnets, NAT Gateway
#------------------------------------------------------------------------------
# Creates VPC infrastructure for HashiCorp platform components
#------------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.network.vpc_cidr
  enable_dns_hostnames = var.network.enable_dns_hostnames
  enable_dns_support   = var.network.enable_dns_support

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

#------------------------------------------------------------------------------
# Public Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.network.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.network.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name                                           = "${var.name_prefix}-public-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  })
}

#------------------------------------------------------------------------------
# Private Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.network.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.network.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name                                           = "${var.name_prefix}-private-${data.aws_availability_zones.available.names[count.index]}"
    "kubernetes.io/role/internal-elb"              = "1"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "shared"
  })
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

#------------------------------------------------------------------------------
# Elastic IPs for NAT Gateway
#------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count = var.network.enable_nat_gateway ? (var.network.single_nat_gateway ? 1 : length(var.network.public_subnet_cidrs)) : 0

  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index}"
  })
}

#------------------------------------------------------------------------------
# NAT Gateway
#------------------------------------------------------------------------------
resource "aws_nat_gateway" "main" {
  count = var.network.enable_nat_gateway ? (var.network.single_nat_gateway ? 1 : length(var.network.public_subnet_cidrs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-${count.index}"
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
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  count = var.network.enable_nat_gateway ? (var.network.single_nat_gateway ? 1 : length(var.network.private_subnet_cidrs)) : 1

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.network.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[var.network.single_nat_gateway ? 0 : count.index].id
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt-${count.index}"
  })
}

#------------------------------------------------------------------------------
# Route Table Associations
#------------------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count = length(var.network.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.network.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.network.single_nat_gateway ? 0 : count.index].id
}

#------------------------------------------------------------------------------
# DB Subnet Group
#------------------------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-db-subnet-group"
  })
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-database-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.network.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-database-sg"
  })
}

#------------------------------------------------------------------------------
# VPC Flow Logs
#------------------------------------------------------------------------------
resource "aws_flow_log" "main" {
  count = var.network.enable_flow_logs ? 1 : 0

  vpc_id                   = aws_vpc.main.id
  traffic_type             = "ALL"
  iam_role_arn             = aws_iam_role.flow_log[0].arn
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow_log[0].arn
  max_aggregation_interval = 60

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-flow-log"
  })
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.network.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${var.name_prefix}/flow-logs"
  retention_in_days = var.network.flow_log_retention_days

  tags = var.common_tags
}

resource "aws_iam_role" "flow_log" {
  count = var.network.enable_flow_logs ? 1 : 0

  name = "${var.name_prefix}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.network.enable_flow_logs ? 1 : 0

  name = "${var.name_prefix}-flow-log-policy"
  role = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

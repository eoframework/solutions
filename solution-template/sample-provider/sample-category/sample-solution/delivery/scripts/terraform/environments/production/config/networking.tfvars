# Production Environment - Networking Configuration
# Network-specific settings for production deployment

# AWS VPC Configuration
aws_vpc_cidr             = "10.0.0.0/16"
aws_availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
aws_public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
aws_private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
aws_enable_nat_gateway   = true
aws_enable_vpn_gateway   = true

# Azure Virtual Network Configuration
azure_vnet_cidr          = "10.1.0.0/16"
azure_subnet_cidrs = {
  web     = "10.1.1.0/24"
  app     = "10.1.2.0/24"
  data    = "10.1.3.0/24"
  mgmt    = "10.1.4.0/24"
}
azure_enable_ddos_protection = true

# Google Cloud VPC Configuration
gcp_vpc_cidr = "10.2.0.0/16"
gcp_subnets = {
  web = {
    cidr   = "10.2.1.0/24"
    region = "us-central1"
  }
  app = {
    cidr   = "10.2.2.0/24"
    region = "us-central1"
  }
  data = {
    cidr   = "10.2.3.0/24"
    region = "us-central1"
  }
}

# DNS Configuration
enable_private_dns = true
dns_zone_name      = "internal.company.com"
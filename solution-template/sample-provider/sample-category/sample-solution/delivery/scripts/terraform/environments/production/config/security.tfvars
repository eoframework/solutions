# Production Environment - Security Configuration
# Security-specific settings for production deployment

# AWS Security Configuration
aws_security_groups = {
  web = {
    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP from internet"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from internet"
      }
    ]
  }
  app = {
    ingress_rules = [
      {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        source_sg_id    = "web"
        description     = "App port from web tier"
      }
    ]
  }
  data = {
    ingress_rules = [
      {
        from_port       = 3306
        to_port         = 3306
        protocol        = "tcp"
        source_sg_id    = "app"
        description     = "MySQL from app tier"
      }
    ]
  }
}

# KMS Key Configuration
enable_kms_encryption = true
kms_key_rotation      = true

# Azure Security Configuration
azure_network_security_groups = {
  web = {
    rules = [
      {
        name                       = "Allow-HTTP"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-HTTPS"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

# Google Cloud Security Configuration
gcp_firewall_rules = {
  allow-web-traffic = {
    direction = "INGRESS"
    ports     = ["80", "443"]
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["web-server"]
  }
  allow-internal = {
    direction = "INGRESS"
    ports     = ["22", "3389"]
    source_ranges = ["10.2.0.0/16"]
    target_tags = ["internal"]
  }
}

# WAF Configuration
enable_waf = true
waf_rules = {
  sql_injection_protection = true
  xss_protection          = true
  rate_limiting           = true
  geo_blocking           = ["CN", "RU", "KP"]
}

# Certificate Management
enable_auto_ssl = true
ssl_domains     = ["api.company.com", "app.company.com"]
# Production Environment - Compute Configuration
# Compute-specific settings for production deployment

# AWS EC2 Configuration
aws_instances = {
  web = {
    instance_type = "t3.medium"
    ami_id        = "ami-0c02fb55956c7d316" # Amazon Linux 2
    min_size      = 2
    max_size      = 10
    desired_size  = 3
    key_name      = "production-keypair"
    user_data     = "install-web-server.sh"
  }
  app = {
    instance_type = "t3.large"
    ami_id        = "ami-0c02fb55956c7d316"
    min_size      = 2
    max_size      = 8
    desired_size  = 3
    key_name      = "production-keypair"
    user_data     = "install-app-server.sh"
  }
}

# AWS RDS Configuration
aws_rds = {
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.large"
  allocated_storage = 100
  backup_retention_period = 7
  backup_window  = "03:00-04:00"
  maintenance_window = "sun:04:00-sun:05:00"
  multi_az       = true
  encrypted      = true
}

# Azure Virtual Machines Configuration
azure_vms = {
  web = {
    size                = "Standard_D2s_v3"
    admin_username      = "azureadmin"
    disable_password_authentication = true
    os_disk_caching     = "ReadWrite"
    os_disk_storage_account_type = "Premium_LRS"
    source_image_reference = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
  }
}

# Azure SQL Database Configuration
azure_sql = {
  sku_name                     = "S2"
  max_size_gb                  = 250
  auto_pause_delay_in_minutes  = -1
  min_capacity                 = 0.5
  max_capacity                 = 4
  zone_redundant               = true
}

# Google Compute Engine Configuration
gcp_instances = {
  web = {
    machine_type = "e2-standard-2"
    zone         = "us-central1-a"
    image        = "ubuntu-os-cloud/ubuntu-2004-lts"
    disk_size    = 20
    disk_type    = "pd-ssd"
    preemptible  = false
  }
}

# Google Cloud SQL Configuration
gcp_sql = {
  database_version = "MYSQL_8_0"
  tier            = "db-n1-standard-2"
  disk_size       = 100
  disk_type       = "PD_SSD"
  backup_enabled  = true
  binary_log_enabled = true
  ipv4_enabled    = false
}

# Auto Scaling Configuration
enable_auto_scaling = true
scaling_policies = {
  scale_up_threshold   = 70
  scale_down_threshold = 30
  scale_up_cooldown    = 300
  scale_down_cooldown  = 300
}

# Load Balancer Configuration
enable_load_balancer = true
load_balancer_type   = "application" # application, network, or classic
health_check = {
  enabled             = true
  healthy_threshold   = 2
  unhealthy_threshold = 3
  timeout             = 5
  interval            = 30
  path                = "/health"
  port                = 80
}
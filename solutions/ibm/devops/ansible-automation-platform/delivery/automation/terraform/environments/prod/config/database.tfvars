#------------------------------------------------------------------------------
# Database Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:18
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  host = "aap-db.example.com"  # PostgreSQL database hostname
  instance_class = "db.r6g.large"  # RDS instance class
  multi_az = true  # Enable Multi-AZ deployment
  name = "awx"  # PostgreSQL database name
  port = 5432  # PostgreSQL database port
  storage_gb = 100  # Database storage in GB
  username = "awx"  # PostgreSQL service account
}

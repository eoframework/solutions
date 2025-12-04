#------------------------------------------------------------------------------
# Database Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

database = {
  host = "aap-test-db.example.com"  # PostgreSQL database hostname
  instance_class = "db.r6g.medium"  # RDS instance class
  multi_az = false  # Enable Multi-AZ deployment
  name = "awx_test"  # PostgreSQL database name
  port = 5432  # PostgreSQL database port
  storage_gb = 50  # Database storage in GB
  username = "awx"  # PostgreSQL service account
}

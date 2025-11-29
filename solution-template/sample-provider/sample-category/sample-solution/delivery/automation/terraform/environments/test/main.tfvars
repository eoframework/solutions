#------------------------------------------------------------------------------
# Solution Identity & Naming Standards
#------------------------------------------------------------------------------
# These values are used to create consistent resource naming and tagging
# across all infrastructure components.
#
# Naming Convention: {solution_abbr}-{environment}-{resource_type}
# Example: smp-test-vpc, smp-test-alb, smp-test-rds
#------------------------------------------------------------------------------

# Solution identification
solution_name = "sample-solution"      # Full solution name (e.g., "vxrail-hyperconverged")
solution_abbr = "smp"                  # 3-4 char abbreviation for resource names

# Provider/category (for organizational tagging)
provider_name = "sample-provider"      # e.g., "dell", "aws", "microsoft"
category_name = "sample-category"      # e.g., "cloud", "security", "network"

#------------------------------------------------------------------------------
# AWS Deployment Configuration
#------------------------------------------------------------------------------

aws_region     = "us-east-1"
# aws_profile    = "mycompany-test"    # Optional: AWS CLI profile name
# aws_account_id = "123456789012"      # Optional: for cross-account validation

#------------------------------------------------------------------------------
# Ownership & Cost Tracking
#------------------------------------------------------------------------------

cost_center   = "CC-00000"             # Cost center code for billing
owner_email   = "team@example.com"     # Team/owner email for notifications
project_code  = "PRJ-SAMPLE"           # Project tracking code

#------------------------------------------------------------------------------
# Environment Override (Optional)
#------------------------------------------------------------------------------
# Environment is auto-discovered from folder name (prod, test, dr)
# Uncomment to override auto-discovery:
# environment = "test"

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------
# Core project identity and organizational settings.
# These values are typically derived from the delivery configuration.csv
# under the "Project" or "Identity" sections.
#
# Naming Convention: {solution_abbr}-{environment}-{resource_type}
# Example: vxr-prod-vpc, vxr-prod-alb, vxr-prod-rds
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Solution Identity
#------------------------------------------------------------------------------

solution_name = "sample-solution"      # Full solution name (e.g., "vxrail-hyperconverged")
solution_abbr = "smp"                  # 3-4 char abbreviation for resource names

# Organization prefix (for globally unique names like S3 buckets)
# org_prefix  = "acme"                 # e.g., "acme", "mycompany" (required for S3 backend)

# Provider/category (for organizational tagging)
provider_name = "sample-provider"      # e.g., "dell", "aws", "microsoft"
category_name = "sample-category"      # e.g., "cloud", "security", "network"

#------------------------------------------------------------------------------
# AWS Deployment Configuration
#------------------------------------------------------------------------------

aws_region     = "us-east-1"
# aws_profile  = "mycompany-prod"      # Optional: AWS CLI profile name
# aws_account_id = "123456789012"      # Optional: for cross-account validation

#------------------------------------------------------------------------------
# Ownership & Cost Tracking
#------------------------------------------------------------------------------

cost_center   = "CC-00000"             # Cost center code for billing
owner_email   = "team@example.com"     # Team/owner email for notifications
project_code  = "PRJ-SAMPLE"           # Project tracking code

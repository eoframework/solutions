#------------------------------------------------------------------------------
# Project Configuration - DR Environment
#------------------------------------------------------------------------------
# DR environment configuration. Must match production for failover compatibility.
# IMPORTANT: aws_region should be different from production for true DR.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Solution Identity (MUST MATCH PRODUCTION)
#------------------------------------------------------------------------------

solution_name = "sample-solution"      # Same as production
solution_abbr = "smp"                  # Same as production

# Organization prefix (for globally unique names like S3 buckets)
# org_prefix  = "acme"                 # Same as production

# Provider/category (for organizational tagging)
provider_name = "sample-provider"      # Same as production
category_name = "sample-category"      # Same as production

#------------------------------------------------------------------------------
# AWS Deployment Configuration (DIFFERENT REGION FOR DR)
#------------------------------------------------------------------------------

aws_region     = "us-west-2"           # DR: DIFFERENT region from production
# aws_profile  = "mycompany-dr"        # Optional: AWS CLI profile for DR region
# aws_account_id = "123456789012"      # Optional: same or different account

#------------------------------------------------------------------------------
# Ownership & Cost Tracking
#------------------------------------------------------------------------------

cost_center   = "CC-00000"             # Same as production
owner_email   = "team@example.com"     # Same as production
project_code  = "PRJ-SAMPLE"           # Same as production

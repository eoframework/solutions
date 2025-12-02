#------------------------------------------------------------------------------
# Project Configuration - Tags, Naming - DR Environment
#------------------------------------------------------------------------------
# DR uses the same solution identity as production.
# IMPORTANT: aws.region is the DR region, aws.dr_region points back to prod.
#------------------------------------------------------------------------------

aws = {
  region    = "us-west-2"  # DR region (different from production)
  dr_region = "us-east-1"  # Points back to production region
}

ownership = {
  cost_center  = "CC-00000"       # Cost center for billing
  owner_email  = "team@example.com"  # Owner email for notifications
  project_code = "PRJ-SAMPLE"     # Project tracking code
}

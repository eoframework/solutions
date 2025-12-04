#------------------------------------------------------------------------------
# Storage Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  account_tier = "Standard"  # Storage account tier for FSLogix
  enable_large_file_shares = false  # Enable large file share support
  enable_smb_multichannel = false  # Enable SMB multichannel for performance
  # File share quota in GB for FSLogix profiles
  fslogix_share_quota_gb = 1024
  replication_type = "LRS"  # Storage replication type
}

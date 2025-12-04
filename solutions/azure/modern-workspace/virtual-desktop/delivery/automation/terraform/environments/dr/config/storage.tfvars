#------------------------------------------------------------------------------
# Storage Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:40:20
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

storage = {
  account_tier = "Premium"  # Storage account tier for FSLogix
  enable_large_file_shares = true  # Enable large file share support
  enable_smb_multichannel = true  # Enable SMB multichannel for performance
  # File share quota in GB for FSLogix profiles
  fslogix_share_quota_gb = 5120
  replication_type = "ZRS"  # Storage replication type
}

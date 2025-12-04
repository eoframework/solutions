#------------------------------------------------------------------------------
# Authentication Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:04
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

auth = {
  htpasswd_backup_enabled = true  # Create htpasswd backup authentication
  ldap_bind_dn = "CN=ocp-svc;OU=ServiceAccounts;DC=example;DC=com"  # LDAP service account DN
  ldap_enabled = false  # Enable LDAP/AD integration
  ldap_group_search_base = "OU=Groups;DC=example;DC=com"  # LDAP base DN for group searches
  ldap_url = "ldaps://ldap.example.com:636"  # Corporate LDAP/AD server URL
  ldap_user_search_base = "OU=Users;DC=example;DC=com"  # LDAP base DN for user searches
  oauth_timeout_seconds = 86400  # OAuth token timeout in seconds
}

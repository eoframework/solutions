#------------------------------------------------------------------------------
# Authentication Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:19
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

auth = {
  ldap_bind_dn = "CN=aap-svc;OU=ServiceAccounts;DC=example;DC=com"  # LDAP service account DN
  ldap_enabled = false  # Enable LDAP/AD integration
  ldap_group_search_base = "OU=Groups;DC=example;DC=com"  # LDAP group search base DN
  ldap_url = "ldaps://ldap.example.com:636"  # Corporate LDAP/AD server URL
  ldap_user_search_base = "OU=Users;DC=example;DC=com"  # LDAP user search base DN
  session_timeout_seconds = 1800  # Session timeout in seconds
}

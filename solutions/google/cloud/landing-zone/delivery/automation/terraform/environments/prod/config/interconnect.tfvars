#------------------------------------------------------------------------------
# Interconnect Configuration - PROD Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 22:21:02
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

interconnect = {
  bandwidth = "10 Gbps"  # Total interconnect bandwidth
  bgp_asn_gcp = 16550  # Google Cloud BGP ASN
  bgp_asn_onprem = "[CLIENT_ASN]"  # WARNING: Expected integer  # On-premises router BGP ASN
  enabled = true  # Enable dedicated interconnect
  location = "iad-zone1-1"  # Interconnect colocation facility
  type = "DEDICATED"  # Interconnect connection type
  vlan_count = 4  # Number of VLAN attachments for HA
}

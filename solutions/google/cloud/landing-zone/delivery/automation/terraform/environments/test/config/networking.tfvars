#------------------------------------------------------------------------------
# Network Configuration - Test
#------------------------------------------------------------------------------
# Generated from configuration.csv Test column
# Minimal configuration for test environment
#------------------------------------------------------------------------------

network = {
  vpc_name                      = "shared-vpc-test"
  vpc_routing_mode              = "GLOBAL"
  subnet_dev_cidr               = "10.0.1.0/24"
  subnet_staging_cidr           = "10.0.2.0/24"
  subnet_prod_cidr              = "10.0.3.0/24"
  subnet_shared_cidr            = "10.0.10.0/24"
  enable_private_google_access  = true
  enable_flow_logs              = false
  flow_log_sampling             = 0.5
  flow_log_aggregation_interval = "INTERVAL_10_MIN"
}

interconnect = {
  type           = "PARTNER"
  bandwidth      = "1 Gbps"
  location       = "iad-zone1-1"
  vlan_count     = 2
  bgp_asn_gcp    = 16550
  bgp_asn_onprem = "[CLIENT_ASN]"
  enabled        = false
}

nat = {
  enabled          = true
  gateway_count    = 1
  logging_enabled  = false
  min_ports_per_vm = 32
  cloud_router_asn = 64514
}

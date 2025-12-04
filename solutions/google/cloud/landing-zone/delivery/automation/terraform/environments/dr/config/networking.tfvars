#------------------------------------------------------------------------------
# Network Configuration - DR
#------------------------------------------------------------------------------
# Generated from configuration.csv DR column
# Full redundancy for disaster recovery
#------------------------------------------------------------------------------

network = {
  vpc_name                      = "shared-vpc-dr"
  vpc_routing_mode              = "GLOBAL"
  subnet_dev_cidr               = "10.1.1.0/24"
  subnet_staging_cidr           = "10.1.2.0/24"
  subnet_prod_cidr              = "10.1.3.0/24"
  subnet_shared_cidr            = "10.1.10.0/24"
  enable_private_google_access  = true
  enable_flow_logs              = true
  flow_log_sampling             = 1.0
  flow_log_aggregation_interval = "INTERVAL_5_SEC"
}

interconnect = {
  type           = "DEDICATED"
  bandwidth      = "10 Gbps"
  location       = "den-zone1-1"
  vlan_count     = 4
  bgp_asn_gcp    = 16550
  bgp_asn_onprem = "[CLIENT_ASN]"
  enabled        = true
}

nat = {
  enabled          = true
  gateway_count    = 3
  logging_enabled  = true
  min_ports_per_vm = 64
  cloud_router_asn = 64514
}

#------------------------------------------------------------------------------
# Servicemesh Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:07
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

servicemesh = {
  istio_enabled = true  # Enable Istio service mesh
  mtls_mode = "STRICT"  # Istio mutual TLS mode
  tracing_enabled = true  # Enable distributed tracing with Jaeger
  tracing_sampling_rate = 1  # Tracing sampling rate percentage
}

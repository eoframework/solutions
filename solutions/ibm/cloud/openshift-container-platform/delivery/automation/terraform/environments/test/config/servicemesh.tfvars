#------------------------------------------------------------------------------
# Servicemesh Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-04 00:34:06
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

servicemesh = {
  istio_enabled = false  # Enable Istio service mesh
  mtls_mode = "PERMISSIVE"  # Istio mutual TLS mode
  tracing_enabled = true  # Enable distributed tracing with Jaeger
  tracing_sampling_rate = 100  # Tracing sampling rate percentage
}

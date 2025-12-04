#------------------------------------------------------------------------------
# Application Configuration - DR Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:50
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  confidence_threshold = "0.85"  # Minimum confidence for auto-approval
  environment = "disaster-recovery"  # Deployment environment identifier
  log_level = "INFO"  # Logging verbosity level
}

docintel = {
  enable_custom_model = true  # Enable custom model usage
  model_custom = "custom-forms-v1"  # Custom trained model ID
  model_invoice = "prebuilt-invoice"  # Pre-built model for invoices
  model_receipt = "prebuilt-receipt"  # Pre-built model for receipts
  sku = "S0"  # Document Intelligence SKU
}

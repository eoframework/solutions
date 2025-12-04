#------------------------------------------------------------------------------
# Application Configuration - TEST Environment
#------------------------------------------------------------------------------
# Generated from configuration on 2025-12-03 18:26:49
#
# To regenerate: python generate-tfvars.py /path/to/solution
#------------------------------------------------------------------------------

application = {
  confidence_threshold = "0.80"  # Minimum confidence for auto-approval
  environment = "development"  # Deployment environment identifier
  log_level = "DEBUG"  # Logging verbosity level
}

docintel = {
  enable_custom_model = false  # Enable custom model usage
  model_custom = ""  # Custom trained model ID
  model_invoice = "prebuilt-invoice"  # Pre-built model for invoices
  model_receipt = "prebuilt-receipt"  # Pre-built model for receipts
  sku = "S0"  # Document Intelligence SKU
}

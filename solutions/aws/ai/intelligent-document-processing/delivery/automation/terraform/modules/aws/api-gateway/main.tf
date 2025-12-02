#------------------------------------------------------------------------------
# AWS API Gateway REST API Module
#------------------------------------------------------------------------------
# Creates REST API with Lambda integrations for IDP endpoints
#------------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  # Binary media types for document uploads
  binary_media_types = var.binary_media_types

  tags = merge(var.common_tags, {
    Name = var.api_name
  })
}

#------------------------------------------------------------------------------
# API Resources (paths)
#------------------------------------------------------------------------------
resource "aws_api_gateway_resource" "this" {
  for_each = var.resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = each.value.parent_path == "/" ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.this[each.value.parent_path].id
  path_part   = each.value.path_part
}

#------------------------------------------------------------------------------
# API Methods
#------------------------------------------------------------------------------
resource "aws_api_gateway_method" "this" {
  for_each = var.methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.resource_path == "/" ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.this[each.value.resource_path].id
  http_method   = each.value.http_method
  authorization = each.value.authorization
  authorizer_id = each.value.authorization == "COGNITO_USER_POOLS" ? aws_api_gateway_authorizer.cognito[0].id : null

  request_parameters = lookup(each.value, "request_parameters", {})
}

#------------------------------------------------------------------------------
# Lambda Integrations
#------------------------------------------------------------------------------
resource "aws_api_gateway_integration" "this" {
  for_each = var.methods

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.resource_path == "/" ? aws_api_gateway_rest_api.this.root_resource_id : aws_api_gateway_resource.this[each.value.resource_path].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.lambda_invoke_arn

  depends_on = [aws_api_gateway_method.this]
}

#------------------------------------------------------------------------------
# CORS (OPTIONS method)
#------------------------------------------------------------------------------
resource "aws_api_gateway_method" "options" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = aws_api_gateway_method_response.options[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options]
}

#------------------------------------------------------------------------------
# Cognito Authorizer
#------------------------------------------------------------------------------
resource "aws_api_gateway_authorizer" "cognito" {
  count = var.cognito_user_pool_arn != null ? 1 : 0

  name            = "${var.api_name}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.this.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [var.cognito_user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

#------------------------------------------------------------------------------
# Deployment & Stage
#------------------------------------------------------------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_integration.options,
  ]
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  xray_tracing_enabled = var.xray_tracing_enabled

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# CloudWatch Log Group for API Gateway
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/api-gateway/${var.api_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = var.common_tags
}

#------------------------------------------------------------------------------
# Throttling Settings
#------------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
    metrics_enabled        = true
    logging_level          = var.logging_level
    data_trace_enabled     = var.data_trace_enabled
  }
}

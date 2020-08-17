resource "aws_apigatewayv2_api" "chartmuseum_api_gateway" {
  name        = "chartmuseum-${random_string.random_name.result}"
  protocol_type = "HTTP"

}

resource "aws_apigatewayv2_route" "ProxyPath" {
  route_key   = "ANY /{proxy+}"
  api_id = aws_apigatewayv2_api.chartmuseum_api_gateway.id
  target = "integrations/${aws_apigatewayv2_integration.chartmuseum.id}"
}

resource "aws_apigatewayv2_integration" "chartmuseum" {
  api_id           = aws_apigatewayv2_api.chartmuseum_api_gateway.id
  integration_type = "AWS_PROXY"
  description               = "Lambda example"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.chartmuseum.invoke_arn
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.chartmuseum_api_gateway.id
  name   = "$default"
  auto_deploy = true
}

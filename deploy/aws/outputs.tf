output "stage_id" {
  value = aws_apigatewayv2_stage.default.id
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.chartmuseum_api_gateway.id
}
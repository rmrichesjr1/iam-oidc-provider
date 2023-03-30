# Token Endpoint

resource "aws_api_gateway_resource" "token_resource" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "token"
}

resource "aws_api_gateway_method" "token_method" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.token_resource.id
  http_method      = "POST"
  authorization    = "AWS_IAM"
  api_key_required = false
}

resource "aws_api_gateway_integration" "token_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.token_method.resource_id
  http_method = aws_api_gateway_method.token_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.token_lambda.invoke_arn
}

# OpenID Configuration Endpoint

resource "aws_api_gateway_resource" "well_known_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  parent_id   = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part   = ".well-known"
}

resource "aws_api_gateway_resource" "openid_config_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  parent_id   = "${aws_api_gateway_resource.well_known_resource.id}"
  path_part   = "openid-configuration"
}

resource "aws_api_gateway_method" "openid_config_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  resource_id   = "${aws_api_gateway_resource.openid_config_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "openid_config_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_method.openid_config_method.resource_id}"
  http_method = "${aws_api_gateway_method.openid_config_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.oidc_lambda.invoke_arn}"
}

# JWK Endpoint

resource "aws_api_gateway_resource" "keys_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  parent_id   = "${aws_api_gateway_rest_api.this.root_resource_id}"
  path_part   = "keys"
}

resource "aws_api_gateway_method" "keys_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  resource_id   = "${aws_api_gateway_resource.keys_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "keys_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
  resource_id = "${aws_api_gateway_method.keys_method.resource_id}"
  http_method = "${aws_api_gateway_method.keys_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.oidc_lambda.invoke_arn}"
}
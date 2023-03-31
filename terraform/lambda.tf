resource "aws_lambda_function" "token_lambda" {
  function_name = "${var.service_name}-create-token"
  handler = "token_lambda.handler"
  role = aws_iam_role.lambda_role.arn

  image_uri = "ghcr.io/martian-cloud/iam-oidc-provider/iam-oidc-provider-token:latest"
  package_type = "Image"

  environment {
    variables = {
      KMS_KEY_ARN     = aws_kms_key.signing_key.arn,
      ISSUER_URL      = local.issuer,
      VALID_AUDIENCES = jsonencode(var.valid_audiences)
    }
  }
}

resource "aws_lambda_permission" "apigw_token_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.token_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/POST/token"
}

resource "aws_lambda_function" "oidc_lambda" {
  function_name = "${var.service_name}-discovery"
  handler = "oidc_lambda.handler"
  role = aws_iam_role.lambda_role.arn

  image_uri = "ghcr.io/martian-cloud/iam-oidc-provider/iam-oidc-provider-oidc:latest"
  package_type = "Image"

  environment {
    variables = {
      KMS_KEY_ARN = aws_kms_key.signing_key.arn
      ISSUER_URL  = local.issuer
    }
  }
}

resource "aws_lambda_permission" "apigw_oidc_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.oidc_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/GET/*"
}

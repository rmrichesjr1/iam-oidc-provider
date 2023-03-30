resource "aws_lambda_function" "token_lambda" {
  function_name = "${var.service_name}-create-token"
  filename = "${path.module}/lambda_package.zip"
  handler = "token_lambda.handler"
  runtime = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda_package.zip")
  role = aws_iam_role.lambda_role.arn

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
  filename = "${path.module}/lambda_package.zip"
  handler = "oidc_lambda.handler"
  runtime = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/lambda_package.zip")
  role = aws_iam_role.lambda_role.arn

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

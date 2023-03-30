resource "aws_api_gateway_domain_name" "this" {
  domain_name              = local.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.this.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.this.id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name  = aws_api_gateway_stage.this.stage_name
}

data "aws_iam_policy_document" "api" {
  statement {
    sid = "Enable access to public endpoint"
    actions = [
      "execute-api:Invoke"
    ]
    resources = [
      "execute-api:/*/GET/.well-known/openid-configuration",
      "execute-api:/*/GET/keys"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid           = try(statement.value.sid, null)
      effect        = try(statement.value.effect, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.service_name
  description = "IAM OIDC Provider"
  policy      = data.aws_iam_policy_document.api.json
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.openid_config_lambda,
    aws_api_gateway_integration.keys_lambda,
    aws_api_gateway_integration.token_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      "${md5(file("${path.module}/apigw.tf"))}",
      "${md5(file("${path.module}/api_endpoints.tf"))}",
      "${md5(data.aws_iam_policy_document.api.json)}"
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "v1"
}

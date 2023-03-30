data "aws_iam_policy_document" "kms_key" {
  statement {
    sid = "Enable Admin Role Access"
    actions = [
      "kms:*"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [var.kms_key_admin_role_arn]
    }
  }

  statement {
    sid     = "Allow lambda to use the key"
    actions = ["kms:DescribeKey", "kms:GetPublicKey", "kms:Sign", "kms:Verify"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_role.arn]
    }
  }
}

resource "aws_kms_key" "signing_key" {
  description              = "Assymetric KMS key used for signing JWTs"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_2048"
  deletion_window_in_days  = 7
  multi_region             = false
  policy                   = data.aws_iam_policy_document.kms_key.json
}

resource "aws_kms_alias" "signing_key_alias" {
  name          = "alias/${var.service_name}-signing-key"
  target_key_id = aws_kms_key.signing_key.key_id
}

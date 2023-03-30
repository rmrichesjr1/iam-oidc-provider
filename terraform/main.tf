terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

locals {
  domain_name = "${var.service_name}.${var.parent_domain_name}"
  issuer = "https://${local.domain_name}"
}

output "issuer" {
  value = local.issuer
}

output "token_endpoint" {
  value = "${local.issuer}/token"
}

output "keys_endpoint" {
  value = "${local.issuer}/keys"
}

output "openid_configuration_endpoint" {
  value = "${local.issuer}/.well-known/openid-configuration"
}
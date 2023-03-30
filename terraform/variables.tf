variable "parent_domain_name" {
  description = "Parent domain name, this domain is used to lookup the hosted zone"
  type        = string
}

variable "kms_key_admin_role_arn" {
  description = "Admin role ARN used for kms key management"
  type        = string
}

variable "valid_audiences" {
  type        = list(string)
  description = "A list of valid audiences"
}

variable "aws_region" {
  description = "AWS Region to deploy example API Gateway REST API"
  type        = string
  default     = "us-east-1"
}

variable "policy_statements" {
  type = list(object({
    sid            = optional(string)
    effect         = optional(string)
    actions        = optional(list(string), [])
    not_actions    = optional(list(string), [])
    resources      = optional(list(string), [])
    not_resources  = optional(list(string), [])
    principals     = optional(list(object({ type = string, identifiers = list(string) })), [])
    not_principals = optional(list(object({ type = string, identifiers = list(string) })), [])
    conditions     = optional(list(object({ test = string, variable = string, values = list(string) })), [])
  }))
  description = "A list of policy statements to build the policy document from, by default only identities from the account it's deployed to have access."
  default     = []
}

variable "iam_permission_boundary" {
  type        = string
  description = "IAM permission boundary for IAM resources"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Default tags that will be applied to all resources"
  default     = {}
}

variable "service_name" {
  description = "The service name"
  type        = string
  default     = "iam-oidc-provider"
}

module "kms" {
  source = "../../modules"

  create        = var.create_kms
  master_prefix = var.master_prefix
  create_kms    = var.create_kms

  kms_keys = var.create_kms ? {
    qm_encryption = {
      description             = var.kms_config.key.description
      deletion_window_in_days = var.kms_config.key.deletion_window
      enable_key_rotation     = var.kms_config.key.enable_rotation
      alias                   = format("alias/%s", var.kms_config.key.alias)

      policy = {
        Version = var.kms_config.policy.version
        Statement = [
          {
            Sid    = var.kms_config.policy.iam_sid
            Effect = var.kms_config.policy.effect_allow
            Principal = {
              AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action   = var.kms_config.policy.admin_actions
            Resource = var.kms_config.policy.all_resources
          },
          {
            Sid    = var.kms_config.policy.eventbridge_sid
            Effect = var.kms_config.policy.effect_allow
            Principal = {
              Service = var.kms_config.policy.eventbridge_principal
            }
            Action   = var.kms_config.policy.eventbridge_actions
            Resource = var.kms_config.policy.all_resources
          }
        ]
      }

      tags = merge(
        {
          Name = var.kms_config.key.alias
        },
        local.merged_tags
      )
    }
  } : {}
}

locals {
  kms_arn = var.create_kms ? module.kms.kms_key_arns["qm_encryption"] : var.existing_kms_arn
}

#---------------------------------------------------------------
# KMS Variables
#---------------------------------------------------------------
variable "create_kms" {
  description = "Whether to create KMS key"
  type        = bool
  default     = true
}

variable "existing_kms_arn" {
  description = "Existing KMS key ARN to use if create_kms is false"
  type        = string
  default     = null
}

variable "kms_config" {
  description = "Configuration for KMS resources"
  type = object({
    key = object({
      description     = string
      deletion_window = number
      enable_rotation = bool
      alias           = string
    })
    policy = object({
      version               = string
      effect_allow          = string
      all_resources         = string
      iam_sid               = string
      eventbridge_sid       = string
      eventbridge_principal = string
      admin_actions         = string
      eventbridge_actions   = list(string)
    })
  })
  default = {
    key = {
      description     = "CMK for AWS resources provisioned by Quota Monitor in this account"
      deletion_window = 7
      enable_rotation = true
      alias           = "alias/CMK-KMS-TA"
    }
    policy = {
      version               = "2012-10-17"
      effect_allow          = "Allow"
      all_resources         = "*"
      iam_sid               = "Enable IAM User Permissions"
      eventbridge_sid       = "Allow EventBridge Service"
      eventbridge_principal = "events.amazonaws.com"
      admin_actions         = "kms:*"
      eventbridge_actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ]
    }
  }
}
# module "kms" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"
#   create_kms    = true
#   kms_keys = {
#     qm_encryption = {
#       description             = "CMK for AWS resources provisioned by Quota Monitor in this account"
#       deletion_window_in_days = 7
#       enable_key_rotation     = true
#       alias                   = "alias/CMK-KMS-Hub"

#       policy = {
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Sid    = "Enable IAM User Permissions"
#             Effect = "Allow"
#             Principal = {
#               AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
#             }
#             Action   = "kms:*"
#             Resource = "*"
#           },
#           {
#             Sid    = "Allow EventBridge Service"
#             Effect = "Allow"
#             Principal = {
#               Service = "events.amazonaws.com"
#             }
#             Action = [
#               "kms:Decrypt",
#               "kms:Encrypt", 
#               "kms:ReEncrypt*",
#               "kms:GenerateDataKey*"
#             ]
#             Resource = "*"
#           }
#         ]
#       }

#       tags = {
#         Name = "QuotaMonitor-KMS"
#       }
#     }
#   }
# }

module "kms" {
  source = "../modules"

  create        = true
  master_prefix = "qm"
  create_kms    = true
  kms_keys = {
    qm_encryption = {
      description             = var.kms_description
      deletion_window_in_days = var.kms_deletion_window
      enable_key_rotation     = var.kms_enable_rotation
      alias                   = var.kms_alias

      policy = {
        Version = var.policy_version
        Statement = [
          {
            Sid    = var.kms_iam_sid
            Effect = var.effect_allow
            Principal = {
              AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action   = var.kms_admin_actions
            Resource = var.all_resources
          },
          {
            Sid    = var.kms_eventbridge_sid
            Effect = var.effect_allow
            Principal = {
              Service = var.eventbridge_service_principal
            }
            Action   = var.kms_eventbridge_actions
            Resource = var.all_resources
          }
        ]
      }

      tags = {
        Name = var.kms_tag_name
      }
    }
  }
}

variable "kms_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "CMK for AWS resources provisioned by Quota Monitor in this account"
}

variable "kms_deletion_window" {
  description = "Duration in days before the key is deleted after being scheduled for deletion"
  type        = number
  default     = 7
}

variable "kms_enable_rotation" {
  description = "Whether key rotation is enabled"
  type        = bool
  default     = true
}

variable "kms_alias" {
  description = "Alias for the KMS key"
  type        = string
  default     = "alias/CMK-KMS-Hub"
}

variable "kms_iam_sid" {
  description = "Statement ID for IAM user permissions"
  type        = string
  default     = "Enable IAM User Permissions"
}

variable "kms_eventbridge_sid" {
  description = "Statement ID for EventBridge service permissions"
  type        = string
  default     = "Allow EventBridge Service"
}

variable "eventbridge_service_principal" {
  description = "EventBridge service principal"
  type        = string
  default     = "events.amazonaws.com"
}

variable "kms_admin_actions" {
  description = "KMS actions for admin permissions"
  type        = string
  default     = "kms:*"
}

variable "kms_eventbridge_actions" {
  description = "KMS actions for EventBridge service"
  type        = list(string)
  default = [
    "kms:Decrypt",
    "kms:Encrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*"
  ]
}

variable "kms_tag_name" {
  description = "Name tag for KMS key"
  type        = string
  default     = "QuotaMonitor-KMS"
}
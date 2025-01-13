# module "sqs" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   create_sqs = true
#   sqs_queue = {
#     slack_notifier_dlq = {
#       name              = "SlackNotifier-Lambda-DLQ"
#       kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

#       policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Effect = "Deny"
#             Principal = {
#               AWS = "*"
#             }
#             Action   = "sqs:*"
#             Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-SlackNotifier-Lambda-DLQ"
#             Condition = {
#               Bool = {
#                 "aws:SecureTransport" = "false"
#               }
#             }
#           }
#         ]
#       })

#       tags = {
#         Name = "QuotaMonitor-SlackNotifier-DLQ"
#       }
#     }

#     sns_publisher_dlq = {
#       name              = "SNSPublisher-Lambda-DLQ"
#       kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

#       policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Effect = "Deny"
#             Principal = {
#               AWS = "*"
#             }
#             Action   = "sqs:*"
#             Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-SNSPublisher-Lambda-DLQ"
#             Condition = {
#               Bool = {
#                 "aws:SecureTransport" = "false"
#               }
#             }
#           }
#         ]
#       })

#       tags = {
#         Name = "QuotaMonitor-SNSPublisher-DLQ"
#       }
#     }
#     summarizer_event_queue = {
#       name               = "Summarizer-EventQueue"
#       visibility_timeout = 60
#       kms_master_key_id  = module.kms.kms_key_arns["qm_encryption"]

#       policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Effect = "Deny"
#             Principal = {
#               AWS = "*"
#             }
#             Action   = "sqs:*"
#             Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-Summarizer-EventQueue"
#             Condition = {
#               Bool = {
#                 "aws:SecureTransport" = "false"
#               }
#             }
#           },
#           {
#             Effect = "Allow"
#             Principal = {
#               Service = "events.amazonaws.com"
#             }
#             Action = [
#               "sqs:SendMessage",
#               "sqs:GetQueueAttributes",
#               "sqs:GetQueueUrl"
#             ]
#             Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-Summarizer-EventQueue"
#           }
#         ]
#       })

#       tags = {
#         Name = "QuotaMonitor-Summarizer-EventQueue"
#       }
#     }

#     reporter_dlq = {
#       name              = "Reporter-Lambda-DLQ"
#       kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

#       policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Effect = "Deny"
#             Principal = {
#               AWS = "*"
#             }
#             Action   = "sqs:*"
#             Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-Reporter-Lambda-DLQ"
#             Condition = {
#               Bool = {
#                 "aws:SecureTransport" = "false"
#               }
#             }
#           }
#         ]
#       })

#       tags = {
#         Name = "QuotaMonitor-Reporter-DLQ"
#       }
#     }
#     deployment_manager_dlq = {
#       name              = "DeploymentManager-Lambda-DLQ"
#       kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

#       policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Effect = "Deny"
#             Principal = {
#               AWS = "*"
#             }
#             Action   = "sqs:*"
#             Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-DeploymentManager-Lambda-DLQ"
#             Condition = {
#               Bool = {
#                 "aws:SecureTransport" = "false"
#               }
#             }
#           }
#         ]
#       })

#       tags = {
#         Name = "QuotaMonitor-DeploymentManager-DLQ"
#       }
#     }
#   }
# }

module "sqs" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_sqs = true
  sqs_queue = {
    slack_notifier_dlq = {
      name              = var.slack_notifier_dlq_name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = var.policy_version
        Statement = [
          {
            Effect = var.effect_deny
            Principal = {
              AWS = var.all_principals
            }
            Action   = var.sqs_all_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.slack_notifier_dlq_name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = var.secure_transport_false
              }
            }
          }
        ]
      })

      tags = {
        Name = var.slack_notifier_dlq_tag_name
      }
    }

    sns_publisher_dlq = {
      name              = var.sns_publisher_dlq_name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = var.policy_version
        Statement = [
          {
            Effect = var.effect_deny
            Principal = {
              AWS = var.all_principals
            }
            Action   = var.sqs_all_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sns_publisher_dlq_name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = var.secure_transport_false
              }
            }
          }
        ]
      })

      tags = {
        Name = var.sns_publisher_dlq_tag_name
      }
    }

    summarizer_event_queue = {
      name               = var.summarizer_queue_name
      visibility_timeout = var.summarizer_visibility_timeout
      kms_master_key_id  = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = var.policy_version
        Statement = [
          {
            Effect = var.effect_deny
            Principal = {
              AWS = var.all_principals
            }
            Action   = var.sqs_all_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.summarizer_queue_name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = var.secure_transport_false
              }
            }
          },
          {
            Effect = var.effect_allow
            Principal = {
              Service = var.eventbridge_service_principal
            }
            Action   = var.sqs_eventbridge_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.summarizer_queue_name}"
          }
        ]
      })

      tags = {
        Name = var.summarizer_queue_tag_name
      }
    }

    reporter_dlq = {
      name              = var.reporter_dlq_name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = var.policy_version
        Statement = [
          {
            Effect = var.effect_deny
            Principal = {
              AWS = var.all_principals
            }
            Action   = var.sqs_all_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.reporter_dlq_name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = var.secure_transport_false
              }
            }
          }
        ]
      })

      tags = {
        Name = var.reporter_dlq_tag_name
      }
    }

    deployment_manager_dlq = {
      name              = var.deployment_manager_dlq_name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = var.policy_version
        Statement = [
          {
            Effect = var.effect_deny
            Principal = {
              AWS = var.all_principals
            }
            Action   = var.sqs_all_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.deployment_manager_dlq_name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = var.secure_transport_false
              }
            }
          }
        ]
      })

      tags = {
        Name = var.deployment_manager_dlq_tag_name
      }
    }
  }
}

# Common Variables
variable "effect_deny" {
  description = "Deny effect for IAM policies"
  type        = string
  default     = "Deny"
}

variable "all_principals" {
  description = "All AWS principals"
  type        = string
  default     = "*"
}

variable "sqs_all_actions" {
  description = "All SQS actions"
  type        = string
  default     = "sqs:*"
}

variable "secure_transport_false" {
  description = "Value for secure transport condition"
  type        = string
  default     = "false"
}

variable "sqs_eventbridge_actions" {
  description = "SQS actions for EventBridge"
  type        = list(string)
  default     = ["sqs:SendMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"]
}

# Queue Names
variable "slack_notifier_dlq_name" {
  description = "Name of the Slack Notifier DLQ"
  type        = string
  default     = "SlackNotifier-Lambda-DLQ"
}

variable "sns_publisher_dlq_name" {
  description = "Name of the SNS Publisher DLQ"
  type        = string
  default     = "SNSPublisher-Lambda-DLQ"
}

variable "summarizer_queue_name" {
  description = "Name of the Summarizer Event Queue"
  type        = string
  default     = "Summarizer-EventQueue"
}

variable "reporter_dlq_name" {
  description = "Name of the Reporter DLQ"
  type        = string
  default     = "Reporter-Lambda-DLQ"
}

variable "deployment_manager_dlq_name" {
  description = "Name of the Deployment Manager DLQ"
  type        = string
  default     = "DeploymentManager-Lambda-DLQ"
}

# Queue Tag Names
variable "slack_notifier_dlq_tag_name" {
  description = "Tag name for Slack Notifier DLQ"
  type        = string
  default     = "QuotaMonitor-SlackNotifier-DLQ"
}

variable "sns_publisher_dlq_tag_name" {
  description = "Tag name for SNS Publisher DLQ"
  type        = string
  default     = "QuotaMonitor-SNSPublisher-DLQ"
}

variable "summarizer_queue_tag_name" {
  description = "Tag name for Summarizer Event Queue"
  type        = string
  default     = "QuotaMonitor-Summarizer-EventQueue"
}

variable "reporter_dlq_tag_name" {
  description = "Tag name for Reporter DLQ"
  type        = string
  default     = "QuotaMonitor-Reporter-DLQ"
}

variable "deployment_manager_dlq_tag_name" {
  description = "Tag name for Deployment Manager DLQ"
  type        = string
  default     = "QuotaMonitor-DeploymentManager-DLQ"
}

# Other Variables
variable "summarizer_visibility_timeout" {
  description = "Visibility timeout for Summarizer Event Queue"
  type        = number
  default     = 60
}
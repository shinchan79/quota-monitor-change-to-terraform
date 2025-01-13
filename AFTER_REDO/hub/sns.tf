# module "sns" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   create_sns = true
#   sns_topics = {
#     publisher = {
#       name              = "SNSPublisher-Topic"
#       kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]
#       tags = {
#         Name = "QuotaMonitor-Publisher-Topic"
#       }
#       subscriptions = {
#         email = {
#           protocol = "email"
#           endpoint = var.sns_email
#         }
#       }
#     }
#   }
# }

module "sns" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_sns = true
  sns_topics = {
    publisher = {
      name              = var.sns_topic_name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]
      tags = {
        Name = var.sns_topic_tag_name
      }
      subscriptions = {
        email = {
          protocol = var.sns_subscription_protocol
          endpoint = var.sns_email
        }
      }
    }
  }
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "SNSPublisher-Topic"
}

variable "sns_topic_tag_name" {
  description = "Name tag for the SNS topic"
  type        = string
  default     = "QuotaMonitor-Publisher-Topic"
}

variable "sns_subscription_protocol" {
  description = "Protocol for SNS topic subscription"
  type        = string
  default     = "email"
}

# Note: sns_email variable should already be defined elsewhere since it's used in locals.tf
# variable "sns_email" {
#   description = "Email endpoint for SNS topic subscription"
#   type        = string
#   default     = ""
# }
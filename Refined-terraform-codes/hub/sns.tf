module "sns" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_sns = true
  sns_topics = {
    publisher = {
      name              = var.sns_config["publisher"].name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]
      tags              = var.tags
      subscriptions = {
        for idx, email in var.sns_emails : "email_${idx}" => {
          protocol = var.sns_config["publisher"].protocol
          endpoint = email
        }
      }
    }
  }
}

variable "sns_config" {
  description = "Configuration for SNS topics"
  type = map(object({
    name     = string
    protocol = string
  }))
  default = {
    publisher = {
      name     = "SNSPublisher-Topic"
      protocol = "email"
    }
  }
}

variable "sns_emails" {
  description = "List of email endpoints for SNS topic subscription"
  type        = list(string)
  default     = []
}
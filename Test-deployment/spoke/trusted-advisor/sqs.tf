#---------------------------------------------------------------
# SQS Queue Configuration
#---------------------------------------------------------------
variable "sqs_queues_config" {
  description = "Configuration for SQS queues"
  type = map(object({
    name               = string
    visibility_timeout = optional(number, 30)
    delay_seconds      = optional(number, 0)
    max_message_size   = optional(number, 262144)
    retention_seconds  = optional(number, 345600)
    actions            = string
    tags               = optional(map(string), {})
  }))
  default = {
    qmta_refresher_dlq = {
      name    = "TARefresher-Lambda-DLQ"
      actions = "sqs:*"
    }
  }
}

#---------------------------------------------------------------
# SQS Module
#---------------------------------------------------------------
module "sqs" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  create_sqs = true
  sqs_queue = {
    qmta_refresher_dlq = {
      name                      = var.sqs_queues_config["qmta_refresher_dlq"].name
      delay_seconds             = var.sqs_queues_config["qmta_refresher_dlq"].delay_seconds
      max_message_size          = var.sqs_queues_config["qmta_refresher_dlq"].max_message_size
      message_retention_seconds = var.sqs_queues_config["qmta_refresher_dlq"].retention_seconds
      visibility_timeout        = var.sqs_queues_config["qmta_refresher_dlq"].visibility_timeout
      kms_master_key_id         = local.kms_arn

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["qmta_refresher_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["qmta_refresher_dlq"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = merge(
        var.sqs_queues_config["qmta_refresher_dlq"].tags,
        local.merged_tags
      )
    }
  }

  depends_on = [
    module.kms
  ]
}
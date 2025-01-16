module "sqs" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  create_sqs = true
  sqs_queue = {
    sns_publisher_dlq = {
      name              = var.sqs_queues_config["sns_publisher_dlq"].name
      kms_master_key_id = var.kms_key_arn

      # Additional configurations from CloudFormation template
      message_retention_seconds   = 345600 # 4 days
      visibility_timeout_seconds  = 30
      receive_wait_time_seconds   = 0
      max_message_size            = 262144
      delay_seconds               = 0
      fifo_queue                  = false
      content_based_deduplication = false
      sqs_managed_sse_enabled     = true

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["sns_publisher_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["sns_publisher_dlq"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = local.merged_tags
    }

    qmcw_poller_dlq = {
      name              = var.sqs_queues_config["qmcw_poller_dlq"].name
      kms_master_key_id = var.kms_key_arn

      # Additional configurations from CloudFormation template
      message_retention_seconds   = 345600 # 4 days
      visibility_timeout_seconds  = 30
      receive_wait_time_seconds   = 0
      max_message_size            = 262144
      delay_seconds               = 0
      fifo_queue                  = false
      content_based_deduplication = false
      sqs_managed_sse_enabled     = true

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["qmcw_poller_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["qmcw_poller_dlq"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = local.merged_tags
    }
  }
}
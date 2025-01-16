module "sqs" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  create_sqs = true
  sqs_queue = {
    # slack_notifier_dlq = {
    #   name              = var.sqs_queues_config["slack_notifier_dlq"].name
    #   kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

    #   policy = jsonencode({
    #     Version = "2012-10-17"
    #     Statement = [
    #       {
    #         Effect = "Deny"
    #         Principal = {
    #           AWS = "*"
    #         }
    #         Action   = var.sqs_queues_config["slack_notifier_dlq"].actions
    #         Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["slack_notifier_dlq"].name}"
    #         Condition = {
    #           Bool = {
    #             "aws:SecureTransport" = "false"
    #           }
    #         }
    #       }
    #     ]
    #   })

    #   tags = local.merged_tags
    # }

    sns_publisher_dlq = {
      name              = var.sqs_queues_config["sns_publisher_dlq"].name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

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

    summarizer_event_queue = {
      name               = var.sqs_queues_config["summarizer_event_queue"].name
      visibility_timeout = var.sqs_queues_config["summarizer_event_queue"].visibility_timeout
      kms_master_key_id  = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["summarizer_event_queue"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["summarizer_event_queue"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          },
          {
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
            Action   = var.sqs_queues_config["summarizer_event_queue"].eventbridge_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["summarizer_event_queue"].name}"
          }
        ]
      })

      tags = local.merged_tags
    }

    reporter_dlq = {
      name              = var.sqs_queues_config["reporter_dlq"].name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["reporter_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["reporter_dlq"].name}"
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

    # deployment_manager_dlq = {
    #   name              = var.sqs_queues_config["deployment_manager_dlq"].name
    #   kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

    #   policy = jsonencode({
    #     Version = "2012-10-17"
    #     Statement = [
    #       {
    #         Effect = "Deny"
    #         Principal = {
    #           AWS = "*"
    #         }
    #         Action   = var.sqs_queues_config["deployment_manager_dlq"].actions
    #         Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["deployment_manager_dlq"].name}"
    #         Condition = {
    #           Bool = {
    #             "aws:SecureTransport" = "false"
    #           }
    #         }
    #       }
    #     ]
    #   })

    #   tags = local.merged_tags
    # }
  }
}

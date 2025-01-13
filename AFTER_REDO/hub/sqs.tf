module "sqs" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_sqs = true
  sqs_queue = {
    slack_notifier_dlq = {
      name              = "SlackNotifier-Lambda-DLQ"
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*"
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-SlackNotifier-Lambda-DLQ"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = {
        Name = "QuotaMonitor-SlackNotifier-DLQ"
      }
    }

    sns_publisher_dlq = {
      name              = "SNSPublisher-Lambda-DLQ"
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*"
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-SNSPublisher-Lambda-DLQ"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = {
        Name = "QuotaMonitor-SNSPublisher-DLQ"
      }
    }
    summarizer_event_queue = {
      name               = "Summarizer-EventQueue"
      visibility_timeout = 60
      kms_master_key_id  = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*"
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-Summarizer-EventQueue"
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
            Action = [
              "sqs:SendMessage",
              "sqs:GetQueueAttributes",
              "sqs:GetQueueUrl"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-Summarizer-EventQueue"
          }
        ]
      })

      tags = {
        Name = "QuotaMonitor-Summarizer-EventQueue"
      }
    }

    reporter_dlq = {
      name              = "Reporter-Lambda-DLQ"
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*"
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-Reporter-Lambda-DLQ"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = {
        Name = "QuotaMonitor-Reporter-DLQ"
      }
    }
    deployment_manager_dlq = {
      name              = "DeploymentManager-Lambda-DLQ"
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*"
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-DeploymentManager-Lambda-DLQ"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = {
        Name = "QuotaMonitor-DeploymentManager-DLQ"
      }
    }
  }
}
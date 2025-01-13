module "sqs" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_sqs = true
  sqs_queue = {
    ################# SNS Spoke
    sns_publisher_dlq = {
      name              = "SNSPublisher-Lambda-DLQ"
      kkms_master_key_id = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sqs"

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

    ################# QM Spoke
    qmcw_poller_dlq = {
      name              = "QMCWPoller-Lambda-DLQ"
      kms_master_key_id = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sqs"

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*" 
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-QMCWPoller-Lambda-DLQ"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = {
        Name = "QMCWPoller-Lambda-DLQ"
      }
    }

    ################# TA Spoke
    qmta_refresher_dlq = {
      name              = "QMTARefresher-Lambda-DLQ"
      kms_master_key_id = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sqs"

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = "sqs:*"
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-QMTARefresher-Lambda-DLQ"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = {
        Name = "QuotaMonitor-QMTARefresher-DLQ"
      }
    }
  }
}
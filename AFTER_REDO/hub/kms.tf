module "kms" {
  source = "../modules"

  create        = true
  master_prefix = "qm"
  create_kms    = true
  kms_keys = {
    qm_encryption = {
      description             = "CMK for AWS resources provisioned by Quota Monitor in this account"
      deletion_window_in_days = 7
      enable_key_rotation     = true
      alias                   = "alias/CMK-KMS-Hub"

      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "Enable IAM User Permissions"
            Effect = "Allow"
            Principal = {
              AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action   = "kms:*"
            Resource = "*"
          },
          {
            Sid    = "Allow EventBridge Service"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
            Action = [
              "kms:Decrypt",
              "kms:Encrypt", 
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*"
            ]
            Resource = "*"
          }
        ]
      }

      tags = {
        Name = "QuotaMonitor-KMS"
      }
    }
  }
}
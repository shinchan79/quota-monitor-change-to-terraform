module "kms" {
  source = "../modules"

  create        = var.create_kms && local.create_hub_resources
  master_prefix = var.master_prefix
  create_kms    = var.create_kms

  kms_keys = var.create_kms ? {
    qm_encryption = {
      description             = var.kms_config.key.description
      deletion_window_in_days = var.kms_config.key.deletion_window
      enable_key_rotation     = var.kms_config.key.enable_rotation
      alias                   = format("alias/%s", trimprefix(var.kms_config.key.alias, "alias/"))

      policy = {
        Version = var.kms_config.policy.version
        Statement = [
          {
            Sid    = var.kms_config.policy.iam_sid
            Effect = var.kms_config.policy.effect_allow
            Principal = {
              AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action   = var.kms_config.policy.admin_actions
            Resource = var.kms_config.policy.all_resources
          },
          {
            Sid    = var.kms_config.policy.eventbridge_sid
            Effect = var.kms_config.policy.effect_allow
            Principal = {
              Service = var.kms_config.policy.eventbridge_principal
            }
            Action   = var.kms_config.policy.eventbridge_actions
            Resource = var.kms_config.policy.all_resources
          }
        ]
      }

      tags = merge(
        {
          Name = var.kms_config.key.alias
        },
        local.merged_tags
      )
    }
  } : {}
}

    # "KMSHubQMEncryptionKeyA80F8C05": {
    #   "Type": "AWS::KMS::Key",
    #   "Properties": {
    #     "Description": "CMK for AWS resources provisioned by Quota Monitor in this account",
    #     "EnableKeyRotation": true,
    #     "Enabled": true,
    #     "KeyPolicy": {
    #       "Statement": [
    #         {
    #           "Action": "kms:*",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "AWS": {
    #               "Fn::Join": [
    #                 "",
    #                 [
    #                   "arn:",
    #                   {
    #                     "Ref": "AWS::Partition"
    #                   },
    #                   ":iam::",
    #                   {
    #                     "Ref": "AWS::AccountId"
    #                   },
    #                   ":root"
    #                 ]
    #               ]
    #             }
    #           },
    #           "Resource": "*"
    #         },
    #         {
    #           "Action": [
    #             "kms:Decrypt",
    #             "kms:Encrypt",
    #             "kms:ReEncrypt*",
    #             "kms:GenerateDataKey*"
    #           ],
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "events.amazonaws.com"
    #           },
    #           "Resource": "*"
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     }
    #   },
    #   "UpdateReplacePolicy": "Retain",
    #   "DeletionPolicy": "Retain",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/KMS-Hub/QM-EncryptionKey/Resource"
    #   }
    # },
    # "KMSHubQMEncryptionKeyAlias6C248240": {
    #   "Type": "AWS::KMS::Alias",
    #   "Properties": {
    #     "AliasName": "alias/CMK-KMS-Hub",
    #     "TargetKeyId": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/KMS-Hub/QM-EncryptionKey/Alias/Resource"
    #   }
    # },
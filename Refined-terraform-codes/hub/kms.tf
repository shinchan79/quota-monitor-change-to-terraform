module "kms" {
  source = "../modules"

  create        = var.create_kms
  master_prefix = var.master_prefix
  create_kms    = var.create_kms

  kms_keys = var.create_kms ? {
    qm_encryption = {
      description             = var.kms_config.key.description
      deletion_window_in_days = var.kms_config.key.deletion_window
      enable_key_rotation     = var.kms_config.key.enable_rotation
      alias                   = var.kms_config.key.alias

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
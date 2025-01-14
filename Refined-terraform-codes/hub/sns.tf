module "sns" {
  source = "../modules"

  create        = var.create_sns
  master_prefix = "qm"
  create_sns    = var.create_sns

  sns_topics = var.create_sns ? {
    publisher = {
      name              = var.sns_config["publisher"].name
      kms_master_key_id = local.kms_arn
      tags = merge(
        {
          Name = var.sns_config["publisher"].name
        },
        local.merged_tags
      )
      subscriptions = {
        for idx, email in var.sns_emails : "email_${idx}" => {
          protocol = var.sns_config["publisher"].protocol
          endpoint = email
        }
      }
    }
  } : {}
}
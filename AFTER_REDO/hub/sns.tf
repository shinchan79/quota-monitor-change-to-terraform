module "sns" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_sns = true
  sns_topics = {
    publisher = {
      name              = "SNSPublisher-Topic"
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]
      tags = {
        Name = "QuotaMonitor-Publisher-Topic"
      }
      subscriptions = {
        email = {
          protocol = "email"
          endpoint = var.sns_email
        }
      }
    }
  }
}
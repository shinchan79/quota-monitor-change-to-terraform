module "dynamodb" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_dynamodb = true
  dynamodb_tables = {
    quota_monitor = {
      name         = "QuotaMonitor-Table"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "MessageId"
      range_key    = "TimeStamp"

      attributes = [
        {
          name = "MessageId"
          type = "S"
        },
        {
          name = "TimeStamp"
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled     = true
        kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
      }

      point_in_time_recovery_enabled = true

      ttl = {
        enabled        = true
        attribute_name = "ExpiryTime"
      }

      deletion_protection_enabled = true

      tags = {
        Name = "QuotaMonitor-Table"
      }
    }
  }
}
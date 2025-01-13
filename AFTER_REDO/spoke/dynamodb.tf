module "dynamodb" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_dynamodb = true
  dynamodb_tables = {
    ################# QM Spoke
    service = {
      name         = "QM-ServiceTable"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "ServiceCode"

      attributes = [
        {
          name = "ServiceCode"
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled = true
      }

      point_in_time_recovery_enabled = true

      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"

      deletion_protection_enabled = false

      tags = {
        Name = "QM-ServiceTable"
      }
    }

    quota = {
      name         = "QM-QuotaTable"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "ServiceCode"
      range_key    = "QuotaCode"

      attributes = [
        {
          name = "ServiceCode"
          type = "S"
        },
        {
          name = "QuotaCode"
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled = true
      }

      point_in_time_recovery_enabled = true

      stream_enabled = false

      deletion_protection_enabled = false

      tags = {
        Name = "QM-QuotaTable"
      }
    }
  }
}
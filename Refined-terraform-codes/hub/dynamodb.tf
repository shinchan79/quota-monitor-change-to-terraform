module "dynamodb" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_dynamodb = true
  dynamodb_tables = {
    quota_monitor = {
      name         = var.dynamodb_config.table_name
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = var.dynamodb_config.hash_key
      range_key    = var.dynamodb_config.range_key

      attributes = [
        {
          name = var.dynamodb_config.hash_key
          type = "S"
        },
        {
          name = var.dynamodb_config.range_key
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
        attribute_name = var.dynamodb_config.ttl_attribute
      }

      deletion_protection_enabled = true

      tags = merge(
        {
          Name = var.dynamodb_config.table_name
        },
        local.merged_tags
      )
    }
  }
}

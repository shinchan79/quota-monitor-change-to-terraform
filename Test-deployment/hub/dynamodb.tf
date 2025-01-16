module "dynamodb" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  create_dynamodb = true
  dynamodb_tables = {
    for key, table in var.dynamodb_config : key => {
      name         = table.table_name
      billing_mode = table.billing_mode
      hash_key     = table.hash_key
      range_key    = table.range_key

      attributes = [
        {
          name = table.hash_key
          type = "S"
        },
        {
          name = table.range_key
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
        attribute_name = table.ttl_attribute
      }

      deletion_protection_enabled = true

      tags = merge(
        {
          Name = table.table_name
        },
        local.merged_tags
      )
    }
  }
}
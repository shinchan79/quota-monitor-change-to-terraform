module "dynamodb" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  create_dynamodb = true
  dynamodb_tables = {
    for key, table in var.dynamodb_config : key => {
      name         = "${var.master_prefix}-${table.name}"
      billing_mode = table.billing_mode
      hash_key     = table.hash_key
      range_key    = table.range_key

      attributes = table.range_key != null ? [
        {
          name = table.hash_key
          type = "S"
        },
        {
          name = table.range_key
          type = "S"
        }
        ] : [
        {
          name = table.hash_key
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled = table.encryption_enabled
      }

      point_in_time_recovery_enabled = table.point_in_time_recovery_enabled

      stream_enabled   = table.stream_enabled
      stream_view_type = table.stream_view_type

      deletion_protection_enabled = table.deletion_protection_enabled

      tags = {
        Name = "${var.master_prefix}-${table.name}"
      }
    }
  }
}
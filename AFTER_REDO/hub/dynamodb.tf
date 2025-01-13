# module "dynamodb" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   create_dynamodb = true
#   dynamodb_tables = {
#     quota_monitor = {
#       name         = "QuotaMonitor-Table"
#       billing_mode = "PAY_PER_REQUEST"
#       hash_key     = "MessageId"
#       range_key    = "TimeStamp"

#       attributes = [
#         {
#           name = "MessageId"
#           type = "S"
#         },
#         {
#           name = "TimeStamp"
#           type = "S"
#         }
#       ]

#       server_side_encryption = {
#         enabled     = true
#         kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
#       }

#       point_in_time_recovery_enabled = true

#       ttl = {
#         enabled        = true
#         attribute_name = "ExpiryTime"
#       }

#       deletion_protection_enabled = true

#       tags = {
#         Name = "QuotaMonitor-Table"
#       }
#     }
#   }
# }

module "dynamodb" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_dynamodb = true
  dynamodb_tables = {
    quota_monitor = {
      name         = var.dynamodb_table_name
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = var.dynamodb_hash_key
      range_key    = var.dynamodb_range_key

      attributes = [
        {
          name = var.dynamodb_hash_key
          type = "S"
        },
        {
          name = var.dynamodb_range_key
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
        attribute_name = var.dynamodb_ttl_attribute
      }

      deletion_protection_enabled = true

      tags = {
        Name = var.dynamodb_table_name
      }
    }
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "QuotaMonitor-Table"
}

variable "dynamodb_hash_key" {
  description = "Hash key for DynamoDB table"
  type        = string
  default     = "MessageId"
}

variable "dynamodb_range_key" {
  description = "Range key for DynamoDB table"
  type        = string
  default     = "TimeStamp"
}

variable "dynamodb_ttl_attribute" {
  description = "TTL attribute name for DynamoDB table"
  type        = string
  default     = "ExpiryTime"
}
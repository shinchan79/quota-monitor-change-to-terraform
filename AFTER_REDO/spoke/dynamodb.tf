# module "dynamodb" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   create_dynamodb = true
#   dynamodb_tables = {
#     ################# QM Spoke
#     service = {
#       name         = "QM-ServiceTable"
#       billing_mode = "PAY_PER_REQUEST"
#       hash_key     = "ServiceCode"

#       attributes = [
#         {
#           name = "ServiceCode"
#           type = "S"
#         }
#       ]

#       server_side_encryption = {
#         enabled = true
#       }

#       point_in_time_recovery_enabled = true

#       stream_enabled   = true
#       stream_view_type = "NEW_AND_OLD_IMAGES"

#       deletion_protection_enabled = false

#       tags = {
#         Name = "QM-ServiceTable"
#       }
#     }

#     quota = {
#       name         = "QM-QuotaTable"
#       billing_mode = "PAY_PER_REQUEST"
#       hash_key     = "ServiceCode"
#       range_key    = "QuotaCode"

#       attributes = [
#         {
#           name = "ServiceCode"
#           type = "S"
#         },
#         {
#           name = "QuotaCode"
#           type = "S"
#         }
#       ]

#       server_side_encryption = {
#         enabled = true
#       }

#       point_in_time_recovery_enabled = true

#       stream_enabled = false

#       deletion_protection_enabled = false

#       tags = {
#         Name = "QM-QuotaTable"
#       }
#     }
#   }
# }

module "dynamodb" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  create_dynamodb = true
  dynamodb_tables = {
    service = {
      name         = "${var.master_prefix}-ServiceTable"
      billing_mode = var.billing_mode
      hash_key     = var.service_table_hash_key

      attributes = [
        {
          name = var.service_table_hash_key
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled = var.encryption_enabled
      }

      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled

      stream_enabled   = var.service_stream_enabled
      stream_view_type = var.service_stream_view_type

      deletion_protection_enabled = var.deletion_protection_enabled

      tags = {
        Name = "${var.master_prefix}-ServiceTable"
      }
    }

    quota = {
      name         = "${var.master_prefix}-QuotaTable"
      billing_mode = var.billing_mode
      hash_key     = var.quota_table_hash_key
      range_key    = var.quota_table_range_key

      attributes = [
        {
          name = var.quota_table_hash_key
          type = "S"
        },
        {
          name = var.quota_table_range_key
          type = "S"
        }
      ]

      server_side_encryption = {
        enabled = var.encryption_enabled
      }

      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled

      stream_enabled = var.quota_stream_enabled

      deletion_protection_enabled = var.deletion_protection_enabled

      tags = {
        Name = "${var.master_prefix}-QuotaTable"
      }
    }
  }
}

variable "master_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "qm"
}

variable "billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "service_table_hash_key" {
  description = "Hash key for service table"
  type        = string
  default     = "ServiceCode"
}

variable "quota_table_hash_key" {
  description = "Hash key for quota table"
  type        = string
  default     = "ServiceCode"
}

variable "quota_table_range_key" {
  description = "Range key for quota table"
  type        = string
  default     = "QuotaCode"
}

variable "encryption_enabled" {
  description = "Enable server side encryption"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point in time recovery"
  type        = bool
  default     = true
}

variable "service_stream_enabled" {
  description = "Enable DynamoDB stream for service table"
  type        = bool
  default     = true
}

variable "service_stream_view_type" {
  description = "DynamoDB stream view type for service table"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "quota_stream_enabled" {
  description = "Enable DynamoDB stream for quota table"
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}
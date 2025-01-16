variable "create_kms" {
  description = "Controls if KMS keys should be created"
  type        = bool
  default     = false
}

variable "kms_keys" {
  description = "Map of KMS keys to create"
  type        = any
  default     = {}
}

resource "aws_kms_key" "this" {
  for_each = var.create_kms ? var.kms_keys : {}

  description             = each.value.description
  deletion_window_in_days = lookup(each.value, "deletion_window_in_days", 7)
  enable_key_rotation     = lookup(each.value, "enable_key_rotation", true)
  policy                  = lookup(each.value, "policy", null) != null ? jsonencode(each.value.policy) : null
  tags                    = lookup(each.value, "tags", {})
}

resource "aws_kms_alias" "this" {
  for_each = var.create_kms ? { for k, v in var.kms_keys : k => v if lookup(v, "alias", null) != null } : {}

  name          = each.value.alias
  target_key_id = aws_kms_key.this[each.key].key_id
}

output "keys" {
  description = "Map of KMS keys created and their attributes"
  value       = aws_kms_key.this
}

output "aliases" {
  description = "Map of KMS aliases created and their attributes"
  value       = aws_kms_alias.this
}
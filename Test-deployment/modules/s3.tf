#---------------------------------------------------------------
# S3 Bucket and Objects
#---------------------------------------------------------------

locals {
  create_bucket = var.create && var.create_s3
}

resource "aws_s3_bucket" "this" {
  for_each = { for k, v in var.s3_buckets : k => v if local.create_bucket }

  bucket        = try(each.value.name, null)
  bucket_prefix = try(each.value.bucket_prefix, null)
  force_destroy = try(each.value.force_destroy, false)

  tags = merge(
    {
      Name = try(each.value.name, each.value.bucket_prefix, "")
    },
    try(each.value.tags, {}),
    var.tags
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for k, v in var.s3_buckets : k => v if local.create_bucket }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = try(each.value.lifecycle_rules, [])

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.status, "Enabled")

      dynamic "filter" {
        for_each = try(rule.value.filter, null) != null ? [rule.value.filter] : []

        content {
          prefix = try(filter.value.prefix, null)
        }
      }

      dynamic "transition" {
        for_each = coalesce(try(rule.value.transitions, []), [])

        content {
          days          = try(transition.value.days, null)
          date          = try(transition.value.date, null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = try(rule.value.expiration, null) != null ? [rule.value.expiration] : []

        content {
          days                         = try(expiration.value.days, null)
          date                         = try(expiration.value.date, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = coalesce(try(rule.value.noncurrent_version_transitions, []), [])

        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(rule.value.noncurrent_version_expiration, null) != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(rule.value.abort_incomplete_multipart_upload_days, null) != null ? [rule.value.abort_incomplete_multipart_upload_days] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = { for k, v in var.s3_buckets : k => v if local.create_bucket && try(v.versioning_enabled, false) }

  bucket = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = { for k, v in var.s3_buckets : k => v if local.create_bucket && try(v.encryption_enabled, true) }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = try(each.value.sse_algorithm, "AES256")
      kms_master_key_id = try(each.value.kms_master_key_id, null)
    }
    bucket_key_enabled = try(each.value.bucket_key_enabled, false)
  }
}

resource "aws_s3_object" "this" {
  for_each = { for k, v in var.s3_objects : k => v if local.create_bucket }

  bucket = try(
    aws_s3_bucket.this[each.value.bucket_key].id,
    each.value.bucket
  )
  key            = each.value.key
  source         = try(each.value.source, null)
  content        = try(each.value.content, null)
  content_base64 = try(each.value.content_base64, null)

  server_side_encryption = try(each.value.server_side_encryption, "AES256")
  kms_key_id             = try(each.value.kms_key_id, null)
  storage_class          = try(each.value.storage_class, "STANDARD")

  override_provider {
    default_tags {
      tags = {}
    }
  }

  tags = try(each.value.tags, {})
}
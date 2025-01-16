module "s3" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  create_s3 = var.create_s3
  s3_buckets = var.create_s3 ? {
    source_code = {
      name               = format("%s-%s-%s-%s", var.master_prefix, var.s3_config.bucket_name, data.aws_region.current.name, data.aws_caller_identity.current.account_id)
      versioning_enabled = var.s3_config.versioning
      lifecycle_rules    = var.s3_config.lifecycle_rules
      tags = merge(
        {
          Name = format("%s-%s-%s-%s", var.master_prefix, var.s3_config.bucket_name, data.aws_region.current.name, data.aws_caller_identity.current.account_id)
        },
        local.merged_tags
      )
    }
  } : {}

  s3_objects = {
    for key, obj in var.source_code_objects : key => {
      bucket_key = var.create_s3 ? "source_code" : null
      bucket     = var.create_s3 ? null : var.existing_s3_bucket
      key        = obj.s3_key
      source     = "${path.module}/${obj.source_path}"
    }
  }
}
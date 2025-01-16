locals {
  # Merged tags for all resources
  merged_tags = merge(
    {
      Application = "QuotaMonitor"
      Environment = "Spoke"
    },
    var.tags
  )

  # S3 bucket name logic
  s3_bucket_name = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : var.existing_s3_bucket

  # Lambda source code mapping
  lambda_source = {
    for key, config in var.lambda_functions_config : key => {
      filename  = var.create_s3 ? null : try(config.local_source.filename, null)
      s3_bucket = var.create_s3 ? local.s3_bucket_name : try(config.s3_source.bucket, null)
      s3_key    = var.create_s3 ? local.lambda_source_map[key] : try(config.s3_source.key, null)
    }
  }

  lambda_source_map = {
    ta_refresher = var.source_code_objects["ta_refresher"].s3_key
    utils_ta     = var.source_code_objects["utils_ta"].s3_key
  }
}
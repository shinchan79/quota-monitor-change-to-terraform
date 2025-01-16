locals {
  create_hub_resources = var.deployment_model == "hub"

  quota_monitor_map = {
    Metrics = {
      MetricsEndpoint    = "https://metrics.awssolutionsbuilder.com/generic"
      SendAnonymizedData = "Yes"
    }
  }

  merged_tags = merge(
    var.tags,
    var.additional_tags
  )

  sns_arn        = var.create_sns ? module.sns.sns_topic_arns["publisher"] : var.existing_sns_arn
  kms_arn        = var.create_kms ? module.kms.kms_key_arns["qm_encryption"] : var.existing_kms_arn
  s3_bucket_name = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : var.existing_s3_bucket

  # Lambda source logic
  lambda_source = {
    for name, config in var.lambda_functions_config : name => {
      # Case 1: Local source path
      filename = lookup(config, "local_source.filename", null) != null ? config.local_source.filename : (
        # Case 2: S3 source (either from created bucket or existing bucket)
        var.create_s3 ? "${path.module}/${var.source_code_objects[name].source_path}" : (
          # Case 3: Existing S3 bucket
          lookup(config, "s3_source.filename", null)
        )
      )

      # Only set S3 attributes if using existing bucket
      s3_bucket = (!var.create_s3 && lookup(config, "local_source.filename", null) == null) ? (
        lookup(config, "s3_source.bucket", null)
      ) : null

      s3_key = (!var.create_s3 && lookup(config, "local_source.filename", null) == null) ? (
        lookup(config, "s3_source.key", null)
      ) : null
    }
  }

  # Lambda layer source logic
  lambda_layer_source = {
    for name, config in var.lambda_layer_config : name => {
      # Case 1: Local source path
      filename = lookup(config, "local_source.filename", null) != null ? config.local_source.filename : (
        # Case 2: S3 source (either from created bucket or existing bucket)
        var.create_s3 ? "${path.module}/${var.source_code_objects["utils_layer"].source_path}" : (
          # Case 3: Existing S3 bucket
          lookup(config, "s3_source.filename", null)
        )
      )

      # Only set S3 attributes if using existing bucket
      s3_bucket = (!var.create_s3 && lookup(config, "local_source.filename", null) == null) ? (
        lookup(config, "s3_source.bucket", null)
      ) : null

      s3_key = (!var.create_s3 && lookup(config, "local_source.filename", null) == null) ? (
        lookup(config, "s3_source.key", null)
      ) : null
    }
  }

  # Map of lambda source code keys in S3
  lambda_source_map = {
    provider_framework = var.source_code_objects["provider_framework"].s3_key
    helper             = var.source_code_objects["helper"].s3_key
    sns_publisher      = var.source_code_objects["sns_publisher"].s3_key
    reporter           = var.source_code_objects["reporter"].s3_key
    utils_layer        = var.source_code_objects["utils_layer"].s3_key
  }
}
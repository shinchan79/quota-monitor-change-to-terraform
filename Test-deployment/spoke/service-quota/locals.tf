locals {
  ssm_parameters = {
    notification_muting_config = "/QuotaMonitor/spoke/NotificationConfiguration"
  }

  spoke_sns_region_exists = var.spoke_sns_region != ""

  quota_monitor_map = {
    ssm_parameters          = local.ssm_parameters
    spoke_sns_region_exists = local.spoke_sns_region_exists
  }

  # Common lambda function ARN format
  list_manager_function_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.master_prefix}-ListManager-Function"

  # Merged tags for all resources
  merged_tags = merge(
    {
      Application = "QuotaMonitor"
      Environment = "Spoke"
    },
    var.tags
  )

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

  # Map of lambda source code keys in S3
  lambda_source_map = {
    sns_publisher         = var.source_code_objects["sns_publisher"].s3_key
    list_manager          = var.source_code_objects["list_manager"].s3_key
    list_manager_provider = var.source_code_objects["list_manager_provider"].s3_key
    qmcw_poller           = var.source_code_objects["qmcw_poller"].s3_key
    utils_sns_spoke       = var.source_code_objects["utils_sns_spoke"].s3_key
    utils_sq_spoke        = var.source_code_objects["utils_sq_spoke"].s3_key
  }
}
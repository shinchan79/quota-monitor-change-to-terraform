module "lambda_layer" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  lambda_layers = {
    utils_sns_spoke = {
      name                = var.lambda_layer_config["utils_sns_spoke"].layer.name
      compatible_runtimes = var.lambda_layer_config["utils_sns_spoke"].layer.runtimes
      # Source code logic
      filename  = var.create_s3 ? null : try(var.lambda_layer_config["utils_sns_spoke"].layer.local_source.filename, null)
      s3_bucket = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : try(var.lambda_layer_config["utils_sns_spoke"].layer.s3_source.bucket, null)
      s3_key    = var.create_s3 ? "layers/utils_sns_spoke.zip" : try(var.lambda_layer_config["utils_sns_spoke"].layer.s3_source.key, null)
      tags = merge(
        {
          Name = var.lambda_layer_config["utils_sns_spoke"].layer.name
        },
        local.merged_tags
      )
    }

    utils_sq_spoke = {
      name                = var.lambda_layer_config["utils_sq_spoke"].layer.name
      compatible_runtimes = var.lambda_layer_config["utils_sq_spoke"].layer.runtimes
      # Source code logic
      filename  = var.create_s3 ? null : try(var.lambda_layer_config["utils_sq_spoke"].layer.local_source.filename, null)
      s3_bucket = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : try(var.lambda_layer_config["utils_sq_spoke"].layer.s3_source.bucket, null)
      s3_key    = var.create_s3 ? "layers/utils_sq_spoke.zip" : try(var.lambda_layer_config["utils_sq_spoke"].layer.s3_source.key, null)
      tags = merge(
        {
          Name = var.lambda_layer_config["utils_sq_spoke"].layer.name
        },
        local.merged_tags
      )
    }
  }

  depends_on = [module.s3]
}
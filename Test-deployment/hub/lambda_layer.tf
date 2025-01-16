module "lambda_layer" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  lambda_layers = {
    utils_sns_spoke = {
      name                = var.lambda_layer_config["utils_sns_spoke"].layer.name
      compatible_runtimes = var.lambda_layer_config["utils_sns_spoke"].layer.runtimes
      s3_bucket           = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : var.existing_s3_bucket
      s3_key              = var.source_code_objects["utils_sns_spoke"].s3_key
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
      s3_bucket           = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : var.existing_s3_bucket
      s3_key              = var.source_code_objects["utils_sq_spoke"].s3_key
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
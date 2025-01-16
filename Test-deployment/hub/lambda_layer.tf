module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  lambda_layers = {
    utils = {
      name                = var.lambda_layer_config["utils"].layer.name
      description         = "Utils Layer for Hub Functions"
      compatible_runtimes = var.lambda_layer_config["utils"].layer.runtimes
      compatible_architectures = ["x86_64"]

      # Source code logic
      filename  = var.create_s3 ? null : try(var.lambda_layer_config["utils"].layer.local_source.filename, null)
      s3_bucket = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : try(var.lambda_layer_config["utils"].layer.s3_source.bucket, null)
      s3_key    = var.create_s3 ? var.source_code_objects["utils_layer"].s3_key : try(var.lambda_layer_config["utils"].layer.s3_source.key, null)

      tags = merge(
        {
          Name = var.lambda_layer_config["utils"].layer.name
        },
        local.merged_tags
      )
    }
  }

  depends_on = [module.s3]
}
module "lambda_layer" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  lambda_layers = {
    utils_ta = {
      name                = var.lambda_layer_config["utils_ta"].layer.name
      compatible_runtimes = var.lambda_layer_config["utils_ta"].layer.runtimes

      # Source code logic
      filename  = var.create_s3 ? null : try(var.lambda_layer_config["utils_ta"].layer.local_source.filename, null)
      s3_bucket = var.create_s3 ? module.s3.s3_bucket_ids["source_code"] : try(var.lambda_layer_config["utils_ta"].layer.s3_source.bucket, null)
      s3_key    = var.create_s3 ? local.lambda_source_map["utils_ta"] : try(var.lambda_layer_config["utils_ta"].layer.s3_source.key, null)

      tags = merge(
        {
          Name = var.lambda_layer_config["utils_ta"].layer.name
        },
        local.merged_tags
      )
    }
  }

  depends_on = [module.s3]
}

variable "lambda_layer_config" {
  description = "Configuration for Lambda Layers"
  type = map(object({
    layer = object({
      name     = string
      runtimes = list(string)
      local_source = optional(object({
        filename = string
      }))
      s3_source = optional(object({
        bucket = string
        key    = string
      }))
    })
  }))
}
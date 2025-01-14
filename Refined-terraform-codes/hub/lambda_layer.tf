module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  create_lambda_layer = true
  lambda_layers = {
    utils = {
      name                = var.lambda_layer_config.layer.name
      compatible_runtimes = var.lambda_layer_config.layer.runtimes
      filename = {
        s3_bucket = var.lambda_layer_config.code.s3_bucket
        s3_key    = var.lambda_layer_config.code.s3_key
      }
    }
  }
}

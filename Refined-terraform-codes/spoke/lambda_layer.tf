module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  create_lambda_layer = true
  lambda_layers = {
    for key, layer in var.lambda_layer_config : key => {
      name                = "${var.master_prefix}-${layer.layer.name}"
      compatible_runtimes = layer.layer.runtimes
      filename = {
        s3_bucket = layer.code.s3_bucket
        s3_key    = layer.code.s3_key
      }
    }
  }
}
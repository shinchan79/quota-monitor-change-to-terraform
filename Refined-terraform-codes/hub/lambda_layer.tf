module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

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

variable "lambda_layer_config" {
  description = "Configuration for Lambda Layer"
  type = object({
    layer = object({
      name     = string
      runtimes = list(string)
    })
    code = object({
      s3_bucket = string
      s3_key    = string
    })
  })
  default = {
    layer = {
      name     = "QM-UtilsLayer"
      runtimes = ["nodejs18.x"]
    }
    code = {
      s3_bucket = "immersionday-aaaa-jjjj"
      s3_key    = "test-aws-myApplication.zip"
    }
  }
}
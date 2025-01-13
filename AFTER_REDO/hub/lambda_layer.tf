# module "lambda_layer" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   # Lambda Layer
#   create_lambda_layer = true
#   lambda_layers = {
#     utils = {
#       name                = "QM-UtilsLayer"
#       compatible_runtimes = ["nodejs18.x"]
#       filename = {
#         s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#         s3_key      = "test-aws-myApplication.zip"
#       }
#     }
#   }
# }
module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_lambda_layer = true
  lambda_layers = {
    utils = {
      name                = var.lambda_layer_name
      compatible_runtimes = var.lambda_layer_runtimes
      filename = {
        s3_bucket = var.lambda_layer_s3_bucket
        s3_key    = var.lambda_layer_s3_key
      }
    }
  }
}

variable "lambda_layer_name" {
  description = "Name of the Lambda Layer"
  type        = string
  default     = "QM-UtilsLayer"
}

variable "lambda_layer_runtimes" {
  description = "List of compatible runtimes for the Lambda Layer"
  type        = list(string)
  default     = ["nodejs18.x"]
}

variable "lambda_layer_s3_bucket" {
  description = "S3 bucket containing the Lambda Layer code"
  type        = string
  default     = "immersionday-aaaa-jjjj"
}

variable "lambda_layer_s3_key" {
  description = "S3 key for the Lambda Layer code"
  type        = string
  default     = "test-aws-myApplication.zip"
}
# module "lambda_layer" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   # Lambda Layer configuration
#   create_lambda_layer = true
#   lambda_layers = {
#     ################# SNS Spoke
#     utils_sns_spoke = {
#       name                = "QM-UtilsLayer-quota-monitor-sns-spoke"
#       compatible_runtimes = ["nodejs18.x"]
#       filename = {
#         s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#         s3_key      = "test-aws-myApplication.zip"
#       }
#     }

#     ################# SQ Spoke
#     utils_sq_spoke = {
#       name                = "QM-UtilsLayer-quota-monitor-sq-spoke"
#       compatible_runtimes = ["nodejs18.x"]
#       filename = {
#         s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#         s3_key      = "test-aws-myApplication.zip"
#       }
#     }

#     ################# TA Spoke
#     utils_ta = {
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
  master_prefix = var.master_prefix

  # Lambda Layer configuration
  create_lambda_layer = true
  lambda_layers = {
    ################# SNS Spoke
    utils_sns_spoke = {
      name                = "${var.master_prefix}-UtilsLayer-quota-monitor-sns-spoke"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket = var.lambda_layer_s3_bucket
        s3_key    = var.lambda_layer_s3_key
      }
    }

    ################# SQ Spoke
    utils_sq_spoke = {
      name                = "${var.master_prefix}-UtilsLayer-quota-monitor-sq-spoke"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket = var.lambda_layer_s3_bucket
        s3_key    = var.lambda_layer_s3_key
      }
    }

    ################# TA Spoke
    utils_ta = {
      name                = "${var.master_prefix}-UtilsLayer"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket = var.lambda_layer_s3_bucket
        s3_key    = var.lambda_layer_s3_key
      }
    }
  }
}

variable "lambda_layer_s3_bucket" {
  description = "S3 bucket containing lambda layer code"
  type        = string
}

variable "lambda_layer_s3_key" {
  description = "S3 key for lambda layer code"
  type        = string
}
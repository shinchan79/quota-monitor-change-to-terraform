module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  # Lambda Layer configuration
  create_lambda_layer = true
  lambda_layers = {
    ################# SNS Spoke
    utils_sns_spoke = {
      name                = "QM-UtilsLayer-quota-monitor-sns-spoke"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
        s3_key      = "test-aws-myApplication.zip"
      }
    }

    ################# SQ Spoke
    utils_sq_spoke = {
      name                = "QM-UtilsLayer-quota-monitor-sq-spoke"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
        s3_key      = "test-aws-myApplication.zip"
      }
    }

    ################# TA Spoke
    utils_ta = {
      name                = "QM-UtilsLayer"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
        s3_key      = "test-aws-myApplication.zip"
      }
    }
  }
}
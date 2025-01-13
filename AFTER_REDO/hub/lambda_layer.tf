module "lambda_layer" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  # Lambda Layer
  create_lambda_layer = true
  lambda_layers = {
    utils = {
      name                = "QM-UtilsLayer"
      compatible_runtimes = ["nodejs18.x"]
      filename = {
        s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
        s3_key      = "test-aws-myApplication.zip"
      }
    }
  }
}
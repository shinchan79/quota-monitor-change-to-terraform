module "helper_lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  lambda_functions = {
    helper = {
      name        = "Helper-Function"
      description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 5
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["lambda_helper"]

      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"
      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      layers = [
        module.lambda_layer.lambda_layer_arns["utils"]
      ]

      environment_variables = {
        METRICS_ENDPOINT      = local.quota_monitor_map.Metrics.MetricsEndpoint
        SEND_METRIC           = local.quota_monitor_map.Metrics.SendAnonymizedData
        QM_STACK_ID           = "quota-monitor-hub"
        QM_SLACK_NOTIFICATION = var.slack_notification
        QM_EMAIL_NOTIFICATION = var.enable_email ? "Yes" : "No"
        SAGEMAKER_MONITORING  = var.sagemaker_monitoring
        CONNECT_MONITORING    = var.connect_monitoring
        LOG_LEVEL             = "info"
        CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0005/v6.3.0"
        VERSION               = "v6.3.0"
        SOLUTION_ID           = "SO0005"
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/QuotaMonitor-Helper"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-Helper"
      }
    }
  }
}
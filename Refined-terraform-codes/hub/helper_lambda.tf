module "helper_lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  lambda_functions = {
    helper = {
      name        = var.helper_config.lambda_function.name
      description = var.helper_config.lambda_function.description
      runtime     = var.helper_config.lambda_function.runtime
      handler     = var.helper_config.lambda_function.handler
      timeout     = var.helper_config.lambda_function.timeout
      memory_size = var.helper_config.lambda_function.memory_size
      role_arn    = module.iam.iam_role_arns["lambda_helper"]

      s3_bucket          = var.helper_config.lambda_code.s3_bucket
      s3_key             = var.helper_config.lambda_code.s3_key
      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      layers = [
        module.lambda_layer.lambda_layer_arns["utils"]
      ]

      environment_variables = {
        METRICS_ENDPOINT      = local.quota_monitor_map.Metrics.MetricsEndpoint
        SEND_METRIC           = local.quota_monitor_map.Metrics.SendAnonymizedData
        QM_STACK_ID           = var.helper_config.lambda_environment.stack_id
        QM_SLACK_NOTIFICATION = var.slack_notification
        QM_EMAIL_NOTIFICATION = var.enable_email ? "Yes" : "No"
        SAGEMAKER_MONITORING  = var.sagemaker_monitoring
        CONNECT_MONITORING    = var.connect_monitoring
        LOG_LEVEL             = var.helper_config.lambda_logging.log_level
        CUSTOM_SDK_USER_AGENT = var.helper_config.lambda_environment.sdk_user_agent
        VERSION               = var.helper_config.lambda_environment.version
        SOLUTION_ID           = var.helper_config.lambda_environment.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.helper_config.lambda_event.max_event_age
        qualifier                    = var.helper_config.lambda_event.qualifier
      }

      logging_config = {
        log_format = var.helper_config.lambda_logging.log_format
        log_group  = var.helper_config.lambda_logging.log_group
        log_level  = var.helper_config.lambda_logging.logging_level
      }

      tags = {
        Name = var.helper_config.lambda_function.tag_name
      }
    }
  }
}

variable "helper_config" {
  description = "Configuration for Helper Lambda function"
  type = object({
    lambda_function = object({
      name        = string
      description = string
      runtime     = string
      handler     = string
      timeout     = number
      memory_size = number
      tag_name    = string
    })
    lambda_code = object({
      s3_bucket = string
      s3_key    = string
    })
    lambda_environment = object({
      stack_id       = string
      sdk_user_agent = string
      version        = string
      solution_id    = string
    })
    lambda_event = object({
      max_event_age = number
      qualifier     = string
    })
    lambda_logging = object({
      log_level     = string
      log_format    = string
      log_group     = string
      logging_level = string
    })
  })
  default = {
    lambda_function = {
      name        = "Helper-Function"
      description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 5
      memory_size = 128
      tag_name    = "QuotaMonitor-Helper"
    }
    lambda_code = {
      s3_bucket = "immersionday-aaaa-jjjj"
      s3_key    = "test-aws-myApplication.zip"
    }
    lambda_environment = {
      stack_id       = "quota-monitor-hub"
      sdk_user_agent = "AwsSolution/SO0005/v6.3.0"
      version        = "v6.3.0"
      solution_id    = "SO0005"
    }
    lambda_event = {
      max_event_age = 14400
      qualifier     = "$LATEST"
    }
    lambda_logging = {
      log_level     = "info"
      log_format    = "JSON"
      log_group     = "/aws/lambda/QuotaMonitor-Helper"
      logging_level = "INFO"
    }
  }
}
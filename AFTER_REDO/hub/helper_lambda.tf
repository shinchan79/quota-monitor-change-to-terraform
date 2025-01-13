# module "helper_lambda" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   lambda_functions = {
#     helper = {
#       name        = "Helper-Function"
#       description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
#       runtime     = "nodejs18.x"
#       handler     = "index.handler"
#       timeout     = 5
#       memory_size = 128
#       role_arn    = module.iam.iam_role_arns["lambda_helper"]

#       s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#       s3_key      = "test-aws-myApplication.zip"
#       security_group_ids = var.vpc_config.security_group_ids
#       subnet_ids         = var.vpc_config.subnet_ids

#       layers = [
#         module.lambda_layer.lambda_layer_arns["utils"]
#       ]

#       environment_variables = {
#         METRICS_ENDPOINT      = local.quota_monitor_map.Metrics.MetricsEndpoint
#         SEND_METRIC           = local.quota_monitor_map.Metrics.SendAnonymizedData
#         QM_STACK_ID           = "quota-monitor-hub"
#         QM_SLACK_NOTIFICATION = var.slack_notification
#         QM_EMAIL_NOTIFICATION = var.enable_email ? "Yes" : "No"
#         SAGEMAKER_MONITORING  = var.sagemaker_monitoring
#         CONNECT_MONITORING    = var.connect_monitoring
#         LOG_LEVEL             = "info"
#         CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0005/v6.3.0"
#         VERSION               = "v6.3.0"
#         SOLUTION_ID           = "SO0005"
#       }

#       event_invoke_config = {
#         maximum_event_age_in_seconds = 14400
#         qualifier                    = "$LATEST"
#       }

#       logging_config = {
#         log_format = "JSON"
#         log_group  = "/aws/lambda/QuotaMonitor-Helper"
#         log_level  = "INFO"
#       }

#       tags = {
#         Name = "QuotaMonitor-Helper"
#       }
#     }
#   }
# }

module "helper_lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  lambda_functions = {
    helper = {
      name        = var.helper_function_name
      description = var.helper_function_description
      runtime     = var.helper_runtime
      handler     = var.helper_handler
      timeout     = var.helper_timeout
      memory_size = var.helper_memory_size
      role_arn    = module.iam.iam_role_arns["lambda_helper"]

      s3_bucket = var.helper_s3_bucket
      s3_key    = var.helper_s3_key
      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      layers = [
        module.lambda_layer.lambda_layer_arns["utils"]
      ]

      environment_variables = {
        METRICS_ENDPOINT      = local.quota_monitor_map.Metrics.MetricsEndpoint
        SEND_METRIC          = local.quota_monitor_map.Metrics.SendAnonymizedData
        QM_STACK_ID          = var.helper_stack_id
        QM_SLACK_NOTIFICATION = var.slack_notification
        QM_EMAIL_NOTIFICATION = var.enable_email ? "Yes" : "No"
        SAGEMAKER_MONITORING  = var.sagemaker_monitoring
        CONNECT_MONITORING    = var.connect_monitoring
        LOG_LEVEL            = var.helper_log_level
        CUSTOM_SDK_USER_AGENT = var.helper_sdk_user_agent
        VERSION              = var.helper_version
        SOLUTION_ID          = var.helper_solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.helper_max_event_age
        qualifier                    = var.helper_qualifier
      }

      logging_config = {
        log_format = var.helper_log_format
        log_group  = var.helper_log_group
        log_level  = var.helper_logging_level
      }

      tags = {
        Name = var.helper_function_tag_name
      }
    }
  }
}

variable "helper_function_name" {
  description = "Name of the Helper Lambda function"
  type        = string
  default     = "Helper-Function"
}

variable "helper_function_description" {
  description = "Description of the Helper Lambda function"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
}

variable "helper_runtime" {
  description = "Runtime for the Helper Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "helper_handler" {
  description = "Handler for the Helper Lambda function"
  type        = string
  default     = "index.handler"
}

variable "helper_timeout" {
  description = "Timeout for the Helper Lambda function"
  type        = number
  default     = 5
}

variable "helper_memory_size" {
  description = "Memory size for the Helper Lambda function"
  type        = number
  default     = 128
}

variable "helper_s3_bucket" {
  description = "S3 bucket containing the Lambda function code"
  type        = string
  default     = "immersionday-aaaa-jjjj"
}

variable "helper_s3_key" {
  description = "S3 key for the Lambda function code"
  type        = string
  default     = "test-aws-myApplication.zip"
}

variable "helper_stack_id" {
  description = "Stack ID for the Helper function"
  type        = string
  default     = "quota-monitor-hub"
}

variable "helper_log_level" {
  description = "Log level for the Helper function"
  type        = string
  default     = "info"
}

variable "helper_sdk_user_agent" {
  description = "Custom SDK user agent for the Helper function"
  type        = string
  default     = "AwsSolution/SO0005/v6.3.0"
}

variable "helper_version" {
  description = "Version of the Helper function"
  type        = string
  default     = "v6.3.0"
}

variable "helper_solution_id" {
  description = "Solution ID for the Helper function"
  type        = string
  default     = "SO0005"
}

variable "helper_max_event_age" {
  description = "Maximum event age in seconds for the Helper function"
  type        = number
  default     = 14400
}

variable "helper_qualifier" {
  description = "Qualifier for the Helper function"
  type        = string
  default     = "$LATEST"
}

variable "helper_log_format" {
  description = "Log format for the Helper function"
  type        = string
  default     = "JSON"
}

variable "helper_log_group" {
  description = "Log group for the Helper function"
  type        = string
  default     = "/aws/lambda/QuotaMonitor-Helper"
}

variable "helper_logging_level" {
  description = "Logging level for the Helper function"
  type        = string
  default     = "INFO"
}

variable "helper_function_tag_name" {
  description = "Name tag for the Helper function"
  type        = string
  default     = "QuotaMonitor-Helper"
}
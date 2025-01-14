# module "lambda" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   lambda_functions = {
#     provider_framework = {
#       name        = "Helper-Provider-Framework"
#       description = "AWS CDK resource provider framework - onEvent (quota-monitor-hub/QM-Helper/QM-Helper-Provider)"
#       runtime     = "nodejs18.x"
#       handler     = "framework.onEvent"
#       timeout     = 900
#       memory_size = 128
#       role_arn    = module.iam.iam_role_arns["provider_framework"]
#       s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#       s3_key      = "test-aws-myApplication.zip"

#       security_group_ids = var.vpc_config.security_group_ids
#       subnet_ids         = var.vpc_config.subnet_ids

#       environment_variables = {
#         USER_ON_EVENT_FUNCTION_ARN = module.helper_lambda.lambda_function_arns["helper"]
#       }

#       logging_config = {
#         log_format = "JSON"
#         log_group  = "/aws/lambda/Helper-Provider-Framework"
#         log_level  = "INFO"
#       }

#       tags = {
#         Name = "QuotaMonitor-ProviderFramework"
#       }

#       depends_on = [
#         module.iam.iam_role_arns["provider_framework"],
#         module.helper_lambda
#       ]
#     }

#     sns_publisher = {
#       name        = "SNSPublisher-Lambda"
#       description = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-Lambda"
#       runtime     = "nodejs18.x"
#       handler     = "index.handler"
#       timeout     = 60
#       memory_size = 128
#       role_arn    = module.iam.iam_role_arns["sns_publisher"]
#       s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#       s3_key      = "test-aws-myApplication.zip"

#       security_group_ids = var.vpc_config.security_group_ids
#       subnet_ids         = var.vpc_config.subnet_ids

#       dead_letter_config = {
#         target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
#       }

#       kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
#       layers      = [module.lambda_layer.lambda_layer_arns["utils"]]

#       environment_variables = {
#         QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
#         # SOLUTION_UUID                           = module.helper_lambda.lambda_function_arns["helper"]
#         SOLUTION_UUID                           = random_uuid.helper_uuid.result # Cần check xem có cần không, custom resource này để làm gì
#         METRICS_ENDPOINT                        = local.quota_monitor_map.Metrics.MetricsEndpoint
#         SEND_METRIC                             = local.quota_monitor_map.Metrics.SendAnonymizedData
#         TOPIC_ARN                               = module.sns.sns_topic_arns["publisher"]
#         LOG_LEVEL                               = "info"
#         CUSTOM_SDK_USER_AGENT                   = "AwsSolution/SO0005/v6.3.0"
#         VERSION                                 = "v6.3.0"
#         SOLUTION_ID                             = "SO0005"
#       }

#       event_invoke_config = {
#         maximum_event_age_in_seconds = 14400
#         qualifier                    = "$LATEST"
#       }

#       logging_config = {
#         log_format = "JSON"
#         log_group  = "/aws/lambda/SNSPublisher-Lambda"
#         log_level  = "INFO"
#       }

#       tags = {
#         Name = "QuotaMonitor-SNSPublisher"
#       }

#       depends_on = [
#         module.iam.iam_role_arns["sns_publisher"],
#         module.helper_lambda
#       ]
#     }

#     reporter = {
#       name        = "Reporter-Lambda"
#       description = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
#       runtime     = "nodejs18.x"
#       handler     = "index.handler"
#       timeout     = 10
#       memory_size = 512
#       role_arn    = module.iam.iam_role_arns["reporter"]
#       s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#       s3_key      = "test-aws-myApplication.zip"

#       security_group_ids = var.vpc_config.security_group_ids
#       subnet_ids         = var.vpc_config.subnet_ids

#       dead_letter_config = {
#         target_arn = module.sqs.sqs_queue_arns["reporter_dlq"]
#       }

#       kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

#       layers = [
#         module.lambda_layer.lambda_layer_arns["utils"]
#       ]

#       environment_variables = {
#         QUOTA_TABLE           = module.dynamodb.dynamodb_table_ids["quota_monitor"]
#         SQS_URL               = module.sqs.sqs_queue_urls["summarizer_event_queue"]
#         MAX_MESSAGES          = "10"
#         MAX_LOOPS             = "10"
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
#         log_group  = "/aws/lambda/Reporter-Lambda"
#         log_level  = "INFO"
#       }

#       tags = {
#         Name = "QuotaMonitor-Reporter"
#       }

#       depends_on = [
#         module.iam.iam_role_arns["reporter"],
#         module.helper_lambda
#       ]
#     }

#     deployment_manager = {
#       name        = "DeploymentManager-Lambda"
#       description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
#       runtime     = "nodejs18.x"
#       handler     = "index.handler"
#       timeout     = 60
#       memory_size = 512
#       role_arn    = module.iam.iam_role_arns["reporter"]
#       s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
#       s3_key      = "test-aws-myApplication.zip"

#       security_group_ids = var.vpc_config.security_group_ids
#       subnet_ids         = var.vpc_config.subnet_ids

#       dead_letter_config = {
#         target_arn = module.sqs.sqs_queue_arns["deployment_manager_dlq"]
#       }

#       kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

#       layers = [module.lambda_layer.lambda_layer_arns["utils"]]

#       environment_variables = {
#         EVENT_BUS_NAME               = module.event_bus.eventbridge_bus_names["quota_monitor"]
#         EVENT_BUS_ARN                = module.event_bus.eventbridge_bus_arns["quota_monitor"]
#         # TA_STACKSET_ID               = module.base.cloudformation_stackset_ids["ta"]
#         # SQ_STACKSET_ID               = module.base.cloudformation_stackset_ids["sq"]
#         # SNS_STACKSET_ID              = module.base.cloudformation_stackset_ids["sns"]
#         QM_OU_PARAMETER              = module.ssm_parameter.ssm_parameter_names["organizational_units"]
#         QM_ACCOUNT_PARAMETER         = var.enable_account_deploy ? module.ssm_parameter.ssm_parameter_names["target_accounts"] : null
#         DEPLOYMENT_MODEL             = var.deployment_model
#         REGIONS_LIST                 = var.regions_list
#         QM_REGIONS_LIST_PARAMETER    = module.ssm_parameter.ssm_parameter_names["regions_list"]
#         SNS_SPOKE_REGION             = var.sns_spoke_region
#         REGIONS_CONCURRENCY_TYPE     = var.region_concurrency
#         MAX_CONCURRENT_PERCENTAGE    = var.max_concurrent_percentage
#         FAILURE_TOLERANCE_PERCENTAGE = var.failure_tolerance_percentage
#         SQ_NOTIFICATION_THRESHOLD    = var.sq_notification_threshold
#         SQ_MONITORING_FREQUENCY      = var.sq_monitoring_frequency
#         SQ_REPORT_OK_NOTIFICATIONS   = var.sq_report_ok_notifications
#         SOLUTION_UUID                = module.helper_lambda.lambda_function_arns["helper"]
#         METRICS_ENDPOINT             = local.quota_monitor_map.Metrics.MetricsEndpoint
#         SEND_METRIC                  = local.quota_monitor_map.Metrics.SendAnonymizedData
#         LOG_LEVEL                    = "info"
#         CUSTOM_SDK_USER_AGENT        = "AwsSolution/SO0005/v6.3.0"
#         VERSION                      = "v6.3.0"
#         SOLUTION_ID                  = "SO0005"
#       }
#       event_invoke_config = {
#         maximum_event_age_in_seconds = 14400
#         qualifier                    = "$LATEST"
#       }

#       logging_config = {
#         log_format = "JSON"
#         log_group  = "/aws/lambda/Reporter-Lambda"
#         log_level  = "INFO"
#       }

#       tags = {
#         Name = "QuotaMonitor-DeploymentManager"
#       }

#       depends_on = [
#         module.iam.iam_role_arns["reporter"],
#         module.helper_lambda
#       ]
#     }
#   }
# }

module "lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  lambda_functions = {
    provider_framework = {
      name        = var.provider_function_name
      description = var.provider_function_description
      runtime     = var.lambda_runtime
      handler     = var.provider_handler
      timeout     = var.provider_timeout
      memory_size = var.provider_memory_size
      role_arn    = module.iam.iam_role_arns["provider_framework"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      environment_variables = {
        USER_ON_EVENT_FUNCTION_ARN = module.helper_lambda.lambda_function_arns["helper"]
      }

      logging_config = {
        log_format = var.log_format
        log_group  = var.provider_log_group
        log_level  = var.log_level
      }

      tags = {
        Name = var.provider_tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["provider_framework"],
        module.helper_lambda
      ]
    }

    sns_publisher = {
      name        = var.sns_publisher_function_name
      description = var.sns_publisher_function_description
      runtime     = var.lambda_runtime
      handler     = var.lambda_handler
      timeout     = var.sns_publisher_timeout
      memory_size = var.sns_publisher_memory_size
      role_arn    = module.iam.iam_role_arns["sns_publisher"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
      }

      kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
      layers      = [module.lambda_layer.lambda_layer_arns["utils"]]

      environment_variables = {
        QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
        SOLUTION_UUID                           = random_uuid.helper_uuid.result
        METRICS_ENDPOINT                        = local.quota_monitor_map.Metrics.MetricsEndpoint
        SEND_METRIC                             = local.quota_monitor_map.Metrics.SendAnonymizedData
        TOPIC_ARN                               = module.sns.sns_topic_arns["publisher"]
        LOG_LEVEL                               = var.environment_log_level
        CUSTOM_SDK_USER_AGENT                   = var.sdk_user_agent
        VERSION                                 = var.app_version
        SOLUTION_ID                             = var.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.max_event_age
        qualifier                    = var.lambda_qualifier
      }

      logging_config = {
        log_format = var.log_format
        log_group  = var.sns_publisher_log_group
        log_level  = var.log_level
      }

      tags = {
        Name = var.sns_publisher_tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["sns_publisher"],
        module.helper_lambda
      ]
    }

    reporter = {
      name        = var.reporter_function_name
      description = var.reporter_function_description
      runtime     = var.lambda_runtime
      handler     = var.lambda_handler
      timeout     = var.reporter_timeout
      memory_size = var.reporter_memory_size
      role_arn    = module.iam.iam_role_arns["reporter"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["reporter_dlq"]
      }

      kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
      layers      = [module.lambda_layer.lambda_layer_arns["utils"]]

      environment_variables = {
        QUOTA_TABLE           = module.dynamodb.dynamodb_table_ids["quota_monitor"]
        SQS_URL               = module.sqs.sqs_queue_urls["summarizer_event_queue"]
        MAX_MESSAGES          = var.reporter_max_messages
        MAX_LOOPS             = var.reporter_max_loops
        LOG_LEVEL             = var.environment_log_level
        CUSTOM_SDK_USER_AGENT = var.sdk_user_agent
        VERSION               = var.app_version
        SOLUTION_ID           = var.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.max_event_age
        qualifier                    = var.lambda_qualifier
      }

      logging_config = {
        log_format = var.log_format
        log_group  = var.reporter_log_group
        log_level  = var.log_level
      }

      tags = {
        Name = var.reporter_tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["reporter"],
        module.helper_lambda
      ]
    }

    deployment_manager = {
      name        = var.deployment_manager_function_name
      description = var.deployment_manager_function_description
      runtime     = var.lambda_runtime
      handler     = var.lambda_handler
      timeout     = var.deployment_manager_timeout
      memory_size = var.deployment_manager_memory_size
      role_arn    = module.iam.iam_role_arns["reporter"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["deployment_manager_dlq"]
      }

      kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
      layers      = [module.lambda_layer.lambda_layer_arns["utils"]]

      environment_variables = {
        EVENT_BUS_NAME               = module.event_bus.eventbridge_bus_names["quota_monitor"]
        EVENT_BUS_ARN                = module.event_bus.eventbridge_bus_arns["quota_monitor"]
        QM_OU_PARAMETER              = module.ssm_parameter.ssm_parameter_names["organizational_units"]
        QM_ACCOUNT_PARAMETER         = var.enable_account_deploy ? module.ssm_parameter.ssm_parameter_names["target_accounts"] : null
        DEPLOYMENT_MODEL             = var.deployment_model
        REGIONS_LIST                 = var.regions_list
        QM_REGIONS_LIST_PARAMETER    = module.ssm_parameter.ssm_parameter_names["regions_list"]
        SNS_SPOKE_REGION             = var.sns_spoke_region
        REGIONS_CONCURRENCY_TYPE     = var.region_concurrency
        MAX_CONCURRENT_PERCENTAGE    = var.max_concurrent_percentage
        FAILURE_TOLERANCE_PERCENTAGE = var.failure_tolerance_percentage
        SQ_NOTIFICATION_THRESHOLD    = var.sq_notification_threshold
        SQ_MONITORING_FREQUENCY      = var.sq_monitoring_frequency
        SQ_REPORT_OK_NOTIFICATIONS   = var.sq_report_ok_notifications
        SOLUTION_UUID                = module.helper_lambda.lambda_function_arns["helper"]
        METRICS_ENDPOINT             = local.quota_monitor_map.Metrics.MetricsEndpoint
        SEND_METRIC                  = local.quota_monitor_map.Metrics.SendAnonymizedData
        LOG_LEVEL                    = var.environment_log_level
        CUSTOM_SDK_USER_AGENT        = var.sdk_user_agent
        VERSION                      = var.app_version
        SOLUTION_ID                  = var.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.max_event_age
        qualifier                    = var.lambda_qualifier
      }

      logging_config = {
        log_format = var.log_format
        log_group  = var.deployment_manager_log_group
        log_level  = var.log_level
      }

      tags = {
        Name = var.deployment_manager_tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["reporter"],
        module.helper_lambda
      ]
    }
  }
}

# Common Variables
variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_handler" {
  description = "Handler for Lambda functions"
  type        = string
  default     = "index.handler"
}

variable "lambda_s3_bucket" {
  description = "S3 bucket containing Lambda function code"
  type        = string
  default     = "immersionday-aaaa-jjjj"
}

variable "lambda_s3_key" {
  description = "S3 key for Lambda function code"
  type        = string
  default     = "test-aws-myApplication.zip"
}

variable "log_format" {
  description = "Log format for Lambda functions"
  type        = string
  default     = "JSON"
}

variable "log_level" {
  description = "Log level for Lambda functions"
  type        = string
  default     = "INFO"
}

variable "environment_log_level" {
  description = "Log level for Lambda environment variables"
  type        = string
  default     = "info"
}

variable "sdk_user_agent" {
  description = "Custom SDK user agent"
  type        = string
  default     = "AwsSolution/SO0005/v6.3.0"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "v6.3.0"
}

variable "solution_id" {
  description = "Solution ID"
  type        = string
  default     = "SO0005"
}

variable "max_event_age" {
  description = "Maximum event age in seconds"
  type        = number
  default     = 14400
}

variable "lambda_qualifier" {
  description = "Lambda qualifier"
  type        = string
  default     = "$LATEST"
}

# Provider Framework Variables
variable "provider_function_name" {
  description = "Name of the Provider Framework Lambda function"
  type        = string
  default     = "Helper-Provider-Framework"
}

variable "provider_function_description" {
  description = "Description of the Provider Framework Lambda function"
  type        = string
  default     = "AWS CDK resource provider framework - onEvent (quota-monitor-hub/QM-Helper/QM-Helper-Provider)"
}

variable "provider_handler" {
  description = "Handler for Provider Framework Lambda function"
  type        = string
  default     = "framework.onEvent"
}

variable "provider_timeout" {
  description = "Timeout for Provider Framework Lambda function"
  type        = number
  default     = 900
}

variable "provider_memory_size" {
  description = "Memory size for Provider Framework Lambda function"
  type        = number
  default     = 128
}

variable "provider_log_group" {
  description = "Log group for Provider Framework Lambda function"
  type        = string
  default     = "/aws/lambda/Helper-Provider-Framework"
}

variable "provider_tag_name" {
  description = "Name tag for Provider Framework Lambda function"
  type        = string
  default     = "QuotaMonitor-ProviderFramework"
}

# SNS Publisher Variables
variable "sns_publisher_function_name" {
  description = "Name of the SNS Publisher Lambda function"
  type        = string
  default     = "SNSPublisher-Lambda"
}

variable "sns_publisher_function_description" {
  description = "Description of the SNS Publisher Lambda function"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-Lambda"
}

variable "sns_publisher_timeout" {
  description = "Timeout for SNS Publisher Lambda function"
  type        = number
  default     = 60
}

variable "sns_publisher_memory_size" {
  description = "Memory size for SNS Publisher Lambda function"
  type        = number
  default     = 128
}

variable "sns_publisher_log_group" {
  description = "Log group for SNS Publisher Lambda function"
  type        = string
  default     = "/aws/lambda/SNSPublisher-Lambda"
}

variable "sns_publisher_tag_name" {
  description = "Name tag for SNS Publisher Lambda function"
  type        = string
  default     = "QuotaMonitor-SNSPublisher"
}

# Reporter Variables
variable "reporter_function_name" {
  description = "Name of the Reporter Lambda function"
  type        = string
  default     = "Reporter-Lambda"
}

variable "reporter_function_description" {
  description = "Description of the Reporter Lambda function"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
}

variable "reporter_timeout" {
  description = "Timeout for Reporter Lambda function"
  type        = number
  default     = 10
}

variable "reporter_memory_size" {
  description = "Memory size for Reporter Lambda function"
  type        = number
  default     = 512
}

variable "reporter_max_messages" {
  description = "Maximum number of messages for Reporter Lambda function"
  type        = string
  default     = "10"
}

variable "reporter_max_loops" {
  description = "Maximum number of loops for Reporter Lambda function"
  type        = string
  default     = "10"
}

variable "reporter_log_group" {
  description = "Log group for Reporter Lambda function"
  type        = string
  default     = "/aws/lambda/Reporter-Lambda"
}

variable "reporter_tag_name" {
  description = "Name tag for Reporter Lambda function"
  type        = string
  default     = "QuotaMonitor-Reporter"
}

# Deployment Manager Variables
variable "deployment_manager_function_name" {
  description = "Name of the Deployment Manager Lambda function"
  type        = string
  default     = "DeploymentManager-Lambda"
}

variable "deployment_manager_function_description" {
  description = "Description of the Deployment Manager Lambda function"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
}

variable "deployment_manager_timeout" {
  description = "Timeout for Deployment Manager Lambda function"
  type        = number
  default     = 60
}

variable "deployment_manager_memory_size" {
  description = "Memory size for Deployment Manager Lambda function"
  type        = number
  default     = 512
}

variable "deployment_manager_log_group" {
  description = "Log group for Deployment Manager Lambda function"
  type        = string
  default     = "/aws/lambda/Reporter-Lambda"
}

variable "deployment_manager_tag_name" {
  description = "Name tag for Deployment Manager Lambda function"
  type        = string
  default     = "QuotaMonitor-DeploymentManager"
}
module "lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  lambda_functions = {
    provider_framework = {
      name        = var.lambda_functions_config.provider_framework.name
      description = var.lambda_functions_config.provider_framework.description
      runtime     = var.lambda_functions_config.provider_framework.runtime
      handler     = var.lambda_functions_config.provider_framework.handler
      timeout     = var.lambda_functions_config.provider_framework.timeout
      memory_size = var.lambda_functions_config.provider_framework.memory_size
      role_arn    = module.iam.iam_role_arns["provider_framework"]
      s3_bucket   = var.lambda_functions_config.provider_framework.s3_bucket
      s3_key      = var.lambda_functions_config.provider_framework.s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      environment_variables = {
        USER_ON_EVENT_FUNCTION_ARN = module.helper_lambda.lambda_function_arns["helper"]
      }

      logging_config = {
        log_format = var.lambda_functions_config.provider_framework.log_format
        log_group  = var.lambda_functions_config.provider_framework.log_group
        log_level  = var.lambda_functions_config.provider_framework.log_level
      }

      tags = {
        Name = var.lambda_functions_config.provider_framework.tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["provider_framework"],
        module.helper_lambda
      ]
    }

    sns_publisher = {
      name        = var.lambda_functions_config.sns_publisher.name
      description = var.lambda_functions_config.sns_publisher.description
      runtime     = var.lambda_functions_config.sns_publisher.runtime
      handler     = var.lambda_functions_config.sns_publisher.handler
      timeout     = var.lambda_functions_config.sns_publisher.timeout
      memory_size = var.lambda_functions_config.sns_publisher.memory_size
      role_arn    = module.iam.iam_role_arns["sns_publisher"]
      s3_bucket   = var.lambda_functions_config.sns_publisher.s3_bucket
      s3_key      = var.lambda_functions_config.sns_publisher.s3_key

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
        LOG_LEVEL                               = var.lambda_functions_config.sns_publisher.environment_log_level
        CUSTOM_SDK_USER_AGENT                   = var.lambda_functions_config.sns_publisher.sdk_user_agent
        VERSION                                 = var.lambda_functions_config.sns_publisher.app_version
        SOLUTION_ID                             = var.lambda_functions_config.sns_publisher.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config.sns_publisher.max_event_age
        qualifier                    = var.lambda_functions_config.sns_publisher.lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config.sns_publisher.log_format
        log_group  = var.lambda_functions_config.sns_publisher.log_group
        log_level  = var.lambda_functions_config.sns_publisher.log_level
      }

      tags = {
        Name = var.lambda_functions_config.sns_publisher.tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["sns_publisher"],
        module.helper_lambda
      ]
    }

    reporter = {
      name        = var.lambda_functions_config.reporter.name
      description = var.lambda_functions_config.reporter.description
      runtime     = var.lambda_functions_config.reporter.runtime
      handler     = var.lambda_functions_config.reporter.handler
      timeout     = var.lambda_functions_config.reporter.timeout
      memory_size = var.lambda_functions_config.reporter.memory_size
      role_arn    = module.iam.iam_role_arns["reporter"]
      s3_bucket   = var.lambda_functions_config.reporter.s3_bucket
      s3_key      = var.lambda_functions_config.reporter.s3_key

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
        MAX_MESSAGES          = var.lambda_functions_config.reporter.max_messages
        MAX_LOOPS             = var.lambda_functions_config.reporter.max_loops
        LOG_LEVEL             = var.lambda_functions_config.reporter.environment_log_level
        CUSTOM_SDK_USER_AGENT = var.lambda_functions_config.reporter.sdk_user_agent
        VERSION               = var.lambda_functions_config.reporter.app_version
        SOLUTION_ID           = var.lambda_functions_config.reporter.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config.reporter.max_event_age
        qualifier                    = var.lambda_functions_config.reporter.lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config.reporter.log_format
        log_group  = var.lambda_functions_config.reporter.log_group
        log_level  = var.lambda_functions_config.reporter.log_level
      }

      tags = {
        Name = var.lambda_functions_config.reporter.tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["reporter"],
        module.helper_lambda
      ]
    }

    deployment_manager = {
      name        = var.lambda_functions_config.deployment_manager.name
      description = var.lambda_functions_config.deployment_manager.description
      runtime     = var.lambda_functions_config.deployment_manager.runtime
      handler     = var.lambda_functions_config.deployment_manager.handler
      timeout     = var.lambda_functions_config.deployment_manager.timeout
      memory_size = var.lambda_functions_config.deployment_manager.memory_size
      role_arn    = module.iam.iam_role_arns["deployment_manager"]
      s3_bucket   = var.lambda_functions_config.deployment_manager.s3_bucket
      s3_key      = var.lambda_functions_config.deployment_manager.s3_key

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
        LOG_LEVEL                    = var.lambda_functions_config.deployment_manager.environment_log_level
        CUSTOM_SDK_USER_AGENT        = var.lambda_functions_config.deployment_manager.sdk_user_agent
        VERSION                      = var.lambda_functions_config.deployment_manager.app_version
        SOLUTION_ID                  = var.lambda_functions_config.deployment_manager.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config.deployment_manager.max_event_age
        qualifier                    = var.lambda_functions_config.deployment_manager.lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config.deployment_manager.log_format
        log_group  = var.lambda_functions_config.deployment_manager.log_group
        log_level  = var.lambda_functions_config.deployment_manager.log_level
      }

      tags = {
        Name = var.lambda_functions_config.deployment_manager.tag_name
      }

      depends_on = [
        module.iam.iam_role_arns["deployment_manager"],
        module.helper_lambda
      ]
    }
  }
}

variable "lambda_functions_config" {
  description = "Configuration for all Lambda functions"
  type = map(object({
    name                  = string
    description           = string
    runtime               = string
    handler               = string
    timeout               = number
    memory_size           = number
    s3_bucket             = string
    s3_key                = string
    log_format            = string
    log_group             = string
    log_level             = string
    tag_name              = string
    environment_log_level = optional(string)
    sdk_user_agent        = optional(string)
    app_version           = optional(string)
    solution_id           = optional(string)
    max_event_age         = optional(number)
    lambda_qualifier      = optional(string)
    max_messages          = optional(string)
    max_loops             = optional(string)
  }))
  default = {
    provider_framework = {
      name        = "Helper-Provider-Framework"
      description = "AWS CDK resource provider framework - onEvent (quota-monitor-hub/QM-Helper/QM-Helper-Provider)"
      runtime     = "nodejs18.x"
      handler     = "framework.onEvent"
      timeout     = 900
      memory_size = 128
      s3_bucket   = "immersionday-aaaa-jjjj"
      s3_key      = "test-aws-myApplication.zip"
      log_format  = "JSON"
      log_group   = "/aws/lambda/Helper-Provider-Framework"
      log_level   = "INFO"
      tag_name    = "QuotaMonitor-ProviderFramework"
    }
    sns_publisher = {
      name                  = "SNSPublisher-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 60
      memory_size           = 128
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/SNSPublisher-Lambda"
      log_level             = "INFO"
      tag_name              = "QuotaMonitor-SNSPublisher"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
    }
    reporter = {
      name                  = "Reporter-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 10
      memory_size           = 512
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/Reporter-Lambda"
      log_level             = "INFO"
      tag_name              = "QuotaMonitor-Reporter"
      max_messages          = "10"
      max_loops             = "10"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
    }
    deployment_manager = {
      name                  = "DeploymentManager-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 60
      memory_size           = 512
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/DeploymentManager-Lambda"
      log_level             = "INFO"
      tag_name              = "QuotaMonitor-DeploymentManager"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
    }
  }
}
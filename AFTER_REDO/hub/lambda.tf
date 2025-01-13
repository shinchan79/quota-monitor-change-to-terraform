module "lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  lambda_functions = {
    provider_framework = {
      name        = "Helper-Provider-Framework"
      description = "AWS CDK resource provider framework - onEvent (quota-monitor-hub/QM-Helper/QM-Helper-Provider)"
      runtime     = "nodejs18.x"
      handler     = "framework.onEvent"
      timeout     = 900
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["provider_framework"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      environment_variables = {
        USER_ON_EVENT_FUNCTION_ARN = module.helper_lambda.lambda_function_arns["helper"]
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/Helper-Provider-Framework"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-ProviderFramework"
      }

      depends_on = [
        module.iam.iam_role_arns["provider_framework"],
        module.helper_lambda
      ]
    }

    sns_publisher = {
      name        = "SNSPublisher-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 60
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["sns_publisher"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
      }

      kms_key_arn = module.kms.kms_key_arns["qm_encryption"]
      layers      = [module.lambda_layer.lambda_layer_arns["utils"]]

      environment_variables = {
        QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
        # SOLUTION_UUID                           = module.helper_lambda.lambda_function_arns["helper"]
        SOLUTION_UUID                           = random_uuid.helper_uuid.result # Cần check xem có cần không, custom resource này để làm gì
        METRICS_ENDPOINT                        = local.quota_monitor_map.Metrics.MetricsEndpoint
        SEND_METRIC                             = local.quota_monitor_map.Metrics.SendAnonymizedData
        TOPIC_ARN                               = module.sns.sns_topic_arns["publisher"]
        LOG_LEVEL                               = "info"
        CUSTOM_SDK_USER_AGENT                   = "AwsSolution/SO0005/v6.3.0"
        VERSION                                 = "v6.3.0"
        SOLUTION_ID                             = "SO0005"
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/SNSPublisher-Lambda"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-SNSPublisher"
      }

      depends_on = [
        module.iam.iam_role_arns["sns_publisher"],
        module.helper_lambda
      ]
    }

    reporter = {
      name        = "Reporter-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 10
      memory_size = 512
      role_arn    = module.iam.iam_role_arns["reporter"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["reporter_dlq"]
      }

      kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

      layers = [
        module.lambda_layer.lambda_layer_arns["utils"]
      ]

      environment_variables = {
        QUOTA_TABLE           = module.dynamodb.dynamodb_table_ids["quota_monitor"]
        SQS_URL               = module.sqs.sqs_queue_urls["summarizer_event_queue"]
        MAX_MESSAGES          = "10"
        MAX_LOOPS             = "10"
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
        log_group  = "/aws/lambda/Reporter-Lambda"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-Reporter"
      }

      depends_on = [
        module.iam.iam_role_arns["reporter"],
        module.helper_lambda
      ]
    }

    deployment_manager = {
      name        = "DeploymentManager-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 60
      memory_size = 512
      role_arn    = module.iam.iam_role_arns["reporter"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["deployment_manager_dlq"]
      }

      kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

      layers = [module.lambda_layer.lambda_layer_arns["utils"]]

      environment_variables = {
        EVENT_BUS_NAME               = module.event_bus.eventbridge_bus_names["quota_monitor"]
        EVENT_BUS_ARN                = module.event_bus.eventbridge_bus_arns["quota_monitor"]
        # TA_STACKSET_ID               = module.base.cloudformation_stackset_ids["ta"]
        # SQ_STACKSET_ID               = module.base.cloudformation_stackset_ids["sq"]
        # SNS_STACKSET_ID              = module.base.cloudformation_stackset_ids["sns"]
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
        LOG_LEVEL                    = "info"
        CUSTOM_SDK_USER_AGENT        = "AwsSolution/SO0005/v6.3.0"
        VERSION                      = "v6.3.0"
        SOLUTION_ID                  = "SO0005"
      }
      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/Reporter-Lambda"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-DeploymentManager"
      }

      depends_on = [
        module.iam.iam_role_arns["reporter"],
        module.helper_lambda
      ]
    }
  }
}
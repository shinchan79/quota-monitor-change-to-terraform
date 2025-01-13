module "lambda" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  # Explicit dependency on IAM module to prevent circular dependencies
  depends_on = [module.iam]

  lambda_functions = {
    ################# SNS Spoke
    sns_publisher = {
      name        = "SNSPublisher-Lambda"
      description = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 60
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["sns_publisher_lambda"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
      }

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_sns_spoke"]
      ]

      environment_variables = {
        QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
        SEND_METRIC                            = "No"
        TOPIC_ARN                              = module.sns.sns_topic_arns["sns_publisher"] 
        LOG_LEVEL                              = "info"
        CUSTOM_SDK_USER_AGENT                  = "AwsSolution/SO0005/v6.3.0"
        VERSION                                = "v6.3.0"
        SOLUTION_ID                            = "SO0005"
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      tags = {
        Name = "QuotaMonitor-SNSPublisher"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/SNSPublisher-Lambda"
        log_level  = "INFO"
      }
    }

    ################# QM Spoke
    list_manager = {
      name        = "ListManager-Function"
      description = "SO0005 quota-monitor-for-aws - QM-ListManager-Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 900
      memory_size = 256
      role_arn    = module.iam.iam_role_arns["list_manager"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_sns_spoke"]
      ]

      environment_variables = {
        SQ_SERVICE_TABLE      = module.dynamodb.dynamodb_table_ids["service"]
        SQ_QUOTA_TABLE        = module.dynamodb.dynamodb_table_ids["quota"]
        PARTITION_KEY         = "ServiceCode"
        SORT                  = "QuotaCode"
        LOG_LEVEL            = "info"
        CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0005/v6.3.0"
        VERSION              = "v6.3.0"
        SOLUTION_ID          = "SO0005"
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/ListManager-Function"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-ListManager"
      }
    }

    list_manager_provider = {
      name        = "ListManager-Provider-Framework"
      description = "AWS CDK resource provider framework - onEvent (quota-monitor-sq-spoke/QM-ListManager/QM-ListManager-Provider)"
      runtime     = "nodejs18.x"
      handler     = "framework.onEvent"
      timeout     = 900
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["list_manager_provider"]
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      environment_variables = {
        USER_ON_EVENT_FUNCTION_ARN = local.list_manager_function_arn
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/ListManager-Provider-Framework"
        log_level  = "INFO"
      }

      tags = {
        Name = "QuotaMonitor-ListManagerProvider"
      }
    }

    qmcw_poller = {
      name        = "QMCWPoller-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-CWPoller-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 900
      memory_size = 512
      role_arn    = module.iam.iam_role_arns["qmcw_poller_lambda"]

      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmcw_poller_dlq"]
      }

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_sq_spoke"]
      ]

      environment_variables = {
        SQ_SERVICE_TABLE            = module.dynamodb.dynamodb_table_ids["service"]
        SQ_QUOTA_TABLE             = module.dynamodb.dynamodb_table_ids["quota"]
        SPOKE_EVENT_BUS            = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
        POLLER_FREQUENCY           = var.monitoring_frequency
        THRESHOLD                  = var.notification_threshold
        SQ_REPORT_OK_NOTIFICATIONS = var.report_ok_notifications
        LOG_LEVEL                  = "info"
        CUSTOM_SDK_USER_AGENT      = "AwsSolution/SO0005/v6.3.0"
        VERSION                    = "v6.3.0"
        SOLUTION_ID               = "SO0005"
      }

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/QMCWPoller-Lambda"
        log_level  = "INFO"
      }

      tags = {
        Name = "QMCWPoller-Lambda"
      }
    }

    ################# TA Spoke 
    ta_refresher = {
      name        = "QM-TA-Refresher-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-Lambda" 
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 60
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["qm_ta_refresher_lambda_service_role"]
      
      s3_bucket   = "immersionday-aaaa-jjjj" # s3://immersionday-aaaa-jjjj/test-aws-myApplication.zip
      s3_key      = "test-aws-myApplication.zip"

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmta_refresher_dlq"]
      }

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_ta"]
      ]

      environment_variables = {
        AWS_SERVICES          = "AutoScaling,CloudFormation,DynamoDB,EBS,EC2,ELB,IAM,Kinesis,RDS,Route53,SES,VPC"
        LOG_LEVEL            = "info"
        CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0005/v6.3.0"
        VERSION              = "v6.3.0"
        SOLUTION_ID          = "SO0005"
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/QM-TA-Refresher-Lambda"
        log_level  = "INFO"
      }

      tags = {
        Name = "QM-TA-Refresher-Lambda"
      }
    }

  }
}

# Local values to break circular dependencies  
locals {
  list_manager_function_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:ListManager-Function"
}
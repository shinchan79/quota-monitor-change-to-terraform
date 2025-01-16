module "lambda" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  depends_on = [module.iam]

  lambda_functions = {
    sns_publisher = {
      name        = var.lambda_functions_config["sns_publisher"].name
      description = var.lambda_functions_config["sns_publisher"].description
      runtime     = var.lambda_functions_config["sns_publisher"].runtime
      handler     = var.lambda_functions_config["sns_publisher"].handler
      timeout     = var.lambda_functions_config["sns_publisher"].timeout
      memory_size = var.lambda_functions_config["sns_publisher"].memory_size
      role_arn    = module.iam.iam_role_arns["sns_publisher_lambda"]
      s3_bucket   = var.lambda_functions_config["sns_publisher"].s3_bucket
      s3_key      = var.lambda_functions_config["sns_publisher"].s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
      }

      layers = [module.lambda_layer.lambda_layer_arns["utils_sns_spoke"]]

      environment_variables = {
        QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
        SEND_METRIC                             = var.send_metric
        TOPIC_ARN                               = var.create_sns ? module.sns.sns_topic_arns["sns_publisher"] : var.existing_sns_topic_arn
        LOG_LEVEL                               = var.lambda_functions_config["sns_publisher"].environment_log_level
        CUSTOM_SDK_USER_AGENT                   = var.lambda_functions_config["sns_publisher"].sdk_user_agent
        VERSION                                 = var.lambda_functions_config["sns_publisher"].app_version
        SOLUTION_ID                             = var.lambda_functions_config["sns_publisher"].solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config["sns_publisher"].max_event_age
        qualifier                    = var.lambda_functions_config["sns_publisher"].lambda_qualifier
      }

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      logging_config = {
        log_format = var.lambda_functions_config["sns_publisher"].log_format
        log_group  = var.lambda_functions_config["sns_publisher"].log_group
        log_level  = var.lambda_functions_config["sns_publisher"].log_level
      }

      tags = merge(
        {
          Name = var.lambda_functions_config["sns_publisher"].name
        },
        try(var.lambda_functions_config["sns_publisher"].tags, {}),
        var.tags
      )
    }

    list_manager = {
      name        = var.lambda_functions_config["list_manager"].name
      description = var.lambda_functions_config["list_manager"].description
      runtime     = var.lambda_functions_config["list_manager"].runtime
      handler     = var.lambda_functions_config["list_manager"].handler
      timeout     = var.lambda_functions_config["list_manager"].timeout
      memory_size = var.lambda_functions_config["list_manager"].memory_size
      role_arn    = module.iam.iam_role_arns["list_manager"]
      s3_bucket   = var.lambda_functions_config["list_manager"].s3_bucket
      s3_key      = var.lambda_functions_config["list_manager"].s3_key

      layers = [module.lambda_layer.lambda_layer_arns["utils_sq_spoke"]]

      environment_variables = {
        SQ_SERVICE_TABLE      = module.dynamodb.dynamodb_table_ids["service"]
        SQ_QUOTA_TABLE        = module.dynamodb.dynamodb_table_ids["quota"]
        PARTITION_KEY         = var.partition_key
        SORT                  = var.sort_key
        LOG_LEVEL             = var.lambda_functions_config["list_manager"].environment_log_level
        CUSTOM_SDK_USER_AGENT = var.lambda_functions_config["list_manager"].sdk_user_agent
        VERSION               = var.lambda_functions_config["list_manager"].app_version
        SOLUTION_ID           = var.lambda_functions_config["list_manager"].solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config["list_manager"].max_event_age
        qualifier                    = var.lambda_functions_config["list_manager"].lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config["list_manager"].log_format
        log_group  = var.lambda_functions_config["list_manager"].log_group
        log_level  = var.lambda_functions_config["list_manager"].log_level
      }

      tags = merge(
        {
          Name = var.lambda_functions_config["list_manager"].name
        },
        try(var.lambda_functions_config["list_manager"].tags, {}),
        var.tags
      )
    }

    list_manager_provider = {
      name        = var.lambda_functions_config["list_manager_provider"].name
      description = var.lambda_functions_config["list_manager_provider"].description
      runtime     = var.lambda_functions_config["list_manager_provider"].runtime
      handler     = var.lambda_functions_config["list_manager_provider"].handler
      timeout     = var.lambda_functions_config["list_manager_provider"].timeout
      memory_size = var.lambda_functions_config["list_manager_provider"].memory_size
      role_arn    = module.iam.iam_role_arns["list_manager_provider"]
      s3_bucket   = var.lambda_functions_config["list_manager_provider"].s3_bucket
      s3_key      = var.lambda_functions_config["list_manager_provider"].s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      environment_variables = {
        USER_ON_EVENT_FUNCTION_ARN = local.list_manager_function_arn
      }

      logging_config = {
        log_format = var.lambda_functions_config["list_manager_provider"].log_format
        log_group  = var.lambda_functions_config["list_manager_provider"].log_group
        log_level  = var.lambda_functions_config["list_manager_provider"].log_level
      }

      tags = merge(
        {
          Name = var.lambda_functions_config["list_manager_provider"].name
        },
        try(var.lambda_functions_config["list_manager_provider"].tags, {}),
        var.tags
      )
    }

    qmcw_poller = {
      name        = var.lambda_functions_config["qmcw_poller"].name
      description = var.lambda_functions_config["qmcw_poller"].description
      runtime     = var.lambda_functions_config["qmcw_poller"].runtime
      handler     = var.lambda_functions_config["qmcw_poller"].handler
      timeout     = var.lambda_functions_config["qmcw_poller"].timeout
      memory_size = var.lambda_functions_config["qmcw_poller"].memory_size
      role_arn    = module.iam.iam_role_arns["qmcw_poller_lambda"]
      s3_bucket   = var.lambda_functions_config["qmcw_poller"].s3_bucket
      s3_key      = var.lambda_functions_config["qmcw_poller"].s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmcw_poller_dlq"]
      }

      layers = [module.lambda_layer.lambda_layer_arns["utils_sq_spoke"]]

      environment_variables = {
        SQ_SERVICE_TABLE           = module.dynamodb.dynamodb_table_ids["service"]
        SQ_QUOTA_TABLE             = module.dynamodb.dynamodb_table_ids["quota"]
        SPOKE_EVENT_BUS            = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
        POLLER_FREQUENCY           = var.monitoring_frequency
        THRESHOLD                  = var.notification_threshold
        SQ_REPORT_OK_NOTIFICATIONS = var.report_ok_notifications
        LOG_LEVEL                  = var.lambda_functions_config["qmcw_poller"].environment_log_level
        CUSTOM_SDK_USER_AGENT      = var.lambda_functions_config["qmcw_poller"].sdk_user_agent
        VERSION                    = var.lambda_functions_config["qmcw_poller"].app_version
        SOLUTION_ID                = var.lambda_functions_config["qmcw_poller"].solution_id
      }

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config["qmcw_poller"].max_event_age
        qualifier                    = var.lambda_functions_config["qmcw_poller"].lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config["qmcw_poller"].log_format
        log_group  = var.lambda_functions_config["qmcw_poller"].log_group
        log_level  = var.lambda_functions_config["qmcw_poller"].log_level
      }

      tags = merge(
        {
          Name = var.lambda_functions_config["qmcw_poller"].name
        },
        try(var.lambda_functions_config["qmcw_poller"].tags, {}),
        var.tags
      )
    }

    ta_refresher = {
      name        = var.lambda_functions_config["ta_refresher"].name
      description = var.lambda_functions_config["ta_refresher"].description
      runtime     = var.lambda_functions_config["ta_refresher"].runtime
      handler     = var.lambda_functions_config["ta_refresher"].handler
      timeout     = var.lambda_functions_config["ta_refresher"].timeout
      memory_size = var.lambda_functions_config["ta_refresher"].memory_size
      role_arn    = module.iam.iam_role_arns["qm_ta_refresher_lambda_service_role"]
      s3_bucket   = var.lambda_functions_config["ta_refresher"].s3_bucket
      s3_key      = var.lambda_functions_config["ta_refresher"].s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmta_refresher_dlq"]
      }

      layers = [module.lambda_layer.lambda_layer_arns["utils_ta"]]

      environment_variables = {
        AWS_SERVICES          = var.aws_services
        LOG_LEVEL             = var.lambda_functions_config["ta_refresher"].environment_log_level
        CUSTOM_SDK_USER_AGENT = var.lambda_functions_config["ta_refresher"].sdk_user_agent
        VERSION               = var.lambda_functions_config["ta_refresher"].app_version
        SOLUTION_ID           = var.lambda_functions_config["ta_refresher"].solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config["ta_refresher"].max_event_age
        qualifier                    = var.lambda_functions_config["ta_refresher"].lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config["ta_refresher"].log_format
        log_group  = var.lambda_functions_config["ta_refresher"].log_group
        log_level  = var.lambda_functions_config["ta_refresher"].log_level
      }

      tags = merge(
        {
          Name = var.lambda_functions_config["ta_refresher"].name
        },
        try(var.lambda_functions_config["ta_refresher"].tags, {}),
        var.tags
      )
    }
  }
}
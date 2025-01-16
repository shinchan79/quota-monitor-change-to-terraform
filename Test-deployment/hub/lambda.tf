# Create archive files if needed
data "archive_file" "lambda" {
  for_each = var.create_archive && local.create_hub_resources ? {
    for k, v in var.lambda_functions_config : k => v
    if lookup(v, "source_dir", null) != null
  } : {}

  type        = "zip"
  source_file = format("${path.module}/%s/%s.py", each.value.source_dir, each.key)
  output_path = "${path.module}/archive_file/${each.key}.zip"
}

# Create main lambda functions
module "lambda" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  lambda_functions = {
    provider_framework = merge(
      {
        name        = var.lambda_functions_config["provider_framework"].name
        description = var.lambda_functions_config["provider_framework"].description
        runtime     = var.lambda_functions_config["provider_framework"].runtime
        handler     = var.lambda_functions_config["provider_framework"].handler
        timeout     = var.lambda_functions_config["provider_framework"].timeout
        memory_size = var.lambda_functions_config["provider_framework"].memory_size
        role_arn    = module.iam.iam_role_arns["provider_framework"]
      },
      local.lambda_source["provider_framework"],
      {
        security_group_ids = var.vpc_config.security_group_ids
        subnet_ids         = var.vpc_config.subnet_ids
        environment_variables = {
          USER_ON_EVENT_FUNCTION_ARN = module.helper_lambda.lambda_function_arns["helper"]
        }
        logging_config = {
          log_format = var.lambda_functions_config["provider_framework"].log_format
          log_group  = var.lambda_functions_config["provider_framework"].log_group
          log_level  = var.lambda_functions_config["provider_framework"].log_level
        }
        tags = merge(
          {
            Name = var.lambda_functions_config["provider_framework"].name
          },
          try(var.lambda_functions_config["provider_framework"].tags, {}),
          local.merged_tags
        )
      }
    )

    sns_publisher = merge(
      {
        name        = var.lambda_functions_config["sns_publisher"].name
        description = var.lambda_functions_config["sns_publisher"].description
        runtime     = var.lambda_functions_config["sns_publisher"].runtime
        handler     = var.lambda_functions_config["sns_publisher"].handler
        timeout     = var.lambda_functions_config["sns_publisher"].timeout
        memory_size = var.lambda_functions_config["sns_publisher"].memory_size
        role_arn    = module.iam.iam_role_arns["sns_publisher"]
      },
      local.lambda_source["sns_publisher"],
      {
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
          LOG_LEVEL                               = var.lambda_functions_config["sns_publisher"].environment_log_level
          CUSTOM_SDK_USER_AGENT                   = var.lambda_functions_config["sns_publisher"].sdk_user_agent
          VERSION                                 = var.lambda_functions_config["sns_publisher"].app_version
          SOLUTION_ID                             = var.lambda_functions_config["sns_publisher"].solution_id
        }

        event_invoke_config = {
          maximum_event_age_in_seconds = var.lambda_functions_config["sns_publisher"].max_event_age
          qualifier                    = var.lambda_functions_config["sns_publisher"].lambda_qualifier
        }

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
          local.merged_tags
        )
      }
    )

    reporter = merge(
      {
        name        = var.lambda_functions_config["reporter"].name
        description = var.lambda_functions_config["reporter"].description
        runtime     = var.lambda_functions_config["reporter"].runtime
        handler     = var.lambda_functions_config["reporter"].handler
        timeout     = var.lambda_functions_config["reporter"].timeout
        memory_size = var.lambda_functions_config["reporter"].memory_size
        role_arn    = module.iam.iam_role_arns["reporter"]
      },
      local.lambda_source["reporter"],
      {
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
          MAX_MESSAGES          = var.lambda_functions_config["reporter"].max_messages
          MAX_LOOPS             = var.lambda_functions_config["reporter"].max_loops
          LOG_LEVEL             = var.lambda_functions_config["reporter"].environment_log_level
          CUSTOM_SDK_USER_AGENT = var.lambda_functions_config["reporter"].sdk_user_agent
          VERSION               = var.lambda_functions_config["reporter"].app_version
          SOLUTION_ID           = var.lambda_functions_config["reporter"].solution_id
        }

        event_invoke_config = {
          maximum_event_age_in_seconds = var.lambda_functions_config["reporter"].max_event_age
          qualifier                    = var.lambda_functions_config["reporter"].lambda_qualifier
        }

        logging_config = {
          log_format = var.lambda_functions_config["reporter"].log_format
          log_group  = var.lambda_functions_config["reporter"].log_group
          log_level  = var.lambda_functions_config["reporter"].log_level
        }

        tags = merge(
          {
            Name = var.lambda_functions_config["reporter"].name
          },
          try(var.lambda_functions_config["reporter"].tags, {}),
          local.merged_tags
        )
      }
    )
  }

  depends_on = [
    module.helper_lambda,
    module.iam,
    module.sqs,
    module.kms,
    module.lambda_layer,
    module.ssm_parameter,
    module.sns,
    module.dynamodb
  ]
}
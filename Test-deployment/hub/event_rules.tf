module "event_rule" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  event_rules = {
    sns_publisher = {
      name           = var.event_rules_config["sns_publisher"].name
      description    = var.event_rules_config["sns_publisher"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = var.event_rules_config["sns_publisher"].status
        }
        "detail-type" = var.event_rules_config["sns_publisher"].detail_type_notifications
        source        = var.event_rules_config["sns_publisher"].event_sources
      })

      targets = [
        {
          arn = module.lambda.lambda_function_arns["sns_publisher"]
          id  = var.event_rules_config["sns_publisher"].target_id
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["sns_publisher"].name
        },
        var.event_rules_config["sns_publisher"].tags,
        local.merged_tags
      )

      depends_on = [module.lambda.lambda_function_arns["sns_publisher"]]
    }

    summarizer_event_queue = {
      name           = var.event_rules_config["summarizer"].name
      description    = var.event_rules_config["summarizer"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = var.event_rules_config["summarizer"].status
        }
        "detail-type" = var.event_rules_config["summarizer"].detail_type_notifications
        source        = var.event_rules_config["summarizer"].event_sources
      })

      targets = [
        {
          arn = module.sqs.sqs_queue_arns["summarizer_event_queue"]
          id  = var.event_rules_config["summarizer"].target_id
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["summarizer"].name
        },
        var.event_rules_config["summarizer"].tags,
        local.merged_tags
      )

      depends_on = [module.sqs.sqs_queue_arns["summarizer_event_queue"]]
    }

    reporter = {
      name                = var.event_rules_config["reporter"].name
      description         = var.event_rules_config["reporter"].description
      schedule_expression = var.event_rules_config["reporter"].schedule
      state               = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["reporter"]
          id  = var.event_rules_config["reporter"].target_id
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["reporter"].name
        },
        var.event_rules_config["reporter"].tags,
        local.merged_tags
      )

      depends_on = [module.lambda.lambda_function_arns["reporter"]]
    }

    # Không deploy những gì liên quan stackset
    # deployment_manager = {
    #   name        = var.event_rules_config["deployment_manager"].name
    #   description = var.event_rules_config["deployment_manager"].description
    #   state       = "ENABLED"

    #   event_pattern = jsonencode({
    #     "detail-type" = ["Parameter Store Change"]
    #     source        = ["aws.ssm"]
    #     resources = [
    #       "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["organizational_units"]}",
    #       var.enable_account_deploy ? "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["target_accounts"]}" : null,
    #       "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["regions_list"]}"
    #     ]
    #   })

    #   targets = [
    #     {
    #       arn = module.lambda.lambda_function_arns["deployment_manager"]
    #       id  = var.event_rules_config["deployment_manager"].target_id
    #     }
    #   ]

    #   tags = merge(
    #     {
    #       Name = var.event_rules_config["deployment_manager"].name
    #     },
    #     var.event_rules_config["deployment_manager"].tags,
    #     local.merged_tags
    #   )

    #   depends_on = [module.lambda.lambda_function_arns["deployment_manager"]]
    # }
  }
}

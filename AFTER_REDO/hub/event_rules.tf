module "event_rule" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  event_rules = {
    sns_publisher = {
      name          = "SNSPublisher-EventsRule"
      description   = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state         = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = ["WARN", "ERROR"]
        }
        "detail-type" = [
          "Trusted Advisor Check Item Refresh Notification",
          "Service Quotas Utilization Notification"
        ]
        source = [
          "aws.trustedadvisor",
          "aws-solutions.quota-monitor"
        ]
      })

      targets = [
        {
          arn = module.lambda.lambda_function_arns["sns_publisher"]
          id  = "Target0"
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["sns_publisher"]]
    }

    summarizer_event_queue = {
      name          = "Summarizer-EventQueue-Rule"
      description   = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state         = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = ["OK", "WARN", "ERROR"]
        }
        "detail-type" = [
          "Trusted Advisor Check Item Refresh Notification",
          "Service Quotas Utilization Notification"
        ]
        source = [
          "aws.trustedadvisor",
          "aws-solutions.quota-monitor"
        ]
      })

      targets = [
        {
          arn = module.sqs.sqs_queue_arns["summarizer_event_queue"]
          id  = "Target0"
        }
      ]

      depends_on = [module.sqs.sqs_queue_arns["summarizer_event_queue"]]
    }
    reporter = {
      name                = "Reporter-EventsRule"
      description         = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
      schedule_expression = "rate(5 minutes)"
      state               = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["reporter"]
          id  = "Target0"
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["reporter"]]
    }

    deployment_manager = {
      name        = "Deployment-Manager-EventsRule"
      description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
      state       = "ENABLED"

      event_pattern = jsonencode({
        "detail-type" = ["Parameter Store Change"]
        source        = ["aws.ssm"]
        resources = [
          "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["organizational_units"]}",
          var.enable_account_deploy ? "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["target_accounts"]}" : null,
          "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["regions_list"]}"
        ]
      })

      targets = [
        {
          arn = module.lambda.lambda_function_arns["deployment_manager"]
          id  = "Target0"
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["deployment_manager"]]
    }
  }
}
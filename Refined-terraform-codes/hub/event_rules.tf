module "event_rule" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  event_rules = {
    sns_publisher = {
      name           = var.event_rules_config.sns_publisher.name
      description    = var.event_rules_config.sns_publisher.description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = var.event_rules_config.common.status_warn_error
        }
        "detail-type" = var.event_rules_config.common.detail_type_notifications
        source        = var.event_rules_config.common.event_sources
      })

      targets = [
        {
          arn = module.lambda.lambda_function_arns["sns_publisher"]
          id  = var.event_rules_config.common.target_id
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["sns_publisher"]]
    }

    summarizer_event_queue = {
      name           = var.event_rules_config.summarizer.name
      description    = var.event_rules_config.summarizer.description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = var.event_rules_config.common.status_all
        }
        "detail-type" = var.event_rules_config.common.detail_type_notifications
        source        = var.event_rules_config.common.event_sources
      })

      targets = [
        {
          arn = module.sqs.sqs_queue_arns["summarizer_event_queue"]
          id  = var.event_rules_config.common.target_id
        }
      ]

      depends_on = [module.sqs.sqs_queue_arns["summarizer_event_queue"]]
    }

    reporter = {
      name                = var.event_rules_config.reporter.name
      description         = var.event_rules_config.reporter.description
      schedule_expression = var.event_rules_config.reporter.schedule
      state               = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["reporter"]
          id  = var.event_rules_config.common.target_id
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["reporter"]]
    }

    deployment_manager = {
      name        = var.event_rules_config.deployment_manager.name
      description = var.event_rules_config.deployment_manager.description
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
          id  = var.event_rules_config.common.target_id
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["deployment_manager"]]
    }
  }
}

variable "event_rules_config" {
  description = "Configuration for EventBridge rules"
  type = object({
    sns_publisher = object({
      name        = string
      description = string
    })
    summarizer = object({
      name        = string
      description = string
    })
    reporter = object({
      name        = string
      description = string
      schedule    = string
    })
    deployment_manager = object({
      name        = string
      description = string
    })
    common = object({
      target_id                 = string
      status_warn_error         = list(string)
      status_all                = list(string)
      detail_type_notifications = list(string)
      event_sources             = list(string)
    })
  })
  default = {
    sns_publisher = {
      name        = "SNSPublisher-EventsRule"
      description = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
    }
    summarizer = {
      name        = "Summarizer-EventQueue-Rule"
      description = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
    }
    reporter = {
      name        = "Reporter-EventsRule"
      description = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
      schedule    = "rate(5 minutes)"
    }
    deployment_manager = {
      name        = "Deployment-Manager-EventsRule"
      description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
    }
    common = {
      target_id                 = "Target0"
      status_warn_error         = ["WARN", "ERROR"]
      status_all                = ["OK", "WARN", "ERROR"]
      detail_type_notifications = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
      event_sources             = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
    }
  }
}
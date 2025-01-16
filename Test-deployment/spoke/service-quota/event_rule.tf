module "event_rule" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  event_rules = {
    sns_publisher = {
      name           = var.event_rules_config["sns_publisher"].name
      description    = var.event_rules_config["sns_publisher"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["sns_spoke"]
      state          = "ENABLED"

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

      tags = merge(
        {
          Name = var.event_rules_config["sns_publisher"].name
        },
        local.merged_tags
      )
    }

    list_manager = {
      name                = var.event_rules_config["list_manager"].name
      description         = var.event_rules_config["list_manager"].description
      schedule_expression = "rate(30 days)"
      state               = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["list_manager"]
          id  = "Target0"
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["list_manager"].name
        },
        local.merged_tags
      )
    }

    qmcw_poller = {
      name                = var.event_rules_config["cw_poller"].name
      description         = var.event_rules_config["cw_poller"].description
      schedule_expression = "rate(5 minutes)"
      state               = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["qmcw_poller"]
          id  = "Target0"
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["cw_poller"].name
        },
        local.merged_tags
      )
    }

    utilization_ok = {
      name           = var.event_rules_config["utilization_ok"].name
      description    = var.event_rules_config["utilization_ok"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = ["OK"]
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
          arn      = var.event_bus_arn
          id       = "Target0"
          role_arn = module.iam.iam_role_arns["utilization_ok_events"]
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["utilization_ok"].name
        },
        local.merged_tags
      )
    }

    utilization_warn = {
      name           = var.event_rules_config["utilization_warn"].name
      description    = var.event_rules_config["utilization_warn"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = ["WARN"]
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
          arn      = var.event_bus_arn
          id       = "Target0"
          role_arn = module.iam.iam_role_arns["utilization_warn_events"]
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["utilization_warn"].name
        },
        local.merged_tags
      )
    }

    utilization_error = {
      name           = var.event_rules_config["utilization_error"].name
      description    = var.event_rules_config["utilization_error"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = ["ERROR"]
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
          arn      = var.event_bus_arn
          id       = "Target0"
          role_arn = module.iam.iam_role_arns["utilization_error_events"]
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["utilization_error"].name
        },
        local.merged_tags
      )
    }

    spoke_sns = {
      name           = var.event_rules_config["spoke_sns"].name
      description    = var.event_rules_config["spoke_sns"].description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state          = "ENABLED"

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
          arn      = module.event_bus.eventbridge_bus_arns["sns_spoke"]
          id       = "Target0"
          role_arn = module.iam.iam_role_arns["spoke_sns_events"]
        }
      ]

      tags = merge(
        {
          Name = var.event_rules_config["spoke_sns"].name
        },
        local.merged_tags
      )
    }
  }

  depends_on = [
    module.lambda,
    module.event_bus,
    module.iam
  ]
}
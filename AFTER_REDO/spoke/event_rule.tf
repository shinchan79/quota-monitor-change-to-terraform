module "event_rule" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  event_rules = {
    ################# SNS Spoke
    sns_publisher = {
      name          = "SNSPublisher-EventsRule"
      description   = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-EventsRule"
      event_bus_name = module.event_bus.eventbridge_bus_names["sns_spoke"] # Reference to the SNS spoke bus
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

    ################# QM Spoke
    list_manager = {
      name        = "ListManager-Schedule"
      description = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      schedule_expression = "rate(30 days)"
      state       = "ENABLED"
      targets = [
        {
          arn = module.lambda.lambda_function_arns["list_manager"]
          id  = "Target0"
        }
      ]
      depends_on = [module.lambda.lambda_function_arns["list_manager"]]
    }

    cw_poller = {
      name                = "CWPoller-EventsRule"
      description         = "SO0005 quota-monitor-for-aws - QM-CWPoller-EventsRule"
      schedule_expression = var.monitoring_frequency
      state              = "ENABLED"
      targets = [
        {
          arn = module.lambda.lambda_function_arns["qmcw_poller"]
          id  = "Target0"
        }
      ]
      depends_on = [module.lambda.lambda_function_arns["qmcw_poller"]]
    }

    utilization_ok = {
      name          = "QM-UtilizationOK"
      description   = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state         = "ENABLED"

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["OK"]
        }
        "detail-type" = [
          "Service Quotas Utilization Notification"
        ]
        source = [
          "aws-solutions.quota-monitor"
        ]
      })

      targets = [
        {
          arn       = var.event_bus_arn
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["utilization_ok_events"]
        }
      ]

      depends_on = [
        module.event_bus,
        module.iam.iam_role_arns["utilization_ok_events"]
      ]
    }

    utilization_warn = {
      name           = "QM-UtilizationWarn"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["WARN"]
        }
        "detail-type" = [
          "Service Quotas Utilization Notification"
        ]
        source = [
          "aws-solutions.quota-monitor"
        ]
      })

      targets = [
        {
          arn       = var.event_bus_arn
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["utilization_warn_events"]
        }
      ]

      depends_on = [
        module.event_bus,
        module.iam.iam_role_arns["utilization_warn_events"]
      ]
    }

    utilization_error = {
      name           = "QM-UtilizationErr"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["ERROR"]
        }
        "detail-type" = [
          "Service Quotas Utilization Notification"
        ]
        source = [
          "aws-solutions.quota-monitor"
        ]
      })

      targets = [
        {
          arn       = var.event_bus_arn
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["utilization_error_events"]
        }
      ]

      depends_on = [
        module.event_bus,
        module.iam.iam_role_arns["utilization_error_events"]
      ]
    }

    spoke_sns = {
      name           = "spoke-sns"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-SpokeSnsEventsRule"
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
          arn  = "arn:${data.aws_partition.current.partition}:events:${var.spoke_sns_region}:${data.aws_caller_identity.current.account_id}:event-bus/QuotaMonitorSnsSpokeBus"
          id   = "Target0"
          role_arn = module.iam.iam_role_arns["spoke_sns_events"]
        }
      ]

      depends_on = [
        module.event_bus,
        module.iam.iam_role_arns["spoke_sns_events"]
      ]
    }

    ################# TA Spoke
    ta_ok = {
      name          = "TA-OK-Rule"
      description   = "Quota Monitor Solution - Spoke - Rule for TA OK events"
      state         = "ENABLED"

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["OK"]
          "check-item-detail" = {
            Service = [
              "AutoScaling", "CloudFormation", "DynamoDB", "EBS", 
              "EC2", "ELB", "IAM", "Kinesis", "RDS", 
              "Route53", "SES", "VPC"
            ]
          }
        }
        "detail-type" = ["Trusted Advisor Check Item Refresh Notification"]
        source = ["aws.trustedadvisor"]
      })

      targets = [
        {
          arn       = var.event_bus_arn
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["ta_ok_rule_events_role"]
        }
      ]
    }

    ta_warn = {
      name          = "TA-Warn-Rule"
      description   = "Quota Monitor Solution - Spoke - Rule for TA WARN events"
      state         = "ENABLED"

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["WARN"]
          "check-item-detail" = {
            Service = [
              "AutoScaling", "CloudFormation", "DynamoDB", "EBS", 
              "EC2", "ELB", "IAM", "Kinesis", "RDS", 
              "Route53", "SES", "VPC"
            ]
          }
        }
        "detail-type" = ["Trusted Advisor Check Item Refresh Notification"]
        source = ["aws.trustedadvisor"]
      })

      targets = [
        {
          arn       = var.event_bus_arn
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["ta_warn_rule_events_role"]
        }
      ]
    }

    ta_error = {
      name          = "TA-Error-Rule"
      description   = "Quota Monitor Solution - Spoke - Rule for TA ERROR events"
      state         = "ENABLED"

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["ERROR"]
          "check-item-detail" = {
            Service = [
              "AutoScaling", "CloudFormation", "DynamoDB", "EBS", 
              "EC2", "ELB", "IAM", "Kinesis", "RDS", 
              "Route53", "SES", "VPC"
            ]
          }
        }
        "detail-type" = ["Trusted Advisor Check Item Refresh Notification"]
        source = ["aws.trustedadvisor"]
      })

      targets = [
        {
          arn       = var.event_bus_arn
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["ta_error_rule_events_role"]
        }
      ]
    }

    ta_refresher = {
      name                = "QM-TA-Refresher-EventsRule"
      description         = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-EventsRule"
      schedule_expression = var.ta_refresh_rate
      state              = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["ta_refresher"]
          id  = "Target0"
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["ta_refresher"]]
    }
  }

  depends_on = [
    module.lambda
  ]
}
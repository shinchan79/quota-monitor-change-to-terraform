# module "event_rule" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   event_rules = {
#     ################# SNS Spoke
#     sns_publisher = {
#       name          = "SNSPublisher-EventsRule"
#       description   = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-EventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["sns_spoke"] # Reference to the SNS spoke bus
#       state         = "ENABLED"

#       event_pattern = jsonencode({
#         detail = {
#           status = ["WARN", "ERROR"]
#         }
#         "detail-type" = [
#           "Trusted Advisor Check Item Refresh Notification",
#           "Service Quotas Utilization Notification"
#         ]
#         source = [
#           "aws.trustedadvisor",
#           "aws-solutions.quota-monitor"
#         ]
#       })

#       targets = [
#         {
#           arn = module.lambda.lambda_function_arns["sns_publisher"]
#           id  = "Target0"
#         }
#       ]

#       depends_on = [module.lambda.lambda_function_arns["sns_publisher"]]
#     }

#     ################# QM Spoke
#     list_manager = {
#       name        = "ListManager-Schedule"
#       description = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
#       schedule_expression = "rate(30 days)"
#       state       = "ENABLED"
#       targets = [
#         {
#           arn = module.lambda.lambda_function_arns["list_manager"]
#           id  = "Target0"
#         }
#       ]
#       depends_on = [module.lambda.lambda_function_arns["list_manager"]]
#     }

#     cw_poller = {
#       name                = "CWPoller-EventsRule"
#       description         = "SO0005 quota-monitor-for-aws - QM-CWPoller-EventsRule"
#       schedule_expression = var.monitoring_frequency
#       state              = "ENABLED"
#       targets = [
#         {
#           arn = module.lambda.lambda_function_arns["qmcw_poller"]
#           id  = "Target0"
#         }
#       ]
#       depends_on = [module.lambda.lambda_function_arns["qmcw_poller"]]
#     }

#     utilization_ok = {
#       name          = "QM-UtilizationOK"
#       description   = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
#       state         = "ENABLED"

#       event_pattern = jsonencode({
#         account = [data.aws_caller_identity.current.account_id]
#         detail = {
#           status = ["OK"]
#         }
#         "detail-type" = [
#           "Service Quotas Utilization Notification"
#         ]
#         source = [
#           "aws-solutions.quota-monitor"
#         ]
#       })

#       targets = [
#         {
#           arn       = var.event_bus_arn
#           id        = "Target0"
#           role_arn  = module.iam.iam_role_arns["utilization_ok_events"]
#         }
#       ]

#       depends_on = [
#         module.event_bus,
#         module.iam.iam_role_arns["utilization_ok_events"]
#       ]
#     }

#     utilization_warn = {
#       name           = "QM-UtilizationWarn"
#       description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
#       state          = "ENABLED"

#       event_pattern = jsonencode({
#         account = [data.aws_caller_identity.current.account_id]
#         detail = {
#           status = ["WARN"]
#         }
#         "detail-type" = [
#           "Service Quotas Utilization Notification"
#         ]
#         source = [
#           "aws-solutions.quota-monitor"
#         ]
#       })

#       targets = [
#         {
#           arn       = var.event_bus_arn
#           id        = "Target0"
#           role_arn  = module.iam.iam_role_arns["utilization_warn_events"]
#         }
#       ]

#       depends_on = [
#         module.event_bus,
#         module.iam.iam_role_arns["utilization_warn_events"]
#       ]
#     }

#     utilization_error = {
#       name           = "QM-UtilizationErr"
#       description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
#       state          = "ENABLED"

#       event_pattern = jsonencode({
#         account = [data.aws_caller_identity.current.account_id]
#         detail = {
#           status = ["ERROR"]
#         }
#         "detail-type" = [
#           "Service Quotas Utilization Notification"
#         ]
#         source = [
#           "aws-solutions.quota-monitor"
#         ]
#       })

#       targets = [
#         {
#           arn       = var.event_bus_arn
#           id        = "Target0"
#           role_arn  = module.iam.iam_role_arns["utilization_error_events"]
#         }
#       ]

#       depends_on = [
#         module.event_bus,
#         module.iam.iam_role_arns["utilization_error_events"]
#       ]
#     }

#     spoke_sns = {
#       name           = "spoke-sns"
#       description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-SpokeSnsEventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
#       state          = "ENABLED"

#       event_pattern = jsonencode({
#         detail = {
#           status = ["WARN", "ERROR"]
#         }
#         "detail-type" = [
#           "Trusted Advisor Check Item Refresh Notification",
#           "Service Quotas Utilization Notification"
#         ]
#         source = [
#           "aws.trustedadvisor",
#           "aws-solutions.quota-monitor"
#         ]
#       })

#       targets = [
#         {
#           arn  = "arn:${data.aws_partition.current.partition}:events:${var.spoke_sns_region}:${data.aws_caller_identity.current.account_id}:event-bus/QuotaMonitorSnsSpokeBus"
#           id   = "Target0"
#           role_arn = module.iam.iam_role_arns["spoke_sns_events"]
#         }
#       ]

#       depends_on = [
#         module.event_bus,
#         module.iam.iam_role_arns["spoke_sns_events"]
#       ]
#     }

#     ################# TA Spoke
#     ta_ok = {
#       name          = "TA-OK-Rule"
#       description   = "Quota Monitor Solution - Spoke - Rule for TA OK events"
#       state         = "ENABLED"

#       event_pattern = jsonencode({
#         account = [data.aws_caller_identity.current.account_id]
#         detail = {
#           status = ["OK"]
#           "check-item-detail" = {
#             Service = [
#               "AutoScaling", "CloudFormation", "DynamoDB", "EBS", 
#               "EC2", "ELB", "IAM", "Kinesis", "RDS", 
#               "Route53", "SES", "VPC"
#             ]
#           }
#         }
#         "detail-type" = ["Trusted Advisor Check Item Refresh Notification"]
#         source = ["aws.trustedadvisor"]
#       })

#       targets = [
#         {
#           arn       = var.event_bus_arn
#           id        = "Target0"
#           role_arn  = module.iam.iam_role_arns["ta_ok_rule_events_role"]
#         }
#       ]
#     }

#     ta_warn = {
#       name          = "TA-Warn-Rule"
#       description   = "Quota Monitor Solution - Spoke - Rule for TA WARN events"
#       state         = "ENABLED"

#       event_pattern = jsonencode({
#         account = [data.aws_caller_identity.current.account_id]
#         detail = {
#           status = ["WARN"]
#           "check-item-detail" = {
#             Service = [
#               "AutoScaling", "CloudFormation", "DynamoDB", "EBS", 
#               "EC2", "ELB", "IAM", "Kinesis", "RDS", 
#               "Route53", "SES", "VPC"
#             ]
#           }
#         }
#         "detail-type" = ["Trusted Advisor Check Item Refresh Notification"]
#         source = ["aws.trustedadvisor"]
#       })

#       targets = [
#         {
#           arn       = var.event_bus_arn
#           id        = "Target0"
#           role_arn  = module.iam.iam_role_arns["ta_warn_rule_events_role"]
#         }
#       ]
#     }

#     ta_error = {
#       name          = "TA-Error-Rule"
#       description   = "Quota Monitor Solution - Spoke - Rule for TA ERROR events"
#       state         = "ENABLED"

#       event_pattern = jsonencode({
#         account = [data.aws_caller_identity.current.account_id]
#         detail = {
#           status = ["ERROR"]
#           "check-item-detail" = {
#             Service = [
#               "AutoScaling", "CloudFormation", "DynamoDB", "EBS", 
#               "EC2", "ELB", "IAM", "Kinesis", "RDS", 
#               "Route53", "SES", "VPC"
#             ]
#           }
#         }
#         "detail-type" = ["Trusted Advisor Check Item Refresh Notification"]
#         source = ["aws.trustedadvisor"]
#       })

#       targets = [
#         {
#           arn       = var.event_bus_arn
#           id        = "Target0"
#           role_arn  = module.iam.iam_role_arns["ta_error_rule_events_role"]
#         }
#       ]
#     }

#     ta_refresher = {
#       name                = "QM-TA-Refresher-EventsRule"
#       description         = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-EventsRule"
#       schedule_expression = var.ta_refresh_rate
#       state              = "ENABLED"

#       targets = [
#         {
#           arn = module.lambda.lambda_function_arns["ta_refresher"]
#           id  = "Target0"
#         }
#       ]

#       depends_on = [module.lambda.lambda_function_arns["ta_refresher"]]
#     }
#   }

#   depends_on = [
#     module.lambda
#   ]
# }

module "event_rule" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  event_rules = {
    sns_publisher = {
      name           = "${var.master_prefix}-SNSPublisher-EventsRule"
      description    = var.sns_publisher_description
      event_bus_name = module.event_bus.eventbridge_bus_names["sns_spoke"]
      state         = var.rule_state

      event_pattern = jsonencode({
        detail = {
          status = var.alert_status_levels
        }
        "detail-type" = var.notification_types
        source        = var.event_sources
      })

      targets = [
        {
          arn = module.lambda.lambda_function_arns["sns_publisher"]
          id  = "Target0"
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["sns_publisher"]]
    }

    list_manager = {
      name                = "${var.master_prefix}-ListManager-Schedule"
      description         = var.list_manager_description
      schedule_expression = var.list_manager_schedule
      state              = var.rule_state
      targets = [
        {
          arn = module.lambda.lambda_function_arns["list_manager"]
          id  = "Target0"
        }
      ]
      depends_on = [module.lambda.lambda_function_arns["list_manager"]]
    }

    cw_poller = {
      name                = "${var.master_prefix}-CWPoller-EventsRule"
      description         = var.cw_poller_description
      schedule_expression = var.monitoring_frequency
      state              = var.rule_state
      targets = [
        {
          arn = module.lambda.lambda_function_arns["qmcw_poller"]
          id  = "Target0"
        }
      ]
      depends_on = [module.lambda.lambda_function_arns["qmcw_poller"]]
    }

    utilization_ok = {
      name           = "${var.master_prefix}-UtilizationOK"
      description    = var.utilization_ok_description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state         = var.rule_state

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["OK"]
        }
        "detail-type" = var.utilization_notification_types
        source        = [var.quota_monitor_source]
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
      name           = "${var.master_prefix}-UtilizationWarn"
      description    = var.utilization_warn_description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state         = var.rule_state

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["WARN"]
        }
        "detail-type" = var.utilization_notification_types
        source        = [var.quota_monitor_source]
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
      name           = "${var.master_prefix}-UtilizationErr"
      description    = var.utilization_error_description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state         = var.rule_state

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["ERROR"]
        }
        "detail-type" = var.utilization_notification_types
        source        = [var.quota_monitor_source]
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
      name           = "${var.master_prefix}-spoke-sns"
      description    = var.spoke_sns_description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
      state         = var.rule_state

      event_pattern = jsonencode({
        detail = {
          status = var.alert_status_levels
        }
        "detail-type" = var.notification_types
        source        = var.event_sources
      })

      targets = [
        {
          arn       = "arn:${data.aws_partition.current.partition}:events:${var.spoke_sns_region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.master_prefix}-${var.sns_spoke_bus_name}"
          id        = "Target0"
          role_arn  = module.iam.iam_role_arns["spoke_sns_events"]
        }
      ]

      depends_on = [
        module.event_bus,
        module.iam.iam_role_arns["spoke_sns_events"]
      ]
    }

    ta_ok = {
      name        = "${var.master_prefix}-TA-OK-Rule"
      description = var.ta_ok_description
      state      = var.rule_state

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["OK"]
          "check-item-detail" = {
            Service = var.monitored_services
          }
        }
        "detail-type" = var.ta_notification_types
        source        = [var.ta_source]
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
      name        = "${var.master_prefix}-TA-Warn-Rule"
      description = var.ta_warn_description
      state      = var.rule_state

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["WARN"]
          "check-item-detail" = {
            Service = var.monitored_services
          }
        }
        "detail-type" = var.ta_notification_types
        source        = [var.ta_source]
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
      name        = "${var.master_prefix}-TA-Error-Rule"
      description = var.ta_error_description
      state      = var.rule_state

      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["ERROR"]
          "check-item-detail" = {
            Service = var.monitored_services
          }
        }
        "detail-type" = var.ta_notification_types
        source        = [var.ta_source]
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
      name                = "${var.master_prefix}-TA-Refresher-EventsRule"
      description         = var.ta_refresher_description
      schedule_expression = var.ta_refresh_rate
      state              = var.rule_state

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

# Variables
variable "sns_publisher_description" {
  description = "Description for SNS Publisher Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-EventsRule"
}

variable "list_manager_description" {
  description = "Description for List Manager Schedule Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
}

variable "cw_poller_description" {
  description = "Description for CloudWatch Poller Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-CWPoller-EventsRule"
}

variable "utilization_ok_description" {
  description = "Description for Utilization OK Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
}

variable "utilization_warn_description" {
  description = "Description for Utilization Warning Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
}

variable "utilization_error_description" {
  description = "Description for Utilization Error Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
}

variable "spoke_sns_description" {
  description = "Description for Spoke SNS Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-SpokeSnsEventsRule"
}

variable "ta_ok_description" {
  description = "Description for TA OK Events Rule"
  type        = string
  default     = "Quota Monitor Solution - Spoke - Rule for TA OK events"
}

variable "ta_warn_description" {
  description = "Description for TA Warning Events Rule"
  type        = string
  default     = "Quota Monitor Solution - Spoke - Rule for TA WARN events"
}

variable "ta_error_description" {
  description = "Description for TA Error Events Rule"
  type        = string
  default     = "Quota Monitor Solution - Spoke - Rule for TA ERROR events"
}

variable "ta_refresher_description" {
  description = "Description for TA Refresher Events Rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-EventsRule"
}

variable "rule_state" {
  description = "State of the EventBridge rules"
  type        = string
  default     = "ENABLED"
}

variable "list_manager_schedule" {
  description = "Schedule expression for List Manager"
  type        = string
  default     = "rate(30 days)"
}

variable "alert_status_levels" {
  description = "Status levels for alerts"
  type        = list(string)
  default     = ["WARN", "ERROR"]
}

variable "notification_types" {
  description = "Types of notifications to handle"
  type        = list(string)
  default     = [
    "Trusted Advisor Check Item Refresh Notification",
    "Service Quotas Utilization Notification"
  ]
}

variable "utilization_notification_types" {
  description = "Types of utilization notifications"
  type        = list(string)
  default     = ["Service Quotas Utilization Notification"]
}

variable "ta_notification_types" {
  description = "Types of Trusted Advisor notifications"
  type        = list(string)
  default     = ["Trusted Advisor Check Item Refresh Notification"]
}

variable "event_sources" {
  description = "Sources of events to handle"
  type        = list(string)
  default     = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
}

variable "quota_monitor_source" {
  description = "Source for quota monitor events"
  type        = string
  default     = "aws-solutions.quota-monitor"
}

variable "ta_source" {
  description = "Source for Trusted Advisor events"
  type        = string
  default     = "aws.trustedadvisor"
}

variable "monitored_services" {
  description = "List of AWS services to monitor"
  type        = list(string)
  default     = [
    "AutoScaling", "CloudFormation", "DynamoDB", "EBS",
    "EC2", "ELB", "IAM", "Kinesis", "RDS",
    "Route53", "SES", "VPC"
  ]
}
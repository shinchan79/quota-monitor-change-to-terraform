# module "event_rule" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   event_rules = {
#     sns_publisher = {
#       name          = "SNSPublisher-EventsRule"
#       description   = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
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

#     summarizer_event_queue = {
#       name          = "Summarizer-EventQueue-Rule"
#       description   = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
#       event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
#       state         = "ENABLED"

#       event_pattern = jsonencode({
#         detail = {
#           status = ["OK", "WARN", "ERROR"]
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
#           arn = module.sqs.sqs_queue_arns["summarizer_event_queue"]
#           id  = "Target0"
#         }
#       ]

#       depends_on = [module.sqs.sqs_queue_arns["summarizer_event_queue"]]
#     }
#     reporter = {
#       name                = "Reporter-EventsRule"
#       description         = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
#       schedule_expression = "rate(5 minutes)"
#       state               = "ENABLED"

#       targets = [
#         {
#           arn = module.lambda.lambda_function_arns["reporter"]
#           id  = "Target0"
#         }
#       ]

#       depends_on = [module.lambda.lambda_function_arns["reporter"]]
#     }

#     deployment_manager = {
#       name        = "Deployment-Manager-EventsRule"
#       description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
#       state       = "ENABLED"

#       event_pattern = jsonencode({
#         "detail-type" = ["Parameter Store Change"]
#         source        = ["aws.ssm"]
#         resources = [
#           "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["organizational_units"]}",
#           var.enable_account_deploy ? "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["target_accounts"]}" : null,
#           "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["regions_list"]}"
#         ]
#       })

#       targets = [
#         {
#           arn = module.lambda.lambda_function_arns["deployment_manager"]
#           id  = "Target0"
#         }
#       ]

#       depends_on = [module.lambda.lambda_function_arns["deployment_manager"]]
#     }
#   }
# }

module "event_rule" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  event_rules = {
    sns_publisher = {
      name           = var.sns_publisher_rule_name
      description    = var.sns_publisher_rule_description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = var.status_warn_error
        }
        "detail-type" = var.detail_type_notifications
        source        = var.event_sources
      })

      targets = [
        {
          arn = module.lambda.lambda_function_arns["sns_publisher"]
          id  = var.target_id
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["sns_publisher"]]
    }

    summarizer_event_queue = {
      name           = var.summarizer_rule_name
      description    = var.summarizer_rule_description
      event_bus_name = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state          = "ENABLED"

      event_pattern = jsonencode({
        detail = {
          status = var.status_all
        }
        "detail-type" = var.detail_type_notifications
        source        = var.event_sources
      })

      targets = [
        {
          arn = module.sqs.sqs_queue_arns["summarizer_event_queue"]
          id  = var.target_id
        }
      ]

      depends_on = [module.sqs.sqs_queue_arns["summarizer_event_queue"]]
    }

    reporter = {
      name                = var.reporter_rule_name
      description         = var.reporter_rule_description
      schedule_expression = var.reporter_schedule
      state               = "ENABLED"

      targets = [
        {
          arn = module.lambda.lambda_function_arns["reporter"]
          id  = var.target_id
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["reporter"]]
    }

    deployment_manager = {
      name        = var.deployment_manager_rule_name
      description = var.deployment_manager_rule_description
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
          id  = var.target_id
        }
      ]

      depends_on = [module.lambda.lambda_function_arns["deployment_manager"]]
    }
  }
}

variable "sns_publisher_rule_name" {
  description = "Name for SNS Publisher EventBridge rule"
  type        = string
  default     = "SNSPublisher-EventsRule"
}

variable "sns_publisher_rule_description" {
  description = "Description for SNS Publisher EventBridge rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
}

variable "summarizer_rule_name" {
  description = "Name for Summarizer EventBridge rule"
  type        = string
  default     = "Summarizer-EventQueue-Rule"
}

variable "summarizer_rule_description" {
  description = "Description for Summarizer EventBridge rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
}

variable "reporter_rule_name" {
  description = "Name for Reporter EventBridge rule"
  type        = string
  default     = "Reporter-EventsRule"
}

variable "reporter_rule_description" {
  description = "Description for Reporter EventBridge rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
}

variable "reporter_schedule" {
  description = "Schedule expression for Reporter rule"
  type        = string
  default     = "rate(5 minutes)"
}

variable "deployment_manager_rule_name" {
  description = "Name for Deployment Manager EventBridge rule"
  type        = string
  default     = "Deployment-Manager-EventsRule"
}

variable "deployment_manager_rule_description" {
  description = "Description for Deployment Manager EventBridge rule"
  type        = string
  default     = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
}

variable "status_warn_error" {
  description = "Status values for warn and error events"
  type        = list(string)
  default     = ["WARN", "ERROR"]
}

variable "status_all" {
  description = "All status values for events"
  type        = list(string)
  default     = ["OK", "WARN", "ERROR"]
}

variable "detail_type_notifications" {
  description = "Detail types for notifications"
  type        = list(string)
  default     = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
}

variable "event_sources" {
  description = "Sources for events"
  type        = list(string)
  default     = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
}

variable "target_id" {
  description = "Target ID for event rules"
  type        = string
  default     = "Target0"
}
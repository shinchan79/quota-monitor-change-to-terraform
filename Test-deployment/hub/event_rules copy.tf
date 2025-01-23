# module "event_rule" {
#   source        = "../modules"
#   create        = local.create_hub_resources
#   create_event  = true
#   master_prefix = var.master_prefix
#   event_rules   = {
#     sns_publisher = {
#       name           = "QM-SNSPublisherFunction-EventsRule"
#       description    = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
#       event_bus_key  = "quota_monitor"
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
#       tags = merge(
#         {
#           Name = "QM-SNSPublisherFunction-EventsRule"
#         },
#         local.merged_tags
#       )
#     }
#     summarizer_event_queue = {
#       name           = "QM-Summarizer-EventQueue-EventsRule"
#       description    = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
#       event_bus_key  = "quota_monitor"
#       state          = "ENABLED"
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
#       tags = merge(
#         {
#           Name = "QM-Summarizer-EventQueue-EventsRule"
#         },
#         local.merged_tags
#       )
#     }
#     reporter = {
#       name                = "QM-Reporter-EventsRule"
#       description         = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
#       schedule_expression = "rate(5 minutes)"
#       state              = "ENABLED"
#       tags = merge(
#         {
#           Name = "QM-Reporter-EventsRule"
#         },
#         local.merged_tags
#       )
#     }
#     deployment_manager = {
#       name           = "QM-Deployment-Manager-EventsRule"
#       description    = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
#       event_bus_key  = "quota_monitor"
#       state          = "ENABLED"
#       event_pattern = jsonencode({
#         "detail-type" = ["Parameter Store Change"]
#         source        = ["aws.ssm"]
#         resources = [
#           "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["target_accounts"]}"
#         ]
#       })
#       tags = merge(
#         {
#           Name = "QM-Deployment-Manager-EventsRule"
#         },
#         local.merged_tags
#       )
#     }
#   }
#   event_targets = {
#     sns_publisher_target = {
#       rule_key      = "sns_publisher"
#       event_bus_key = "quota_monitor"  # Thêm event_bus_key
#       target_arn    = module.lambda.lambda_function_arns["sns_publisher"]
#     }
#     summarizer_target = {
#       rule_key      = "summarizer_event_queue"
#       event_bus_key = "quota_monitor"  # Thêm event_bus_key
#       target_arn    = module.sqs.sqs_queue_arns["summarizer_event_queue"]
#     }
#     reporter_target = {
#       rule_key   = "reporter"
#       target_arn = module.lambda.lambda_function_arns["reporter"]
#     }
#     deployment_target = {
#       rule_key      = "deployment_manager"
#       event_bus_key = "quota_monitor"  # Thêm event_bus_key
#       target_arn    = module.lambda.lambda_function_arns["deployment_manager"]
#     }
#   }
#   depends_on = [
#     module.lambda,
#     module.sqs,
#     module.event_bus
#   ]
# }


    # "QMSummarizerEventQueueQMSummarizerEventQueueEventsRuleE50B8D7C": {
    #   "Type": "AWS::Events::Rule",
    #   "Properties": {
    #     "Description": "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule",
    #     "EventBusName": {
    #       "Ref": "QMBusFF5C6C0C"
    #     },
    #     "EventPattern": {
    #       "detail": {
    #         "status": [
    #           "OK",
    #           "WARN",
    #           "ERROR"
    #         ]
    #       },
    #       "detail-type": [
    #         "Trusted Advisor Check Item Refresh Notification",
    #         "Service Quotas Utilization Notification"
    #       ],
    #       "source": [
    #         "aws.trustedadvisor",
    #         "aws-solutions.quota-monitor"
    #       ]
    #     },
    #     "State": "ENABLED",
    #     "Targets": [
    #       {
    #         "Arn": {
    #           "Fn::GetAtt": [
    #             "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A",
    #             "Arn"
    #           ]
    #         },
    #         "Id": "Target0"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Summarizer-EventQueue/QM-Summarizer-EventQueue-EventsRule/Resource"
    #   }
    # },


    #     "QMReporterQMReporterEventsRule0BF77282": {
    #   "Type": "AWS::Events::Rule",
    #   "Properties": {
    #     "Description": "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule",
    #     "ScheduleExpression": "rate(5 minutes)",
    #     "State": "ENABLED",
    #     "Targets": [
    #       {
    #         "Arn": {
    #           "Fn::GetAtt": [
    #             "QMReporterQMReporterLambda7D98A6E4",
    #             "Arn"
    #           ]
    #         },
    #         "Id": "Target0"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-EventsRule/Resource"
    #   }
    # },
module "event_rule" {
  source        = "../modules"
  create        = local.create_hub_resources
  create_event  = true
  master_prefix = var.master_prefix
  event_rules = {
    sns_publisher = {
      name          = var.event_rules_config["sns_publisher"].name
      description   = var.event_rules_config["sns_publisher"].description
      event_bus     = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state         = "ENABLED"
      event_pattern = jsonencode({
        detail = {
          status = var.event_rules_config["sns_publisher"].status
        }
        "detail-type" = var.event_rules_config["sns_publisher"].detail_type_notifications
        source        = var.event_rules_config["sns_publisher"].event_sources
      })
      tags = merge(
        {
          Name = var.event_rules_config["sns_publisher"].name
        },
        try(var.event_rules_config["sns_publisher"].tags, {}),
        local.merged_tags
      )
    }
    summarizer_event_queue = {
      name          = var.event_rules_config["summarizer"].name
      description   = var.event_rules_config["summarizer"].description
      event_bus     = module.event_bus.eventbridge_bus_names["quota_monitor"]
      state         = "ENABLED"
      event_pattern = jsonencode({
        detail = {
          status = var.event_rules_config["summarizer"].status
        }
        "detail-type" = var.event_rules_config["summarizer"].detail_type_notifications
        source        = var.event_rules_config["summarizer"].event_sources
      })
      tags = merge(
        {
          Name = var.event_rules_config["summarizer"].name
        },
        try(var.event_rules_config["summarizer"].tags, {}),
        local.merged_tags
      )
    }
    reporter = {
      name                = var.event_rules_config["reporter"].name
      description         = var.event_rules_config["reporter"].description
      schedule_expression = var.event_rules_config["reporter"].schedule
      state              = "ENABLED"
      tags = merge(
        {
          Name = var.event_rules_config["reporter"].name
        },
        try(var.event_rules_config["reporter"].tags, {}),
        local.merged_tags
      )
    }
    deployment_manager = {
      name          = var.event_rules_config["deployment_manager"].name
      description   = var.event_rules_config["deployment_manager"].description
      state         = "ENABLED"
      event_pattern = jsonencode({
        "detail-type" = ["Parameter Store Change"]
        source        = ["aws.ssm"]
        resources = [
          "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["target_accounts"]}"
        ]
      })
      tags = merge(
        {
          Name = var.event_rules_config["deployment_manager"].name
        },
        try(var.event_rules_config["deployment_manager"].tags, {}),
        local.merged_tags
      )
    }
  }
  event_targets = {
    sns_publisher_target = {
      rule_key   = "sns_publisher"
      event_bus  = module.event_bus.eventbridge_bus_names["quota_monitor"]
      target_arn = module.lambda.lambda_function_arns["sns_publisher"]
      target_id  = var.event_rules_config["sns_publisher"].target_id
    }
    summarizer_target = {
      rule_key   = "summarizer_event_queue"
      event_bus  = module.event_bus.eventbridge_bus_names["quota_monitor"]
      target_arn = module.sqs.sqs_queue_arns["summarizer_event_queue"]
      target_id  = var.event_rules_config["summarizer"].target_id
    }
    reporter_target = {
      rule_key   = "reporter"
      target_arn = module.lambda.lambda_function_arns["reporter"]
      target_id  = var.event_rules_config["reporter"].target_id
    }
    deployment_target = {
      rule_key   = "deployment_manager"
      target_arn = module.lambda.lambda_function_arns["deployment_manager"]
      target_id  = var.event_rules_config["deployment_manager"].target_id
    }
  }
  depends_on = [
    module.lambda,
    module.sqs,
    module.event_bus
  ]
}



    # "QMSlackNotifierQMSlackNotifierEventsRuleC3528E53": {
    #   "Type": "AWS::Events::Rule",
    #   "Properties": {
    #     "Description": "SO0005 quota-monitor-for-aws - QM-SlackNotifier-EventsRule",
    #     "EventBusName": {
    #       "Ref": "QMBusFF5C6C0C"
    #     },
    #     "EventPattern": {
    #       "detail": {
    #         "status": [
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
    #             "QMSlackNotifierQMSlackNotifierLambda95713661",
    #             "Arn"
    #           ]
    #         },
    #         "Id": "Target0"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-EventsRule/Resource"
    #   },
    #   "Condition": "SlackTrueCondition"
    # },



    
    # "QMSNSPublisherFunctionQMSNSPublisherFunctionEventsRule5BDCD4FD": {
    #   "Type": "AWS::Events::Rule",
    #   "Properties": {
    #     "Description": "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule",
    #     "EventBusName": {
    #       "Ref": "QMBusFF5C6C0C"
    #     },
    #     "EventPattern": {
    #       "detail": {
    #         "status": [
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
    #             "QMSNSPublisherFunctionQMSNSPublisherFunctionLambda8BD2DBC1",
    #             "Arn"
    #           ]
    #         },
    #         "Id": "Target0"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SNSPublisherFunction/QM-SNSPublisherFunction-EventsRule/Resource"
    #   }
    # },



    #     "QMDeploymentManagerQMDeploymentManagerEventsRule53DB2DA9": {
    #   "Type": "AWS::Events::Rule",
    #   "Properties": {
    #     "Description": "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule",
    #     "EventPattern": {
    #       "detail-type": [
    #         "Parameter Store Change"
    #       ],
    #       "source": [
    #         "aws.ssm"
    #       ],
    #       "resources": [
    #         {
    #           "Fn::Join": [
    #             "",
    #             [
    #               "arn:",
    #               {
    #                 "Ref": "AWS::Partition"
    #               },
    #               ":ssm:",
    #               {
    #                 "Ref": "AWS::Region"
    #               },
    #               ":",
    #               {
    #                 "Ref": "AWS::AccountId"
    #               },
    #               ":parameter",
    #               {
    #                 "Ref": "QMAccounts3D743F6B"
    #               }
    #             ]
    #           ]
    #         }
    #       ]
    #     },
    #     "State": "ENABLED",
    #     "Targets": [
    #       {
    #         "Arn": {
    #           "Fn::GetAtt": [
    #             "QMDeploymentManagerQMDeploymentManagerLambdaB36F1B21",
    #             "Arn"
    #           ]
    #         },
    #         "Id": "Target0"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-EventsRule/Resource"
    #   }
    # },
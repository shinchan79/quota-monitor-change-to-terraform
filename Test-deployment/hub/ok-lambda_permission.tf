module "lambda_permissions" {
  source = "../modules"

  create                   = local.create_hub_resources
  create_lambda            = true
  create_lambda_permission = true
  master_prefix            = var.master_prefix

  lambda_permissions = {
    sns_publisher = {
      statement_id  = var.lambda_permissions_config["sns_publisher"].statement_id
      action        = var.lambda_permissions_config["sns_publisher"].action
      function_name = module.lambda.lambda_function_names["sns_publisher"]
      principal     = var.lambda_permissions_config["sns_publisher"].principal
      source_arn    = module.event_rule.eventbridge_rule_arns["sns_publisher"]
    }

    reporter = {
      statement_id  = var.lambda_permissions_config["reporter"].statement_id
      action        = var.lambda_permissions_config["reporter"].action
      function_name = module.lambda.lambda_function_names["reporter"]
      principal     = var.lambda_permissions_config["reporter"].principal
      source_arn    = module.event_rule.eventbridge_rule_arns["reporter"]
    }

    deployment_manager = {
      statement_id  = var.lambda_permissions_config["deployment_manager"].statement_id
      action        = var.lambda_permissions_config["deployment_manager"].action
      function_name = module.lambda.lambda_function_names["deployment_manager"]
      principal     = var.lambda_permissions_config["deployment_manager"].principal
      source_arn    = module.event_rule.eventbridge_rule_arns["deployment_manager"]
    }
  }

  depends_on = [
    module.event_rule
  ]
}


    # "QMSlackNotifierQMSlackNotifierEventsRuleAllowEventRulequotamonitorhubnoouQMSlackNotifierQMSlackNotifierLambda52C322580E2041A7": {
    #   "Type": "AWS::Lambda::Permission",
    #   "Properties": {
    #     "Action": "lambda:InvokeFunction",
    #     "FunctionName": {
    #       "Fn::GetAtt": [
    #         "QMSlackNotifierQMSlackNotifierLambda95713661",
    #         "Arn"
    #       ]
    #     },
    #     "Principal": "events.amazonaws.com",
    #     "SourceArn": {
    #       "Fn::GetAtt": [
    #         "QMSlackNotifierQMSlackNotifierEventsRuleC3528E53",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-EventsRule/AllowEventRulequotamonitorhubnoouQMSlackNotifierQMSlackNotifierLambda52C32258"
    #   },
    #   "Condition": "SlackTrueCondition"
    # },



    #     "QMSNSPublisherFunctionQMSNSPublisherFunctionEventsRuleAllowEventRulequotamonitorhubnoouQMSNSPublisherFunctionQMSNSPublisherFunctionLambda76203A7F3F46BC24": {
    #   "Type": "AWS::Lambda::Permission",
    #   "Properties": {
    #     "Action": "lambda:InvokeFunction",
    #     "FunctionName": {
    #       "Fn::GetAtt": [
    #         "QMSNSPublisherFunctionQMSNSPublisherFunctionLambda8BD2DBC1",
    #         "Arn"
    #       ]
    #     },
    #     "Principal": "events.amazonaws.com",
    #     "SourceArn": {
    #       "Fn::GetAtt": [
    #         "QMSNSPublisherFunctionQMSNSPublisherFunctionEventsRule5BDCD4FD",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SNSPublisherFunction/QM-SNSPublisherFunction-EventsRule/AllowEventRulequotamonitorhubnoouQMSNSPublisherFunctionQMSNSPublisherFunctionLambda76203A7F"
    #   }
    # },


    #     "QMReporterQMReporterEventsRuleAllowEventRulequotamonitorhubnoouQMReporterQMReporterLambda0CE086E3DDFD1F2A": {
    #   "Type": "AWS::Lambda::Permission",
    #   "Properties": {
    #     "Action": "lambda:InvokeFunction",
    #     "FunctionName": {
    #       "Fn::GetAtt": [
    #         "QMReporterQMReporterLambda7D98A6E4",
    #         "Arn"
    #       ]
    #     },
    #     "Principal": "events.amazonaws.com",
    #     "SourceArn": {
    #       "Fn::GetAtt": [
    #         "QMReporterQMReporterEventsRule0BF77282",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-EventsRule/AllowEventRulequotamonitorhubnoouQMReporterQMReporterLambda0CE086E3"
    #   }
    # },
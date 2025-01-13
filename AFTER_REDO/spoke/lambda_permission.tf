module "lambda_permissions" {
  source = "../modules"

  create                   = true
  create_lambda           = true
  create_lambda_permission = true
  master_prefix           = "qm"

  lambda_permissions = {
    ################# SNS Spoke
    sns_publisher = {
      statement_id  = "AllowEventRulequotamonitorsnsspoke"
      action        = "lambda:InvokeFunction" 
      function_name = module.lambda.lambda_function_names["sns_publisher"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["sns_publisher"]
    }

    ################# QM Spoke
    list_manager = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["list_manager"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["list_manager"]
    }

    cw_poller = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["qmcw_poller"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["cw_poller"]
    }

    ################# TA Spoke => Code lại 
    ta_refresher = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["ta_refresher"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["ta_refresher"]
    }
  }

  depends_on = [
    module.event_rule,
    module.lambda
  ]
}
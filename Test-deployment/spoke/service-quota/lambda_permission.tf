module "lambda_permissions" {
  source = "../../modules"

  create                   = true
  create_lambda            = true
  create_lambda_permission = true
  master_prefix            = var.master_prefix

  lambda_permissions = {
    sns_publisher = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["sns_publisher"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["sns_publisher"]
    }

    list_manager = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["list_manager"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["list_manager"]
    }

    qmcw_poller = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["qmcw_poller"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["qmcw_poller"]
    }

    list_manager_provider = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name = module.lambda.lambda_function_names["list_manager_provider"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["list_manager"]
    }
  }

  depends_on = [
    module.event_rule,
    module.lambda
  ]
}
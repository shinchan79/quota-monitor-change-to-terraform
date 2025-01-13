module "lambda_permissions" {
  source = "../modules"

  create                   = true
  create_lambda           = true
  create_lambda_permission = true
  master_prefix           = "qm"

  lambda_permissions = {
    sns_publisher = {
      statement_id  = "AllowEventBridgeInvoke" 
      action        = "lambda:InvokeFunction"
      function_name  = module.lambda.lambda_function_names["sns_publisher"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["sns_publisher"]
    }

    reporter = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name  = module.lambda.lambda_function_names["reporter"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["reporter"]
    }

    deployment_manager = {
      statement_id  = "AllowEventBridgeInvoke"
      action        = "lambda:InvokeFunction"
      function_name  = module.lambda.lambda_function_names["deployment_manager"]
      principal     = "events.amazonaws.com"
      source_arn    = module.event_rule.eventbridge_rule_arns["deployment_manager"]
    }
  }

  depends_on = [
    module.event_rule
  ]
}
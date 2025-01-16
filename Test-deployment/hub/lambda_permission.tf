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

    # deployment_manager = {
    #   statement_id  = var.lambda_permissions_config["deployment_manager"].statement_id
    #   action        = var.lambda_permissions_config["deployment_manager"].action
    #   function_name = module.lambda.lambda_function_names["deployment_manager"]
    #   principal     = var.lambda_permissions_config["deployment_manager"].principal
    #   source_arn    = module.event_rule.eventbridge_rule_arns["deployment_manager"]
    # }
  }

  depends_on = [
    module.event_rule
  ]
}

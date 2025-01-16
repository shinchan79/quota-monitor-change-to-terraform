# Lambda permission configurations
variable "lambda_permissions_config" {
  description = "Configuration for Lambda permissions"
  type = map(object({
    statement_id = string
    action       = string
    principal    = string
  }))
  default = {
    ta_refresher = {
      statement_id = "AllowEventBridgeInvoke"
      action       = "lambda:InvokeFunction"
      principal    = "events.amazonaws.com"
    }
  }
}

module "lambda_permissions" {
  source = "../../modules"

  create                   = true
  create_lambda            = true
  create_lambda_permission = true
  master_prefix            = var.master_prefix

  lambda_permissions = {
    ta_refresher = {
      statement_id  = var.lambda_permissions_config["ta_refresher"].statement_id
      action        = var.lambda_permissions_config["ta_refresher"].action
      function_name = module.lambda.lambda_function_names["ta_refresher"]
      principal     = var.lambda_permissions_config["ta_refresher"].principal
      source_arn    = module.event_rule.eventbridge_rule_arns["ta_refresher"]
    }
  }

  depends_on = [
    module.event_rule,
    module.lambda
  ]
}
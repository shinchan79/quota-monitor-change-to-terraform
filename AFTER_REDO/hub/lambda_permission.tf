# module "lambda_permissions" {
#   source = "../modules"

#   create                   = true
#   create_lambda           = true
#   create_lambda_permission = true
#   master_prefix           = "qm"

#   lambda_permissions = {
#     sns_publisher = {
#       statement_id  = "AllowEventBridgeInvoke" 
#       action        = "lambda:InvokeFunction"
#       function_name  = module.lambda.lambda_function_names["sns_publisher"]
#       principal     = "events.amazonaws.com"
#       source_arn    = module.event_rule.eventbridge_rule_arns["sns_publisher"]
#     }

#     reporter = {
#       statement_id  = "AllowEventBridgeInvoke"
#       action        = "lambda:InvokeFunction"
#       function_name  = module.lambda.lambda_function_names["reporter"]
#       principal     = "events.amazonaws.com"
#       source_arn    = module.event_rule.eventbridge_rule_arns["reporter"]
#     }

#     deployment_manager = {
#       statement_id  = "AllowEventBridgeInvoke"
#       action        = "lambda:InvokeFunction"
#       function_name  = module.lambda.lambda_function_names["deployment_manager"]
#       principal     = "events.amazonaws.com"
#       source_arn    = module.event_rule.eventbridge_rule_arns["deployment_manager"]
#     }
#   }

#   depends_on = [
#     module.event_rule
#   ]
# }

module "lambda_permissions" {
  source = "../modules"

  create                   = true
  create_lambda           = true
  create_lambda_permission = true
  master_prefix           = "qm"

  lambda_permissions = {
    sns_publisher = {
      statement_id  = var.lambda_permission_statement_id
      action        = var.lambda_permission_action
      function_name = module.lambda.lambda_function_names["sns_publisher"]
      principal     = var.eventbridge_service_principal
      source_arn    = module.event_rule.eventbridge_rule_arns["sns_publisher"]
    }

    reporter = {
      statement_id  = var.lambda_permission_statement_id
      action        = var.lambda_permission_action
      function_name = module.lambda.lambda_function_names["reporter"]
      principal     = var.eventbridge_service_principal
      source_arn    = module.event_rule.eventbridge_rule_arns["reporter"]
    }

    deployment_manager = {
      statement_id  = var.lambda_permission_statement_id
      action        = var.lambda_permission_action
      function_name = module.lambda.lambda_function_names["deployment_manager"]
      principal     = var.eventbridge_service_principal
      source_arn    = module.event_rule.eventbridge_rule_arns["deployment_manager"]
    }
  }

  depends_on = [
    module.event_rule
  ]
}

variable "lambda_permission_statement_id" {
  description = "Statement ID for Lambda permission"
  type        = string
  default     = "AllowEventBridgeInvoke"
}

variable "lambda_permission_action" {
  description = "Action for Lambda permission"
  type        = string
  default     = "lambda:InvokeFunction"
}

# Note: eventbridge_service_principal is already defined in kms.tf
# variable "eventbridge_service_principal" {
#   description = "EventBridge service principal"
#   type        = string
#   default     = "events.amazonaws.com"
# }

#---------------------------------------------------------------
# Event Rules Configuration
#---------------------------------------------------------------
variable "event_rules_config" {
  description = "Configuration for EventBridge rules"
  type = map(object({
    name                = string
    description         = string
    schedule_expression = optional(string)
    state               = optional(string, "ENABLED")
    event_pattern       = optional(any)
    targets = list(object({
      id       = string
      arn      = optional(string)
      role_arn = optional(string)
    }))
    tags = optional(map(string), {})
  }))

  default = {
    ta_ok = {
      name        = "TA-OK-Rule"
      description = "Quota Monitor Solution - Spoke - Rule for TA OK events"
      state       = "ENABLED"
      targets = [
        {
          id = "Target0"
        }
      ]
    }
    ta_warn = {
      name        = "TA-Warn-Rule"
      description = "Quota Monitor Solution - Spoke - Rule for TA WARN events"
      state       = "ENABLED"
      targets = [
        {
          id = "Target0"
        }
      ]
    }
    ta_error = {
      name        = "TA-Error-Rule"
      description = "Quota Monitor Solution - Spoke - Rule for TA ERROR events"
      state       = "ENABLED"
      targets = [
        {
          id = "Target0"
        }
      ]
    }
    ta_refresher = {
      name                = "TA-Refresher-Rule"
      description         = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-EventsRule"
      schedule_expression = "rate(12 hours)"
      state               = "ENABLED"
      targets = [
        {
          id = "Target0"
        }
      ]
    }
  }
}

#---------------------------------------------------------------
# Event Rules Module
#---------------------------------------------------------------
module "event_rule" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  event_rules = {
    ta_ok = {
      name        = format("%s-%s", var.master_prefix, var.event_rules_config["ta_ok"].name)
      description = var.event_rules_config["ta_ok"].description
      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["OK"]
          check-item-detail = {
            Service = split(",", var.aws_services)
          }
        }
        detail-type = ["Trusted Advisor Check Item Refresh Notification"]
        source      = ["aws.trustedadvisor"]
      })
      state = var.event_rules_config["ta_ok"].state
      targets = [
        {
          arn      = var.event_bus_arn
          id       = var.event_rules_config["ta_ok"].targets[0].id
          role_arn = module.iam.iam_role_arns["ta_ok_rule_events_role"]
        }
      ]
      tags = local.merged_tags
    }

    ta_warn = {
      name        = format("%s-%s", var.master_prefix, var.event_rules_config["ta_warn"].name)
      description = var.event_rules_config["ta_warn"].description
      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["WARN"]
          check-item-detail = {
            Service = split(",", var.aws_services)
          }
        }
        detail-type = ["Trusted Advisor Check Item Refresh Notification"]
        source      = ["aws.trustedadvisor"]
      })
      state = var.event_rules_config["ta_warn"].state
      targets = [
        {
          arn      = var.event_bus_arn
          id       = var.event_rules_config["ta_warn"].targets[0].id
          role_arn = module.iam.iam_role_arns["ta_warn_rule_events_role"]
        }
      ]
      tags = local.merged_tags
    }

    ta_error = {
      name        = format("%s-%s", var.master_prefix, var.event_rules_config["ta_error"].name)
      description = var.event_rules_config["ta_error"].description
      event_pattern = jsonencode({
        account = [data.aws_caller_identity.current.account_id]
        detail = {
          status = ["ERROR"]
          check-item-detail = {
            Service = split(",", var.aws_services)
          }
        }
        detail-type = ["Trusted Advisor Check Item Refresh Notification"]
        source      = ["aws.trustedadvisor"]
      })
      state = var.event_rules_config["ta_error"].state
      targets = [
        {
          arn      = var.event_bus_arn
          id       = var.event_rules_config["ta_error"].targets[0].id
          role_arn = module.iam.iam_role_arns["ta_error_rule_events_role"]
        }
      ]
      tags = local.merged_tags
    }

    ta_refresher = {
      name                = format("%s-%s", var.master_prefix, var.event_rules_config["ta_refresher"].name)
      description         = var.event_rules_config["ta_refresher"].description
      schedule_expression = var.ta_refresh_rate
      state               = var.event_rules_config["ta_refresher"].state
      targets = [
        {
          arn = module.lambda.lambda_function_arns["ta_refresher"]
          id  = var.event_rules_config["ta_refresher"].targets[0].id
        }
      ]
      tags = local.merged_tags
    }
  }

  depends_on = [
    module.lambda,
    module.iam
  ]
}
module "event_rule" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  event_rules = {
    for key, rule in var.event_rules_config : key => {
      name                = "${var.master_prefix}-${rule.name}"
      description         = rule.description
      event_bus_name      = try(rule.event_bus_name != null ? module.event_bus.eventbridge_bus_names[rule.event_bus_name] : null, null)
      state               = rule.state
      schedule_expression = try(rule.schedule_expression, null)

      event_pattern = try(rule.event_pattern != null ? jsonencode(merge(
        rule.event_pattern,
        {
          account = try(rule.event_pattern.account != null ? rule.event_pattern.account : [data.aws_caller_identity.current.account_id], null)
        }
      )) : null, null)

      targets = [
        for target in rule.targets : {
          arn = replace(target.arn, "TARGET_ARN", {
            sns_publisher     = module.lambda.lambda_function_arns["sns_publisher"]
            list_manager      = module.lambda.lambda_function_arns["list_manager"]
            cw_poller         = module.lambda.lambda_function_arns["qmcw_poller"]
            utilization_ok    = var.event_bus_arn
            utilization_warn  = var.event_bus_arn
            utilization_error = var.event_bus_arn
            spoke_sns         = "arn:${data.aws_partition.current.partition}:events:${var.spoke_sns_region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.master_prefix}-${var.event_bus_config.sns_spoke.bus_name}"
            ta_ok             = var.event_bus_arn
            ta_warn           = var.event_bus_arn
            ta_error          = var.event_bus_arn
            ta_refresher      = module.lambda.lambda_function_arns["ta_refresher"]
          }[key])
          id       = target.id
          role_arn = try(target.role_arn != null ? module.iam.iam_role_arns[target.role_arn] : null, null)
        }
      ]

      tags = merge(
        {
          Name = "${var.master_prefix}-${rule.name}"
        },
        try(rule.tags, {}),
        local.merged_tags
      )
    }
  }

  depends_on = [
    module.lambda,
    module.event_bus,
    module.iam
  ]
}
# IAM role configurations
variable "iam_role_names" {
  description = "Names for IAM roles"
  type        = map(string)
  default = {
    ta_ok_rule_events_role      = "TAOkRuleEventsRole"
    ta_warn_rule_events_role    = "TAWarnRuleEventsRole"
    ta_error_rule_events_role   = "TAErrorRuleEventsRole"
    qm_ta_refresher_lambda_role = "TARefresher-Lambda-Role"
  }
}

module "iam" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix
  create_role   = true

  iam_roles = {
    ta_ok_rule_events_role = {
      name = var.iam_role_names["ta_ok_rule_events_role"]
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })
      policies = {
        ta_ok_rule_events_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }
      tags = local.merged_tags
    }

    ta_warn_rule_events_role = {
      name = var.iam_role_names["ta_warn_rule_events_role"]
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })
      policies = {
        ta_warn_rule_events_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }
      tags = local.merged_tags
    }

    ta_error_rule_events_role = {
      name = var.iam_role_names["ta_error_rule_events_role"]
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })
      policies = {
        ta_error_rule_events_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }
      tags = local.merged_tags
    }

    qm_ta_refresher_lambda_role = {
      name = var.iam_role_names["qm_ta_refresher_lambda_role"]
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
      additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
      policies = {
        qm_ta_refresher_lambda_service_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage"
              ]
              Resource = module.sqs.sqs_queue_arns["qmta_refresher_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "support:RefreshTrustedAdvisorCheck"
              ]
              Resource = "*"
            }
          ]
        })
      }
      tags = local.merged_tags
    }
  }
}
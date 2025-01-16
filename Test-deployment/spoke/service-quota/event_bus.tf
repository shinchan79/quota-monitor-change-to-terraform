module "event_bus" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  event_buses = {
    sns_spoke = {
      name = var.event_bus_config["sns_spoke"].bus_name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = var.event_bus_config["sns_spoke"].policy_sid
            Effect = "Allow"
            Principal = {
              AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_config["sns_spoke"].resource_name}"
          }
        ]
      })
      tags = merge(
        {
          Name = var.event_bus_config["sns_spoke"].bus_name
        },
        local.merged_tags
      )
    }
    quota_monitor_spoke = {
      name = var.event_bus_config["quota_monitor_spoke"].bus_name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = var.event_bus_config["quota_monitor_spoke"].policy_sid
            Effect = "Allow"
            Principal = {
              AWS = "*"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_config["quota_monitor_spoke"].resource_name}"
            Condition = {
              StringEquals = {
                "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
              }
            }
          }
        ]
      })
      tags = merge(
        {
          Name = var.event_bus_config["quota_monitor_spoke"].bus_name
        },
        local.merged_tags
      )
    }
  }
}
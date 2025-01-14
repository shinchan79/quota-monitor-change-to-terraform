module "event_bus" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_event = true
  event_buses = {
    quota_monitor = {
      name = var.event_bus_config.bus_name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = var.event_bus_config.policy_sid
            Effect = "Allow"
            Principal = {
              AWS = "*"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_config.resource_name}"
            Condition = {
              StringEquals = {
                "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
              }
            }
          }
        ]
      })
      tags = merge({
        Name = var.event_bus_config.bus_name
      }, local.merged_tags)
    }
  }
}

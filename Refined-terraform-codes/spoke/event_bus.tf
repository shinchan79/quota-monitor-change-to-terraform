module "event_bus" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  create_event = true
  event_buses = {
    for key, bus in var.event_bus_config : key => {
      name = bus.bus_name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = bus.policy_sid
            Effect = "Allow"
            Principal = {
              AWS = contains(["sns_spoke"], key) ? (
                "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
              ) : "*"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${bus.resource_name}"
            Condition = contains(["quota_monitor_spoke"], key) ? {
              StringEquals = {
                "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
              }
            } : null
          }
        ]
      })
      tags = merge(
        {
          Name = bus.bus_name
        },
        local.merged_tags
      )
    }
  }
}
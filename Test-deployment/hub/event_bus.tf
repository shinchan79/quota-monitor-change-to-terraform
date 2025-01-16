module "event_bus" {
  source = "../modules"
  create = local.create_hub_resources

  master_prefix = var.master_prefix
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
              AWS = "*"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${bus.resource_name}"
            Condition = {
              StringEquals = {
                "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
              }
            }
          }
        ]
      })
      tags = merge({
        Name = bus.bus_name
      }, local.merged_tags)
    }
  }
}
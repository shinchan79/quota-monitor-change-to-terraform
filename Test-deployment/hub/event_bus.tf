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
            Sid    = "AllowPutEvents"
            Effect = "Allow"
            Principal = {
              Service = ["trustedadvisor.amazonaws.com", "servicequotas.amazonaws.com"]
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${bus.resource_name}"
          }
        ]
      })
      tags = merge({
        Name = bus.bus_name
      }, local.merged_tags)
    }
  }
}
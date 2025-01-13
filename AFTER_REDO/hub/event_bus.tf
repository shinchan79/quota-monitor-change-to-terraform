module "event_bus" {
  source = "../modules"

  create        = true
  master_prefix = "qm"
  # Eventbus 
  create_event = true
  event_buses = {
    quota_monitor = {
      name = "QuotaMonitorBus"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "AllowPutEvents"
            Effect = "Allow"
            Principal = {
              AWS = "*"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/qm-QuotaMonitorBus"
            Condition = {
              StringEquals = {
                "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
              }
            }
          }
        ]
      })
      tags = {
        Name = "QuotaMonitorBus"
      }
    }
  }
}
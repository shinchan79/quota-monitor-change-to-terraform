# module "event_bus" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"
#   # Eventbus 
#   create_event = true
#   event_buses = {
#     quota_monitor = {
#       name = "QuotaMonitorBus"
#       policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Sid    = "AllowPutEvents"
#             Effect = "Allow"
#             Principal = {
#               AWS = "*"
#             }
#             Action   = "events:PutEvents"
#             Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/qm-QuotaMonitorBus"
#             Condition = {
#               StringEquals = {
#                 "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
#               }
#             }
#           }
#         ]
#       })
#       tags = {
#         Name = "QuotaMonitorBus"
#       }
#     }
#   }
# }

module "event_bus" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_event = true
  event_buses = {
    quota_monitor = {
      name = var.event_bus_name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = var.event_bus_policy_sid
            Effect = "Allow"
            Principal = {
              AWS = "*"
            }
            Action   = "events:PutEvents"
            Resource = "arn:${data.aws_partition.current.partition}:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/${var.event_bus_resource_name}"
            Condition = {
              StringEquals = {
                "aws:PrincipalOrgID" = data.aws_organizations_organization.current.id
              }
            }
          }
        ]
      })
      tags = {
        Name = var.event_bus_name
      }
    }
  }
}

variable "event_bus_name" {
  description = "Name of the EventBridge event bus"
  type        = string
  default     = "QuotaMonitorBus"
}

variable "event_bus_policy_sid" {
  description = "Statement ID for the event bus policy"
  type        = string
  default     = "AllowPutEvents"
}

variable "event_bus_resource_name" {
  description = "Resource name for the event bus ARN"
  type        = string
  default     = "qm-QuotaMonitorBus"
}
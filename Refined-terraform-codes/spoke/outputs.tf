################# SNS Spoke
output "spoke_sns_eventbus" {
  description = "SNS Event Bus Arn in spoke account"
  value       = module.event_bus.eventbridge_bus_arns["sns_spoke"]
}
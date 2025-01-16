locals {
  ssm_parameters = {
    notification_muting_config = "/QuotaMonitor/spoke/NotificationConfiguration"
  }

  spoke_sns_region_exists = var.spoke_sns_region != ""

  quota_monitor_map = {
    ssm_parameters          = local.ssm_parameters
    spoke_sns_region_exists = local.spoke_sns_region_exists
  }

  # Common lambda function ARN format
  list_manager_function_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.master_prefix}-ListManager-Function"

  # Merged tags for all resources
  merged_tags = merge(
    {
      Application = "QuotaMonitor"
      Environment = "Spoke"
    },
    var.tags
  )
}
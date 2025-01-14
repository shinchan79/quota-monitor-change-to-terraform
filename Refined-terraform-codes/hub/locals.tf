locals {
  quota_monitor_map = {
    Metrics = {
      MetricsEndpoint    = "https://metrics.awssolutionsbuilder.com/generic"
      SendAnonymizedData = "Yes"
    }
    SSMParameters = {
      SlackHook                = "/QuotaMonitor/SlackHook"
      OrganizationalUnits      = "/QuotaMonitor/OUs"
      Accounts                 = "/QuotaMonitor/Accounts"
      NotificationMutingConfig = "/QuotaMonitor/NotificationConfiguration"
      RegionsList              = "/QuotaMonitor/RegionsToDeploy"
    }
  }

  merged_tags = merge(
    var.tags,
    var.additional_tags
  )
}
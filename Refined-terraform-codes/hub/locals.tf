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

  sns_arn = var.create_sns ? module.sns.sns_topic_arns["publisher"] : var.existing_sns_arn
  kms_arn = var.create_kms ? module.kms.kms_key_arns["qm_encryption"] : var.existing_kms_arn
}
locals {
  ssm_parameters = {
    notification_muting_config = "/QuotaMonitor/spoke/NotificationConfiguration"
  }

  spoke_sns_region_exists = var.spoke_sns_region != ""

  quota_monitor_map = {
    ################# SNS Spoke
    SSMParameters = local.ssm_parameters,

    ################# QM Spoke
    ssm_parameters          = local.ssm_parameters,
    spoke_sns_region_exists = local.spoke_sns_region_exists,

    ################# TA Spoke
    ssm_parameters          = local.ssm_parameters,
    spoke_sns_region_exists = local.spoke_sns_region_exists
  }
}
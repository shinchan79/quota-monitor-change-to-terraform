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
      RegionsList             = "/QuotaMonitor/RegionsToDeploy"
    }
  }

  # Add conditions equivalent
  conditions = {
    email_true_condition = var.sns_email != ""
    slack_true_condition = var.slack_notification == "Yes"
    account_deploy_condition = var.deployment_model == "Hybrid"
    is_china_partition = data.aws_partition.current.partition == "aws-cn"
  }

  # Add supported regions list if needed
  supported_regions = [
    "af-south-1", "ap-east-1", "ap-northeast-1", "ap-northeast-2",
    "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ca-central-1",
    "cn-north-1", "cn-northwest-1", "eu-central-1", "eu-north-1",
    "eu-south-1", "eu-west-1", "eu-west-2", "eu-west-3",
    "il-central-1", "me-central-1", "me-south-1", "sa-east-1",
    "us-east-1", "us-east-2", "us-west-1", "us-west-2"
  ]
}
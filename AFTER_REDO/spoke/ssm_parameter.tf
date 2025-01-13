module "ssm_parameter" {
  source = "../modules"

  create               = true
  master_prefix        = "qm"
  create_ssm_parameter = true

  ssm_parameters = {
    ################# SNS Spoke
    notification_muting = {
      name        = local.quota_monitor_map.SSMParameters.notification_muting_config
      description = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
      type        = "StringList"
      value       = "NOP"
      tier        = "Standard"
      tags = {
        Name = "QuotaMonitor-NotificationMuting"
      }
    }
  }
}
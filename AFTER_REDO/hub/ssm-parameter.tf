module "ssm_parameter" {
  source = "../modules"

  create               = true
  master_prefix        = "qm"
  create_ssm_parameter = true

  ssm_parameters = {
    slack_webhook = {
      name        = local.quota_monitor_map.SSMParameters.SlackHook
      description = "Slack Hook URL to send Quota Monitor events"
      type        = "String"
      value       = "NOP"
      tier        = "Standard"
      create      = var.slack_notification == "Yes"
      tags = {
        Name = "QuotaMonitor-SlackHook"
      }
    }

    organizational_units = {
      name        = local.quota_monitor_map.SSMParameters.OrganizationalUnits
      description = "List of target Organizational Units"
      type        = "StringList"
      value       = "NOP"
      tier        = "Standard"
      tags = {
        Name = "QuotaMonitor-OUs"
      }
    }

    target_accounts = {
      name        = local.quota_monitor_map.SSMParameters.Accounts
      description = "List of target Accounts"
      type        = "StringList"
      value       = "NOP"
      tier        = "Standard"
      create      = var.account_deployment
      tags = {
        Name = "QuotaMonitor-Accounts"
      }
    }

    notification_muting = {
      name        = local.quota_monitor_map.SSMParameters.NotificationMutingConfig
      description = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
      type        = "StringList"
      value       = "NOP"
      tier        = "Standard"
      tags = {
        Name = "QuotaMonitor-NotificationMuting"
      }
    }

    regions_list = {
      name        = local.quota_monitor_map.SSMParameters.RegionsList
      description = "list of regions to deploy spoke resources (eg. us-east-1,us-west-2)"
      type        = "StringList"
      value       = var.regions_list
      tier        = "Standard"
      tags = {
        Name = "QuotaMonitor-RegionsList"
      }
    }
  }
}

variable "account_deployment" {
  type    = bool
  default = false
}
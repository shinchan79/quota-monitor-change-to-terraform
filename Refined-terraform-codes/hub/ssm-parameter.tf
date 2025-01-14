module "ssm_parameter" {
  source = "../modules"

  create               = true
  master_prefix        = "qm"
  create_ssm_parameter = true

  ssm_parameters = {
    slack_webhook = {
      name        = local.quota_monitor_map.SSMParameters.SlackHook
      description = var.ssm_parameters_config["slack_webhook"].description
      type        = var.ssm_parameters_config["slack_webhook"].type
      value       = var.ssm_parameters_config["slack_webhook"].value
      tier        = var.ssm_parameters_config["slack_webhook"].tier
      create      = var.slack_notification == "Yes"
      tags        = var.tags
    }

    organizational_units = {
      name        = local.quota_monitor_map.SSMParameters.OrganizationalUnits
      description = var.ssm_parameters_config["organizational_units"].description
      type        = var.ssm_parameters_config["organizational_units"].type
      value       = var.ssm_parameters_config["organizational_units"].value
      tier        = var.ssm_parameters_config["organizational_units"].tier
      tags        = var.tags
    }

    target_accounts = {
      name        = local.quota_monitor_map.SSMParameters.Accounts
      description = var.ssm_parameters_config["target_accounts"].description
      type        = var.ssm_parameters_config["target_accounts"].type
      value       = var.ssm_parameters_config["target_accounts"].value
      tier        = var.ssm_parameters_config["target_accounts"].tier
      create      = var.account_deployment
      tags        = var.tags
    }

    notification_muting = {
      name        = local.quota_monitor_map.SSMParameters.NotificationMutingConfig
      description = var.ssm_parameters_config["notification_muting"].description
      type        = var.ssm_parameters_config["notification_muting"].type
      value       = var.ssm_parameters_config["notification_muting"].value
      tier        = var.ssm_parameters_config["notification_muting"].tier
      tags        = var.tags
    }

    regions_list = {
      name        = local.quota_monitor_map.SSMParameters.RegionsList
      description = var.ssm_parameters_config["regions_list"].description
      type        = var.ssm_parameters_config["regions_list"].type
      value       = var.regions_list
      tier        = var.ssm_parameters_config["regions_list"].tier
      tags        = var.tags
    }
  }
}

variable "ssm_parameters_config" {
  description = "Configuration for SSM parameters"
  type = map(object({
    description = string
    type        = string
    value       = optional(string, "NOP")
    tier        = optional(string, "Standard")
  }))
  default = {
    slack_webhook = {
      description = "Slack Hook URL to send Quota Monitor events"
      type        = "String"
    }
    organizational_units = {
      description = "List of target Organizational Units"
      type        = "StringList"
    }
    target_accounts = {
      description = "List of target Accounts"
      type        = "StringList"
    }
    notification_muting = {
      description = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
      type        = "StringList"
    }
    regions_list = {
      description = "list of regions to deploy spoke resources (eg. us-east-1,us-west-2)"
      type        = "StringList"
    }
  }
}

variable "account_deployment" {
  description = "Whether to enable account deployment"
  type        = bool
  default     = false
}
# module "ssm_parameter" {
#   source = "../modules"

#   create               = true
#   master_prefix        = "qm"
#   create_ssm_parameter = true

#   ssm_parameters = {
#     slack_webhook = {
#       name        = local.quota_monitor_map.SSMParameters.SlackHook
#       description = "Slack Hook URL to send Quota Monitor events"
#       type        = "String"
#       value       = "NOP"
#       tier        = "Standard"
#       create      = var.slack_notification == "Yes"
#       tags = {
#         Name = "QuotaMonitor-SlackHook"
#       }
#     }

#     organizational_units = {
#       name        = local.quota_monitor_map.SSMParameters.OrganizationalUnits
#       description = "List of target Organizational Units"
#       type        = "StringList"
#       value       = "NOP"
#       tier        = "Standard"
#       tags = {
#         Name = "QuotaMonitor-OUs"
#       }
#     }

#     target_accounts = {
#       name        = local.quota_monitor_map.SSMParameters.Accounts
#       description = "List of target Accounts"
#       type        = "StringList"
#       value       = "NOP"
#       tier        = "Standard"
#       create      = var.account_deployment
#       tags = {
#         Name = "QuotaMonitor-Accounts"
#       }
#     }

#     notification_muting = {
#       name        = local.quota_monitor_map.SSMParameters.NotificationMutingConfig
#       description = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
#       type        = "StringList"
#       value       = "NOP"
#       tier        = "Standard"
#       tags = {
#         Name = "QuotaMonitor-NotificationMuting"
#       }
#     }

#     regions_list = {
#       name        = local.quota_monitor_map.SSMParameters.RegionsList
#       description = "list of regions to deploy spoke resources (eg. us-east-1,us-west-2)"
#       type        = "StringList"
#       value       = var.regions_list
#       tier        = "Standard"
#       tags = {
#         Name = "QuotaMonitor-RegionsList"
#       }
#     }
#   }
# }

# variable "account_deployment" {
#   type    = bool
#   default = false
# }

module "ssm_parameter" {
  source = "../modules"

  create               = true
  master_prefix        = "qm"
  create_ssm_parameter = true

  ssm_parameters = {
    slack_webhook = {
      name        = local.quota_monitor_map.SSMParameters.SlackHook
      description = var.slack_webhook_description
      type        = var.ssm_string_type
      value       = var.ssm_default_value
      tier        = var.ssm_tier
      create      = var.slack_notification == "Yes"
      tags = {
        Name = var.slack_webhook_tag_name
      }
    }

    organizational_units = {
      name        = local.quota_monitor_map.SSMParameters.OrganizationalUnits
      description = var.ou_parameter_description
      type        = var.ssm_stringlist_type
      value       = var.ssm_default_value
      tier        = var.ssm_tier
      tags = {
        Name = var.ou_parameter_tag_name
      }
    }

    target_accounts = {
      name        = local.quota_monitor_map.SSMParameters.Accounts
      description = var.accounts_parameter_description
      type        = var.ssm_stringlist_type
      value       = var.ssm_default_value
      tier        = var.ssm_tier
      create      = var.account_deployment
      tags = {
        Name = var.accounts_parameter_tag_name
      }
    }

    notification_muting = {
      name        = local.quota_monitor_map.SSMParameters.NotificationMutingConfig
      description = var.notification_muting_description
      type        = var.ssm_stringlist_type
      value       = var.ssm_default_value
      tier        = var.ssm_tier
      tags = {
        Name = var.notification_muting_tag_name
      }
    }

    regions_list = {
      name        = local.quota_monitor_map.SSMParameters.RegionsList
      description = var.regions_list_description
      type        = var.ssm_stringlist_type
      value       = var.regions_list
      tier        = var.ssm_tier
      tags = {
        Name = var.regions_list_tag_name
      }
    }
  }
}

# Common Variables
variable "ssm_string_type" {
  description = "SSM parameter type for string values"
  type        = string
  default     = "String"
}

variable "ssm_stringlist_type" {
  description = "SSM parameter type for string list values"
  type        = string
  default     = "StringList"
}

variable "ssm_default_value" {
  description = "Default value for SSM parameters"
  type        = string
  default     = "NOP"
}

variable "ssm_tier" {
  description = "SSM parameter tier"
  type        = string
  default     = "Standard"
}

# Parameter Descriptions
variable "slack_webhook_description" {
  description = "Description for Slack webhook parameter"
  type        = string
  default     = "Slack Hook URL to send Quota Monitor events"
}

variable "ou_parameter_description" {
  description = "Description for organizational units parameter"
  type        = string
  default     = "List of target Organizational Units"
}

variable "accounts_parameter_description" {
  description = "Description for target accounts parameter"
  type        = string
  default     = "List of target Accounts"
}

variable "notification_muting_description" {
  description = "Description for notification muting parameter"
  type        = string
  default     = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
}

variable "regions_list_description" {
  description = "Description for regions list parameter"
  type        = string
  default     = "list of regions to deploy spoke resources (eg. us-east-1,us-west-2)"
}

# Parameter Tag Names
variable "slack_webhook_tag_name" {
  description = "Tag name for Slack webhook parameter"
  type        = string
  default     = "QuotaMonitor-SlackHook"
}

variable "ou_parameter_tag_name" {
  description = "Tag name for organizational units parameter"
  type        = string
  default     = "QuotaMonitor-OUs"
}

variable "accounts_parameter_tag_name" {
  description = "Tag name for target accounts parameter"
  type        = string
  default     = "QuotaMonitor-Accounts"
}

variable "notification_muting_tag_name" {
  description = "Tag name for notification muting parameter"
  type        = string
  default     = "QuotaMonitor-NotificationMuting"
}

variable "regions_list_tag_name" {
  description = "Tag name for regions list parameter"
  type        = string
  default     = "QuotaMonitor-RegionsList"
}

variable "account_deployment" {
  description = "Whether to enable account deployment"
  type        = bool
  default     = false
}
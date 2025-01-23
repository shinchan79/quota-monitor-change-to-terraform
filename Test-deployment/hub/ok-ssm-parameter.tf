module "ssm_parameter" {
  source = "../modules"

  create               = local.create_hub_resources
  master_prefix        = var.master_prefix
  create_ssm_parameter = true

  ssm_parameters = {
    notification_muting = {
      name        = var.ssm_parameters_config["notification_muting"].name
      description = var.ssm_parameters_config["notification_muting"].description
      type        = var.ssm_parameters_config["notification_muting"].type
      value       = var.ssm_parameters_config["notification_muting"].value
      tier        = var.ssm_parameters_config["notification_muting"].tier
      tags = merge(
        {
          Name = format("/%s%s", var.master_prefix, var.ssm_parameters_config["notification_muting"].name)
        },
        try(var.ssm_parameters_config["notification_muting"].tags, {}),
        local.merged_tags
      )
    }

    # Thêm target_accounts parameter
    target_accounts = {
      name        = var.ssm_parameters_config["target_accounts"].name
      description = var.ssm_parameters_config["target_accounts"].description
      type        = var.ssm_parameters_config["target_accounts"].type
      value       = var.ssm_parameters_config["target_accounts"].value
      tier        = var.ssm_parameters_config["target_accounts"].tier
      tags = merge(
        {
          Name = format("/%s%s", var.master_prefix, var.ssm_parameters_config["target_accounts"].name)
        },
        try(var.ssm_parameters_config["target_accounts"].tags, {}),
        local.merged_tags
      )
    }
  }
}

    # "QMSlackHook4F1AD495": {
    #   "Type": "AWS::SSM::Parameter",
    #   "Properties": {
    #     "Description": "Slack Hook URL to send Quota Monitor events",
    #     "Name": {
    #       "Fn::FindInMap": [
    #         "QuotaMonitorMap",
    #         "SSMParameters",
    #         "SlackHook"
    #       ]
    #     },
    #     "Type": "String",
    #     "Value": "NOP"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackHook/Resource"
    #   },
    #   "Condition": "SlackTrueCondition"
    # },
    # "QMAccounts3D743F6B": {
    #   "Type": "AWS::SSM::Parameter",
    #   "Properties": {
    #     "Description": "List of target Accounts",
    #     "Name": {
    #       "Fn::FindInMap": [
    #         "QuotaMonitorMap",
    #         "SSMParameters",
    #         "Accounts"
    #       ]
    #     },
    #     "Type": "StringList",
    #     "Value": "NOP"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Accounts/Resource"
    #   }
    # },
    # "QMNotificationMutingConfig3B7948BA": {
    #   "Type": "AWS::SSM::Parameter",
    #   "Properties": {
    #     "Description": "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D",
    #     "Name": {
    #       "Fn::FindInMap": [
    #         "QuotaMonitorMap",
    #         "SSMParameters",
    #         "NotificationMutingConfig"
    #       ]
    #     },
    #     "Type": "StringList",
    #     "Value": "NOP"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-NotificationMutingConfig/Resource"
    #   }
    # },
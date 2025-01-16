# module "ssm_parameter" {
#   source = "../modules"

#   create               = local.create_hub_resources
#   master_prefix        = var.master_prefix
#   create_ssm_parameter = true

#   ssm_parameters = {
#     # slack_webhook = {
#     #   name        = var.ssm_parameters_config["slack_webhook"].name
#     #   description = var.ssm_parameters_config["slack_webhook"].description
#     #   type        = var.ssm_parameters_config["slack_webhook"].type
#     #   value       = var.ssm_parameters_config["slack_webhook"].value
#     #   tier        = var.ssm_parameters_config["slack_webhook"].tier
#     #   create      = var.slack_notification == "Yes"
#     #   tags = merge(
#     #     {
#     #       Name = var.ssm_parameters_config["slack_webhook"].name
#     #     },
#     #     var.ssm_parameters_config["slack_webhook"].tags,
#     #     local.merged_tags
#     #   )
#     # }

#     # organizational_units = {
#     #   name        = var.ssm_parameters_config["organizational_units"].name
#     #   description = var.ssm_parameters_config["organizational_units"].description
#     #   type        = var.ssm_parameters_config["organizational_units"].type
#     #   value       = var.ssm_parameters_config["organizational_units"].value
#     #   tier        = var.ssm_parameters_config["organizational_units"].tier
#     #   tags = merge(
#     #     {
#     #       Name = var.ssm_parameters_config["organizational_units"].name
#     #     },
#     #     var.ssm_parameters_config["organizational_units"].tags,
#     #     local.merged_tags
#     #   )
#     # }

#     # target_accounts = {
#     #   name        = var.ssm_parameters_config["target_accounts"].name
#     #   description = var.ssm_parameters_config["target_accounts"].description
#     #   type        = var.ssm_parameters_config["target_accounts"].type
#     #   value       = var.ssm_parameters_config["target_accounts"].value
#     #   tier        = var.ssm_parameters_config["target_accounts"].tier
#     #   create      = var.account_deployment
#     #   tags = merge(
#     #     {
#     #       Name = var.ssm_parameters_config["target_accounts"].name
#     #     },
#     #     var.ssm_parameters_config["target_accounts"].tags,
#     #     local.merged_tags
#     #   )
#     # }

#     notification_muting = {
#       name        = format("/%s/%s", var.master_prefix, var.ssm_parameters_config["notification_muting"].name)
#       description = var.ssm_parameters_config["notification_muting"].description
#       type        = var.ssm_parameters_config["notification_muting"].type
#       value       = var.ssm_parameters_config["notification_muting"].value
#       tier        = var.ssm_parameters_config["notification_muting"].tier
#       tags = merge(
#         {
#           Name = format("/%s/%s", var.master_prefix, var.ssm_parameters_config["notification_muting"].name)
#         },
#         var.ssm_parameters_config["notification_muting"].tags,
#         local.merged_tags
#       )
#     }

#     # regions_list = {
#     #   name        = var.ssm_parameters_config["regions_list"].name
#     #   description = var.ssm_parameters_config["regions_list"].description
#     #   type        = var.ssm_parameters_config["regions_list"].type
#     #   value       = var.regions_list
#     #   tier        = var.ssm_parameters_config["regions_list"].tier
#     #   tags = merge(
#     #     {
#     #       Name = var.ssm_parameters_config["regions_list"].name
#     #     },
#     #     var.ssm_parameters_config["regions_list"].tags,
#     #     local.merged_tags
#     #   )
#     # }
#   }
# }

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
  }
}
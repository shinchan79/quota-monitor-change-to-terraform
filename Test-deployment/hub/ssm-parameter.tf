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
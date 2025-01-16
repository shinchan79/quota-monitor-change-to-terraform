module "ssm_parameter" {
  source = "../modules"

  create               = true
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
          Name = var.ssm_parameters_config["notification_muting"].name
        },
        var.ssm_parameters_config["notification_muting"].tags,
        local.merged_tags
      )
    }
  }
}
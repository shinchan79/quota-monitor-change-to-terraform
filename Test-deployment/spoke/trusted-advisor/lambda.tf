# Create archive files if needed
data "archive_file" "lambda" {
  for_each = var.create_archive ? {
    for k, v in var.lambda_functions_config : k => v
    if lookup(v, "source_dir", null) != null
  } : {}

  type        = "zip"
  source_file = format("${path.module}/%s/%s.py", each.value.source_dir, each.key)
  output_path = "${path.module}/archive_file/${each.key}.zip"
}

module "lambda" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  lambda_functions = {
    ta_refresher = {
      name        = var.lambda_functions_config["ta_refresher"].name
      description = var.lambda_functions_config["ta_refresher"].description
      runtime     = var.lambda_functions_config["ta_refresher"].runtime
      handler     = var.lambda_functions_config["ta_refresher"].handler
      timeout     = var.lambda_functions_config["ta_refresher"].timeout
      memory_size = var.lambda_functions_config["ta_refresher"].memory_size
      role_arn    = module.iam.iam_role_arns["qm_ta_refresher_lambda_role"]

      # Source code logic
      filename  = local.lambda_source["ta_refresher"].filename
      s3_bucket = local.lambda_source["ta_refresher"].s3_bucket
      s3_key    = local.lambda_source["ta_refresher"].s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmta_refresher_dlq"]
      }

      layers = [module.lambda_layer.lambda_layer_arns["utils_ta"]]

      environment_variables = {
        AWS_SERVICES          = var.aws_services
        LOG_LEVEL             = var.lambda_functions_config["ta_refresher"].environment_log_level
        CUSTOM_SDK_USER_AGENT = var.lambda_functions_config["ta_refresher"].sdk_user_agent
        VERSION               = var.lambda_functions_config["ta_refresher"].app_version
        SOLUTION_ID           = var.lambda_functions_config["ta_refresher"].solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = var.lambda_functions_config["ta_refresher"].max_event_age
        qualifier                    = var.lambda_functions_config["ta_refresher"].lambda_qualifier
      }

      logging_config = {
        log_format = var.lambda_functions_config["ta_refresher"].log_format
        log_group  = var.lambda_functions_config["ta_refresher"].log_group
        log_level  = var.lambda_functions_config["ta_refresher"].log_level
      }

      tags = merge(
        {
          Name = format("%s-%s", var.master_prefix, var.lambda_functions_config["ta_refresher"].name)
        },
        try(var.lambda_functions_config["ta_refresher"].tags, {}),
        local.merged_tags
      )
    }
  }

  depends_on = [
    module.iam,
    module.lambda_layer,
    module.sqs
  ]
}
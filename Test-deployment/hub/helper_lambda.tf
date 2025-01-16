# Create archive for helper lambda if needed
data "archive_file" "helper_lambda" {
  for_each = var.create_archive && local.create_hub_resources ? {
    for k, v in { "helper" = var.helper_config.lambda_function } : k => v
    if lookup(v, "source_dir", null) != null
  } : {}

  type        = "zip"
  source_file = format("${path.module}/%s/%s.py", each.value.source_dir, each.key)
  output_path = "${path.module}/archive_file/${each.key}.zip"
}

module "helper_lambda" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  lambda_functions = {
    helper = merge(
      {
        name        = var.helper_config.lambda_function.name
        description = var.helper_config.lambda_function.description
        runtime     = var.helper_config.lambda_function.runtime
        handler     = var.helper_config.lambda_function.handler
        timeout     = var.helper_config.lambda_function.timeout
        memory_size = var.helper_config.lambda_function.memory_size
        role_arn    = module.iam.iam_role_arns["lambda_helper"]
      },
      # Sử dụng logic source code giống như các lambda functions khác
      {
        filename = var.create_s3 ? "${path.module}/${var.source_code_objects["helper"].source_path}" : (
          lookup(var.helper_config.lambda_function, "local_source.filename", null) != null ?
          var.helper_config.lambda_function.local_source.filename : null
        )
        s3_bucket = !var.create_s3 ? var.helper_config.lambda_code.s3_bucket : null
        s3_key    = !var.create_s3 ? var.helper_config.lambda_code.s3_key : null
      },
      {
        security_group_ids = var.vpc_config.security_group_ids
        subnet_ids         = var.vpc_config.subnet_ids

        environment_variables = {
          STACK_ID              = var.helper_config.lambda_environment.stack_id
          CUSTOM_SDK_USER_AGENT = var.helper_config.lambda_environment.sdk_user_agent
          VERSION               = var.helper_config.lambda_environment.version
          SOLUTION_ID           = var.helper_config.lambda_environment.solution_id
        }

        event_invoke_config = {
          maximum_event_age_in_seconds = var.helper_config.lambda_event.max_event_age
          qualifier                    = var.helper_config.lambda_event.qualifier
        }

        logging_config = {
          log_format = var.helper_config.lambda_logging.log_format
          log_group  = var.helper_config.lambda_logging.log_group
          log_level  = var.helper_config.lambda_logging.logging_level
        }

        tags = merge(
          {
            Name = var.helper_config.lambda_function.name
          },
          try(var.helper_config.lambda_function.tags, {}),
          local.merged_tags
        )
      }
    )
  }

  depends_on = [
    module.iam,
    module.lambda_layer,
    module.s3
  ]
}
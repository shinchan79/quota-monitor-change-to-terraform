# Create log groups first
resource "aws_cloudwatch_log_group" "lambda" {
  for_each = {
    for k, v in local.lambda_functions_normalized : k => v
    if var.create_lambda && var.create && try(v.logging_config.log_group != null, false)
  }

  name              = format("/aws/lambda/%s", each.value.function_name)
  retention_in_days = var.cloudwatch_log_group.retention_in_days
  log_group_class   = var.cloudwatch_log_group.log_group_class
  kms_key_id        = var.cloudwatch_log_group.kms_key_id

  tags = merge(
    var.additional_tags,
    var.cloudwatch_log_group.tags
  )
}

# Create archive files if needed
data "archive_file" "lambda" {
  for_each = {
    for k, v in local.lambda_functions_normalized : k => v
    if var.create_lambda && var.create && v.source_dir != null && v.s3_bucket == null
  }

  type        = "zip"
  source_file = format("${path.module}/../.%s/%s.py", each.value.source_dir, each.value.name)
  output_path = "${path.module}/archive_file/${each.value.name}.zip"
}

# Create Lambda functions
resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_functions_normalized

  filename         = each.value.s3_bucket == null ? try(data.archive_file.lambda[each.key].output_path, null) : null
  source_code_hash = each.value.s3_bucket == null ? try(data.archive_file.lambda[each.key].output_base64sha256, null) : null

  s3_bucket = each.value.s3_bucket
  s3_key    = each.value.s3_bucket != null ? each.value.s3_key : null

  function_name = each.value.function_name
  role          = try(aws_iam_role.role[each.value.role_key].arn, each.value.role_arn)
  handler       = each.value.handler
  runtime       = each.value.runtime
  timeout       = each.value.timeout
  memory_size   = each.value.memory_size
  architectures = each.value.architectures
  kms_key_arn   = each.value.kms_key_arn
  layers        = try(each.value.layers, null)

  environment {
    variables = each.value.environment_variables
  }

  dynamic "vpc_config" {
    for_each = each.value.security_group_ids != null && each.value.subnet_ids != null ? [1] : []
    content {
      security_group_ids = each.value.security_group_ids
      subnet_ids         = each.value.subnet_ids
    }
  }

  dynamic "logging_config" {
    for_each = each.value.logging_config != null ? [1] : []
    content {
      application_log_level = try(each.value.logging_config.application_log_level, null)
      log_format            = try(each.value.logging_config.log_format, "JSON")
      log_group             = try(aws_cloudwatch_log_group.lambda[each.key].name, each.value.logging_config.log_group)
      system_log_level      = try(each.value.logging_config.system_log_level, "WARN")
    }
  }

  tags = merge(
    var.additional_tags,
    each.value.tags
  )

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# Event invoke config
resource "aws_lambda_function_event_invoke_config" "invoke_config" {
  for_each = {
    for k, v in local.lambda_functions_normalized : k => v
    if var.create_lambda && var.create && v.event_invoke_config != null
  }

  function_name                = aws_lambda_function.lambda[each.key].function_name
  qualifier                    = try(each.value.event_invoke_config.qualifier, "$LATEST")
  maximum_event_age_in_seconds = try(each.value.event_invoke_config.maximum_event_age_in_seconds, null)
  maximum_retry_attempts       = try(each.value.event_invoke_config.maximum_retry_attempts, null)

  dynamic "destination_config" {
    for_each = try(each.value.event_invoke_config.destination_config, null) != null ? [1] : []
    content {
      dynamic "on_failure" {
        for_each = try(each.value.event_invoke_config.destination_config.on_failure, null) != null ? [1] : []
        content {
          destination = each.value.event_invoke_config.destination_config.on_failure.destination_arn
        }
      }
      dynamic "on_success" {
        for_each = try(each.value.event_invoke_config.destination_config.on_success, null) != null ? [1] : []
        content {
          destination = each.value.event_invoke_config.destination_config.on_success.destination_arn
        }
      }
    }
  }

  depends_on = [aws_lambda_function.lambda]
}
# resource "aws_cloudwatch_log_group" "lambda" {
#   for_each = { for k, v in var.lambda_functions : k => v if var.create_lambda && var.create }

#   name              = "/aws/lambda/${each.value.name}"
#   retention_in_days = each.value.logging_config.retention_in_days
#   kms_key_id        = each.value.logging_config.kms_key_id

#   tags = merge(
#     var.additional_tags,
#     each.value.logging_config.log_group_tags
#   )
# }
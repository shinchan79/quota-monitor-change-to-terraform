# =======================================================
# DynamoDB Outputs
# =======================================================
output "dynamodb_table_arns" {
  description = "ARNs of the DynamoDB tables"
  value       = { for k, v in aws_dynamodb_table.table : k => v.arn }
}

output "dynamodb_table_ids" {
  description = "IDs/Names of the DynamoDB tables"
  value       = { for k, v in aws_dynamodb_table.table : k => v.id }
}

output "dynamodb_table_streams" {
  description = "List of stream ARNs of DynamoDB tables"
  value = {
    for k, v in aws_dynamodb_table.table : k => v.stream_arn if v.stream_enabled
  }
}

output "dynamodb_table_stream_arns" {
  description = "List of stream ARNs of DynamoDB tables"
  value = {
    for k, v in aws_dynamodb_table.table : k => v.stream_arn if v.stream_enabled
  }
}

output "dynamodb_table_stream_labels" {
  description = "List of stream labels of DynamoDB tables"
  value = {
    for k, v in aws_dynamodb_table.table : k => v.stream_label if v.stream_enabled
  }
}

# =======================================================
# EventBridge Outputs
# =======================================================
output "eventbridge_bus_arns" {
  description = "ARNs of the EventBridge buses"
  value       = { for k, v in aws_cloudwatch_event_bus.event_bus : k => v.arn }
}

output "eventbridge_rule_arns" {
  description = "ARNs of the EventBridge rules"
  value       = { for k, v in aws_cloudwatch_event_rule.event_rule : k => v.arn }
}

output "eventbridge_bus_names" {
  description = "Names of the EventBridge buses"
  value       = { for k, v in aws_cloudwatch_event_bus.event_bus : k => v.name }
}

# =======================================================
# Lambda Outputs
# =======================================================
output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value = {
    for k, v in aws_lambda_function.lambda : k => v.function_name
  }
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value = {
    for k, v in aws_lambda_function.lambda : k => v.arn
  }
}

output "lambda_function_invoke_arns" {
  description = "Invoke ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.lambda : k => v.invoke_arn }
}

# =======================================================
# IAM Role Outputs
# =======================================================
output "iam_role_arns" {
  description = "ARNs of the IAM roles"
  value       = { for k, v in aws_iam_role.role : k => v.arn }
}

output "iam_role_names" {
  description = "Names of the IAM roles"
  value       = { for k, v in aws_iam_role.role : k => v.name }
}

# =======================================================
# SQS Outputs
# =======================================================
output "sqs_queue_arns" {
  description = "ARNs of the SQS queues"
  value       = { for k, v in aws_sqs_queue.queue : k => v.arn }
}

output "sqs_queue_urls" {
  description = "URLs of the SQS queues"
  value       = { for k, v in aws_sqs_queue.queue : k => v.url }
}

# =======================================================
# SNS Outputs
# =======================================================
output "sns_topic_arns" {
  description = "ARNs of the SNS topics"
  value       = { for k, v in aws_sns_topic.topic : k => v.arn }
}

# =======================================================
# SSM Parameter Outputs
# =======================================================
output "ssm_parameter_arns" {
  description = "ARNs of the SSM parameters"
  value       = { for k, v in aws_ssm_parameter.parameters : k => v.arn }
}

output "ssm_parameter_names" {
  description = "Names of the SSM parameters"
  value       = { for k, v in aws_ssm_parameter.parameters : k => v.name }
}

output "lambda_layer_arns" {
  description = "Map of Lambda Layer ARNs"
  value = {
    for k, v in aws_lambda_layer_version.this : k => v.arn
  }
}

#=========

output "lambda_event_invoke_config_ids" {
  description = "IDs of the Lambda Event Invoke Configs"
  value = {
    for k, v in aws_lambda_function_event_invoke_config.invoke_config : k => v.id
  }
}

#=========

output "lambda_permission_ids" {
  description = "IDs of the Lambda permissions"
  value = {
    for k, v in aws_lambda_permission.this : k => v.id
  }
}

# =======================================================
# KMS Outputs
# =======================================================
output "kms_key_arns" {
  description = "ARNs of the KMS keys"
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "kms_key_ids" {
  description = "IDs of the KMS keys"
  value       = { for k, v in aws_kms_key.this : k => v.id }
}
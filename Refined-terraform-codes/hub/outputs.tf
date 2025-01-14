output "custom_resource_outputs" {
  value = {
    helper_uuid = random_uuid.helper_uuid.result
  }
}

#---------------------------------------------------------------
# Custom Resource Outputs
#---------------------------------------------------------------
output "helper_uuid" {
  description = "UUID generated for helper function"
  value       = random_uuid.helper_uuid.result
}

#---------------------------------------------------------------
# DynamoDB Outputs
#---------------------------------------------------------------
output "dynamodb_table_arns" {
  description = "ARNs of created DynamoDB tables"
  value       = module.dynamodb.dynamodb_table_arns
}

output "dynamodb_table_ids" {
  description = "IDs of created DynamoDB tables"
  value       = module.dynamodb.dynamodb_table_ids
}

#---------------------------------------------------------------
# EventBridge Outputs
#---------------------------------------------------------------
output "eventbridge_bus_arns" {
  description = "ARNs of created EventBridge buses"
  value       = module.event_bus.eventbridge_bus_arns
}

output "eventbridge_bus_names" {
  description = "Names of created EventBridge buses"
  value       = module.event_bus.eventbridge_bus_names
}

output "eventbridge_rule_arns" {
  description = "ARNs of created EventBridge rules"
  value       = module.event_rule.eventbridge_rule_arns
}

#---------------------------------------------------------------
# IAM Role Outputs
#---------------------------------------------------------------
output "iam_role_arns" {
  description = "ARNs of created IAM roles"
  value       = module.iam.iam_role_arns
}

output "iam_role_names" {
  description = "Names of created IAM roles"
  value       = module.iam.iam_role_names
}

#---------------------------------------------------------------
# KMS Outputs
#---------------------------------------------------------------
output "kms_key_arns" {
  description = "ARNs of created KMS keys"
  value       = module.kms.kms_key_arns
}

output "kms_key_ids" {
  description = "IDs of created KMS keys"
  value       = module.kms.kms_key_ids
}

#---------------------------------------------------------------
# Lambda Outputs
#---------------------------------------------------------------
output "lambda_function_arns" {
  description = "ARNs of created Lambda functions"
  value       = module.lambda.lambda_function_arns
}

output "lambda_function_names" {
  description = "Names of created Lambda functions"
  value       = module.lambda.lambda_function_names
}

output "lambda_layer_arns" {
  description = "ARNs of created Lambda layers"
  value       = module.lambda_layer.lambda_layer_arns
}

#---------------------------------------------------------------
# SNS Outputs
#---------------------------------------------------------------
output "sns_topic_arns" {
  description = "ARNs of created SNS topics"
  value       = module.sns.sns_topic_arns
}

#---------------------------------------------------------------
# SQS Outputs
#---------------------------------------------------------------
output "sqs_queue_arns" {
  description = "ARNs of created SQS queues"
  value       = module.sqs.sqs_queue_arns
}

output "sqs_queue_urls" {
  description = "URLs of created SQS queues"
  value       = module.sqs.sqs_queue_urls
}

#---------------------------------------------------------------
# SSM Parameter Outputs
#---------------------------------------------------------------
output "ssm_parameter_arns" {
  description = "ARNs of created SSM parameters"
  value       = module.ssm_parameter.ssm_parameter_arns
}

output "ssm_parameter_names" {
  description = "Names of created SSM parameters"
  value       = module.ssm_parameter.ssm_parameter_names
}

#---------------------------------------------------------------
# Helper Lambda Outputs
#---------------------------------------------------------------
output "helper_lambda_function_arns" {
  description = "ARNs of created helper Lambda functions"
  value       = module.helper_lambda.lambda_function_arns
}

output "helper_lambda_function_names" {
  description = "Names of created helper Lambda functions"
  value       = module.helper_lambda.lambda_function_names
}

#---------------------------------------------------------------
# General Outputs
#---------------------------------------------------------------
output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

output "organization_id" {
  description = "AWS Organizations ID"
  value       = data.aws_organizations_organization.current.id
}
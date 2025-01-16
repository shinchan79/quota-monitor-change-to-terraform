#---------------------------------------------------------------
# EventBridge Outputs
#---------------------------------------------------------------
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

#---------------------------------------------------------------
# Service Checks Output
#---------------------------------------------------------------
output "service_checks" {
  description = "Service limit checks monitored in the account"
  value       = var.aws_services
}
variable "vpc_config" {
  description = "VPC configuration for Lambda function"
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}

variable "regions_list" {
  type        = string
  description = "List of regions to deploy spoke resources"
}

variable "sns_email" {
  type        = string
  description = "Email for SNS notifications"
}

variable "slack_notification" {
  type        = string
  description = "Enable/disable Slack notifications (Yes/No)"
  default     = "No"
}

variable "enable_email" {
  type        = bool
  description = "Enable/disable email notifications"
  default     = false
}

variable "sagemaker_monitoring" {
  type        = string
  description = "Enable/disable SageMaker monitoring (Yes/No)"
  default     = "No"
}

variable "connect_monitoring" {
  type        = string
  description = "Enable/disable Connect monitoring (Yes/No)"
  default     = "No"
}

variable "deployment_model" {
  type        = string
  description = "Deployment model for the solution (SPOKE_REGION/SPOKE_ACCOUNT)"
  default     = "SPOKE_REGION"
}

variable "sns_spoke_region" {
  type        = string
  description = "Region where SNS topics will be created in spoke accounts"
  default     = "us-east-1"
}

variable "region_concurrency" {
  type        = string
  description = "Type of concurrency for regional deployments (SEQUENTIAL/PARALLEL)"
  default     = "SEQUENTIAL"
}

variable "max_concurrent_percentage" {
  type        = number
  description = "Maximum percentage of concurrent deployments"
  default     = 100
}

variable "failure_tolerance_percentage" {
  type        = number
  description = "Percentage of failures that can be tolerated during deployment"
  default     = 0
}

variable "sq_notification_threshold" {
  type        = number
  description = "Threshold percentage for Service Quotas notifications"
  default     = 80
}

variable "sq_monitoring_frequency" {
  type        = number
  description = "Frequency (in minutes) for monitoring Service Quotas"
  default     = 5
}

variable "sq_report_ok_notifications" {
  type        = bool
  description = "Whether to report OK notifications for Service Quotas"
  default     = false
}

variable "enable_account_deploy" {
  type    = bool
  default = true
}
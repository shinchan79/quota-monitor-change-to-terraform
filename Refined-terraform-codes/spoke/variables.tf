################# QM Spoke

variable "notification_threshold" {
  type        = string
  description = "Threshold percentage for quota utilization alerts (0-100)"
  default     = "80"

  validation {
    condition     = can(regex("^([1-9]|[1-9][0-9])$", var.notification_threshold))
    error_message = "Threshold must be a whole number between 0 and 100"
  }
}

variable "monitoring_frequency" {
  type        = string
  description = "Frequency to monitor quota utilization"
  default     = "rate(12 hours)"

  validation {
    condition = contains([
      "rate(6 hours)",
      "rate(12 hours)",
      "rate(1 day)"
    ], var.monitoring_frequency)
    error_message = "monitoring_frequency must be one of: rate(6 hours), rate(12 hours), rate(1 day)"
  }
}

variable "report_ok_notifications" {
  type        = string
  description = "Report OK Notifications"
  default     = "No"

  validation {
    condition     = contains(["Yes", "No"], var.report_ok_notifications)
    error_message = "report_ok_notifications must be either Yes or No"
  }
}

variable "sagemaker_monitoring" {
  type        = string
  description = "Enable monitoring for SageMaker quotas"
  default     = "Yes"

  validation {
    condition     = contains(["Yes", "No"], var.sagemaker_monitoring)
    error_message = "sagemaker_monitoring must be either Yes or No"
  }
}

variable "connect_monitoring" {
  type        = string
  description = "Enable monitoring for Connect quotas"
  default     = "Yes"

  validation {
    condition     = contains(["Yes", "No"], var.connect_monitoring)
    error_message = "connect_monitoring must be either Yes or No"
  }
}

variable "vpc_config" {
  description = "VPC configuration for Lambda functions"
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}

################# TA Spoke

# variable "master_prefix"{
#   type = string
#   default = "qm"
# }

variable "ta_refresh_rate" {
  type        = string
  description = "The rate at which to refresh Trusted Advisor checks"
  default     = "rate(12 hours)" # Giá trị mặc định
}
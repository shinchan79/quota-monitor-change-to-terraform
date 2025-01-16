#---------------------------------------------------------------
# Common Variables
#---------------------------------------------------------------
variable "master_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "qm"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

#---------------------------------------------------------------
# Event Bus Variables
#---------------------------------------------------------------
variable "event_bus_arn" {
  description = "ARN of the central event bus"
  type        = string
}

#---------------------------------------------------------------
# Monitoring Variables
#---------------------------------------------------------------
variable "aws_services" {
  description = "Comma separated list of AWS services to monitor"
  type        = string
  default     = "AutoScaling,CloudFormation,DynamoDB,EBS,EC2,ELB,IAM,Kinesis,RDS,Route53,SES,VPC"
}

variable "ta_refresh_rate" {
  description = "The rate at which to refresh Trusted Advisor checks"
  type        = string
  default     = "rate(12 hours)"
  validation {
    condition     = contains(["rate(6 hours)", "rate(12 hours)", "rate(1 day)"], var.ta_refresh_rate)
    error_message = "Allowed values are: rate(6 hours), rate(12 hours), rate(1 day)"
  }
}

#---------------------------------------------------------------
# S3 Configuration
#---------------------------------------------------------------
variable "create_s3" {
  description = "Whether to create S3 bucket"
  type        = bool
  default     = true
}

variable "existing_s3_bucket" {
  description = "Existing S3 bucket name if create_s3 is false"
  type        = string
  default     = null
}

variable "s3_config" {
  description = "Configuration for S3 bucket"
  type = object({
    bucket_name = string
    versioning  = optional(bool, true)
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = bool
      prefix  = optional(string)
      expiration = optional(object({
        days = number
      }))
    })), [])
  })
  default = {
    bucket_name = "quota-monitor-ta-spoke-source-code"
    versioning  = true
  }
}

variable "source_code_objects" {
  description = "Map of source code zip files to upload to S3"
  type = map(object({
    source_path = string
    s3_key      = string
  }))
  default = {
    ta_refresher = {
      source_path = "source_codes/ta_refresher.zip"
      s3_key      = "lambda/ta_refresher.zip"
    }
    utils_ta = {
      source_path = "source_codes/utils_ta.zip"
      s3_key      = "layers/utils_ta.zip"
    }
  }
}

#---------------------------------------------------------------
# Lambda Function Variables
#---------------------------------------------------------------
variable "lambda_functions_config" {
  description = "Configuration for Lambda functions"
  type = map(object({
    name                  = string
    description           = string
    runtime               = string
    handler               = string
    timeout               = number
    memory_size           = number
    log_format            = string
    log_group             = string
    log_level             = string
    environment_log_level = optional(string)
    sdk_user_agent        = optional(string)
    app_version           = optional(string)
    solution_id           = optional(string)
    max_event_age         = optional(number)
    lambda_qualifier      = optional(string)
    tags                  = optional(map(string), {})

    # Source code options
    source_dir = optional(string) # For local archive creation
    local_source = optional(object({
      filename = string
    }))
    s3_source = optional(object({
      bucket = string
      key    = string
    }))
  }))
}

variable "create_archive" {
  description = "Whether to create archive from source files"
  type        = bool
  default     = false
}
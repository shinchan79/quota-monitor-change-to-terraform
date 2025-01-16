################################################################################
# Module Variables
################################################################################
variable "create" {
  description = "Flag to control whether module resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create)
    error_message = "Valid values for 'create' are 'true' or 'false'."
  }
}

################################################################################
# DynamoDB Variables
################################################################################
variable "create_dynamodb" {
  description = "Flag to control whether DynamoDB resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_dynamodb)
    error_message = "Valid values for 'create_dynamodb' are 'true' or 'false'."
  }
}

variable "dynamodb_tables" {
  description = "A map of DynamoDB table definitions."
  type = map(object({
    name           = optional(string)
    billing_mode   = optional(string, "PAY_PER_REQUEST")
    read_capacity  = optional(string, "5")
    write_capacity = optional(string, "5")
    hash_key       = string
    range_key      = optional(string)

    # Stream settings
    stream_enabled   = optional(bool, false)
    stream_view_type = optional(string, null)

    table_class                    = optional(string, "STANDARD")
    deletion_protection_enabled    = optional(bool, true)
    point_in_time_recovery_enabled = optional(bool, false)
    server_side_encryption = optional(object({
      enabled     = optional(bool, true)
      kms_key_arn = optional(string)
    }))
    attributes = list(object({
      name = string
      type = string
    }))
    local_secondary_index = optional(list(object({
      name               = string
      range_key          = string
      projection_type    = string
      non_key_attributes = optional(list(string))
    })), [])
    tags = optional(map(string))
  }))
  default = {}
}

################################################################################
# EventBridge Variables
################################################################################

variable "create_event" {
  description = "Flag to control whether EventBridge resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_event)
    error_message = "Valid values for 'create_event' are 'true' or 'false'."
  }
}

variable "event_buses" {
  description = "A map of EventBridge bus configurations."
  type = map(object({
    name               = optional(string)
    policy             = optional(string)
    kms_key_identifier = optional(string)
    tags               = optional(map(string))
  }))
  default = {}
}

variable "event_rules" {
  description = "A map of EventBridge rule definitions."
  type = map(object({
    name                = optional(string)
    event_bus           = optional(string)
    event_bus_key       = optional(string)
    description         = optional(string)
    schedule_expression = optional(string)
    event_pattern       = optional(string)
    state               = optional(string)
    force_destroy       = optional(bool, false)
    tags                = optional(map(string))
  }))
  default = {}
}

variable "event_targets" {
  description = "A map of EventBridge target configurations."
  type = map(object({
    rule           = optional(string)
    rule_key       = optional(string)
    event_bus      = optional(string)
    event_bus_key  = optional(string)
    target_arn     = optional(string)
    target_sqs_key = optional(string)
    role_arn       = optional(string)
    tags           = optional(map(string))
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = optional(string)
    }))
  }))
  default = {}
}

variable "event_schedules" {
  description = "A map of event schedule configurations."
  type = map(object({
    name                 = optional(string)
    flexible_time_window = optional(string, "OFF")
    schedule_expression  = optional(string)
    role_arn             = optional(string)
    input                = optional(string)
    kms_key_arn          = optional(string)
    group_name           = optional(string, "default")
  }))
  default = {}
}

variable "event_schedule_groups" {
  description = "A map of event schedule group configurations."
  type = map(object({
    name = string
  }))
  default = {}
}

variable "custom_kms_arn" {
  description = "AWS KMS key ARN used for encrypting resources."
  type        = string
  default     = null
  validation {
    condition     = var.custom_kms_arn != null ? can(regex("^arn:aws:kms:[a-zA-Z0-9-]+:[[:digit:]]{12}:key/.+", var.custom_kms_arn)) : true
    error_message = "Valid values for 'custom_kms_arn' must be a valid KMS ARN (ex: arn:aws:kms:us-east-1:111122223333:key/1234abcd-12ab-34cd-56ef-1234567890ab)."
  }
}

################################################################################
# IAM Role Variables
################################################################################
variable "create_role" {
  description = "Flag to control whether IAM role resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_role)
    error_message = "Valid values for 'create_role' are 'true' or 'false'."
  }
}

variable "iam_roles" {
  description = "A map of IAM role configurations."
  type = map(object({
    name                  = optional(string)
    description           = optional(string)
    path                  = optional(string)
    force_detach_policies = optional(string)
    permissions_boundary  = optional(string)
    policies              = optional(map(string))
    assume_role_policy    = optional(string)
    additional_policies   = optional(list(string))
    tags                  = optional(map(string))
  }))
  default = {}
}

################################################################################
# Lambda Variables
################################################################################
variable "create_lambda" {
  description = "Flag to control whether Lambda function resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_lambda)
    error_message = "Valid values for 'create_lambda' are 'true' or 'false'."
  }
}

# variable "lambda_functions" {
#   description = "Map of Lambda function configurations."
#   type = map(object({
#     name                  = optional(string)
#     runtime               = optional(string, "python3.12")
#     timeout               = optional(number, 30)
#     memory_size           = optional(string, 128)
#     architectures         = optional(list(string), ["x86_64"])
#     role_arn              = optional(string)
#     role_key              = optional(string)
#     source_file           = optional(string)
#     source_dir            = string
#     handler               = optional(string, "lambda_handler")
#     kms_key_arn           = optional(string)
#     environment_variables = optional(map(string))
#     security_group_ids    = optional(list(string))
#     subnet_ids            = optional(list(string))
#     logging_config = object({
#       application_log_level = optional(string)
#       log_format            = optional(string, "JSON")
#       log_group             = optional(string)
#       system_log_level      = optional(string, "WARN")
#     })
#     tags = optional(map(string))
#   }))
#   default = {}
# }

variable "lambda_functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    name          = string
    description   = optional(string)
    runtime       = string
    handler       = string
    timeout       = optional(number, 3)
    memory_size   = optional(number, 128)
    architectures = optional(list(string), ["x86_64"])
    # source_dir            = optional(string)
    filename              = optional(string) # Local file path
    s3_bucket             = optional(string) # Existing S3 bucket
    s3_key                = optional(string)
    environment_variables = optional(map(string), {})
    security_group_ids    = optional(list(string))
    subnet_ids            = optional(list(string))
    kms_key_arn           = optional(string)
    layers                = optional(list(string))
    role_arn              = string
    role_key              = optional(string)

    event_invoke_config = optional(object({
      maximum_event_age_in_seconds = optional(number)
      maximum_retry_attempts       = optional(number)
      qualifier                    = optional(string)
      destination_config = optional(object({
        on_failure = optional(object({
          destination_arn = string
        }))
        on_success = optional(object({
          destination_arn = string
        }))
      }))
    }))

    logging_config = optional(object({
      application_log_level = optional(string)
      log_format            = optional(string)
      log_group             = optional(string)
      system_log_level      = optional(string)
    }))

    tags = optional(map(string), {})
  }))
  default = {}
}


# Giữ nguyên phần lambda_permissions variable
variable "create_lambda_permission" {
  description = "Flag to control whether Lambda permission resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_lambda_permission)
    error_message = "Valid values for 'create_lambda_permission' are 'true' or 'false'."
  }
}

variable "lambda_permissions" {
  description = "Map of Lambda permission configurations."
  type = map(object({
    statement_id   = optional(string)
    action         = optional(string, "lambda:InvokeFunction")
    function_name  = optional(string)
    function_key   = optional(string)
    principal      = string
    source_arn     = optional(string)
    source_account = optional(string)
    qualifier      = optional(string)
  }))
  default = {}
}

################################################################################
# SNS Variables
################################################################################

variable "create_sns" {
  description = "Flag to control whether SNS resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_sns)
    error_message = "Valid values for 'create_sns' are 'true' or 'false'."
  }
}

variable "sns_topics" {
  description = "Map of SNS topics and their subscriptions configurations"
  type = map(object({
    name              = optional(string)
    kms_master_key_id = optional(string)
    tags              = optional(map(string))
    subscriptions = optional(map(object({
      protocol = string
      endpoint = string
    })))
  }))
  default = {}
}

################################################################################
# SQS Variables
################################################################################

variable "create_sqs" {
  description = "Flag to control whether SQS resources should be created."
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_sqs)
    error_message = "Valid values for 'create_sqs' are 'true' or 'false'."
  }
}

variable "sqs_queue" {
  description = "A map of SQS queue configurations."
  type = map(object({
    name                      = optional(string)
    delay_seconds             = optional(number, 0)
    max_message_size          = optional(number, 262144)
    message_retention_seconds = optional(number, 345600)
    receive_wait_time_seconds = optional(number, 0)
    fifo_queue                = optional(bool, false)
    kms_master_key_id         = optional(string)
    policy                    = optional(string)
    tags                      = optional(map(string))
  }))
  default = {}
}

################################################################################
# SSM Parameter Variables
################################################################################

variable "create_ssm_parameter" {
  description = "Flag to control whether SSM Parameter resources should be created"
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_ssm_parameter)
    error_message = "Valid values for 'create_ssm_parameter' are 'true' or 'false'."
  }
}

variable "ssm_parameters" {
  description = "Map of SSM Parameter configurations"
  type = map(object({
    name            = string
    description     = optional(string)
    type            = string
    value           = string
    allowed_pattern = optional(string)
    data_type       = optional(string)
    key_id          = optional(string)
    tier            = optional(string)
    tags            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.ssm_parameters : contains(["String", "StringList", "SecureString"], v.type)
    ])
    error_message = "SSM Parameter type must be one of: String, StringList, SecureString"
  }

  validation {
    condition = alltrue([
      for k, v in var.ssm_parameters : v.tier == null || contains(["Standard", "Advanced", "Intelligent-Tiering"], v.tier)
    ])
    error_message = "SSM Parameter tier must be one of: Standard, Advanced, Intelligent-Tiering"
  }
}

################################################################################
# CloudWatch Variables
################################################################################

variable "cloudwatch_log_group" {
  description = "Configuration for CloudWatch Log Groups"
  type = object({
    retention_in_days = optional(number, 30)
    log_group_class   = optional(string, "STANDARD")
    kms_key_id        = optional(string)
    tags              = optional(map(string), {})
  })
  default = {
    retention_in_days = 30
    log_group_class   = "STANDARD"
    tags              = {}
  }
}

################################################################################
# Lambda layer Variables
################################################################################

variable "create_lambda_layer" {
  description = "Controls if Lambda Layer should be created"
  type        = bool
  default     = false
}

variable "lambda_layers" {
  description = "Map of Lambda layers to create"
  type = map(object({
    name                = string
    compatible_runtimes = list(string)
    s3_bucket           = string
    s3_key              = string
    tags                = optional(map(string), {})
  }))
  default = {}
}

#############
# Lambda Event Invoke Config Variables
variable "create_lambda_event_invoke_config" {
  description = "Flag to control whether Lambda Event Invoke Config resources should be created"
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_lambda_event_invoke_config)
    error_message = "Valid values for 'create_lambda_event_invoke_config' are 'true' or 'false'."
  }
}

variable "lambda_event_invoke_configs" {
  description = "Map of Lambda Event Invoke Config configurations"
  type = map(object({
    function_name                = optional(string)
    function_key                 = optional(string)
    qualifier                    = optional(string, "$LATEST")
    maximum_event_age_in_seconds = optional(number, 14400)
    maximum_retry_attempts       = optional(number)
    destination_config = optional(object({
      on_failure = optional(object({
        destination_arn = string
      }))
      on_success = optional(object({
        destination_arn = string
      }))
    }))
  }))
  default = {}
}

################################################################################
# Lambda Permission Variables
################################################################################

#####################
variable "create_sns_subscription" {
  description = "Flag to control whether SNS subscription resources should be created"
  type        = bool
  default     = true
  validation {
    condition     = contains([true, false], var.create_sns_subscription)
    error_message = "Valid values for 'create_sns_subscription' are 'true' or 'false'."
  }
}

variable "sns_subscriptions" {
  description = "Map of SNS subscription configurations"
  type = map(object({
    topic_key = optional(string)
    topic_arn = optional(string)
    protocol  = string
    endpoint  = string
  }))
  default = {}
}

#---------------------------------------------------------------
# S3 Variables
#---------------------------------------------------------------
variable "create_s3" {
  description = "Controls if S3 resources should be created"
  type        = bool
  default     = false
}

variable "s3_buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    name               = optional(string)
    bucket_prefix      = optional(string)
    force_destroy      = optional(bool, false)
    versioning_enabled = optional(bool, false)
    encryption_enabled = optional(bool, true)
    sse_algorithm      = optional(string, "AES256")
    kms_master_key_id  = optional(string)
    bucket_key_enabled = optional(bool, false)
    lifecycle_rules = optional(list(object({
      id      = string
      enabled = bool
      filter = optional(object({
        prefix = optional(string)
      }))
      transitions = optional(list(object({
        days          = optional(number)
        date          = optional(string)
        storage_class = string
      })), [])
      expiration = optional(object({
        days                         = optional(number)
        date                         = optional(string)
        expired_object_delete_marker = optional(bool)
      }))
      noncurrent_version_transitions = optional(list(object({
        days          = number
        storage_class = string
      })), [])
      noncurrent_version_expiration = optional(object({
        days = number
      }))
      abort_incomplete_multipart_upload_days = optional(number)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "s3_objects" {
  description = "Map of S3 objects to create"
  type = map(object({
    bucket_key             = optional(string)
    bucket                 = optional(string)
    key                    = string
    source                 = optional(string)
    content                = optional(string)
    content_base64         = optional(string)
    server_side_encryption = optional(string)
    kms_key_id             = optional(string)
    storage_class          = optional(string)
    tags                   = optional(map(string), {})
  }))
  default = {}
}

################################################################################
# Common Variables
################################################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags for the security group resource."
  type        = map(string)
  default     = {}
}

variable "master_prefix" {
  description = "A key prefix for AWS resources."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.master_prefix))
    error_message = "Valid values for 'master_prefix' must match the pattern ^[a-zA-Z0-9-]+$."
  }
}

variable "create_archive" {
  description = "Whether to create archive files for Lambda functions"
  type        = bool
  default     = false
}
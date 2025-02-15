# DynamoDB 
variable "dynamodb_config" {
  description = "Configuration for DynamoDB tables"
  type = map(object({
    table_name    = string
    billing_mode  = string
    hash_key      = string
    range_key     = string
    ttl_attribute = optional(string)
  }))
  # default = {
  #   quota_monitor = {
  #     table_name    = "QuotaMonitor-Table"
  #     billing_mode  = "PAY_PER_REQUEST"
  #     hash_key      = "MessageId"
  #     range_key     = "TimeStamp"
  #     ttl_attribute = "ExpiryTime"
  #   }
  # }
}

# Event bus
# Event bus
variable "event_bus_config" {
  description = "Configuration for EventBridge event buses"
  type = map(object({
    bus_name      = string
    policy_sid    = string
    resource_name = string
  }))
  # default = {
  #   quota_monitor = {
  #     bus_name      = "QuotaMonitorBus"
  #     policy_sid    = "AllowPutEvents"
  #     resource_name = "qm-QuotaMonitorBus"
  #   }
  # }
}

variable "vpc_config" {
  description = "VPC configuration for Lambda function"
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
}

# variable "regions_list" {
#   type        = string
#   description = "List of regions to deploy spoke resources"
# }

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
  description = "Deployment model for the solution (hub/spoke-sq/spoke-ta)"
  default     = "hub"
}

# variable "sns_spoke_region" {
#   type        = string
#   description = "Region where SNS topics will be created in spoke accounts"
#   default     = "us-east-1"
# }

# variable "region_concurrency" {
#   type        = string
#   description = "Type of concurrency for regional deployments (SEQUENTIAL/PARALLEL)"
#   default     = "SEQUENTIAL"
# }

# variable "max_concurrent_percentage" {
#   type        = number
#   description = "Maximum percentage of concurrent deployments"
#   default     = 100
# }

# variable "failure_tolerance_percentage" {
#   type        = number
#   description = "Percentage of failures that can be tolerated during deployment"
#   default     = 0
# }

# variable "sq_notification_threshold" {
#   type        = number
#   description = "Threshold percentage for Service Quotas notifications"
#   default     = 80
# }

# variable "sq_monitoring_frequency" {
#   type        = number
#   description = "Frequency (in minutes) for monitoring Service Quotas"
#   default     = 5
# }

# variable "sq_report_ok_notifications" {
#   type        = bool
#   description = "Whether to report OK notifications for Service Quotas"
#   default     = false
# }

# variable "enable_account_deploy" {
#   type    = bool
#   default = true
# }

# variable "account_deployment" {
#   description = "Whether to enable account deployment"
#   type        = bool
#   default     = false
# }

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags to be applied to all resources"
  default     = {}
}

# Event rules

variable "event_rules_config" {
  description = "Configuration for EventBridge rules"
  type = map(object({
    name                      = string
    description               = string
    schedule                  = optional(string)
    target_id                 = string
    status                    = optional(list(string))
    detail_type_notifications = optional(list(string))
    event_sources             = optional(list(string))
    tags                      = optional(map(string), {})
  }))

  # default = {
  #   sns_publisher = {
  #     name                      = "SNSPublisher-EventsRule"
  #     description               = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
  #     target_id                 = "Target0"
  #     status                    = ["WARN", "ERROR"]
  #     detail_type_notifications = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
  #     event_sources             = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
  #     tags                      = {}
  #   }
  #   summarizer = {
  #     name                      = "Summarizer-EventQueue-Rule"
  #     description               = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
  #     target_id                 = "Target0"
  #     status                    = ["OK", "WARN", "ERROR"]
  #     detail_type_notifications = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
  #     event_sources             = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
  #     tags                      = {}
  #   }
  #   reporter = {
  #     name        = "Reporter-EventsRule"
  #     description = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
  #     schedule    = "rate(5 minutes)"
  #     target_id   = "Target0"
  #     tags        = {}
  #   }
  #   deployment_manager = {
  #     name        = "Deployment-Manager-EventsRule"
  #     description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
  #     target_id   = "Target0"
  #     tags        = {}
  #   }
  # }
}

# Helper lambda config

variable "helper_config" {
  description = "Configuration for Helper Lambda function"
  type = object({
    lambda_function = object({
      name        = string
      description = string
      runtime     = string
      handler     = string
      timeout     = number
      memory_size = number
      tags        = optional(map(string), {})
    })
    lambda_code = object({
      s3_bucket = string
      s3_key    = string
    })
    lambda_environment = object({
      stack_id       = string
      sdk_user_agent = string
      version        = string
      solution_id    = string
      log_level      = string           # Thêm trường này
      qm_stack_id    = string           # Thêm trường này  
      send_metric    = string           # Thêm trường này
    })
    lambda_event = object({
      max_event_age = number
      qualifier     = string
    })
    lambda_logging = object({
      log_level     = string
      log_format    = string
      log_group     = string
      logging_level = string
    })
  })
  # default = {
  #   lambda_function = {
  #     name        = "Helper-Function"
  #     description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
  #     runtime     = "nodejs18.x"
  #     handler     = "index.handler"
  #     timeout     = 5
  #     memory_size = 128
  #     tags        = {}
  #   }
  #   lambda_code = {
  #     s3_bucket = "immersionday-aaaa-jjjj"
  #     s3_key    = "test-aws-myApplication.zip"
  #   }
  #   lambda_environment = {
  #     stack_id       = "quota-monitor-hub"
  #     sdk_user_agent = "AwsSolution/SO0005/v6.3.0"
  #     version        = "v6.3.0"
  #     solution_id    = "SO0005"
  #     log_level      = "info"           # Thêm giá trị default
  #     qm_stack_id    = "quota-monitor-hub-no-ou"  # Thêm giá trị default
  #     send_metric    = "Yes"            # Thêm giá trị default
  #   }
  #   lambda_event = {
  #     max_event_age = 14400
  #     qualifier     = "$LATEST"
  #   }
  #   lambda_logging = {
  #     log_level     = "info"
  #     log_format    = "JSON"
  #     log_group     = "/aws/lambda/QuotaMonitor-Helper"
  #     logging_level = "INFO"
  #   }
  # }
}

# IAM 

# variable "management_account_id" {
#   type        = string
#   description = "AWS Management Account ID"
# }

variable "iam_role_names" {
  description = "Names for IAM roles"
  type        = map(string)
  # default = {
  #   lambda_helper      = "HelperFunctionRole"
  #   deployment_manager = "DeploymentManager-Lambda-Role"
  #   provider_framework = "HelperProviderFrameworkOnEventRole"
  #   sns_publisher      = "SNSPublisher-Lambda-Role"
  #   reporter           = "Reporter-Lambda-Role"
  # }
}

variable "master_prefix" {
  description = "Prefix to be used for all resources"
  type        = string
  default     = "qm"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# KMS
variable "create_kms" {
  description = "Whether to create KMS key"
  type        = bool
  default     = true
}

variable "existing_kms_arn" {
  description = "Existing KMS key ARN to use if create_kms is false"
  type        = string
  default     = null
}

variable "kms_config" {
  description = "Configuration for KMS resources"
  type = object({
    key = object({
      description     = string
      deletion_window = number
      enable_rotation = bool
      alias           = string
    })
    policy = object({
      version               = string
      effect_allow          = string
      all_resources         = string
      iam_sid               = string
      eventbridge_sid       = string
      eventbridge_principal = string
      admin_actions         = string
      eventbridge_actions   = list(string)
    })
  })
  # default = {
  #   key = {
  #     description     = "CMK for AWS resources provisioned by Quota Monitor in this account"
  #     deletion_window = 7
  #     enable_rotation = true
  #     alias           = "alias/CMK-KMS-Hub2"
  #   }
  #   policy = {
  #     version               = "2012-10-17"
  #     effect_allow          = "Allow"
  #     all_resources         = "*"
  #     iam_sid               = "Enable IAM User Permissions"
  #     eventbridge_sid       = "Allow EventBridge Service"
  #     eventbridge_principal = "events.amazonaws.com"
  #     admin_actions         = "kms:*"
  #     eventbridge_actions = [
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:ReEncrypt*",
  #       "kms:GenerateDataKey*"
  #     ]
  #   }
  # }
}

# Lambda layer
variable "lambda_layer_config" {
  description = "Configuration for Lambda layers"
  type = map(object({
    layer = object({
      name     = string
      runtimes = list(string)
    })
    local_source = optional(object({
      filename = string
    }))
    s3_source = optional(object({
      bucket = string
      key    = string
    }))
  }))
  # default = {
  #   utils = {
  #     layer = {
  #       name     = "QM-UtilsLayer"
  #       runtimes = ["nodejs18.x"]
  #     }
  #   }
  # }
}

# Lambda permission
variable "lambda_permissions_config" {
  description = "Configuration for Lambda permissions"
  type = map(object({
    statement_id = string
    action       = string
    principal    = string
  }))
  # default = {
  #   sns_publisher = {
  #     statement_id = "AllowEventBridgeInvoke"
  #     action       = "lambda:InvokeFunction"
  #     principal    = "events.amazonaws.com"
  #   }
  #   reporter = {
  #     statement_id = "AllowEventBridgeInvoke"
  #     action       = "lambda:InvokeFunction"
  #     principal    = "events.amazonaws.com"
  #   }
  #   deployment_manager = {
  #     statement_id = "AllowEventBridgeInvoke"
  #     action       = "lambda:InvokeFunction"
  #     principal    = "events.amazonaws.com"
  #   }
  # }
}

# Lambda 
variable "lambda_functions_config" {
  description = "Configuration for Lambda functions"
  type = map(object({
    name        = string
    description = string
    runtime     = string
    handler     = string
    timeout     = number
    memory_size = number
    local_source = optional(object({
      filename = string
    }))
    s3_source = optional(object({
      bucket = string
      key    = string
    }))
    log_format            = string
    log_group             = string
    log_level             = string
    environment_log_level = optional(string)
    sdk_user_agent        = optional(string)
    app_version           = optional(string)
    solution_id           = optional(string)
    max_event_age         = optional(number)
    lambda_qualifier      = optional(string)
    max_messages          = optional(string)
    max_loops             = optional(string)
    tags                  = optional(map(string), {})
  }))
  # default = {
  #   provider_framework = {
  #     name        = "QM-Helper-Provider-framework-onEvent"
  #     description = "AWS CDK resource provider framework - onEvent"
  #     runtime     = "nodejs18.x"
  #     handler     = "framework.onEvent"
  #     timeout     = 900
  #     memory_size = 128
  #     log_format  = "JSON"
  #     log_group   = "/aws/lambda/QM-Helper-Provider-framework-onEvent"
  #     log_level   = "INFO"
  #     s3_source = {
  #       bucket = "solutions-ap-southeast-1"
  #       key    = "quota-monitor-for-aws/v6.3.0/asset7382a0addb9f34974a1ea6c6c9b063882af874828f366f5c93b2b7b64db15c94.zip"
  #     }
  #   }

  #   helper = {
  #     name        = "QM-Helper-Function"
  #     description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
  #     runtime     = "nodejs18.x"
  #     handler     = "index.handler"
  #     timeout     = 5
  #     memory_size = 128
  #     log_format  = "JSON"
  #     log_group   = "/aws/lambda/QM-Helper-Function"
  #     log_level   = "INFO"
  #     s3_source = {
  #       bucket = "solutions-ap-southeast-1"
  #       key    = "quota-monitor-for-aws/v6.3.0/assetf4ee0c3d949f011b3f0f60d231fdacecab71c5f3ccf9674352231cedf831f6cd.zip"
  #     }
  #   }

  #   slack_notifier = {
  #     name        = "QM-SlackNotifier-Lambda"
  #     description = "SO0005 quota-monitor-for-aws - QM-SlackNotifier-Lambda"
  #     runtime     = "nodejs18.x"
  #     handler     = "index.handler"
  #     timeout     = 60
  #     memory_size = 128
  #     log_format  = "JSON"
  #     log_group   = "/aws/lambda/QM-SlackNotifier-Lambda"
  #     log_level   = "INFO"
  #     s3_source = {
  #       bucket = "solutions-ap-southeast-1"
  #       key    = "quota-monitor-for-aws/v6.3.0/asset11434a0b3246f0b4445dd28fdbc9e4e7dc808ccf355077acd9b000c5d88e6713.zip"
  #     }
  #   }

  #   sns_publisher = {
  #     name        = "QM-SNSPublisher-Lambda"
  #     description = "SO0005 quota-monitor-for-aws - QM-SNSPublisher-Lambda"
  #     runtime     = "nodejs18.x"
  #     handler     = "index.handler"
  #     timeout     = 60
  #     memory_size = 128
  #     log_format  = "JSON"
  #     log_group   = "/aws/lambda/QM-SNSPublisher-Lambda"
  #     log_level   = "INFO"
  #     s3_source = {
  #       bucket = "solutions-ap-southeast-1"
  #       key    = "quota-monitor-for-aws/v6.3.0/assete7a324e67e467d0c22e13b0693ca4efdceb0d53025c7fb45fe524870a5c18046.zip"
  #     }
  #   }

  #   reporter = {
  #     name        = "QM-Reporter-Lambda"
  #     description = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
  #     runtime     = "nodejs18.x"
  #     handler     = "index.handler"
  #     timeout     = 10
  #     memory_size = 512
  #     log_format  = "JSON"
  #     log_group   = "/aws/lambda/QM-Reporter-Lambda"
  #     log_level   = "INFO"
  #     max_messages = "10"
  #     max_loops    = "10"
  #     s3_source = {
  #       bucket = "solutions-ap-southeast-1"
  #       key    = "quota-monitor-for-aws/v6.3.0/asseta6fda81c73d731886f04e1734d036f12ceb7b94c2efec30bb511f477ac58aa9c.zip"
  #     }
  #   }

  #   deployment_manager = {
  #     name        = "QM-Deployment-Manager-Lambda"
  #     description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
  #     runtime     = "nodejs18.x"
  #     handler     = "index.handler"
  #     timeout     = 60
  #     memory_size = 512
  #     log_format  = "JSON"
  #     log_group   = "/aws/lambda/QM-Deployment-Manager-Lambda"
  #     log_level   = "INFO"
  #     s3_source = {
  #       bucket = "solutions-ap-southeast-1"
  #       key    = "quota-monitor-for-aws/v6.3.0/asset6a1cf55956fc481a1f22a54b0fa78a3d78b7e61cd41e12bf80ac8c9404ff9eb2.zip"
  #     }
  #   }
  # }
}

# Uncomment và thêm các biến còn thiếu

variable "regions_list" {
  type        = string
  description = "List of regions to deploy spoke resources"
  default     = "ap-southeast-1" # Hoặc giá trị mặc định phù hợp
}

variable "sns_spoke_region" {
  type        = string
  description = "Region where SNS topics will be created in spoke accounts"
  default     = "ap-southeast-1"
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
  type        = bool
  description = "Whether to enable account deployment"
  default     = true
}

# SNS
variable "create_sns" {
  description = "Whether to create SNS topics"
  type        = bool
  default     = true
}

variable "existing_sns_arn" {
  description = "Existing SNS topic ARN to use if create_sns is false"
  type        = string
  default     = null
}

variable "sns_config" {
  description = "Configuration for SNS topics"
  type = map(object({
    name     = string
    protocol = string
  }))
  # default = {
  #   publisher = {
  #     name     = "SNSPublisher-Topic"
  #     protocol = "email"
  #   }
  # }
}

variable "sns_emails" {
  description = "List of email endpoints for SNS topic subscription"
  type        = list(string)
  default     = []
}

# SQS 

variable "sqs_queues_config" {
  description = "Configuration for SQS queues"
  type = map(object({
    name                = string
    visibility_timeout  = optional(number)
    actions             = string
    eventbridge_actions = optional(list(string))
  }))
  # default = {
  #   slack_notifier_dlq = {
  #     name    = "SlackNotifier-Lambda-DLQ"
  #     actions = "sqs:*"
  #   }
  #   sns_publisher_dlq = {
  #     name    = "SNSPublisher-Lambda-DLQ"
  #     actions = "sqs:*"
  #   }
  #   summarizer_event_queue = {
  #     name                = "Summarizer-EventQueue"
  #     visibility_timeout  = 60
  #     actions             = "sqs:*"
  #     eventbridge_actions = ["sqs:SendMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"]
  #   }
  #   reporter_dlq = {
  #     name    = "Reporter-Lambda-DLQ"
  #     actions = "sqs:*"
  #   }
  #   deployment_manager_dlq = {
  #     name    = "DeploymentManager-Lambda-DLQ"
  #     actions = "sqs:*"
  #   }
  # }
}

# SSM parametes

variable "ssm_parameters_config" {
  description = "Configuration for SSM parameters"
  type = map(object({
    name        = string
    description = string
    type        = string
    value       = optional(string, "NOP")
    tier        = optional(string, "Standard")
    tags        = optional(map(string), {})
  }))
  # default = {
  #   notification_muting = {
  #     name        = "/QuotaMonitor/NotificationConfiguration"
  #     description = "Muting configuration for services and limits"
  #     type        = "StringList"
  #     tags        = {}
  #   }
  # }
}

# S3 Configuration
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
  # default = {
  #   bucket_name = "quota-monitor-source-code"
  #   versioning  = true
  # }
}

variable "source_code_objects" {
  description = "Map of source code zip files to upload to S3"
  type = map(object({
    source_path = string
    s3_key      = string
  }))
  # default = {
  #   provider_framework = {
  #     source_path = "source_codes/framework-onEvent.zip" # Sửa tên file
  #     s3_key      = "lambda/provider_framework.zip"
  #   }
  #   helper = {
  #     source_path = "source_codes/helper-function.zip" # Sửa tên file
  #     s3_key      = "lambda/helper.zip"
  #   }
  #   sns_publisher = {
  #     source_path = "source_codes/sns-publisher.zip" # Sửa tên file
  #     s3_key      = "lambda/sns_publisher.zip"
  #   }
  #   utils_layer = {
  #     source_path = "source_codes/utils-layer.zip" # Sửa tên file
  #     s3_key      = "layers/utils_layer.zip"
  #   }
  # }
}

variable "create_archive" {
  description = "Whether to create archive files from source code"
  type        = bool
  default     = false
}
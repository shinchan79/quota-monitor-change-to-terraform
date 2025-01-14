# DynamoDB 
variable "dynamodb_config" {
  description = "Configuration for DynamoDB tables"
  type = map(object({
    table_name    = string
    billing_mode  = string
    hash_key      = string
    range_key     = string
    ttl_attribute = string
  }))
  default = {
    quota_monitor = {
      table_name    = "QuotaMonitor-Table"
      billing_mode  = "PAY_PER_REQUEST"
      hash_key      = "MessageId"
      range_key     = "TimeStamp"
      ttl_attribute = "ExpiryTime"
    }
  }
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
  default = {
    quota_monitor = {
      bus_name      = "QuotaMonitorBus"
      policy_sid    = "AllowPutEvents"
      resource_name = "qm-QuotaMonitorBus"
    }
  }
}


#....
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

variable "account_deployment" {
  description = "Whether to enable account deployment"
  type        = bool
  default     = false
}

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

  default = {
    sns_publisher = {
      name                      = "SNSPublisher-EventsRule"
      description               = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
      target_id                 = "Target0"
      status                    = ["WARN", "ERROR"]
      detail_type_notifications = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
      event_sources             = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
      tags                      = {}
    }
    summarizer = {
      name                      = "Summarizer-EventQueue-Rule"
      description               = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
      target_id                 = "Target0"
      status                    = ["OK", "WARN", "ERROR"]
      detail_type_notifications = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
      event_sources             = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
      tags                      = {}
    }
    reporter = {
      name        = "Reporter-EventsRule"
      description = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
      schedule    = "rate(5 minutes)"
      target_id   = "Target0"
      tags        = {}
    }
    deployment_manager = {
      name        = "Deployment-Manager-EventsRule"
      description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
      target_id   = "Target0"
      tags        = {}
    }
  }
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
  default = {
    lambda_function = {
      name        = "Helper-Function"
      description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 5
      memory_size = 128
      tags        = {}
    }
    lambda_code = {
      s3_bucket = "immersionday-aaaa-jjjj"
      s3_key    = "test-aws-myApplication.zip"
    }
    lambda_environment = {
      stack_id       = "quota-monitor-hub"
      sdk_user_agent = "AwsSolution/SO0005/v6.3.0"
      version        = "v6.3.0"
      solution_id    = "SO0005"
    }
    lambda_event = {
      max_event_age = 14400
      qualifier     = "$LATEST"
    }
    lambda_logging = {
      log_level     = "info"
      log_format    = "JSON"
      log_group     = "/aws/lambda/QuotaMonitor-Helper"
      logging_level = "INFO"
    }
  }
}

# IAM 

variable "management_account_id" {
  type        = string
  description = "AWS Management Account ID"
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
  default = {
    key = {
      description     = "CMK for AWS resources provisioned by Quota Monitor in this account"
      deletion_window = 7
      enable_rotation = true
      alias           = "alias/CMK-KMS-Hub"
    }
    policy = {
      version               = "2012-10-17"
      effect_allow          = "Allow"
      all_resources         = "*"
      iam_sid               = "Enable IAM User Permissions"
      eventbridge_sid       = "Allow EventBridge Service"
      eventbridge_principal = "events.amazonaws.com"
      admin_actions         = "kms:*"
      eventbridge_actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ]
    }
  }
}

# Lambda layer
variable "lambda_layer_config" {
  description = "Configuration for Lambda Layers"
  type = map(object({
    layer = object({
      name     = string
      runtimes = list(string)
    })
    code = object({
      s3_bucket = string
      s3_key    = string
    })
  }))
  default = {
    utils = {
      layer = {
        name     = "QM-UtilsLayer"
        runtimes = ["nodejs18.x"]
      }
      code = {
        s3_bucket = "immersionday-aaaa-jjjj"
        s3_key    = "test-aws-myApplication.zip"
      }
    }
  }
}

# Lambda permission
variable "lambda_permissions_config" {
  description = "Configuration for Lambda permissions"
  type = map(object({
    statement_id = string
    action       = string
    principal    = string
  }))
  default = {
    sns_publisher = {
      statement_id = "AllowEventBridgeInvoke"
      action       = "lambda:InvokeFunction"
      principal    = "events.amazonaws.com"
    }
    reporter = {
      statement_id = "AllowEventBridgeInvoke"
      action       = "lambda:InvokeFunction"
      principal    = "events.amazonaws.com"
    }
    deployment_manager = {
      statement_id = "AllowEventBridgeInvoke"
      action       = "lambda:InvokeFunction"
      principal    = "events.amazonaws.com"
    }
  }
}

# Lambda 

variable "lambda_functions_config" {
  description = "Configuration for all Lambda functions"
  type = map(object({
    name                  = string
    description           = string
    runtime               = string
    handler               = string
    timeout               = number
    memory_size           = number
    s3_bucket             = string
    s3_key                = string
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
  default = {
    provider_framework = {
      name        = "Helper-Provider-Framework"
      description = "AWS CDK resource provider framework - onEvent (quota-monitor-hub/QM-Helper/QM-Helper-Provider)"
      runtime     = "nodejs18.x"
      handler     = "framework.onEvent"
      timeout     = 900
      memory_size = 128
      s3_bucket   = "immersionday-aaaa-jjjj"
      s3_key      = "test-aws-myApplication.zip"
      log_format  = "JSON"
      log_group   = "/aws/lambda/Helper-Provider-Framework"
      log_level   = "INFO"
      tags        = {}
    }
    sns_publisher = {
      name                  = "SNSPublisher-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 60
      memory_size           = 128
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/SNSPublisher-Lambda"
      log_level             = "INFO"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
      tags                  = {}
    }
    reporter = {
      name                  = "Reporter-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 10
      memory_size           = 512
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/Reporter-Lambda"
      log_level             = "INFO"
      max_messages          = "10"
      max_loops             = "10"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
      tags                  = {}
    }
    deployment_manager = {
      name                  = "DeploymentManager-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 60
      memory_size           = 512
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/DeploymentManager-Lambda"
      log_level             = "INFO"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
      tags                  = {}
    }
  }
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
  default = {
    publisher = {
      name     = "SNSPublisher-Topic"
      protocol = "email"
    }
  }
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
  default = {
    slack_notifier_dlq = {
      name    = "SlackNotifier-Lambda-DLQ"
      actions = "sqs:*"
    }
    sns_publisher_dlq = {
      name    = "SNSPublisher-Lambda-DLQ"
      actions = "sqs:*"
    }
    summarizer_event_queue = {
      name                = "Summarizer-EventQueue"
      visibility_timeout  = 60
      actions             = "sqs:*"
      eventbridge_actions = ["sqs:SendMessage", "sqs:GetQueueAttributes", "sqs:GetQueueUrl"]
    }
    reporter_dlq = {
      name    = "Reporter-Lambda-DLQ"
      actions = "sqs:*"
    }
    deployment_manager_dlq = {
      name    = "DeploymentManager-Lambda-DLQ"
      actions = "sqs:*"
    }
  }
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
  default = {
    slack_webhook = {
      name        = "/QuotaMonitor/SlackHook"
      description = "Slack Hook URL to send Quota Monitor events"
      type        = "String"
      tags        = {}
    }
    organizational_units = {
      name        = "/QuotaMonitor/OUs"
      description = "List of target Organizational Units"
      type        = "StringList"
      tags        = {}
    }
    target_accounts = {
      name        = "/QuotaMonitor/Accounts"
      description = "List of target Accounts"
      type        = "StringList"
      tags        = {}
    }
    notification_muting = {
      name        = "/QuotaMonitor/NotificationConfiguration"
      description = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
      type        = "StringList"
      tags        = {}
    }
    regions_list = {
      name        = "/QuotaMonitor/RegionsToDeploy"
      description = "list of regions to deploy spoke resources (eg. us-east-1,us-west-2)"
      type        = "StringList"
      tags        = {}
    }
  }
}
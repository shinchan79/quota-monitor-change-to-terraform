# DynamoDB
variable "dynamodb_config" {
  description = "Configuration for DynamoDB tables"
  type = map(object({
    name                           = string
    billing_mode                   = string
    hash_key                       = string
    range_key                      = optional(string)
    stream_enabled                 = optional(bool)
    stream_view_type               = optional(string)
    encryption_enabled             = optional(bool)
    point_in_time_recovery_enabled = optional(bool)
    deletion_protection_enabled    = optional(bool)
  }))
  default = {
    service = {
      name                           = "ServiceTable"
      billing_mode                   = "PAY_PER_REQUEST"
      hash_key                       = "ServiceCode"
      stream_enabled                 = true
      stream_view_type               = "NEW_AND_OLD_IMAGES"
      encryption_enabled             = true
      point_in_time_recovery_enabled = true
      deletion_protection_enabled    = false
    }
    quota = {
      name                           = "QuotaTable"
      billing_mode                   = "PAY_PER_REQUEST"
      hash_key                       = "ServiceCode"
      range_key                      = "QuotaCode"
      encryption_enabled             = true
      point_in_time_recovery_enabled = true
      deletion_protection_enabled    = false
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
    sns_spoke = {
      bus_name      = "QuotaMonitorSnsSpokeBus"
      policy_sid    = "allowed_accounts"
      resource_name = "qm-QuotaMonitorSnsSpokeBus"
    }
    quota_monitor_spoke = {
      bus_name      = "QuotaMonitorSpokeBus"
      policy_sid    = "AllowPutEvents"
      resource_name = "qm-QuotaMonitorSpokeBus"
    }
  }
}

# Event rules
variable "event_rules_config" {
  description = "Configuration for EventBridge rules"
  type = map(object({
    name                = string
    description         = string
    event_bus_name      = optional(string)
    schedule_expression = optional(string)
    state               = optional(string, "ENABLED")
    event_pattern = optional(object({
      detail = optional(object({
        status = optional(list(string))
        check_item_detail = optional(object({
          Service = optional(list(string))
        }))
      }))
      detail_type = optional(list(string))
      source      = optional(list(string))
      account     = optional(list(string))
    }))
    targets = list(object({
      arn      = string
      id       = string
      role_arn = optional(string)
    }))
    tags = optional(map(string), {})
  }))

  default = {
    sns_publisher = {
      name           = "SNSPublisher-EventsRule"
      description    = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-EventsRule"
      event_bus_name = "sns_spoke"
      event_pattern = {
        detail = {
          status = ["WARN", "ERROR"]
        }
        detail_type = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
        source      = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
      }
      targets = [
        {
          arn = "TARGET_ARN"
          id  = "Target0"
        }
      ]
    }

    list_manager = {
      name                = "ListManager-Schedule"
      description         = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      schedule_expression = "rate(30 days)"
      targets = [
        {
          arn = "TARGET_ARN"
          id  = "Target0"
        }
      ]
    }

    cw_poller = {
      name                = "CWPoller-EventsRule"
      description         = "SO0005 quota-monitor-for-aws - QM-CWPoller-EventsRule"
      schedule_expression = "rate(5 minutes)"
      targets = [
        {
          arn = "TARGET_ARN"
          id  = "Target0"
        }
      ]
    }

    utilization_ok = {
      name           = "UtilizationOK"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      event_bus_name = "quota_monitor_spoke"
      event_pattern = {
        detail = {
          status = ["OK"]
        }
        detail_type = ["Service Quotas Utilization Notification"]
        source      = ["aws-solutions.quota-monitor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "utilization_ok_events"
        }
      ]
    }

    utilization_warn = {
      name           = "UtilizationWarn"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      event_bus_name = "quota_monitor_spoke"
      event_pattern = {
        detail = {
          status = ["WARN"]
        }
        detail_type = ["Service Quotas Utilization Notification"]
        source      = ["aws-solutions.quota-monitor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "utilization_warn_events"
        }
      ]
    }

    utilization_error = {
      name           = "UtilizationErr"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-EventsRule"
      event_bus_name = "quota_monitor_spoke"
      event_pattern = {
        detail = {
          status = ["ERROR"]
        }
        detail_type = ["Service Quotas Utilization Notification"]
        source      = ["aws-solutions.quota-monitor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "utilization_error_events"
        }
      ]
    }

    spoke_sns = {
      name           = "spoke-sns"
      description    = "SO0005 quota-monitor-for-aws - quota-monitor-sq-spoke-SpokeSnsEventsRule"
      event_bus_name = "quota_monitor_spoke"
      event_pattern = {
        detail = {
          status = ["WARN", "ERROR"]
        }
        detail_type = ["Trusted Advisor Check Item Refresh Notification", "Service Quotas Utilization Notification"]
        source      = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "spoke_sns_events"
        }
      ]
    }

    ta_ok = {
      name        = "TA-OK-Rule"
      description = "Quota Monitor Solution - Spoke - Rule for TA OK events"
      event_pattern = {
        detail = {
          status = ["OK"]
          check_item_detail = {
            Service = ["AutoScaling", "CloudFormation", "DynamoDB", "EBS", "EC2", "ELB", "IAM", "Kinesis", "RDS", "Route53", "SES", "VPC"]
          }
        }
        detail_type = ["Trusted Advisor Check Item Refresh Notification"]
        source      = ["aws.trustedadvisor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "ta_ok_rule_events_role"
        }
      ]
    }

    ta_warn = {
      name        = "TA-Warn-Rule"
      description = "Quota Monitor Solution - Spoke - Rule for TA WARN events"
      event_pattern = {
        detail = {
          status = ["WARN"]
          check_item_detail = {
            Service = ["AutoScaling", "CloudFormation", "DynamoDB", "EBS", "EC2", "ELB", "IAM", "Kinesis", "RDS", "Route53", "SES", "VPC"]
          }
        }
        detail_type = ["Trusted Advisor Check Item Refresh Notification"]
        source      = ["aws.trustedadvisor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "ta_warn_rule_events_role"
        }
      ]
    }

    ta_error = {
      name        = "TA-Error-Rule"
      description = "Quota Monitor Solution - Spoke - Rule for TA ERROR events"
      event_pattern = {
        detail = {
          status = ["ERROR"]
          check_item_detail = {
            Service = ["AutoScaling", "CloudFormation", "DynamoDB", "EBS", "EC2", "ELB", "IAM", "Kinesis", "RDS", "Route53", "SES", "VPC"]
          }
        }
        detail_type = ["Trusted Advisor Check Item Refresh Notification"]
        source      = ["aws.trustedadvisor"]
      }
      targets = [
        {
          arn      = "TARGET_ARN"
          id       = "Target0"
          role_arn = "ta_error_rule_events_role"
        }
      ]
    }

    ta_refresher = {
      name                = "TA-Refresher-EventsRule"
      description         = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-EventsRule"
      schedule_expression = "rate(5 minutes)"
      targets = [
        {
          arn = "TARGET_ARN"
          id  = "Target0"
        }
      ]
    }
  }
}

# Variables needed for event rules
# Variables needed for event rules
variable "event_bus_arn" {
  description = "ARN of the central event bus"
  type        = string
  default     = "arn:aws:events:us-east-1:123456789012:event-bus/qm-QuotaMonitorBus" # Default value for testing
}

variable "spoke_sns_region" {
  description = "Region for SNS spoke event bus"
  type        = string
  default     = "us-east-1"
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
    utils_sns_spoke = {
      layer = {
        name     = "UtilsLayer-SNS-Spoke"
        runtimes = ["nodejs18.x"]
      }
      code = {
        s3_bucket = "immersionday-aaaa-jjjj"
        s3_key    = "test-aws-myApplication.zip"
      }
    }
    utils_sq_spoke = {
      layer = {
        name     = "UtilsLayer-SQ-Spoke"
        runtimes = ["nodejs18.x"]
      }
      code = {
        s3_bucket = "immersionday-aaaa-jjjj"
        s3_key    = "test-aws-myApplication.zip"
      }
    }
    utils_ta = {
      layer = {
        name     = "UtilsLayer-TA"
        runtimes = ["nodejs18.x"]
      }
      code = {
        s3_bucket = "immersionday-aaaa-jjjj"
        s3_key    = "test-aws-myApplication.zip"
      }
    }
  }
}

# Lambda functiotions
# Lambda functions
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
    sns_publisher = {
      name                  = "SNSPublisher-Lambda"
      description           = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-Lambda"
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

    list_manager = {
      name                  = "ListManager-Function"
      description           = "SO0005 quota-monitor-for-aws - QM-ListManager-Function"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 900
      memory_size           = 256
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/ListManager-Function"
      log_level             = "INFO"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
      tags                  = {}
    }

    list_manager_provider = {
      name        = "ListManager-Provider-Framework"
      description = "AWS CDK resource provider framework - onEvent (quota-monitor-sq-spoke/QM-ListManager/QM-ListManager-Provider)"
      runtime     = "nodejs18.x"
      handler     = "framework.onEvent"
      timeout     = 900
      memory_size = 128
      s3_bucket   = "immersionday-aaaa-jjjj"
      s3_key      = "test-aws-myApplication.zip"
      log_format  = "JSON"
      log_group   = "/aws/lambda/ListManager-Provider-Framework"
      log_level   = "INFO"
      tags        = {}
    }

    qmcw_poller = {
      name                  = "CWPoller-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-CWPoller-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 900
      memory_size           = 512
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/CWPoller-Lambda"
      log_level             = "INFO"
      environment_log_level = "info"
      sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
      app_version           = "v6.3.0"
      solution_id           = "SO0005"
      max_event_age         = 14400
      lambda_qualifier      = "$LATEST"
      tags                  = {}
    }

    ta_refresher = {
      name                  = "TA-Refresher-Lambda"
      description           = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-Lambda"
      runtime               = "nodejs18.x"
      handler               = "index.handler"
      timeout               = 60
      memory_size           = 128
      s3_bucket             = "immersionday-aaaa-jjjj"
      s3_key                = "test-aws-myApplication.zip"
      log_format            = "JSON"
      log_group             = "/aws/lambda/TA-Refresher-Lambda"
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

# Other required variables
variable "vpc_config" {
  description = "VPC configuration for Lambda functions"
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  default = {
    security_group_ids = [] # Empty list as default
    subnet_ids         = [] # Empty list as default
  }
}

variable "send_metric" {
  description = "Whether to send metrics"
  type        = string
  default     = "No"
}

variable "partition_key" {
  description = "DynamoDB partition key"
  type        = string
  default     = "ServiceCode"
}

variable "sort_key" {
  description = "DynamoDB sort key"
  type        = string
  default     = "QuotaCode"
}

variable "monitoring_frequency" {
  description = "Frequency for monitoring"
  type        = string
  default     = "rate(5 minutes)"
}

variable "notification_threshold" {
  description = "Threshold for notifications"
  type        = number
  default     = 80
}

variable "report_ok_notifications" {
  description = "Whether to report OK notifications"
  type        = bool
  default     = false
}

variable "aws_services" {
  description = "Comma separated list of AWS services to monitor"
  type        = string
  default     = "AutoScaling,CloudFormation,DynamoDB,EBS,EC2,ELB,IAM,Kinesis,RDS,Route53,SES,VPC"
}

variable "existing_sns_topic_arn" {
  description = "Existing SNS topic ARN"
  type        = string
  default     = null
}

variable "create_sns" {
  description = "Whether to create SNS topics"
  type        = bool
  default     = true
}

# SNS Topics
variable "sns_topics_config" {
  description = "Configuration for SNS topics"
  type = map(object({
    name                = string
    existing_kms_key_id = optional(string)
    tags                = optional(map(string), {})
  }))
  default = {
    sns_publisher = {
      name = "SNSPublisher-SNSTopic"
    }
  }
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN for SNS encryption"
  type        = string
  default     = null
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
    sns_publisher_dlq = {
      name    = "SNSPublisher-Lambda-DLQ"
      actions = "sqs:*"
    }
    qmcw_poller_dlq = {
      name    = "CWPoller-Lambda-DLQ"
      actions = "sqs:*"
    }
    qmta_refresher_dlq = {
      name    = "TARefresher-Lambda-DLQ"
      actions = "sqs:*"
    }
  }
}

# SSM parameters
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
    notification_muting = {
      name        = "/QuotaMonitor/spoke/NotificationConfiguration"
      description = "Muting configuration for services, limits e.g. ec2:L-1216C47A,ec2:Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances,dynamodb,logs:*,geo:L-05EFD12D"
      type        = "StringList"
      tags        = {}
    }
  }
}

#---------------------------------------------------------------
# Monitoring Configuration
#---------------------------------------------------------------
variable "sagemaker_monitoring" {
  description = "Enable/disable SageMaker monitoring (Yes/No)"
  type        = string
  default     = "No"
}

variable "connect_monitoring" {
  description = "Enable/disable Connect monitoring (Yes/No)"
  type        = string
  default     = "No"
}

# Common variables
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
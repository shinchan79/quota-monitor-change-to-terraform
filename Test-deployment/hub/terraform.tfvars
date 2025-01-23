#---------------------------------------------------------------
# General Configuration
#---------------------------------------------------------------
master_prefix = "qm"

#---------------------------------------------------------------
# Tags Configuration
#---------------------------------------------------------------
tags = {
  Environment = "Production"
  Project     = "QuotaMonitor"
}

additional_tags = {
  Owner      = "Platform Team"
  CostCenter = "123456"
}

#---------------------------------------------------------------
# VPC Configuration
#---------------------------------------------------------------
vpc_config = {
  security_group_ids = ["sg-03d99266a5f63d8ee"]
  subnet_ids         = ["subnet-02989c560709bd208", "subnet-0b6fb0104e0dac190"]
}

#---------------------------------------------------------------
# Notifications Configuration
#---------------------------------------------------------------
enable_email = true
sns_emails   = ["trinhhaiyen79@gmail.com"]

#---------------------------------------------------------------
# Monitoring Configuration
#---------------------------------------------------------------
sagemaker_monitoring = "No"
connect_monitoring   = "No"

#---------------------------------------------------------------
# KMS Configuration
#---------------------------------------------------------------
create_kms       = true
existing_kms_arn = null

kms_config = {
  key = {
    description     = "CMK for AWS resources provisioned by Quota Monitor in this account"
    deletion_window = 7
    enable_rotation = true
    alias           = "alias/CMK-KMS-Hub2"
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

#---------------------------------------------------------------
# SNS Configuration
#---------------------------------------------------------------
create_sns       = true
existing_sns_arn = null

sns_config = {
  publisher = {
    name     = "SNSPublisher-Topic"
    protocol = "email"
  }
}

#---------------------------------------------------------------
# DynamoDB Configuration
#---------------------------------------------------------------
dynamodb_config = {
  quota_monitor = {
    table_name    = "QMTable"
    billing_mode  = "PAY_PER_REQUEST"
    hash_key      = "MessageId"
    range_key     = "TimeStamp"
    ttl_attribute = "ExpiryTime"
  }
}

#---------------------------------------------------------------
# Event Bus Configuration
#---------------------------------------------------------------
event_bus_config = {
  quota_monitor = {
    bus_name      = "QuotaMonitorBus"
    policy_sid    = "AllowPutEvents"
    resource_name = "qm-QuotaMonitorBus"
  }
}

#---------------------------------------------------------------
# Event Rules Configuration
#---------------------------------------------------------------
event_rules_config = {
  sns_publisher = {
    name        = "QM-SNSPublisherFunction-EventsRule" 
    description = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-EventsRule"
    target_id   = "Target0"
    status      = ["WARN", "ERROR"]
    detail_type_notifications = [
      "Trusted Advisor Check Item Refresh Notification",
      "Service Quotas Utilization Notification"
    ]
    event_sources = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
    tags = {
      Rule = "SNSPublisher"
    }
  }

  summarizer = {
    name        = "QM-Summarizer-EventQueue-EventsRule"
    description = "SO0005 quota-monitor-for-aws - QM-Summarizer-EventQueue-EventsRule"
    target_id   = "Target0"
    status      = ["OK", "WARN", "ERROR"]
    detail_type_notifications = [
      "Trusted Advisor Check Item Refresh Notification",
      "Service Quotas Utilization Notification" 
    ]
    event_sources = ["aws.trustedadvisor", "aws-solutions.quota-monitor"]
    tags = {
      Rule = "Summarizer"
    }
  }

  reporter = {
    name        = "QM-Reporter-EventsRule"
    description = "SO0005 quota-monitor-for-aws - QM-Reporter-EventsRule"
    schedule    = "rate(3 hours)"
    target_id   = "Target0"
    tags = {
      Rule = "Reporter"
    }
  }

  deployment_manager = {
    name        = "QM-Deployment-Manager-EventsRule"
    description = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-EventsRule"
    target_id   = "Target0"
    detail_type = ["Parameter Store Change"]
    source      = ["aws.ssm"]
    tags = {
      Rule = "DeploymentManager"
    }
  }
}

#---------------------------------------------------------------
# Lambda Layer Configuration
#---------------------------------------------------------------
lambda_layer_config = {
  utils = {
    layer = {
      name     = "QM-UtilsLayer"
      runtimes = ["nodejs18.x"]
    }
  }
}

#---------------------------------------------------------------
# Lambda Functions Configuration
#---------------------------------------------------------------
lambda_functions_config = {
  provider_framework = {
    name        = "QM-Helper-Provider-framework-onEvent"
    description = "AWS CDK resource provider framework - onEvent (quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Provider)"
    runtime     = "nodejs18.x"
    handler     = "framework.onEvent"
    timeout     = 900
    memory_size = 128
    s3_bucket   = "your-lambda-code-bucket"
    s3_key      = "provider-framework.zip"
    log_format  = "JSON"
    log_group   = "/aws/lambda/QM-Helper-Provider-framework-onEvent"
    log_level   = "INFO"
  }

  sns_publisher = {
    name                  = "SNSPublisher-Lambda"
    description           = "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 60
    memory_size           = 128
    s3_bucket             = "your-lambda-code-bucket"
    s3_key                = "sns-publisher.zip"
    log_format            = "JSON"
    log_group             = "/aws/lambda/SNSPublisher-Lambda"
    log_level             = "DEBUG"
    environment_log_level = "debug"
    sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
    app_version           = "v6.3.0"
    solution_id           = "SO0005"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
  }

  reporter = {
    name                  = "Reporter-Lambda"
    description           = "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 60
    memory_size           = 512
    s3_bucket             = "your-lambda-code-bucket"
    s3_key                = "reporter.zip"
    log_format            = "Text"
    log_group             = "/aws/lambda/qm-Reporter-Lambda"
    log_level             = "INFO"
    max_messages          = "10"
    max_loops             = "10"
    environment_log_level = "info"
    sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
    app_version           = "v6.3.0"
    solution_id           = "SO0005"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
  }

  deployment_manager = {
    name                  = "QM-Deployment-Manager-Lambda"
    description           = "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 60
    memory_size           = 512
    log_format            = "JSON"
    log_group             = "/aws/lambda/QM-Deployment-Manager-Lambda"
    log_level             = "INFO"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
  }
}

#---------------------------------------------------------------
# Lambda Permissions Configuration
#---------------------------------------------------------------
lambda_permissions_config = {
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

#---------------------------------------------------------------
# Helper Lambda Configuration
#---------------------------------------------------------------
helper_config = {
  lambda_function = {
    name        = "Helper-Function"
    description = "SO0005 quota-monitor-for-aws - QM-Helper-Function"
    runtime     = "nodejs18.x"
    handler     = "index.handler"
    timeout     = 60
    memory_size = 128
    tags = {
      Function = "Helper"
    }
  }
  lambda_code = {
    s3_bucket = "your-lambda-code-bucket"
    s3_key    = "helper.zip"
  }
  lambda_environment = {
    stack_id       = "quota-monitor-hub"
    sdk_user_agent = "AwsSolution/SO0005/v6.3.0"
    version        = "v6.3.0"
    solution_id    = "SO0005"
    log_level      = "info"
    qm_stack_id    = "quota-monitor-hub-no-ou"
    send_metric    = "No"
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

#---------------------------------------------------------------
# SQS Configuration
#---------------------------------------------------------------
sqs_queues_config = {
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

#---------------------------------------------------------------
# SSM Parameters Configuration
#---------------------------------------------------------------
ssm_parameters_config = {
  notification_muting = {
    name        = "/QuotaMonitor/NotificationConfiguration"
    description = "Muting configuration for services"
    type        = "StringList"
    value       = "ec2:L-1216C47A,ec2:Running On-Demand Standard instances,dynamodb,logs:*,geo:L-05EFD12D"
    tier        = "Standard"
    tags = {
      Service = "Notifications"
    }
  }
  target_accounts = {
    name        = "/QuotaMonitor/Accounts"
    description = "List of accounts to monitor"
    type        = "StringList"
    value       = "405142580014,830427153490"
    tier        = "Standard"
    tags = {
      Service = "AccountManagement"
    }
  }
}

#---------------------------------------------------------------
# S3 Configuration
#---------------------------------------------------------------
create_s3 = true
s3_config = {
  bucket_name = "quota-monitor-source-code"
  versioning  = true
  lifecycle_rules = [{
    id      = "cleanup"
    enabled = true
    expiration = {
      days = 90
    }
  }]
}

source_code_objects = {
  provider_framework = {
    source_path = "source_codes/framework-onEvent.zip"
    s3_key      = "lambda/provider_framework.zip"
  }
  helper = {
    source_path = "source_codes/helper-function.zip"
    s3_key      = "lambda/helper.zip"
  }
  sns_publisher = {
    source_path = "source_codes/sns-publisher.zip"
    s3_key      = "lambda/sns_publisher.zip"
  }
  reporter = {
    source_path = "source_codes/reporter.zip"
    s3_key      = "lambda/reporter.zip"
  }
  deployment_manager = {
    source_path = "source_codes/deployment-manager.zip"
    s3_key      = "lambda/deployment_manager.zip"
  }
  utils_layer = {
    source_path = "source_codes/utils-layer.zip"
    s3_key      = "layers/utils_layer.zip"
  }
}


# IAM 
iam_role_names = {
  lambda_helper      = "HelperFunctionRole"
  deployment_manager = "DeploymentManager-Lambda-Role"
  provider_framework = "HelperProviderFrameworkOnEventRole"
  sns_publisher      = "SNSPublisher-Lambda-Role"
  reporter           = "Reporter-Lambda-Role"
}

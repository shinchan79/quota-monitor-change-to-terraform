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

#---------------------------------------------------------------
# VPC Configuration
#---------------------------------------------------------------
vpc_config = {
  security_group_ids = ["sg-04ff57abf41aa053b"]
  subnet_ids         = ["subnet-e707d7af", "subnet-3502a253"]
}

#---------------------------------------------------------------
# Lambda Functions Configuration
#---------------------------------------------------------------
lambda_functions_config = {
  sns_publisher = {
    name                  = "SNSPublisher-Function"
    description           = "SNS Publisher Function"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 30
    memory_size           = 128
    environment_log_level = "info"
    sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
    app_version           = "v6.3.0"
    solution_id           = "SO0005"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
    log_format            = "JSON"
    log_group             = "/aws/lambda/qm-SNSPublisher-Function"
    log_level             = "INFO"
    source_dir            = "source_codes"
    tags                  = {}
  }

  list_manager = {
    name                  = "ListManager-Function"
    description           = "List Manager Function"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 30
    memory_size           = 128
    environment_log_level = "info"
    sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
    app_version           = "v6.3.0"
    solution_id           = "SO0005"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
    log_format            = "JSON"
    log_group             = "/aws/lambda/qm-ListManager-Function"
    log_level             = "INFO"
    source_dir            = "source_codes"
    tags                  = {}
  }

  list_manager_provider = {
    name                  = "ListManagerProvider-Function"
    description           = "List Manager Provider Function"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 30
    memory_size           = 128
    environment_log_level = "info"
    sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
    app_version           = "v6.3.0"
    solution_id           = "SO0005"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
    log_format            = "JSON"
    log_group             = "/aws/lambda/qm-ListManagerProvider-Function"
    log_level             = "INFO"
    source_dir            = "source_codes"
    tags                  = {}
  }

  qmcw_poller = {
    name                  = "QMCWPoller-Function"
    description           = "QMCW Poller Function"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 30
    memory_size           = 128
    environment_log_level = "info"
    sdk_user_agent        = "AwsSolution/SO0005/v6.3.0"
    app_version           = "v6.3.0"
    solution_id           = "SO0005"
    max_event_age         = 14400
    lambda_qualifier      = "$LATEST"
    log_format            = "JSON"
    log_group             = "/aws/lambda/qm-QMCWPoller-Function"
    log_level             = "INFO"
    source_dir            = "source_codes"
    tags                  = {}
  }
}

#---------------------------------------------------------------
# Lambda Layer Configuration
#---------------------------------------------------------------
lambda_layer_config = {
  utils_sns_spoke = {
    layer = {
      name     = "UtilsSNSSpoke-Layer"
      runtimes = ["nodejs18.x"]
    }
  }
  utils_sq_spoke = {
    layer = {
      name     = "UtilsSQSpoke-Layer"
      runtimes = ["nodejs18.x"]
    }
  }
}

#---------------------------------------------------------------
# S3 Configuration
#---------------------------------------------------------------
create_s3 = true

s3_config = {
  bucket_name = "quota-monitor-spoke-source-code"
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
  sns_publisher = {
    source_path = "source_codes/sns-publisher.zip"
    s3_key      = "lambda/sns_publisher.zip"
  }
  list_manager = {
    source_path = "source_codes/list-manager.zip"
    s3_key      = "lambda/list_manager.zip"
  }
  list_manager_provider = {
    source_path = "source_codes/framework-onEvent.zip"
    s3_key      = "lambda/list_manager_provider.zip"
  }
  qmcw_poller = {
    source_path = "source_codes/cw-poller.zip"
    s3_key      = "lambda/qmcw_poller.zip"
  }
  utils_sns_spoke = {
    source_path = "source_codes/utils-layer.zip"
    s3_key      = "layers/utils_sns_spoke.zip"
  }
  utils_sq_spoke = {
    source_path = "source_codes/utils-layer copy.zip"
    s3_key      = "layers/utils_sq_spoke.zip"
  }
}

#---------------------------------------------------------------
# Archive Configuration
#---------------------------------------------------------------
create_archive = false

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
}

#---------------------------------------------------------------
# SQS Configuration
#---------------------------------------------------------------
sqs_queues_config = {
  sns_publisher_dlq = {
    name    = "SNSPublisher-Lambda-DLQ"
    actions = "sqs:*"
  }
  qmcw_poller_dlq = {
    name    = "QMCWPoller-Lambda-DLQ"
    actions = "sqs:*"
  }
}

#---------------------------------------------------------------
# SNS Configuration
#---------------------------------------------------------------
create_sns = true
sns_topics_config = {
  sns_publisher = {
    name = "SNSPublisher-SNSTopic"
  }
}

#---------------------------------------------------------------
# Monitoring Configuration
#---------------------------------------------------------------
monitoring_frequency    = 5
notification_threshold  = 80
report_ok_notifications = true
send_metric             = true

#---------------------------------------------------------------
# Region Configuration
#---------------------------------------------------------------
spoke_sns_region = "ap-southeast-1"

#---------------------------------------------------------------
# Event Bus Configuration
#---------------------------------------------------------------
event_bus_arn = "arn:aws:events:ap-southeast-1:405142580014:event-bus/qm-QuotaMonitorBus"
module "lambda" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  # Explicit dependency on IAM module to prevent circular dependencies
  depends_on = [module.iam]

  lambda_functions = {
    ################# SNS Spoke
    sns_publisher = {
      name        = "${var.master_prefix}-SNSPublisher-Lambda"
      description = "SO0005 quota-monitor-for-aws - sq-spoke-SNSPublisherFunction-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 60
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["sns_publisher_lambda"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
      }

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_sns_spoke"]
      ]

      environment_variables = {
        QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
        SEND_METRIC                             = var.send_metric
        TOPIC_ARN                               = module.sns.sns_topic_arns["sns_publisher"]
        LOG_LEVEL                               = var.log_level
        CUSTOM_SDK_USER_AGENT                   = var.custom_sdk_user_agent
        VERSION                                 = var.solution_version
        SOLUTION_ID                             = var.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      tags = var.tags

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/${var.master_prefix}-SNSPublisher-Lambda"
        log_level  = var.log_level
      }
    }

    ################# QM Spoke
    list_manager = {
      name        = "${var.master_prefix}-ListManager-Function"
      description = "SO0005 quota-monitor-for-aws - QM-ListManager-Function"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 900
      memory_size = 256
      role_arn    = module.iam.iam_role_arns["list_manager"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_sns_spoke"]
      ]

      environment_variables = {
        SQ_SERVICE_TABLE      = module.dynamodb.dynamodb_table_ids["service"]
        SQ_QUOTA_TABLE        = module.dynamodb.dynamodb_table_ids["quota"]
        PARTITION_KEY         = var.partition_key
        SORT                  = var.sort_key
        LOG_LEVEL             = var.log_level
        CUSTOM_SDK_USER_AGENT = var.custom_sdk_user_agent
        VERSION               = var.solution_version
        SOLUTION_ID           = var.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/${var.master_prefix}-ListManager-Function"
        log_level  = var.log_level
      }

      tags = var.tags
    }

    list_manager_provider = {
      name        = "${var.master_prefix}-ListManager-Provider-Framework"
      description = "AWS CDK resource provider framework - onEvent (quota-monitor-sq-spoke/QM-ListManager/QM-ListManager-Provider)"
      runtime     = "nodejs18.x"
      handler     = "framework.onEvent"
      timeout     = 900
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["list_manager_provider"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      environment_variables = {
        USER_ON_EVENT_FUNCTION_ARN = local.list_manager_function_arn
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/${var.master_prefix}-ListManager-Provider-Framework"
        log_level  = var.log_level
      }

      tags = var.tags
    }

    qmcw_poller = {
      name        = "${var.master_prefix}-CWPoller-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-CWPoller-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 900
      memory_size = 512
      role_arn    = module.iam.iam_role_arns["qmcw_poller_lambda"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmcw_poller_dlq"]
      }

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_sq_spoke"]
      ]

      environment_variables = {
        SQ_SERVICE_TABLE           = module.dynamodb.dynamodb_table_ids["service"]
        SQ_QUOTA_TABLE             = module.dynamodb.dynamodb_table_ids["quota"]
        SPOKE_EVENT_BUS            = module.event_bus.eventbridge_bus_names["quota_monitor_spoke"]
        POLLER_FREQUENCY           = var.monitoring_frequency
        THRESHOLD                  = var.notification_threshold
        SQ_REPORT_OK_NOTIFICATIONS = var.report_ok_notifications
        LOG_LEVEL                  = var.log_level
        CUSTOM_SDK_USER_AGENT      = var.custom_sdk_user_agent
        VERSION                    = var.solution_version
        SOLUTION_ID                = var.solution_id
      }

      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/${var.master_prefix}-CWPoller-Lambda"
        log_level  = var.log_level
      }

      tags = var.tags
    }

    ################# TA Spoke 
    ta_refresher = {
      name        = "${var.master_prefix}-TA-Refresher-Lambda"
      description = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-Lambda"
      runtime     = "nodejs18.x"
      handler     = "index.handler"
      timeout     = 60
      memory_size = 128
      role_arn    = module.iam.iam_role_arns["qm_ta_refresher_lambda_service_role"]
      s3_bucket   = var.lambda_s3_bucket
      s3_key      = var.lambda_s3_key

      dead_letter_config = {
        target_arn = module.sqs.sqs_queue_arns["qmta_refresher_dlq"]
      }

      layers = [
        module.lambda_layer.lambda_layer_arns["utils_ta"]
      ]

      environment_variables = {
        AWS_SERVICES          = var.aws_services
        LOG_LEVEL             = var.log_level
        CUSTOM_SDK_USER_AGENT = var.custom_sdk_user_agent
        VERSION               = var.solution_version
        SOLUTION_ID           = var.solution_id
      }

      event_invoke_config = {
        maximum_event_age_in_seconds = 14400
        qualifier                    = "$LATEST"
      }

      logging_config = {
        log_format = "JSON"
        log_group  = "/aws/lambda/${var.master_prefix}-TA-Refresher-Lambda"
        log_level  = var.log_level
      }

      tags = var.tags
    }
  }
}

# Local values to break circular dependencies  
locals {
  list_manager_function_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.master_prefix}-ListManager-Function"
}

variable "lambda_s3_bucket" {
  description = "S3 bucket containing lambda code"
  type        = string
}

variable "lambda_s3_key" {
  description = "S3 key for lambda code"
  type        = string
}

variable "send_metric" {
  description = "Whether to send metrics"
  type        = string
  default     = "No"
}

variable "log_level" {
  description = "Log level for Lambda functions"
  type        = string
  default     = "info"
}

variable "custom_sdk_user_agent" {
  description = "Custom SDK user agent"
  type        = string
  default     = "AwsSolution/SO0005/v6.3.0"
}

variable "solution_version" {
  description = "Solution version"
  type        = string
  default     = "v6.3.0"
}

variable "solution_id" {
  description = "Solution ID"
  type        = string
  default     = "SO0005"
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

variable "aws_services" {
  description = "Comma separated list of AWS services to monitor"
  type        = string
  default     = "AutoScaling,CloudFormation,DynamoDB,EBS,EC2,ELB,IAM,Kinesis,RDS,Route53,SES,VPC"
}
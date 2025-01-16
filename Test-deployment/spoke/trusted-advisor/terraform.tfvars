#---------------------------------------------------------------
# General Configuration
#---------------------------------------------------------------
master_prefix = "qm"
event_bus_arn = "arn:aws:events:us-east-1:123456789012:event-bus/qm-QuotaMonitorBus"

tags = {
  Environment = "Production"
  Project     = "QuotaMonitor"
}

additional_tags = {
  Owner      = "Platform Team"
  CostCenter = "123456"
}

#---------------------------------------------------------------
# Lambda Layer Configuration
#---------------------------------------------------------------
lambda_layer_config = {
  utils_ta = {
    layer = {
      name     = "UtilsLayer-TA"
      runtimes = ["nodejs18.x"]
    }
  }
}

#---------------------------------------------------------------
# Lambda Functions Configuration
#---------------------------------------------------------------
lambda_functions_config = {
  ta_refresher = {
    name                  = "TA-Refresher-Lambda"
    description           = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-Lambda"
    runtime               = "nodejs18.x"
    handler               = "index.handler"
    timeout               = 60
    memory_size           = 128
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

#---------------------------------------------------------------
# Event Rules Configuration 
#---------------------------------------------------------------
event_rules_config = {
  ta_ok = {
    name        = "TA-OK-Rule"
    description = "Quota Monitor Solution - Spoke - Rule for TA OK events"
    state       = "ENABLED"
    targets = [
      {
        id = "Target0"
      }
    ]
  }
  ta_warn = {
    name        = "TA-Warn-Rule"
    description = "Quota Monitor Solution - Spoke - Rule for TA WARN events"
    state       = "ENABLED"
    targets = [
      {
        id = "Target0"
      }
    ]
  }
  ta_error = {
    name        = "TA-Error-Rule"
    description = "Quota Monitor Solution - Spoke - Rule for TA ERROR events"
    state       = "ENABLED"
    targets = [
      {
        id = "Target0"
      }
    ]
  }
  ta_refresher = {
    name                = "TA-Refresher-Rule"
    description         = "SO0005 quota-monitor-for-aws - QM-TA-Refresher-EventsRule"
    schedule_expression = "rate(12 hours)"
    state               = "ENABLED"
    targets = [
      {
        id = "Target0"
      }
    ]
  }
}

#---------------------------------------------------------------
# IAM Role Names Configuration
#---------------------------------------------------------------
iam_role_names = {
  ta_ok_rule_events_role      = "TAOkRuleEventsRole"
  ta_warn_rule_events_role    = "TAWarnRuleEventsRole"
  ta_error_rule_events_role   = "TAErrorRuleEventsRole"
  qm_ta_refresher_lambda_role = "TARefresher-Lambda-Role"
}

#---------------------------------------------------------------
# SQS Configuration
#---------------------------------------------------------------
sqs_queues_config = {
  qmta_refresher_dlq = {
    name    = "TARefresher-Lambda-DLQ"
    actions = "sqs:*"
  }
}

#---------------------------------------------------------------
# Lambda Permissions Configuration
#---------------------------------------------------------------
lambda_permissions_config = {
  ta_refresher = {
    statement_id = "AllowEventBridgeInvoke"
    action       = "lambda:InvokeFunction"
    principal    = "events.amazonaws.com"
  }
}

#---------------------------------------------------------------
# Monitoring Configuration
#---------------------------------------------------------------
aws_services    = "AutoScaling,CloudFormation,DynamoDB,EBS,EC2,ELB,IAM,Kinesis,RDS,Route53,SES,VPC"
ta_refresh_rate = "rate(12 hours)"

#---------------------------------------------------------------
# S3 Configuration
#---------------------------------------------------------------
create_s3 = true
s3_config = {
  bucket_name = "quota-monitor-ta-spoke-source-code"
  versioning  = true
  lifecycle_rules = [
    {
      id      = "cleanup-old-versions"
      enabled = true
      expiration = {
        days = 90
      }
    }
  ]
}

source_code_objects = {
  ta_refresher = {
    source_path = "source_codes/ta-refresher.zip"
    s3_key      = "lambda/ta_refresher.zip"
  }
  utils_ta = {
    source_path = "source_codes/utils-layer.zip"
    s3_key      = "layers/utils_ta.zip"
  }
}
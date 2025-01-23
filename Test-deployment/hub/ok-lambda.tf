# Create archive files if needed
data "archive_file" "lambda" {
  for_each = var.create_archive && local.create_hub_resources ? {
    for k, v in var.lambda_functions_config : k => v
    if lookup(v, "source_dir", null) != null
  } : {}

  type        = "zip"
  source_file = format("${path.module}/%s/%s.py", each.value.source_dir, each.key)
  output_path = "${path.module}/archive_file/${each.key}.zip"
}

# Create main lambda functions
module "lambda" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  lambda_functions = {
    provider_framework = merge(
      {
        name        = var.lambda_functions_config["provider_framework"].name
        description = var.lambda_functions_config["provider_framework"].description
        runtime     = var.lambda_functions_config["provider_framework"].runtime
        handler     = var.lambda_functions_config["provider_framework"].handler
        timeout     = var.lambda_functions_config["provider_framework"].timeout
        memory_size = var.lambda_functions_config["provider_framework"].memory_size
        role_arn    = module.iam.iam_role_arns["provider_framework"]
        layers      = [module.lambda_layer.lambda_layer_arns["utils"]]
      },
      local.lambda_source["provider_framework"],
      {
        security_group_ids = var.vpc_config.security_group_ids
        subnet_ids         = var.vpc_config.subnet_ids
        environment_variables = {
          USER_ON_EVENT_FUNCTION_ARN = module.helper_lambda.lambda_function_arns["helper"]
          LOG_LEVEL                  = "info"
          METRICS_ENDPOINT           = local.quota_monitor_map.Metrics.MetricsEndpoint
          QM_STACK_ID                = "quota-monitor-hub-no-ou"
          SEND_METRIC                = "Yes"
          CUSTOM_SDK_USER_AGENT      = "AwsSolution/SO0005/v6.3.0"
          VERSION                    = "v6.3.0"
          SOLUTION_ID                = "SO0005"
        }
        logging_config = {
          log_format = var.lambda_functions_config["provider_framework"].log_format
          log_group  = var.lambda_functions_config["provider_framework"].log_group
          log_level  = var.lambda_functions_config["provider_framework"].log_level
        }
        tags = merge(
          {
            Name = var.lambda_functions_config["provider_framework"].name
          },
          try(var.lambda_functions_config["provider_framework"].tags, {}),
          local.merged_tags
        )
      }
    )

    sns_publisher = merge(
      {
        name        = var.lambda_functions_config["sns_publisher"].name
        description = var.lambda_functions_config["sns_publisher"].description
        runtime     = var.lambda_functions_config["sns_publisher"].runtime
        handler     = var.lambda_functions_config["sns_publisher"].handler
        timeout     = var.lambda_functions_config["sns_publisher"].timeout
        memory_size = var.lambda_functions_config["sns_publisher"].memory_size
        role_arn    = module.iam.iam_role_arns["sns_publisher"]
        layers      = [module.lambda_layer.lambda_layer_arns["utils"]]
      },
      local.lambda_source["sns_publisher"],
      {
        security_group_ids = var.vpc_config.security_group_ids
        subnet_ids         = var.vpc_config.subnet_ids

        dead_letter_config = {
          target_arn = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
        }

        kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

        environment_variables = {
          QM_NOTIFICATION_MUTING_CONFIG_PARAMETER = module.ssm_parameter.ssm_parameter_names["notification_muting"]
          SOLUTION_UUID                           = random_uuid.helper_uuid.result
          METRICS_ENDPOINT                        = local.quota_monitor_map.Metrics.MetricsEndpoint
          SEND_METRIC                             = local.quota_monitor_map.Metrics.SendAnonymizedData
          TOPIC_ARN                               = module.sns.sns_topic_arns["publisher"]
          LOG_LEVEL                               = "info"
          QM_STACK_ID                             = "quota-monitor-hub-no-ou"
          CUSTOM_SDK_USER_AGENT                   = "AwsSolution/SO0005/v6.3.0"
          VERSION                                 = "v6.3.0"
          SOLUTION_ID                             = "SO0005"
        }

        event_invoke_config = {
          maximum_event_age_in_seconds = var.lambda_functions_config["sns_publisher"].max_event_age
          qualifier                    = var.lambda_functions_config["sns_publisher"].lambda_qualifier
        }

        logging_config = {
          log_format = var.lambda_functions_config["sns_publisher"].log_format
          log_group  = var.lambda_functions_config["sns_publisher"].log_group
          log_level  = var.lambda_functions_config["sns_publisher"].log_level
        }

        tags = merge(
          {
            Name = var.lambda_functions_config["sns_publisher"].name
          },
          try(var.lambda_functions_config["sns_publisher"].tags, {}),
          local.merged_tags
        )
      }
    )

    reporter = merge(
      {
        name        = var.lambda_functions_config["reporter"].name
        description = var.lambda_functions_config["reporter"].description
        runtime     = var.lambda_functions_config["reporter"].runtime
        handler     = var.lambda_functions_config["reporter"].handler
        timeout     = var.lambda_functions_config["reporter"].timeout
        memory_size = var.lambda_functions_config["reporter"].memory_size
        role_arn    = module.iam.iam_role_arns["reporter"]
        layers      = [module.lambda_layer.lambda_layer_arns["utils"]]
      },
      local.lambda_source["reporter"],
      {
        security_group_ids = var.vpc_config.security_group_ids
        subnet_ids         = var.vpc_config.subnet_ids

        dead_letter_config = {
          target_arn = module.sqs.sqs_queue_arns["reporter_dlq"]
        }

        kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

        environment_variables = {
          QUOTA_TABLE           = module.dynamodb.dynamodb_table_ids["quota_monitor"]
          SQS_URL               = module.sqs.sqs_queue_urls["summarizer_event_queue"]
          MAX_MESSAGES          = var.lambda_functions_config["reporter"].max_messages
          MAX_LOOPS             = var.lambda_functions_config["reporter"].max_loops
          LOG_LEVEL             = "info"
          QM_STACK_ID           = "quota-monitor-hub-no-ou"
          CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0005/v6.3.0"
          VERSION               = "v6.3.0"
          SOLUTION_ID           = "SO0005"
        }

        event_invoke_config = {
          maximum_event_age_in_seconds = var.lambda_functions_config["reporter"].max_event_age
          qualifier                    = var.lambda_functions_config["reporter"].lambda_qualifier
        }

        logging_config = {
          log_format = var.lambda_functions_config["reporter"].log_format
          log_group  = var.lambda_functions_config["reporter"].log_group
          log_level  = var.lambda_functions_config["reporter"].log_level
        }

        tags = merge(
          {
            Name = var.lambda_functions_config["reporter"].name
          },
          try(var.lambda_functions_config["reporter"].tags, {}),
          local.merged_tags
        )
      }
    )

    deployment_manager = merge(
      {
        name        = var.lambda_functions_config["deployment_manager"].name
        description = var.lambda_functions_config["deployment_manager"].description
        runtime     = var.lambda_functions_config["deployment_manager"].runtime
        handler     = var.lambda_functions_config["deployment_manager"].handler
        timeout     = var.lambda_functions_config["deployment_manager"].timeout
        memory_size = var.lambda_functions_config["deployment_manager"].memory_size
        role_arn    = module.iam.iam_role_arns["deployment_manager"]
        layers      = [module.lambda_layer.lambda_layer_arns["utils"]]
      },
      local.lambda_source["deployment_manager"],
      {
        dead_letter_config = {
          target_arn = module.sqs.sqs_queue_arns["deployment_manager_dlq"]
        }

        kms_key_arn = module.kms.kms_key_arns["qm_encryption"]

        environment_variables = {
          EVENT_BUS_NAME        = module.event_bus.eventbridge_bus_names["quota_monitor"]
          EVENT_BUS_ARN         = module.event_bus.eventbridge_bus_arns["quota_monitor"]
          QM_ACCOUNT_PARAMETER  = module.ssm_parameter.ssm_parameter_names["target_accounts"]
          DEPLOYMENT_MODEL      = "Accounts"
          LOG_LEVEL            = "info"
          CUSTOM_SDK_USER_AGENT = "AwsSolution/SO0005/v6.3.0"
          VERSION              = "v6.3.0"
          SOLUTION_ID          = "SO0005"
        }

        event_invoke_config = {
          maximum_event_age_in_seconds = var.lambda_functions_config["deployment_manager"].max_event_age
          qualifier                    = var.lambda_functions_config["deployment_manager"].lambda_qualifier
        }

        logging_config = {
          log_format = var.lambda_functions_config["deployment_manager"].log_format
          log_group  = var.lambda_functions_config["deployment_manager"].log_group
          log_level  = var.lambda_functions_config["deployment_manager"].log_level
        }

        tags = merge(
          {
            Name = var.lambda_functions_config["deployment_manager"].name
          },
          try(var.lambda_functions_config["deployment_manager"].tags, {}),
          local.merged_tags
        )
      }
    )
  }

  depends_on = [
    module.helper_lambda,
    module.iam,
    module.sqs,
    module.kms,
    module.lambda_layer,
    module.ssm_parameter,
    module.sns,
    module.dynamodb,
    module.event_bus
  ]
}


    # "QMSlackNotifierQMSlackNotifierLambda95713661": {
    #   "Type": "AWS::Lambda::Function",
    #   "Properties": {
    #     "Code": {
    #       "S3Bucket": {
    #         "Fn::Sub": "solutions-${AWS::Region}"
    #       },
    #       "S3Key": "quota-monitor-for-aws/v6.3.0/asset11434a0b3246f0b4445dd28fdbc9e4e7dc808ccf355077acd9b000c5d88e6713.zip"
    #     },
    #     "DeadLetterConfig": {
    #       "TargetArn": {
    #         "Fn::GetAtt": [
    #           "QMSlackNotifierQMSlackNotifierLambdaDeadLetterQueue74B865F7",
    #           "Arn"
    #         ]
    #       }
    #     },
    #     "Description": "SO0005 quota-monitor-for-aws - QM-SlackNotifier-Lambda",
    #     "Environment": {
    #       "Variables": {
    #         "SLACK_HOOK": {
    #           "Fn::FindInMap": [
    #             "QuotaMonitorMap",
    #             "SSMParameters",
    #             "SlackHook"
    #           ]
    #         },
    #         "QM_NOTIFICATION_MUTING_CONFIG_PARAMETER": {
    #           "Ref": "QMNotificationMutingConfig3B7948BA"
    #         },
    #         "LOG_LEVEL": "info",
    #         "CUSTOM_SDK_USER_AGENT": "AwsSolution/SO0005/v6.3.0",
    #         "VERSION": "v6.3.0",
    #         "SOLUTION_ID": "SO0005"
    #       }
    #     },
    #     "Handler": "index.handler",
    #     "KmsKeyArn": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     },
    #     "Layers": [
    #       {
    #         "Ref": "QMUtilsLayerQMUtilsLayerLayer80D5D993"
    #       }
    #     ],
    #     "MemorySize": 128,
    #     "Role": {
    #       "Fn::GetAtt": [
    #         "QMSlackNotifierQMSlackNotifierLambdaServiceRole6342FD1D",
    #         "Arn"
    #       ]
    #     },
    #     "Runtime": "nodejs18.x",
    #     "Timeout": 60
    #   },
    #   "DependsOn": [
    #     "QMSlackNotifierQMSlackNotifierLambdaServiceRoleDefaultPolicy4C4D219B",
    #     "QMSlackNotifierQMSlackNotifierLambdaServiceRole6342FD1D"
    #   ],
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-Lambda/Resource",
    #     "aws:asset:path": "asset.11434a0b3246f0b4445dd28fdbc9e4e7dc808ccf355077acd9b000c5d88e6713.zip",
    #     "aws:asset:is-bundled": false,
    #     "aws:asset:property": "Code",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     },
    #     "guard": {
    #       "SuppressedRules": [
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK",
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK"
    #       ]
    #     }
    #   },
    #   "Condition": "SlackTrueCondition"
    # },
    # "QMSlackNotifierQMSlackNotifierLambdaEventInvokeConfig5340A982": {
    #   "Type": "AWS::Lambda::EventInvokeConfig",
    #   "Properties": {
    #     "FunctionName": {
    #       "Ref": "QMSlackNotifierQMSlackNotifierLambda95713661"
    #     },
    #     "MaximumEventAgeInSeconds": 14400,
    #     "Qualifier": "$LATEST"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-Lambda/EventInvokeConfig/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   },
    #   "Condition": "SlackTrueCondition"
    # },


    #     "QMHelperQMHelperFunction91954E97": {
    #   "Type": "AWS::Lambda::Function",
    #   "Properties": {
    #     "Code": {
    #       "S3Bucket": {
    #         "Fn::Sub": "solutions-${AWS::Region}"
    #       },
    #       "S3Key": "quota-monitor-for-aws/v6.3.0/assetf4ee0c3d949f011b3f0f60d231fdacecab71c5f3ccf9674352231cedf831f6cd.zip"
    #     },
    #     "Description": "SO0005 quota-monitor-for-aws - QM-Helper-Function",
    #     "Environment": {
    #       "Variables": {
    #         "METRICS_ENDPOINT": {
    #           "Fn::FindInMap": [
    #             "QuotaMonitorMap",
    #             "Metrics",
    #             "MetricsEndpoint"
    #           ]
    #         },
    #         "SEND_METRIC": {
    #           "Fn::FindInMap": [
    #             "QuotaMonitorMap",
    #             "Metrics",
    #             "SendAnonymizedData"
    #           ]
    #         },
    #         "QM_STACK_ID": "quota-monitor-hub-no-ou",
    #         "LOG_LEVEL": "info",
    #         "CUSTOM_SDK_USER_AGENT": "AwsSolution/SO0005/v6.3.0",
    #         "VERSION": "v6.3.0",
    #         "SOLUTION_ID": "SO0005"
    #       }
    #     },
    #     "Handler": "index.handler",
    #     "Layers": [
    #       {
    #         "Ref": "QMUtilsLayerQMUtilsLayerLayer80D5D993"
    #       }
    #     ],
    #     "MemorySize": 128,
    #     "Role": {
    #       "Fn::GetAtt": [
    #         "QMHelperQMHelperFunctionServiceRole0506622D",
    #         "Arn"
    #       ]
    #     },
    #     "Runtime": "nodejs18.x",
    #     "Timeout": 5
    #   },
    #   "DependsOn": [
    #     "QMHelperQMHelperFunctionServiceRole0506622D"
    #   ],
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Function/Resource",
    #     "aws:asset:path": "asset.f4ee0c3d949f011b3f0f60d231fdacecab71c5f3ccf9674352231cedf831f6cd.zip",
    #     "aws:asset:is-bundled": false,
    #     "aws:asset:property": "Code",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     },
    #     "guard": {
    #       "SuppressedRules": [
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK",
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK"
    #       ]
    #     }
    #   }
    # },
    # "QMHelperQMHelperFunctionEventInvokeConfig580F9F5F": {
    #   "Type": "AWS::Lambda::EventInvokeConfig",
    #   "Properties": {
    #     "FunctionName": {
    #       "Ref": "QMHelperQMHelperFunction91954E97"
    #     },
    #     "MaximumEventAgeInSeconds": 14400,
    #     "Qualifier": "$LATEST"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Function/EventInvokeConfig/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },


    #     "QMHelperQMHelperProviderframeworkonEventB1DF6D3F": {
    #   "Type": "AWS::Lambda::Function",
    #   "Properties": {
    #     "Code": {
    #       "S3Bucket": {
    #         "Fn::Sub": "solutions-${AWS::Region}"
    #       },
    #       "S3Key": "quota-monitor-for-aws/v6.3.0/asset7382a0addb9f34974a1ea6c6c9b063882af874828f366f5c93b2b7b64db15c94.zip"
    #     },
    #     "Description": "AWS CDK resource provider framework - onEvent (quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Provider)",
    #     "Environment": {
    #       "Variables": {
    #         "USER_ON_EVENT_FUNCTION_ARN": {
    #           "Fn::GetAtt": [
    #             "QMHelperQMHelperFunction91954E97",
    #             "Arn"
    #           ]
    #         }
    #       }
    #     },
    #     "Handler": "framework.onEvent",
    #     "Role": {
    #       "Fn::GetAtt": [
    #         "QMHelperQMHelperProviderframeworkonEventServiceRole4A1EBBAB",
    #         "Arn"
    #       ]
    #     },
    #     "Runtime": "nodejs18.x",
    #     "Timeout": 900
    #   },
    #   "DependsOn": [
    #     "QMHelperQMHelperProviderframeworkonEventServiceRoleDefaultPolicy86C1FCC1",
    #     "QMHelperQMHelperProviderframeworkonEventServiceRole4A1EBBAB"
    #   ],
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Provider/framework-onEvent/Resource",
    #     "aws:asset:path": "asset.7382a0addb9f34974a1ea6c6c9b063882af874828f366f5c93b2b7b64db15c94",
    #     "aws:asset:is-bundled": false,
    #     "aws:asset:property": "Code",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "IAM policy is appropriated scoped, ARN is provided in policy resource, false warning",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "Lambda function created by Provider L2 construct uses nodejs 14, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     },
    #     "guard": {
    #       "SuppressedRules": [
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK"
    #       ]
    #     }
    #   }
    # },



    #     "QMSNSPublisherFunctionQMSNSPublisherFunctionLambda8BD2DBC1": {
    #   "Type": "AWS::Lambda::Function",
    #   "Properties": {
    #     "Code": {
    #       "S3Bucket": {
    #         "Fn::Sub": "solutions-${AWS::Region}"
    #       },
    #       "S3Key": "quota-monitor-for-aws/v6.3.0/assete7a324e67e467d0c22e13b0693ca4efdceb0d53025c7fb45fe524870a5c18046.zip"
    #     },
    #     "DeadLetterConfig": {
    #       "TargetArn": {
    #         "Fn::GetAtt": [
    #           "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaDeadLetterQueue72FF519A",
    #           "Arn"
    #         ]
    #       }
    #     },
    #     "Description": "SO0005 quota-monitor-for-aws - QM-SNSPublisherFunction-Lambda",
    #     "Environment": {
    #       "Variables": {
    #         "QM_NOTIFICATION_MUTING_CONFIG_PARAMETER": {
    #           "Ref": "QMNotificationMutingConfig3B7948BA"
    #         },
    #         "SOLUTION_UUID": {
    #           "Fn::GetAtt": [
    #             "QMHelperCreateUUIDE0D423E6",
    #             "UUID"
    #           ]
    #         },
    #         "METRICS_ENDPOINT": {
    #           "Fn::FindInMap": [
    #             "QuotaMonitorMap",
    #             "Metrics",
    #             "MetricsEndpoint"
    #           ]
    #         },
    #         "SEND_METRIC": {
    #           "Fn::FindInMap": [
    #             "QuotaMonitorMap",
    #             "Metrics",
    #             "SendAnonymizedData"
    #           ]
    #         },
    #         "TOPIC_ARN": {
    #           "Ref": "QMSNSPublisherQMSNSPublisherSNSTopic7EE2EBF4"
    #         },
    #         "LOG_LEVEL": "info",
    #         "CUSTOM_SDK_USER_AGENT": "AwsSolution/SO0005/v6.3.0",
    #         "VERSION": "v6.3.0",
    #         "SOLUTION_ID": "SO0005"
    #       }
    #     },
    #     "Handler": "index.handler",
    #     "KmsKeyArn": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     },
    #     "Layers": [
    #       {
    #         "Ref": "QMUtilsLayerQMUtilsLayerLayer80D5D993"
    #       }
    #     ],
    #     "MemorySize": 128,
    #     "Role": {
    #       "Fn::GetAtt": [
    #         "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleA2F00B10",
    #         "Arn"
    #       ]
    #     },
    #     "Runtime": "nodejs18.x",
    #     "Timeout": 60
    #   },
    #   "DependsOn": [
    #     "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleDefaultPolicy1E6E152C",
    #     "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleA2F00B10"
    #   ],
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SNSPublisherFunction/QM-SNSPublisherFunction-Lambda/Resource",
    #     "aws:asset:path": "asset.e7a324e67e467d0c22e13b0693ca4efdceb0d53025c7fb45fe524870a5c18046.zip",
    #     "aws:asset:is-bundled": false,
    #     "aws:asset:property": "Code",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     },
    #     "guard": {
    #       "SuppressedRules": [
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK"
    #       ]
    #     }
    #   }
    # },
    # "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaEventInvokeConfig7A963AA0": {
    #   "Type": "AWS::Lambda::EventInvokeConfig",
    #   "Properties": {
    #     "FunctionName": {
    #       "Ref": "QMSNSPublisherFunctionQMSNSPublisherFunctionLambda8BD2DBC1"
    #     },
    #     "MaximumEventAgeInSeconds": 14400,
    #     "Qualifier": "$LATEST"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SNSPublisherFunction/QM-SNSPublisherFunction-Lambda/EventInvokeConfig/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },



    #     "QMReporterQMReporterLambda7D98A6E4": {
    #   "Type": "AWS::Lambda::Function",
    #   "Properties": {
    #     "Code": {
    #       "S3Bucket": {
    #         "Fn::Sub": "solutions-${AWS::Region}"
    #       },
    #       "S3Key": "quota-monitor-for-aws/v6.3.0/asseta6fda81c73d731886f04e1734d036f12ceb7b94c2efec30bb511f477ac58aa9c.zip"
    #     },
    #     "DeadLetterConfig": {
    #       "TargetArn": {
    #         "Fn::GetAtt": [
    #           "QMReporterQMReporterLambdaDeadLetterQueueA0C464BC",
    #           "Arn"
    #         ]
    #       }
    #     },
    #     "Description": "SO0005 quota-monitor-for-aws - QM-Reporter-Lambda",
    #     "Environment": {
    #       "Variables": {
    #         "QUOTA_TABLE": {
    #           "Ref": "QMTable336670B0"
    #         },
    #         "SQS_URL": {
    #           "Ref": "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A"
    #         },
    #         "MAX_MESSAGES": "10",
    #         "MAX_LOOPS": "10",
    #         "LOG_LEVEL": "info",
    #         "CUSTOM_SDK_USER_AGENT": "AwsSolution/SO0005/v6.3.0",
    #         "VERSION": "v6.3.0",
    #         "SOLUTION_ID": "SO0005"
    #       }
    #     },
    #     "Handler": "index.handler",
    #     "KmsKeyArn": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     },
    #     "Layers": [
    #       {
    #         "Ref": "QMUtilsLayerQMUtilsLayerLayer80D5D993"
    #       }
    #     ],
    #     "MemorySize": 512,
    #     "Role": {
    #       "Fn::GetAtt": [
    #         "QMReporterQMReporterLambdaServiceRoleBA4CED84",
    #         "Arn"
    #       ]
    #     },
    #     "Runtime": "nodejs18.x",
    #     "Timeout": 10
    #   },
    #   "DependsOn": [
    #     "QMReporterQMReporterLambdaServiceRoleDefaultPolicyC6B87A76",
    #     "QMReporterQMReporterLambdaServiceRoleBA4CED84"
    #   ],
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-Lambda/Resource",
    #     "aws:asset:path": "asset.a6fda81c73d731886f04e1734d036f12ceb7b94c2efec30bb511f477ac58aa9c.zip",
    #     "aws:asset:is-bundled": false,
    #     "aws:asset:property": "Code",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     },
    #     "guard": {
    #       "SuppressedRules": [
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK"
    #       ]
    #     }
    #   }
    # },
    # "QMReporterQMReporterLambdaEventInvokeConfig07548BFA": {
    #   "Type": "AWS::Lambda::EventInvokeConfig",
    #   "Properties": {
    #     "FunctionName": {
    #       "Ref": "QMReporterQMReporterLambda7D98A6E4"
    #     },
    #     "MaximumEventAgeInSeconds": 14400,
    #     "Qualifier": "$LATEST"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-Lambda/EventInvokeConfig/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },

    # "QMDeploymentManagerQMDeploymentManagerLambdaB36F1B21": {
    #   "Type": "AWS::Lambda::Function",
    #   "Properties": {
    #     "Code": {
    #       "S3Bucket": {
    #         "Fn::Sub": "solutions-${AWS::Region}"
    #       },
    #       "S3Key": "quota-monitor-for-aws/v6.3.0/asset6a1cf55956fc481a1f22a54b0fa78a3d78b7e61cd41e12bf80ac8c9404ff9eb2.zip"
    #     },
    #     "DeadLetterConfig": {
    #       "TargetArn": {
    #         "Fn::GetAtt": [
    #           "QMDeploymentManagerQMDeploymentManagerLambdaDeadLetterQueue9B4636C2",
    #           "Arn"
    #         ]
    #       }
    #     },
    #     "Description": "SO0005 quota-monitor-for-aws - QM-Deployment-Manager-Lambda",
    #     "Environment": {
    #       "Variables": {
    #         "EVENT_BUS_NAME": {
    #           "Ref": "QMBusFF5C6C0C"
    #         },
    #         "EVENT_BUS_ARN": {
    #           "Fn::GetAtt": [
    #             "QMBusFF5C6C0C",
    #             "Arn"
    #           ]
    #         },
    #         "QM_ACCOUNT_PARAMETER": {
    #           "Ref": "QMAccounts3D743F6B"
    #         },
    #         "DEPLOYMENT_MODEL": "Accounts",
    #         "LOG_LEVEL": "info",
    #         "CUSTOM_SDK_USER_AGENT": "AwsSolution/SO0005/v6.3.0",
    #         "VERSION": "v6.3.0",
    #         "SOLUTION_ID": "SO0005"
    #       }
    #     },
    #     "Handler": "index.handler",
    #     "KmsKeyArn": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     },
    #     "Layers": [
    #       {
    #         "Ref": "QMUtilsLayerQMUtilsLayerLayer80D5D993"
    #       }
    #     ],
    #     "MemorySize": 512,
    #     "Role": {
    #       "Fn::GetAtt": [
    #         "QMDeploymentManagerQMDeploymentManagerLambdaServiceRole84304F72",
    #         "Arn"
    #       ]
    #     },
    #     "Runtime": "nodejs18.x",
    #     "Timeout": 60
    #   },
    #   "DependsOn": [
    #     "QMDeploymentManagerQMDeploymentManagerLambdaServiceRoleDefaultPolicy7E3D0777",
    #     "QMDeploymentManagerQMDeploymentManagerLambdaServiceRole84304F72"
    #   ],
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-Lambda/Resource",
    #     "aws:asset:path": "asset.6a1cf55956fc481a1f22a54b0fa78a3d78b7e61cd41e12bf80ac8c9404ff9eb2.zip",
    #     "aws:asset:is-bundled": false,
    #     "aws:asset:property": "Code",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     },
    #     "guard": {
    #       "SuppressedRules": [
    #         "LAMBDA_INSIDE_VPC",
    #         "LAMBDA_CONCURRENCY_CHECK"
    #       ]
    #     }
    #   }
    # },
    # "QMDeploymentManagerQMDeploymentManagerLambdaEventInvokeConfig4C3821AB": {
    #   "Type": "AWS::Lambda::EventInvokeConfig",
    #   "Properties": {
    #     "FunctionName": {
    #       "Ref": "QMDeploymentManagerQMDeploymentManagerLambdaB36F1B21"
    #     },
    #     "MaximumEventAgeInSeconds": 14400,
    #     "Qualifier": "$LATEST"
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-Lambda/EventInvokeConfig/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },

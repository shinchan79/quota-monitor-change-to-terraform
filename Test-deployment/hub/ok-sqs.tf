module "sqs" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  create_sqs = true
  sqs_queue = {
    # slack_notifier_dlq = {
    #   name              = var.sqs_queues_config["slack_notifier_dlq"].name
    #   kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

    #   policy = jsonencode({
    #     Version = "2012-10-17"
    #     Statement = [
    #       {
    #         Effect = "Deny"
    #         Principal = {
    #           AWS = "*"
    #         }
    #         Action   = var.sqs_queues_config["slack_notifier_dlq"].actions
    #         Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["slack_notifier_dlq"].name}"
    #         Condition = {
    #           Bool = {
    #             "aws:SecureTransport" = "false"
    #           }
    #         }
    #       }
    #     ]
    #   })

    #   tags = local.merged_tags
    # }

    sns_publisher_dlq = {
      name              = var.sqs_queues_config["sns_publisher_dlq"].name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["sns_publisher_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["sns_publisher_dlq"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = local.merged_tags
    }

    summarizer_event_queue = {
      name               = var.sqs_queues_config["summarizer_event_queue"].name
      visibility_timeout = var.sqs_queues_config["summarizer_event_queue"].visibility_timeout
      kms_master_key_id  = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["summarizer_event_queue"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["summarizer_event_queue"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          },
          {
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
            Action   = var.sqs_queues_config["summarizer_event_queue"].eventbridge_actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["summarizer_event_queue"].name}"
          }
        ]
      })

      tags = local.merged_tags
    }

    reporter_dlq = {
      name              = var.sqs_queues_config["reporter_dlq"].name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["reporter_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["reporter_dlq"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = local.merged_tags
    }

    deployment_manager_dlq = {
      name              = var.sqs_queues_config["deployment_manager_dlq"].name
      kms_master_key_id = module.kms.kms_key_arns["qm_encryption"]

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Principal = {
              AWS = "*"
            }
            Action   = var.sqs_queues_config["deployment_manager_dlq"].actions
            Resource = "arn:${data.aws_partition.current.partition}:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.master_prefix}-${var.sqs_queues_config["deployment_manager_dlq"].name}"
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })

      tags = local.merged_tags
    }
  }
}


    # "QMSlackNotifierQMSlackNotifierLambdaDeadLetterQueue74B865F7": {
    #   "Type": "AWS::SQS::Queue",
    #   "Properties": {
    #     "KmsMasterKeyId": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "UpdateReplacePolicy": "Delete",
    #   "DeletionPolicy": "Delete",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-Lambda-Dead-Letter-Queue/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "Queue itself is dead-letter queue",
    #           "id": "AwsSolutions-SQS3"
    #         }
    #       ]
    #     }
    #   },
    #   "Condition": "SlackTrueCondition"
    # },
    # "QMSlackNotifierQMSlackNotifierLambdaDeadLetterQueuePolicy719E4C6A": {
    #   "Type": "AWS::SQS::QueuePolicy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:*",
    #           "Condition": {
    #             "Bool": {
    #               "aws:SecureTransport": "false"
    #             }
    #           },
    #           "Effect": "Deny",
    #           "Principal": {
    #             "AWS": "*"
    #           },
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMSlackNotifierQMSlackNotifierLambdaDeadLetterQueue74B865F7",
    #               "Arn"
    #             ]
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "Queues": [
    #       {
    #         "Ref": "QMSlackNotifierQMSlackNotifierLambdaDeadLetterQueue74B865F7"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-Lambda-Dead-Letter-Queue/Policy/Resource"
    #   },
    #   "Condition": "SlackTrueCondition"
    # },



    #     "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A": {
    #   "Type": "AWS::SQS::Queue",
    #   "Properties": {
    #     "KmsMasterKeyId": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     },
    #     "VisibilityTimeout": 60
    #   },
    #   "UpdateReplacePolicy": "Delete",
    #   "DeletionPolicy": "Delete",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Summarizer-EventQueue/QM-Summarizer-EventQueue-Queue/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "dlq not implemented on sqs, will evaluate in future if there is need",
    #           "id": "AwsSolutions-SQS3"
    #         }
    #       ]
    #     }
    #   }
    # },
    # "QMSummarizerEventQueueQMSummarizerEventQueueQueuePolicyE7E1F6D8": {
    #   "Type": "AWS::SQS::QueuePolicy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:*",
    #           "Condition": {
    #             "Bool": {
    #               "aws:SecureTransport": "false"
    #             }
    #           },
    #           "Effect": "Deny",
    #           "Principal": {
    #             "AWS": "*"
    #           },
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": [
    #             "sqs:SendMessage",
    #             "sqs:GetQueueAttributes",
    #             "sqs:GetQueueUrl"
    #           ],
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "events.amazonaws.com"
    #           },
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A",
    #               "Arn"
    #             ]
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "Queues": [
    #       {
    #         "Ref": "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Summarizer-EventQueue/QM-Summarizer-EventQueue-Queue/Policy/Resource"
    #   }
    # },


    #     "QMTable336670B0": {
    #   "Type": "AWS::DynamoDB::Table",
    #   "Properties": {
    #     "AttributeDefinitions": [
    #       {
    #         "AttributeName": "MessageId",
    #         "AttributeType": "S"
    #       },
    #       {
    #         "AttributeName": "TimeStamp",
    #         "AttributeType": "S"
    #       }
    #     ],
    #     "BillingMode": "PAY_PER_REQUEST",
    #     "KeySchema": [
    #       {
    #         "AttributeName": "MessageId",
    #         "KeyType": "HASH"
    #       },
    #       {
    #         "AttributeName": "TimeStamp",
    #         "KeyType": "RANGE"
    #       }
    #     ],
    #     "PointInTimeRecoverySpecification": {
    #       "PointInTimeRecoveryEnabled": true
    #     },
    #     "SSESpecification": {
    #       "KMSMasterKeyId": {
    #         "Fn::GetAtt": [
    #           "KMSHubQMEncryptionKeyA80F8C05",
    #           "Arn"
    #         ]
    #       },
    #       "SSEEnabled": true,
    #       "SSEType": "KMS"
    #     },
    #     "TimeToLiveSpecification": {
    #       "AttributeName": "ExpiryTime",
    #       "Enabled": true
    #     }
    #   },
    #   "UpdateReplacePolicy": "Retain",
    #   "DeletionPolicy": "Retain",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Table/Resource"
    #   }
    # },


    #     "QMReporterQMReporterLambdaDeadLetterQueueA0C464BC": {
    #   "Type": "AWS::SQS::Queue",
    #   "Properties": {
    #     "KmsMasterKeyId": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "UpdateReplacePolicy": "Delete",
    #   "DeletionPolicy": "Delete",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-Lambda-Dead-Letter-Queue/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "Queue itself is dead-letter queue",
    #           "id": "AwsSolutions-SQS3"
    #         }
    #       ]
    #     }
    #   }
    # },
    # "QMReporterQMReporterLambdaDeadLetterQueuePolicyE714847D": {
    #   "Type": "AWS::SQS::QueuePolicy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:*",
    #           "Condition": {
    #             "Bool": {
    #               "aws:SecureTransport": "false"
    #             }
    #           },
    #           "Effect": "Deny",
    #           "Principal": {
    #             "AWS": "*"
    #           },
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMReporterQMReporterLambdaDeadLetterQueueA0C464BC",
    #               "Arn"
    #             ]
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "Queues": [
    #       {
    #         "Ref": "QMReporterQMReporterLambdaDeadLetterQueueA0C464BC"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-Lambda-Dead-Letter-Queue/Policy/Resource"
    #   }
    # },


    #     "QMDeploymentManagerQMDeploymentManagerEventsRuleAllowEventRulequotamonitorhubnoouQMDeploymentManagerQMDeploymentManagerLambda69BB20E9F676A8A9": {
    #   "Type": "AWS::Lambda::Permission",
    #   "Properties": {
    #     "Action": "lambda:InvokeFunction",
    #     "FunctionName": {
    #       "Fn::GetAtt": [
    #         "QMDeploymentManagerQMDeploymentManagerLambdaB36F1B21",
    #         "Arn"
    #       ]
    #     },
    #     "Principal": "events.amazonaws.com",
    #     "SourceArn": {
    #       "Fn::GetAtt": [
    #         "QMDeploymentManagerQMDeploymentManagerEventsRule53DB2DA9",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-EventsRule/AllowEventRulequotamonitorhubnoouQMDeploymentManagerQMDeploymentManagerLambda69BB20E9"
    #   }
    # },
    # "QMDeploymentManagerQMDeploymentManagerLambdaDeadLetterQueue9B4636C2": {
    #   "Type": "AWS::SQS::Queue",
    #   "Properties": {
    #     "KmsMasterKeyId": {
    #       "Fn::GetAtt": [
    #         "KMSHubQMEncryptionKeyA80F8C05",
    #         "Arn"
    #       ]
    #     }
    #   },
    #   "UpdateReplacePolicy": "Delete",
    #   "DeletionPolicy": "Delete",
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-Lambda-Dead-Letter-Queue/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "Queue itself is dead-letter queue",
    #           "id": "AwsSolutions-SQS3"
    #         }
    #       ]
    #     }
    #   }
    # },
    # "QMDeploymentManagerQMDeploymentManagerLambdaDeadLetterQueuePolicy6B59E185": {
    #   "Type": "AWS::SQS::QueuePolicy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:*",
    #           "Condition": {
    #             "Bool": {
    #               "aws:SecureTransport": "false"
    #             }
    #           },
    #           "Effect": "Deny",
    #           "Principal": {
    #             "AWS": "*"
    #           },
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMDeploymentManagerQMDeploymentManagerLambdaDeadLetterQueue9B4636C2",
    #               "Arn"
    #             ]
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "Queues": [
    #       {
    #         "Ref": "QMDeploymentManagerQMDeploymentManagerLambdaDeadLetterQueue9B4636C2"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-Lambda-Dead-Letter-Queue/Policy/Resource"
    #   }
    # },
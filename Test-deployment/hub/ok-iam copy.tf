module "iam" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  # IAM roles 
  create_role = true
  iam_roles = {
    lambda_helper = {
      name = "${var.master_prefix}-${var.iam_role_names["lambda_helper"]}"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
      additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]

      policies = {
        vpc_permissions = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
              ]
              Resource = "*"
            }
          ]
        })
      }
      tags = local.merged_tags
    }

    provider_framework = {
      name = "${var.master_prefix}-${var.iam_role_names["provider_framework"]}"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
      additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
      ]

      policies = {
        lambda_invoke = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "lambda:InvokeFunction"
              Resource = [
                "arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
              ]
            }
          ]
        })
      }

      tags = local.merged_tags
    }

    sns_publisher = {
      name = "${var.master_prefix}-${var.iam_role_names["sns_publisher"]}"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
      additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
      ]

      policies = {
        lambda_permissions = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect   = "Allow"
              Action   = "sqs:SendMessage"
              Resource = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:CreateGrant"
              ]
              Resource = module.kms.kms_key_arns["qm_encryption"]
            },
            {
              Effect   = "Allow"
              Action   = "kms:ListAliases"
              Resource = "*"
            },
            {
              Effect   = "Allow"
              Action   = "SNS:Publish"
              Resource = module.sns.sns_topic_arns["publisher"]
            },
            {
              Effect   = "Allow"
              Action   = "kms:GenerateDataKey"
              Resource = module.kms.kms_key_arns["qm_encryption"]
            },
            {
              Effect   = "Allow"
              Action   = "ssm:GetParameter"
              Resource = module.ssm_parameter.ssm_parameter_arns["notification_muting"]
            }
          ]
        })
      }

      tags = local.merged_tags
    }

    reporter = {
      name = "${var.master_prefix}-${var.iam_role_names["reporter"]}"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
      additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
      ]

      policies = {
        lambda_permissions = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect   = "Allow"
              Action   = "sqs:SendMessage"
              Resource = module.sqs.sqs_queue_arns["reporter_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:CreateGrant"
              ]
              Resource = module.kms.kms_key_arns["qm_encryption"]
            },
            {
              Effect   = "Allow"
              Action   = "kms:ListAliases"
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage"
              ]
              Resource = module.sqs.sqs_queue_arns["summarizer_event_queue"]
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:GetItem",
                "dynamodb:PutItem"
              ]
              Resource = module.dynamodb.dynamodb_table_arns["quota_monitor"]
            }
          ]
        })
      }

      tags = local.merged_tags
    }

    deployment_manager = {
      name = "${var.master_prefix}-${var.iam_role_names["deployment_manager"]}"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "lambda.amazonaws.com"
            }
          }
        ]
      })
      additional_policies = [
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
        "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
      ]

      policies = {
        lambda_permissions = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect   = "Allow"
              Action   = "sqs:SendMessage"
              Resource = module.sqs.sqs_queue_arns["deployment_manager_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:CreateGrant"
              ]
              Resource = module.kms.kms_key_arns["qm_encryption"]
            },
            {
              Effect   = "Allow"
              Action   = "kms:ListAliases"
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "events:PutPermission",
                "events:RemovePermission"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = "events:DescribeEventBus"
              Resource = module.event_bus.eventbridge_bus_arns["quota_monitor"]
            },
            {
              Effect = "Allow"
              Action = "ssm:GetParameter"
              Resource = module.ssm_parameter.ssm_parameter_arns["target_accounts"]
            },
            {
              Effect = "Allow"
              Action = "support:DescribeTrustedAdvisorChecks"
              Resource = "*"
            }
          ]
        })
      }
      tags = local.merged_tags
    }
  }
}


    # "QMSlackNotifierQMSlackNotifierLambdaServiceRole6342FD1D": {
    #   "Type": "AWS::IAM::Role",
    #   "Properties": {
    #     "AssumeRolePolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sts:AssumeRole",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "lambda.amazonaws.com"
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "ManagedPolicyArns": [
    #       {
    #         "Fn::Join": [
    #           "",
    #           [
    #             "arn:",
    #             {
    #               "Ref": "AWS::Partition"
    #             },
    #             ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    #           ]
    #         ]
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-Lambda/ServiceRole/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   },
    #   "Condition": "SlackTrueCondition"
    # },
    # "QMSlackNotifierQMSlackNotifierLambdaServiceRoleDefaultPolicy4C4D219B": {
    #   "Type": "AWS::IAM::Policy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:SendMessage",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMSlackNotifierQMSlackNotifierLambdaDeadLetterQueue74B865F7",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": [
    #             "kms:Encrypt",
    #             "kms:Decrypt",
    #             "kms:CreateGrant"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "KMSHubQMEncryptionKeyA80F8C05",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "kms:ListAliases",
    #           "Effect": "Allow",
    #           "Resource": "*"
    #         },
    #         {
    #           "Action": "ssm:GetParameter",
    #           "Effect": "Allow",
    #           "Resource": [
    #             {
    #               "Fn::Join": [
    #                 "",
    #                 [
    #                   "arn:",
    #                   {
    #                     "Ref": "AWS::Partition"
    #                   },
    #                   ":ssm:",
    #                   {
    #                     "Ref": "AWS::Region"
    #                   },
    #                   ":",
    #                   {
    #                     "Ref": "AWS::AccountId"
    #                   },
    #                   ":parameter",
    #                   {
    #                     "Ref": "QMSlackHook4F1AD495"
    #                   }
    #                 ]
    #               ]
    #             },
    #             {
    #               "Fn::Join": [
    #                 "",
    #                 [
    #                   "arn:",
    #                   {
    #                     "Ref": "AWS::Partition"
    #                   },
    #                   ":ssm:",
    #                   {
    #                     "Ref": "AWS::Region"
    #                   },
    #                   ":",
    #                   {
    #                     "Ref": "AWS::AccountId"
    #                   },
    #                   ":parameter",
    #                   {
    #                     "Ref": "QMNotificationMutingConfig3B7948BA"
    #                   }
    #                 ]
    #               ]
    #             }
    #           ]
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "PolicyName": "QMSlackNotifierQMSlackNotifierLambdaServiceRoleDefaultPolicy4C4D219B",
    #     "Roles": [
    #       {
    #         "Ref": "QMSlackNotifierQMSlackNotifierLambdaServiceRole6342FD1D"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SlackNotifier/QM-SlackNotifier-Lambda/ServiceRole/DefaultPolicy/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   },
    #   "Condition": "SlackTrueCondition"
    # },


    #     "QMHelperQMHelperFunctionServiceRole0506622D": {
    #   "Type": "AWS::IAM::Role",
    #   "Properties": {
    #     "AssumeRolePolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sts:AssumeRole",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "lambda.amazonaws.com"
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "ManagedPolicyArns": [
    #       {
    #         "Fn::Join": [
    #           "",
    #           [
    #             "arn:",
    #             {
    #               "Ref": "AWS::Partition"
    #             },
    #             ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    #           ]
    #         ]
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Function/ServiceRole/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },


    #     "QMHelperQMHelperProviderframeworkonEventServiceRole4A1EBBAB": {
    #   "Type": "AWS::IAM::Role",
    #   "Properties": {
    #     "AssumeRolePolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sts:AssumeRole",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "lambda.amazonaws.com"
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "ManagedPolicyArns": [
    #       {
    #         "Fn::Join": [
    #           "",
    #           [
    #             "arn:",
    #             {
    #               "Ref": "AWS::Partition"
    #             },
    #             ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    #           ]
    #         ]
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Provider/framework-onEvent/ServiceRole/Resource",
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
    #     }
    #   }
    # },
    # "QMHelperQMHelperProviderframeworkonEventServiceRoleDefaultPolicy86C1FCC1": {
    #   "Type": "AWS::IAM::Policy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "lambda:InvokeFunction",
    #           "Effect": "Allow",
    #           "Resource": [
    #             {
    #               "Fn::GetAtt": [
    #                 "QMHelperQMHelperFunction91954E97",
    #                 "Arn"
    #               ]
    #             },
    #             {
    #               "Fn::Join": [
    #                 "",
    #                 [
    #                   {
    #                     "Fn::GetAtt": [
    #                       "QMHelperQMHelperFunction91954E97",
    #                       "Arn"
    #                     ]
    #                   },
    #                   ":*"
    #                 ]
    #               ]
    #             }
    #           ]
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "PolicyName": "QMHelperQMHelperProviderframeworkonEventServiceRoleDefaultPolicy86C1FCC1",
    #     "Roles": [
    #       {
    #         "Ref": "QMHelperQMHelperProviderframeworkonEventServiceRole4A1EBBAB"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Helper/QM-Helper-Provider/framework-onEvent/ServiceRole/DefaultPolicy/Resource",
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
    #     }
    #   }
    # },



    #     "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleA2F00B10": {
    #   "Type": "AWS::IAM::Role",
    #   "Properties": {
    #     "AssumeRolePolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sts:AssumeRole",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "lambda.amazonaws.com"
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "ManagedPolicyArns": [
    #       {
    #         "Fn::Join": [
    #           "",
    #           [
    #             "arn:",
    #             {
    #               "Ref": "AWS::Partition"
    #             },
    #             ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    #           ]
    #         ]
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SNSPublisherFunction/QM-SNSPublisherFunction-Lambda/ServiceRole/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },
    # "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleDefaultPolicy1E6E152C": {
    #   "Type": "AWS::IAM::Policy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:SendMessage",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaDeadLetterQueue72FF519A",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": [
    #             "kms:Encrypt",
    #             "kms:Decrypt",
    #             "kms:CreateGrant"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "KMSHubQMEncryptionKeyA80F8C05",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "kms:ListAliases",
    #           "Effect": "Allow",
    #           "Resource": "*"
    #         },
    #         {
    #           "Action": "SNS:Publish",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Ref": "QMSNSPublisherQMSNSPublisherSNSTopic7EE2EBF4"
    #           }
    #         },
    #         {
    #           "Action": "kms:GenerateDataKey",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "KMSHubQMEncryptionKeyA80F8C05",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "ssm:GetParameter",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::Join": [
    #               "",
    #               [
    #                 "arn:",
    #                 {
    #                   "Ref": "AWS::Partition"
    #                 },
    #                 ":ssm:",
    #                 {
    #                   "Ref": "AWS::Region"
    #                 },
    #                 ":",
    #                 {
    #                   "Ref": "AWS::AccountId"
    #                 },
    #                 ":parameter",
    #                 {
    #                   "Ref": "QMNotificationMutingConfig3B7948BA"
    #                 }
    #               ]
    #             ]
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "PolicyName": "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleDefaultPolicy1E6E152C",
    #     "Roles": [
    #       {
    #         "Ref": "QMSNSPublisherFunctionQMSNSPublisherFunctionLambdaServiceRoleA2F00B10"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-SNSPublisherFunction/QM-SNSPublisherFunction-Lambda/ServiceRole/DefaultPolicy/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },


        # "QMReporterQMReporterLambdaServiceRoleBA4CED84": {
    #   "Type": "AWS::IAM::Role",
    #   "Properties": {
    #     "AssumeRolePolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sts:AssumeRole",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "lambda.amazonaws.com"
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "ManagedPolicyArns": [
    #       {
    #         "Fn::Join": [
    #           "",
    #           [
    #             "arn:",
    #             {
    #               "Ref": "AWS::Partition"
    #             },
    #             ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    #           ]
    #         ]
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-Lambda/ServiceRole/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },
    # "QMReporterQMReporterLambdaServiceRoleDefaultPolicyC6B87A76": {
    #   "Type": "AWS::IAM::Policy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:SendMessage",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMReporterQMReporterLambdaDeadLetterQueueA0C464BC",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": [
    #             "kms:Encrypt",
    #             "kms:Decrypt",
    #             "kms:CreateGrant"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "KMSHubQMEncryptionKeyA80F8C05",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "kms:ListAliases",
    #           "Effect": "Allow",
    #           "Resource": "*"
    #         },
    #         {
    #           "Action": [
    #             "sqs:DeleteMessage",
    #             "sqs:ReceiveMessage"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMSummarizerEventQueueQMSummarizerEventQueueQueue95FCCD2A",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": [
    #             "dynamodb:GetItem",
    #             "dynamodb:PutItem"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMTable336670B0",
    #               "Arn"
    #             ]
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "PolicyName": "QMReporterQMReporterLambdaServiceRoleDefaultPolicyC6B87A76",
    #     "Roles": [
    #       {
    #         "Ref": "QMReporterQMReporterLambdaServiceRoleBA4CED84"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Reporter/QM-Reporter-Lambda/ServiceRole/DefaultPolicy/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },

    #     "QMDeploymentManagerQMDeploymentManagerLambdaServiceRole84304F72": {
    #   "Type": "AWS::IAM::Role",
    #   "Properties": {
    #     "AssumeRolePolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sts:AssumeRole",
    #           "Effect": "Allow",
    #           "Principal": {
    #             "Service": "lambda.amazonaws.com"
    #           }
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "ManagedPolicyArns": [
    #       {
    #         "Fn::Join": [
    #           "",
    #           [
    #             "arn:",
    #             {
    #               "Ref": "AWS::Partition"
    #             },
    #             ":iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    #           ]
    #         ]
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-Lambda/ServiceRole/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },
    # "QMDeploymentManagerQMDeploymentManagerLambdaServiceRoleDefaultPolicy7E3D0777": {
    #   "Type": "AWS::IAM::Policy",
    #   "Properties": {
    #     "PolicyDocument": {
    #       "Statement": [
    #         {
    #           "Action": "sqs:SendMessage",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMDeploymentManagerQMDeploymentManagerLambdaDeadLetterQueue9B4636C2",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": [
    #             "kms:Encrypt",
    #             "kms:Decrypt",
    #             "kms:CreateGrant"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "KMSHubQMEncryptionKeyA80F8C05",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "kms:ListAliases",
    #           "Effect": "Allow",
    #           "Resource": "*"
    #         },
    #         {
    #           "Action": [
    #             "events:PutPermission",
    #             "events:RemovePermission"
    #           ],
    #           "Effect": "Allow",
    #           "Resource": "*"
    #         },
    #         {
    #           "Action": "events:DescribeEventBus",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::GetAtt": [
    #               "QMBusFF5C6C0C",
    #               "Arn"
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "ssm:GetParameter",
    #           "Effect": "Allow",
    #           "Resource": {
    #             "Fn::Join": [
    #               "",
    #               [
    #                 "arn:",
    #                 {
    #                   "Ref": "AWS::Partition"
    #                 },
    #                 ":ssm:",
    #                 {
    #                   "Ref": "AWS::Region"
    #                 },
    #                 ":",
    #                 {
    #                   "Ref": "AWS::AccountId"
    #                 },
    #                 ":parameter",
    #                 {
    #                   "Ref": "QMAccounts3D743F6B"
    #                 }
    #               ]
    #             ]
    #           }
    #         },
    #         {
    #           "Action": "support:DescribeTrustedAdvisorChecks",
    #           "Effect": "Allow",
    #           "Resource": "*"
    #         }
    #       ],
    #       "Version": "2012-10-17"
    #     },
    #     "PolicyName": "QMDeploymentManagerQMDeploymentManagerLambdaServiceRoleDefaultPolicy7E3D0777",
    #     "Roles": [
    #       {
    #         "Ref": "QMDeploymentManagerQMDeploymentManagerLambdaServiceRole84304F72"
    #       }
    #     ]
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-Deployment-Manager/QM-Deployment-Manager-Lambda/ServiceRole/DefaultPolicy/Resource",
    #     "cdk_nag": {
    #       "rules_to_suppress": [
    #         {
    #           "reason": "AWSLambdaBasicExecutionRole added by cdk only gives write permissions for CW logs",
    #           "id": "AwsSolutions-IAM4"
    #         },
    #         {
    #           "reason": "Actions restricted on kms key ARN. Only actions that do not support resource-level permissions have * in resource",
    #           "id": "AwsSolutions-IAM5"
    #         },
    #         {
    #           "reason": "GovCloud regions support only up to nodejs 16, risk is tolerable",
    #           "id": "AwsSolutions-L1"
    #         }
    #       ]
    #     }
    #   }
    # },
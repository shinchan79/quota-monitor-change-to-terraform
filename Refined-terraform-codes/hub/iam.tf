module "iam" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  # IAM roles 
  create_role = true
  iam_roles = {
    lambda_helper = {
      name = "${var.master_prefix}-HelperFunctionRole"
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
      name = "${var.master_prefix}-HelperProviderFrameworkOnEventRole"
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
        lambda_invoke = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = "lambda:InvokeFunction"
              Resource = [
                "arn:${data.aws_partition.current.partition}:lambda:${data.aws_region.current.name}:function:*"
              ]
            },
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

    slack_notifier = {
      name = "${var.master_prefix}-SlackNotifier-Lambda-Role"
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
              Resource = module.sqs.sqs_queue_arns["slack_notifier_dlq"]
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
              Action = "ssm:GetParameter"
              Resource = [
                "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["slack_webhook"]}",
                "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["notification_muting"]}"
              ]
            }
          ]
        })
      }

      tags = local.merged_tags
    }

    sns_publisher = {
      name = "${var.master_prefix}-SNSPublisher-Lambda-Role"
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
              Resource = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["notification_muting"]}"
            }
          ]
        })
      }

      tags = local.merged_tags
    }

    reporter = {
      name = "${var.master_prefix}-Reporter-Lambda-Role"
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
      name = "${var.master_prefix}-DeploymentManager-Lambda-Role"
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
              Effect   = "Allow"
              Action   = "events:DescribeEventBus"
              Resource = module.event_bus.eventbridge_bus_arns["quota_monitor"]
            },
            {
              Effect = "Allow"
              Action = "ssm:GetParameter"
              Resource = compact([
                "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["organizational_units"]}",
                var.enable_account_deploy ? "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["target_accounts"]}" : null,
                "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["regions_list"]}"
              ])
            },
            {
              Effect = "Allow"
              Action = [
                "organizations:DescribeOrganization",
                "organizations:ListRoots",
                "organizations:ListAccounts",
                "organizations:ListDelegatedAdministrators",
                "organizations:ListAccountsForParent"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = "cloudformation:DescribeStackSet"
              Resource = [for stack in ["${var.master_prefix}-TA-Spoke-StackSet", "${var.master_prefix}-SQ-Spoke-StackSet", "${var.master_prefix}-SNS-Spoke-StackSet"] :
                "arn:${data.aws_partition.current.partition}:cloudformation:*:${var.management_account_id}:stackset/${stack}:*"
              ]
            },
            {
              Effect = "Allow"
              Action = [
                "cloudformation:CreateStackInstances",
                "cloudformation:DeleteStackInstances",
                "cloudformation:ListStackInstances"
              ]
              Resource = flatten([
                [for stack in ["${var.master_prefix}-TA-Spoke-StackSet", "${var.master_prefix}-SQ-Spoke-StackSet", "${var.master_prefix}-SNS-Spoke-StackSet"] :
                  "arn:${data.aws_partition.current.partition}:cloudformation:*:${var.management_account_id}:stackset/${stack}:*"
                ],
                [for stack in ["${var.master_prefix}-TA-Spoke-StackSet", "${var.master_prefix}-SQ-Spoke-StackSet", "${var.master_prefix}-SNS-Spoke-StackSet"] :
                  "arn:${data.aws_partition.current.partition}:cloudformation:*:${var.management_account_id}:stackset-target/${stack}:*/*"
                ],
                ["arn:${data.aws_partition.current.partition}:cloudformation:*::type/resource/*"]
              ])
            },
            {
              Effect   = "Allow"
              Action   = "ec2:DescribeRegions"
              Resource = "*"
            },
            {
              Effect   = "Allow"
              Action   = "support:DescribeTrustedAdvisorChecks"
              Resource = "*"
            }
          ]
        })
      }

      tags = local.merged_tags
    }
  }
}

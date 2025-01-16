module "iam" {
  source = "../modules"

  create        = local.create_hub_resources
  master_prefix = var.master_prefix

  # IAM roles 
  create_role = true
  iam_roles = {
    lambda_helper = {
      name = var.iam_role_names["lambda_helper"]
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
      name = var.iam_role_names["provider_framework"]
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

    sns_publisher = {
      name = var.iam_role_names["sns_publisher"]
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
      name = var.iam_role_names["reporter"]
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
  }
}
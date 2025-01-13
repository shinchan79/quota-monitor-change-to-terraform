module "iam" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix
  create_role   = true

  iam_roles = {
    ################# SNS Spoke
    sns_publisher_lambda = {
      name = "${var.master_prefix}-SNSPublisherFunctionLambdaServiceRole"
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
        lambda_permissions = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage"
              ]
              Resource = module.sqs.sqs_queue_arns["sns_publisher_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "SNS:Publish"
              ]
              Resource = module.sns.sns_topic_arns["sns_publisher"]
            },
            {
              Effect = "Allow"
              Action = [
                "kms:GenerateDataKey"
              ]
              Resource = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sns"
            },
            {
              Effect = "Allow"
              Action = [
                "ssm:GetParameter"
              ]
              Resource = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${module.ssm_parameter.ssm_parameter_names["notification_muting"]}"
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
      tags = var.tags
    }

    ################# QM Spoke
    list_manager = {
      name = "${var.master_prefix}-ListManagerFunctionRole"
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
        list_manager_permissions = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:BatchWriteItem", 
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan"
              ]
              Resource = module.dynamodb.dynamodb_table_arns["service"]
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:DeleteItem", 
                "dynamodb:Query",
                "dynamodb:Scan"
              ]
              Resource = module.dynamodb.dynamodb_table_arns["quota"]
            },
            {
              Effect = "Allow"
              Action = [
                "cloudwatch:GetMetricData",
                "servicequotas:ListServiceQuotas",
                "servicequotas:ListServices",
                "dynamodb:DescribeLimits",
                "autoscaling:DescribeAccountLimits",
                "route53:GetAccountLimit",
                "rds:DescribeAccountAttributes"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:ListStreams"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator"
              ]
              Resource = "${module.dynamodb.dynamodb_table_arns["service"]}/stream/*"
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
      
      tags = var.tags
    }

    list_manager_provider = {
      name = "${var.master_prefix}-ListManagerProviderframeworkonEventRole"
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
              Action = [
                "lambda:InvokeFunction"
              ]
              Resource = local.lambda_function_arns
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

      tags = var.tags
    }

    qmcw_poller_lambda = {
      name = "${var.master_prefix}-CWPollerLambdaServiceRole"
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
        default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage"
              ]
              Resource = module.sqs.sqs_queue_arns["qmcw_poller_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:Query"
              ]
              Resource = module.dynamodb.dynamodb_table_arns["quota"]
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:Scan"
              ]
              Resource = module.dynamodb.dynamodb_table_arns["service"]
            },
            {
              Effect = "Allow"
              Action = [
                "cloudwatch:GetMetricData"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            },
            {
              Effect = "Allow"
              Action = [
                "servicequotas:ListServices"
              ]
              Resource = "*"
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

      tags = var.tags
    }

    utilization_ok_events = {
      name = "${var.master_prefix}-UtilizationOKEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })

      policies = {
        default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }

      tags = var.tags
    }

    utilization_warn_events = {
      name = "${var.master_prefix}-UtilizationWarnEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })

      policies = {
        default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }

      tags = var.tags
    }

    utilization_error_events = {
      name = "${var.master_prefix}-UtilizationErrEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })

      policies = {
        default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }

      tags = var.tags
    }

    spoke_sns_events = {
      name = "${var.master_prefix}-SpokeSnsRuleEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })

      policies = {
        default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = "arn:${data.aws_partition.current.partition}:events:${var.spoke_sns_region}:${data.aws_caller_identity.current.account_id}:event-bus/${var.master_prefix}SnsSpokeBus"
            }
          ]
        })
      }

      tags = var.tags
    }

    ################# TA Spoke
    ta_ok_rule_events_role = {
      name = "${var.master_prefix}-TAOkRuleEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })
      policies = {
        ta_ok_rule_events_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }
      tags = var.tags
    }

    ta_warn_rule_events_role = {
      name = "${var.master_prefix}-TAWarnRuleEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })
      policies = {
        ta_warn_rule_events_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }
      tags = var.tags
    }

    ta_error_rule_events_role = {
      name = "${var.master_prefix}-TAErrorRuleEventsRole"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
              Service = "events.amazonaws.com"
            }
          }
        ]
      })
      policies = {
        ta_error_rule_events_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "events:PutEvents"
              ]
              Resource = var.event_bus_arn
            }
          ]
        })
      }
      tags = var.tags
    }

    qm_ta_refresher_lambda_service_role = {
      name = "${var.master_prefix}-TARefresherLambdaServiceRole"
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
        qm_ta_refresher_lambda_service_role_default_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "sqs:SendMessage"
              ]
              Resource = module.sqs.sqs_queue_arns["qmta_refresher_dlq"]
            },
            {
              Effect = "Allow"
              Action = [
                "support:RefreshTrustedAdvisorCheck"
              ]
              Resource = "*"
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
      tags = var.tags
    }
  }
}

# Local values to prevent circular dependencies
locals {
  lambda_function_arns = [
    "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
  ]
}

variable "master_prefix" {
  description = "Prefix to be used for all resources"
  type        = string
  default     = "qm"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "event_bus_arn" {
  description = "ARN of the event bus"
  type        = string
}

variable "spoke_sns_region" {
  description = "Region for SNS spoke"
  type        = string
}
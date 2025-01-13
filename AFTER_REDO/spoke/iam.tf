module "iam" {
  source = "../modules"

  create        = true
  master_prefix = "qm"
  create_role   = true

  iam_roles = {
    ################# SNS Spoke
    sns_publisher_lambda = {
      name = "SNSPublisherFunctionLambdaServiceRole"
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
      tags = {
        Name = "QuotaMonitor-SNSPublisherLambda-Role"
      }
    }

    ################# QM Spoke
    list_manager = {
      name = "QMListManagerFunctionRole"
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
      
      tags = {
        Name = "QM-ListManagerRole"
      }
    }

    list_manager_provider = {
      name = "QMListManagerProviderframeworkonEventRole"
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

      tags = {
        Name = "QM-ListManagerProviderFrameworkRole"
      }
    }

    qmcw_poller_lambda = {
      name = "QMCWPollerLambdaServiceRole"
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

      tags = {
        Name = "QuotaMonitor-QMCWPoller-Role"
      }
    }

    utilization_ok_events = {
      name = "QMUtilizationOKEventsRole"
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

      tags = {
        Name = "QuotaMonitor-UtilizationOK-Events-Role"
      }
    }

    utilization_warn_events = {
      name = "QMUtilizationWarnEventsRole"
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

      tags = {
        Name = "QuotaMonitor-UtilizationWarn-Events-Role"
      }
    }

    utilization_error_events = {
      name = "QMUtilizationErrEventsRole"
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

      tags = {
        Name = "QuotaMonitor-UtilizationErr-Events-Role"
      }
    }

    spoke_sns_events = {
      name = "SpokeSnsRuleEventsRole"
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
              Resource = "arn:${data.aws_partition.current.partition}:events:${var.spoke_sns_region}:${data.aws_caller_identity.current.account_id}:event-bus/QuotaMonitorSnsSpokeBus"
            }
          ]
        })
      }

      tags = {
        Name = "QuotaMonitor-SpokeSns-Events-Role"
      }
    }

    ################# TA Spoke
    ta_ok_rule_events_role = {
      name = "TAOkRuleEventsRole"
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
      tags = {
        Name = "QuotaMonitor-TAOkRuleEventsRole"
      }
    }

    ta_warn_rule_events_role = {
      name = "TAWarnRuleEventsRole"
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
      tags = {
        Name = "QuotaMonitor-TAWarnRuleEventsRole"
      }
    }

    ta_error_rule_events_role = {
      name = "TAErrorRuleEventsRole"
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
      tags = {
        Name = "QuotaMonitor-TAErrorRuleEventsRole"
      }
    }

    qm_ta_refresher_lambda_service_role = {
      name = "QMTARefresherLambdaServiceRole"
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
      tags = {
        Name = "QuotaMonitor-QMTARefresherLambdaServiceRole"
      }
    }
  }
}

# Local values to prevent circular dependencies
locals {
  lambda_function_arns = [
    "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"
  ]
}
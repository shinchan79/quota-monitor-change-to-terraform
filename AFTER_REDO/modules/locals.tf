locals {
  iam_policies = chunklist(flatten([
    for k, v in var.iam_roles : concat(
      setproduct([k], keys(var.iam_roles[k].policies)),
    ) if var.create_role && var.create && v.policies != null
  ]), 2)

  iam_additional_policies = chunklist(flatten([
    for k, v in var.iam_roles : concat(
      setproduct([k], var.iam_roles[k].additional_policies),
    ) if var.create_role && var.create && v.additional_policies != null
  ]), 2)

  # aws_service_policies = {
  #   sqs_source = {
  #     actions = [
  #       "sqs:ReceiveMessage",
  #       "sqs:DeleteMessage",
  #       "sqs:GetQueueAttributes"
  #     ]
  #   },
  #   sqs_target = {
  #     actions = [
  #       "sqs:SendMessage"
  #     ]
  #   },
  #   sqs_dlq = {
  #     actions = [
  #       "sqs:SendMessage"
  #     ]
  #   },
  #   dynamodb = {
  #     actions = [
  #       "dynamodb:DescribeStream",
  #       "dynamodb:GetRecords",
  #       "dynamodb:GetShardIterator",
  #       "dynamodb:ListStreams"
  #     ]
  #   },
  #   kinesis_source = {
  #     actions = [
  #       "kinesis:DescribeStream",
  #       "kinesis:DescribeStreamSummary",
  #       "kinesis:GetRecords",
  #       "kinesis:GetShardIterator",
  #       "kinesis:ListShards",
  #       "kinesis:ListStreams",
  #       "kinesis:SubscribeToShard"
  #     ]
  #   },
  #   kinesis_target = {
  #     actions = [
  #       "kinesis:PutRecord",
  #       "kinesis:PutRecords"
  #     ]
  #   },
  #   mq = {
  #     actions = [
  #       "mq:DescribeBroker",
  #       "secretsmanager:GetSecretValue",
  #       "ec2:CreateNetworkInterface",
  #       "ec2:DeleteNetworkInterface",
  #       "ec2:DescribeNetworkInterfaces",
  #       "ec2:DescribeSecurityGroups",
  #       "ec2:DescribeSubnets",
  #       "ec2:DescribeVpcs",
  #       "logs:CreateLogGroup",
  #       "logs:CreateLogStream",
  #       "logs:PutLogEvents"
  #     ]
  #   },
  #   msk = {
  #     actions = [
  #       "kafka:DescribeClusterV2",
  #       "kafka:GetBootstrapBrokers",
  #       "ec2:CreateNetworkInterface",
  #       "ec2:DeleteNetworkInterface",
  #       "ec2:DescribeNetworkInterfaces",
  #       "ec2:DescribeSecurityGroups",
  #       "ec2:DescribeSubnets",
  #       "ec2:DescribeVpcs",
  #       "logs:CreateLogGroup",
  #       "logs:CreateLogStream",
  #       "logs:PutLogEvents"
  #     ]
  #   },
  #   lambda = {
  #     actions = [
  #       "lambda:InvokeFunction"
  #     ]
  #   },
  #   step_functions = {
  #     actions = [
  #       "states:StartExecution"
  #     ]
  #   },
  #   api_gateway = {
  #     actions = [
  #       "execute-api:Invoke"
  #     ]
  #   },
  #   api_destination = {
  #     actions = [
  #       "events:InvokeApiDestination"
  #     ]
  #   },
  #   batch = {
  #     actions = [
  #       "batch:SubmitJob"
  #     ]
  #   },
  #   logs = {
  #     actions = [
  #       "logs:DescribeLogGroups",
  #       "logs:DescribeLogStreams",
  #       "logs:CreateLogStream",
  #       "logs:PutLogEvents"
  #     ]
  #   },
  #   ecs = {
  #     actions = [
  #       "ecs:RunTask"
  #     ]
  #   },
  #   ecs_iam_passrole = {
  #     actions = [
  #       "iam:PassRole"
  #     ]
  #   },
  #   eventbridge = {
  #     actions = [
  #       "events:PutEvents"
  #     ]
  #   },
  #   firehose = {
  #     actions = [
  #       "firehose:PutRecord"
  #     ]
  #   },
  #   inspector = {
  #     actions = [
  #       "inspector:CreateAssessmentTemplate"
  #     ]
  #   },
  #   redshift = {
  #     actions = [
  #       "redshift-data:ExecuteStatement"
  #     ]
  #   },
  #   sagemaker = {
  #     actions = [
  #       "sagemaker:CreatePipeline"
  #     ]
  #   },
  #   sns = {
  #     actions = [
  #       "sns:Publish"
  #     ]
  #   }
  # }
  lambda_layer = {
    for k, v in var.lambda_layers : k => {
      name                = try(v.name, "${var.master_prefix}-${k}-layer")
      description         = try(v.description, null)
      compatible_runtimes = try(v.compatible_runtimes, null)
      filename            = try(v.filename, null)
      s3_bucket           = try(v.filename.s3_bucket, null)
      s3_key              = try(v.filename.s3_key, null)
    } if var.create && var.create_lambda_layer
  }

  # Normalize lambda configurations
  lambda_functions_normalized = {
    for k, v in var.lambda_functions : k => {
      name                  = coalesce(v.name, k)
      function_name         = substr(format("%s-%s", var.master_prefix, coalesce(v.name, k)), 0, 63)
      source_dir           = try(v.source_dir, null)
      source_file          = try(v.source_file, null)
      s3_bucket            = try(v.s3_bucket, null)
      s3_key               = try(v.s3_key, null)
      handler              = v.handler
      runtime              = v.runtime
      role_arn             = try(v.role_arn, null)
      role_key             = try(v.role_key, null)
      timeout              = v.timeout
      memory_size          = v.memory_size
      architectures        = try(v.architectures, ["x86_64"])
      environment_variables = try(v.environment_variables, {})
      security_group_ids   = try(v.security_group_ids, null)
      subnet_ids           = try(v.subnet_ids, null)
      kms_key_arn          = try(v.kms_key_arn, null)
      logging_config       = try(v.logging_config, null)
      tags                 = try(v.tags, {})
      layers               = try(v.layers, null)
      event_invoke_config  = try(v.event_invoke_config, null)
    }
  }
}
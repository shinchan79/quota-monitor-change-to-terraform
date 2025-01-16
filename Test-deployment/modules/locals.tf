locals {
  # IAM policies logic
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

  # Lambda layer logic
  lambda_layer = {
    for k, v in var.lambda_layers : k => {
      name                = try(v.name, "${var.master_prefix}-${k}-layer")
      description         = try(v.description, null)
      compatible_runtimes = try(v.compatible_runtimes, null)
      # Source code logic cho layer
      filename  = var.create_s3 ? "${path.module}/${var.s3_objects["utils_layer"].source}" : try(v.filename, null)
      s3_bucket = var.create_s3 ? try(aws_s3_bucket.this["source_code"].id, null) : try(v.s3_bucket, null)
      s3_key    = var.create_s3 ? try(aws_s3_object.this["utils_layer"].key, null) : try(v.s3_key, null)
    } if var.create && var.create_lambda_layer
  }

  # Lambda functions logic
  lambda_functions_normalized = {
    for k, v in var.lambda_functions : k => {
      name                  = coalesce(v.name, k)
      function_name         = substr(format("%s-%s", var.master_prefix, coalesce(v.name, k)), 0, 63)
      handler               = v.handler
      runtime               = v.runtime
      role_arn              = try(v.role_arn, null)
      role_key              = try(v.role_key, null)
      timeout               = v.timeout
      memory_size           = v.memory_size
      architectures         = try(v.architectures, ["x86_64"])
      environment_variables = try(v.environment_variables, {})
      security_group_ids    = try(v.security_group_ids, null)
      subnet_ids            = try(v.subnet_ids, null)
      kms_key_arn           = try(v.kms_key_arn, null)
      logging_config        = try(v.logging_config, null)
      tags                  = try(v.tags, {})
      layers                = try(v.layers, null)
      event_invoke_config   = try(v.event_invoke_config, null)

      # Source code logic cho function
      filename  = var.create_s3 ? "${path.module}/${try(var.s3_objects[k].source, null)}" : try(v.filename, null)
      s3_bucket = var.create_s3 ? try(aws_s3_bucket.this["source_code"].id, null) : try(v.s3_bucket, null)
      s3_key    = var.create_s3 ? try(aws_s3_object.this[k].key, null) : try(v.s3_key, null)
    }
  }

  # Source files logic
  lambda_source_files = {
    for k, v in var.lambda_functions : k => v
    if var.create_lambda && var.create &&
    try(v.source_dir != null, false) &&
    try(v.s3_bucket == null, true)
  }
}
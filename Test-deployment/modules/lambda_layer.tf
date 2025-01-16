resource "aws_lambda_layer_version" "this" {
  for_each = var.create && var.lambda_layers != null ? var.lambda_layers : {}

  layer_name          = format("%s-%s", var.master_prefix, coalesce(each.value.name, each.key))
  description         = try(each.value.description, null)
  compatible_runtimes = each.value.compatible_runtimes
  filename            = try(each.value.filename, null)
  s3_bucket           = try(each.value.s3_bucket, null)
  s3_key              = try(each.value.s3_key, null)
}
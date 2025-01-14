resource "aws_lambda_permission" "this" {
  for_each = var.create_lambda_permission && var.create ? var.lambda_permissions : {}

  statement_id   = coalesce(each.value.statement_id, each.key)
  action         = coalesce(each.value.action, "lambda:InvokeFunction")
  function_name  = try(aws_lambda_function.lambda[each.value.function_key].function_name, each.value.function_name)
  principal      = each.value.principal
  source_arn     = each.value.source_arn
  source_account = each.value.source_account
  qualifier      = each.value.qualifier
}
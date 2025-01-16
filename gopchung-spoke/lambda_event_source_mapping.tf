module "event_source_mapping" {
  source = "../modules"

  create        = true
  master_prefix = "qm"

  create_lambda_event_source_mapping = true
  lambda_event_source_mappings = {
    ################# QM Spoke
    service_table_stream = {
      function_name     = module.lambda.lambda_function_names["list_manager"]
      event_source_arn  = module.dynamodb.dynamodb_table_streams["service"]
      batch_size        = 1
      starting_position = "LATEST"
    }
  }

  depends_on = [
    module.lambda,
    module.dynamodb
  ]
}
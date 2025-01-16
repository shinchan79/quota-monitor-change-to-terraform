# ################## QM Spoke
#     # "QMListManagerSQServiceList2C145D4D": {
#     #   "Type": "Custom::SQServiceList",
resource "aws_lambda_invocation" "qm_list_manager_service_list" {
  function_name = module.lambda.lambda_function_arns["list_manager_provider"]

  input = jsonencode({
    RequestType = "Create"
    ResourceProperties = {
      VERSION             = "v6.3.0"
      SageMakerMonitoring = var.sagemaker_monitoring
      ConnectMonitoring   = var.connect_monitoring
    }
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.event_rule, # Phụ thuộc vào toàn bộ module event_rule
    module.dynamodb    # Phụ thuộc vào toàn bộ module dynamodb
  ]

  triggers = {
    redeployment = sha1(jsonencode({
      version              = "v6.3.0"
      sagemaker_monitoring = var.sagemaker_monitoring
      connect_monitoring   = var.connect_monitoring
    }))
  }
}
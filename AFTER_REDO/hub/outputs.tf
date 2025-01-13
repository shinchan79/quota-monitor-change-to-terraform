output "custom_resource_outputs" {
  value = {
    helper_uuid = random_uuid.helper_uuid.result
  }
}
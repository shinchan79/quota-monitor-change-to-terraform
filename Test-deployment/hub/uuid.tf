resource "random_uuid" "helper_uuid" {}

resource "null_resource" "launch_data" {
  triggers = {
    uuid = random_uuid.helper_uuid.result
  }
}
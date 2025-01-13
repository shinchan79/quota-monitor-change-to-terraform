# terraform.tfvars

# Required variables
event_bus_arn = "arn:aws:events:ap-southeast-1:830427153490:event-bus/qm-QuotaMonitorBus"

vpc_config = {
  security_group_ids = ["sg-04ff57abf41aa053b"]
  subnet_ids = ["subnet-e707d7af"]
}
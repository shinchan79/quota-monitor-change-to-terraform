# module "sns" {
#   source = "../modules"

#   create        = true
#   master_prefix = "qm"

#   create_sns = true
#   sns_topics = {
#     ################# SNS Spoke
#     sns_publisher = {
#       name              = "SNSPublisher-SNSTopic"
#       kms_master_key_id = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sns"
#       tags = {
#         Name = "QuotaMonitor-SNSPublisher-Topic"
#       }
#     }
#   }
# }
module "sns" {
  source = "../modules"

  create        = true
  master_prefix = var.master_prefix

  create_sns = true
  sns_topics = {
    ################# SNS Spoke
    sns_publisher = {
      name              = "${var.master_prefix}-SNSPublisher-SNSTopic"
      kms_master_key_id = "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sns"
      tags             = var.tags
    }
  }
}

variable "master_prefix" {
  description = "Prefix to be used for all resources"
  type        = string
  default     = "qm"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
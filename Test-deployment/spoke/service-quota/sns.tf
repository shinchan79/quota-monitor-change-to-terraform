module "sns" {
  source = "../../modules"

  create        = true
  master_prefix = var.master_prefix

  create_sns = var.create_sns
  sns_topics = var.create_sns ? {
    sns_publisher = {
      name = "${var.master_prefix}-${var.sns_topics_config["sns_publisher"].name}"

      # KMS configuration from CloudFormation template
      kms_master_key_id = coalesce(
        var.sns_topics_config["sns_publisher"].existing_kms_key_id,
        var.kms_key_arn,
        "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/sns"
      )

      tags = merge(
        {
          Name = "${var.master_prefix}-${var.sns_topics_config["sns_publisher"].name}"
        },
        try(var.sns_topics_config["sns_publisher"].tags, {}),
        var.tags
      )
    }
  } : {}
}
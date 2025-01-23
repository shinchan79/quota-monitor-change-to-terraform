module "sns" {
  source = "../modules"

  create        = var.create_sns && local.create_hub_resources
  master_prefix = var.master_prefix
  create_sns    = var.create_sns

  sns_topics = var.create_sns ? {
    publisher = {
      name              = var.sns_config["publisher"].name
      kms_master_key_id = local.kms_arn
      tags = merge(
        {
          Name = var.sns_config["publisher"].name
        },
        local.merged_tags
      )
      subscriptions = {
        for idx, email in var.sns_emails : "email_${idx}" => {
          protocol = var.sns_config["publisher"].protocol
          endpoint = email
        }
      }
    }
  } : {}
}




    # "QMEmailSubscription32E71F90": {
    #   "Type": "AWS::SNS::Subscription",
    #   "Properties": {
    #     "Endpoint": {
    #       "Ref": "SNSEmail"
    #     },
    #     "Protocol": "email",
    #     "TopicArn": {
    #       "Ref": "QMSNSPublisherQMSNSPublisherSNSTopic7EE2EBF4"
    #     }
    #   },
    #   "Metadata": {
    #     "aws:cdk:path": "quota-monitor-hub-no-ou/QM-EmailSubscription/Resource"
    #   },
    #   "Condition": "EmailTrueCondition"
    # },
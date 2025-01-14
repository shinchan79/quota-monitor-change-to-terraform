resource "aws_sns_topic" "topic" {
  for_each = var.create_sns && var.create ? var.sns_topics : {}

  name              = format("%s-%s", var.master_prefix, coalesce(each.value.name, each.key))
  kms_master_key_id = each.value.kms_master_key_id
  tags              = merge(var.additional_tags, each.value.tags)
}

resource "aws_sns_topic_subscription" "this" {
  for_each = merge([
    for topic_key, topic in var.sns_topics : {
      for sub_key, sub in coalesce(topic.subscriptions, {}) :
      "${topic_key}:${sub_key}" => merge(sub, {
        topic_arn = aws_sns_topic.topic[topic_key].arn
      })
    }
    if var.create_sns && var.create
  ]...)

  topic_arn = each.value.topic_arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
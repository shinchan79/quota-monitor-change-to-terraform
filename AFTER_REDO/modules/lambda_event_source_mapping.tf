# lambda_event_source_mapping.tf

# Khai báo variable cho event source mapping
variable "create_lambda_event_source_mapping" {
  description = "Whether to create Lambda event source mapping"
  type        = bool
  default     = false
}

variable "lambda_event_source_mappings" {
  description = "Map of Lambda event source mapping configurations"
  type = map(object({
    function_key = optional(string)
    function_name = optional(string)
    event_source_arn = optional(string)
    batch_size = optional(number, 100)
    starting_position = optional(string)
    starting_position_timestamp = optional(string)
    enabled = optional(bool, true)
    maximum_batching_window_in_seconds = optional(number)
    maximum_record_age_in_seconds = optional(number)
    maximum_retry_attempts = optional(number)
    parallelization_factor = optional(number)
    bisect_batch_on_function_error = optional(bool)
    tumbling_window_in_seconds = optional(number)
    function_response_types = optional(list(string))

    # SQS specific
    scaling_config = optional(object({
      maximum_concurrency = number
    }))

    filter_criteria = optional(object({
      filter = optional(list(object({
        pattern = string  
      })))
    }))

    destination_config = optional(object({
      on_failure = optional(object({
        destination_arn = string
      }))
    }))

    # For streams like Kinesis & DynamoDB 
    metrics_config = optional(object({
      metrics = list(string)
    }))
  }))
  default = {}
}

# Event source mapping resource 
resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.create_lambda_event_source_mapping && var.create ? var.lambda_event_source_mappings : {}

  function_name = try(aws_lambda_function.lambda[each.value.function_key].function_name, each.value.function_name)
  event_source_arn = each.value.event_source_arn

  batch_size = each.value.batch_size
  starting_position = each.value.starting_position
  starting_position_timestamp = each.value.starting_position_timestamp
  enabled = each.value.enabled
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  maximum_record_age_in_seconds = each.value.maximum_record_age_in_seconds
  maximum_retry_attempts = each.value.maximum_retry_attempts
  parallelization_factor = each.value.parallelization_factor
  bisect_batch_on_function_error = each.value.bisect_batch_on_function_error
  tumbling_window_in_seconds = each.value.tumbling_window_in_seconds
  function_response_types = each.value.function_response_types

  dynamic "scaling_config" {
    for_each = each.value.scaling_config != null ? [each.value.scaling_config] : []
    content {
      maximum_concurrency = scaling_config.value.maximum_concurrency
    }
  }

  dynamic "filter_criteria" {
    for_each = each.value.filter_criteria != null ? [each.value.filter_criteria] : []
    content {
      dynamic "filter" {
        for_each = filter_criteria.value.filter != null ? filter_criteria.value.filter : []
        content {
          pattern = filter.value.pattern
        }
      }
    }
  }

  dynamic "destination_config" {
    for_each = each.value.destination_config != null ? [each.value.destination_config] : []
    content {
      dynamic "on_failure" {
        for_each = destination_config.value.on_failure != null ? [destination_config.value.on_failure] : []
        content {
          destination_arn = on_failure.value.destination_arn
        }
      }
    }
  }

  dynamic "metrics_config" {
    for_each = each.value.metrics_config != null ? [each.value.metrics_config] : []
    content {
      metrics = metrics_config.value.metrics
    }
  }
}

# Outputs
output "lambda_event_source_mapping_ids" {
  description = "The event source mapping IDs"
  value = { for k, v in aws_lambda_event_source_mapping.this : k => v.id }
}

output "lambda_event_source_mapping_arns" {
  description = "The event source mapping ARNs"
  value = { for k, v in aws_lambda_event_source_mapping.this : k => v.arn }
}
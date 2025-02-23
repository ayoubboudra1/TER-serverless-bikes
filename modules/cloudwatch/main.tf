# CloudWatch alarms for Step Function failures
resource "aws_cloudwatch_metric_alarm" "step_function_failures" {
  alarm_name          = "StepFunction-ExecutionFailures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ExecutionsFailed"
  namespace           = "AWS/States"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for Step Function execution failures"
  alarm_actions       = var.alarm_actions

  dimensions = {
    StateMachineArn = var.step_function_arn
  }
}

# CloudWatch alarms for Lambda errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = toset(var.lambda_function_names)
  alarm_name          = "${each.key}-Lambda-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm for Lambda ${each.key} errors"
  alarm_actions       = var.alarm_actions

  dimensions = {
    FunctionName = each.key
  }
}

# CloudWatch alarms for S3 bucket size
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  for_each            = toset(var.s3_bucket_names)
  alarm_name          = "${each.key}-Size-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = var.s3_size_threshold
  alarm_description   = "Alarm for ${each.key} bucket size"
  alarm_actions       = var.alarm_actions

  dimensions = {
    BucketName   = each.key
    StorageType  = "StandardStorage"
  }
}
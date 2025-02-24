output "step_function_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.step_function_failures.arn
}

output "lambda_function_names" {
  value        = ["extract_lambda", "preprocess_lambda"] 
}

output "s3_bucket_names" {
  value        = ["my-bronze-data-bucket-ter-serverless", "my-silver-data-bucket-ter-serverless"]
}
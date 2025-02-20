output "bronze_bucket" {
  value = aws_s3_bucket.bronze.bucket
}

output "silver_bucket" {
  value = aws_s3_bucket.silver.bucket
}

# output "snowpipe_queue_arn" {
#   description = "ARN of the SQS queue for Snowpipe notifications"
#   value       = aws_sqs_queue.snowpipe_queue.arn
# }

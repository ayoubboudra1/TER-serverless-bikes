# Bronze Bucket
resource "aws_s3_bucket" "bronze" {
  bucket        = var.bronze_bucket_name
  force_destroy = true # Forces deletion even if the bucket is not empty
}

# Silver Bucket
resource "aws_s3_bucket" "silver" {
  bucket        = var.silver_bucket_name
  force_destroy = true # Forces deletion even if the bucket is not empty
}

# SQS Queue for Snowpipe Notifications
resource "aws_sqs_queue" "snowpipe_queue" {
  name = "${var.silver_bucket_name}-snowpipe-queue"
}

# SQS Queue Policy to Allow S3 Notifications
resource "aws_sqs_queue_policy" "snowpipe_queue_policy" {
  queue_url = aws_sqs_queue.snowpipe_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.snowpipe_queue.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${aws_s3_bucket.silver.bucket}"
          }
        }
      }
    ]
  })
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.silver.bucket

  queue {
    queue_arn     = aws_sqs_queue.snowpipe_queue.arn
    events        = ["s3:ObjectCreated:*"] # Trigger on object creation
    filter_prefix = "FreeBikeStatusData/"  # Only objects with this prefix
  }
}

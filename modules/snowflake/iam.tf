# IAM Role for Snowflake Storage Integration
resource "aws_iam_role" "snowflake_storage" {
  name = "snowflake-storage-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${var.snowflake_aws_account_id}:root"
      },
      Action = "sts:AssumeRole",
      Condition = {
        StringEquals = {
          "sts:ExternalId" = var.snowflake_external_id
        }
      }
    }]
  })
}

# IAM Policy for S3 and SQS access
resource "aws_iam_policy" "snowflake_storage" {
  name = "snowflake-storage-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.silver_bucket_name}",
          "arn:aws:s3:::${var.silver_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = [aws_sqs_queue.ingest.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "snowflake_storage" {
  role       = aws_iam_role.snowflake_storage.name
  policy_arn = aws_iam_policy.snowflake_storage.arn
}

# SQS Queue for auto-ingest
resource "aws_sqs_queue" "ingest" {
  name = "snowflake-ingest-queue"
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.silver_bucket_name}",
      "arn:aws:s3:::${var.silver_bucket_name}/FreeBikeStatusData/*"
    ]
  }
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.silver_bucket_name

  queue {
    queue_arn     = aws_sqs_queue.ingest.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "FreeBikeStatusData/"
  }
}

resource "aws_sqs_queue_policy" "ingest_policy" {
  queue_url = aws_sqs_queue.ingest.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "sqs:SendMessage",
      Resource  = aws_sqs_queue.ingest.arn,
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "arn:aws:s3:::${var.silver_bucket_name}"
        }
      }
    }]
  })
}


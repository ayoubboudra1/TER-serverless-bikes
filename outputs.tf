output "bronze_bucket" {
  description = "Name of the Bronze S3 bucket"
  value       = module.s3.bronze_bucket
}

output "silver_bucket" {
  description = "Name of the Silver S3 bucket"
  value       = module.s3.silver_bucket
}

output "extract_lambda_arn" {
  description = "ARN of the Extract Lambda function"
  value       = module.lambda.extract_lambda_arn
}

output "preprocess_lambda_arn" {
  description = "ARN of the Preprocess Lambda function"
  value       = module.lambda.preprocess_lambda_arn
}

output "snowflake_table" {
  description = "Snowflake table for ingested data"
  value       = module.snowflake.source_data_table
}

output "historical_stage" {
  description = "Snowflake external stage for historical data"
  value       = module.snowflake.historical_stage
}

output "realtime_stage" {
  description = "Snowflake external stage for realtime data"
  value       = module.snowflake.realtime_stage
}

output "snowpipe" {
  description = "Snowflake pipe for realtime ingestion"
  value       = module.snowflake.snowpipe
}

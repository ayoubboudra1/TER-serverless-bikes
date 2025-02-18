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

output "historical_copy_task" {
  description = "Scheduled task for copying historical data"
  value       = module.snowflake.historical_copy_task
}

# Output for BIKE_DIMENSION Task
output "load_bike_dimension_task" {
  description = "Task to load data into BIKE_DIMENSION"
  value       = module.snowflake.load_bike_dimension_task
}

# Output for LOCATION_DIMENSION Task
output "load_location_dimension_task" {
  description = "Task to load data into LOCATION_DIMENSION"
  value       = module.snowflake.load_location_dimension_task
}

# Output for COMPANY_DIMENSION Task
output "load_company_dimension_task" {
  description = "Task to load data into COMPANY_DIMENSION"
  value       = module.snowflake.load_company_dimension_task
}

# Output for PRICING_PLAN_DIMENSION Task
output "load_pricing_plan_dimension_task" {
  description = "Task to load data into PRICING_PLAN_DIMENSION"
  value       = module.snowflake.load_pricing_plan_dimension_task
}

# Output for TIME_DIMENSION Task
output "load_time_dimension_task" {
  description = "Task to load data into TIME_DIMENSION"
  value       = module.snowflake.load_time_dimension_task
}

# Output for BIKE_STATUS_FACT Task
output "load_bike_status_fact_task" {
  description = "Task to load data into BIKE_STATUS_FACT"
  value       = module.snowflake.load_bike_status_fact_task
}

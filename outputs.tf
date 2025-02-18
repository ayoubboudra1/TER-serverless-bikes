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

# output "snowpipe" {
#   description = "Snowflake pipe for realtime ingestion"
#   value       = module.snowflake.snowpipe
# }

# Output for BIKE_DIMENSION Table
output "bike_dimension_table" {
  description = "Snowflake table for BIKE_DIMENSION"
  value       = module.snowflake.bike_dimension_table
}

# Output for LOCATION_DIMENSION Table
output "location_dimension_table" {
  description = "Snowflake table for LOCATION_DIMENSION"
  value       = module.snowflake.location_dimension_table
}

# Output for COMPANY_DIMENSION Table
output "company_dimension_table" {
  description = "Snowflake table for COMPANY_DIMENSION"
  value       = module.snowflake.company_dimension_table
}

# Output for PRICING_PLAN_DIMENSION Table
output "pricing_plan_dimension_table" {
  description = "Snowflake table for PRICING_PLAN_DIMENSION"
  value       = module.snowflake.pricing_plan_dimension_table
}

# Output for TIME_DIMENSION Table
output "time_dimension_table" {
  description = "Snowflake table for TIME_DIMENSION"
  value       = module.snowflake.time_dimension_table
}

# Output for BIKE_STATUS_FACT Table
output "bike_status_fact_table" {
  description = "Snowflake table for BIKE_STATUS_FACT"
  value       = module.snowflake.bike_status_fact_table
}

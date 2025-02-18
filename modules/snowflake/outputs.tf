# Realtime Stage
output "realtime_stage" {
  description = "Snowflake external stage for realtime data"
  value       = snowflake_stage.realtime_stage.name
}

# Historical Stage
output "historical_stage" {
  description = "Snowflake external stage for historical data"
  value       = snowflake_stage.historical_stage.name
}

# # Snowpipe
# output "snowpipe" {
#   description = "Snowflake pipe for realtime ingestion"
#   value       = snowflake_pipe.snowpipe.name
# }

# Output for BIKE_DIMENSION Table
output "bike_dimension_table" {
  description = "Snowflake table for BIKE_DIMENSION"
  value       = snowflake_table.bike_dimension.name
}

# Output for LOCATION_DIMENSION Table
output "location_dimension_table" {
  description = "Snowflake table for LOCATION_DIMENSION"
  value       = snowflake_table.location_dimension.name
}

# Output for COMPANY_DIMENSION Table
output "company_dimension_table" {
  description = "Snowflake table for COMPANY_DIMENSION"
  value       = snowflake_table.company_dimension.name
}

# Output for PRICING_PLAN_DIMENSION Table
output "pricing_plan_dimension_table" {
  description = "Snowflake table for PRICING_PLAN_DIMENSION"
  value       = snowflake_table.pricing_plan_dimension.name
}

# Output for TIME_DIMENSION Table
output "time_dimension_table" {
  description = "Snowflake table for TIME_DIMENSION"
  value       = snowflake_table.time_dimension.name
}

# Output for BIKE_STATUS_FACT Table
output "bike_status_fact_table" {
  description = "Snowflake table for BIKE_STATUS_FACT"
  value       = snowflake_table.bike_status_fact.name
}


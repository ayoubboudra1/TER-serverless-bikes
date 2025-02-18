# Scheduled Task for Historical Data Copy
output "historical_copy_task" {
  description = "Scheduled task for copying historical data"
  value       = snowflake_task.historical_copy.name
}

# Task to Load BIKE_DIMENSION
output "load_bike_dimension_task" {
  description = "Task to load data into BIKE_DIMENSION"
  value       = snowflake_task.load_bike_dimension.name
}

# Task to Load LOCATION_DIMENSION
output "load_location_dimension_task" {
  description = "Task to load data into LOCATION_DIMENSION"
  value       = snowflake_task.load_location_dimension.name
}

# Task to Load COMPANY_DIMENSION
output "load_company_dimension_task" {
  description = "Task to load data into COMPANY_DIMENSION"
  value       = snowflake_task.load_company_dimension.name
}

# Task to Load PRICING_PLAN_DIMENSION
output "load_pricing_plan_dimension_task" {
  description = "Task to load data into PRICING_PLAN_DIMENSION"
  value       = snowflake_task.load_pricing_plan_dimension.name
}

# Task to Load TIME_DIMENSION
output "load_time_dimension_task" {
  description = "Task to load data into TIME_DIMENSION"
  value       = snowflake_task.load_time_dimension.name
}

# Task to Load BIKE_STATUS_FACT
output "load_bike_status_fact_task" {
  description = "Task to load data into BIKE_STATUS_FACT"
  value       = snowflake_task.load_bike_status_fact.name
}

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

# Snowpipe
output "snowpipe" {
  description = "Snowflake pipe for realtime ingestion"
  value       = snowflake_pipe.snowpipe.name
}

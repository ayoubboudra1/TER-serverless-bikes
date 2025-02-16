output "source_data_table" {
  description = "Snowflake table for ingested data"
  value       = snowflake_table.source_data.name
}

output "historical_stage" {
  description = "Snowflake external stage for historical data"
  value       = snowflake_stage.historical_stage.name
}

output "realtime_stage" {
  description = "Snowflake external stage for realtime data"
  value       = snowflake_stage.realtime_stage.name
}

output "snowpipe" {
  description = "Snowflake pipe for realtime ingestion"
  value       = snowflake_pipe.snowpipe.name
}

output "historical_copy_task" {
  description = "Scheduled task for copying historical data"
  value       = snowflake_task.historical_copy.name
}

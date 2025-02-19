

output "snowflake_database" {
  description = "Nom de la base de données Snowflake"
  value       = var.snowflake_database
}

output "snowflake_schema" {
  description = "Nom du schéma Snowflake"
  value       = var.snowflake_schema
}

output "snowflake_table_name" {
  description = "Nom de la table Snowflake"
  value       = snowflake_table.source_data.name
}

# output "snowflake_stage_historical" {
#   description = "Nom du stage Snowflake pour les données historiques"
#   value       = snowflake_stage.historical_stage.name
# }

output "snowflake_stage_realtime" {
  description = "Nom du stage Snowflake pour les données en temps réel"
  value       = snowflake_stage.realtime_stage.name
}

output "snowflake_file_format" {
  description = "Nom du format de fichier JSON dans Snowflake"
  value       = snowflake_file_format.json_format.name
}

output "snowflake_pipe" {
  description = "Nom du pipe Snowflake pour l'ingestion automatique"
  value       = snowflake_pipe.snowpipe.name
}

output "snowflake_task_realtime_copy" {
  description = "Nom de la tâche Snowflake pour la copie des données historiques"
  value       = snowflake_task.realtime_copy.name
}

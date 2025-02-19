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

output "snowflake_database" {
  description = "Nom de la base de données Snowflake"
  value       = module.snowflake.snowflake_database
}

output "snowflake_schema" {
  description = "Nom du schéma Snowflake"
  value       = module.snowflake.snowflake_schema
}

output "snowflake_table_name" {
  description = "Nom de la table Snowflake"
  value       = module.snowflake.snowflake_table_name
}

output "snowflake_stage_historical" {
  description = "Nom du stage Snowflake pour les données historiques"
  value       = module.snowflake.snowflake_stage_historical
}

output "snowflake_stage_realtime" {
  description = "Nom du stage Snowflake pour les données en temps réel"
  value       = module.snowflake.snowflake_stage_realtime
}

output "snowflake_file_format" {
  description = "Nom du format de fichier JSON dans Snowflake"
  value       = module.snowflake.snowflake_file_format
}

output "snowflake_pipe" {
  description = "Nom du pipe Snowflake pour l'ingestion automatique"
  value       = module.snowflake.snowflake_pipe
}

output "snowflake_task_historical_copy" {
  description = "Nom de la tâche Snowflake pour la copie des données historiques"
  value       = module.snowflake.snowflake_task_historical_copy
}

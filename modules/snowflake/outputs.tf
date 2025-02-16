output "snowflake_database" {
  value = snowflake_database.dwh.name
}

output "snowflake_schema" {
  value = snowflake_schema.schema.name
}

output "snowflake_table" {
  value = snowflake_table.bike_table.name
}

output "s3_access_key" {
  value     = aws_iam_access_key.snowflake_user.id
  sensitive = true
}

output "s3_secret_key" {
  value     = aws_iam_access_key.snowflake_user.secret
  sensitive = true
}

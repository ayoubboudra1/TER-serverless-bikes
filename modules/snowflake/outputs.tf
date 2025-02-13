output "snowflake_database_name" {
  value = snowflake_database.my_db.name
}

output "snowflake_schema_name" {
  value = snowflake_schema.my_schema.name
}

output "snowflake_table_name" {
  value = snowflake_table.bike_data_table.name
}

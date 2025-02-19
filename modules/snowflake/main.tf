terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      #   version = "~> 0.87.1"
    }
  }


}


resource "snowflake_file_format" "json_format" {
  name              = "MY_JSON_FORMAT"
  database          = var.snowflake_database
  schema            = var.snowflake_schema
  format_type       = "JSON"
  strip_outer_array = true
}

resource "snowflake_table" "source_data" {
  name     = var.snowflake_table
  database = var.snowflake_database
  schema   = var.snowflake_schema

  column {
    name = "bike_id"
    type = "STRING"
}
column {
    name = "lat"
    type = "FLOAT"
}
column {
    name = "lon"
    type = "FLOAT"
}
column {
    name = "is_disabled"
    type = "BOOLEAN"
}
column {
    name = "is_reserved"
    type = "BOOLEAN"
}
column {
    name = "vehicle_type_id"
    type = "STRING"
}
column {
    name = "last_reported"
    type = "TIMESTAMP_NTZ"
}
column {
    name = "current_range_meters"
    type = "FLOAT"
}
column {
    name = "current_fuel_percent"
    type = "FLOAT"
}
column {
    name = "pricing_plan_id"
    type = "STRING"
}
column {
    name = "type"
    type = "STRING"
}
column {
    name = "time"
    type = "TIMESTAMP_NTZ"
}
column {
    name = "country_code"
    type = "STRING"
}
column {
    name = "company_name"
    type = "STRING"
}
column {
    name = "Location"
    type = "STRING"
}
column {
    name = "System ID"
    type = "STRING"
}
column {
    name = "form_factor"
    type = "STRING"
}
column {
    name = "propulsion_type"
    type = "STRING"
}
column {
    name = "max_range_meters"
    type = "FLOAT"
}
column {
    name = "plan_id"
    type = "STRING"
}
column {
    name = "currency"
    type = "STRING"
}
column {
    name = "price"
    type = "FLOAT"
}
column {
    name = "is_taxable"
    type = "BOOLEAN"
}
column {
    name = "description"
    type = "STRING"
}
column {
    name = "per_min_pricing"
    type = "FLOAT"
}
column {
    name = "pricing_name"
    type = "STRING"
}
}


# resource "snowflake_stage" "historical_stage" {
#   name        = "MY_S3_STAGE"
#   database    = var.snowflake_database
#   schema      = var.snowflake_schema
#   url         = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
#   credentials = "AWS_KEY_ID='${var.aws_key}' AWS_SECRET_KEY='${var.aws_secret}'"
#   file_format = "TYPE = 'JSON'"

# }

resource "snowflake_stage" "realtime_stage" {
  name        = "MY_S3_REALTIME_STAGE"
  database    = var.snowflake_database
  schema      = var.snowflake_schema
  url         = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
  credentials = "AWS_KEY_ID='${var.aws_key}' AWS_SECRET_KEY='${var.aws_secret}'"
  file_format = "TYPE = 'JSON'"
}
# file_format = "(TYPE = 'JSON')"

resource "snowflake_pipe" "snowpipe" {
  name     = "SNOWPIPE_DAILY"
  database = var.snowflake_database
  schema   = var.snowflake_schema

  copy_statement = <<EOF
COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name}
FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.realtime_stage.name}
FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
ON_ERROR = 'CONTINUE'
EOF

  auto_ingest = true
}
resource "snowflake_task" "realtime_copy" {
  name      = "COPY_realtime_DATA"
  database  = var.snowflake_database
  schema    = var.snowflake_schema

  # Schedule: Run the COPY every hour, on the hour (UTC)
   schedule {
    minutes = 1
  }

  sql_statement = <<EOF
COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name}
  FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.realtime_stage.name}
  FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE'
EOF

  # Set to true so the task immediately starts/resumes on creation
  started = true
}


resource "snowflake_database" "dwh" {
  name = var.snowflake_database
}
resource "snowflake_schema" "schema" {
  database = snowflake_database.dwh.name
  name     = var.snowflake_schema
}
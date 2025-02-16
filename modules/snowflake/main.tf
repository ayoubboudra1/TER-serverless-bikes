terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      #   version = "~> 0.87.1"
    }
  }

  # Enable preview features

}


resource "snowflake_file_format" "json_format" {
  name              = "MY_JSON_FORMAT"
  database          = var.snowflake_database
  schema            = var.snowflake_schema
  format_type       = "JSON"
  strip_outer_array = true
}

##############################
# 2. Create a Table to Store Data
##############################
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
    name = "location"
    type = "STRING"
  }
  column {
    name = "system_id"
    type = "STRING"
  }
}

##############################
# 3. Create External Stage for Historical Data
##############################
resource "snowflake_stage" "historical_stage" {
  name        = "MY_S3_STAGE"
  database    = var.snowflake_database
  schema      = var.snowflake_schema
  url         = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
  credentials = "AWS_KEY_ID='${var.aws_key}' AWS_SECRET_KEY='${var.aws_secret}'"
  file_format = "TYPE = 'JSON'"

}

##############################
# 4. Create External Stage for Realtime Data
##############################
resource "snowflake_stage" "realtime_stage" {
  name        = "MY_S3_REALTIME_STAGE"
  database    = var.snowflake_database
  schema      = var.snowflake_schema
  url         = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
  credentials = "AWS_KEY_ID='${var.aws_key}' AWS_SECRET_KEY='${var.aws_secret}'"
  file_format = "TYPE = 'JSON'"
}
# file_format = "(TYPE = 'JSON')"

##############################
# 5. Create a Snowpipe for Realtime Ingestion
##############################
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

##############################
# 6. Create a Scheduled Task for Historical Data (Optional)
##############################
##############################
# 6. Create a Scheduled Task for Historical Data (Optional)
##############################
resource "snowflake_task" "historical_copy" {
  name      = "COPY_HISTORICAL_DATA"
  database  = var.snowflake_database
  schema    = var.snowflake_schema
  warehouse = var.snowflake_warehouse

  sql_statement = <<EOF
COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name}
FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.historical_stage.name}
FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
ON_ERROR = 'CONTINUE'
EOF
  started       = true
  # Corrected schedule: Runs every hour at minute 0
  schedule {
    minutes = 5
  }

  # Ensure the task is started

}

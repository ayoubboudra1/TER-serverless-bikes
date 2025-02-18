terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      # version = "~> 0.87.1"
    }
  }
}

# Define JSON file format
resource "snowflake_file_format" "json_format" {
  name              = "MY_JSON_FORMAT"
  database          = var.snowflake_database
  schema            = var.snowflake_schema
  format_type       = "JSON"
  strip_outer_array = true
}

# Dimension Tables
resource "snowflake_table" "bike_dimension" {
  name     = "BIKE_DIMENSION"
  database = var.snowflake_database
  schema   = var.snowflake_schema
  column {
    name = "bike_id"
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
}

resource "snowflake_table" "location_dimension" {
  name     = "LOCATION_DIMENSION"
  database = var.snowflake_database
  schema   = var.snowflake_schema
  column {
    name = "location_id"
    type = "NUMBER(38,0)"
  }
  column {
    name = "country_code"
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

resource "snowflake_table" "company_dimension" {
  name     = "COMPANY_DIMENSION"
  database = var.snowflake_database
  schema   = var.snowflake_schema
  column {
    name = "company_name"
    type = "STRING"
  }
}

resource "snowflake_table" "pricing_plan_dimension" {
  name     = "PRICING_PLAN_DIMENSION"
  database = var.snowflake_database
  schema   = var.snowflake_schema
  column {
    name = "pricing_plan_id"
    type = "STRING"
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

resource "snowflake_table" "time_dimension" {
  name     = "TIME_DIMENSION"
  database = var.snowflake_database
  schema   = var.snowflake_schema
  column {
    name = "time_id"
    type = "NUMBER(38,0)"
  }
  column {
    name = "time"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "year"
    type = "NUMBER(4,0)"
  }
  column {
    name = "month"
    type = "NUMBER(2,0)"
  }
  column {
    name = "day"
    type = "NUMBER(2,0)"
  }
  column {
    name = "hour"
    type = "NUMBER(2,0)"
  }
}

resource "snowflake_table" "bike_status_fact" {
  name     = "BIKE_STATUS_FACT"
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
    name = "current_range_meters"
    type = "FLOAT"
  }
  column {
    name = "current_fuel_percent"
    type = "FLOAT"
  }
  column {
    name = "last_reported"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "pricing_plan_id"
    type = "STRING"
  }
  column {
    name = "company_name"
    type = "STRING"
  }
  column {
    name = "time_id"
    type = "NUMBER(38,0)"
  }
}

resource "snowflake_stage" "historical_stage" {
  name        = "MY_S3_STAGE"
  database    = var.snowflake_database
  schema      = var.snowflake_schema
  url         = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
  credentials = "AWS_KEY_ID='${var.aws_key}' AWS_SECRET_KEY='${var.aws_secret}'"
  file_format = "TYPE = 'JSON'"
}

resource "snowflake_stage" "realtime_stage" {
  name        = "MY_S3_REALTIME_STAGE"
  database    = var.snowflake_database
  schema      = var.snowflake_schema
  url         = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
  credentials = "AWS_KEY_ID='${var.aws_key}' AWS_SECRET_KEY='${var.aws_secret}'"
  file_format = "TYPE = 'JSON'"
}

# Pipes for Dimension Tables
resource "snowflake_pipe" "bike_dimension_pipe" {
  name           = "BIKE_DIMENSION_PIPE"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO "${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_table.bike_dimension.name}" 
  FROM @"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_stage.realtime_stage.name}"
  FILE_FORMAT = (FORMAT_NAME='"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_file_format.json_format.name}"')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE';
EOF
  auto_ingest    = true
}

resource "snowflake_pipe" "location_dimension_pipe" {
  name           = "LOCATION_DIMENSION_PIPE"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO "${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_table.location_dimension.name}"
  FROM @"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_stage.realtime_stage.name}"
  FILE_FORMAT = (FORMAT_NAME='"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_file_format.json_format.name}"')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE';
EOF
  auto_ingest    = true
}

resource "snowflake_pipe" "company_dimension_pipe" {
  name           = "COMPANY_DIMENSION_PIPE"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO "${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_table.company_dimension.name}"
  FROM @"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_stage.realtime_stage.name}"
  FILE_FORMAT = (FORMAT_NAME='"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_file_format.json_format.name}"')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE';
EOF
  auto_ingest    = true
}

resource "snowflake_pipe" "pricing_plan_dimension_pipe" {
  name           = "PRICING_PLAN_DIMENSION_PIPE"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO "${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_table.pricing_plan_dimension.name}"
  FROM @"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_stage.realtime_stage.name}"
  FILE_FORMAT = (FORMAT_NAME='"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_file_format.json_format.name}"')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE';
EOF
  auto_ingest    = true
}

resource "snowflake_pipe" "time_dimension_pipe" {
  name           = "TIME_DIMENSION_PIPE"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO "${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_table.time_dimension.name}"
  FROM @"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_stage.realtime_stage.name}"
  FILE_FORMAT = (FORMAT_NAME='"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_file_format.json_format.name}"')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE';
EOF
  auto_ingest    = true
}

# Pipe for Fact Table (Loading raw data)
resource "snowflake_pipe" "bike_status_fact_pipe" {
  name           = "BIKE_STATUS_FACT_PIPE"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO "${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_table.bike_status_fact.name}"
FROM @"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_stage.realtime_stage.name}"
FILE_FORMAT = (FORMAT_NAME='"${var.snowflake_database}"."${var.snowflake_schema}"."${snowflake_file_format.json_format.name}"')
MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
ON_ERROR = 'CONTINUE';
EOF
  auto_ingest    = true
}

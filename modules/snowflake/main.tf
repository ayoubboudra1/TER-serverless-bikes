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
# Create dimension table for bikes
resource "snowflake_table" "dim_bike" {
  database = var.snowflake_database
  schema   = var.snowflake_schema
  name     = "DIM_BIKE"
  column {
    name = "bike_id"
    type = "STRING"
  }
  column {
    name = "vehicle_type_id"
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
# Create dimension table for locations
resource "snowflake_table" "dim_location" {
  database = var.snowflake_database
  schema   = var.snowflake_schema
  name     = "DIM_LOCATION"
  column {
    name = "location_id"
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
    name = "country_code"
    type = "STRING"
  }
  column {
    name = "Location"
    type = "STRING"
  }
}

# Create dimension table for companies
resource "snowflake_table" "dim_company" {
  database = var.snowflake_database
  schema   = var.snowflake_schema
  name     = "DIM_COMPANY"
  column {
    name = "company_id"
    type = "STRING"
  }
  column {
    name = "company_name"
    type = "STRING"
  }
  column {
    name = "System_ID"
    type = "STRING"
  }
}

# Create dimension table for pricing plans
resource "snowflake_table" "dim_pricing_plan" {
  database = var.snowflake_database
  schema   = var.snowflake_schema
  name     = "DIM_PRICING_PLAN"
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

# Create fact table for bike status
resource "snowflake_table" "fact_bike_status" {
  database = var.snowflake_database
  schema   = var.snowflake_schema
  name     = "FACT_BIKE_STATUS"
  column {
    name = "bike_id"
    type = "STRING"
  }
  column {
    name = "location_id"
    type = "STRING"
  }
  column {
    name = "company_id"
    type = "STRING"
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
    name = "System_ID"
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

# resource "snowflake_pipe" "snowpipe" {
#   name     = "SNOWPIPE_DAILY"
#   database = var.snowflake_database
#   schema   = var.snowflake_schema

#   copy_statement = <<EOF
# COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name}
# FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.realtime_stage.name}
# FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
# MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
# ON_ERROR = 'CONTINUE'
# EOF

#   auto_ingest = true
# }
resource "snowflake_task" "realtime_copy" {
  name      = "COPY_realtime_DATA"
  database  = var.snowflake_database
  schema    = var.snowflake_schema

  # Schedule: Run the COPY every ** minutes
   schedule {
    minutes = 60
  }

  sql_statement = <<EOF
COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name}
  FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.realtime_stage.name}
  FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
  MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
  ON_ERROR = 'CONTINUE'
  PURGE = TRUE;
EOF

  # Set to true so the task immediately starts/resumes on creation
  started = true
}

# Create a task to transform raw data into dim and fact tables
resource "snowflake_task" "transform_data" {
  database = var.snowflake_database
  schema   = var.snowflake_schema
  name      = "TRANSFORM_DATA"
  after = ["${var.snowflake_database}.${var.snowflake_schema}.${snowflake_task.realtime_copy.name}"]

  sql_statement = <<SQL
BEGIN
-- Insert into DIM_BIKE
INSERT INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.dim_bike.name} 
    ("bike_id", "vehicle_type_id", "form_factor", "propulsion_type", "max_range_meters")
SELECT DISTINCT "bike_id", "vehicle_type_id", "form_factor", "propulsion_type", "max_range_meters"
FROM ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name};

-- Insert into DIM_LOCATION
INSERT INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.dim_location.name} 
    ("location_id", "lat", "lon", "country_code", "Location")  -- "Location" is case-sensitive
SELECT DISTINCT MD5(CONCAT("lat", "lon")) AS "location_id", "lat", "lon", "country_code", "Location"
FROM ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name};

-- Insert into DIM_COMPANY
INSERT INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.dim_company.name} 
    ("company_id", "company_name", "System_ID")  -- "System_ID" is case-sensitive
SELECT DISTINCT MD5("company_name") AS "company_id", "company_name", "System_ID"
FROM ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name};

-- Insert into DIM_PRICING_PLAN
INSERT INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.dim_pricing_plan.name} 
    ("pricing_plan_id", "plan_id", "currency", "price", "is_taxable", "description", "per_min_pricing", "pricing_name")
SELECT DISTINCT "pricing_plan_id", "plan_id", "currency", "price", "is_taxable", "description", "per_min_pricing", "pricing_name"
FROM ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name};

-- Insert into FACT_BIKE_STATUS
INSERT INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.fact_bike_status.name} 
    ("bike_id", "location_id", "company_id", "pricing_plan_id", "time", "is_disabled", "is_reserved", "current_range_meters", "current_fuel_percent")
SELECT 
    "bike_id",
    MD5(CONCAT("lat", "lon")) AS "location_id",
    MD5("company_name") AS "company_id",
    "pricing_plan_id",
    "time",
    "is_disabled",
    "is_reserved",
    "current_range_meters",
    "current_fuel_percent"
FROM ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name};
END;
SQL


    # Set to true so the task immediately starts/resumes on creation
    started = true
}

resource "snowflake_task" "delete_source_data" {
  name      = "DELETE_SOURCE_DATA"
  database  = var.snowflake_database
  schema    = var.snowflake_schema

  after = ["${var.snowflake_database}.${var.snowflake_schema}.${snowflake_task.transform_data.name}"]

  sql_statement = <<SQL
TRUNCATE TABLE ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.source_data.name};
SQL

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
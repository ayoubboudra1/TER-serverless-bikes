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

# Fact Table: Bike Status Fact
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

# Stages
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

# Pipes
resource "snowflake_pipe" "snowpipe" {
  name           = "SNOWPIPE_DAILY"
  database       = var.snowflake_database
  schema         = var.snowflake_schema
  copy_statement = <<EOF
COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.bike_status_fact.name}
FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.realtime_stage.name}
FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
ON_ERROR = 'CONTINUE'
EOF
  auto_ingest    = true
}

# Tasks
resource "snowflake_task" "historical_copy" {
  name          = "COPY_HISTORICAL_DATA"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
COPY INTO ${var.snowflake_database}.${var.snowflake_schema}.${snowflake_table.bike_status_fact.name}
FROM @${var.snowflake_database}.${var.snowflake_schema}.${snowflake_stage.historical_stage.name}
FILE_FORMAT = (FORMAT_NAME='${var.snowflake_database}.${var.snowflake_schema}.${snowflake_file_format.json_format.name}')
MATCH_BY_COLUMN_NAME = "CASE_INSENSITIVE"
ON_ERROR = 'CONTINUE'
EOF
  started       = true
  schedule {
    minutes = 60
  }
}

resource "snowflake_task" "load_bike_dimension" {
  name          = "LOAD_BIKE_DIMENSION"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
MERGE INTO ${var.snowflake_database}.${var.snowflake_schema}.BIKE_DIMENSION AS target
USING (
    SELECT DISTINCT
        bike_id::STRING AS bike_id,
        form_factor::STRING AS form_factor,
        propulsion_type::STRING AS propulsion_type,
        max_range_meters::FLOAT AS max_range_meters
    FROM ${var.snowflake_database}.${var.snowflake_schema}.SOURCE_DATA
) AS source
ON target.bike_id = source.bike_id
WHEN NOT MATCHED THEN
INSERT (bike_id, form_factor, propulsion_type, max_range_meters)
VALUES (source.bike_id, source.form_factor, source.propulsion_type, source.max_range_meters);
EOF
  schedule {
    minutes = 60
  }
  started = true
}

resource "snowflake_task" "load_location_dimension" {
  name          = "LOAD_LOCATION_DIMENSION"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
MERGE INTO ${var.snowflake_database}.${var.snowflake_schema}.LOCATION_DIMENSION AS target
USING (
    SELECT DISTINCT
        MD5(CONCAT(country_code, location, system_id))::NUMBER(38,0) AS location_id,
        country_code::STRING AS country_code,
        location::STRING AS location,
        system_id::STRING AS system_id
    FROM ${var.snowflake_database}.${var.snowflake_schema}.SOURCE_DATA
) AS source
ON target.location_id = source.location_id
WHEN NOT MATCHED THEN
INSERT (location_id, country_code, location, system_id)
VALUES (source.location_id, source.country_code, source.location, source.system_id);
EOF
  schedule {
    minutes = 60
  }
  started = true
}

resource "snowflake_task" "load_company_dimension" {
  name          = "LOAD_COMPANY_DIMENSION"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
MERGE INTO ${var.snowflake_database}.${var.snowflake_schema}.COMPANY_DIMENSION AS target
USING (
    SELECT DISTINCT company_name::STRING AS company_name
    FROM ${var.snowflake_database}.${var.snowflake_schema}.SOURCE_DATA
) AS source
ON target.company_name = source.company_name
WHEN NOT MATCHED THEN
INSERT (company_name)
VALUES (source.company_name);
EOF
  schedule {
    minutes = 60
  }
  started = true
}

resource "snowflake_task" "load_pricing_plan_dimension" {
  name          = "LOAD_PRICING_PLAN_DIMENSION"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
MERGE INTO ${var.snowflake_database}.${var.snowflake_schema}.PRICING_PLAN_DIMENSION AS target
USING (
    SELECT DISTINCT
        pricing_plan_id::STRING AS pricing_plan_id,
        plan_id::STRING AS plan_id,
        currency::STRING AS currency,
        price::FLOAT AS price,
        is_taxable::BOOLEAN AS is_taxable,
        description::STRING AS description,
        per_min_pricing::FLOAT AS per_min_pricing,
        pricing_name::STRING AS pricing_name
    FROM ${var.snowflake_database}.${var.snowflake_schema}.SOURCE_DATA
) AS source
ON target.pricing_plan_id = source.pricing_plan_id
WHEN NOT MATCHED THEN
INSERT (pricing_plan_id, plan_id, currency, price, is_taxable, description, per_min_pricing, pricing_name)
VALUES (source.pricing_plan_id, source.plan_id, source.currency, source.price, source.is_taxable, source.description, source.per_min_pricing, source.pricing_name);
EOF
  schedule {
    minutes = 60
  }
  started = true
}

resource "snowflake_task" "load_time_dimension" {
  name          = "LOAD_TIME_DIMENSION"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
MERGE INTO ${var.snowflake_database}.${var.snowflake_schema}.TIME_DIMENSION AS target
USING (
    SELECT DISTINCT
        MD5(TO_VARCHAR(time))::NUMBER(38,0) AS time_id,
        time::TIMESTAMP_NTZ AS time,
        YEAR(time)::NUMBER(4,0) AS year,
        MONTH(time)::NUMBER(2,0) AS month,
        DAY(time)::NUMBER(2,0) AS day,
        HOUR(time)::NUMBER(2,0) AS hour
    FROM ${var.snowflake_database}.${var.snowflake_schema}.SOURCE_DATA
) AS source
ON target.time_id = source.time_id
WHEN NOT MATCHED THEN
INSERT (time_id, time, year, month, day, hour)
VALUES (source.time_id, source.time, source.year, source.month, source.day, source.hour);
EOF
  schedule {
    minutes = 60
  }
  started = true
}

resource "snowflake_task" "load_bike_status_fact" {
  name          = "LOAD_BIKE_STATUS_FACT"
  database      = var.snowflake_database
  schema        = var.snowflake_schema
  warehouse     = var.snowflake_warehouse
  sql_statement = <<EOF
INSERT INTO ${var.snowflake_database}.${var.snowflake_schema}.BIKE_STATUS_FACT (
    bike_id, lat, lon, is_disabled, is_reserved, current_range_meters,
    current_fuel_percent, last_reported, pricing_plan_id, company_name, time_id
)
SELECT
    b.bike_id,
    s.lat,
    s.lon,
    s.is_disabled,
    s.is_reserved,
    s.current_range_meters,
    s.current_fuel_percent,
    s.last_reported,
    p.pricing_plan_id,
    c.company_name,
    t.time_id
FROM ${var.snowflake_database}.${var.snowflake_schema}.SOURCE_DATA s
JOIN ${var.snowflake_database}.${var.snowflake_schema}.BIKE_DIMENSION b ON s.bike_id = b.bike_id
JOIN ${var.snowflake_database}.${var.snowflake_schema}.COMPANY_DIMENSION c ON s.company_name = c.company_name
JOIN ${var.snowflake_database}.${var.snowflake_schema}.PRICING_PLAN_DIMENSION p ON s.pricing_plan_id = p.pricing_plan_id
JOIN ${var.snowflake_database}.${var.snowflake_schema}.TIME_DIMENSION t ON s.time = t.time
WHERE NOT EXISTS (
    SELECT 1
    FROM ${var.snowflake_database}.${var.snowflake_schema}.BIKE_STATUS_FACT f
    WHERE f.bike_id = b.bike_id AND f.last_reported = s.last_reported
);
EOF
  schedule {
    minutes = 5
  }
  started = true
}

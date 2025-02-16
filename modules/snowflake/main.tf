terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.0"
    }
  }
}

resource "aws_iam_user" "snowflake_user" {
  name = "snowflake-s3-user"
}

resource "aws_iam_access_key" "snowflake_user" {
  user = aws_iam_user.snowflake_user.name
}

resource "aws_iam_user_policy" "s3_access" {
  name   = "snowflake-s3-access"
  user   = aws_iam_user.snowflake_user.name
  policy = data.aws_iam_policy_document.s3_access.json
}

# data "aws_iam_policy_document" "s3_access" {
#   statement {
#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket"
#     ]
#     resources = [
#       "arn:aws:s3:::${var.silver_bucket_name}",
#       "arn:aws:s3:::${var.silver_bucket_name}/*"
#     ]
#   }
# }

resource "snowflake_database" "dwh" {
  name = "BIKE_DWH"
}

resource "snowflake_schema" "schema" {
  database = snowflake_database.dwh.name
  name     = "BIKE_SCHEMA"
}

resource "snowflake_table" "bike_table" {
  database = snowflake_database.dwh.name
  schema   = snowflake_schema.schema.name
  name     = "BIKE_DATA"

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
    type = "TIMESTAMP_NTZ(9)"
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
    type = "TIMESTAMP"
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

resource "snowflake_stage" "s3_stage" {
  database    = snowflake_database.dwh.name
  schema      = snowflake_schema.schema.name
  name        = "S3_STAGE"
  url         = "s3://${var.silver_bucket_name}"
  credentials = "AWS_KEY_ID='${aws_iam_access_key.snowflake_user.id}' AWS_SECRET_KEY='${aws_iam_access_key.snowflake_user.secret}'"
}

# Snowflake Storage Integration
resource "snowflake_storage_integration" "s3" {
  name    = "S3_INTEGRATION"
  type    = "EXTERNAL_STAGE"
  enabled = true

  storage_provider          = "S3"
  storage_aws_role_arn      = aws_iam_role.snowflake_storage.arn
  storage_allowed_locations = ["s3://${var.silver_bucket_name}/FreeBikeStatusData/"]
}

# Snowflake Stage using Storage Integration
resource "snowflake_stage" "s3" {
  database            = snowflake_database.dwh.name
  schema              = snowflake_schema.schema.name
  name                = "S3_STAGE"
  url                 = "s3://${var.silver_bucket_name}/FreeBikeStatusData/"
  storage_integration = snowflake_storage_integration.s3.name
  file_format         = "TYPE = JSON"
}

# Snowflake Pipe with Auto-Ingest
resource "snowflake_pipe" "bike" {
  database    = snowflake_database.dwh.name
  schema      = snowflake_schema.schema.name
  name        = "BIKE_PIPE"
  auto_ingest = true
  integration = snowflake_storage_integration.s3.name

  copy_statement = <<EOF
    COPY INTO ${snowflake_database.dwh.name}.${snowflake_schema.schema.name}.${snowflake_table.bike_table.name}
    FROM @${snowflake_stage.s3.name}
    FILE_FORMAT = (TYPE = 'JSON')
  EOF
}

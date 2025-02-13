resource "snowflake_database" "my_db" {
  name    = "BIKE_SHARING_DB"
  comment = "Database for bike-sharing data"
}

resource "snowflake_schema" "my_schema" {
  database = snowflake_database.my_db.name
  name     = "BIKE_SCHEMA"
}

resource "snowflake_table" "bike_data_table" {
  database = snowflake_database.my_db.name
  schema   = snowflake_schema.my_schema.name
  name     = "BIKE_DATA"

  column {
    name = "ID"
    type = "NUMBER(38,0)"
  }

  column {
    name = "STATION_NAME"
    type = "VARCHAR(255)"
  }

  column {
    name = "BIKE_TYPE"
    type = "VARCHAR(50)"
  }

  column {
    name = "TIMESTAMP"
    type = "TIMESTAMP_NTZ"
  }
}

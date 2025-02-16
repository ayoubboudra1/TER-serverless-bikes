
variable "silver_bucket_name" {
  description = "Name of the silver S3 bucket (where FreeBikeStatusData/ folder is located)"
  type        = string
}

variable "aws_key" {
  description = "AWS access key for Snowflake stage authentication"
  type        = string
}

variable "aws_secret" {
  description = "AWS secret key for Snowflake stage authentication"
  type        = string
  sensitive   = true
}

variable "snowflake_database" {
  description = "Snowflake database name"
  type        = string
}

variable "snowflake_schema" {
  description = "Snowflake schema name"
  type        = string
}

variable "snowflake_table" {
  description = "Name of the Snowflake table for ingested FreeBikeStatusData"
  type        = string
  default     = "FREEBIKE_STATUS_DATA"
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse name"
  type        = string

}

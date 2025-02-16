variable "silver_bucket_name" {
  type = string
}

variable "snowflake_aws_account_id" {
  description = "Snowflake's AWS account ID"
  type        = string
}

variable "snowflake_external_id" {
  description = "Snowflake storage integration external ID"
  type        = string
  sensitive   = true
}

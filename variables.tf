variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bronze_bucket_name" {
  description = "Name of the Bronze S3 bucket (must be globally unique)"
  type        = string
  default     = "my-bronze-data-bucket-ter-serverless"
}

variable "silver_bucket_name" {
  description = "Name of the Silver S3 bucket (must be globally unique)"
  type        = string
  default     = "my-silver-data-bucket-ter-serverless"
}

variable "extract_lambda_zip_path" {
  description = "Path to the extract lambda deployment package ZIP file"
  type        = string
  default     = "lambda/extract_lambda.zip"
}

variable "preprocess_lambda_zip_path" {
  description = "Path to the preprocess lambda deployment package ZIP file"
  type        = string
  default     = "lambda/preprocess_lambda.zip"
}

variable "lambda_runtime" {
  description = "Runtime for Lambda functions"
  type        = string
  default     = "python3.9"
}

variable "state_machine_name" {
  description = "Name for the Step Function state machine"
  type        = string
  default     = "DataPipelineStateMachine"
}
variable "snowflake_account_name" {
  description = "Snowflake account name (from your Snowflake URL)"
  type        = string
}

# variable "snowflake_organization_name" {
#   description = "Snowflake organization name"
#   type        = string
# }

variable "snowflake_user" {
  description = "Snowflake user name"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS access key (for Snowflake stage credentials)"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key (for Snowflake stage credentials)"
  type        = string
  sensitive   = true
}

variable "snowflake_database" {
  description = "Snowflake database name"
  type        = string
  default     = "MY_DATABASE"
}

variable "snowflake_schema" {
  description = "Snowflake schema name"
  type        = string
  default     = "PUBLIC"
}

variable "snowflake_table" {
  description = "Snowflake table name for data ingestion"
  type        = string
  default     = "SOURCE_DATA"
}

# variable "snowflake_warehouse" {
#   description = "Snowflake warehouse for running tasks"
#   type        = string
#   default     = "MY_WH"
# }

variable "snowflake_role" {
  description = "Snowflake role for running tasks"
  type        = string
  default     = "ACCOUNTADMIN"
}

variable "snowflake_region" {
  description = "Snowflake region"
  type        = string
  default     = "us-east-1"
}

variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
}

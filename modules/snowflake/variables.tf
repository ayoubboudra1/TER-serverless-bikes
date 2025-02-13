variable "snowflake_account" {
  description = "Your Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Your Snowflake username"
  type        = string
}

variable "snowflake_password" {
  description = "Your Snowflake password"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role (e.g., SYSADMIN, ACCOUNTADMIN)"
  type        = string
  default     = "SYSADMIN"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 5.45.0"
    }
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      # version = ">= 0.77.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role
  organization_name = var.snowflake_organization_name


  preview_features_enabled = [
    "snowflake_file_format_resource",
    "snowflake_stage_resource",
    "snowflake_table_resource",
    "snowflake_pipe_resource"
  ]

}

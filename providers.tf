terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.0" # Correct source
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "snowflake" {
  account  = "${var.snowflake_account}.${var.snowflake_region}"
  username = var.snowflake_user
  password = var.snowflake_password
  role     = var.snowflake_role
}


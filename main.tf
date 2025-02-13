terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "s3" {
  source             = "./modules/s3"
  bronze_bucket_name = var.bronze_bucket_name
  silver_bucket_name = var.silver_bucket_name
}

module "lambda" {
  source                     = "./modules/lambda"
  lambda_runtime             = "python3.8"
  extract_lambda_zip_path    = "lambda/extract_lambda.zip"
  preprocess_lambda_zip_path = "lambda/preprocess_lambda.zip"
  bronze_bucket_name         = "my-bronze-data-bucket-ter-serverless"
  silver_bucket_name         = "my-silver-data-bucket-ter-serverless"
}


module "step_function" {
  source                = "./modules/step_function"
  state_machine_name    = var.state_machine_name
  extract_lambda_arn    = module.lambda.extract_lambda_arn
  preprocess_lambda_arn = module.lambda.preprocess_lambda_arn
}

module "snowflake" {
  source = "./modules/snowflake"

  snowflake_account  = var.snowflake_account
  snowflake_user     = var.snowflake_user
  snowflake_password = var.snowflake_password
  snowflake_role     = var.snowflake_role
}

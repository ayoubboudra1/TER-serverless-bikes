variable "extract_lambda_zip_path" {
  description = "Path to the ZIP package for the extract lambda function"
  type        = string
}

variable "preprocess_lambda_zip_path" {
  description = "Path to the ZIP package for the preprocess lambda function"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime (e.g., python3.9)"
  type        = string
}

variable "bronze_bucket_name" {
  description = "The Bronze S3 bucket name (passed in for environment variables)"
  type        = string
}


variable "silver_bucket_name" {
  description = "The name of the Silver S3 bucket"
  type        = string
}

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

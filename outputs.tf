output "bronze_bucket" {
  description = "Name of the Bronze S3 bucket"
  value       = module.s3.bronze_bucket
}

output "silver_bucket" {
  description = "Name of the Silver S3 bucket"
  value       = module.s3.silver_bucket
}

output "extract_lambda_arn" {
  description = "ARN of the Extract Lambda function"
  value       = module.lambda.extract_lambda_arn
}

output "preprocess_lambda_arn" {
  description = "ARN of the Preprocess Lambda function"
  value       = module.lambda.preprocess_lambda_arn
}

output "state_machine_arn" {
  description = "ARN of the Step Function state machine"
  value       = module.step_function.state_machine_arn
}

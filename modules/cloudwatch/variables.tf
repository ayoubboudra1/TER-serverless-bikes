variable "step_function_arn" {
  description = "ARN of the Step Function"
  type        = string
}

variable "lambda_function_names" {
  description = "List of Lambda function names to monitor"
  type        = list(string)
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names to monitor"
  type        = list(string)
}

variable "s3_size_threshold" {
  description = "Threshold for S3 bucket size (in bytes)"
  type        = number
  default     = 10737418240 # 10 GB
}

variable "alarm_actions" {
  description = "List of actions (e.g., SNS topic ARNs) to trigger when alarms fire"
  type        = list(string)
  default     = []
}
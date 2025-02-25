variable "state_machine_name" {
  description = "Name for the Step Function state machine"
  type        = string
  default = "aws_sfn_state_machine.data_pipeline.arn"
}

variable "extract_lambda_arn" {
  description = "ARN of the extract lambda function"
  type        = string
}

variable "preprocess_lambda_arn" {
  description = "ARN of the preprocess lambda function"
  type        = string
}

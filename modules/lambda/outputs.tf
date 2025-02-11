output "extract_lambda_arn" {
  value = aws_lambda_function.extract_lambda.arn
}

output "preprocess_lambda_arn" {
  value = aws_lambda_function.preprocess_lambda.arn
}

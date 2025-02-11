resource "aws_sfn_state_machine" "data_pipeline" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.step_function_role.arn
  definition = templatefile("${path.module}/state_machine.json", {
    extract_lambda_arn    = var.extract_lambda_arn,
    preprocess_lambda_arn = var.preprocess_lambda_arn
  })
}

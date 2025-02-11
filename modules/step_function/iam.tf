resource "aws_iam_role" "step_function_role" {
  name = "${var.state_machine_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name        = "${var.state_machine_name}-policy"
  description = "Policy for Step Function to invoke Lambda functions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Action : ["lambda:InvokeFunction"],
        Resource : [
          var.extract_lambda_arn,
          var.preprocess_lambda_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_policy_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

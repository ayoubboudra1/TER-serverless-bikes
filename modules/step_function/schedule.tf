# modules/step_function/schedule.tf

# Create an EventBridge rule to run every 5 minutes
resource "aws_cloudwatch_event_rule" "step_function_schedule" {
  name                = "StepFunctionFiveMinuteSchedule"
  description         = "Trigger the Step Function every 1 hour"
  schedule_expression = "rate(1 hour)"
}

# Create an IAM Role for EventBridge to assume in order to start the state machine execution
resource "aws_iam_role" "events_step_function_role" {
  name = "events-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "events.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach a policy so the role can invoke the Step Function execution
resource "aws_iam_policy" "events_step_function_policy" {
  name = "events-step-function-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "states:StartExecution",
      Resource = aws_sfn_state_machine.data_pipeline.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "events_step_function_attach" {
  role       = aws_iam_role.events_step_function_role.name
  policy_arn = aws_iam_policy.events_step_function_policy.arn
}

# Create an EventBridge target that triggers the Step Function
resource "aws_cloudwatch_event_target" "step_function_target" {
  rule      = aws_cloudwatch_event_rule.step_function_schedule.name
  target_id = "StepFunction"
  arn       = aws_sfn_state_machine.data_pipeline.arn
  role_arn  = aws_iam_role.events_step_function_role.arn
}

# Trigger an initial execution right after creation
resource "null_resource" "initial_execution" {
  depends_on = [aws_sfn_state_machine.data_pipeline]
  triggers = {
    state_machine_arn = aws_sfn_state_machine.data_pipeline.arn
  }

  provisioner "local-exec" {
    # For Windows (PowerShell), you can use:
    command = "powershell -Command \"aws stepfunctions start-execution --state-machine-arn ${aws_sfn_state_machine.data_pipeline.arn} --name initial-$(Get-Date -UFormat '%s')\""
  }
}

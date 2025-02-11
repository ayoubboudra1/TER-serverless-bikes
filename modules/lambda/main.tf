resource "aws_lambda_function" "extract_lambda" {
  function_name    = "ExtractDataLambda"
  handler          = "extract_lambda.lambda_handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_role.arn
  filename         = var.extract_lambda_zip_path
  source_code_hash = filebase64sha256(var.extract_lambda_zip_path)

  environment {
    variables = {
      BRONZE_BUCKET = var.bronze_bucket_name
    }
  }

  timeout = 30 # ⏳ Ensuring Extract Lambda (Bronze) has a 30-sec timeout
}

resource "aws_lambda_function" "preprocess_lambda" {
  function_name    = "PreprocessLambda"
  handler          = "preprocess_lambda.lambda_handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_role.arn
  filename         = var.preprocess_lambda_zip_path
  source_code_hash = filebase64sha256(var.preprocess_lambda_zip_path)

  environment {
    variables = {
      SILVER_BUCKET = var.silver_bucket_name
    }
  }

  timeout = 30 # ⏳ Added timeout to 30 sec for Silver bucket function
}

# Schedule the extract_lambda to run every 1 hour
resource "aws_cloudwatch_event_rule" "extract_schedule" {
  name                = "ExtractLambdaSchedule"
  description         = "Schedule rule to run extract lambda every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "extract_target" {
  rule      = aws_cloudwatch_event_rule.extract_schedule.name
  target_id = "ExtractLambda"
  arn       = aws_lambda_function.extract_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.extract_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.extract_schedule.arn
}

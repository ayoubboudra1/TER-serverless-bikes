resource "aws_sns_topic" "alarm_notifications" {
  name = "alarm-notifications-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = "aymen.mokrani.am@gmail.com" 
}
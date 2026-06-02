output "sns_topic_arn" {
  description = "SNS topic ARN for billing alerts"
  value       = aws_sns_topic.billing_alerts.arn
}

output "budget_name" {
  description = "AWS Budget name"
  value       = aws_budgets_budget.monthly.name
}

output "cloudwatch_alarm_name" {
  description = "CloudWatch billing alarm name"
  value       = aws_cloudwatch_metric_alarm.billing.alarm_name
}

locals {
  tags = merge({
    Project       = "aws-certification-portfolio"
    Environment   = "study"
    Certification = "cloud-practitioner"
    Module        = "billing-alerts"
  }, var.tags)
}

resource "aws_sns_topic" "billing_alerts" {
  name = "billing-alerts"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "billing_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_budgets_budget" "monthly" {
  name         = "monthly-cost-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.billing_alerts.arn]
  }
}

resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "billing-alarm-usd${var.monthly_budget_usd}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400
  statistic           = "Maximum"
  threshold           = var.monthly_budget_usd
  alarm_description   = "Billing alarm when estimated charges exceed $${var.monthly_budget_usd}"
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }

  tags = local.tags
}

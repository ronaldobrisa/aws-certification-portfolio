# billing-alerts

Configures cost monitoring and alerting to prevent unexpected AWS charges.

## Resources

| Resource | Purpose |
|---|---|
| SNS Topic + Email Subscription | Notification channel for alerts |
| AWS Budget | Tracks monthly spend with alerts at 80% and 100% forecasted |
| CloudWatch Billing Alarm | Triggers when estimated charges exceed threshold |

## Alert thresholds

| Alert | Threshold | Type |
|---|---|---|
| Budget warning | 80% of monthly limit | Actual spend |
| Budget exceeded | 100% of monthly limit | Forecasted spend |
| CloudWatch alarm | Monthly limit (USD) | Estimated charges |

## Usage

```bash
mise run tf:init  01-cloud-practitioner/billing-alerts
mise run tf:plan  01-cloud-practitioner/billing-alerts
mise run tf:apply 01-cloud-practitioner/billing-alerts
```

## Variables

| Variable | Description | Default |
|---|---|---|
| `alert_email` | Email for notifications | Required |
| `monthly_budget_usd` | Monthly limit in USD | `10` |
| `tags` | Additional tags | `{}` |

> After apply, confirm the SNS email subscription from your inbox.

# iam-basics

Demonstrates IAM fundamentals: groups, policies, roles, and instance profiles following the principle of least privilege.

## Resources

| Resource | Purpose |
|---|---|
| IAM Group: Developers | PowerUserAccess for dev team |
| IAM Group: ReadOnly | ReadOnlyAccess for auditors |
| IAM Policy: S3ReadOnlyCustom | Custom least-privilege S3 read policy |
| IAM Role: EC2S3ReadRole | Service role allowing EC2 to read S3 |
| IAM Instance Profile | Attaches EC2S3ReadRole to EC2 instances |

## Key Concepts

- **Groups over individual users** — permissions managed at group level
- **Least privilege** — custom policy grants only required actions
- **Service roles** — EC2 assumes role via instance profile, no access keys needed

## Usage

```bash
mise run tf:init  01-cloud-practitioner/iam-basics
mise run tf:plan  01-cloud-practitioner/iam-basics
mise run tf:apply 01-cloud-practitioner/iam-basics
```

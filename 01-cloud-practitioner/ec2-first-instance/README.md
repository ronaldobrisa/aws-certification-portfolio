# ec2-first-instance

Launches an EC2 instance running a simple Apache web server, demonstrating compute, security groups, and AMI selection.

## Architecture

```mermaid
graph LR
    Internet -->|:80| SG[Security Group]
    Internet -->|:22| SG
    SG --> EC2[EC2 t2.micro\nAmazon Linux 2023]
```

## Resources

| Resource | Purpose |
|---|---|
| Security Group | Allows HTTP :80 and SSH :22 inbound |
| EC2 Instance | Amazon Linux 2023, t2.micro (free tier) |
| AMI Data Source | Always fetches latest Amazon Linux 2023 AMI |

## Usage

```bash
mise run tf:init  01-cloud-practitioner/ec2-first-instance
mise run tf:plan  01-cloud-practitioner/ec2-first-instance
mise run tf:apply 01-cloud-practitioner/ec2-first-instance
```

## Variables

| Variable | Description | Default |
|---|---|---|
| `instance_type` | EC2 instance type | `t2.micro` |
| `allowed_ssh_cidr` | CIDR allowed to SSH | `0.0.0.0/0` |
| `tags` | Additional tags | `{}` |

> For production use, restrict `allowed_ssh_cidr` to your own IP.

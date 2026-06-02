# s3-static-site

Hosts a static website on S3 with CloudFront CDN and HTTPS enforcement.

## Architecture

```mermaid
graph LR
    User -->|HTTPS| CF[CloudFront]
    CF -->|HTTP| S3[S3 Bucket]
```

## Resources

| Resource | Purpose |
|---|---|
| S3 Bucket | Static file storage |
| S3 Website Configuration | index.html + error.html routing |
| S3 Bucket Policy | Public read access |
| CloudFront Distribution | CDN + HTTPS + redirect HTTP→HTTPS |

## Usage

```bash
mise run tf:init  01-cloud-practitioner/s3-static-site
mise run tf:plan  01-cloud-practitioner/s3-static-site
mise run tf:apply 01-cloud-practitioner/s3-static-site
```

## Variables

| Variable | Description | Required |
|---|---|---|
| `bucket_name` | Globally unique S3 bucket name | Yes |
| `tags` | Additional tags | No |

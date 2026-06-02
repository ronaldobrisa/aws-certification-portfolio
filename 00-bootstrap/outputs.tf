output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "terraform_local_role_arn" {
  description = "IAM Role ARN for local Terraform execution"
  value       = aws_iam_role.terraform_local.arn
}

output "admin_user_arn" {
  description = "IAM AdminUser ARN"
  value       = aws_iam_user.admin.arn
}

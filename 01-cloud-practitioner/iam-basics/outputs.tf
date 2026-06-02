output "developers_group_name" {
  description = "IAM group name for developers"
  value       = aws_iam_group.developers.name
}

output "read_only_group_name" {
  description = "IAM group name for read-only access"
  value       = aws_iam_group.read_only.name
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile for EC2 with S3 read access"
  value       = aws_iam_instance_profile.ec2_s3_read.name
}

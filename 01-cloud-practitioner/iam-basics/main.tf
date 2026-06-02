locals {
  tags = merge({
    Project       = "aws-certification-portfolio"
    Environment   = "study"
    Certification = "cloud-practitioner"
    Module        = "iam-basics"
  }, var.tags)
}

resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group" "read_only" {
  name = "ReadOnly"
}

resource "aws_iam_group_policy_attachment" "developers_power_user" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_group_policy_attachment" "read_only_view" {
  group      = aws_iam_group.read_only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnlyCustom"
  description = "Custom policy: read-only access to all S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:ListBucket"]
      Resource = ["arn:aws:s3:::*", "arn:aws:s3:::*/*"]
    }]
  })

  tags = local.tags
}

resource "aws_iam_role" "ec2_s3_read" {
  name        = "EC2S3ReadRole"
  description = "Allows EC2 instances to read from S3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ec2_s3_read" {
  role       = aws_iam_role.ec2_s3_read.name
  policy_arn = aws_iam_policy.s3_read_only.arn
}

resource "aws_iam_instance_profile" "ec2_s3_read" {
  name = "EC2S3ReadProfile"
  role = aws_iam_role.ec2_s3_read.name
}

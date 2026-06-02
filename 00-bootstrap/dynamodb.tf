resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project}-tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.tags, { Name = "terraform-state-locks" })
}

variable "bucket_name" {
  description = "Unique name for the S3 static site bucket"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

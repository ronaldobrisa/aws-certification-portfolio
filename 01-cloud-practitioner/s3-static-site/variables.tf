variable "bucket_name" {
  description = "Override para o nome do bucket (único global). Se null, é derivado do account_id."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

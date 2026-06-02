variable "project" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-cert-portfolio"
}

variable "tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

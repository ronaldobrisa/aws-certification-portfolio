variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorizado a fazer SSH na instância. Fechado por padrão; defina seu IP/32 (ex.: -var allowed_ssh_cidr=1.2.3.4/32) quando for realmente usar SSH."
  type        = string
  default     = "127.0.0.1/32"
}

variable "tags" {
  description = "Additional tags to merge with default tags"
  type        = map(string)
  default     = {}
}

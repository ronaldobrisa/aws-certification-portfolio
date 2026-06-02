data "aws_caller_identity" "current" {}

locals {
  tags = merge({
    Project       = "aws-certification-portfolio"
    Environment   = "study"
    Certification = "bootstrap"
    Module        = "00-bootstrap"
  }, var.tags)
}

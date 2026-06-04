terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Owner     = "ronaldobrisa"
      ManagedBy = "terraform"
    }
  }
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.1.0, < 6.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}
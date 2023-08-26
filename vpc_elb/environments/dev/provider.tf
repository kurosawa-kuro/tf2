terraform {
  required_version = "1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

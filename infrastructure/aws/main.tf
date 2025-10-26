terraform {
  required_version = "~> 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Management = "terraform"
      Repository = "github.com/cjhouser/thoughtlyify.io"
      Directory  = "/infrastructure/aws/"
    }
  }
}

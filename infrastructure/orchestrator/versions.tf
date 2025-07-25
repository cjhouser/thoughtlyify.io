terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Management = "terraform"
      Repository = "github.com/cjhouser/thoughtlyify.io"
      Directory  = "/infrastructure/orchestrator/"
    }
  }
}

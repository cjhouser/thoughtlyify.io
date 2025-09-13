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

data "aws_iam_user" "chouser" {
  user_name = "charles.houser"
}

data "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
}

data "aws_iam_role" "eks_node" {
  name = "eks_node"
}
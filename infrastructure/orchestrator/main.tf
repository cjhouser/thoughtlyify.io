terraform {
  required_version = "~> 1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
  }
}

locals {
  short_oidc_arn = split("/", aws_iam_openid_connect_provider.platform.arn)[1]
  k8s_common_annotations = {
    "thoughtlyify.io/directory"  = "infrastructure/orchestrator/"
    "thoughtlyify.io/repository" = "github.com/cjhouser/thoughtlyify.io"
  }
  k8s_common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
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

provider "kubernetes" {
  host                   = aws_eks_cluster.platform.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.platform.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.platform.name]
    command     = "aws"
  }
}

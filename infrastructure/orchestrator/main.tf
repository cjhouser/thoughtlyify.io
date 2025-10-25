terraform {
  required_version = "~> 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
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

provider "kubernetes" {
  host                   = aws_eks_cluster.platform.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.platform.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.platform.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.platform.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.platform.certificate_authority[0].data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.platform.name]
      command     = "aws"
    }
  }
}

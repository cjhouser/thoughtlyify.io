data "aws_iam_policy_document" "authn_eks_cluster" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_user" "chouser" {
  user_name = "charles.houser"
}

data "aws_iam_policy_document" "authn_eks_node" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "authz_ipv6_cni" {
  statement {
    actions = [
      "ec2:AssignIpv6Addresses",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceTypes"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "ec2:CreateTags"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }
}

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

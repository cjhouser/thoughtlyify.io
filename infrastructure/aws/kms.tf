resource "aws_kms_key" "openbao" {
  description             = "Openbao seal key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
}

data "aws_iam_policy_document" "authz_openbao" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.openbao.arn,
      ]
    }
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
    resources = [
      "*",
    ]
  }
}

resource "aws_kms_key_policy" "openbao" {
  key_id = aws_kms_key.openbao.id
  policy = data.aws_iam_policy_document.authz_openbao.json
}

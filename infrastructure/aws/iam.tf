#############
### ROLES ###
#############
resource "aws_iam_role" "eks_cluster_role" {
  assume_role_policy = data.aws_iam_policy_document.authn_eks_cluster.json
  name               = "eks_cluster_role"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = data.aws_iam_policy.eks_cluster_policy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node" {
  assume_role_policy = data.aws_iam_policy_document.authn_eks_node.json
  name               = "eks_node"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = data.aws_iam_policy.eks_worker_node_policy.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = data.aws_iam_policy.ec2_container_registry_read_only.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_pull_only" {
  policy_arn = data.aws_iam_policy.ec2_container_registry_pull_only.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "ipv6_cni" {
  policy_arn = aws_iam_policy.ipv6_cni.arn
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  name               = "AmazonEKS_EBS_CSI_Driver"
  assume_role_policy = data.aws_iam_policy_document.authn_pod_identity.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = data.aws_iam_policy.eks_ebs_csi_driver.arn
  role       = aws_iam_role.eks_ebs_csi_driver.name
}

resource "aws_iam_role" "load_balancer_controller" {
  name               = "AWSLoadBalancerController"
  assume_role_policy = data.aws_iam_policy_document.authn_pod_identity.json
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  policy_arn = aws_iam_policy.load_balancer_controller.arn
  role       = aws_iam_role.load_balancer_controller.name
}

resource "aws_iam_role" "openbao" {
  name               = "openbao"
  assume_role_policy = data.aws_iam_policy_document.authn_pod_identity.json
}

resource "aws_iam_role_policy_attachment" "openbao" {
  policy_arn = aws_iam_policy.openbao.arn
  role       = aws_iam_role.openbao.name
}

#####################
### AUTHORIZATION ###
#####################
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

resource "aws_iam_policy" "ipv6_cni" {
  description = "ipv6 CNI EKS"
  name        = "ipv6_cni"
  path        = "/"
  policy      = data.aws_iam_policy_document.authz_ipv6_cni.json
}

data "aws_iam_policy_document" "authz_load_balancer_controller" {
  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "elasticloadbalancing.amazonaws.com",
      ]
    }
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "ec2:CreateSecurityGroup",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "ec2:CreateTags",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateSecurityGroup",
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
  }
  statement {
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "true",
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
    ]
  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
    ]
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
    ]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "true",
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
    ]
    condition {
      test     = "StringEquals"
      variable = "elasticloadbalancing:CreateAction"
      values = [
        "CreateTargetGroup",
        "CreateLoadBalancer",
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup",
    ]
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values = [
        "false",
      ]
    }
    effect = "Allow"
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule",
    ]
    effect = "Allow"
    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "authz_openbao" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    effect = "Allow"
    resources = [
      aws_kms_key.openbao.arn,
    ]
  }
}

resource "aws_iam_policy" "load_balancer_controller" {
  name   = "AWSLoadBalancerController"
  path   = "/"
  policy = data.aws_iam_policy_document.authz_load_balancer_controller.json
}

resource "aws_iam_policy" "openbao" {
  name   = "openbao"
  path   = "/"
  policy = data.aws_iam_policy_document.authz_openbao.json
}

######################
### AUTHENTICATION ###
######################
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

data "aws_iam_policy_document" "authn_pod_identity" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "pods.eks.amazonaws.com",
      ]
    }
  }
}
